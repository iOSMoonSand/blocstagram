//
//  MediaTests.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/17/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testThatInitializationWorks {
    
    NSDictionary *sourceDictionary = @{@"id" : @"01978465",
                                       @"caption" : @"This caption",
                                       @"comments" : @[@"comment 1",@"comment 2"],
                                       @"image" : @"http://www.example.com/example.jpg"};
    
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The id number should be equal");
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"], @"The caption shouled be equal");
    XCTAssertEqualObjects(testMedia.comments, sourceDictionary[@"comments"], @"The comments should be equal");
    XCTAssertEqualObjects(testMedia.mediaURL, [NSURL URLWithString:sourceDictionary[@"image"]], @"The image should be equal");
}

@end
