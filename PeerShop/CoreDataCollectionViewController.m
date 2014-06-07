//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Fall 2013.
//  Copyright 2013 Stanford University. All rights reserved.
//

#import "CoreDataCollectionViewController.h"

@interface CoreDataCollectionViewController()
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@end

@implementation CoreDataCollectionViewController

#pragma mark - Properties

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.collectionView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        [self stopObservingManagedObjectContext];
        _fetchedResultsController = newfrc;
        [self startObservingManagedObjectContext];
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch]; 
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.collectionView reloadData];
        }
    }
}

- (void)setObserveManagedObjectContext:(BOOL)observeManagedObjectContext
{
    if (observeManagedObjectContext != _observeManagedObjectContext) {
        if (self.observeManagedObjectContext) [self stopObservingManagedObjectContext];
        _observeManagedObjectContext = observeManagedObjectContext;
        if (self.observeManagedObjectContext) [self startObservingManagedObjectContext];
    }
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    self.objectChanges = [[NSMutableArray alloc] init];
    self.sectionChanges= [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.observeManagedObjectContext) [self startObservingManagedObjectContext];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopObservingManagedObjectContext];
}

- (void)startObservingManagedObjectContext
{
    if (self.fetchedResultsController.managedObjectContext && self.view.window) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextChanged:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.fetchedResultsController.managedObjectContext];
    }
}

- (void)stopObservingManagedObjectContext
{
    if (self.fetchedResultsController.managedObjectContext) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:self.fetchedResultsController.managedObjectContext];
    }
}

- (void)managedObjectContextChanged:(NSNotification *)notification
{
    [self performFetch];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        self.beganUpdates = YES;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext && self.collectionView.window != nil)
    {
        NSMutableDictionary *change = [NSMutableDictionary new];

        switch(type)
        {
            case NSFetchedResultsChangeInsert:
//                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                change[@(type)] = @(sectionIndex);
                break;
                
            case NSFetchedResultsChangeDelete:
//                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                change[@(type)] = @(sectionIndex);
                break;
        }
        [self.sectionChanges addObject:change];
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{		
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext && self.collectionView.window != nil)
    {
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
//                [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
                change[@(type)] = newIndexPath;
                break;
                
            case NSFetchedResultsChangeDelete:
//                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                change[@(type)] = indexPath;
                break;
                
            case NSFetchedResultsChangeUpdate:
//                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                change[@(type)] = indexPath;
                break;
                
            case NSFetchedResultsChangeMove:
//                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//                [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
                change[@(type)] = @[indexPath, newIndexPath];
                break;
        }
        [self.objectChanges addObject:change];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
    return;

    if ([self.sectionChanges count]>0){
        [self.collectionView performBatchUpdates:^{

            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }


    if ([self.objectChanges count] > 0 && [self.sectionChanges count]==0) {

        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            [self.collectionView reloadData];
        } else {
            [self.collectionView performBatchUpdates:^{

                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                //                            [self.collectionView deleteItemsAtIndexPaths:obj[0]];
                                //                            [self.collectionView insertItemsAtIndexPaths:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
            
            
        }
    }

    [self.objectChanges removeAllObjects];

    self.beganUpdates = NO;
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }

    return shouldReload;
}

@end

