//
//  RAXMLElement.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//


#import "RAXMLElement.h"

NSString * const TFHppleNodeContentKey           = @"nodeContent";
NSString * const TFHppleNodeNameKey              = @"nodeName";
NSString * const TFHppleNodeAttributeArrayKey    = @"nodeAttributeArray";
NSString * const TFHppleNodeAttributeNameKey     = @"attributeName";
NSString * const TFHppleNoteChildArrayKey		 = @"nodeChildArray";

@implementation RAXMLElement

@synthesize node;

- (void) dealloc
{
  [node release];

  [super dealloc];
}

- (id) initWithNode:(NSDictionary *) theNode
{
  if (!(self = [super init]))
    return nil;

  [theNode retain];
  node = theNode;

  return self;
}


- (NSString *) content
{
  return [node objectForKey:TFHppleNodeContentKey];
}


- (NSString *) tagName
{
  return [node objectForKey:TFHppleNodeNameKey];
}

- (NSDictionary *) attributes
{
  NSMutableDictionary * translatedAttributes = [NSMutableDictionary dictionary];
  for (NSDictionary * attributeDict in [node objectForKey:TFHppleNodeAttributeArrayKey]) {
    [translatedAttributes setObject:[attributeDict objectForKey:TFHppleNodeContentKey]
                             forKey:[attributeDict objectForKey:TFHppleNodeAttributeNameKey]];
  }
  return translatedAttributes;
}

- (NSString *) objectForKey:(NSString *) theKey
{
  return [[self attributes] objectForKey:theKey];
}

- (id) description
{
  return [node description];
}

@end
