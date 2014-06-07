//
//  Item.m
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "Item.h"
#import "PeerShopInterface.h"

@implementation Item

@dynamic thumbnailUrl;
@dynamic unique;
@dynamic itemDescription;
@dynamic price;
@dynamic imageUrl;
@dynamic user;
@dynamic thumbnail;
@dynamic title;

+ (Item *)itemWithDict:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    Item *item = nil;

    NSString *unique = [NSString stringWithFormat:@"%@", [dict valueForKeyPath:ITEM_ID]];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];

    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (error || !matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                              inManagedObjectContext:context];
        item.unique = unique;
        item.title = [dict valueForKey:ITEM_TITLE_KEY];
        item.itemDescription = [dict valueForKey:ITEM_DESCRIPTION_KEY];
        item.price = [dict valueForKey:ITEM_PRICE_KEY];
        item.user = [dict valueForKey:ITEM_USER_KEY];
        item.thumbnail = nil;
        item.thumbnailUrl = [[PeerShopInterface itemThumbnailURL:dict] absoluteString];
        item.imageUrl = [[PeerShopInterface itemImageURL:dict] absoluteString];

    } else {
        item = [matches firstObject];
    }

    return item;
}

- (void) saveThumb:(NSData *) thumb
{
    self.thumbnail = thumb;
    [self.managedObjectContext save:nil];
}
@end
