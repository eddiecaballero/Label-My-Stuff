//
//  CreateTableViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 5/7/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "CreateTableViewController.h"
#import "CreateCollectionViewController.h"
#import "AppDelegate.h"
#import "PrintView.h"
#import "Folder.h"
#import "NSFileManager+Additions.h"
#import "TableCell.h"
#import "ECSlidingViewController.h"

#pragma mark - # Defines

#define plusTag 0

@interface CreateTableViewController ()

@property (nonatomic, strong) NSString *originalTextFieldText;

@end

@implementation CreateTableViewController

#pragma mark - Helper Methods (Navigation Bar and Toolbar)

-(void)setUpNavigationBarAndToolbar
{
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plus)];
    
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Menu", nil) style:UIBarButtonItemStyleDone target:self action:@selector(menu)];
    
    self.navigationItem.leftBarButtonItems = @[menuButtonItem, addButtonItem];
    
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                   target:self action:@selector(print)];

    [self setToolbarItems:@[actionItem] animated:YES];
}

#pragma mark - Target Action

-(void)plus
{
    NSString *alertTitle = NSLocalizedString(@"New Album", nil);
    NSString *alertMessage = NSLocalizedString(@"Enter a name for this album", nil);
    NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
    NSString *alertSave = NSLocalizedString(@"Save", nil);
    
    Class UIAlertControllerClass = NSClassFromString(@"UIAlertController");
    
    if (UIAlertControllerClass)
    {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
         {
             [textField addTarget:self
                           action:@selector(alertTextFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:alertSave
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              NSString *newDirectoryName = alertController.textFields.firstObject.text;
                                                              
                                                              [[NSFileManager defaultManager] eec_createAlbumWithName:newDirectoryName];
                                                              
                                                              [self.tableView reloadData];
                                                          }];
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        
        saveAction.enabled = NO;
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        #endif
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:alertCancel
                                              otherButtonTitles:alertSave, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = plusTag;
        [alert show];
    }
}

-(void)print
{
    PrintViewController *pVC = [[PrintViewController alloc] initWithNibName:@"PrintView"
                                                                   bundle:nil];
    pVC.delegate = self;
    /*
     Note - It appears the target where you need to set modalPresentationStyle has changed. For example, in iOS 7, to get this to work, I needed to set the modalPresentationStyle of the View Controller(s) which was attempting to open the modal to UIModalPresentationCurrentContext. However, to get this to work in iOS8, I needed to set the modalPresentationStyle of the modal view which going to be displayed to UIModalPresentationOverCurrentContext.
     
     The point is that they moved the setting to the modal VC instead of the presenting VC
     
     ios7:
     presentingVC.modalPresentationStyle = UIModalPresentationCurrentContext;
     
     
     ios8:
     modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
     modalVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     
     and then in both:
     [presentingVC presentViewController:modalVC animated:YES completion:nil];
     */
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:pVC animated:YES completion:nil];
}

-(void)menu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - AlertController Handlers

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *textField = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = textField.text.length >= 1;
    }
    
    #endif
}

