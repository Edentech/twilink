//
//  TWStoryViewController.h
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TWStory;

@interface TWStoryViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) TWStory *story;

@end
