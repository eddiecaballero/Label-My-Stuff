//
//  Folder.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 7/23/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Folder : NSManagedObject

//https://stackoverflow.com/questions/12161549/nsmanagedobject-model-generated-by-xcode-use-retain-property-in-arc-project
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;

@end
