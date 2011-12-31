//
//  RAZoomingScrollView.m
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAZoomingScrollView.h"
#import "RAPhotoBrowser.h"

@implementation RAZoomingScrollView

@synthesize index, photoBrowser, photoImageView;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		// Tap view for background
		tapView = [[UIViewTap alloc] initWithFrame:frame];
		tapView.tapDelegate = self;
		tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:tapView];
		
		// Image view
		photoImageView = [[UIImageViewTap alloc] initWithFrame:CGRectZero];
		photoImageView.tapDelegate = self;
		photoImageView.contentMode = UIViewContentModeScaleAspectFit;
		photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:photoImageView];
		
		// Spinner
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.hidesWhenStopped = YES;
		spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:spinner];
		
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		
	}
	
	return self;
}


- (void)dealloc {
	[tapView release];
	[photoImageView release];
	[spinner release];
	[super dealloc];
}

- (void)setIndex:(int)value {
	if (value == NSNotFound) {
		
		// Release image
		photoImageView.image = nil;
		
	} else {
		
		// Reset for new page at index
		index = value;
		
		// Display image
		[self displayImage];
		
	}
}

#pragma mark -
#pragma mark Image

// Get and display image
- (void)displayImage {
	if (index != NSNotFound && photoImageView.image == nil) {
		
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
		
		// Get image
		UIImage *img = [self.photoBrowser imageAtIndex:index];
		if (img) {
			
			// Hide spinner
			[spinner stopAnimating];
			
			// Set image
			photoImageView.image = img;
			photoImageView.hidden = NO;
			
			// Setup photo frame
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
			photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;

			// Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
			
		} else {
			
			// Hide image view
			photoImageView.hidden = YES;
			[spinner startAnimating];
			
		}
		[self setNeedsLayout];
	}
}

// Image failed so just show black!
- (void)displayImageFailure {
	[spinner stopAnimating];
}

#pragma mark -
#pragma mark Setup Content

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
	
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}
    
	// Calculate Max
	CGFloat maxScale = 4.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	// Reset position
	photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height);
	[self setNeedsLayout];

}

#pragma mark -
#pragma mark UIView Layout

- (void)layoutSubviews {
	
	// Update tap view frame
	tapView.frame = self.bounds;
	
	// Spinner
	if (!spinner.hidden) spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
													  floorf(self.bounds.size.height/2.0));
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(photoImageView.frame, frameToCenter))
		photoImageView.frame = frameToCenter;
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[photoBrowser hideControlsAfterDelay];
}

#pragma mark -
#pragma mark Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
	[photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	
	// Cancel any single tap handling
	[NSObject cancelPreviousPerformRequestsWithTarget:photoBrowser];
	
	// Zoom
	if (self.zoomScale == self.maximumZoomScale) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
	
	// Delay controls
	[photoBrowser hideControlsAfterDelay];
}

- (void)handleTripleTap:(CGPoint)touchPoint 
{

	if ( photoImageView.backgroundColor == [UIColor blackColor] )
	{
		photoImageView.backgroundColor = [UIColor whiteColor];
	}
	else 
	{
		photoImageView.backgroundColor = [UIColor blackColor];
	}

}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:imageView]]; }
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:imageView]]; }
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch { [self handleTripleTap:[touch locationInView:imageView]]; }

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:view]]; }
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:view]]; }
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch { [self handleTripleTap:[touch locationInView:view]]; }


@end
