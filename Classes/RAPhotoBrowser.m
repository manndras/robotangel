//
//  RAPhotoBrowser.m
//  Robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import "RAPhotoBrowser.h"
#import "RAZoomingScrollView.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "RAAnimatedTextView.h"
#import "RAPhoto.h"
#import "RAFacebookController.h"
#import "RAConstants.h"
#import "Facebook.h"
#import "FBConnect.h"

#define PADDING 10

// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end


// RAPhotoBrowser
@implementation RAPhotoBrowser

- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [super init])) 
	{
		// Store photos
		photos = [photosArray retain];
		
        // Defaults
		self.wantsFullScreenLayout = YES;
		currentPageIndex = 0;
		performingLayout = NO;
		rotating = NO;
		
	}
	return self;
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	// Release any cached data, images, etc that aren't in use.
	
	// Release images
	[photos makeObjectsPerformSelector:@selector(releasePhoto)];
	[recycledPages removeAllObjects];
	NSLog(@"didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
	currentPageIndex = 0;
//	[pagingScrollView release];
//	[visiblePages release];
//	[recycledPages release];
//	[toolbar release];
//	[previousButton release];
//	[nextButton release];
}

- (void)dealloc {
	[photos release];
	[pagingScrollView release];
	[visiblePages release];
	[recycledPages release];
	[toolbar release];
	[previousButton release];
	[nextButton release];
	[_slideshowTimer release];
    [super dealloc];
}

#pragma mark -
#pragma mark View

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// View
	self.view.backgroundColor = [UIColor blackColor];
	
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	pagingScrollView.pagingEnabled = YES;
	pagingScrollView.delegate = self;
	pagingScrollView.showsHorizontalScrollIndicator = NO;
	pagingScrollView.showsVerticalScrollIndicator = NO;
	pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
	[self.view addSubview:pagingScrollView];
	
	// Setup pages
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	[self tilePages];
	
	// Navigation Bar
	self.navigationController.navigationBar.tintColor = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

	// Toolbar
	toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
	toolbar.tintColor = nil;
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	[self.view addSubview:toolbar];
	
	/*
	CGFloat height = 20.0;
	CGRect frame = CGRectMake(0.0, self.view.bounds.size.height - [self frameForToolbarAtOrientation:self.interfaceOrientation].size.height - height, self.view.bounds.size.width, height);
	 */
	textLayer = [[RAAnimatedTextView alloc] initWithFrame:[self frameForAnimatingLabelView]];
	[self.view addSubview:textLayer];
	
	
	
	// Toolbar Items
	previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
	nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
	actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    slideshowButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startSlideShow)];
	robotangelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"URLLink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToSite)];


	
	//self.navigationItem.rightBarButtonItem = actionButton;
 //   [actionButton release];
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	NSMutableArray *items = [[NSMutableArray alloc] init];
	//[items addObject:space];
	[items addObject:actionButton];
	[items addObject:space];
	if (photos.count > 1) 
	{
		[items addObject:previousButton];
	}
	
	[items addObject:space];
	[items addObject:slideshowButton];
	[items addObject:space];
	if (photos.count > 1) 
	{
		[items addObject:nextButton];
	}
	
	[items addObject:space];
	[items addObject:robotangelButton];

	[toolbar setItems:items];
	[items release];
	[space release];

	// Super
    [super viewDidLoad];
	
	
}

- (void)goToSite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.robotangel.com"]];
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsLookup?ean=0737463850629"]];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// Super
	[self toggleControls];

	[super viewWillAppear:animated];
	
	// Layout
	[self performLayout];
	
	// Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	
	// Navigation
	[self updateNavigation];
	[self hideControlsAfterDelay];
	[self didStartViewingPageAtIndex:currentPageIndex]; // initial
	
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[self hideControls];
	if ( _slideshowPlaying )
	{
		[self stopSlideShow];
	}
	// Super
	[super viewWillDisappear:animated];
	
	// Cancel any hiding timers
	[self cancelControlHiding];
	
}


