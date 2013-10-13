//
//  TWTweetDetailsViewController.m
//  twilink
//
//  Created by Matthew Mondok on 10/12/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWTweetDetailsViewController.h"
#import "TWStory.h"
#import <QuartzCore/QuartzCore.h>

@interface TWTweetDetailsViewController (){
    
    __weak IBOutlet UILabel *_tweetRTs;
    __weak IBOutlet UILabel *_twitterHandle;
    __weak IBOutlet UITextView *_tweetText;
    __weak IBOutlet UILabel *_twitterRealName;
    __weak IBOutlet UIImageView *_twitterImage;
    __weak IBOutlet UIView *_dossierView;
    __weak IBOutlet UILabel *_tweetFaves;
    __weak IBOutlet UITextView *_tweetLink;
    __weak IBOutlet UITextView *_tweetLinkPageTitle;
}

@end

@implementation TWTweetDetailsViewController
@synthesize story;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _tweetText.contentInset = UIEdgeInsetsMake(-10,-2,0,0);
    _tweetLink.contentInset = UIEdgeInsetsMake(-10,-2,0,0);
    _tweetLinkPageTitle.contentInset = UIEdgeInsetsMake(-10,-2,0,0);
    [self setupView];
    [self setupDossier];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupDossier{
    @try {
        _twitterImage.image = story.avatar;
        _twitterRealName.text = story.realName;
        _tweetText.text = story.tweet;
        _twitterHandle.text = story.user;
        _tweetFaves.text =story.favoritesCount;
        _tweetRTs.text = story.retweets;
        
        _tweetLink.text = [story.url absoluteString];
        _tweetLinkPageTitle.text = [story titleForStory];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception debugDescription]);
    }
}

-(void) setupView{
    [_dossierView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dossier"]]];
    [_dossierView.layer setOpaque:NO];
    _dossierView.opaque = NO;
    _dossierView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _dossierView.layer.shadowOpacity = 1.0;
    _dossierView.layer.shadowRadius = 10.0;
    _dossierView.layer.shadowOffset = CGSizeMake(1, 3);
    _dossierView.clipsToBounds = NO;
}

@end
