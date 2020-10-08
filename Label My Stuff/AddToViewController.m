//
//  AddToViewController.m
//   Label My Stuff
//
//  Created by Eddie Caballero on 10/16/14.
//  Copyright (c) 2014 Eddie Caballero. All rights reserved.
//

#import "AddToViewController.h"
#import "NSFileManager+Additions.h"
#import "CreateCollectionViewController.h"

@interface AddToViewController ()

@property (nonatomic, strong) NSString *selectedDirectory;

- (IBAction)cancel:(id)sender;

@end

@implementation AddToViewController

#pragma mark - Target Action

- (IBAction)cancel:(id)sender
{
    [self.delegate AddToViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *directories = [[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory];
    cell.textLabel.text = directories[indexPath.row];
    
    //Make sure current Directory is disabled.
    NSString *currentDir = [[(CreateCollectionViewController *)[self delegate] currentURL] lastPathComponent];
    
    if ([cell.textLabel.text isEqualToString:currentDir])
    {
        [cell setUserInteractionEnabled:NO];
        [cell.textLabel setEnabled:NO];
    }
    else
    {
        [cell setUserInteractionEnabled:YES];
        [cell.textLabel setEnabled:YES];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *directories = [[NSFileManager defaultManager] eec_directoriesInDocumentsDirectory];
    self.selectedDirectory = directories[indexPath.row];
    
    [self.delegate AddToViewController:self didSelectDirectory:self.selectedDirectory];
}

@end
