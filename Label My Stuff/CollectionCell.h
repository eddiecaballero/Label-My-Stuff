//
//  CollectionCell.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 6/4/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImage;

-(void)checkMark;
-(void)unCheckMark;

@end
