//
//  RAGalleryType.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAGalleryViewController;

@interface RAGallery : NSObject 
{
	RAGalleryViewController * _galleryViewController;
	NSString * _imageURL;
	NSString * _categoryName;
	NSString * _href;
	NSArray * _images;
	NSArray * _thumbnails;
	CGRect _targetFrame;
}

@property (nonatomic, readwrite, retain) NSString * imageURL;
@property (nonatomic, readwrite, retain) NSString * categoryName;
@property (nonatomic, readwrite, retain) NSString * href;
@property (nonatomic, readwrite, retain) NSArray * images;
@property (nonatomic, readwrite, retain) NSArray * thumbnails;
@property (nonatomic, readwrite, retain) IBOutlet RAGalleryViewController * galleryViewController;


- (id) initWithCategoryName:(NSString *)catName withHref:(NSString *)href imageURL:(NSString *)imageURL;
- (void)addImages:(NSArray *)images;
- (void)loadGalleryDataForViewFrame:(CGRect)frame;


@end
