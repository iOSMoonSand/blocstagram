//
//  DataSource.h
//  Blocstagram
//
//  Created by Alexis Schreier on 05/19/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

+(instancetype) sharedInstance;

+ (NSString *) instagramClientID;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

//We want other classes to be able to request that images be downloaded so we make this method public in .h
- (void) downloadImageForMediaItem:(Media *)mediaItem;

@end
