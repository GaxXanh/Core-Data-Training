//
//  AddNewEmployeeViewController.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "AddNewEmployeeViewController.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>

static NSString *CertificateTableViewCell = @"CertificateTableViewCell";

@interface AddNewEmployeeViewController () <NSFetchedResultsControllerDelegate , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfFsu;
@property (weak, nonatomic) IBOutlet UITableView *tblCertificate;
@property (strong, nonatomic) NSFetchedResultsController *frc;

@end

@implementation AddNewEmployeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tfName.delegate = self;
    self.tfFsu.delegate = self;
    [self.tblCertificate setAllowsMultipleSelection:YES];
    [self structFetchResult];
    // Do any additional setup after loading the view.
}

- (void) structFetchResult;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Certificate"];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    fetchRequest.sortDescriptors = @[nameSort];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                   managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    
    self.frc.delegate = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]) {
    } else {
        NSLog(@"Failed to fetch.");
    }

}

#pragma mark - IBAction Methods

- (IBAction)resetAll:(id)sender
{
    NSArray<NSIndexPath *> *arrSelectedRows = [self.tblCertificate indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in arrSelectedRows) {
        [[self.tblCertificate cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [self.tblCertificate reloadData];
    [self.tfName setText:nil];
    [self.tfFsu setText:nil];
}

- (IBAction)addNewEmployee:(id)sender
{
    if ([self checkValidateData]) {
        NSString *name = self.tfName.text;
        NSString *fsu = self.tfFsu.text;
        NSMutableArray *listCertificates = [[NSMutableArray alloc] init];
        NSArray<NSIndexPath *> *listSelectedRows = [self.tblCertificate indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in listSelectedRows) {
            [listCertificates addObject:
             [self.tblCertificate cellForRowAtIndexPath:indexPath].textLabel.text];
        }
        if ([[CoreDataManager sharedInstance] createNewEmployeeWithFirstName:name
                                                                       ofFsu:fsu
                                                            withCertificates:[NSArray arrayWithArray:listCertificates]]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Employee"
                                                                           message:@"Added Successfully"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"Failed");
        }
    }
    
    [self resetAll:self];
    
    return;
}

#pragma mark - Private Methods

- (BOOL) checkValidateData;
{
    return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tblCertificate beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tblCertificate insertRowsAtIndexPaths:@[newIndexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tblCertificate endUpdates];
}

#pragma mark - TableView Datasource & Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tblCertificate]) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([tableView isEqual:self.tblCertificate]) {
        
        cell = [self.tblCertificate dequeueReusableCellWithIdentifier:CertificateTableViewCell
                                                         forIndexPath:indexPath];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        Certificate *certificate = [self.frc objectAtIndexPath:indexPath];
        
        cell.textLabel.text = certificate.name;
        
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryNone) {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.tfName]) {
        [self.tfName resignFirstResponder];
    } else if ([textField isEqual:self.tfFsu]) {
        [self.tfFsu resignFirstResponder];
    }
    
    return NO;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.tfName]) {
        [self.tfName becomeFirstResponder];
    } else if ([textField isEqual:self.tfFsu]) {
        [self.tfFsu becomeFirstResponder];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.tfFsu resignFirstResponder];
    [self.tfName resignFirstResponder];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.tfName resignFirstResponder];
    [self.tfFsu resignFirstResponder];
}



@end
