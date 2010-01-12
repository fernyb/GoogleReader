//
//  GoogleReaderTest.m
//  GoogleReader
//
//  Created by fernyb on 1/12/10.
//  Copyright 2010 Fernando Barajas. All rights reserved.
//

#import "GoogleReaderTest.h"
#import "GoogleReader.h"


@implementation GoogleReaderTest

- (void)setUp
{
  email = @"fernyb@fernyb.net";
  password = @"super-password";
}

- (void)testSetsEmailAndPassword
{
  GoogleReader * reader = [[GoogleReader alloc] init];
  [reader setEmail:email];
  [reader setPassword:password];
  
  GHAssertEqualStrings([reader email], email, @"should have email");
  GHAssertEqualStrings([reader password], password, @"should have password");
  [reader release];
}

- (void)testInitSetsEmailAndPassword
{
  GoogleReader * reader = [[GoogleReader alloc] initWithEmail:email andPassword:password];
  
  GHAssertEqualStrings([reader email], email, @"should have email");
  GHAssertEqualStrings([reader password], password, @"should have password");
  [reader release];
}


@end
