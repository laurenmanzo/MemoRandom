//
//  MemosTableViewController.m
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import "MemosTableViewController.h"
#import "AppDelegate.h"
#import "MemoDetailViewController.h"
#import "Memo.h"

@interface MemosTableViewController ()

@end

@implementation MemosTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.managedObjectContext = MemoRandomAppDelegate.managedObjectContext;
	
	//Setup the fetch request
	NSEntityDescription *memoEntityDescription = [NSEntityDescription entityForName:@"Memo" inManagedObjectContext:self.managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:memoEntityDescription];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	
	//Initialize Fetched Results Controller
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	//Configure Fetched Results Controller
	[self.fetchedResultsController setDelegate:self];
	
	//Perform fetch
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"Unable to perform fetch.");
		NSLog(@"%@, %@", error, error.localizedDescription);
	}
	
	self.tableView.allowsMultipleSelectionDuringEditing = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
	
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemoCell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.tableView.editing) {
		[self performSegueWithIdentifier:@"DetailView" sender:self];
	}
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
	Memo *memo = (Memo*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
	UILabel *memoNameLabel = (UILabel*)[cell viewWithTag:1];
	UILabel *dateLabel = (UILabel*)[cell viewWithTag:2];
	UILabel *lengthLabel = (UILabel*)[cell viewWithTag:3];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	NSString *formattedDate = [dateFormatter stringFromDate:memo.date];
	
	[memoNameLabel setText:memo.name];
	[dateLabel setText:formattedDate];
	[lengthLabel setText:memo.length];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	//Overridden so that a delete button can be added to the nagivation bar, to support multiple delete.
	[super setEditing:editing animated:animated];
	
	if (editing) {
		UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonPressed:)];
		self.navigationItem.leftBarButtonItem = deleteButton;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (void)deleteButtonPressed:(id)sender {
	NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
	BOOL rowsSelected = selectedRows.count > 0;
	if (rowsSelected) {
		for (int i = 0; i < selectedRows.count; i++) {
			//Get the memo
			Memo* memo = (Memo*)[self.fetchedResultsController objectAtIndexPath:[selectedRows objectAtIndex:i]];
			//Delete audio file
			[memo deleteAudioFile];
			//Delete the row from the context
			[self.fetchedResultsController.managedObjectContext deleteObject:memo];
		}
		//Commit the deletes
		NSError *error = nil;
		if (![self.fetchedResultsController.managedObjectContext save:&error]) {
			NSLog(@"Unable to save managed object context.");
			NSLog(@"%@, %@", error, error.localizedDescription);
		}
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		Memo *memo = (Memo*)[self.fetchedResultsController objectAtIndexPath:indexPath];
		NSError *error = nil;
		if (memo) {
			[self.fetchedResultsController.managedObjectContext deleteObject:memo];
			if (![self.fetchedResultsController.managedObjectContext save:&error]) {
				NSLog(@"Unable to save managed object context.");
				NSLog(@"%@, %@", error, error.localizedDescription);
			}
		}
	}
}

#pragma mark - Navigation
//Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch (type) {
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
		default:
			break;
	}
}

#pragma mark - Navigation

// Do preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"DetailView"]) {
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
		MemoDetailViewController *destinationViewController = segue.destinationViewController;
		Memo *memo = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
		[destinationViewController setMemo:memo];
	}
}


@end