#pragma mark -
#pragma mark Layout

// Layout subviews
- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Toolbar
	toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	textLayer.frame = [self frameForAnimatingLabelView];
	[textLayer setUpNewAnimationsLayers];
	
	// Remember index
	int indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
		
	// Frame needs changing
	pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (RAZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
	performingLayout = NO;

}

#pragma mark -
#pragma mark Photos

// Get image if it has been loaded, otherwise nil
- (UIImage *)imageAtIndex:(int)index {
	if (photos && (index >= 0 && index < photos.count)) {

		// Get image or obtain in background
		RAPhoto *photo = [photos objectAtIndex:index];
		if ([photo isImageAvailable]) {
			return [photo image];
		} else {
			[photo obtainImageInBackgroundAndNotify:self];
		}
		
	}
	return nil;
}

- (RAPhoto *)currentPhoto
{
	return [photos objectAtIndex:currentPageIndex];
}


- (RAPhoto *)currentPhotoWithCopyright
{
	NSString * copyright = @"© Angel Ceballos Photography";
	
	// TODO: Make an RAPhoto with a copyright symbol drawn on top of it.
	UILabel * label = [[[UILabel alloc] init] autorelease];
	label.text = copyright;
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0,-1);
	
	//UIImage * textImage = [self settingImageFromView:label];
	
	
	//UIImage * photoImage = [[self currentPhoto] photoImage];
	
	
	
	return [photos objectAtIndex:currentPageIndex];
}


- (UIImage *)settingImageFromView:(UIView *)view 
{
   
	CGRect rect = [view bounds];  

    UIGraphicsBeginImageContext(rect.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    [view.layer renderInContext:context];  
    UIImage *imageCaptureRect;
	
    imageCaptureRect = UIGraphicsGetImageFromCurrentImageContext();  
    UIImage * imageCapture = imageCaptureRect;

	
    UIGraphicsEndImageContext();   
	
	return imageCapture;
}


#pragma mark -
#pragma mark RAPhotoDelegate

- (void)photoDidFinishLoading:(RAPhoto *)photo {
	int index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page to display image again
			RAZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImage];
			
		}
	}
}

- (void)photoDidFailToLoad:(RAPhoto *)photo {
	int index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page it failed
			RAZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImageFailure];
			
		}
	}
}

