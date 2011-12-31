//
//  UIViewTap.h
//  Robotangel
//
//  Created by Rob Daly on 3/26/2011.
//  Copyright 2011 Rob Daly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIViewTapDelegate;

@interface UIViewTap : UIView {
	id <UIViewTapDelegate> tapDelegate;
}
@property (nonatomic, assign) id <UIViewTapDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol UIViewTapDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
@end