//
//  DisplayViewController.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 5/11/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) NSURL *currentURL;

@end
