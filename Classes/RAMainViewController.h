//
//  RAMainViewController.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef enum _RAViewType
{
	kCategoriesView		= 0,
	kGalleryBrowswer,	

} RAViewType;


@class RAGallery, RAGalleriesView, RAImageScrollView, CATransition;


@interface RAMainViewController : UIViewController <UIScrollViewDelegate> {
	
	// ivars that control the categories
	RAGalleriesView * _scrollView;
	UILabel * _loadingLabel;
	NSArray	* _elements;
	
	NSTimer * _progressTimer;
	
	UIImageView * _progressImage;
	
	UIImage * _progress1;
	UIImage * _progress2;
	UIImage * _progress3;
	
	NSInteger _upOrDown;
	
	// ivars that control the gallery scrollview
	UIScrollView * _pagingScrollView;
    NSMutableSet * _recycledPages;
    NSMutableSet * _visiblePages;
	
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           _firstVisiblePageIndexBeforeRotation;
    CGFloat       _percentScrolledIntoFirstVisiblePage;
	NSArray * _images;
	
	UIToolbar * _galleryToolbar;
	NSUInteger _currentImageIndex;
	BOOL _galTBShown;

	BOOL _scrollViewGotBackToBeginning;
	
	NSUInteger _numberOfGalleriesLoaded;
	
	CATransition * _galleryLoadAnimation;
	CATransition * _categoriesLoadAnimation;
	
	BOOL _galleriesTransitioned;
	BOOL _categoriesTransitioned;
	
	BOOL _dataLoaded;
}

@property (readwrite, retain) RAGalleriesView * scrollView;
@property (readwrite, retain) UIScrollView * pagingScrollView;
@property (assign) IBOutlet UILabel * loadingLabel;
@property (assign) IBOutlet UIImageView * progressImage;
@property (readwrite, retain) IBOutlet NSArray * elements;
@property (nonatomic, readwrite, retain) NSArray * images;

+ (id)sharedViewController;
- (void)exitProgress;
- (void)galleryLoaded;
- (void)enterGallery:(RAGallery *)gallery;
- (NSArray *)projectElementsForURL:(NSURL *)url;
- (RAGallery *)createCategoryFromXMLElement:(NSDictionary *)element;

@end

