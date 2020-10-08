//
//  InitViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 1/10/15.
//  Copyright (c) 2015 Eddie Caballero. All rights reserved.
//

#import "InitViewController.h"
#import "NavViewController.h" //For status bar color
#import "Nav2ViewController.h" //For status bar color

@interface InitViewController ()
@end

@implementation InitViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self.topViewController isMemberOfClass:[NavViewController class]])
    {
        return UIStatusBarStyleLightContent;
    }
    
    if ([self.topViewController isMemberOfClass:[Nav2ViewController class]])
    {
        return UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Scan"];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

@end
