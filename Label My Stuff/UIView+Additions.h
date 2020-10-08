//
//  UIView+Additions.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 8/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

+(UILabel *)eec_addLabelWithText:(NSString *)text toView:(UIView *)view anchorToView:(UIView *)anchorView;
+(void)eec_cleanRemoveFromSuperview:(UIView*)view;

@end
