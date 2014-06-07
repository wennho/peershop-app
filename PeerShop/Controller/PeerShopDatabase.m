//
//  PeerShopDatabase.m
//  PeerShop
//
//  Created by Wen Hao on 6/6/14.
//  Copyright (c) 2014 Wen Hao. All rights reserved.
//

#import "PeerShopDatabase.h"
#import "PeerShopInterface.h"
#import "Item.h"

@interface PeerShopDatabase()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation PeerShopDatabase

+ (PeerShopDatabase *)sharedDefaultDatabase
{

    static PeerShopDatabase *database = nil;
    if (!database) {
        database = [[self alloc] initWithName:@"PeerShopDatabase"];
    }

    return database;
}


- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        if ([name length]) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
            url = [url URLByAppendingPathComponent:name];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                [document openWithCompletionHandler:^(BOOL success) {
                    if (success) self.managedObjectContext = document.managedObjectContext;
                }];
            } else {
                [document saveToURL:url
                   forSaveOperation:UIDocumentSaveForCreating
                  completionHandler:^(BOOL success) {
                      if (success) {
                          self.managedObjectContext = document.managedObjectContext;
                          [self fetch];
                      }

                  }];
            }
        } else {
            self = nil;
        }
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:PeerShopDatabaseAvailable
                                                        object:self];
}


- (void)fetch
{
    [self fetchWithCompletionHandler:nil];
}

- (void)fetchWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    if (self.managedObjectContext) {
        [PeerShopInterface downloadItemList:^(NSArray *itemList) {

            [self.managedObjectContext performBlock:^{
                // load up the Core Data database
                for (NSDictionary *itemDict in itemList) {
                    [Item itemWithDict:itemDict inManagedObjectContext:self.managedObjectContext];
                }

                if (completionHandler) {
                    completionHandler(YES);
                }

            }];

        }];

    } else {
        if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(NO);
        });
    }
}


@end
