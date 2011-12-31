//
//  RAXMLElement.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const TFHppleNodeContentKey;
extern NSString * const TFHppleNodeNameKey;
extern NSString * const TFHppleNodeAttributeArrayKey;
extern NSString * const TFHppleNodeAttributeNameKey;
extern NSString * const TFHppleNoteChildArrayKey;


@interface RAXMLElement : NSObject {
  NSDictionary * node;
}

@property (nonatomic, readwrite, retain) NSDictionary * node;

- (id) initWithNode:(NSDictionary *) theNode;

// Returns this tag's innerHTML content.
- (NSString *) content;

// Returns the name of the current tag, such as "h3".
- (NSString *) tagName;

// Returns tag attributes with name as key and content as value.
//   href  = 'http://peepcode.com'
//   class = 'highlight'
- (NSDictionary *) attributes;

// Provides easy access to the content of a specific attribute, 
// such as 'href' or 'class'.
- (NSString *) objectForKey:(NSString *) theKey;

@end
