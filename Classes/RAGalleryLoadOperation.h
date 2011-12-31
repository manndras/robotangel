//
//  RAGalleryLoadOperation.h
//  robotangel
//
//  Created by rdaly on 1/23/11.
//  Copyright 2011 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RAGallery;

@interface RAGalleryLoadOperation : NSOperation {

	RAGallery * _gallery;
	NSURL * _galleryURL;
}

@property (nonatomic, readwrite, retain) RAGallery * gallery;
@property (nonatomic, readwrite, retain) NSURL * galleryURL;

- (id) initWithGallery:(RAGallery *)gallery;
- (NSArray *)scriptElementsForURL:(NSURL *)url;
- (NSArray *)imagesFromGalleryHTMLBlob:(NSString *)htmlBlob;

@end
