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

    if ([PeerShopInterface isLoggedIn]) {

        self.usernameField.hidden = YES;
        self.passwordField.hidden = YES;
        [self logoutMode];
    } else {
        self.loginMessage.hidden = YES;
        [self loginMode];
    }

    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tapper];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([PeerShopInterface isLoggedIn]) {
        [self setLogoutFrames];
        [self logoutMode];
    } else {
        [self setLoginFrames];
        [self loginMode];
    }

}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.usernameOffset = self.usernameField.frame.origin.x;
    self.passwordOffset = self.passwordField.frame.origin.x;
    self.messageOffset = self.loginMessage.frame.origin.x;

}

- (void) setLoginFrames
{
    CGRect frame = self.usernameField.frame;
    self.usernameField.frame = CGRectMake(self.usernameOffset, frame.origin.y, frame.size.width, frame.size.height);
    frame = self.passwordField.frame;
    self.passwordField.frame = CGRectMake(self.passwordOffset, frame.origin.y, frame.size.width, frame.size.height);
    frame = self.loginMessage.frame;
    self.loginMessage.frame = CGRectMake(self.messageOffset - ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);
}

- (void) setLogoutFrames
{
    CGRect frame = self.usernameField.frame;
    self.usernameField.frame = CGRectMake(self.usernameOffset + ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);
    frame = self.passwordField.frame;
    self.passwordField.frame = CGRectMake(self.passwordOffset + ANIMATION_OFFSET, frame.origin.y, frame.size.width, frame.size.height);
    frame = self.loginMessage.frame;
    self.loginMessage.frame = CGRectMake(self.messageOffset, frame.origin.y, frame.size.width, frame.size.height);
}

- (void) loginMode
{
    self.usernameField.hidden = NO;
    self.passwordField.hidden = NO;


    void (^animations)(void) = ^{
        [self setLoginFrames];

        [self.button setTitle:@"Log In" forState:UIControlStateNormal];
        self.loginStatus.text = nil;

        self.usernameField.text = [PeerShopInterface username];
        self.passwordField.text = [PeerShopInterface password];

        self.usernameField.alpha = 1;
        self.passwordField.alpha = 1;
        self.loginMessage.alpha = 0;
    };

    [UIView animateWithDuration:0.3
                     animations:animations];
}

- (void) logoutMode
{
        self.loginMessage.hidden = NO;
    void (^animations)(void) = ^{
        [self setLogoutFrames];

        [self.button setTitle:@"Log Out" forState:UIControlStateNormal];

        self.loginMessage.text = [NSString stringWithFormat:@"Logged in as %@", [PeerShopInterface username]];

        self.loginMessage.alpha = 1;
        self.usernameField.alpha = 0;
        self.passwordField.alpha = 0;
        self.loginStatus.text = nil;

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
            if (success) {
                [self setLoginFrames];
                [self logoutMode];
            } else {
                self.loginStatus.text = @"Invalid username or password";
            }
        };

        [PeerShopInterface login:callback];
    } else {
        [PeerShopInterface logOut:^(BOOL success) {
            if (success) {
                [self setLogoutFrames];
                [self loginMode];
            }
        }];
    }
}

@end
