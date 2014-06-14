//
//  AppDelegate.m
//  ZKProxyServer
//
//  Created by Zeeshan Khan on 09/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKAppDelegate.h"
#import "ZKProxyServer.h"

@interface ZKAppDelegate () {
    NSMutableData *responseData;
}
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

    responseData = nil;
}

- (void)callWebService {
    NSLog(@"Call Web Service Button Clicked");
    if (responseData == nil) {
        NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8080/"];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
        [request setHTTPBody:[@"Request Body Data" dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        [NSURLConnection connectionWithRequest:request delegate:self];
        responseData = [NSMutableData new];
    }
}

#pragma mark - Connection Delegate

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = httpResponse.statusCode;
    NSLog(@"Response Status Code: %d", responseStatusCode);
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    NSLog(@"Error Code: %d",error.code);
    [responseData release]; responseData = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection  {
    
    NSString *strIncomingData = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Response: %@", strIncomingData);
    [responseData release]; responseData = nil;
}

@end
