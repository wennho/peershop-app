//
//  PeerShopInterface.h
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeerShopInterface : NSObject
+ (NSURL *) URLforItemList;
+ (NSURL *) ItemThumbnailURL:(NSDictionary *)item;
@end
