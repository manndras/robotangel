//
//  RACategoryView.h
//  robotangel
//
//  Created by Rob Daly on 3/11/11.
//  Copyright 2011 Platonic Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAGallery;

@interface RAGalleryView : UIView {

	RAGallery * _gallery;
}

@property (nonatomic, readwrite, retain) RAGallery * gallery;

- (id)initWithFrame:(CGRect)frame forGallery:(RAGallery *)gallery;
- (CGRect)scaledImageRect:(CGRect)iRect forContentRect:(CGRect)rect;


@end
