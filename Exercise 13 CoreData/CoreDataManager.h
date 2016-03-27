//
//  CoreDataManager.h
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Certificate.h"

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataManager *) sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL) createNewCertificateWithName:(NSString *)name;
- (NSArray<Certificate *> *) getAllCertificates;

@end
