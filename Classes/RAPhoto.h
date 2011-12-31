//
//  RAPhoto.h
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

// Class
@class RAPhoto;

// Delegate
@protocol RAPhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(RAPhoto *)photo;
- (void)photoDidFailToLoad:(RAPhoto *)photo;
@end

// RAPhoto
@interface RAPhoto : NSObject {
	
	// Image
	NSString * photoPath;
	NSURL * photoURL;
	UIImage * photoImage;
	NSString * title;
	
	// Flags
	BOOL workingInBackground;
	
}

@property (retain) NSString * title;
@property (retain) NSURL * photoURL;

// Class
+ (RAPhoto *)photoWithImage:(UIImage *)image;
+ (RAPhoto *)photoWithFilePath:(NSString *)path;
+ (RAPhoto *)photoWithURL:(NSURL *)url;
+ (RAPhoto *)photoWithURL:(NSURL *)url title:(NSString *)title;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url title:(NSString *)aTitle;

	
// Public methods
- (BOOL)isImageAvailable;
- (UIImage *)image;
- (UIImage *)obtainImage;
- (void)obtainImageInBackgroundAndNotify:(id <RAPhotoDelegate>)notifyDelegate;
- (void)releasePhoto;

@end
