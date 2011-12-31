//
//  UIImageViewTap.h
//  Robotangel
//
//  Created by Rob Daly on 3/26/2011.
//  Copyright 2011 Rob Daly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIImageViewTapDelegate;

@interface UIImageViewTap : UIImageView {
	id <UIImageViewTapDelegate> tapDelegate;
}
@property (nonatomic, assign) id <UIImageViewTapDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol UIImageViewTapDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end