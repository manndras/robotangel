//
//  RAGalleryLoadOperation.m
//  robotangel
//
//  Created by rdaly on 1/23/11.
//  Copyright 2011 Microsoft Corporation. All rights reserved.
//

#import "RAGalleryLoadOperation.h"
#import "RAGallery.h"
#import "RAXMLStream.h"
#import "RAPhoto.h"
#import "RAConstants.h"

static NSString * urlFormat = @"url:";
//static NSString * mediaIDFormat = @"media:id:";
static NSString * descriptionFormat = @"description:";
//static NSString * widthFormat = @"width:";
//static NSString * heightFormat = @"height:";


@implementation RAGalleryLoadOperation

@synthesize gallery = _gallery,
			galleryURL = _galleryURL;

- (id) initWithGallery:(RAGallery *)gallery
{
	self = [super init];
	if (self != nil) {
		
		_gallery = [gallery retain];
		_galleryURL = [[NSURL URLWithString:[kRobotangelCarbonMadeURL stringByAppendingPathComponent:[_gallery href]]] retain];
		
	}
	return self;
}


- (void)main
{
	
	NSURLRequest * baseRequest = [NSURLRequest requestWithURL:[self galleryURL]];
	
	if ( [NSURLConnection canHandleRequest:baseRequest] )
	{
		NSArray * scriptNodes = [self scriptElementsForURL:[self galleryURL]];
		
		if ( [scriptNodes count] == 1 )
		{
			NSDictionary * xmlDict = [[scriptNodes objectAtIndex:0] node];
			NSDictionary * htmlDict = [[xmlDict objectForKey:TFHppleNoteChildArrayKey] objectAtIndex:0];
			NSString * htmlBlob = [htmlDict objectForKey:TFHppleNodeContentKey];
			NSArray * imageURLs = [self imagesFromGalleryHTMLBlob:htmlBlob];
			
			[[self gallery] performSelectorOnMainThread:@selector(addImages:) withObject:imageURLs waitUntilDone:YES];
		}
		else 
		{
			// error
		}
		
	}
	
}

- (NSArray *)scriptElementsForURL:(NSURL *)url
{
	
	NSData *data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
	RAXMLStream * xpathParser = [[[RAXMLStream alloc] initWithHTMLData:data] autorelease];
	NSArray * elements  = [xpathParser search:@"//script[contains(.,'new CM.Gallery')]"];
		
	return elements;
}



- (NSArray *)imagesFromGalleryHTMLBlob:(NSString *)htmlBlob
{
	NSMutableArray * images = [NSMutableArray array];
	
	NSArray * paragraphs = [htmlBlob componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
	NSMutableArray * cleanArray = [NSMutableArray array];
	
	for ( NSString * paragraph in paragraphs )
	{
		if ( [paragraph hasPrefix:@"{"] )
		{
			[cleanArray addObject:[[[[[paragraph stringByReplacingOccurrencesOfString:@"\"" withString:@""]
												stringByReplacingOccurrencesOfString:@"{" withString:@""]
												stringByReplacingOccurrencesOfString:@"}" withString:@""]
												stringByReplacingOccurrencesOfString:@"[" withString:@","]
												stringByReplacingOccurrencesOfString:@"]" withString:@""]];
		}
	}
	
	for ( NSString * item in cleanArray )
	{
		NSArray * components = [item componentsSeparatedByString:@","];
		

		NSString * predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", urlFormat];
		NSPredicate * pred = [NSPredicate predicateWithFormat:predicateFormat];
		NSString * url = [[[components filteredArrayUsingPredicate:pred] 
														objectAtIndex:0] 
														stringByReplacingOccurrencesOfString:urlFormat withString:@""];
		/*
		predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", mediaIDFormat];
		pred = [NSPredicate predicateWithFormat:predicateFormat];
		NSString * mediaID = [[[components filteredArrayUsingPredicate:pred] 
														objectAtIndex:0]
														stringByReplacingOccurrencesOfString:mediaIDFormat withString:@""];	
		*/
		predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", descriptionFormat];
		pred = [NSPredicate predicateWithFormat:predicateFormat];
		NSString * description = [[components filteredArrayUsingPredicate:pred] objectAtIndex:0];
		if ( description )
		{
			description = [description stringByReplacingOccurrencesOfString:descriptionFormat withString:@""];
		}
		/*
		predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", widthFormat];
		pred = [NSPredicate predicateWithFormat:predicateFormat];
		NSString * width = [(NSString *)[[components filteredArrayUsingPredicate:pred] 
							 objectAtIndex:0] 
							stringByReplacingOccurrencesOfString:widthFormat withString:@""];

	
		
		predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", heightFormat];
		pred = [NSPredicate predicateWithFormat:predicateFormat];
		NSString * height = [(NSString *)[[components filteredArrayUsingPredicate:pred] 
										 objectAtIndex:0] 
							 stringByReplacingOccurrencesOfString:heightFormat withString:@""];
		
		if ( description )
		{
			description = [description stringByReplacingOccurrencesOfString:descriptionFormat withString:@""];
		}

		
		NSDictionary * imageData = [NSDictionary dictionaryWithObjectsAndKeys:url, @"imageURL", 
																			mediaID, @"imageID",
																			description, @"imageName", 
																			width, @"width", 
																			height, @"height", nil];
		*/
		[images addObject:[RAPhoto photoWithURL:[NSURL URLWithString:url] title:description]];
	}
	
	return [NSArray arrayWithArray:images];
}

- (void)dealloc
{
	[_gallery release], _gallery = nil;
	[super dealloc];
}

@end
