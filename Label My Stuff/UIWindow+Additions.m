//
//  UIWindow+Additions.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 6/7/16.
//  Copyright © 2016 Eddie Caballero. All rights reserved.
//

#import "UIWindow+Additions.h"

@implementation UIWindow (Additions)

+(UIViewController*)eec_topMostViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    return topController;
}

@end
