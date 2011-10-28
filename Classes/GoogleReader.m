//
//  GoogleReader.m
//  GoogleReaderSync
//
//  Created by fernyb on 1/10/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "JSON.h"
#import "GoogleReader.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@implementation GoogleReader
@synthesize email, password, sessionId, token;
@synthesize rssURL;

- (id)initWithEmail:(NSString *)address andPassword:(NSString *)passwd
{
  self = [super init];
  if (self != nil) {
    [self setEmail:address];
    [self setPassword:passwd];
  }
  return self;
}


#pragma mark Request A Token

- (void)requestToken
{
  if(cookies && [cookies count] > 0) {
    NSString * url = @"http://www.google.com/reader/api/0/token";

    ASIHTTPRequest * request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
    [request setUseCookiePersistance:YES];
    [request setRequestMethod:@"GET"];
    [request setRequestCookies:cookies];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];
    [request startSynchronous];

    NSString * html = [request responseString];
    [self setToken:html];
  }
}

#pragma mark Request A Session

- (void)requestSession
{
  if(cookies && [cookies count] > 0) {
    return;
  }

  NSString * url = [NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?service=reader&Email=%@&Passwd=%@", [self email], [self password]];

  ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(requestSessionDidFinish:)];
  [request setDidFailSelector:@selector(requestSessionDidFail:)];
  [request startSynchronous];
}

#pragma mark Request Session Delegate

- (void)requestSessionDidFinish:(ASIHTTPRequest *)request
{
  NSString * html = [request responseString];
  if(html) {
    NSArray * items = [html componentsSeparatedByString:@"\n"];

    cookies = [[NSMutableArray alloc] init];

    NSArray  * parts;
    NSString * cName;
    NSString * cValue;

    for(NSString * c in items) {
      parts  = [c componentsSeparatedByString:@"="];
      if([parts count] == 2) {
        cName  = [parts objectAtIndex:0];
        cValue = [parts objectAtIndex:1];

        NSMutableDictionary * cookieProperties = [[NSMutableDictionary alloc] init];
        [cookieProperties setValue:cName forKey:NSHTTPCookieName];
        [cookieProperties setValue:cValue forKey:NSHTTPCookieValue];
        [cookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
        [cookieProperties setValue:@".google.com" forKey:NSHTTPCookieDomain];

        NSHTTPCookie * cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];

        [cookies addObject:cookie];
        [cookie release], cookie = nil;
        [cookieProperties release], cookieProperties = nil;
      }
    } // end for
  } // end if html
}

- (void)requestSessionDidFail:(ASIHTTPRequest *)request
{
  NSLog(@"Request Session Did Fail: %@", [[request error] localizedDescription]);
}


- (NSString *)auth
{
  for(NSHTTPCookie * cookie in cookies) {
    if([[cookie name] isEqualToString:@"Auth"]) {
      return [cookie value];
    }
  }
  return nil;
}

#pragma mark Subscribe To RSS Feed

- (void)subscribeToRSSFeedURL:(NSString *)feedURL
{
  [self requestSession];
  [self requestToken];

  if([self token] && feedURL) {
    NSString * url = @"http://www.google.com/reader/api/0/subscription/quickadd?client=scroll";

    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:feedURL forKey:@"quickadd"];
    [request setPostValue:[self token] forKey:@"T"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];

    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDidSubscribe:)];
    [request setDidFailSelector:@selector(requestDidFailToSubscribe:)];
    [request startSynchronous];
  }
}

- (void)subscribe
{
  [self subscribeToRSSFeedURL:rssURL];
}

#pragma mark Subscribe Delegate Methods

- (void)requestDidSubscribe:(ASIHTTPRequest *)request
{
  NSString * response = [request responseString];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveGoogleReaderResponse" object:response];
}

- (void)requestDidFailToSubscribe:(ASIHTTPRequest *)request
{
  NSString * response = [[request error] localizedDescription];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveGoogleReaderResponse" object:response];
}

#pragma mark Unsubscribe

- (void)unsubscribeToRSSFeedURL:(NSString *)feedURL
{
  [self requestSession];
  [self requestToken];

  if([self token] && feedURL) {
    NSString * url = @"http://www.google.com/reader/api/0/subscription/edit?client=scroll";

    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:[NSString stringWithFormat:@"feed/%@", feedURL]
                   forKey:@"s"];
    [request setPostValue:@"unsubscribe" forKey:@"ac"];
    [request setPostValue:[self token] forKey:@"T"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];

    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDidUnsubscribe:)];
    [request setDidFailSelector:@selector(requestDidFailToUnsubscribe:)];
    [request startSynchronous];
  }
}

- (void)unsubscribe
{
  [self unsubscribeToRSSFeedURL:rssURL];
}

#pragma mark Unsubscribe Delegate Methods

- (void)requestDidUnsubscribe:(ASIHTTPRequest *)request
{
  NSString * response = [request responseString];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveGoogleReaderResponse" object:response];
}

- (void)requestDidFailToUnsubscribe:(ASIHTTPRequest *)request
{
  NSString * response = [[request error] localizedDescription];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveGoogleReaderResponse" object:response];
}

#pragma mark Unread RSS Feeds

/*
* Returns an Array of Unread RSS Feeds
*/
- (NSArray *)unreadRSSFeeds {
  if(!cookies && [cookies count] == 0) {
    [self requestSession];
  }

  NSString * timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
  NSString * url = [NSString stringWithFormat:@"http://www.google.com/reader/api/0/unread-count?allcomments=false&output=json&ck=%@&client=scroll", timestamp];

  ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  [request setRequestMethod:@"GET"];
  [request setRequestCookies:cookies];
  [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];

  [request startSynchronous];

  if([request responseStatusCode] != 200) {
    // Handle when status code is not 200
    return [NSArray array];
  }

  NSString * body = [request responseString];
  NSArray * feeds;
  NSDictionary * json;

  if([[body className] isEqualToString:@"NSString"]) {
    json = [body JSONValue];
  } else {
    // I hate doing this but I get an NSCFString.
    // Not sure how to do this the correct way.
    SBJsonParser * jsonParser = [SBJsonParser new];
    json = [jsonParser objectWithString:body];
    if (!json) {
      NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
    }
    [jsonParser release];
  }

  feeds = [json objectForKey:@"unreadcounts"];

  NSMutableArray * filteredFeeds = [NSMutableArray array];
  for(NSDictionary * f in feeds) {
    if([[f objectForKey:@"id"] hasPrefix:@"feed/"]) {
      [filteredFeeds addObject:f];
    }
  }

  return filteredFeeds;
}


#pragma mark Subscription List

- (NSArray *)subscriptionList
{
  if(!cookies && [cookies count] == 0) {
    [self requestSession];
  }

  NSString * url = @"http://www.google.com/reader/api/0/subscription/list?output=json&client=scroll";

  ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  [request setRequestMethod:@"GET"];
  [request setRequestCookies:cookies];
  [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=%@", [self auth]]];

  [request startSynchronous];

  NSMutableArray * feeds = [NSMutableArray array];
  if([request responseStatusCode] == 200) {
    NSString * body = [request responseString];
    if(body) {
      NSDictionary * json = [body JSONValue];
      feeds = [json objectForKey:@"subscriptions"];
    }
  }

  return feeds;
}

- (void) dealloc
{
  [email release];
  [password release];
  [sessionId release];
  [token release];
  [cookies release];
  [rssURL release];
  [super dealloc];
}


@end
