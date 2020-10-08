//
//  DisplayViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 5/11/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "DisplayViewController.h"
#import <BCGenieEffect/UIView+Genie.h>
#import "NSFileManager+Additions.h"

#pragma mark - # Defines

#define destructiveTrashTag 0
#define cancelTrashTag 1

@interface DisplayViewController ()

@property (assign, nonatomic) BOOL hiddenNavigationBarAndToolBar;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGRect endRect;
@property (strong, nonatomic) UIView *trashView;
@property (strong, nonatomic) UIImageView *displayImage;
@property (strong, nonatomic) UIImageView *neoDisplayImageView;
@property (strong, nonatomic) UIBarButtonItem *trashItem;

@end

@implementation DisplayViewController

#pragma mark - Helper Methods (Status, Title, Navigation Bar and Toolbar)

/*
 "View controller-based status bar appearance" in info.plist must be set to 'YES' inorder to change StatusBarStyle.
 "View controller-based status bar appearance" in info.plist must be set to 'NO' inorder to hide StatusBar.
 
 Left "View controller-based status bar appearance" as YES and Im hiding status via a 3rd party solution instead of,
 
 Code for -(void)showStatusBar and -(void)hideStatusBar methods both from: http://stackoverflow.com/questions/21413294/remove-status-bar-programmatically-in-imagepickercontroller-ios-7/27339754#27339754
*/

- (void)showStatusBar
{
    UIWindow *statusBarWindow = [(UIWindow *)[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    CGRect frame = statusBarWindow.frame;
    frame.origin.y = 0;
    statusBarWindow.frame = frame;
}

- (void)hideStatusBar
{
    UIWindow *statusBarWindow = [(UIWindow *)[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    CGRect frame = statusBarWindow.frame;
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    frame.origin.y = -statuBarFrameSize.height;
    statusBarWindow.frame = frame;
}

-(void)setUpNavigationBarAndToolbar
{
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                 target:self  action:@selector(activity)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil action:nil];
    
    self.trashItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"closedtrash.png"] style:UIBarButtonItemStylePlain target:self action:@selector(trash:)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self setToolbarItems:@[shareItem, spaceItem, self.trashItem]];
}

-(void)setCurrentTitle
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self.currentURL URLByDeletingLastPathComponent]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    if (error)
    {
        
    }
    
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self.currentURL isEqual:obj])
        {
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%lu of %lu", nil), idx+1, (unsigned long)contents.count];
        }
    }];
}

#pragma mark - Helper Methods (View)

-(void)setUpDisplayView
{
    self.displayImage = [[UIImageView alloc] init];
    [self.view addSubview:self.displayImage];
    
    //Add Constraints (Start)
    [self.displayImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *displayIV = self.displayImage;
    NSDictionary *displayElementsDictionary = NSDictionaryOfVariableBindings(displayIV);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[displayIV]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:displayElementsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[displayIV]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:displayElementsDictionary]];
    //Add Constraints (End)
    
    [self.displayImage setContentMode:UIViewContentModeScaleAspectFit];
    self.displayImage.image = self.currentImage;
}

#pragma mark - Helper Methods (GestureRecognizer)

-(void)setUpGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - Helper Methods (Timer)

-(void)setupTimer
{
    self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(respondToTapGesture) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(void)invalidateTimer
{
    [self.timer invalidate];
}

#pragma mark - Helper Methods (Trash)

-(NSURL *)newDisplayViewURL
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[self currentURL] URLByDeletingLastPathComponent]
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
    __block NSURL *newURL = nil;
    [contents enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
        
        if ([self.currentURL isEqual:obj])
        {
            if (idx == 0 && [contents count] <= 1) //Deleting first image and this would be the last one
            {
                newURL = nil;
            }
            else if (idx == 0 && [contents count] > 1) //Deleting first image and this would not be the last one
            {
                NSInteger i = idx;
                newURL = contents[++i];
            }
            else //Deleting any image but the first image
            {
                NSInteger i = idx;
                newURL = contents[--i];
            }
        }
    }];
    return newURL;
}

-(void)setUpNewDisplayViewWithURL:(NSURL *)url
{
    if (url == nil)
    {
        if (self.neoDisplayImageView == nil)
        {
            self.neoDisplayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nophoto.png"]];
        }
        else
        {
            [self.neoDisplayImageView setImage:[UIImage imageNamed:@"nophoto.png"]];
        }
    }
    else
    {
        if (self.neoDisplayImageView == nil)
        {
            self.neoDisplayImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:url.path]];
        }
        else
        {
            [self.neoDisplayImageView setImage:[UIImage imageWithContentsOfFile:url.path]];
        }
    }
    
    self.neoDisplayImageView.contentMode = self.displayImage.contentMode;
    
    [self.view insertSubview:self.neoDisplayImageView belowSubview:self.displayImage];
    
    //Add Constraints (Start)
    [self.neoDisplayImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *newIV = self.neoDisplayImageView;
    NSDictionary *newElementsDictionary = NSDictionaryOfVariableBindings(newIV);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newIV]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:newElementsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newIV]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:newElementsDictionary]];
    //Add Constraints (End)
}

