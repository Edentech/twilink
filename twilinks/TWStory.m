//
//  TWStory.m
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWStory.h"
#import "TFHpple.h"

@implementation TWStory
@synthesize tweetId,title,tweet,user,avatar,timestamp,url, forAccount;

-(NSString *) titleForStory{
    if(_parsed){
        return title;
    }
    _parsed = true;
    title = @"";
    NSData *data = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    NSString *xpath = @"//title";
    
    NSArray *nodes = [parser searchWithXPathQuery:xpath];
    for (TFHppleElement *element in nodes) {
        title = [[element firstChild] content];
        if (title == nil){
            title = tweet;
        }
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if (!title || title.length == 0){
        title = @"No Title";
    }
    return title;
}
@end
