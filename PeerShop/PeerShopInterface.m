//
//  PeerShopInterface.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.

#import "PeerShopInterface.h"

typedef void (^CompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@interface PeerShopInterface ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) BOOL loggedIn;
@end

#define BOUNDARY @"peershopboundary"
#define CSRF_KEY @"csrfmiddlewaretoken"

@implementation PeerShopInterface

+ (NSString *) baseURLString
{
    //    return @"http://luiwenhao.com";
    return @"http://localhost:8000";
}

+ (NSURL *) URLforItemList
{
    return [NSURL URLWithString:[[self baseURLString] stringByAppendingString:@"/peerShop/app/item/"]];
}

+ (NSURL *) itemThumbnailURL:(NSDictionary *)item
{
    return [NSURL URLWithString:[[self baseURLString] stringByAppendingString:[item valueForKey:@"thumbnailUrl"]]];
}


+ (NSURL *) itemImageURL:(NSDictionary *)item
{
    return [NSURL URLWithString:[[self baseURLString] stringByAppendingString:[item valueForKey:@"imageUrl"]]];
}

+ (NSURL *) itemUploadURL
{
    return [NSURL URLWithString:[[self baseURLString] stringByAppendingString:@"/upload/new/"]];
}

+ (NSURL *) loginURL
{
    return [NSURL URLWithString:[[self baseURLString]
                                 stringByAppendingString:@"/user/login/"]];
}

+ (NSString *) getCSRF
{
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"csrftoken"]){
            return cookie.value;
        }
    }
    return nil;
}

- (void)makeLoginRequest:(NSMutableURLRequest *)request {
    if (request == nil) {
        request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
        self.loggedIn = NO;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =  [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (self.loggedIn) {
            // We're logged in and good to go

        } else if (!self.loggedIn) {
            self.loggedIn = YES;
            [self loginWithCSRF];
        }
        
    }];
    [dataTask resume];

}


- (void) loginWithCSRF
{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
    [request setHTTPMethod:@"POST"];
    NSString *authString = [NSString stringWithFormat:@"%@=%@&login=wenhao&password=mystery",CSRF_KEY ,[PeerShopInterface getCSRF], nil];
    [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];
    [self makeLoginRequest:request];
}

+ (void) login
{
    PeerShopInterface *me = [PeerShopInterface getSingleton];
    [me makeLoginRequest:nil];
}



+ (void) downloadItemList: (void (^)(NSArray *itemList)) block
{
    NSURL *url = [PeerShopInterface URLforItemList];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *items = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(items);
        });

    }];
    [dataTask resume];
    
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

    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sharedSession];


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


+ (void) uploadItem: (NSDictionary *) itemDict withImage:(UIImage *) image
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[PeerShopInterface itemUploadURL]];
    [request setHTTPMethod:@"POST"];

    NSArray *keys = itemDict.allKeys;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:itemDict];

    for (NSString *key in keys) {
        [params setObject:params[key] forKey:[@"image-" stringByAppendingString:key]];
        [params removeObjectForKey:key];
    }


    [params setObject:[PeerShopInterface getCSRF] forKey:CSRF_KEY];


    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    NSMutableData *body = [[NSMutableData alloc] init];
    // add item parameters
    for (id key in params){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"image\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }


    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {


    }];
    [task resume];

}







@end
