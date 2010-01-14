//
//  AppController.m
//  GoogleReader
//
//  Created by fernyb on 1/11/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "AppController.h"
#import "GoogleReader.h"


@implementation AppController

- (id) init
{
  self = [super init];
  if (self != nil) {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveGoogleReaderResponse:) 
                                                 name:@"didReceiveGoogleReaderResponse" 
                                               object:nil];
  }
  return self;
}

- (void)awakeFromNib
{
  [feedURL setStringValue:@"http://cocoacast.com/?q=rss.xml"];
}

- (IBAction)subscribeBtn:(id)sender
{
  GoogleReader * reader = [[GoogleReader alloc] init];
  [reader setEmail:[email stringValue]];
  [reader setPassword:[password stringValue]];
  [reader setRssURL:[feedURL stringValue]];
  [reader subscribe];
  [reader release];
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
