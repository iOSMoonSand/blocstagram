//
//  FilterCollectionViewCell.h
//  Blocstagram
//
//  Created by Alexis Schreier on 06/15/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterCollectionViewCell;
@protocol FilterCollectionViewCellDelegate <NSObject>

- (CGFloat) calculateEdgeSizeWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout;

@end



@interface FilterCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, weak) id <FilterCollectionViewCellDelegate> delegate;

@end
