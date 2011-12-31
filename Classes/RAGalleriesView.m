//
//  CategoriesView.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAGalleriesView.h"
#import "RAGallery.h"
#import "RAGalleryView.h"
#import <QuartzCore/QuartzCore.h>
#import "RAPhotoBrowser.h"
#import "RAMainViewController.h"
//#import "RAImageView.h"

@implementation RAGalleriesView

@synthesize categories = _categories,
			views = _views;

- (id)initWithFrame:(CGRect)frame categories:(NSArray *)categories
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		_categories = [categories retain];
		_views = [[NSMutableArray array] retain];
		[self setBackgroundColor:[UIColor clearColor]];

    }
    return self;
}

- (void)addCategories
{
	
	CGFloat yOrigin = 0.0f;
	CGSize contentSize = CGSizeMake(0.0, 0.0);
	contentSize.width = [self frame].size.width;
	
	int i = 0;
	
	for ( RAGallery * category in [self categories] )
	{
		CGRect viewFrame = [self frame];
		viewFrame.size.height = ([self frame].size.height)/6;
		viewFrame.origin.y = yOrigin;
		viewFrame.origin.x = 0.0f;

		RAGalleryView * view = [[RAGalleryView alloc] initWithFrame:viewFrame forGallery:category];
		[_views addObject:view];
		[self setNeedsDisplay];
	
		[self addSubview:view];
			
		yOrigin = yOrigin + viewFrame.size.height;
		contentSize.height += viewFrame.size.height+5;
		i++;
	}
	[self setContentSize:contentSize];
}


- (void)layoutScrollImagesInScrollView:(UIScrollView *)scrollView forImageCount:(NSUInteger)count
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView subviews];
	
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (self.frame.size.width);
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake((count * self.frame.size.width), [scrollView bounds].size.height)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( [[touches anyObject] tapCount] == 1 )
	{
		//[self openGallery:[self gallery]];
		CGPoint locationPoint = [[touches anyObject] locationInView:self];
		id view = [self hitTest:locationPoint withEvent:event];
		
		if ( [view isKindOfClass:[RAGalleryView class]] )
		{
			RAGallery * gallery = [(RAGalleryView *)view gallery];			
			RAMainViewController * galleryViewController = [RAMainViewController sharedViewController];			
			[galleryViewController enterGallery:gallery];			
		}
	}
}			

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	RAGalleryViewController * galleryViewController = [RAMainViewController sharedViewController];
	[[galleryViewController view] setFrame:[[galleryViewController pagingScrollView] frame]];
	[galleryViewController setView:[galleryViewController pagingScrollView]];
}


- (void)dealloc {
	[_categories release], _categories = nil;
	[_views release], _views = nil;
    [super dealloc];
}


@end
