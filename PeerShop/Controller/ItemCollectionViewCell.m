//
//  ItemCollectionViewCell.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//
// Adapted from Paul Hegarty's Shutterbug demo for CS193P

#import "ItemCollectionViewCell.h"
#import "PeerShopInterface.h"

@interface ItemCollectionViewCell ()
@end

@implementation ItemCollectionViewCell

- (void) setItem:(NSDictionary *)item
{
    _item = item;
    [self downloadThumbnail];
}

typedef void (^CompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

- (void) downloadThumbnail
{
    if (self.item){
        NSURL *thumbURL = [PeerShopInterface ItemThumbnailURL:self.item];

        NSURLRequest *request = [NSURLRequest requestWithURL:thumbURL];

        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        CompletionBlock block = ^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            // this handler is not executing on the main queue, so we can't do UI directly here
            if (!error) {
                if ([request.URL isEqual:thumbURL]) {
                    // UIImage is an exception to the "can't do UI here"
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                    // but calling "self.image =" is definitely not an exception to that!
                    // so we must dispatch this back to the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{ self.imageView.image = image; });
                }
            }
        };

        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:block];
        [task resume];
    }
}

@end
