//
//  RACategoryView.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAGalleryView.h"
#import "RAGallery.h"
#import <QuartzCore/QuartzCore.h>

@implementation RAGalleryView

@synthesize gallery = _gallery;

- (BOOL)canBecomeFirstResponder
{
	return YES;
}


- (id)initWithFrame:(CGRect)frame forGallery:(RAGallery *)gallery
{
	_gallery = [gallery retain];
	
	
	[self setUserInteractionEnabled:YES];
	
	if ((self = [super initWithFrame:frame])) {
		
		// Image 
		NSData *receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[gallery imageURL]]];
		UIImage * image = [[[UIImage alloc] initWithData:receivedData] autorelease];
		
		UIImageView * imageView = [[[UIImageView alloc] init] autorelease];
		[imageView setFrame:[self scaledImageRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height) forContentRect:[self frame]]];
		imageView.contentMode = UIViewContentModeScaleAspectFill; 
		[[imageView layer] setOpacity:0.0f];
		[[imageView layer] setBorderColor:[UIColor darkGrayColor].CGColor];
		[[imageView layer] setBorderWidth:1.0f];
		
		[imageView setImage:image];
		
		
		// Text
		UILabel * label = [[[UILabel alloc] init] autorelease];
		[[label layer] setOpacity:0.0f];
		[label setFrame:frame];
		
	
		[label setFont:[UIFont boldSystemFontOfSize:16]];
		[label setText:[gallery categoryName]];
		[label setTextColor:[UIColor whiteColor]];
		[label setBackgroundColor:[UIColor clearColor]];
		
		label.layer.borderColor = [UIColor clearColor].CGColor;
		
		CGSize maximumLabelSize = CGSizeMake(500,9999); // go nuts with the maximum size
		CGSize expectedLabelSize = [[gallery categoryName] sizeWithFont:label.font 
													   constrainedToSize:maximumLabelSize 
														   lineBreakMode:label.lineBreakMode]; 
		CGRect newFrame = label.frame;
		newFrame.size.height = expectedLabelSize.height;
		newFrame.origin.x = [imageView frame].size.width + 30;
		newFrame.origin.y = [imageView frame].size.height/2 + expectedLabelSize.height;
		label.frame = newFrame;
		
		// Add views
		[self addSubview:imageView];
		[self addSubview:label];
		[[imageView layer] setOpacity:1.0f];
		[[label layer] setOpacity:1.0f];
    }
    
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)scaledImageRect:(CGRect)iRect forContentRect:(CGRect)rect
{
	CGRect outRect;
	
	CGFloat newHeight = rect.size.height*0.85;
	CGFloat multiplier = newHeight/iRect.size.height;
	
	CGFloat yOrigin = (rect.size.height = newHeight)/2;
	CGFloat xOrigin = 10.0f;
	
	outRect = CGRectMake(xOrigin, yOrigin, iRect.size.width*multiplier, iRect.size.height*multiplier);
	
	return outRect;
}


- (void)dealloc {
    
	[_gallery release], _gallery = nil;
    [super dealloc];

}

- (void)chooseSelf
{
	NSLog(@"Chosen");
}

@end
