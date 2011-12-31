//
//  RAFacebookController.m
//  Robotangel
//
//  Created by rdaly on 4/7/11.
//  Copyright 2011 Microsoft Corporation. All rights reserved.
//

#import "RAFacebookController.h"
#import "Facebook.h"
#import "RAConstants.h"

@implementation RAFacebookController

+ (Facebook *)facebookForDelegate:(id)delegate
{
	Facebook * facebook = [[Facebook alloc] initWithAppId:kFacebookAppID];
	
	
	return [facebook autorelease];
}

+ (void)uploadPhoto:(UIImage *)photo toFacebook:(Facebook *)facebook forDelegate:(id <FBRequestDelegate>)delegate
{
		
	if ( photo && facebook )
	{
	}
}

@end
