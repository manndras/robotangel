//
//  RAPhotoBrowserAppDelegate.h
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAMainViewController;

@interface RAPhotoBrowserAppDelegate : NSObject <UIApplicationDelegate> {
   
    UIWindow * _window;

	UINavigationController * _nc;
	RAMainViewController * _viewController;
	
	UIView * _networkUnavailableAlert;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RAMainViewController *viewController;
@property (nonatomic, retain) IBOutlet UIView * networkUnavailableAlert;


- (BOOL)siteIsReachable;

- (void)setupViews;


@end

