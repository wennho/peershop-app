//
//  ItemCollectionViewCell.h
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) Item *item;
@end
