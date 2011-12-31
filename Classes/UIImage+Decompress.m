//
//  UIImage+Decompress.m
//  Robotangel
//
//  Created by Rob Daly on 3/26/2011.
//  Copyright 2011 Rob Daly. All rights reserved.
//

#import "UIImage+Decompress.h"

@implementation UIImage (Decompress)

// Force the UIImage to decompress the image and cache
// http://stackoverflow.com/questions/1815476/cgimage-uiimage-lazily-loading-on-ui-thread-causes-stutter

- (void)decompress {
    const CGImageRef cgImage = [self CGImage];  
	
    const int width = CGImageGetWidth(cgImage);
    const int height = CGImageGetHeight(cgImage);
	
    const CGColorSpaceRef colorspace = CGImageGetColorSpace(cgImage);
    const CGContextRef context = CGBitmapContextCreate(
													   NULL, /* Where to store the data. NULL = don’t care */
													   width, height, /* width & height */
													   8, width * 4, /* bits per component, bytes per row */
													   colorspace, kCGImageAlphaNoneSkipFirst);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
}

@end
