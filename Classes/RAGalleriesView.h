//
//  RAGalleriesView.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RAGalleriesView : UIScrollView <UIScrollViewDelegate> {

	NSArray * _categories;
	NSMutableArray * _views;
}

@property (nonatomic, readwrite, retain) NSArray * categories;
@property (nonatomic, readwrite, retain) NSArray * views;

- (id)initWithFrame:(CGRect)frame categories:(NSArray *)categories;
- (void)addCategories;


@end
