//
//  ItemCollectionViewCell.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.

#import "ItemCollectionViewCell.h"
#import "PeerShopInterface.h"

@interface ItemCollectionViewCell ()
@end

@implementation ItemCollectionViewCell

- (void) setItem:(Item *)item
{
    _item = item;
    [self downloadThumbnail];
}



- (void) downloadThumbnail
{
    if (self.item){
        NSURL *thumbURL = [NSURL URLWithString:self.item.thumbnailUrl];

        [PeerShopInterface downloadThumbnail:thumbURL
                                   withBlock:^(UIImage *img) {
                                       self.imageView.image = img;
                                       [self.item saveThumb:UIImageJPEGRepresentation(img, 1.0)];
                                   }];
    }
}

@end
