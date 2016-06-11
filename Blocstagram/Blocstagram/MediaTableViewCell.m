//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Alexis Schreier on 05/20/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

//mediaItem elements
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) LikeButton *likeButton;

@property (nonatomic, strong) ComposeCommentView *commentView;

@end

//static = belong to every instance of MediaTableViewCell
static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell


#pragma mark - load and init
#pragma mark

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        
        self.mediaImageView.userInteractionEnabled = YES;
        
        //tap geture recognizer in the image view
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        //long press geture recognizer in the image view
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        //create the Like button
//        self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [self.shareButton setEnabled:YES];
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        //add subviews to the table view cell's view herarchy
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.commentView]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        //NSDictionaryOfVariableBindings is particularly useful when creating Autolayout constraints
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        //setting an explicit width of 38 for the like button
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeButton(==38)]|"
                                                                                 options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        NSLayoutConstraint *mediaImageViewTop = [NSLayoutConstraint constraintWithItem:self.mediaImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:8.0];
        
        NSLayoutConstraint *usernameAndCaptionTop = [NSLayoutConstraint constraintWithItem:self.usernameAndCaptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mediaImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4.0];
        
        NSLayoutConstraint *commentLabelTop = [NSLayoutConstraint constraintWithItem:self.commentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameAndCaptionLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4.0];
        
        NSLayoutConstraint *commentLabelBottom = [NSLayoutConstraint constraintWithItem:self.commentLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]"
//                                                                                 options:kNilOptions
//                                                                                 metrics:nil
//                                                                                   views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
    
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [NSLayoutConstraint activateConstraints:@[mediaImageViewTop, usernameAndCaptionTop, commentLabelTop, commentLabelBottom, self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
        //[self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
    }
    return self;
}


#pragma mark - Configure mediaItem subview
#pragma mark

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (!self.mediaItem) {
        return;
    }
    
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
                self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = 0;
    }
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    layoutCell.mediaItem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentView.frame);
}

- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];//see method below
    self.commentLabel.attributedText = [self commentString];//see method below
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.commentView.text = mediaItem.temporaryComment;
}

- (NSAttributedString *) usernameAndCaptionString {
    // #1
    CGFloat usernameFontSize = 15;
    
    // #2 - Make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // #3 - Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // #4
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}


#pragma mark - UIGestureRecognizerDelegate
#pragma mark

//if in editing mode to delete image and user taps on image hide the delete button, don't zoom in
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Image View Gesture Recognizers: Zoom & Share
#pragma mark

//tap gesture method when user taps an the image view (zoom)
- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
    NSLog(@"tap fired");
}

//long press gesture method when user taps an the image view (share)
- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}


#pragma mark - Like Button Tap
#pragma mark

//when like button is tapped, inform the delegate
- (void) likePressed:(UIButton *)sender {
    
    [self.delegate cellDidPressLikeButton:self];
    NSLog(@"like button fired");
}


#pragma mark - ComposeCommentViewDelegate
#pragma mark

//In both commentViewDidPressCommentButton: and commentViewWillStartEditing:, the cell tells its delegate (the images table controller) that a comment was composed or that the user began editing
- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender {
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

//we store the text written so far in temporaryComment. This allows a user to scroll up and down the table without losing any partially written comments
- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text {
    self.mediaItem.temporaryComment = text;
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender {
    [self.delegate cellWillStartComposingComment:self];
}

//If another object tells the cell to stopComposingComment, the cell passes that message to the comment view. This will allow the cell's view controller to dismiss the keyboard by passing a message to the comment editor through the cell.
- (void) stopComposingComment {
    [self.commentView stopComposingComment];
}


@end
