//
//  LikeButton.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/07/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

//define the image names
#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface LikeButton ()

//property for storing the spinerView
@property (nonatomic, strong) CircleSpinnerView *spinnerView;

@end

@implementation LikeButton

//create the spinner view, and set up the button upon init
- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //contentEdgeInsets provides a buffer between the edge of the button and the content
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //contentVerticalAlignment specifies the alignment of the button's content. By default it's centered, but we want it at the top so that the like button isn't misaligned on photos with longer captions.
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        //set the default state to "not liked"
        self.likeButtonState = LikeStateNotLiked;
    }
    
    return self;
}

//spinner view's frame should be updated whenever the button's frame changes
- (void) layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

//Update the button's appearance based on the set state
//This setter updates the button's image and userInteractionEnabled property depending on the LikeState passed in. It also shows or hides the spinner view as appropriate.
- (void) setLikeButtonState:(LikeState)likeState {
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
