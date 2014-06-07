//
//  Item.h
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * thumbnail;

+ (Item *) itemWithDict:(NSDictionary *) dict inManagedObjectContext:(NSManagedObjectContext *) context;
- (void) saveThumb:(NSData *) thumb;
@end
