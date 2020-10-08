//
//  PrintView.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 7/23/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintView : UIView <UIPrintInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;


@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;
@property (weak, nonatomic) IBOutlet UIImageView *imageView7;
@property (weak, nonatomic) IBOutlet UIImageView *imageView8;


@property (weak, nonatomic) IBOutlet UIImageView *imageView9;
@property (weak, nonatomic) IBOutlet UIImageView *imageView10;
@property (weak, nonatomic) IBOutlet UIImageView *imageView11;
@property (weak, nonatomic) IBOutlet UIImageView *imageView12;


@property (weak, nonatomic) IBOutlet UIImageView *imageView13;
@property (weak, nonatomic) IBOutlet UIImageView *imageView14;
@property (weak, nonatomic) IBOutlet UIImageView *imageView15;
@property (weak, nonatomic) IBOutlet UIImageView *imageView16;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;

@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;
@property (weak, nonatomic) IBOutlet UILabel *label7;
@property (weak, nonatomic) IBOutlet UILabel *label8;

@property (weak, nonatomic) IBOutlet UILabel *label9;
@property (weak, nonatomic) IBOutlet UILabel *label10;
@property (weak, nonatomic) IBOutlet UILabel *label11;
@property (weak, nonatomic) IBOutlet UILabel *label12;

@property (weak, nonatomic) IBOutlet UILabel *label13;
@property (weak, nonatomic) IBOutlet UILabel *label14;
@property (weak, nonatomic) IBOutlet UILabel *label15;
@property (weak, nonatomic) IBOutlet UILabel *label16;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSMutableArray *labels;

-(NSArray *)imageViews;

@end
