//
//  MemosTableViewController.h
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemosTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)deleteButtonPressed:(id)sender;
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;

@end
