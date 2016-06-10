//
//  ComposeCommentView.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/10/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "ComposeCommentView.h"

@interface ComposeCommentView () <UITextViewDelegate>//conforms to the UITextViewDelegate protocol

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation ComposeCommentView

//init with button and text view
- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.textView = [UITextView new];
        self.textView.delegate = self;
        
        self.button = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.button setAttributedTitle:[self commentAttributedString] forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.textView];
        //self.button is a subview of self.textView, not self. This will be helpful when we want to wrap long comment text around the button.
        [self.textView addSubview:self.button];
    }
    
    return self;
}

- (NSAttributedString *) commentAttributedString {
    
    NSString *baseString = NSLocalized
}

@end

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */