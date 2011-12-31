//
//  RAXMLStream.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//


#import "RAXMLStream.h"
#import "RAXPathQuery.h"

@implementation RAXMLStream

@synthesize data;

- (void) dealloc
{
  [data release];
  [super dealloc];
}

- (id) initWithData:(NSData *)theData isXML:(BOOL)isDataXML
{
  if (!(self = [super init]))
    return nil;

  self.data = theData;
  isXML = isDataXML;

  return self;
}

- (id) initWithXMLData:(NSData *)theData
{
  return [self initWithData:theData isXML:YES];
}

- (id) initWithHTMLData:(NSData *)theData
{
  return [self initWithData:theData isXML:NO];
}

// Returns all elements at xPath.
- (NSArray *) search:(NSString *)xPathOrCSS
{
  NSArray * detailNodes;
  if (isXML) {
    detailNodes = PerformXMLXPathQuery(data, xPathOrCSS);
  } else {
    detailNodes = PerformHTMLXPathQuery(data, xPathOrCSS);
  }

  NSMutableArray * hppleElements = [NSMutableArray array];
  for (id node in detailNodes) {
    RAXMLElement * e = [[RAXMLElement alloc] initWithNode:node];
    [hppleElements addObject:e];
    [e release];
  }
  return hppleElements;
}

// Returns first element at xPath
- (RAXMLElement *) at:(NSString *)xPathOrCSS
{
  NSArray * elements = [self search:xPathOrCSS];
  if ([elements count] >= 1)
    return [elements objectAtIndex:0];

  return nil;
}

@end