#pragma mark - Editing

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    //Note: Code below finds Refs to each UITextField in each Cell in the UITableView in order to setUserInteraction for iOS7 or Above and for iOS6.
    if (editing)
    {
        for (id cell in self.tableView.subviews)
        {
            if ([NSStringFromClass([cell class]) isEqualToString:@"UITableViewWrapperView"])
            {
                for (id cell2 in [(UIView *)cell subviews])
                {
                    if([cell2 isMemberOfClass:[TableCell class]])
                    {
                        TableCell *tableCell = cell2;
                        
                        for (id textField in tableCell.contentView.subviews)
                        {
                            if ([textField isKindOfClass:[UITextField class]])
                            {
                                UITextField *theTextField = (UITextField *)textField;
                                
                                [cell setUserInteractionEnabled:YES];
                                [theTextField setUserInteractionEnabled:YES];
                            }
                        }
                    }
                }
            }
            else
            {
                if([cell isMemberOfClass:[TableCell class]])
                {
                    TableCell *tableCell = cell;
                    
                    for (id textField in tableCell.contentView.subviews)
                    {
                        if ([textField isKindOfClass:[UITextField class]])
                        {
                            UITextField *theTextField = (UITextField *)textField;
                            
                            [theTextField setUserInteractionEnabled:YES];
                        }
                    }
                }
            }
        }
    }
    
    if (!editing)
    {
        for (id cell in self.tableView.subviews)
        {
            if ([NSStringFromClass([cell class]) isEqualToString:@"UITableViewWrapperView"])
            {
                for (id cell2 in [(UIView *)cell subviews])
                {
                    if([cell2 isMemberOfClass:[TableCell class]])
                    {
                        TableCell *tableCell = cell2;
                        
                        for (id textField in tableCell.contentView.subviews)
                        {
                            if ([textField isKindOfClass:[UITextField class]])
                            {
                                UITextField *theTextField = (UITextField *)textField;
                                
                                if ([theTextField isEditing])
                                {
                                    [theTextField endEditing:YES];
                                }
                                [theTextField setUserInteractionEnabled:NO];
                            }
                        }
                    }
                }
            }
            else
            {
                for (id cell in self.tableView.subviews)
                {
                    if([cell isMemberOfClass:[TableCell class]])
                    {
                        TableCell *tableCell = cell;
                        
                        for (id textField in tableCell.contentView.subviews)
                        {
                            if ([textField isKindOfClass:[UITextField class]])
                            {
                                UITextField *theTextField = (UITextField *)textField;
                                
                                if ([theTextField isEditing])
                                {
                                    [theTextField endEditing:YES];
                                }
                                [theTextField setUserInteractionEnabled:NO];
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpNavigationBarAndToolbar];
    
    //http://stackoverflow.com/questions/30158315/admob-ads-not-appear-in-footer-of-uitableview-when-keyboard-is-shown
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeLeaderboard];
    }
    else
    {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    }
    
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = kadUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Alert View delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == plusTag)
    {
        if (buttonIndex == 1)
        {
            NSString *newDirectoryName = [alertView textFieldAtIndex:0].text;
            
            [[NSFileManager defaultManager] eec_createAlbumWithName:newDirectoryName];
            
            [self.tableView reloadData];
        }
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == plusTag)
    {
        if ([[[alertView textFieldAtIndex:0] text] length] > 0)
            return YES;
        else
            return NO;
    }
    return YES;
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self setEditing:NO animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.originalTextFieldText = [textField text];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField text] != self.originalTextFieldText)
    {
        NSString *oldDirectoryName = self.originalTextFieldText;
        NSString *newDirectoryName = [textField text];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        
        NSString *oldDirectoryPath = [documentsDirectory stringByAppendingPathComponent:oldDirectoryName];
        NSString *newDirectoryPath = [documentsDirectory stringByAppendingPathComponent:newDirectoryName];
        
        NSURL *oldDirectoryURL = [NSURL fileURLWithPath:oldDirectoryPath];
        NSURL *newDirectoryURL = [NSURL fileURLWithPath:newDirectoryPath];
        
        NSError *error;
        if ([[NSFileManager defaultManager] moveItemAtURL: oldDirectoryURL toURL: newDirectoryURL error: &error])
        {
            [[NSFileManager defaultManager] eec_updateCoreDataWithRenamedDirectory:oldDirectoryName withNewDirectory:newDirectoryName];
            
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Print View Controller Delegate

-(void)PrintViewControllerDidFinishPrinting:(PrintViewController *)printViewController
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:NO completion:NULL];
    });
}

#pragma mark - Google Ad Banner Delegate (Optional)

-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.tableView.tableHeaderView = self.bannerView;
    self.tableView.sectionHeaderHeight = self.bannerView.adSize.size.height;
}

-(void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    self.tableView.sectionHeaderHeight = 0.0f;
    self.bannerView = nil;
}

//-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    self.tableView.sectionHeaderHeight = 0.0f;
//    self.bannerView = nil;
//}

#pragma mark - Table view data source (Required)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = (TableCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *directories = [[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory];
    
    cell.textField.text = directories[indexPath.row];
    cell.textField.delegate = self;
    
    return cell;
}

#pragma mark - Table view data source (Optional)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray *directories = [[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory];
        
        NSString *selectedDirectory = [NSString stringWithFormat:@"/%@", directories[indexPath.row]];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        
        NSURL *url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:selectedDirectory]];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
        
        [[NSFileManager defaultManager] eec_deleteCoreDataEntryWithURL:url];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"tableToCollection"])
    {
        // Get the new view controller using [segue destinationViewController].
        CreateCollectionViewController *vc = [segue destinationViewController];
        
        // Pass the selected object to the new view controller.
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *directories = [[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        NSString *selectedDirectory = [NSString stringWithFormat:@"/%@", directories[indexPath.row]];
        NSURL *url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:selectedDirectory]];
        
        [vc setCurrentURL:url];
    }
}

@end
