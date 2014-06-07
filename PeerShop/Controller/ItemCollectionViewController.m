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
#import "PeerShopHeaderView.h"
#import "Item.h"
#import "PeerShopDatabase.h"

@interface ItemCollectionViewController ()
//@property (strong, nonatomic) NSMutableArray *items; // NSDictionary
//@property (strong, nonatomic) NSArray *itemsToLoad; // NSDictionary
@end

@implementation ItemCollectionViewController
//
//-(void) animateAddItem:(id) itemIndex
//{
//    NSNumber *index = (NSNumber*) itemIndex;
//    id item = [self.itemsToLoad objectAtIndex:index.intValue];
//    [self.items addObject:item];
//    NSIndexPath *path = [NSIndexPath indexPathForRow:index.intValue inSection:0];
//    NSArray *paths = [[NSArray alloc] initWithObjects:path, nil];
//
//    [self.collectionView insertItemsAtIndexPaths:paths];
//
//}
//
//-(void)loadItems:(NSArray *)items
//{
//    self.items = [[NSMutableArray alloc] init];
//    self.itemsToLoad = items;
//    for (int i =0; i < [items count]; i++){
//        [self performSelector:@selector(animateAddItem:) withObject:[NSNumber numberWithInt:i] afterDelay:0.1 * i];
//    }
//
//}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNIB = [UINib nibWithNibName:NSStringFromClass([PeerShopHeaderView class]) bundle:nil];
//    [self.collectionView registerNib:cellNIB forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PeerShopHeaderView class])];
    [self fetchItems];

}


- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    self.items = nil;
//    [self.collectionView reloadData];
//    [self fetchItems];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    PeerShopDatabase *peerdb = [PeerShopDatabase sharedDefaultDatabase];
    if (peerdb.managedObjectContext) {
        self.managedObjectContext = peerdb.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:PeerShopDatabaseAvailable
                                                                        object:peerdb
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = peerdb.managedObjectContext;
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
}


-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (IBAction) fetchItems
{
//    [PeerShopInterface downloadItemList:^(NSArray *itemList) {
//        [self loadItems: itemList];
//    }];
    [[PeerShopDatabase sharedDefaultDatabase] fetch];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

// Subclasses can override this to change behavior
- (NSArray *) getSortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                           ascending:YES
                                            selector:nil]];
}


- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
        request.predicate = nil;
        request.sortDescriptors = [self getSortDescriptors];

        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


#pragma mark - DataSource methods


- (Item *) getItem:(NSIndexPath *)index
{
    return [self.fetchedResultsController objectAtIndexPath:index];
}

// REQUIRED: Set up each cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Cells that goes off screen are enqueued into a reuse pool
    // The method below looks for reuseable cell
    ItemCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (!myCell)
        myCell = [[ItemCollectionViewCell alloc] init];

    // IndexPath specifies the section and row of a cell. Here, row is equivalent to the index.
    myCell.item = [self getItem:indexPath];
    return myCell;
}



//- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *view = nil;
//    if (kind == UICollectionElementKindSectionHeader) {
//        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                                  withReuseIdentifier:NSStringFromClass([PeerShopHeaderView class])
//                                                         forIndexPath:indexPath];
//    }
//
//    return view;
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    // only the height component is used
//    return CGSizeMake(50, 35);
//}


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
        detailVC.item = [self getItem:indexPath];
    }
}



@end
