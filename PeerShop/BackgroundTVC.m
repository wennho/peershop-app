//
//  BackgroundTVC.m
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "BackgroundTVC.h"

@interface BackgroundTVC ()

@end

@implementation BackgroundTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackground];
}

- (void) setupBackground
{
    UIImageView *tmp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tmp setFrame:self.tableView.bounds];
    self.tableView.backgroundView = tmp;
}

@end
