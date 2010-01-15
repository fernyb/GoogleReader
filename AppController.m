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


@implementation AppController

- (id) init
{
  self = [super init];
  if (self != nil) {
    action = kSubscribe;
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
  if([action isEqualToString:kSubscribe]) {
    GoogleReader * reader = [[GoogleReader alloc] init];
    [reader setEmail:[email stringValue]];
    [reader setPassword:[password stringValue]];
    [reader setRssURL:[feedURL stringValue]];
    [reader subscribe];
    [reader release];
  } else if ([action isEqualToString:kUnsubscribe]) {
    GoogleReader * reader = [[GoogleReader alloc] init];
    [reader setEmail:[email stringValue]];
    [reader setPassword:[password stringValue]];
    [reader setRssURL:[feedURL stringValue]];
    [reader unsubscribe];
    [reader release];
  }
}

- (void)didReceiveGoogleReaderResponse:(NSNotification *)notification
{
  [response setStringValue:[notification object]];
}

- (IBAction)findSelectedRadioButton:(id)sender
{
  NSButtonCell * cell = [sender selectedCell];
  switch ([cell tag]) {
    case 101:
        action = kSubscribe;
      break;
      case 102:
        action = kUnsubscribe;
        break;
      case 103:
        action = kDiscover;
      break;
    default:
        action = kSubscribe;
      break;
  }
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
