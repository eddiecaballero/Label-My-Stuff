//
//  CreateCollectionViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 4/30/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "CreateCollectionViewController.h"
#import "CollectionCell.h"
#import "DisplayViewController.h"
#import "AppDelegate.h"
#import "NSFileManager+Additions.h"
#import "UIView+Additions.h"

#pragma mark - # Defines

#define plusTag 0
#define trashTag 1
#define addToTag 2

@interface CreateCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *selectedItemsURLs;
@property (nonatomic, assign) BOOL isSharing;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UILabel *noPhotoLabel;
@property (nonatomic, strong) UIBarButtonItem *addButtonItem;

@end

@implementation CreateCollectionViewController
{
    NSUInteger _numberOfSelectedItems;
}

#pragma mark - Custom Accessors

-(NSMutableArray *)selectedItemsURLs
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    
    NSMutableArray *selectedItemsURLs = [[NSMutableArray alloc] init];
    
    for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [selectedItemsURLs addObject:(NSURL *)contents[indexPath.row]];
    }
    return selectedItemsURLs;
}

#pragma mark - Helper Methods (Camera)

-(BOOL)startCameraControllerFromViewController:(UIViewController *)controller
                                 usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - Helper Methods (Photo Library)

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    mediaUI.delegate = delegate;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        #ifndef NSFoundationVersionNumber_iOS_8_0
        #define NSFoundationVersionNumber_iOS_8_0 1134.10 //extract with NSLog(@"%f", NSFoundationVersionNumber) or from previous iOS version headers
        #endif
        
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)
        {
            #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                mediaUI.modalPresentationStyle = UIModalPresentationPopover;
                
                [self presentViewController:mediaUI animated:YES completion:nil];

                UIPopoverPresentationController *popover = mediaUI.popoverPresentationController;

                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
                popover.barButtonItem = self.addButtonItem;
                popover.delegate = self;
            }];
            
            #endif
        }
        else
        {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
            self.popover.delegate = self;

            [self.popover presentPopoverFromBarButtonItem:self.addButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        [controller presentViewController:mediaUI animated:YES completion:nil];
    }
    
    return YES;
}

#pragma mark - Helper Methods (Navigation Bar and Toolbar)

-(void)setUpNormalNavigationBarAndToolbar
{
     self.addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(plus:)];
    
    self.navigationItem.rightBarButtonItem = self.addButtonItem;
    self.navigationItem.hidesBackButton = NO;

    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                  target:self action:@selector(shareButtonTapped:)];

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil
                                   action:nil];
    
    [self setToolbarItems:@[shareItem, spaceItem] animated:YES];
}

-(void)setUpSharingNavigationBarAndToolbar
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                         target:self
                                         action:@selector(shareButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sharing", nil)
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(activity)];
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil
                                   action:nil];
    UIBarButtonItem *addToItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add To", nil)
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                 action:@selector(addTo:)];
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil
                                   action:nil];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                  action:@selector(trash:)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                               action:@selector(plus:)];
    
    [shareItem setEnabled:NO];
    [addToItem setEnabled:NO];
    [deleteItem setEnabled:NO];
    [deleteItem setTintColor:[UIColor redColor]];
    [addItem setEnabled:YES];
    
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    if ([contents count] == 0)
    {
        [self setToolbarItems:@[shareItem, spaceItem1, addItem, spaceItem2, deleteItem] animated:YES];
    }
    else
    {
        [self setToolbarItems:@[shareItem, spaceItem1, addToItem, spaceItem2, deleteItem] animated:YES];
    }
}

#pragma mark - Helper Methods (Directory Management)

