//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Alexis Schreier on 05/24/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.


//view controller to handle displaying a Media item in full-screen

#import <UIKit/UIKit.h>

@class Media, MediaFullScreenViewController;

// declare protocol
@protocol MediaFullScreenViewControllerDelegate <NSObject>

- (void)displayShareSheetWithImage:(UIImage *)image onViewController:(UIViewController *)viewController;

@end


@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, weak) id <MediaFullScreenViewControllerDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

//properties for the gesture recognizers
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

//custom initializer, pass it a Media object to display
- (instancetype) initWithMedia:(Media *)media;

//Scroll views don't just slide content around on the screen - they also make it easy to zoom in and out.
- (void) centerScrollView;

@end
