//
//  AppController.h
//  GoogleReader
//
//  Created by fernyb on 1/11/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
  IBOutlet NSTextField * email;
  IBOutlet NSTextField * password;
  IBOutlet NSTextField * feedURL;
  IBOutlet NSTextField * response;
}

- (IBAction)subscribeBtn:(id)sender;
- (void)didReceiveGoogleReaderResponse:(NSNotification *)notification;

@end
