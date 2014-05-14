//
//  ItemListViewController.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemCollectionViewController.h"
#import "ItemCollectionViewCell.h"
#import "ItemDetailViewController.h"

@interface ItemCollectionViewController ()
// Image names for thumbnails
@property (strong, nonatomic) NSMutableArray *characterThumbnails; //NSString
@end

@implementation ItemCollectionViewController

// Lazy instantiation for names of thumbnails
- (NSMutableArray *)characterThumbnails {
    if (!_characterThumbnails) {
        _characterThumbnails = [[NSMutableArray alloc] init];
    }
    return _characterThumbnails;
}

#pragma mark - DataSource methods
// REQUIRED: Number of items in section. (Number of thumbnails)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.characterThumbnails.count;
    return 5;
}

// REQUIRED: Set up each cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Cells that goes off screen are enqueued into a reuse pool
    // The method below looks for reuseable cell
    ItemCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (!myCell)
        myCell = [[ItemCollectionViewCell alloc] init];

    // IndexPath specifies the section and row of a cell. Here, row is equivalent to the index.
    // Set the image of the cell.
    myCell.imageView.image = [UIImage imageNamed:@"pencil"];
    return myCell;
}

#pragma mark - Navigation

// Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get indexPath for the selected cell
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[ItemCollectionViewCell class]]) {
        indexPath = [self.collectionView indexPathForCell:sender];
    }

    // Set up destination view controller
    id destVC = segue.destinationViewController;
    if (indexPath && [destVC isKindOfClass:[ItemDetailViewController class]]) {
        if ([segue.identifier isEqualToString:@"Select Character"]) {
            ItemDetailViewController *detailVC = (ItemDetailViewController *)destVC;
            detailVC.image = [UIImage imageNamed:self.characterThumbnails[indexPath.row]];
            detailVC.itemTitle = self.characterThumbnails[indexPath.row];
        }
    }
}

@end
