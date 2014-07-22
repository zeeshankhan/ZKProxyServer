//
//  AppDelegate.m
//  ZKProxyServer
//
//  Created by Zeeshan Khan on 09/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKAppDelegate.h"
#import "ZKProxyServer.h"
#import "ZKRequestCall.h"

@interface ZKAppDelegate () {
    NSMutableData *responseData;
}
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@end

@implementation ZKAppDelegate

#pragma mark - UIApplication delegates

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    [self addButtonInWindow];
    [[ZKProxyServer sharedInstance] start];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[ZKProxyServer sharedInstance] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[ZKProxyServer sharedInstance] start];
}

#pragma mark - Button & IBAction

- (void)addButtonInWindow {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn.layer setBorderColor:[btn.titleLabel textColor].CGColor];
    [btn.layer setCornerRadius:5];
    [btn.layer setBorderWidth:1];
    
    [btn setTitle:@"Call Web Service" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(callWebService) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 100, 200, 35)];
    [btn setCenter:_window.center];
    [_window addSubview:btn];
    
    self.requestQueue = [[NSOperationQueue new] autorelease];
}

- (void)callWebService {
    NSLog(@"Call Web Service Button Clicked");

    // NSOperation calling.. make sure you only call this, comment below calling.
//    ZKRequestCall *request1 = [ZKRequestCall new];
//    [self.requestQueue addOperation:request1];
//    [request1 release]; request1 = nil;
    
    
    
    NSLog(@"Main Thread calling...");
    if (responseData == nil) {

        NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8080/"];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
        [request setHTTPBody:[@"Request Body Data" dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        
        
        // 1. It didn't work for any.
//        [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        // 2. It didn't work for large image file, tried with 18MB.
        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [con setDelegateQueue:[NSOperationQueue currentQueue]];
        [con start];

        
        // 3. It didn't work for large image file, tried with 18MB.
//        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//        [con scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode]; // Or NSRunLoopCommonModes
//        [con start];

        
        // 4. It didn't work for large image file, tried with 18MB.
//        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//        NSRunLoop *loop = [NSRunLoop currentRunLoop];
//        [con scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
//        [con start];
//        [loop run]; // need to close this.
        
        
        // 5. Crash (need to look into)
//        NSHTTPURLResponse *res = nil;
//        NSError *err = nil;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
//        NSLog(@"Res Code: %ld, DataLen: %lu", (long)res.statusCode, (unsigned long)data.length);
        
        
        // 6. WORKED for large image as well
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
//            NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage.jpg"];
//            NSLog(@"Res Code: %ld, DataLen: %lu, Path: %@", (long)res.statusCode, (unsigned long)data.length, imagePath);
//            [data writeToFile:imagePath atomically:YES];
//        }];

        responseData = [NSMutableData new];
    }
}

#pragma mark - Connection Delegate

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = httpResponse.statusCode;
    NSLog(@"Response Status Code: %ld", (long)responseStatusCode);
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    NSLog(@"Error Code: %@", error);
    [responseData release]; responseData = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection  {
    
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage.jpg"];
    NSLog(@"Img path: %@, DataLen: %lu", imagePath, (unsigned long)responseData.length);
    [responseData writeToFile:imagePath atomically:YES];

//    NSString *strIncomingData = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
//    NSLog(@"Response: %@", strIncomingData);
    [responseData release]; responseData = nil;
}


@end