-(void)animateTrashWithURL:(NSURL *)url
{
    [self.trashItem setImage:[UIImage imageNamed:@"opentrash.png"]];
    
    CGRect endRect = self.trashView.frame;
    [self.displayImage genieInTransitionWithDuration:0.7 destinationRect:endRect destinationEdge:BCRectEdgeTop completion:^{
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:self.currentURL error:&error];
        self.currentURL = url;
        
        //Set new view as main view
        [self.displayImage removeFromSuperview];
        self.displayImage = self.neoDisplayImageView;
        self.neoDisplayImageView = nil;
        
        
        [self.trashItem setImage:[UIImage imageNamed:@"closedtrash.png"]];
        
        if (url == nil)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self setCurrentTitle];
        }
    }];
}

-(void)setupTrashView
{
    self.trashView = [[UIView alloc] init];
    
    [self.view addSubview:self.trashView];
    
    [self.trashView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *trashV = self.trashView;
    NSDictionary *elementsDictionary = NSDictionaryOfVariableBindings(trashV);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trashV]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:elementsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[trashV]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:elementsDictionary]];
}

#pragma mark - Target & Action

-(void)activity
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.currentImage]
                                                                                         applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{
        [self.timer invalidate];
    }];
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
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self setupTimer];
                                                             }];
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
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:alertCancel
                                                   destructiveButtonTitle:alertDelete
                                                        otherButtonTitles:nil, nil];
        actionSheet.delegate = self;
        [actionSheet showFromBarButtonItem:self.trashItem animated:YES];
    }
    
    [self.timer invalidate];
}

#pragma mark - AlertController Handlers

-(void)trashHandler
{
    NSURL *url = [self newDisplayViewURL];
    
    [self setUpNewDisplayViewWithURL:url];
    
    [self animateTrashWithURL:url];
    
    [self setupTimer];
}

#pragma mark - Touch & Gestures

-(void)respondToTapGesture
{
    if (self.hiddenNavigationBarAndToolBar)
    {
        self.hiddenNavigationBarAndToolBar = NO;
        
        //So showStatusBar method animates in synch with Navigation and ToolBar methods.
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             [self.navigationController setNavigationBarHidden:NO animated:NO]; //1
             [self.navigationController setToolbarHidden:NO animated:NO]; //2
             [self showStatusBar]; //3
         }
                         completion:nil];
        
        //Set Up Display Timer.
        self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(respondToTapGesture) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    else
    {
        //So hideStatusBar method animates in synch with Navigation and ToolBar methods.
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             [self.navigationController setNavigationBarHidden:YES animated:YES];
             [self.navigationController setToolbarHidden:YES animated:YES];
             [self hideStatusBar];
         }
                         completion:nil];

        
        self.hiddenNavigationBarAndToolBar = YES;

        [self.timer invalidate];
    }
}

#pragma mark - Status Bar

-(BOOL)prefersStatusBarHidden
{
    if (self.hiddenNavigationBarAndToolBar)
    {
        return self.hiddenNavigationBarAndToolBar;
    }
    else
    {
        return YES;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpNavigationBarAndToolbar];
    self.hiddenNavigationBarAndToolBar = NO;
    
    [self setCurrentTitle];
    
    [self setUpDisplayView];
    self.neoDisplayImageView = nil;
    
    [self setupTrashView];
    
    [self setUpGestureRecognizer];
    
    [self setupTimer];
    
    //Listen to Menu Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateTimer) name:@"MenuAppearedNotification" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

//Pressing Back Nav button at just the right time may fail to stop status bar from dissappearing, this method will help with fixing the bug.
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[self.navigationController viewControllers] containsObject:self])
    {
        // We were removed from the navigation controller's view controller stack
        // thus, we can infer that the back button was pressed
        
        [self.timer invalidate];
    }
    else
    {
        [self.timer invalidate];
    }
}

#pragma mark - Dealloc

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ActionSheet Delegate (Trash Management)

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == destructiveTrashTag)
    {
        [self trashHandler];
    }
    
    if (buttonIndex == cancelTrashTag)
    {
        [self setupTimer];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//Does not seem to work in Simulator.
-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self setupTimer];
}

@end
