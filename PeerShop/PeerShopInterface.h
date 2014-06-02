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
typedef void (^SuccessCallback)(BOOL success);

@interface PeerShopInterface : NSObject

+ (NSURL *) itemThumbnailURL:(NSDictionary *)item;
+ (NSURL *) itemImageURL:(NSDictionary *)item;
+ (void) downloadThumbnail:(NSURL*)url withBlock:(CallbackBlock) callback;
+ (void) login:(SuccessCallback) callback;
+ (void) ensureLogin: (UIViewController *) vc;
+ (void) uploadItem: (NSDictionary *) itemDict withImage:(UIImage *) image withCallback:(void (^)(NSArray *itemList)) callback;
+ (void) downloadItemList: (void (^)(NSArray *itemList)) block;

+ (NSString *) username;
+ (NSString *) password;
+ (void) setUsername:(NSString *)username;
+ (void) setPassword:(NSString *)password;

@end
