//
//  RAMainViewController.m
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAMainViewController.h"
#import "RAXMLStream.h"
#import "RAGallery.h"
#import "RAGalleriesView.h"
#import "RAPhotoBrowser.h"
#import "RAPhotoBrowser.h"
#import "RAConstants.h"
#import "RAPhotoBrowserAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


static NSString * xpathProjectQuery = @"//li[contains(@class, 'project ')]";
static RAMainViewController * sharedViewController = nil;


@implementation RAMainViewController

@synthesize scrollView = _scrollView,
			pagingScrollView = _pagingScrollView,
			loadingLabel = _loadingLabel,
			progressImage = _progressImage,
			elements = _elements,
			images = _images;


#pragma mark -
#pragma mark Singleton Methods

+ (id)sharedViewController 
{
    @synchronized(self) {
        if(sharedViewController == nil)
            sharedViewController = [[super allocWithZone:NULL] init];
    }
    return sharedViewController;
}

+ (id)allocWithZone:(NSZone *)zone 
{
    return [[self sharedViewController] retain];

}
- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount 
{
    return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release 
{
    // never release
}

- (id)autorelease 
{
    return self;
}

- (id)init 
{
    self = [super init];
    
    if ( self ) {
		_images = [[NSArray array] retain];
		self.title = @"Galleries";
		_dataLoaded = NO;
    }
    return self;
}

- (void)dealloc {
	[_pagingScrollView release];
	[_images release];
	[super dealloc];
}

#pragma mark -
#pragma mark View Management

/*
- (void)viewDidUnload
{
    [super viewDidUnload];
    [_pagingScrollView release];
    _pagingScrollView = nil;
    [_recycledPages release];
    _recycledPages = nil;
    [_visiblePages release];
    _visiblePages = nil;
}
*/

- (void)enterGallery:(RAGallery *)gallery
{
	RAPhotoBrowser *browser = [[RAPhotoBrowser alloc] initWithPhotos:[gallery images]];
	//[browser setInitialPageIndex:0]; // Can be changed if desired
	[self.navigationController pushViewController:browser animated:YES];
	[self.navigationController setNavigationBarHidden:NO];
	[browser release];	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if ( !_dataLoaded )
	{
		// load all the frames of our animation
		_progressImage = [[[UIImageView alloc] init] autorelease];
		
		[[self view] setBackgroundColor:[UIColor blackColor]];
		
		CGRect mainframe = self.view.frame;
		CGFloat imageWidth = [UIImage imageNamed:@"head_tooth_1.png"].size.width/2;
		CGFloat imageHeight = [UIImage imageNamed:@"head_tooth_1.png"].size.height/2;
		CGFloat xOrigin = mainframe.size.width/2 - imageWidth/2;
		CGFloat yOrigin = mainframe.size.height/2 - imageHeight/2;
		
		[_progressImage setFrame:CGRectMake(xOrigin, yOrigin, imageWidth, imageHeight)];
		_progressImage.animationImages = [NSArray arrayWithObjects:  
										  [UIImage imageNamed:@"head_tooth_1.png"],
										  [UIImage imageNamed:@"head_tooth_2.png"],
										  [UIImage imageNamed:@"head_tooth_3.png"],
										  [UIImage imageNamed:@"head_tooth_4.png"],
										  [UIImage imageNamed:@"head_tooth_6.png"],
										  [UIImage imageNamed:@"head_tooth_7.png"],
										  [UIImage imageNamed:@"head_tooth_8.png"],
										  [UIImage imageNamed:@"head_tooth_9.png"],
										  [UIImage imageNamed:@"head_tooth_10.png"],
										  [UIImage imageNamed:@"head_tooth_10.png"],
										  [UIImage imageNamed:@"head_tooth_10.png"],
										  [UIImage imageNamed:@"head_tooth_10.png"],
										  nil];
		
		[self.view addSubview:_progressImage];
		
		
		_progressImage.animationDuration = 0.8;
		// repeat the annimation forever
		_progressImage.animationRepeatCount = 0;
		// start animating
		[_progressImage startAnimating];
		
		
		
		[self setElements:[NSArray array]];
		
		RAPhotoBrowserAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
		
		if ( ![appDelegate siteIsReachable] )
		{
			[self exitProgress];
			[[self view] addSubview:[appDelegate networkUnavailableAlert]];
			return;
		}
		
		NSOperationQueue *operation = [[[NSOperationQueue alloc] init] autorelease];
		
		[operation addOperationWithBlock:^{
			NSURL * baseURL = [NSURL URLWithString:kRobotangelCarbonMadeURL];
			NSURLRequest * baseRequest = [NSURLRequest requestWithURL:baseURL];
			
			if ( [NSURLConnection canHandleRequest:baseRequest] )
			{
				[self setElements:[self projectElementsForURL:baseURL]];
				
				if ( [[self elements] count] > 0 )
				{
					[self setScrollView:[[[RAGalleriesView alloc] initWithFrame:[[self view] frame] categories:[self elements]] autorelease]];
					//[[self view] addSubview:[self scrollView]];
					[self performSelectorOnMainThread:@selector(addViews) withObject:nil waitUntilDone:YES];
				}
				else 
				{
					// error
					
				}
				
			}
			else 
			{
				// error
			}
		}];
		_dataLoaded = YES;
	}
	
	
}

- (void)viewDidLoad 
{
   	
		[super viewDidLoad];	
}


- (void)addViews
{
	
	for ( RAGallery * gallery in [self elements] )
	{
		[gallery loadGalleryDataForViewFrame:self.view.frame];
	}
}

- (void)galleryLoaded
{
	_numberOfGalleriesLoaded++;
	
	if ( _numberOfGalleriesLoaded == [[self elements] count] )
	{

		_numberOfGalleriesLoaded = 0;

		[self exitProgress];
		
		[UIView animateWithDuration:0.9
							  delay:0.0
							options: UIViewAnimationOptionTransitionCurlUp
						 animations:^{
							 [[self view] performSelectorOnMainThread:@selector(addSubview:) withObject:[self scrollView] waitUntilDone:YES];
							 [[self scrollView] addCategories];
						 } 
						 completion:nil];
		
	}
}

- (void)exitProgress
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(loadingFadedOut)];
	[_progressImage setAlpha:0.0f];
	[UIView commitAnimations];	
}



