////
//Header

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface RAAnimatedTextView : UIView {
	
	CATextLayer *_textLabel;
	CAScrollLayer * _scrollLayer;
	NSString * _stringValue;
	UIFont * _font;
	CGFloat _textWidth;
	CGFloat _textHeight;
	BOOL _needsAnimating;
	BOOL _animating;
	BOOL _songChanged;
	NSTimer * _timer;
	
	CGGradientRef _topGradient;
	CGGradientRef _bottomGradient;
}

@property (nonatomic, retain, readwrite) CATextLayer * textLabel;
@property (nonatomic, retain, readwrite) CAScrollLayer * scrollLayer;
@property (nonatomic, retain, readwrite) NSString * stringValue;
@property (nonatomic, retain, readwrite) UIFont * font;
@property (nonatomic, readwrite) CGFloat textWidth;
@property (nonatomic, readwrite) CGFloat textHeight;
@property (nonatomic, readwrite) BOOL needsAnimating;
@property (nonatomic, readwrite) BOOL animating;
@property (nonatomic, readwrite) BOOL songChanged;


#pragma mark Layer management
- (CATextLayer *)textLayer;
- (void)setUpNewAnimationsLayers;
- (void)getAnimationProperties;

#pragma mark Animation
- (void)beginAnimation; 

@end

