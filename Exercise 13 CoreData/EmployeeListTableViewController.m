//
//  PersonListTableViewController.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "EmployeeListTableViewController.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Employee.h"
#import "DetailEmployeeTableViewController.h"

static NSString *EmployeeTableViewCell = @"EmployeeTableViewCell";
static NSString *DetailEmployeeTableView = @"DetailEmployeeTableViewController";

@interface EmployeeListTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;

@end

@implementation EmployeeListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Employee";
    
    [self structFetchResult];
}



#pragma mark - Private Method
- (void) structFetchResult;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSSortDescriptor *indexSort = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    
    fetchRequest.sortDescriptors = @[indexSort];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                   managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    
    self.frc.delegate = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]) {
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch.");
    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        
        return sectionInfo.numberOfObjects;
        
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([tableView isEqual:self.tableView]) {
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:EmployeeTableViewCell forIndexPath:indexPath];
        
        Employee *employee = [self.frc objectAtIndexPath:indexPath];
        
        cell.textLabel.text = employee.name;
        cell.detailTextLabel.text = employee.fsu;
        
        NSLog(@"%@ - %@ - Tag: %@", employee.name, employee.fsu, employee.index);
        for (Certificate *insCertificate in employee.certificates) {
            NSLog(@"%@", insCertificate.name);
        }
        
        [cell setTag:[employee.index integerValue]];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailEmployeeTableViewController *detailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:DetailEmployeeTableView];
    
    NSInteger tag = [self.tableView cellForRowAtIndexPath:indexPath].tag;
    
    Employee *employee = [[CoreDataManager sharedInstance] getEmployeeHaveIndex:tag];
    [detailTableViewController setEmployee:employee];
    
    [self.navigationController pushViewController:detailTableViewController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Employee *employeeToDelete = [self.frc objectAtIndexPath:indexPath];
    [[CoreDataManager sharedInstance] deleteEmployee:employeeToDelete];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"abc");
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
