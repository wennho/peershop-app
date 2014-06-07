//
//  ItemListViewController.h
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//
//  Adapted from Alexander Hsu's LittleFighters demo and Paul Hegarty's Shutterbug demo for CS193P

#import <UIKit/UIKit.h>


@interface ItemCollectionViewController : UICollectionViewController
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@end