#pragma mark -
#pragma mark Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = pagingScrollView.bounds;
	int firstNeededPageIndex = floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex  = MIN(lastNeededPageIndex, photos.count-1);
	
	// Recycle no longer needed pages
	for (RAZoomingScrollView *page in visiblePages) {
		if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
			[recycledPages addObject:page];
			/*NSLog(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add missing pages
	for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			RAZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[[RAZoomingScrollView alloc] init] autorelease];
				page.photoBrowser = self;
			}
			[self configurePage:page forIndex:index];
			[visiblePages addObject:page];
			[pagingScrollView addSubview:page];
			/*NSLog(@"Added page at index %i", page.index);*/
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(int)index {
	for (RAZoomingScrollView *page in visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (RAZoomingScrollView *)pageDisplayedAtIndex:(int)index {
	RAZoomingScrollView *thePage = nil;
	for (RAZoomingScrollView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(RAZoomingScrollView *)page forIndex:(int)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
}
										  
- (RAZoomingScrollView *)dequeueRecycledPage {
	RAZoomingScrollView *page = [recycledPages anyObject];
	if (page) {
		[[page retain] autorelease];
		[recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(int)index {
	
	// Release images further away than +1/-1
	int i;
	for (i = 0;       i < index-1;      i++) { [(RAPhoto *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
	for (i = index+2; i < photos.count; i++) { [(RAPhoto *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
	
	// Preload next & previous images
	i = index - 1; if (i >= 0 && i < photos.count) { [(RAPhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
	i = index + 1; if (i >= 0 && i < photos.count) { [(RAPhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
	
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGRect)frameForAnimatingLabelView {
	CGFloat height = 20.0;
	CGRect frame = CGRectMake(0.0, self.view.bounds.size.height - [self frameForToolbarAtOrientation:self.interfaceOrientation].size.height - height, self.view.bounds.size.width, height);
	return frame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * photos.count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(int)index {
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	
	if (performingLayout || rotating) 
	{
		return;
	}
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = pagingScrollView.bounds;
	int index = floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds));
	if (index < 0) index = 0;
	if (index > photos.count-1)
	{
		index = photos.count-1;
	}
	int previousCurrentPage = currentPageIndex;
	currentPageIndex = index;
	if (currentPageIndex != previousCurrentPage) [self didStartViewingPageAtIndex:index];
		
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	if ( _slideshowPlaying )
	{
		[self stopSlideShow];
	}
	
	
	[self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
	[self updateNavigation];
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {

	// Title
	if (photos.count > 1) 
	{
		self.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex + 1, photos.count];
	} 
	else 
	{
		self.title = nil;
	}
	
	// Buttons
	previousButton.enabled = (currentPageIndex > 0);
	nextButton.enabled = (currentPageIndex < photos.count-1);
	
	NSString * title = [[photos objectAtIndex:currentPageIndex] title];
	
	NSNotification * titleChange = [NSNotification notificationWithName:@"photoChanged" object:title];
	[[NSNotificationCenter defaultCenter] postNotification:titleChange];
	textLayer.stringValue = title;
	
}

- (void)jumpToPageAtIndex:(int)index {
	
	// Change page
	if (index >= 0 && index < photos.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage 
{ 
	[self jumpToPageAtIndex:currentPageIndex-1]; 
}

- (void)gotoNextPage 
{ 
	[self jumpToPageAtIndex:currentPageIndex+1]; 
}

#pragma mark -
#pragma mark Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden {
	
	if ( _slideshowPlaying && !hidden )
	{
		[self stopSlideShow];
	}

	
	// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;
	
	// Bars
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
	[toolbar setAlpha:hidden ? 0 : 1];
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[textLayer setAlpha:hidden ? 0 : 1];
	[toolbar setAlpha:hidden ? 0 : 1];
	[UIView commitAnimations];
	
	if ( hidden && _slideshowPlaying )
	{
		[self stopSlideShow];
	}
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
	
}


- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		[controlVisibilityTimer release];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
}

- (void)hideControls 
{ 
	[self setControlsHidden:YES]; 
}

- (void)toggleControls 
{ 
	[self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; 
}


- (void)startSlideShow
{
	if ( !_slideshowPlaying )
	{
		[self setControlsHidden:YES];
		_slideshowTimer = [[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(advanceSlide) userInfo:nil repeats:YES] retain];
		_slideshowPlaying = YES;
	}
}

- (void)stopSlideShow
{
	[_slideshowTimer invalidate];
	[_slideshowTimer release];
	_slideshowTimer = nil;
	_slideshowPlaying = NO;
}

- (void)advanceSlide
{
	if ( currentPageIndex != (photos.count -1) )
	{
		UIImageView *imgView1 = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
		imgView1.image = [self imageAtIndex:currentPageIndex];
		imgView1.contentMode = UIViewContentModeScaleAspectFit;
		imgView1.backgroundColor = [UIColor blackColor];
		imgView1.alpha = 1.0;

		UIImageView *imgView2 = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
		imgView2.image = [self imageAtIndex:currentPageIndex+1];
		imgView2.contentMode = UIViewContentModeScaleAspectFit;
		imgView2.backgroundColor = [UIColor blackColor];
		imgView1.alpha = 0.0;
	
		
		
		[[self view] addSubview:imgView1];
		[[self view] addSubview:imgView2];


		[UIView animateWithDuration:1.0
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut 
						 animations:^{
							 [imgView2 setAlpha:0.0f];
							 [imgView2 setAlpha:1.0f];
						 } 
						 completion:^(BOOL complete){
							 [imgView2 removeFromSuperview];
							 [self jumpToPageAtIndex:currentPageIndex+1]; 
							 [imgView2 removeFromSuperview];
						 } ];
	}
	else 
	{
		[self stopSlideShow]; 
		[self toggleControls];
	}
	[self updateNavigation];
}

#pragma mark -
#pragma mark UIActionSheet actions and Delegates

- (void)showActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"Email Photo",
																	  @"Save to Photo Album",
																	  @"Share on Facebook",
																	  nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
	//[actionSheet showFromRect:self.view.frame inView:self.view animated:YES];
	[actionSheet release];
}

- (void)emailCurrentPhoto 
{

	if (![MFMailComposeViewController canSendMail])
		
		return;
	
	MFMailComposeViewController * mailController = [[MFMailComposeViewController alloc] init];
	[mailController setMailComposeDelegate:self];
	[mailController setSubject:@"Image from Angel Ceballos Photography"];
	
	NSMutableString * body = [NSMutableString stringWithFormat:@"Check out this cool image from Angel Ceballos Photography!\r"
																@"<a href=\"http://www.mysite.com/path/to/link\">www.robotangel.com</a>\r"];
	
	[mailController setMessageBody:body isHTML:YES];
	
	UIImage * image = [self imageAtIndex:currentPageIndex];
	NSData *imageData = UIImagePNGRepresentation(image);
	
	
	[mailController addAttachmentData:imageData mimeType:@"image/png" fileName:@"File.png"];
	[[self navigationController] presentModalViewController:mailController animated:YES];
	[mailController release];
	
}

- (void)shareOnFacebook
{
	_facebook = [RAFacebookController facebookForDelegate:self];
	
	//[_facebook dialog:@"feed" andDelegate:self];
	[self publishPhoto];
}

- (void)saveToPhotoAlbum
{
	UIImage * image = [self imageAtIndex:currentPageIndex];
	UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if ( buttonIndex == kEmailPhoto )
	{
		[self emailCurrentPhoto];
	}
	else if ( buttonIndex == kSaveToPhotoAlbum )
	{
		[self saveToPhotoAlbum];
	}
	else if ( buttonIndex == kShareOnFacebook )
	{
		[self shareOnFacebook];
	}

}


#pragma mark -
#pragma mark Mail Controller Delegates

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
	// Basically, for what we're doing, we'll just want to dismiss the controller when anything happens
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	// Remember page index before rotation
	pageIndexBeforeRotation = currentPageIndex;
	rotating = YES;
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	currentPageIndex = pageIndexBeforeRotation;
	[self performLayout];
	
	// Delay control holding
	[self hideControlsAfterDelay];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	rotating = NO;
}

#pragma mark -
#pragma mark Properties

- (void)setInitialPageIndex:(int)index {
	if (![self isViewLoaded]) {
		if (index < 0 || index >= photos.count) {
			currentPageIndex = 0;
		} else {
			currentPageIndex = index;
		}
	}
}


#pragma mark Facebook Integration

- (void)publishPhoto 
{
	
	RAPhoto * photo = [self currentPhoto];
	NSURL * url = [photo photoURL];
	NSString * title = [photo title];
	NSString * photoURL = [[url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *message = @"Angel Ceballos Photography";
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   message, @"message", photoURL, @"picture", title, @"name", nil];
	
	[_facebook dialog:@"feed"
			andParams:params
		  andDelegate:self];	
}


- (void)fbDidLogin 
{
	[self publishPhoto];
}


#pragma mark Facebook delegates

-(void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}


- (void)fbDidLogout {
	
	
}

- (void)dialogDidSucceed:(NSURL *)url
{
	
}
- (void)dialogDidCancel:(NSURL *)url
{
	
}


@end

