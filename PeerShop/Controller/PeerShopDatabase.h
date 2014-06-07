//
//  PeerShopDatabase.h
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PeerShopDatabase : NSObject

+ (PeerShopDatabase *)sharedDefaultDatabase;
#define PeerShopDatabaseAvailable @"PeerShopDatabaseAvailable"

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void)fetch;
- (void)fetchWithCompletionHandler:(void (^)(BOOL success))completionHandler;

@end
