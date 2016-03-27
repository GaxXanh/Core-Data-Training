//
//  Employee+CoreDataProperties.h
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Employee.h"

NS_ASSUME_NONNULL_BEGIN

@interface Employee (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *fsu;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSSet<Certificate *> *certificates;

@end

@interface Employee (CoreDataGeneratedAccessors)

- (void)addCertificatesObject:(Certificate *)value;
- (void)removeCertificatesObject:(Certificate *)value;
- (void)addCertificates:(NSSet<Certificate *> *)values;
- (void)removeCertificates:(NSSet<Certificate *> *)values;

@end

NS_ASSUME_NONNULL_END
