//
//  CreateCollectionViewController.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 4/30/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToViewController.h"

@interface CreateCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, AddToViewControllerDelegate, UIPopoverControllerDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 
, UIPopoverPresentationControllerDelegate
#endif
>

@property (nonatomic, strong) NSURL *currentURL;

@end
