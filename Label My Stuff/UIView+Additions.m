//
//  UIView+Additions.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 8/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

+(UILabel *)eec_addLabelWithText:(NSString *)text toView:(UIView *)view anchorToView:(UIView *)anchorView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blackColor];
    [label setNumberOfLines:0];
    [label setPreferredMaxLayoutWidth:view.frame.size.width];
    [view addSubview:label];
    
    UIView *labelV = label;
    UIView *anchorV = anchorView;
    NSDictionary *labelVElementsDictionary = NSDictionaryOfVariableBindings(labelV, anchorV);
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[anchorV]-[labelV]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:labelVElementsDictionary]];

    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0];
    
    [view addConstraint:c];
    
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    return label;
}

//http://stackoverflow.com/questions/14833070/nsgenericexception-reason-unable-to-install-constraint-on-view
+(void)eec_cleanRemoveFromSuperview:(UIView*)view
{
    if(!view || !view.superview)
        return;

    //First remove any constraints on the superview
    NSMutableArray * constraints_to_remove = [NSMutableArray new];
    UIView * superview = view.superview;
    for( NSLayoutConstraint * constraint in superview.constraints)
    {
        if( constraint.firstItem == view ||constraint.secondItem == view )
        {
            [constraints_to_remove addObject:constraint];
        }
    }
    [superview removeConstraints:constraints_to_remove];
    
    //Then remove the view itself.
    [view removeFromSuperview];
}

@end
