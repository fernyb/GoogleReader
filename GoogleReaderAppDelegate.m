//
//  GoogleReaderAppDelegate.m
//  GoogleReader
//
//  Created by fernyb on 1/11/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "GoogleReaderAppDelegate.h"
#import "GoogleReader.h"


@implementation GoogleReaderAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
  GoogleReader * reader = [[GoogleReader alloc] init];
  [reader setEmail:@""];
  [reader setPassword:@""];
  [reader subscribeToRSSFeedURL:@"http://cocoacast.com/?q=rss.xml"];
  [reader release];
  
}

@end
