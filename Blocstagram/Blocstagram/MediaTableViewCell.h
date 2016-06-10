//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Alexis Schreier on 05/20/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;
//define the new MediaTableViewCell protocol

@protocol MediaTableViewCellDelegate <NSObject>

//protocol's delegate method which will inform the cell's controller when the user taps on the image
- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;

//protocol's delegate method to trigger a share sheet if the user long-presses on an image
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

//indicates like button was pressed
- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;


+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
