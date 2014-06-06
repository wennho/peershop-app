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
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *loginMessage;
@property (nonatomic) CGFloat usernameOffset;
@property (nonatomic) CGFloat passwordOffset;
@property (nonatomic) CGFloat messageOffset;
@end

@implementation LoginVC
#define ANIMATION_OFFSET 300

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.usernameOffset = self.usernameField.frame.origin.x;
    self.passwordOffset = self.passwordField.frame.origin.x;
    self.messageOffset = self.loginMessage.frame.origin.x;

    self.loginMessage.hidden = YES;

    if ([PeerShopInterface isLoggedIn]) {
        [self logoutMode];
    } else {
        [self loginMode];
    }

    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tapper];

}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // setting the correct frame offset does not work in viewDidLoad
    CGRect frame = self.loginMessage.frame;
    self.loginMessage.frame = CGRectMake(self.messageOffset - ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);

}

- (void) loginMode
{
    void (^animations)(void) = ^{
        CGRect frame = self.usernameField.frame;
        self.usernameField.frame = CGRectMake(self.usernameOffset, frame.origin.y, frame.size.width, frame.size.height);
        frame = self.passwordField.frame;
        self.passwordField.frame = CGRectMake(self.passwordOffset, frame.origin.y, frame.size.width, frame.size.height);
        frame = self.loginMessage.frame;
        self.loginMessage.frame = CGRectMake(self.messageOffset - ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);

        [self.button setTitle:@"Log In" forState:UIControlStateNormal];
        self.loginStatus.text = nil;

        self.usernameField.text = [PeerShopInterface username];
        self.passwordField.text = [PeerShopInterface password];
    };

    [UIView animateWithDuration:0.3
                     animations:animations];
}

- (void) logoutMode
{
    self.loginMessage.hidden = NO;

    void (^animations)(void) = ^{
        CGRect frame = self.usernameField.frame;
        self.usernameField.frame = CGRectMake(self.usernameOffset + ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);
        frame = self.passwordField.frame;
        self.passwordField.frame = CGRectMake(self.passwordOffset + ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);
        frame = self.loginMessage.frame;
        self.loginMessage.frame = CGRectMake(self.messageOffset, frame.origin.y, frame.size.width, frame.size.height);

        [self.button setTitle:@"Log Out" forState:UIControlStateNormal];

        self.loginMessage.text = [NSString stringWithFormat:@"Logged in as %@", [PeerShopInterface username]];

    };

    [UIView animateWithDuration:0.3
                     animations:animations];
}


-(void) singleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (IBAction)doLogin:(id)sender {

    if (![PeerShopInterface isLoggedIn]) {
        self.loginStatus.text = nil;
        [self.view endEditing:YES];

        [PeerShopInterface setUsername:self.usernameField.text];
        [PeerShopInterface setPassword:self.passwordField.text];

        SuccessCallback callback = ^(BOOL success){

            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self logoutMode];
                } else {
                    self.loginStatus.text = @"Invalid username or password";
                }
            });

        };

        [PeerShopInterface login:callback];
    } else {
        [PeerShopInterface logOut:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loginMode];
                });
            }
        }];
    }
}

@end
