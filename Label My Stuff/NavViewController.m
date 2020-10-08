//
//  NavViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 1/10/15.
//  Copyright (c) 2015 Eddie Caballero. All rights reserved.
//

#import "NavViewController.h"
#import "ECSlidingViewController.h"
#import "MenuTableViewController.h"

@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Shadow and Effects
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.barTintColor = [UIColor blackColor];
    }
    else
    {
        self.navigationBar.tintColor = [UIColor blackColor];
    }
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]])
    {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    //Ability to swipe to reveal menu.
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

@end
