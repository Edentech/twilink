//
//  TWStoryViewController.m
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWStoryViewController.h"
#import "TWStory.h"
#import "TUSafariActivity.h"
#import "MBProgressHUD.h"
#import "TWTweetDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TWStoryViewController (){
    
    __weak IBOutlet UITextView *_tweetTextView;
    __weak IBOutlet UIImageView *_avatarImageView;
    __weak IBOutlet UIWebView *_webView;
}


@end

@implementation TWStoryViewController
@synthesize story;

#pragma mark control

- (void)showActivityStatusBar {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)stopActivityStatusBar {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
    [self showActivityStatusBar];
    [self setup];
    [super viewDidLoad];
    _webView.delegate = self;
}

-(void) setup{
    self.title = story.title;
    _tweetTextView.text = story.tweet;
    [_webView loadRequest:[NSURLRequest requestWithURL:story.url]];
    _avatarImageView.image = story.avatar;
    _avatarImageView.layer.cornerRadius = 15.0f;
    _avatarImageView.clipsToBounds = YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TWTweetDetailsViewController *controller =
    (TWTweetDetailsViewController *)[segue destinationViewController];
    
    controller.story = story;
}

- (IBAction)actionTapped:(id)sender {
    TUSafariActivity *safari = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[story.url, story.title] applicationActivities:@[safari]];
    [self presentViewController:activityView animated:YES completion:nil];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopActivityStatusBar];
}

@end
