//
//  AddToViewController.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 10/16/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddToViewController;

@protocol AddToViewControllerDelegate <NSObject>

-(void)AddToViewController:(AddToViewController *)addToViewController didSelectDirectory:(NSString *)directory;
-(void)AddToViewControllerDidCancel:(AddToViewController *)addToViewController;

@end

@interface AddToViewController : UIViewController

@property (nonatomic, strong) NSArray *selectedItemsURLs;
@property (nonatomic, weak) id<AddToViewControllerDelegate> delegate;

@end
