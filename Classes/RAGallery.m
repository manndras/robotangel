//
//  RAGalleryType.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAGallery.h"
#import "RAMainViewController.h"
#import "RAGalleryLoadOperation.h"


@implementation RAGallery

@synthesize imageURL = _imageURL,
			categoryName = _categoryName,
			href = _href,
			images = _images,
			thumbnails = _thumbnails,
			galleryViewController = _galleryViewController;


- (id) initWithCategoryName:(NSString *)catName withHref:(NSString *)href imageURL:(NSString *)imageURL
{
	self = [super init];
	if (self != nil) {
		
		_categoryName = [catName retain];
		_href = [href retain];
		_imageURL = [imageURL retain];
		_images = [[NSMutableArray array] retain];
	}
	return self;
}


- (void)addImages:(NSArray *)images
{
	[self setImages:images];
	[[RAMainViewController sharedViewController] galleryLoaded];
	NSLog(@"%@", images);
}


- (void)loadGalleryDataForViewFrame:(CGRect)frame
{
	_targetFrame = frame;
	NSOperationQueue * galQueue = [[[NSOperationQueue alloc] init] autorelease];
	RAGalleryLoadOperation * loadOp = [[[RAGalleryLoadOperation alloc] initWithGallery:self] autorelease];
	[galQueue addOperation:loadOp];
}


- (void)dealloc
{
	[_categoryName release], _categoryName = nil;
	[_href release], _href = nil;
	[_imageURL release], _imageURL = nil;
	[_images release], _images = nil;
	[super dealloc];
}

@end
