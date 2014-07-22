//
//  ZKRequestCall.m
//  ZKProxyServer
//
//  Created by Zeeshan Khan on 02/07/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKRequestCall.h"

@interface ZKRequestCall()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection* operationConnection;
@end

@implementation ZKRequestCall

- (void)main {
    
    if ([self isCancelled])
        return;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"NSOperation Calling...");

    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8080/"];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:[@"Request Body Data" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];

    // 1. Nothing worked (None of the delegate method get called.)
//    [NSURLConnection connectionWithRequest:request delegate:self];

    
    // 2. It WORKED for all.
//    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//    [con setDelegateQueue:[NSOperationQueue currentQueue]];
//    [con start];


    // 3A. It didn’t work for large file.
//    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//    [con scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    [con start];

    
    // 3B. It didn’t work for large file.
//    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//    [con scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//    [con start];
    
    
    // 4. It WORKED for all. (It worked for NSDefaultRunLoopMode mode as well, where apple document says this “The mode to deal with input sources other than NSConnection objects.”).
//    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//    NSRunLoop *loop = [NSRunLoop currentRunLoop];
//    [con scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
//    [con start];
//    [loop run];   // [loop runUntilDate:[NSDate distantFuture]]; // Need to stop this run loop as well

    
    // 5. It WORKED for all.
//    NSHTTPURLResponse *res = nil;
//    NSError *err = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
//    NSLog(@"Res Code: %ld, DataLen: %lu", (long)res.statusCode, (unsigned long)data.length);

    
    // 6. It WORKED for all.
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
//        NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage.jpg"];
//        NSLog(@"Res Code: %ld, DataLen: %lu, Path: %@", (long)res.statusCode, (unsigned long)data.length, imagePath);
//        [data writeToFile:imagePath atomically:YES];
//    }];

    
}

#pragma mark - Connection Delegate

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {

    // This method is called when the server has determined that it has enough information to create the NSURLResponse.
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = httpResponse.statusCode;
    NSLog(@"Response Status Code: %ld", (long)responseStatusCode);

    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // responseData is an instance variable declared elsewhere.
    self.responseData = [[NSMutableData new] autorelease];

}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    [self.responseData appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"Error Code: %@",error);
    self.responseData = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection  {
   
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"ConnectionDidFinish");

//    NSString *strIncomingData = [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease];
//    NSLog(@"Response String: %@ - %@", self.requestType, strIncomingData);

    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage1.PNG"];

    UIImage *img = [UIImage imageWithData:self.responseData];
    
    NSLog(@"Image is %@, DataLen: %lu, Path: %@", (img == nil)?@"nil":@"valid", (unsigned long)self.responseData.length, imagePath);
    [self.responseData writeToFile:imagePath atomically:YES];
    
    self.responseData = nil;
    
    [connection cancel];
    connection = nil;
}

- (void)dealloc {
    self.responseData = nil;
    [super dealloc];
}

@end
