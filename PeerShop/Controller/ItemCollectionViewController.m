//
//  ItemListViewController.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//


#import "ItemCollectionViewController.h"
#import "ItemCollectionViewCell.h"
#import "ItemDetailViewController.h"
#import "PeerShopInterface.h"
#import "PeerShopHeaderView.h"
#import "Item.h"
#import "PeerShopDatabase.h"

@interface ItemCollectionViewController ()
@property (strong, nonatomic) NSMutableArray *items; // NSDictionary
@property (strong, nonatomic) NSMutableArray *itemsToAdd;
@property (nonatomic) BOOL needsFetch;
@end

@implementation ItemCollectionViewController

- (void) clearItems
{
    [self.items removeAllObjects];
}

-(void) animateAddItem:(id) itemIndex
{
    NSNumber *index = (NSNumber*) itemIndex;
    [self.items addObject:self.itemsToAdd[index.intValue]];
    int row = [self.items count]-1;
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    NSArray *paths = [[NSArray alloc] initWithObjects:path, nil];

    [self.collectionView insertItemsAtIndexPaths:paths];

}

-(void)loadItems:(NSArray *)items
{
    int count = 0;
    self.itemsToAdd = [NSMutableArray new];
    for (Item *item in items) {
        if (![self.items containsObject:item]) {
            [self.itemsToAdd addObject:item];
            [self performSelector:@selector(animateAddItem:) withObject:[NSNumber numberWithInt:count] afterDelay:0.1 * count];
            count++;
        }
    }
}

- (void) registerHeader
{
    UINib *cellNIB = [UINib nibWithNibName:NSStringFromClass([PeerShopHeaderView class]) bundle:nil];
    [self.collectionView registerNib:cellNIB forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PeerShopHeaderView class])];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.items = [[NSMutableArray alloc] init];
    [self registerHeader];
    self.needsFetch = NO;
    [self getMOC];

}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    self.managedObjectContext = [PeerShopDatabase sharedDefaultDatabase].managedObjectContext;

    if (self.managedObjectContext){
        [self fetch];
    } else {
        self.needsFetch = YES;
    }

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

-(NSArray *) getSortDescriptors
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                           ascending:YES
                                            selector:nil]];
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (self.needsFetch) {
        self.needsFetch = NO;
        [self fetch];
    }
}

- (IBAction) getMOC
{
    PeerShopDatabase *peerDB = [PeerShopDatabase sharedDefaultDatabase];


    if (peerDB.managedObjectContext) {
        self.managedObjectContext = peerDB.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:PeerShopDatabaseAvailable
                                                                        object:peerDB
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                        self.managedObjectContext = peerDB.managedObjectContext;
                                                                        });

                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }


}

-(NSPredicate *) getPredicate
{
    return nil;
}

- (void) fetch
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [self getPredicate];
    request.sortDescriptors = [self getSortDescriptors];



    [[PeerShopDatabase sharedDefaultDatabase] fetchWithCompletionHandler:^(BOOL success) {

        NSArray *items = [self.managedObjectContext executeFetchRequest:request error:nil];
        [self loadItems:items];

    }];

}


#pragma mark - DataSource methods

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (Item *) getItem:(NSIndexPath *)index
{
    return self.items[index.row];
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



- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                  withReuseIdentifier:NSStringFromClass([PeerShopHeaderView class])
                                                         forIndexPath:indexPath];
    }

    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // only the height component is used
    return CGSizeMake(50, 35);
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
        detailVC.item = [self getItem:indexPath];
    }
}



@end
