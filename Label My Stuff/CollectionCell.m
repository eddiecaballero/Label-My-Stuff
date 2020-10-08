//
//  CollectionCell.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 6/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "CollectionCell.h"

@interface CollectionCell ()

@property (nonatomic, strong) UIImageView *checkmarkImageView;

@end

@implementation CollectionCell

#pragma mark - Cell Reuse

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.checkmarkImageView removeFromSuperview];
}

#pragma mark - Check Marks

-(void)checkMark
{
    self.checkmarkImageView = [[UIImageView alloc] init];
    [self.checkmarkImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.checkmarkImageView setImage:[UIImage imageNamed:@"checkmark.png"]];
    
    [self.cellImage addSubview:self.checkmarkImageView];
    
    UIImageView *check = self.checkmarkImageView;
    NSDictionary *elementsDictionary = NSDictionaryOfVariableBindings(check);
    
    [self.cellImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[check(32)]-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:nil
                                                                             views:elementsDictionary]];
    
    [self.cellImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[check(32)]-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:nil
                                                                             views:elementsDictionary]];
}

-(void)unCheckMark
{
    [self.checkmarkImageView removeFromSuperview];
}

@end