#pragma mark -
#pragma mark View Switching
- (void)switchToView:(RAViewType)view withObject:(id)object
{


}

#pragma mark Actions
- (void)loadGalleries
{
	[self switchToView:kCategoriesView withObject:nil];
}

#pragma mark -
#pragma mark Animation notification


- (NSArray *)projectElementsForURL:(NSURL *)url
{
	NSMutableArray * projects = [NSMutableArray array];
	
	NSData *data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
	RAXMLStream * xpathParser = [[[RAXMLStream alloc] initWithHTMLData:data] autorelease];
	NSArray * elements  = [xpathParser search:xpathProjectQuery];

		
	for ( RAXMLElement * element in elements )
	{
		NSDictionary * topNode = [element node];
		RAGallery * project = [self createCategoryFromXMLElement:topNode];
		
		if ( project )
		{
			[projects addObject:project];
		}
	}
	
	return projects;
}


- (RAGallery *)createCategoryFromXMLElement:(NSDictionary *)element
{
	RAGallery * project = nil;
	
	NSString * categoryName = nil;
	NSString * imageURL = nil;
	NSString * href = nil;
	
	if ( [[element objectForKey:TFHppleNodeNameKey] isEqualToString:@"li"] )
	{
		// Get the first level dictionary
		
		NSArray * itemArray = [element objectForKey:TFHppleNoteChildArrayKey];
		
		if ( [itemArray count] > 0 )
		{
			NSDictionary * dict = [[element objectForKey:TFHppleNoteChildArrayKey] objectAtIndex:0];
			NSArray * nodeArray = [dict objectForKey:TFHppleNodeAttributeArrayKey];
			
			if ( [nodeArray count] > 0 )
			{
				for ( NSDictionary * attributeDict in nodeArray )
				{
					if ( [[attributeDict objectForKey:@"attributeName"] isEqualToString:@"href"] )
					{
						//[project setHref:[attributeDict objectForKey:@"nodeContent"]];
						href = [attributeDict objectForKey:@"nodeContent"];
					}
				}
				
				NSArray * childArray = [dict objectForKey:TFHppleNoteChildArrayKey];
				if ( [childArray count] > 0 )
				{
					for ( NSDictionary * attributeDict in childArray )
					{
						NSArray * attributesArray = [attributeDict objectForKey:TFHppleNodeAttributeArrayKey];
						if ( [attributesArray count] > 0 )
						{
							for ( NSDictionary * attrDict in attributesArray )
							{
								if ( [[attrDict objectForKey:@"attributeName"] isEqualToString:@"src"] )
								{
									//[project setImageURL:[attrDict objectForKey:@"nodeContent"]];
									imageURL = [attrDict objectForKey:@"nodeContent"];
								}
								else if ([[attrDict objectForKey:@"attributeName"] isEqualToString:@"alt"] ) 
								{
									//[project setCategoryName:[attrDict objectForKey:@"nodeContent"]];
									categoryName = [attrDict objectForKey:@"nodeContent"];
								}

							}
						}
					}
				}
			}
		}
	}
	project = [[[RAGallery alloc] initWithCategoryName:categoryName withHref:href imageURL:imageURL] autorelease];
	
	return project;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
	
	// Remember page index before rotation
//	rotating = YES;
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
	
	for ( UIView * subview in self.view.subviews )
	{
		[subview setFrame:self.view.frame];
	}

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	
//	rotating = NO;
}


@end
