//
//  ItemListViewController.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//
//  Adapted from Alexander Hsu's LittleFighters demo and Paul Hegarty's Shutterbug demo for CS193P

#import "ItemCollectionViewController.h"
#import "ItemCollectionViewCell.h"
#import "ItemDetailViewController.h"
#import "PeerShopInterface.h"

@interface ItemCollectionViewController ()
// Image names for thumbnails
@property (strong, nonatomic) NSArray *items; //NSString
@end

@implementation ItemCollectionViewController

-(void)setItems:(NSArray *)items
{
    _items = items;
    [self.collectionView reloadData];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self fetchItems];

}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (IBAction) fetchItems
{
    NSURL *url = [PeerShopInterface URLforItemList];

    dispatch_queue_t fetchQueue = dispatch_queue_create("peershop item fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSArray *items = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                         options:0
                                                           error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.items = items;
        });
    });

}


#pragma mark - DataSource methods
// REQUIRED: Number of items in section. (Number of thumbnails)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

// REQUIRED: Set up each cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Cells that goes off screen are enqueued into a reuse pool
    // The method below looks for reuseable cell
    ItemCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (!myCell)
        myCell = [[ItemCollectionViewCell alloc] init];

    // IndexPath specifies the section and row of a cell. Here, row is equivalent to the index.
    myCell.item = self.items[indexPath.row];
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
        ItemDetailViewController *detailVC = (ItemDetailViewController *)destVC;
        detailVC.item = self.items[indexPath.row];
    }
}

@end
