//
//  AppController.m
//  GoogleReader
//
//  Created by fernyb on 1/11/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "AppController.h"
#import "GoogleReader.h"

static NSString * kSubscribe   = @"subscribe";
static NSString * kUnsubscribe = @"unsubscribe";
static NSString * kDiscover    = @"discover";
static NSString * kUnreadFeeds = @"unreadFeeds";

@implementation AppController
@synthesize actions, selectedAction;

- (id) init
{
  self = [super init];
  if (self != nil) {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveGoogleReaderResponse:) 
                                                 name:@"didReceiveGoogleReaderResponse" 
                                               object:nil];
    selectedAction = kSubscribe;
    [self setActions:[NSArray arrayWithObjects:kSubscribe, kUnsubscribe, kUnreadFeeds, kDiscover, nil]];
  }
  return self;
}

- (void)awakeFromNib
{
  [feedURL setStringValue:@"http://cocoacast.com/?q=rss.xml"];
}

- (IBAction)subscribeBtn:(id)sender
{
  if([selectedAction isEqualToString:kSubscribe]) {
    GoogleReader * reader = [[GoogleReader alloc] init];
    [reader setEmail:[email stringValue]];
    [reader setPassword:[password stringValue]];
    [reader setRssURL:[feedURL stringValue]];
    [reader subscribe];
    [reader release];
  
  } else if ([selectedAction isEqualToString:kUnsubscribe]) {
    GoogleReader * reader = [[GoogleReader alloc] init];
    [reader setEmail:[email stringValue]];
    [reader setPassword:[password stringValue]];
    [reader setRssURL:[feedURL stringValue]];
    [reader unsubscribe];
    [reader release];
    
  } else if ([selectedAction isEqualToString:kUnreadFeeds]) {
    GoogleReader * reader = [[GoogleReader alloc] init];
    [reader setEmail:[email stringValue]];
    [reader setPassword:[password stringValue]];
    
    NSArray * feeds = [reader unreadRSSFeeds];
    NSLog(@"%@", feeds);
    
    [reader release];
  }
}

- (void)didReceiveGoogleReaderResponse:(NSNotification *)notification
{
  [response setStringValue:[notification object]];
}

- (void) dealloc
{
  [email release];
  [password release];
  [feedURL release];
  [response release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}


@end
