//
//  ZoomingScrollView.h
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"

@class RAPhotoBrowser;

@interface RAZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	
	// Browser
	RAPhotoBrowser *photoBrowser;
	
	// State
	int index;
	
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
	
}

// Properties
@property (nonatomic) int index;
@property (nonatomic, assign) RAPhotoBrowser *photoBrowser;
@property (nonatomic, retain) UIImageViewTap *photoImageView;

// Methods
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
