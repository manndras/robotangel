//
//  Menu.m
//  Robotangel
//
//  Created by Rob Daly on 3/26/2011.
//  Copyright 2011 Rob Daly. All rights reserved.
//

#import "Menu.h"
#import "RAPhotoBrowser.h"

@implementation Menu

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		self.title = @"RAPhotoBrowser";
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {

	// Super
    [super viewWillAppear:animated];
	
	// Set bar styles
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure
	switch (indexPath.row) {
		case 0: cell.textLabel.text = @"Single photo from a file"; break;
		case 1: cell.textLabel.text = @"Multiple photos from files"; break;
		case 2: cell.textLabel.text = @"Multiple photos from Flickr"; break;
		default: break;
	}
    return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Browser
	NSMutableArray *photos = [[NSMutableArray alloc] init];
	switch (indexPath.row) {
		case 0: 
			[photos addObject:[RAPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]]];
			break;
		case 1: 
			[photos addObject:[RAPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]]];
			[photos addObject:[RAPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]]];
			[photos addObject:[RAPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3l" ofType:@"jpg"]]];
			[photos addObject:[RAPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo4l" ofType:@"jpg"]]];
			break;
		case 2: 
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404564/524x520.jpeg?token=7VdVP0U6ps_rLPDRWZJcsT8e-aw1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404569/522x520.jpeg?token=UiLs07VhK4aVfwH5xQZVuQzQP7U1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404566/500x500.jpeg?token=k5FbRA9qdJK5FwhkS2V_cBFsO8E1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404568/780x410.jpeg?token=MFftIbAvobV4N2RoIKdh1wA9_ho1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404572/780x390.jpeg?token=tjofGuzEaKWjZFV58iMdCdKYFa81"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404573/274x520.jpeg?token=YSlTLeU5r-T6zvj0NiEBbnr72Ko1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/11404574/390x450.jpeg?token=HF-BsUIKbFlT8f-1hSzAHRff-Hk1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003266/521x520.jpeg?token=wdq49_MLJX3a6EfQ7VK9b8fE3hA1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003267/521x520.jpeg?token=Ebg6AwjqD5lWsjbsE9yq1G0rQo41"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003264/521x520.jpeg?token=Zal633AX88IJQ_2xuR9LGLlDtNk1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003265/521x520.jpeg?token=5Kt20Fh6H-8v7jMfoX884II_Q4g1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/9973292/527x520.jpeg?token=_VQx68q2LW0LnjtO4t7GeUqcZ2Y1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003257/514x520.jpeg?token=d7ALAABQRTsUeababPAB6170mSI1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003222/521x520.jpeg?token=DqwUjGpxXjTsFaRNzTTkJlk9qlU1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003261/521x520.jpeg?token=dVG2wpkLctpLkxkXLbouedr8KKY1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003258/521x520.jpeg?token=VgmCh8diILvBwRi6jMvivdKacU81"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003259/521x520.jpeg?token=vm2gD6BaUvoZldzg2we3BbGGp3U1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003260/521x520.jpeg?token=uIudKr8sQRdpHHPPu-KeLd5oPSk1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003285/521x520.jpeg?token=9bFoBpZtfMYwBmj7pan1B2wKAr01"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5811940/769x520.jpeg?token=5A1FX1xSGCTp_YDnKgMGDnBN6Ac1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5811960/340x520.jpeg?token=0kXK-nt3V4NAi9Z0osgGHEcEQ8k1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5811936/346x520.jpeg?token=ExgH37louZhh6Jgbl0Cv6BxcsGA1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003221/521x520.jpeg?token=cjqnFANXaYYkZQRyi3Wsd2zbtbA1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/6003286/521x520.jpeg?token=4TI9m0VvDSH7JqHW9GFR5r18ADE1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812212/344x520.jpeg?token=9N5RaDAaWkbJTCuSvrWtimVfphk1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812213/347x520.jpeg?token=cAn21jRAtLu9OEQtvINybuhBDaU1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812214/346x520.jpeg?token=CRB1XGaCpgBmbU4oDIkyrnPZGwI1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812215/767x520.jpeg?token=Lqrt54xuGXsZVGRO1mW85h-otkM1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812216/780x518.jpeg?token=sGzXpKWGHLeRPRwx0yYpv85_0Iw1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812246/756x520.jpeg?token=djv5HWjHRHKMj5TJBx7WfJOSelc1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812248/351x520.jpeg?token=43m4zVb8YLnozWfVHvKcDFTPEK81"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812247/356x520.jpeg?token=AjQZfhxsnCXZ419KwiMdaRtwsGE1"]]];
			[photos addObject:[RAPhoto photoWithURL:[NSURL URLWithString:@"http://m.cmcdn.net/5812267/735x520.jpeg?token=zzU9UbTEdggybRofSmt5yJRRnI81"]]];			
			break;
		default: break;
	}
	
	// Create browser
	RAPhotoBrowser *browser = [[RAPhotoBrowser alloc] initWithPhotos:photos];
	//[browser setInitialPageIndex:0]; // Can be changed if desired
	[self.navigationController pushViewController:browser animated:YES];
	[browser release];
	[photos release];
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}

@end

