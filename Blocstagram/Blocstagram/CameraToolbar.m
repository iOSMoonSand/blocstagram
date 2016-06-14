//
//  CameraToolbar.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "CameraToolbar.h"

@interface CameraToolbar ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *cameraButton;

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIView *purpleView;

@end




@implementation CameraToolbar

- (instancetype) initWithImageNames:(NSArray *)imageNames {
    
    self = [super init];
    
    if (self) {
        
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftButton setImage:[UIImage imageNamed:imageNames.firstObject] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:imageNames.lastObject] forState:UIControlStateNormal];
        [self.cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.cameraButton setContentEdgeInsets:UIEdgeInsetsMake(10,10,15,10)];
        
        self.whiteView = [UIView new];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        
        self.purpleView = [UIView new];
        self.purpleView.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1];
        
        for (UIView *view in @[self.whiteView, self.purpleView, self.leftButton, self.cameraButton, self.rightButton]) {
            
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [self createConstraints];
    }
    
    return self;
}

//position the views with auto-layout
- (void) createConstraints {
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_leftButton, _rightButton, _cameraButton, _whiteView, _purpleView);
    
    // The three buttons have equal widths and are distributed across the whole view
    NSArray *allButtonsHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftButton][_cameraButton(==_leftButton)][_rightButton(==_leftButton)]|"
                                                                                       options:kNilOptions
                                                                                       metrics:nil
                                                                                         views:viewDictionary];
    
    //left and right buttons have 10 points of spacing from the top. all 3 buttons are aligned with the bottom of the view
    NSArray *leftButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_leftButton]|"
                                                                                     options:kNilOptions
                                                                                     metrics:nil
                                                                                       views:viewDictionary];
    
    NSArray *cameraButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraButton]|"
                                                                                       options:kNilOptions
                                                                                       metrics:nil
                                                                                         views:viewDictionary];
    
    NSArray *rightButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_rightButton]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:viewDictionary];
    
    // The white view goes behind all the buttons, 10 points from the top.
    NSArray *whiteViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_whiteView]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:viewDictionary];
    
    NSArray *whiteViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_whiteView]|"
                                                                                    options:kNilOptions
                                                                                    metrics:nil
                                                                                      views:viewDictionary];
    
    // The purple view is positioned identically to the camera button
    NSArray *purpleViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_leftButton][_purpleView][_rightButton]"
                                                                                       options:NSLayoutFormatAlignAllBottom
                                                                                       metrics:nil
                                                                                         views:viewDictionary];
    
    NSArray *purpleViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_purpleView]"
                                                                                     options:kNilOptions
                                                                                     metrics:nil
                                                                                       views:viewDictionary];
    
    NSArray *allConstraintsArray = @[allButtonsHorizontalConstraints, leftButtonVerticalConstraints, rightButtonVerticalConstraints, cameraButtonVerticalConstraints, whiteViewVerticalConstraints, whiteViewHorizontalConstraints, purpleViewVerticalConstraints, purpleViewHorizontalConstraints];
    
    for (NSArray *constraintsArray in allConstraintsArray) {
        
        for (NSLayoutConstraint *constraint in constraintsArray) {
            
            [self addConstraint: constraint];
        }
    }
}

//in layout subviews, round the top corners of the purple view with a mask layer
- (void) layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.purpleView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.purpleView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.purpleView.layer.mask = maskLayer;
}

//inform delegate when buttons are tapped
# pragma mark - Button Handlers
# pragma mark

- (void) leftButtonPressed:(UIButton *)sender {
    
    //method called on delegate property defined in public interface: whatever object the delegate is, when the user taps this button the leftButtonPressedOnToolbar: method will get called. We implement that method in the delegate's .m file to tell it what to do
    [self.delegate leftButtonPressedOnToolbar:self];
}

- (void) rightButtonPressed:(UIButton *)sender {
    
    [self.delegate rightButtonPressedOnToolbar:self];
}

- (void) cameraButtonPressed:(UIButton *)sender {
    
    [self.delegate cameraButtonPressedOnToolbar:self];
}

@end







/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */