//
//  PeerShopInterface.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.
//
// Adapted from Paul Hegarty's Shutterbug demo for CS193P

#import "PeerShopInterface.h"

typedef void (^CompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@implementation PeerShopInterface

+ (NSString *) baseURL
{
//    return @"http://luiwenhao.com";
    return @"http://localhost:8000";
}

+ (NSURL *) URLforItemList
{
    return [NSURL URLWithString:[[self baseURL] stringByAppendingString:@"/peerShop/app/item/"]];
}

+ (NSURL *) ItemThumbnailURL:(NSDictionary *)item
{
    return [NSURL URLWithString:[[self baseURL] stringByAppendingString:[item valueForKey:@"thumbnailUrl"]]];
}


+ (NSURL *) ItemImageURL:(NSDictionary *)item
{
    return [NSURL URLWithString:[[self baseURL] stringByAppendingString:[item valueForKey:@"imageUrl"]]];
}


+ (void) downloadThumbnail:(NSURL*)url withBlock:(void (^)(UIImage *img)) callback
{

        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        CompletionBlock block = ^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            // this handler is not executing on the main queue, so we can't do UI directly here
            if (!error) {
                if ([request.URL isEqual:url]) {
                    // UIImage is an exception to the "can't do UI here"
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                    // but calling "self.image =" is definitely not an exception to that!
                    // so we must dispatch this back to the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(image);
                    });
                }
            }
        };

        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:block];
        [task resume];

}


@end
