//
//  ComposeCommentView.h
//  Blocstagram
//
//  Created by Alexis Schreier on 06/10/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComposeCommentView;

//The compose comment view's delegate protocol will inform its delegate when the user starts editing, updates the text, or presses the comment button.
@protocol ComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender;
- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentViewWillStartEditing:(ComposeCommentView *)sender;

@end

@interface ComposeCommentView : UIView

@property (nonatomic, weak) NSObject <ComposeCommentViewDelegate> *delegate;//the object of the ComposeCommentView class has a delegate of type NSObject and must conform to the <ComposeCommentViewDelegate> protocol
@property (nonatomic, assign) BOOL isWritingComment;//determines whether the user is currently editing a comment
@property (nonatomic, strong) NSString *text;//contains the text of the comment, and will allow an external controller to set text

//A controller can call stopComposingComment to end composition and dismiss the keyboard
- (void) stopComposingComment;

@end
