//
//  GoogleReaderAppDelegate.h
//  GoogleReader
//
//  Created by fernyb on 1/11/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GoogleReaderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
