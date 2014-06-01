//
//  PeerShopInterface.h
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.

#import <Foundation/Foundation.h>

#define ITEM_TITLE_KEY @"title"
#define ITEM_DESCRIPTION_KEY @"description"
#define ITEM_PRICE_KEY @"price"



typedef void (^CallbackBlock)(UIImage *img);

@interface PeerShopInterface : NSObject
+ (NSURL *) itemThumbnailURL:(NSDictionary *)item;
+ (NSURL *) itemImageURL:(NSDictionary *)item;
+ (void) downloadThumbnail:(NSURL*)url withBlock:(CallbackBlock) callback;
+ (void) login;
+ (void) uploadItem: (NSDictionary *) itemDict withImage:(UIImage *) image;
+ (void) downloadItemList: (void (^)(NSArray *itemList)) block;
@end
