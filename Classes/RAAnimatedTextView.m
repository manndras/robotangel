//
//  AnimatedTextLayer.m
//  NowPlaying
//
//  Created by rdaly on 1/12/11.
//  Copyright 2011 Microsoft Corporation. All rights reserved.
//

#import "RAAnimatedTextView.h"
#import <CoreText/CoreText.h>

//#import <ApplicationServices/ApplicationServices.h>


@implementation RAAnimatedTextView


@synthesize textLabel = _textLabel,
			scrollLayer = _scrollLayer,
			stringValue = _stringValue,
			font = _font,
			textWidth = _textWidth,
			textHeight = _textHeight,
			needsAnimating = _needsAnimating,
			animating = _animating,
			songChanged = _songChanged;

#define FONT_SIZE 14.0f
#define DELAY_DURATION 2.0f
#define ANIMATION_DURATION 6.0f // Time for both the animtion of text and the delay before next animating text
#define RIGHT_PADDING 30.0f // Padding to add to the end of a song string used to separate it and the duplicate of it that will scroll in
#define LAYER_PADDING 35.0f // Layer drawing to finish before edges of view

#pragma mark -
#pragma mark Tearup/Teardown

- (id)initWithFrame:(CGRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self != nil) 
	{
		
		// Gradients we'll use when drawing the background
		/*
		_topGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:244.0f/255.f green:244.0f/255.f blue:228.0f/255.f alpha:1.0], 0.0,
												[NSColor colorWithCalibratedRed:244.0f/255.f green:244.0f/255.f blue:228.0f/255.f alpha:1.0], 0.5,
												[NSColor colorWithCalibratedRed:229.0f/255.f green:234.0f/255.f blue:211.0f/255.f alpha:1.0], 1.0,
												nil];
		
		_bottomGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:244.0f/255.f green:244.0f/255.f blue:228.0f/255.f alpha:1.0], 0.0,
							[NSColor colorWithCalibratedRed:229.0f/255.f green:234.0f/255.f blue:211.0f/255.f alpha:1.0], 1.0,
							nil];		
			*/
		// Notification for changes to the string
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(photoChanged:) 
													 name:@"photoChanged" 
												object:nil];
		
			
	}
	return self;
}

