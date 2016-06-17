//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Alexis Schreier on 05/24/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.


//view controller to handle displaying a Media item in full-screen

#import <UIKit/UIKit.h>

@class Media, MediaFullScreenViewController;
@protocol MediaFullScreenViewControllerDelegate <NSObject>

- (void)displayShareSheetWithImage:(UIImage *)image onViewController:(UIViewController *)viewController;

@end



@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, weak) id <MediaFullScreenViewControllerDelegate> delegate;

@property (nonatomic, strong) Media *media; //property to store Media items

//@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UITapGestureRecognizer *dismissalTap;

//custom initializer, pass it a Media object to display
- (instancetype) initWithMedia:(Media *)media;

//Scroll views don't just slide content around on the screen - they also make it easy to zoom in and out.
- (void) centerScrollView;

//allow subclasses request the recalculation of the zoom scales
- (void) recalculateZoomScale;

@end
