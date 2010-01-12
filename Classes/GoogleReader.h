//
//  GoogleReader.h
//  GoogleReaderSync
//
//  Created by fernyb on 1/10/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


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

- (void)requestToken;
- (void)requestSession;
- (void)subscribeToRSSFeedURL:(NSString *)feedURL;

@end
