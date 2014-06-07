//
//  PeerShopInterface.m
//  PeerShop
//
//  Created by Wen Hao on 5/14/14.

#import "PeerShopInterface.h"

typedef void (^CompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@interface PeerShopInterface ()

@end

#define BOUNDARY @"peershopboundary"
#define CSRF_KEY @"csrfmiddlewaretoken"
#define USERNAME_KEY @"PeerShopUsername"
#define PASSWORD_KEY @"PeerShopPassword"

@implementation PeerShopInterface

static NSString *_username;
static NSString *_password;
static BOOL loggedIn = NO;

+ (PeerShopInterface *) getSingleton
{
    static PeerShopInterface *singleton = nil;
    if (!singleton) {
        singleton  = [[PeerShopInterface alloc] init];
    }
    return singleton;
}

+ (NSString *) username
{
    if (!_username) {
        _username = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME_KEY];
    }
    return _username;
}

+ (NSString *) password
{
    if (!_password) {
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:PASSWORD_KEY];
    }
    return _password;
}

+ (void) setUsername:(NSString *)username
{
    _username = username;
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setPassword:(NSString *)password
{
    _password = password;
    [[NSUserDefaults standardUserDefaults] setObject:_password forKey:PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) isLoggedIn
{
    return loggedIn;
}

#pragma mark URLs

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
    return [NSURL URLWithString:[[self baseURLString] stringByAppendingString:@"/peerShop/app/item/new/"]];
}

+ (NSURL *) loginURL
{
    return [NSURL URLWithString:[[self baseURLString]
                                 stringByAppendingString:@"/user/login/"]];
}

+ (NSURL *) logoutURL
{
    return [NSURL URLWithString:[[self baseURLString]
                                 stringByAppendingString:@"/user/logout/"]];
}


#pragma mark Login

+ (NSString *) getCSRF
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[self baseURLString]]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"csrftoken"]){
            return cookie.value;
        }
    }
    return nil;
}

+ (void) loginWithCSRF:(SuccessCallback) callback
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
    [request setHTTPMethod:@"POST"];
    NSString *authString = [NSString stringWithFormat:
                            @"%@=%@&login=%@&password=%@",
                            CSRF_KEY ,
                            [PeerShopInterface getCSRF],
                            [PeerShopInterface username],
                            [PeerShopInterface password],
                            nil];
    [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =  [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = ![response.URL isEqual:[PeerShopInterface loginURL]];
            loggedIn = success;
            callback(success);
        });

    }];
    [dataTask resume];
}

+ (void) logOut:(SuccessCallback) callback
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[PeerShopInterface logoutURL]];
    [request setHTTPMethod:@"POST"];
    NSString *authString = [NSString stringWithFormat:
                            @"%@=%@",
                            CSRF_KEY ,
                            [PeerShopInterface getCSRF],
                            nil];
    [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =  [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            loggedIn = NO;
            callback(YES);
        });
    }];
    [dataTask resume];
}

+ (void) logoutThenLogin:(SuccessCallback) callback
{
    [PeerShopInterface logOut: ^(BOOL success){
        [PeerShopInterface loginWithCSRF:callback];
    }];
}

+ (void) login:(SuccessCallback) callback
{
    // obtain CSRF, then login
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[PeerShopInterface loginURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =  [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (loggedIn){
                [PeerShopInterface logoutThenLogin:callback];
            } else {
                [PeerShopInterface loginWithCSRF:callback];
            }
        });
    }];
    [dataTask resume];
}

+ (void) ensureLogin: (UIViewController *) vc
{
    if (!loggedIn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Not Logged In"
                                  message:@"Log in before creating an item."
                                  delegate:vc
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
            [alert show];
        });
    }
}

#pragma mark Download/Upload

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

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:block];
    [task resume];

}



+ (void) uploadItem: (NSDictionary *) itemDict withImage:(UIImage *) image withCallback:(void (^)(NSArray *itemList)) callback
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


    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request
                                                         fromData:body
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSArray *items = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:0
                                                                                                       error:NULL];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        callback(items);
                                                    });
                                                }];
    [task resume];
    
}







@end
