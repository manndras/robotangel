//
//  RAXMLStream.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAXMLElement.h"

@interface RAXMLStream : NSObject {
  NSData * data;
  BOOL isXML;
}

- (id) initWithData:(NSData *)theData isXML:(BOOL)isDataXML;
- (id) initWithHTMLData:(NSData *)theData;
- (id) initWithXMLData:(NSData *)theData;
- (NSArray *) search:(NSString *)xPathOrCSS;
- (RAXMLElement *) at:(NSString *)xPathOrCSS;

@property (retain) NSData * data;

@end
