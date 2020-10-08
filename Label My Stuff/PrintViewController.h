//
//  PrintViewController.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 8/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrintViewController;

@protocol PrintViewControllerDelegate <NSObject>

-(void)PrintViewControllerDidFinishPrinting:(PrintViewController *)printViewController;

@end

@interface PrintViewController : UIViewController <UIPrintInteractionControllerDelegate>

@property (nonatomic, weak) id<PrintViewControllerDelegate> delegate;

@end
