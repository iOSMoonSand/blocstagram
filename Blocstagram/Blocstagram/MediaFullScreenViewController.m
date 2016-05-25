//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Alexis Schreier on 05/24/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"

#pragma mark - add05
#import "MediaTableViewCell.m"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Media *media; //property to store Media items

#pragma mark - add01
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation MediaFullScreenViewController


#pragma mark - view load and init
#pragma mark

//set up the scroll view and image view

- (instancetype) initWithMedia:(Media *)media {
    self = [super init];
    
    //store the media item for later use
    if (self) {
        self.media = media;
    }
    
    return self;
}

//make sure the image starts out centered
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    #pragma mark - add02
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // #1 create and configure a scroll view, and add it as the only subview of self.view
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    // #2 create an image view, set the image, and add it as a subview of the scroll view
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    #pragma mark - add04
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setEnabled:NO];
    
    [self.shareButton setTitle:NSLocalizedString(@"Share", @"Share command") forState:UIControlStateNormal];
    [self.shareButton addTarget:self.scrollView action:@selector(longPressFired) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:self.shareButton];
    
    // #3 contentSize represents the size of the content view, which is the content being scrolled around. In our case, we're simply scrolling around an image, so we'll pass in its size.
    self.scrollView.contentSize = self.media.image.size;
    
    //initialize gesture recognizers
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2; //allows a tap gesture recognizer to require more than one tap to fire
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap]; //allows one gesture recognizer to wait for another gesture recognizer to fail before it succeeds. Without this line, it would be impossible to double-tap because the single tap gesture recognizer would fire before the user had a chance to tap twice.
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // #4 scroll view's frame is set to the view's bounds. This way, the scroll view will always take up all of the view's space.
    self.scrollView.frame = self.view.bounds;
    
    // #5 set the views' frames
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    //Whichever is smaller will become our minimumZoomScale. This prevents the user from pinching the image so small that there's wasted screen space.
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    //maximumZoomScale will always be 1 (representing 100%). We could make this bigger, but then the image would get pixelated if the user zooms in too much.
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    
    #pragma mark - add03
    static const CGFloat itemHeight = 60;
    CGFloat width = CGRectGetWidth(self.imageView.bounds);
    CGFloat buttonWidth = CGRectGetWidth(self.imageView.bounds) / 4;
    CGFloat imageViewHeight = CGRectGetHeight(self.scrollView.bounds) - itemHeight;
    
    // Now, assign the frames
    self.shareButton.frame = CGRectMake(250, 0, buttonWidth, itemHeight);
    self.imageView.frame = CGRectMake(0, CGRectGetMaxY(self.shareButton.frame), width, imageViewHeight);
}


#pragma mark - center scroll view
#pragma mark

//If the image is zoomed out so it doesn't fill the full scroll view, this method will center the image on the appropriate axis.
- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}


#pragma mark - UIScrollViewDelegate
#pragma mark

// #6 tells the scroll view which view to zoom in and out on
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// #7 calls centerScrollView after the user has changed the zoom level
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}


#pragma mark - Gesture Recognizers
#pragma mark

//When the user single-taps, simply dismiss the view controller
- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//When the user double-taps, adjust the zoom level
- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        // #8 If the current zoom scale is already as small as it can be, double-tapping will zoom in. This works by calculating a rectangle using the user's finger as a center point, and telling the scroll view to zoom in on that rectangle.
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        // #9 If the current zoom scale is larger then zoom out to the minimum scale.
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}


#pragma mark - Misc
#pragma mark

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
