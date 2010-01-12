//
//  GoogleReader.h
//  GoogleReaderSync
//
//  Created by fernyb on 1/10/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ASIHTTPRequest;

@interface GoogleReader : NSObject {
  NSString * email;
  NSString * password;
  NSString * sessionId;
  NSString * token;
  NSMutableArray * cookies;
}

@property(copy) NSString * email;
@property(copy) NSString * password;
@property(copy) NSString * sessionId;
@property(copy) NSString * token;

- (id)initWithEmail:(NSString *)address andPassword:(NSString *)passwd;

- (void)requestToken;
- (void)requestSession;
- (void)subscribeToRSSFeedURL:(NSString *)feedURL;

- (void)requestDidSubscribe:(ASIHTTPRequest *)request;
- (void)requestDidFailToSubscribe:(ASIHTTPRequest *)request;

@end
