//
//  PeerShopInterface.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "PeerShopInterface.h"



@implementation PeerShopInterface

+ (NSString *) baseURL
{
    return @"http://luiwenhao.com";
}

+ (NSURL *) URLforItemList
{
    return [NSURL URLWithString:[[self baseURL] stringByAppendingString:@"/peerShop/app/item/"]];
}

+ (NSURL *) ItemThumbnailURL:(NSDictionary *)item
{
    return [NSURL URLWithString:[[self baseURL] stringByAppendingString:[item valueForKey:@"thumbnailUrl"]]];
}


@end
