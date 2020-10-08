//
//  ScanViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 4/30/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "CreateCollectionViewController.h"
#import "ECSlidingViewController.h"
#import "AppDelegate.h"
#import "Folder.h"

@interface ScanViewController ()

@property (nonatomic, strong) NSString *scannedResult;

- (IBAction)scan:(id)sender;

@end

@implementation ScanViewController

#pragma mark - Helper Methods (Navigation and Toolbar)

-(void)setUpNavigationBarAndToolbar
{
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Menu", nil)
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(menu)];
    self.navigationItem.leftBarButtonItem = menuButtonItem;
}

#pragma mark - Helper Methods (Camera availability)

-(BOOL)isCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    return [videoDevices count] > 0;
}

#pragma mark - Target & Action

- (IBAction)scan:(id)sender
{
    if ([self isCameraAvailable])
    {
        //Barcode Reader that scans from the camera feed
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        reader.supportedOrientationsMask = ZBarOrientationMaskAll;
        
        ZBarImageScanner *scanner = reader.scanner;
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology:ZBAR_I25
                       config:ZBAR_CFG_ENABLE
                           to:0];
        
        [self presentViewController:reader animated:YES completion:nil];
    }
}

-(void)menu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpNavigationBarAndToolbar];
}

-(BOOL)shouldAutorotate
{
    return [super shouldAutorotate];
}

#pragma mark - ZBar Reader Delegate (ZBar)

-(void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Get the decoded results.
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for (symbol in results)
    {
        //Just grabs first barcode
        break;
    }
    self.scannedResult = symbol.data; //Ready for segue (what we were looking for)
    
    [reader dismissViewControllerAnimated:YES completion:nil]; //has to be dismissed from the reader
    
    //Use to be part of scan...Had to change storyboard to support this.
    [self performSegueWithIdentifier:@"scan" sender:self];
}

#pragma mark - Segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)
    {
        //
    }
    
    [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[(Folder *)obj id] isEqualToString:self.scannedResult])
        {
            self.scannedResult = [(Folder *)obj name];
        }
    }];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *selectedDirectory = [NSString stringWithFormat:@"/%@", self.scannedResult];
    NSURL *url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:selectedDirectory]];
    
    [[segue destinationViewController] setCurrentURL:url];
}

@end
