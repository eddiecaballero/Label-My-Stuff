//
//  TableCell.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 11/26/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //https://stackoverflow.com/questions/320078/adding-the-clear-button-to-an-iphone-uitextfield
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

@end
