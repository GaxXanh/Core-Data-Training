//
//  EditCertificateEmployee.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/29/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "EditCertificateEmployee.h"

static NSString *CertificateTableViewCell = @"EditCertificateEmployee";

@interface EditCertificateEmployee () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;

@end

@implementation EditCertificateEmployee

- (void) viewDidLoad;
{
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.title = self.employee.name;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self structFetchResult];
}

- (void) structFetchResult;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Certificate"];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    fetchRequest.sortDescriptors = @[nameSort];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]  sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]) {
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch.");
    }
}

- (void) save;
{
    NSInteger numOfRow = [self.tableView numberOfRowsInSection:0];
    
    NSMutableSet *selectedCertificate = [[NSMutableSet alloc] init];
    
    for (NSInteger i = 0; i < numOfRow; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
            Certificate *certificate = [self.frc objectAtIndexPath:indexPath];
            [selectedCertificate addObject:certificate];
        }
    }
    
    [[CoreDataManager sharedInstance] updateCertificate:selectedCertificate forEmployee:self.employee];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView DataSource & Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([tableView isEqual:self.tableView]) {
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:CertificateTableViewCell
                                                         forIndexPath:indexPath];
        
        Certificate *certificate = [self.frc objectAtIndexPath:indexPath];
        
        cell.textLabel.text = certificate.name;
        
        if ([self.employee.certificates containsObject:certificate]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryNone) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}



@end
