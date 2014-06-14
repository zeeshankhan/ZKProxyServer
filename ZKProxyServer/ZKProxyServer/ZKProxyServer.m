//
//  ZKProxyServer.m
//  ZKProxyServer
//
//  Created by Zeeshan Khan on 09/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKProxyServer.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <CFNetwork/CFNetwork.h>

@interface ZKProxyServer () {
	NSFileHandle *listeningHandle;
	CFSocketRef socket;
    CFHTTPMessageRef incomingRequest;
}
@end

@implementation ZKProxyServer

+ (instancetype)sharedInstance {
    static ZKProxyServer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)start {

	socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
	if (!socket) {
        NSLog(@"[Proxy Server] Unable to create socket.");
		return;
	}
    
	int reuse = true;
	int fileDescriptor = CFSocketGetNative(socket);
	if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(int)) != 0) {
        NSLog(@"[Proxy Server] Unable to set socket options.");
		return;
	}
	
	struct sockaddr_in address;
	memset(&address, 0, sizeof(address));
	address.sin_len = sizeof(address);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(8080);
	CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
	[(id)addressData autorelease];
	
	if (CFSocketSetAddress(socket, addressData) != kCFSocketSuccess) {
        NSLog(@"[Proxy Server] Unable to bind socket to address.");
		return;
	}
    
	listeningHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingConnectionNotification:)
                                                 name:NSFileHandleConnectionAcceptedNotification object:nil];
	[listeningHandle acceptConnectionInBackgroundAndNotify];
	
    NSLog(@"[Proxy Server] Started");
}

- (void)receiveIncomingConnectionNotification:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSFileHandle *incomingFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    if (incomingFileHandle) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingDataNotification:)
                                                     name:NSFileHandleDataAvailableNotification object:incomingFileHandle];
        
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
}

- (void)receiveIncomingDataNotification:(NSNotification *)notification {

    NSFileHandle *incomingFileHandle = [notification object];
    NSData *data = [incomingFileHandle availableData];
    
//NSString *strIncomingData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//NSLog(@"[Proxy Server] receiveIncomingDataNotification: %@", strIncomingData);
    
    if (data.length > 0) {

        if (!incomingRequest) {
            incomingRequest = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        }
        
        CFHTTPMessageAppendBytes(incomingRequest, [data bytes], [data length]);
        if (CFHTTPMessageIsHeaderComplete(incomingRequest) == true) {
            
//            NSURL *messageURL = [NSMakeCollectable(CFHTTPMessageCopyRequestURL(incomingRequest)) autorelease];
//            NSLog(@"URL: %@", messageURL.absoluteString);
//
//            NSString *httpMethod = [NSMakeCollectable(CFHTTPMessageCopyRequestMethod(incomingRequest)) autorelease];
//            NSLog(@"HTTP method: %@", httpMethod);
//
//            NSDictionary *httpHeaderFields = [NSMakeCollectable(CFHTTPMessageCopyAllHeaderFields(incomingRequest)) autorelease];
//            NSLog(@"HTTP Header Fields: %@", httpHeaderFields);
//
//            NSData *httpBodyData = [NSMakeCollectable(CFHTTPMessageCopyBody(incomingRequest)) autorelease];
//            NSString *httpBody = [[[NSString alloc] initWithData:httpBodyData encoding:NSUTF8StringEncoding] autorelease];
//            NSLog(@"HTTP Body: %@", httpBody);
            
            [self startResponse:incomingFileHandle];
        }
    }
}

- (void)startResponse:(NSFileHandle*)fileHandle {
    
    NSInteger responseCode = 200;
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, responseCode, NULL, kCFHTTPVersion1_1);

    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/plain");
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
    
    NSData *fileData = [@"This is my sample response for Web Service Call" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataLength = [NSString stringWithFormat:@"%ld", (unsigned long)[fileData length]];
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length", (CFStringRef)dataLength);

    CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
    
//    NSString *strHeaderData = [[[NSString alloc] initWithData:(NSData*)headerData encoding:NSUTF8StringEncoding] autorelease];
//    NSString *strFileData = [[[NSString alloc] initWithData:(NSData*)fileData encoding:NSUTF8StringEncoding] autorelease];
//    NSLog(@"[Proxy Server] Response: %@ %@", strHeaderData, strFileData);
    
    @try {
        [fileHandle writeData:(NSData *)headerData];
        if (fileData) {
            [fileHandle writeData:fileData];
        }
    }
    @catch (NSException *exception) {
        // Ignore the exception, it normally just means the client
        // closed the connection from the other end.
    }
    @finally {
        CFRelease(headerData);
        CFRelease(response);
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:fileHandle];
        if (fileHandle)
            [fileHandle closeFile];
        fileHandle = nil;
    }

}

- (void)stop {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:nil];
    
    if (listeningHandle != nil) {
        [listeningHandle closeFile];
        [listeningHandle release];
        listeningHandle = nil;
    }
    
    if (socket) {
        CFSocketInvalidate(socket);
        CFRelease(socket);
        socket = nil;
    }
    
}

@end
