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

@interface ZKAppDelegate ()
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

    ZKRequestCall *request1 = [ZKRequestCall new];
    [self.requestQueue addOperation:request1];
    [request1 release]; request1 = nil;
}

@end
