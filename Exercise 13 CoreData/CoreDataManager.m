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

- (BOOL) createNewEmployeeWithFirstName:(NSString *)name ofFsu:(NSString *)fsu withCertificates:(NSSet<Certificate *> *)listCertificates;
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
    newEmployee.certificates = listCertificates;
    
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

- (NSArray<Certificate *> *) getAllCertificates;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Certificate"];
    
    NSError *requestError = nil;
    
    NSArray<Certificate *> *certificates = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&requestError];
    
    if ([certificates count] > 0) {
        return certificates;
    } else {
        NSLog(@"There are no certificate in table");
    }
    
    return nil;
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

- (NSUInteger) getCurrentIndexOfEmployeeTable;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSError *requestError = nil;
    
    NSArray *employees = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:&requestError];
    
    if ([employees count] > 0) {
        Employee *lastEmployee = [employees lastObject];
        return [lastEmployee.index unsignedIntegerValue];
    } else {
        NSLog(@"There are no employee in table");
    }
    
    return 0;
}

- (NSArray *) searchAllEmployeesHaveCertificate:(Certificate *)certificate;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];
    
    NSSortDescriptor *idSord = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    
    fetchRequest.sortDescriptors = @[idSord];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(name == %@)", certificate.name];
    
    fetchRequest.predicate = predicate;
    
    NSError *requestError = nil;
    
    NSArray *employees = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                  error:&requestError];
    
    if ([employees count] > 0) {
        return employees;
    } else {
        NSLog(@"Could not find any Employee entities in the context");
    }
    
    return nil;
}


@end

