//
//  GoogleReader.m
//  GoogleReaderSync
//
//  Created by fernyb on 1/10/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "GoogleReader.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation GoogleReader
@synthesize email, password, sessionId, token;

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
  [self requestSession];
  
  if(cookies && [cookies count] > 0) {      
    NSString * url = @"http://www.google.com/reader/api/0/token";
    
    ASIHTTPRequest * request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
    [request setUseCookiePersistance:YES];
    [request setRequestMethod:@"GET"];
    [request setRequestCookies:cookies];
    [request startSynchronous];
    
    NSString * html = [request responseString];
    [self setToken:html];
  }
}

#pragma mark Request A Session

- (void)requestSession
{
  if(![self sessionId]) {
    NSString * url = [NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?service=reader&Email=%@&Passwd=%@", [self email], [self password]];
    
    //
    // Note to self: Asychronous will be way better!
    //
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    
    NSString * html = [request responseString];
    
    if(html) {
      if(cookies) {
        [cookies release], cookies = nil;
      }
      
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
}

#pragma mark Subscribe To RSS Feed

- (void)subscribeToRSSFeedURL:(NSString *)feedURL
{
  [self requestToken];
  
  if([self token]) {
    NSString * url = @"http://www.google.com/reader/api/0/subscription/quickadd?client=scroll";
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:feedURL forKey:@"quickadd"];
    [request setPostValue:[self token] forKey:@"T"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDidSubscribe:)];
    [request setDidFailSelector:@selector(requestDidFailToSubscribe:)];
    [request startSynchronous];
  }
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

- (void) dealloc
{
  [email release];
  [password release];
  [sessionId release];
  [token release];
  [cookies release];
  [super dealloc];
}


@end
