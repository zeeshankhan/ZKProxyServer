//
//  ZKProxyServer.h
//  ZKProxyServer
//
//  Created by Zeeshan Khan on 09/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKProxyServer : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

@end
