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
  NSString * rssURL;
}

@property(copy) NSString * email;
@property(copy) NSString * password;
@property(copy) NSString * sessionId;
@property(copy) NSString * token;
@property(copy) NSString * rssURL;

- (id)initWithEmail:(NSString *)address andPassword:(NSString *)passwd;

- (void)requestToken;

- (void)requestSession;
- (void)requestSessionDidFinish:(ASIHTTPRequest *)request;
- (void)requestSessionDidFail:(ASIHTTPRequest *)request;

- (void)subscribeToRSSFeedURL:(NSString *)feedURL;
- (void)subscribe;
- (void)requestDidSubscribe:(ASIHTTPRequest *)request;
- (void)requestDidFailToSubscribe:(ASIHTTPRequest *)request;

- (void)unsubscribe;
- (void)unsubscribeToRSSFeedURL:(NSString *)feedURL;
- (void)requestDidUnsubscribe:(ASIHTTPRequest *)request;
- (void)requestDidFailToUnsubscribe:(ASIHTTPRequest *)request;

- (NSArray *)unreadRSSFeeds;

@end
