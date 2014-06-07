//
//  ItemSearchViewController.m
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemSearchViewController.h"
#import "SearchHeaderView.h"
@interface ItemSearchViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) SearchHeaderView *search;
@end

@implementation ItemSearchViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void) registerHeader
{
    UINib *cellNIB = [UINib nibWithNibName:NSStringFromClass([SearchHeaderView class]) bundle:nil];
    [self.collectionView registerNib:cellNIB forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([SearchHeaderView class])];
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                  withReuseIdentifier:NSStringFromClass([SearchHeaderView class])
                                                         forIndexPath:indexPath];
    }
    self.search = (SearchHeaderView*)view;
    [self.search.searchField setDelegate:self];
    return view;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self doSearch];
    [self.view endEditing:YES];
    return YES;
}

- (void) setSearch:(SearchHeaderView *)search
{
    _search = search;
}

-(NSPredicate *) getPredicate
{
    NSString *query =self.search.searchField.text;
    if ([query length] > 0) {
        return [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", self.search.searchField.text];
    } else {
        return nil;
    }
}

- (void) doSearch
{
    [self clearItems];
    [self.collectionView reloadData];
    [self fetch];
}

-(void) singleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}


@end
