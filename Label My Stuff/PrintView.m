//
//  PrintView.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 7/23/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "PrintView.h"

@implementation PrintView

-(NSMutableArray *)imageViews
{
    return [ @[self.imageView1,
                                              self.imageView2,
                                              self.imageView3,
                                              self.imageView4,
                                              self.imageView5,
                                              self.imageView6,
                                              self.imageView7,
                                              self.imageView8,
                                              self.imageView9,
                                              self.imageView10,
                                              self.imageView11,
                                              self.imageView12,
                                              self.imageView13,
                                              self.imageView14,
                                              self.imageView15,
                                              self.imageView16] mutableCopy];
}

-(NSMutableArray *)labels
{
    return [ @[self.label1,
                                              self.label2,
                                              self.label3,
                                              self.label4,
                                              self.label5,
                                              self.label6,
                                              self.label7,
                                              self.label8,
                                              self.label9,
                                              self.label10,
                                              self.label11,
                                              self.label12,
                                              self.label13,
                                              self.label14,
                                              self.label15,
                                              self.label16] mutableCopy];
}

@end
