//
//  RAPhotoBrowser.h
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RAPhoto.h"
#import "FBConnect.h"

typedef enum _UIActionTypes
{
	kEmailPhoto			=	0,
	kSaveToPhotoAlbum	=	1,
	kShareOnFacebook	=	2
} UIActionTypes;

@class RAZoomingScrollView, RAAnimatedTextView, Facebook;

@interface RAPhotoBrowser : UIViewController <UIScrollViewDelegate, RAPhotoDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate> {
	
	// Photos
	NSArray *photos;
	
	// Views
	UIScrollView *pagingScrollView;
	
	// Paging
	NSMutableSet *visiblePages, *recycledPages;
	int currentPageIndex;
	int pageIndexBeforeRotation;
	
	// Navigation & controls
	UIToolbar *toolbar;
	NSTimer *controlVisibilityTimer;
	UIBarButtonItem *previousButton, *nextButton, *actionButton, *slideshowButton, *robotangelButton;
	
	NSString * _imageTitle;
	RAAnimatedTextView * textLayer;

	BOOL performingLayout;
	BOOL rotating;
	
	NSTimer * _slideshowTimer;
	BOOL _slideshowPlaying;
	
	Facebook * _facebook;
	
}

// Init
- (id)initWithPhotos:(NSArray *)photosArray;

// Photos
- (UIImage *)imageAtIndex:(int)index;
- (RAPhoto *)currentPhoto;

// Layout
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(int)index;
- (RAZoomingScrollView *)pageDisplayedAtIndex:(int)index;
- (RAZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(RAZoomingScrollView *)page forIndex:(int)index;
- (void)didStartViewingPageAtIndex:(int)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForAnimatingLabelView;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(int)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(int)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;
- (void)startSlideShow;
- (void)stopSlideShow;
- (void)advanceSlide;


// Controls
- (void)cancelControlHiding;
- (void)hideControls;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

// UI Action Sheet
- (void)showActionSheet;
- (void)saveToPhotoAlbum;
- (void)emailCurrentPhoto;

// Properties
- (void)setInitialPageIndex:(int)index;

// Facebook integration
- (void)publishPhoto;


@end