-(void)saveAlbumWithName:(NSString *)albumName
{
    if ([[NSFileManager defaultManager] eec_createAlbumWithName:albumName])
    {
        if ([self addSelectedItemsURLs:self.selectedItemsURLs toDirectory:albumName])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(BOOL)addSelectedItemsURLs:(NSArray *)selectedItemsURLs toDirectory:(NSString *)directory
{
    for (NSURL *sourceURL in selectedItemsURLs)
    {
        NSURL *destinationURL = [[[[sourceURL URLByDeletingLastPathComponent]               //source file removed
                                   URLByDeletingLastPathComponent]                          //source folder removed
                                  URLByAppendingPathComponent:directory isDirectory:YES]    //destination folder added
                                 URLByAppendingPathComponent:sourceURL.lastPathComponent];  //source file added
        
        NSError *error;
        if(![[NSFileManager defaultManager]fileExistsAtPath:destinationURL.path])
        {
            if(![[NSFileManager defaultManager] moveItemAtURL:sourceURL toURL:destinationURL error:&error])
            {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Helper Methods (Background Image)

-(void)setupBackgroundImage
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.currentURL
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    if ([contents count] == 0)
    {
        //1. View
        if (self.backgroundImage == nil)
        {
            self.backgroundImage = [[UIImageView alloc] init];
            
            //Add View
            [self.view insertSubview:self.backgroundImage belowSubview:self.view];
            
            //Add Constraints (Start)
            [self.backgroundImage setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            UIView *backgroundIV = self.backgroundImage;
            NSDictionary *backgroundIVElementsDictionary = NSDictionaryOfVariableBindings(backgroundIV);
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backgroundIV(212)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:backgroundIVElementsDictionary]];
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backgroundIV(212)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:backgroundIVElementsDictionary]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImage
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImage
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0]];
            //Add Constraints (End)
        }
        
        [self.backgroundImage setImage:[UIImage imageNamed:@"nophoto.png"]];
        
        //2. Label
        if (self.noPhotoLabel == nil)
        {
            self.noPhotoLabel = [UIView eec_addLabelWithText:nil toView:self.view anchorToView:self.backgroundImage];
        }
        
        self.noPhotoLabel.text = NSLocalizedString(@"No Photos. You can add photos via device camera or accessing the camera roll.", nil);
    }
    else
    {
        self.backgroundImage.image = nil;
        self.noPhotoLabel.text = nil;
    }
}

#pragma mark - Target & Action

-(void)activity
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    
    NSMutableArray *selectedItemsURLs = [[NSMutableArray alloc] init];
    NSMutableArray *selectedItemsImages = [[NSMutableArray alloc] init];
    
    for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [selectedItemsURLs addObject:(NSURL *)contents[indexPath.row]];
    }
    
    for (NSURL *url in selectedItemsURLs)
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
        [selectedItemsImages addObject:image];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:selectedItemsImages
                                                                                         applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)plus:(id)sender
{
    NSString *alertTitle = NSLocalizedString(@"How would you like to add picture?", nil);
    NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
    NSString *alertCamera = NSLocalizedString(@"Camera", nil);
    NSString *alertMediaLibrary = NSLocalizedString(@"Photo Album", nil);
    
    Class UIAlertControllerClass = NSClassFromString(@"UIAlertController");
    
    if (UIAlertControllerClass)
    {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:alertCamera
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self startCameraControllerFromViewController:self usingDelegate:self];
                                                             }];
        UIAlertAction *mediaLibraryAction = [UIAlertAction actionWithTitle:alertMediaLibrary
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self startMediaBrowserFromViewController:self usingDelegate:self];
                                                             }];
        [alertController addAction:cancelAction];
        [alertController addAction:cameraAction];
        [alertController addAction:mediaLibraryAction];
        
        //For iPad popOver
        alertController.popoverPresentationController.barButtonItem = sender;
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        #endif
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                                 delegate:self
                                                        cancelButtonTitle:alertCancel
                                                   destructiveButtonTitle:alertCamera //FIX THIS - Camera should not be under Destructive
                                                        otherButtonTitles:alertMediaLibrary, nil];
        actionSheet.tag = plusTag;
        actionSheet.delegate = self; //just added this to test cancel delegate
        [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
    }
}

-(void)shareButtonTapped:(id)sender
{
    if (!self.isSharing)
    {
        self.isSharing = YES;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Select Photo", nil)];
        [self setUpSharingNavigationBarAndToolbar];
        [self.collectionView setAllowsMultipleSelection:YES];
    }
    else
    {
        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
        {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];

            [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
        }
        [self.collectionView reloadData];

        self.isSharing = NO;
        self.title = [self.currentURL lastPathComponent];

        [self setUpNormalNavigationBarAndToolbar];

        [self.collectionView setAllowsMultipleSelection:NO];
    }
}

