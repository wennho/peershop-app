//
//  LoginVC.m
//  PeerShop
//
//  Created by Wen Hao on 6/1/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "LoginVC.h"
#import "PeerShopInterface.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UILabel *loginStatus;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation LoginVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.usernameField.text = [PeerShopInterface username];
    self.passwordField.text = [PeerShopInterface password];

    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tapper];

}

-(void) singleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (IBAction)doLogin:(id)sender {
    self.loginStatus.text = nil;
    [self.view endEditing:YES];

    [PeerShopInterface setUsername:self.usernameField.text];
    [PeerShopInterface setPassword:self.passwordField.text];

    SuccessCallback callback = ^(BOOL success){

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.loginStatus.text = @"SUCCESS";
                UIColor * color = [UIColor colorWithRed:19/255.0f green:170/255.0f blue:53/255.0f alpha:1.0f];
                self.loginStatus.textColor = color;
            } else {
                self.loginStatus.text = @"FAILED";
                self.loginStatus.textColor = [UIColor redColor];
            }
        });

    };

    [PeerShopInterface login:callback];
}

@end
