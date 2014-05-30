//
//  PeerShopInterface.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.

#import "PeerShopInterface.h"

typedef void (^CompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@interface PeerShopInterface ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSHTTPCookie *csrfCookie;
@property (nonatomic) BOOL loggedIn;
@end


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

+ (NSURL *) loginURL
{
    return [NSURL URLWithString:[[self baseURL]
                                 stringByAppendingString:@"/user/login/"]];
}

- (void)makeLoginRequest:(NSMutableURLRequest *)request {
    if (request == nil) {
        request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
        self.loggedIn = NO;
    }

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"Failed to make connection");
    }
}


- (void) login
{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
    [request setHTTPMethod:@"POST"];
    NSString *authString = [NSString stringWithFormat:@"username=wenhao;password=mystery;csrfmiddlewaretoken=%@;", self.csrfCookie.value, nil];
    NSLog(@"%@", authString);
    [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];
    [self makeLoginRequest:request];
}



+ (void) downloadThumbnail:(NSURL*)url withBlock:(void (^)(UIImage *img)) callback
{

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

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


    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];


    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:block];
    [task resume];
    
}

+ (PeerShopInterface *) getSingleton
{
    static PeerShopInterface *singleton = nil;
    if (!singleton) {
        singleton  = [[PeerShopInterface alloc] init];
    }
    return singleton;
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    [connection cancel];

    if (self.loggedIn) {
        // We're logged in and good to go

    } else if (!self.loggedIn) {
        self.loggedIn = YES;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:[PeerShopInterface loginURL]];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"csrftoken"]) {
                self.csrfCookie = cookie;
                break;
            }
        }

        [self login];
    }



}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    [self.responseData setLength:0];
}




@end