-(void)addTo:(id)sender
{
    NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
    NSString *alertExisting = NSLocalizedString(@"Add to Existing Album", nil);
    NSString *alertNew = NSLocalizedString(@"Add to New Album", nil);
    
    Class UIAlertControllerClass = NSClassFromString(@"UIAlertController");
    
    if (UIAlertControllerClass)
    {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *existingAction = [UIAlertAction actionWithTitle:alertExisting
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self performSegueWithIdentifier:@"addTo" sender:self];
                                                             }];
        UIAlertAction *newAction = [UIAlertAction actionWithTitle:alertNew
                                                            style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", nil)
                                                                                                                                        message:NSLocalizedString(@"Enter a name for this album", nil)
                                                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                               [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
                                                                {
                                                                    [textField addTarget:self
                                                                                  action:@selector(alertTextFieldDidChange:)
                                                                        forControlEvents:UIControlEventEditingChanged];
                                                                }];
                                                               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                                                                      style:UIAlertActionStyleCancel
                                                                                                                    handler:nil];
                                                               UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil)
                                                                                                                    style:UIAlertActionStyleDefault
                                                                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                      NSString *albumName = alertController.textFields.firstObject.text;
                                                                                                                      
                                                                                                                      [self saveAlbumWithName:albumName];
                                                                                                                  }];
                                                               [alertController addAction:cancelAction];
                                                               [alertController addAction:saveAction];
                                                               
                                                               saveAction.enabled = NO;
                                                               
                                                               [self presentViewController:alertController animated:YES completion:nil];
                                                           }];
        [alertController addAction:cancelAction];
        [alertController addAction:existingAction];
        [alertController addAction:newAction];
        
        //For iPad popOver
        alertController.popoverPresentationController.barButtonItem = sender;
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        #endif
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:alertCancel
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:alertExisting, alertNew, nil];
        actionSheet.tag = addToTag;
        [actionSheet showInView:self.view];
    }
}

-(void)trash:(id)sender
{
    NSString *alertCancel = NSLocalizedString(@"Cancel", nil);
    NSString *alertDelete = NSLocalizedString(@"Delete Photo", nil);
    
    Class UIAlertControllerClass = NSClassFromString(@"UIAlertController");
    
    if (UIAlertControllerClass)
    {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:alertCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:alertDelete
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self trashHandler];
                                                             }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        
        //For iPad popOver
        alertController.popoverPresentationController.barButtonItem = sender;
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        #endif
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:alertCancel destructiveButtonTitle:alertDelete otherButtonTitles:nil, nil];
        actionSheet.tag = trashTag;
        [actionSheet showInView:self.view];
    }
}

#pragma mark - AlertController Handlers

-(void)trashHandler
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    
    NSMutableArray *selectedItemsURLs = [[NSMutableArray alloc] init];
    for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [selectedItemsURLs addObject:(NSURL *)contents[indexPath.row]];
    }
    
    error = nil;
    for (NSURL *url in selectedItemsURLs)
    {
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];

        _numberOfSelectedItems--;
    }
    
    [self setupBackgroundImage];
    [self.collectionView reloadData];
    
    //1. ShareMode Off
    [self shareButtonTapped:self];
}

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

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpNormalNavigationBarAndToolbar];
    
    [self backgroundImage];
    
    self.title = [self.currentURL lastPathComponent];
    
    self.isSharing = NO;
    
    _numberOfSelectedItems = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupBackgroundImage];
    
    [self.collectionView reloadData];
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == addToTag)
    {
        if (buttonIndex == 1)
        {
            NSString *albumName = [alertView textFieldAtIndex:0].text;
            
            [self saveAlbumWithName:albumName];
        }
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == addToTag)
    {
        if ([[[alertView textFieldAtIndex:0] text] length] > 0)
            return YES;
        else
            return NO;
    }
    return YES;
}

#pragma mark - ActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == plusTag)
    {
        if (buttonIndex == 0)
        {
            [self startCameraControllerFromViewController:self usingDelegate:self];
        }
        
        if (buttonIndex == 1)
        {
            [self startMediaBrowserFromViewController:self usingDelegate:self];
        }
    }
    
    if (actionSheet.tag == trashTag)
    {
        if (buttonIndex == 0)//destructive
        {
            [self trashHandler];
        }
        
        if (buttonIndex == 1)//cancel
        {
            //1. ShareMode Off
            //[self shareButtonTapped:self];
        }
    }
    
    if (actionSheet.tag == addToTag)
    {
        if (buttonIndex == 0)
        {
            [self performSegueWithIdentifier:@"addTo" sender:self];
        }
        
        if (buttonIndex == 1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Album", nil)
                                                            message:NSLocalizedString(@"Enter a name for this album", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = addToTag;
            alert.delegate = self;
            [alert textFieldAtIndex:0].delegate = self;
            [alert textFieldAtIndex:0].enablesReturnKeyAutomatically = YES;
            [alert show];
        }
    }
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([UIAlertView class])
    {
        [(UIAlertView *)[textField superview] dismissWithClickedButtonIndex:1 animated:YES];
        
        [self saveAlbumWithName:textField.text];
    }
    
    return YES;
}