- (void)didMoveToSuperview
{
	[self setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
	[self setUpNewAnimationsLayers];
	[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	_timer = [NSTimer scheduledTimerWithTimeInterval:DELAY_DURATION target:self selector:@selector(beginAnimation) userInfo:nil repeats:YES];	
	self.layer.needsDisplayOnBoundsChange = YES;
}

- (void)dealloc {
    [_textLabel release];
	[_timer release];
	[_font release];
	[_stringValue release];
	[_scrollLayer release];
	[_textLabel release];
//	[_topGradient release];
//	[_bottomGradient release];
    [super dealloc];
	
//	[[NSNotificationCenter defaultCenter] removeObserver:self 
//											  forKeyPath:kInternalSongChangeNotification];
}

#pragma mark -
#pragma mark Drawing
- (void)drawRect:(CGRect)dirtyRect
{
	[super drawRect:dirtyRect];
} 



#pragma mark -
#pragma mark Layer management

- (CATextLayer *)textLayer
{
	self.layer.backgroundColor = [[UIColor clearColor] CGColor];
	
	CATextLayer * textLayer = [CATextLayer layer];
	
    CGColorRef blackColor = [[UIColor blackColor] CGColor];
	CGColorRef whiteColor = [[UIColor colorWithWhite:1.0 alpha:0.8] CGColor];
	
	if ( [self needsAnimating] )
	{
		// Begin at left aligned so the text can move from right to left
		[textLayer setAlignmentMode:kCAAlignmentLeft];
	}
	else 
	{
		// Text won't move, center it
		[textLayer setAlignmentMode:kCAAlignmentCenter];
	}
	
	[textLayer setForegroundColor:whiteColor];
	[textLayer setFontSize:FONT_SIZE];
	[textLayer setString:[self stringValue]];
	
	// Layer shadow
	
	[textLayer setShadowColor:blackColor];
	[textLayer setShadowOffset:CGSizeMake(0.0f, -1.0f)];
	[textLayer setShadowOpacity:1.0];
	[textLayer setShadowRadius:0.5];
	
	// Font - turns out fastest way to get a CGFontRef from an NSFont is through CTFont...
//	CTFontRef ctFont = (CTFontRef)[self font];
//	CGFontRef cgFont = CTFontCopyGraphicsFont (
//											   ctFont,
//											   NULL
//											   );
//	
	CGFontRef font = CGFontCreateWithFontName((CFStringRef)[self font].fontName);
	textLayer.font = font;
	
//	[textLayer setFont:cgFont];
	if ([textLayer respondsToSelector:@selector(setContentsScale:)])
	{
		textLayer.contentsScale = [[UIScreen mainScreen] scale];
	}
	
	return textLayer;
}


- (void)setUpNewAnimationsLayers
{	
	// Set up scroll layer
	if ( [self scrollLayer] )
	{
		[[self scrollLayer] removeFromSuperlayer];
	}
	
	[self setScrollLayer:[CAScrollLayer layer]];
	CGRect scrollLayerRect = [self bounds];
	
	scrollLayerRect.origin.x += LAYER_PADDING;
	scrollLayerRect.size.width -= LAYER_PADDING*1.85; // allow for quicklook button
		
	[[self scrollLayer] setFrame:scrollLayerRect];
	[[self scrollLayer] setEdgeAntialiasingMask:( kCALayerLeftEdge | kCALayerRightEdge )];
	[[self layer] addSublayer:[self scrollLayer]];
	
	// Initialize things animation cares about
	[self getAnimationProperties];
	
	[self setTextLabel:[self  textLayer]];
	
	// Text Layer and Geometry
	CGRect layerRect = [self bounds];	
	layerRect.size.width = [self textWidth];
	
	int yDelta = 4;//(int)([self bounds].size.height - [self textHeight])/2;
	layerRect.origin.y = ([self bounds].origin.y + yDelta);
	
	[[self textLabel] setFrame:layerRect];

/*
	// FAILED ATTEMPT TO HAVE A FEATURED EDGE ON THE TEXT VIEW
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	[gradientLayer setFrame:[[self textLabel] frame]];
	[gradientLayer setPosition:[[self textLabel] position]];
	[gradientLayer setMasksToBounds:NO];
	[gradientLayer setColors:[NSArray arrayWithObjects:
							  (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], 
							  (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor], 
							  (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor], 
							  (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], nil]];

	[gradientLayer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.0], nil]];
	[gradientLayer setStartPoint:CGPointMake(0.5, 0.5)];
	[gradientLayer setStartPoint:CGPointMake(0.0, 1.0)];
	
	[[self textLabel] setMask:gradientLayer];
	[[self textLabel] setMasksToBounds:NO];
	
	[gradientLayer release];
*/
	
    [[self scrollLayer] addSublayer:_textLabel];
	
	[[self layer] setNeedsDisplay];
}

- (void)getAnimationProperties
{

	CGSize textSize = [[self stringValue] sizeWithFont:[self font]];
	
	CGFloat width = textSize.width;
	if ( width > ([[self scrollLayer] frame].size.width))
	{
		// If we're animating the same string repeatedly, we want a gap between horizontal layers
		[self setTextWidth:width + RIGHT_PADDING];
		[self setNeedsAnimating:YES];
	}
	else 
	{
		[self setTextWidth:[[self scrollLayer] frame].size.width];
		[self setNeedsAnimating:NO];
	}
	
	[self setTextHeight:textSize.height];
}


#pragma mark -
#pragma mark Animation

- (void)beginAnimation {
	
	if ( ![self animating] && [self needsAnimating] )
	{
		// Creat and insert a new text layer to the right of the existing one
		// Push one to the left with the other and remove the initial layer once it's out of view	
		CATextLayer * dupLayer = [self textLayer];
		CGRect dupFrame = [_textLabel frame];
		dupFrame.origin.x += [_textLabel frame].size.width;
		[dupLayer setFrame:dupFrame];
		[[self scrollLayer] addSublayer:dupLayer];
		
		[CATransaction begin];	
		[CATransaction setValue:[NSNumber numberWithFloat:ANIMATION_DURATION]
						 forKey:kCATransactionAnimationDuration];	
		// Similar values to the EaseInEaseOut timing function
		// These value will make it begin at the same slow pace as that function, still slowing down at the end but not as much
		[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.42 :0.0 :0.78 :1.0]];
		[CATransaction setCompletionBlock:^{
			
			[self setAnimating:NO];

			if ( [self needsAnimating] )
			{
				// if the song changed while animating, the layer will have already been removed
				if ( ![self songChanged] ) 
				{
					[_textLabel removeFromSuperlayer];
					[self setTextLabel:dupLayer];
				}
				else 
				{
					[self setSongChanged:NO];
				}
			}
		}];
		
		[(CAScrollLayer *)[self scrollLayer] scrollToPoint:CGPointMake(([_textLabel frame].origin.x + [_textLabel frame].size.width), 0.0)];
		[self setAnimating:YES];
		[CATransaction commit];			
	}
}




#pragma mark -
#pragma mark Notifications

- (void)photoChanged:(NSNotification *)notification
{
	
	NSString * newSong = [notification object];
	if ( ![newSong isEqualToString:[self stringValue]] )
	{
	
		[self setStringValue:[notification object]];
		
		//reset the timer, this prevents timer collisions as well as just making things seem right
		[_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:ANIMATION_DURATION]];
		
		if ( [self animating] )
		{
			[self setSongChanged:YES];
			[[self scrollLayer] removeAllAnimations];
		}
		
		// Basically rebuild the whole layer environment when the song changes 
		[self setUpNewAnimationsLayers];
		
		if ( [self needsAnimating] ) 
		{
			[self beginAnimation];
		}
	}
}



@end