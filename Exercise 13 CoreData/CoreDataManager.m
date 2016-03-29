//
//  CoreDataManager.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "CoreDataManager.h"
#import "Certificate.h"
#import "Employee.h"

@implementation CoreDataManager

+ (CoreDataManager *) sharedInstance;
{
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[CoreDataManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.GaxXanh.Exercise_13_CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Exercise_13_CoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Exercise_13_CoreData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Common Method

- (BOOL) createNewEmployeeWithFirstName:(NSString *)name ofFsu:(NSString *)fsu withCertificates:(NSArray *)listCertificates;
{
    BOOL result = NO;
    
    Employee *newEmployee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee"
                                                          inManagedObjectContext:self.managedObjectContext];
    
    if (newEmployee == nil) {
        NSLog(@"Failed to create new employee.");
        return NO;
    }
    
    newEmployee.index = [NSNumber numberWithUnsignedInteger:[self getCurrentIndexOfEmployeeTable] + 1];
    newEmployee.name = name;
    newEmployee.fsu = fsu;
    
    NSSet<Certificate *> *certificates = [self getCertificatesWithArrayNameCertificates:listCertificates];
    [newEmployee setCertificates:certificates];
    
    for (Certificate *insCertificate in certificates) {
        [insCertificate addEmployeesObject:newEmployee];
    }
    
    NSError *savingError = nil;
    
    if ([self.managedObjectContext save:&savingError]) {
        return YES;
    } else {
        NSLog(@"Failed to save the new employee. Error = %@", savingError);
    }
    
    return result;
}

- (BOOL) createNewCertificateWithName:(NSString *)name
{
    BOOL result = NO;
    
    Certificate *newCertificate = [NSEntityDescription insertNewObjectForEntityForName:@"Certificate"
                                                                inManagedObjectContext:self.managedObjectContext];
    
    if (newCertificate == nil) {
        NSLog(@"Failed to create new certificate.");
        return NO;
    }
    
    newCertificate.name = name;
    
    NSError *savingError = nil;
    
    if ([self.managedObjectContext save:&savingError]) {
        return YES;
    } else {
        NSLog(@"Failed to save the new certificate. Error = %@", savingError);
    }
    
    return result;
}

- (void) deleteEmployee:(Employee *)employeeToDelete;
{
    [self.managedObjectContext deleteObject:employeeToDelete];
    if ([employeeToDelete isDeleted]){
        NSError *savingError = nil;
        if ([[self managedObjectContext] save:&savingError]){
            NSLog(@"Successfully deleted the object");
        } else {
            NSLog(@"Failed to save the context with error = %@", savingError);
        }
    }
}

- (void) removeAllEmployee;
{
    for (Employee *insEmployee in [self getAllEmployee]) {
        [self.managedObjectContext deleteObject:insEmployee];
    }
    [self.managedObjectContext save:nil];
}

- (void) removeAllCertificates;
{
    for (Certificate *insCertificate in [self getAllCertificates]) {
        [self.managedObjectContext deleteObject:insCertificate];
    }
    [self.managedObjectContext save:nil];
}

- (NSArray<Employee *> *) getAllEmployee;
{
    NSFetchRequest *fetchRequet = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSError *requestError = nil;
    
    NSArray<Employee *> *employees = [self.managedObjectContext executeFetchRequest:fetchRequet
                                                                              error:&requestError];
    
    if ([employees count] > 0) {
        return employees;
    } else {
        NSLog(@"There are no employee in table");
    }
    
    return nil;
}

- (NSArray<Certificate *> *) getAllCertificates;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Certificate"];
    
    NSError *requestError = nil;
    
    NSArray<Certificate *> *certificates = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if ([certificates count] > 0) {
        return certificates;
    } else {
        NSLog(@"There are no certificate in table");
    }
    
    return nil;
}