#pragma mark - AddToViewControllerDelegate

-(void)AddToViewController:(AddToViewController *)addToViewController didSelectDirectory:(NSString *)directory
{
    [self addSelectedItemsURLs:addToViewController.selectedItemsURLs toDirectory:directory];
    
    [self setupBackgroundImage];
    [self.collectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)AddToViewControllerDidCancel:(AddToViewController *)addToViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImagePicker Controller Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSString *dataPath = [NSString stringWithFormat:@"%@/image_%f.png", [self.currentURL path], [[NSDate date] timeIntervalSince1970]];
    
    [[NSFileManager defaultManager] createFileAtPath:dataPath contents:UIImagePNGRepresentation(image) attributes:nil];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.collectionView reloadData];
    [self setupBackgroundImage];
    
    if (self.isSharing) //For when AddTo: calls Plus: when no images in directory.
    {
        [self shareButtonTapped:self];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionView (DataSource)

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.currentURL
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    return [contents count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    
    NSURL *url = contents[indexPath.row];

    UIImage *image = [UIImage imageWithContentsOfFile:[url path]];

    cell.cellImage.image = image;
    
    //Check if Cell needs CheckMark (For when Scrolling).
    if (self.isSharing)
    {
        if ([self.collectionView.indexPathsForSelectedItems containsObject:indexPath])
        {
            [cell checkMark];
        }
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - CollectionView (Delegate)

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isSharing)
    {
        [self performSegueWithIdentifier:@"collectionToDisplay" sender:self];
    }
    else
    {
        CollectionCell *cell = (CollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

        [cell checkMark];

        _numberOfSelectedItems++;

        if (_numberOfSelectedItems == 1)
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%lu Photo Selected", nil), (unsigned long)_numberOfSelectedItems];
            
            for (UIBarButtonItem *buttonItem in self.toolbarItems)
            {
                [buttonItem setEnabled:YES];
            }
        }
        else
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%lu Photos Selected", nil), (unsigned long)_numberOfSelectedItems];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSharing)
    {
        CollectionCell *cell = (CollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.cellImage.layer.borderWidth = 3.0f;
        cell.cellImage.layer.borderColor = [UIColor clearColor].CGColor;
        
        [cell unCheckMark];
        
        _numberOfSelectedItems--;

        if (_numberOfSelectedItems == 0)
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"Select Photo", nil)];
            
            for (UIBarButtonItem *buttonItem in self.toolbarItems)
            {
                [buttonItem setEnabled:NO];
            }
        }
        else if (_numberOfSelectedItems == 1)
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%lu Photo Selected", nil), (unsigned long)_numberOfSelectedItems];
        }
        else
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%lu Photos Selected", nil), (unsigned long)_numberOfSelectedItems];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout (Delegate)

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    float lenght = (screenWidth / 2) - 5.0f;

    return CGSizeMake(lenght, lenght);
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"collectionToDisplay"])
    {
        // Get the new view controller using [segue destinationViewController].
        DisplayViewController *vc = [segue destinationViewController];
        
        // Pass the selected object to the new view controller.
        NSError *error;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self currentURL]
                                                          includingPropertiesForKeys:@[]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:&error];

        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        [vc setCurrentImage:[UIImage imageWithContentsOfFile:[(NSURL *)contents[indexPath.row] path]]];
        [vc setCurrentURL:(NSURL *)contents[indexPath.row]];
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    if ([[segue identifier] isEqualToString:@"addTo"])
    {
        AddToViewController *destinationVC = [segue destinationViewController];
        destinationVC.delegate = self;
        
        // Pass the selected object to the new view controller.
        [destinationVC setSelectedItemsURLs:self.selectedItemsURLs];
        
        //1. ShareMode Off
        [self shareButtonTapped:self];
    }
}

@end
