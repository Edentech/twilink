//
//  TWStoryViewController.m
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWStoryViewController.h"
#import "TWStory.h"
#import "TWSafariActivity.h"

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
    _avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:story.avatar]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionTapped:(id)sender {
    TWSafariActivity *safari = [[TWSafariActivity alloc] init];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[story.title, story.url] applicationActivities:@[safari]];
    [self presentViewController:activityView animated:YES completion:nil];
}

@end
