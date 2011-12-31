//
//  RAPhoto.m
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAPhoto.h"
#import "UIImage+Decompress.h"

// Private
@interface RAPhoto ()

// Properties
@property (retain) UIImage *photoImage;
@property () BOOL workingInBackground;



// Private Methods
- (void)doBackgroundWork:(id <RAPhotoDelegate>)delegate;

@end


// RAPhoto
@implementation RAPhoto

// Properties
@synthesize photoImage, workingInBackground, title, photoURL;

#pragma mark Class Methods

+ (RAPhoto *)photoWithImage:(UIImage *)image {
	return [[[RAPhoto alloc] initWithImage:image] autorelease];
}

+ (RAPhoto *)photoWithFilePath:(NSString *)path {
	return [[[RAPhoto alloc] initWithFilePath:path] autorelease];
}

+ (RAPhoto *)photoWithURL:(NSURL *)url {
	return [[[RAPhoto alloc] initWithURL:url] autorelease];
}

+ (RAPhoto *)photoWithURL:(NSURL *)url title:(NSString *)title {
	return [[[RAPhoto alloc] initWithURL:url title:title] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.photoImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		photoURL = [url copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url title:(NSString *)aTitle
{
	if ((self = [super init])) {
		photoURL = [url copy];
		title = [aTitle retain];
	}
	return self;
}

- (void)dealloc {
	[photoPath release];
	[photoURL release];
	[photoImage release];
	[super dealloc];
}

#pragma mark Photo

// Return whether the image available
// It is available if the UIImage has been loaded and
// loading from file or URL is not required
- (BOOL)isImageAvailable {
	return (self.photoImage != nil);
}

// Return image
- (UIImage *)image {
	return self.photoImage;
}

// Get and return the image from existing image, file path or url
- (UIImage *)obtainImage {
	if (!self.photoImage) {
		
		// Load
		UIImage *img = nil;
		if (photoPath) { 
			
			// Read image from file
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfFile:photoPath options:NSDataReadingUncached error:&error];
			if (!error) {
				img = [[UIImage alloc] initWithData:data];
			} else {
				NSLog(@"Photo from file error: %@", error);
			}
			
		} else if (photoURL) { 
			
			// Read image from URL and return
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photoURL];
			NSError *error = nil;
			NSURLResponse *response = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			[request release];
			if (data) {
				img = [[UIImage alloc] initWithData:data];
			} else {
				NSLog(@"Photo from URL error: %@", error);
			}
			
		}

		// Force the loading and caching of raw image data for speed
		[img decompress];		
		
		// Store
		self.photoImage = img;
		[img release];
		
	}
	return [[self.photoImage retain] autorelease];
}

// Release if we can get it again from path or url
- (void)releasePhoto {
	if (self.photoImage && (photoPath || photoURL)) {
		self.photoImage = nil;
	}
}

// Obtain image in background and notify the browser when it has loaded
- (void)obtainImageInBackgroundAndNotify:(id <RAPhotoDelegate>)delegate {
	if (self.workingInBackground == YES) return; // Already fetching
	self.workingInBackground = YES;
	[self performSelectorInBackground:@selector(doBackgroundWork:) withObject:delegate];
}

// Run on background thread
// Download image and notify delegate
- (void)doBackgroundWork:(id <RAPhotoDelegate>)delegate {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Load image
	UIImage *img = [self obtainImage];
	
	// Notify delegate of success or fail
	if (img) {
		[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFinishLoading:) withObject:self waitUntilDone:NO];
	} else {
		[(NSObject *)delegate performSelectorOnMainThread:@selector(photoDidFailToLoad:) withObject:self waitUntilDone:NO];		
	}

	// Finish
	self.workingInBackground = NO;
	
	[pool release];
}

@end
