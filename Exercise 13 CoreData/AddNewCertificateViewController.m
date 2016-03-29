//
//  AddNewCertificateViewController.m
//  Exercise 13 CoreData
//
//  Created by Pham Anh on 3/26/16.
//  Copyright © 2016 com.gaxxanh. All rights reserved.
//

#import "AddNewCertificateViewController.h"
#import "CoreDataManager.h"

@interface AddNewCertificateViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfCertificateName;

@end

@implementation AddNewCertificateViewController

- (IBAction)addCertificate:(id)sender {
    [self.tfCertificateName resignFirstResponder];
    if ([self.tfCertificateName.text  isEqual: @""]) {
        NSLog(@"Input ?");
        return;
    }
    if ([[CoreDataManager sharedInstance] createNewCertificateWithName:_tfCertificateName.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create New Certificate"
                                                                       message:@"Created Successfully"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"Create Failed");
    }
    
    [self.tfCertificateName setText:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfCertificateName.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.tfCertificateName resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tfCertificateName becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.tfCertificateName resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
