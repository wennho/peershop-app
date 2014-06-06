//
//  ItemCollectionViewLayout.m
//  PeerShop
//
//  Created by Wen Hao on 6/2/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "ItemCollectionViewLayout.h"

@implementation ItemCollectionViewLayout

#define SPACING 2



- (CGFloat) minimumInteritemSpacing
{
    return SPACING;
}

- (CGFloat) minimumLineSpacing
{
    return SPACING;
}

- (CGSize) itemSize
{
    return CGSizeMake(105, 105);
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.center = CGPointMake(attributes.center.x,attributes.center.y + 200);
    attributes.alpha = 0;
    return attributes;
}

@end