- (Employee *) getEmployeeHaveIndex:(NSInteger) index;
{
    NSFetchRequest *fetchRequets = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSString *attributeName = @"index";
    NSNumber *attributeValue = [NSNumber numberWithInteger:index];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@" argumentArray:@[attributeName, attributeValue]];
    [fetchRequets setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequets error:&error];
    
    if ([fetchedObjects count] != 1) {
        NSLog(@"Error: %@", error);
        return nil;
    } else {
        return [fetchedObjects objectAtIndex:0];
    }
}

- (NSUInteger) getCurrentIndexOfEmployeeTable;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSError *requestError = nil;
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO]];
    
    NSArray *employees = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:&requestError];
    
    if ([employees count] == 1) {
        Employee *employee = [employees objectAtIndex:0];
        return [employee.index unsignedIntegerValue];
    } else {
        NSLog(@"There are no employee in table or fail ?");
    }
    
    return 0;
}

- (void) deleteCertificateWithName:(NSString *)attributeNameValue;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Certificate" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSString *attributeName = @"name";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@" argumentArray:@[attributeName ,attributeNameValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        NSLog(@"Error : %@", error);
    } else {
        for (Certificate *insCertificate in fetchedObjects) {
            if ([insCertificate.name isEqualToString:attributeNameValue]) {
                [self.managedObjectContext deleteObject:insCertificate];
                if ([insCertificate isDeleted]) {
                    NSLog(@"Successfully deleted certificate: %@", insCertificate.name);
                    
                    NSError *savingError = nil;
                    if ([self.managedObjectContext save:&savingError]){
                        NSLog(@"Successfully saved the context.");
                    }
                    else {
                        NSLog(@"Failed to save the context.");
                    }
                }
            }
        }
    }
}

- (NSSet <Certificate *> *) getCertificatesWithArrayNameCertificates:(NSArray *)listCertificates;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Certificate" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"name";
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    for (NSString *certificateName in listCertificates) {
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"%K like %@" argumentArray:@[attributeName, certificateName]];
        [subPredicates addObject:predicateName];
    }
    NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithArray:subPredicates]];
    [fetchRequest setPredicate:orPredicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        return [NSSet setWithArray:fetchedObjects];
    } else {
        return nil;
    }
}

- (NSArray *) searchAllEmployeesHaveCertificate:(NSString *)certificate;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Certificate"];
    
    NSString *attributeName = @"name";
    NSString *attributeValue = certificate;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@" argumentArray:@[attributeName, attributeValue]];
    
    fetchRequest.predicate = predicate;
    
    NSError *requestError = nil;
    
    NSArray *certificates = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:&requestError];
    
    if ([certificates count] == 1) {
        Certificate *insCertificate = [certificates objectAtIndex:0];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithSet:insCertificate.employees];
        NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *sorted = [orderedSet sortedArrayUsingDescriptors:@[indexDescriptor]];
        return [NSArray arrayWithArray:sorted];
    } else {
        NSLog(@"Could not find any Employee entities in the context");
    }
    
    return nil;
}

- (BOOL) updateCertificate:(NSSet<Certificate *> *)selectedCertificates forEmployee:(Employee *)employee;
{
    NSArray *allCertificate = [self getAllCertificates];
    // Remove certificate in employee and remove employee in certificate
    for (Certificate *insCertificate in allCertificate) {
        [employee removeCertificatesObject:insCertificate];
        [insCertificate removeEmployeesObject:employee];
    }
    [employee addCertificates:selectedCertificates];
    
    // Add certificate for employee and add employee for certificate
    for (Certificate *insCertificate in selectedCertificates) {
        [employee addCertificatesObject:insCertificate];
        [insCertificate addEmployeesObject:employee];
    }
    
    NSError *savingError = nil;
    if ([self.managedObjectContext save:&savingError]) {
        NSLog(@"Update Successfully");
        return true;
    } else {
        NSLog(@"Update Failed With Error : %@", savingError);
        return false;
    }
}

@end

