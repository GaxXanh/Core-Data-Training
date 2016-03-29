//
//  DetailEmployeeTableViewController.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "DetailEmployeeTableViewController.h"
#import "ListEmployeeTableViewController.h"
#import "EditCertificateEmployee.h"
#import "CoreDataManager.h"

static NSString *DetailEmployeeTableViewCell = @"DetailEmployeeTableViewCell";
static NSString *ListEmployeeTableView = @"ListEmployeeTableViewController";

@interface DetailEmployeeTableViewController ()

@property (nonatomic) Employee *employee;
@property (strong, nonatomic) NSArray<Certificate *> *listCertificate;

@end

@implementation DetailEmployeeTableViewController

@synthesize employee = _employee;

#pragma mark - View Life Cycle

- (void) viewDidLoad;
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.title = self.employee.name;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                               target:self
                                                                               action:@selector(add)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.listCertificate = [self.employee.certificates allObjects];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.listCertificate = [self.employee.certificates allObjects];
    [self.tableView reloadData];
}

- (void) add;
{
    EditCertificateEmployee *editCertificateEmployee = [self.storyboard instantiateViewControllerWithIdentifier:@"EditCertificateEmployee"];
    
    [editCertificateEmployee setEmployee:self.employee];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editCertificateEmployee];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Public Methods

- (void) setEmployee:(Employee *)employee;
{
    _employee = employee;
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", [self.employee.certificates count]);
    return [self.employee.certificates count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = nil;
    if ([tableView isEqual:self.tableView]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:DetailEmployeeTableViewCell forIndexPath:indexPath];
        cell.textLabel.text = [self.listCertificate objectAtIndex:indexPath.row].name;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    Certificate *insCertificate = [self.listCertificate objectAtIndex:indexPath.row];
    NSArray<Employee *> *listEmployees = [[CoreDataManager sharedInstance] searchAllEmployeesHaveCertificate:insCertificate.name];
    ListEmployeeTableViewController *listEmployeeTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:ListEmployeeTableView];
    
    [listEmployeeTableViewController setListEmployees:listEmployees];
    [listEmployeeTableViewController setCertificate:insCertificate];
    
    [self.navigationController pushViewController:listEmployeeTableViewController animated:YES];
    
}

@end
