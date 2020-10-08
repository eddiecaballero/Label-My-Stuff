//
//  NSFileManager+Additions.h
//   Label My Stuff
//
//  Created by Eddie Caballero on 10/3/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions) <UIAlertViewDelegate>

-(NSArray *)eec_directoriesInDocumentsDirectory;

-(BOOL)eec_createAlbumWithName:(NSString *)name;
-(void)eec_updateCoreDataWithRenamedDirectory:(NSString *)oldDirectory withNewDirectory:(NSString *)newDirectory;
-(void)eec_deleteCoreDataEntryWithURL:(NSURL *)url;

@end
