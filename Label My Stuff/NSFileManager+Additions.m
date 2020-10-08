//
//  NSFileManager+Additions.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 10/3/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "NSFileManager+Additions.h"
#import "AppDelegate.h"
#import "UIWindow+Additions.h"

@implementation NSFileManager (Additions)

#pragma mark - CoreData Helper Additions

-(NSString *)updateCoreDataWithDirectory:(NSString *)directory
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSManagedObject *folder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder"
                                                            inManagedObjectContext:context];
    
    NSString *folderID = [NSString stringWithFormat:@"LabelMySuffID_%f", [[NSDate date] timeIntervalSince1970]];
    
    [folder setValue:folderID forKey:@"id"];
    [folder setValue:directory forKey:@"name"];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"An error! %@", error);
    }
    
    return folderID;
}

#pragma mark - General NSFileManager Additions

-(NSArray *)eec_directoriesInDocumentsDirectory
{
    //Read from Documents Directory
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSURL *directoryURL = [NSURL fileURLWithPath:documentsDirectory];
    
    NSArray *keys = @[NSURLIsDirectoryKey, NSURLLocalizedNameKey];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                  NSDirectoryEnumerationSkipsHiddenFiles)
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    NSMutableArray *directories = [[NSMutableArray alloc] init];
    for (NSURL *url in enumerator)
    {
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue])
        {
            NSString *localizedName = nil;
            [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
            
            [directories addObject:localizedName];
        }
    }
    return directories;
}

#pragma mark - CoreData Additions

-(BOOL)eec_createAlbumWithName:(NSString *)name
{
    NSString *newDirectoryName = name;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:newDirectoryName];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        //Create New Directory
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        //Update CoreData with New Directory
        [self updateCoreDataWithDirectory:newDirectoryName];
        
        return YES;
    }
    else
    {
        NSString *alertTitle = NSLocalizedString(@"New album not created.", nil);
        NSString *alertMessage = NSLocalizedString(@"Folder already exists, please rename.", nil);
        NSString *alertOk = NSLocalizedString(@"Ok", nil);
        
        Class UIAlertControllerClass = NSClassFromString(@"UIAlertController");
        
        if (UIAlertControllerClass)
        {
            #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                     message:alertMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:alertOk
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
            [alertController addAction:okAction];
            
            [[UIWindow eec_topMostViewController] presentViewController:alertController animated:YES completion:nil];
            
            #endif
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertMessage
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:alertOk, nil] show];
        }
        return NO;
    }
}

-(void)eec_updateCoreDataWithRenamedDirectory:(NSString *)oldDirectory withNewDirectory:(NSString *)newDirectory
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //Fetch Specific Managed Object
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", oldDirectory];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"An error! %@", error);
    }
    
    //Rename by setting new value for name.
    [(NSManagedObject *)array[0] setValue:newDirectory forKey:@"name"]; //If textfield can hold same names then this will retrive multiple objects...
    
    error = nil;
    if (![context save:&error])
    {
        NSLog(@"An error! %@", error);
    }
}

-(void)eec_deleteCoreDataEntryWithURL:(NSURL *)url
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //Fetch Specific Managed Object
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", [url lastPathComponent]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array != nil)
    {
        NSLog(@"An error! %@", error);
    }
    
    [context deleteObject:(NSManagedObject *)array[0]];
    
    error = nil;
    if (![context save:&error])
    {
        NSLog(@"An error! %@", error);
    }
}

@end
