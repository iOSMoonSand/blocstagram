//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/07/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation CircleSpinnerView

//We'll create circleLayer by overriding the getter, and creating it the first time it's called. (This is called lazy instantiation.)
- (CAShapeLayer*)circleLayer {
    if(!_circleLayer) {
        //calculates a CGPoint representing the center of the arc. (In our case, the arc is an entire circle.)
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        //arcCenter is used to construct a CGRect. The spinning circle will fit inside this rect.
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        //This makes a UIBezierPath object. (A bezier path is a path which can have both straight and curved line segments.)
        //bezierPathWithArcCenter:radius:startAngle:endAngle:clockwise: makes a new bezier path in the shape of an arc, with the start and end angles in radians
        //smoothedPath represents a smooth circle
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        //Here we're creating a CAShapeLayer, a core animation layer made from a bezier path. (Other layers can be made from other things, such as images.)
        _circleLayer = [CAShapeLayer layer];
        //We set its contentScale, which is just like UIImage's scale (1.0 on regular screens; 2.0 on Retina Displays).
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        //Its frame is set to rect
        _circleLayer.frame = rect;
        //We want the center of the circle to be transparent (so we can see the heart),
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        //and the border to be the defined strokeColor
        //Core animation classes use CGColorRef instead of UIColor, so we convert them using CGColor
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        //lineCap specifies the shape of the ends of the line
        _circleLayer.lineCap = kCALineCapRound;
        //lineJoin specifies the shape of the joints between parts of the line
        _circleLayer.lineJoin = kCALineJoinBevel;
        //Finally, we assign the circular path to the layer
        _circleLayer.path = smoothedPath.CGPath;
        
        //We'll now make a mask layer and set its size to be the same. Different parts of a layer can have different opacities, as indicated by its mask layer's alpha channel.
        CALayer *maskLayer = [CALayer layer];
        //image from .xcassets folder
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        //Now we'll animate the mask in a circular motion.
        //set the animation duration to 1 second. (CFTimeInterval, like NSTimeInterval, is specified in seconds.)
        CFTimeInterval animationDuration = 1;
        //We specify a linear animation (as opposed to easing in or out, for example.) This means the speed of the movement will stay the same throughout the entire animation.
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        //We specify that this animation will animate the layer's rotation transform from 0 to π * 2 (one full circular turn.)
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        //This animation will be repeated an infinite number of times.
        animation.repeatCount = INFINITY;
        //fillMode specifies what happens when the animation is complete (you can opt to hide layers once an animation has ended.) In our case, we specify kCAFillModeForwards to leave the layer on screen after the animation.
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        //Finally, we add the animation to the layer.
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        //Now that we've animated the mask, all that's left is to animate the line that draws the circle itself.
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        //We use two CABasicAnimations
        //One animates the start of the stroke
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        //the other animates the end
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        //Both animations are added to a CAAnimationGroup, which groups multiple animations and runs them concurrently.
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        //We add the animations to the circle layer, and we're done building the animation
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}

//positions the circle layer in the center of the view
- (void)layoutAnimatedLayer {
    
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

//When we add a subview to another view using [UIView -addSubview:], the subview can react to this in [UIView -willMoveToSuperview:]
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    } else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

//Update the position of the layer if the frame changes
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
    }
}

//If we change the radius of the circle, that will affect positioning as well. We can update this by overriding the setter (setRadius:) to recreate the circle layer
- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

//We should also inform self.circleLayer if the other two properties change (stroke width or color)
- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

//set some default values in the initializer and provide a hint about our size
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
