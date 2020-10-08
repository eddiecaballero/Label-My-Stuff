//
//  CreateTableViewController.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 5/7/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrintViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@class GADBannerView;

@interface CreateTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate,PrintViewControllerDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *bannerView;

@end
