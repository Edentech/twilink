//
//  TWStoryViewController.m
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWStoryViewController.h"
#import "TWStory.h"
#import "TUSafariActivity.h"

@interface TWStoryViewController (){
    
    __weak IBOutlet UITextView *_tweetTextView;
    __weak IBOutlet UIImageView *_avatarImageView;
    __weak IBOutlet UIWebView *_webView;
}


@end

@implementation TWStoryViewController
@synthesize story;


- (void)viewDidLoad
{
    [self setup];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) setup{
    self.title = story.title;
    _tweetTextView.text = story.tweet;
    [_webView loadRequest:[NSURLRequest requestWithURL:story.url]];
    _avatarImageView.image = story.avatar;
}

- (IBAction)actionTapped:(id)sender {
    TUSafariActivity *safari = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[story.url, story.title] applicationActivities:@[safari]];
    [self presentViewController:activityView animated:YES completion:nil];
}

@end
