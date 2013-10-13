//
//  TWStory.h
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWStory : NSObject{
    BOOL _parsed;
}

@property (nonatomic, retain) NSString *tweetId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *tweet;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *forAccount;
@property (nonatomic, retain) NSString *realName;
@property (nonatomic, retain) NSString *retweets;
@property (nonatomic, retain) NSString *favoritesCount;

-(NSString *) titleForStory;

@end
