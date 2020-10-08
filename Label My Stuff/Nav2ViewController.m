//
//  Nav2ViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 4/17/15.
//  Copyright (c) 2015 Eddie Caballero. All rights reserved.
//

#import "Nav2ViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface Nav2ViewController ()

@end

@implementation Nav2ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.translucent = YES;
    self.toolbar.translucent = YES;
    
    if (![self.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationBar.tintColor =  [UIColor darkGrayColor];
        self.toolbar.tintColor = [UIColor darkGrayColor];
    }
}

@end
