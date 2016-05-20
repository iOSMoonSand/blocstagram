//
//  Comment.h
//  Blocstagram
//
//  Created by Alexis Schreier on 05/19/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (nonatomic, strong) NSString *idNumber;

@property (nonatomic, strong) User *from;
@property (nonatomic, strong) NSString *text;

@end
