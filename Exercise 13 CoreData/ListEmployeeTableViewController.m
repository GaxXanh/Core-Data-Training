//
//  ListEmployeeTableViewController.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "ListEmployeeTableViewController.h"
#import "CoreDataManager.h"
#import "Employee.h"
#import "Certificate.h"

static NSString *ListEmployeeTableViewCell = @"ListEmployeeTableViewCell";

@interface ListEmployeeTableViewController ()

@end

@implementation ListEmployeeTableViewController

- (void) viewDidLoad;
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.title = self.certificate.name;
}

#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listEmployees count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([tableView isEqual:self.tableView]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:ListEmployeeTableViewCell forIndexPath:indexPath];
        Employee *insEmployee = [self.listEmployees objectAtIndex:indexPath.row];
        cell.textLabel.text = insEmployee.name;
        cell.detailTextLabel.text = insEmployee.fsu;
    }
    
    return cell;
}
@end