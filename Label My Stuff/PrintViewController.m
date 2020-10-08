//
//  PrintViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 8/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "PrintViewController.h"
#import "AppDelegate.h"
#import "PrintView.h"
#import "Folder.h"
#import <ZXingObjC/ZXingObjC.h>

@interface PrintViewController ()

@end

@implementation PrintViewController

#pragma mark - Helper Method (Print)

-(UIImage *)encodeImageForFolder:(NSString *)folder
{
    NSError* error = nil;
    ZXMultiFormatWriter* writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:folder
                                  format:kBarcodeFormatQRCode
                                   width:500
                                  height:500
                                   error:&error];
    UIImage *image = nil;
    
    if (result)
    {
        CGImageRef imageRef = [[ZXImage imageWithMatrix:result] cgimage];
        
        image = [UIImage imageWithCGImage:imageRef];
    }
    
    return image;
}

-(void)clearPrintView
{
    PrintView *printView = (PrintView *)self.view;
    
    for (int i = 0; i < printView.labels.count; i++)
    {
        [(UILabel *)printView.labels[i] setText:nil];
        [(UIImageView *)printView.imageViews[i] setImage:nil];
    }
}

- (void)createPDFWithPages:(NSArray *)array fileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *PDFPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",fileName]];
    
    NSMutableArray * imageArray = [[NSMutableArray alloc] init];
    for (NSData *data in array)
    {
        [imageArray addObject:[UIImage imageWithData:data]];
    }
    
    UIGraphicsBeginPDFContextToFile(PDFPath, CGRectZero, nil);
    for (UIImage *image in imageArray)
    {
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, image.size.width, image.size.height), nil);
        
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    UIGraphicsEndPDFContext();
}

-(void)addPageToPages:(NSMutableArray *)pages
{
    PrintView *printView = (PrintView *)self.view;
    
    UIGraphicsBeginImageContext(printView.bounds.size);
    [printView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *page = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [pages addObject:UIImagePNGRepresentation(page)];
}

-(NSArray *)readyPages
{
    [self.view setHidden:NO];
    
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)
    {
        NSLog(@"x. Fetch Request: Error handing code.");
    }
    
    [self clearPrintView];
    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    
    __block NSUInteger index = 0;
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        PrintView *printView = (PrintView *)self.view;
        
        if (index == printView.labels.count)
        {
            index = 0;
            
            [self addPageToPages:pages];
            
            [self clearPrintView];
        }
        
        [(UILabel *)printView.labels[index] setText:[(Folder *)obj name]];
        UIImage *encodedImage = [self encodeImageForFolder:[(Folder *)obj id]];
        [(UIImageView *)printView.imageViews[index] setImage:encodedImage];
        
        index++;
    }];
    
    [self addPageToPages:pages];
    
    [self.view setHidden:YES];
    
    return pages;
}

-(void)print
{
    UIPrintInteractionController *printer = [UIPrintInteractionController sharedPrintController];
    printer.delegate = self;
    
    UIPrintInfo *info = [UIPrintInfo printInfo];
    info.orientation = UIPrintInfoOrientationLandscape;
    info.outputType = UIPrintInfoOutputGrayscale;
    
    info.duplex = UIPrintInfoDuplexLongEdge;
    info.jobName = @"Label My Stuff";
    
    printer.printInfo = info;
    printer.showsPageRange = YES;
    
    NSArray *items = [self readyPages];
    
    printer.printingItems = items;
    //[self createPDFWithPages:items fileName:@"Label My Stuff"];
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
        if (!completed && error)
            NSLog(@"FAILED! due to error in domain %@ with error code %ld: %@",
                  error.domain, (long)error.code, [error localizedDescription]);
        
        [self removeFromParentViewController];
    };
    
    [printer presentAnimated:YES completionHandler:completionHandler];
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self print];
}

#pragma mark - UIPrintInteractionControllerDelegate

-(void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController
{
    [self removeFromParentViewController];
}

-(void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [self removeFromParentViewController];
}

-(void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.delegate PrintViewControllerDidFinishPrinting:self];
    });
}

@end
