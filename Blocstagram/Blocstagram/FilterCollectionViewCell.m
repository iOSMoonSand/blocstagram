//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/15/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@implementation FilterCollectionViewCell
    
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
//        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.clipsToBounds = YES;
        
        
//        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        
        
        for (UIView *view in @[self.thumbnail, self.label]) {
            [self.contentView addSubview:view];
        }
    }
    
    return self;
}


@end
