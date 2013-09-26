//
//  TWStory.h
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWStory : NSObject

@property (nonatomic, retain) NSString *tweetId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *tweet;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *timestamp;
@property (nonatomic, retain) NSURL *url;

@end
