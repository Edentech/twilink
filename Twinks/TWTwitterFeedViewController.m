//
//  TWTwitterFeedViewController.m
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWTwitterFeedViewController.h"
#import "STTwitter.h"
#import "TFHpple.h"
#import "TWTweetCell.h"
#import "TWStory.h"
#import "TWStoryViewController.h"
#import "MBProgressHUD.h"

@interface TWTwitterFeedViewController (){
    
    __weak IBOutlet UITableView *_tweetTable;
    __weak IBOutlet UILabel *_nameLabel;
    NSArray *_statuses;
}

@end

@implementation TWTwitterFeedViewController

#pragma mark loading stuff
- (void)viewDidLoad
{
    [super viewDidLoad];
    _nameLabel.text = @"";
    [self updateTimeline];
}

- (IBAction)refreshView:(id)sender {
    [self updateTimeline];
}

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

#pragma mark load tweets and stories

- (void)updateTimeline {
    [self showActivityStatusBar];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self runTimelineUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

-(void) runTimelineUpdate {
    static NSString *dateKey = @"REFRESH_RATE";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *date = [defaults objectForKey:dateKey];
    
    if (!date){
        [defaults setObject:[NSDate date] forKey:dateKey];
    } else {
        int elapsedMinutes = abs([date timeIntervalSinceNow]/60);
        if (elapsedMinutes < 5  && _statuses.count > 0){
            [self stopActivityStatusBar];
            return;
        }
        [defaults setObject:[NSDate date] forKey:dateKey];
    }
    
    _nameLabel.text = @"";
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _nameLabel.text = [NSString stringWithFormat:@"Fetching timeline for @%@", username];
        NSString *lastId = nil;
        if (_statuses.count > 0){
            TWStory *stry = (TWStory *)[_statuses firstObject];
            lastId = stry.tweetId;
        }
        [twitter getHomeTimelineSinceID:lastId
                                  count:50
                           successBlock:^(NSArray *statuses) {
                               
                               NSLog(@"-- statuses: %@", statuses);
                               
                               _nameLabel.text = [NSString stringWithFormat:@"@%@", username];
                               
                               //                               self.statuses = statuses;
                               NSMutableArray *tempStatuses = [[NSMutableArray alloc] initWithArray:_statuses];
                               for (NSDictionary *d in statuses) {
                                   NSArray *urls = [d valueForKeyPath:@"entities.urls"];
                                   if (urls.count > 0){
                                       TWStory *story = [self storyFromStatus:d];
                                       if (story){
                                           [tempStatuses addObject:story];
                                       }
                                   }
                               }
                               _statuses = tempStatuses;
                               
                               [_tweetTable reloadData];
                               [self stopActivityStatusBar];
                           } errorBlock:^(NSError *error) {
                               _nameLabel.text = [error localizedDescription];
                               [self stopActivityStatusBar];
                           }];
        
    } errorBlock:^(NSError *error) {
        _nameLabel.text = [error localizedDescription];
        [self stopActivityStatusBar];
    }];
}

-(TWStory *)storyFromStatus:(NSDictionary *)status{
    
    NSString *idStr = [status valueForKey:@"id_str"];
    
    NSArray *existing = [_statuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tweetId = %@", idStr]];
    if (existing.count > 0){
        return nil;
    }

    TWStory *story = [[TWStory alloc] init];
    
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    NSArray *urls = [status valueForKeyPath:@"entities.urls"];
    
    NSString *url = urls[0][@"expanded_url"];
    
    NSURL *u = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:u];
    

    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:data];

    NSString *tutorialsXpathQueryString = @"//title";
    NSString *title = url;
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    for (TFHppleElement *element in tutorialsNodes) {
        title = [[element firstChild] content];
        if (title == nil){
            title = @"";
        }
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    NSString *userImageUrl = [status valueForKeyPath:@"user.profile_image_url"];
    story.tweetId = idStr;
    story.user = screenName;
    story.tweet = [status valueForKey:@"text"];
    story.title = (title.length > 0) ? title : story.tweet;
    story.avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageUrl]]];
    story.timestamp = dateString;
    story.url = u;
    
    return story;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TWTweetCell"];
    
    if(cell == nil) {
        cell = [[TWTweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TWTweetCell"];
    }
    
    TWStory *story = [_statuses objectAtIndex:indexPath.row];
    
    cell.titleText.text = story.title;
    cell.titleImage.image = story.avatar;
    
    cell.tweetLabel.text = [NSString stringWithFormat:@"@%@ | %@", story.user, story.timestamp];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TWStory *story = [_statuses objectAtIndex:indexPath.row];
    TWStoryViewController *viewController = (TWStoryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TWStoryViewController"];
    viewController.story = story;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
