//
//  ListEmployeeTableViewController.h
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/28/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"

@interface ListEmployeeTableViewController : UITableViewController

@property (strong, nonatomic) NSArray <Employee *> *listEmployees;
@property (strong, nonatomic) Certificate *certificate;

@end
