//
//  SVSignInViewController.m
//  AlarTestTask
//
//  Created by Dead Inside on 24/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import "SVSignInViewController.h"
#import "SVDataPageViewController.h"
#import "SVAPIManager.h"

@interface SVSignInViewController () <SVAPIManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) SVAPIManager *APIManager;

@end

@implementation SVSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.APIManager = [SVAPIManager defaultManager];
}

- (void)viewWillAppear:(BOOL)animated {
    self.APIManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signInButtonTouched:(id)sender {
    if ([self isTextFieldsFilled]) {
        [self.APIManager signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    } else {
        [self showAlertWithText:@"Введите логин/пароль"];
    }
}

- (BOOL)isTextFieldsFilled {
    if (self.usernameTextField.text.length && self.passwordTextField.text.length) {
        return YES;
    }
    return NO;
}

- (void)showAlertWithText:(NSString *)text {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Ошибка" message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:aa];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ac animated:YES completion:nil];
    });
}

#pragma mark - SVIAPIManager delegate

- (void)didGetSignInResponse:(BOOL)signedIn error:(NSError *)error {
    if (signedIn) {
        SVDataPageViewController *vc = [[SVDataPageViewController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showViewController:vc sender:self];
        });
    } else {
        if (!error) {
            [self showAlertWithText:@"Неверные логин/пароль"];
        } else {
            [self showAlertWithText:error.localizedDescription];
        }
    }
}

@end
