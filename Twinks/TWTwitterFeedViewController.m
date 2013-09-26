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

@interface TWTwitterFeedViewController (){
    
    __weak IBOutlet UITableView *_tweetTable;
    __weak IBOutlet UILabel *_nameLabel;
    NSArray *_statuses;
}

@end

@implementation TWTwitterFeedViewController


- (void)showActivityStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)stopActivityStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}


- (void)updateTimeline {
    [self showActivityStatusBar];

    _nameLabel.text = @"";
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _nameLabel.text = [NSString stringWithFormat:@"Fetching timeline for @%@", username];
        
        [twitter getHomeTimelineSinceID:nil
                                  count:50
                           successBlock:^(NSArray *statuses) {
                               
                               NSLog(@"-- statuses: %@", statuses);
                               
                               _nameLabel.text = [NSString stringWithFormat:@"@%@", username];
                               
                               //                               self.statuses = statuses;
                               NSMutableArray *tempStatuses = [[NSMutableArray alloc] init];
                               for (NSDictionary *d in statuses) {
                                   NSArray *urls = [d valueForKeyPath:@"entities.urls"];
                                   if (urls.count > 0){
                                       TWStory *story = [self storyFromStatus:d];
                                       [tempStatuses addObject:story];
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
        return [existing firstObject];
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
    story.avatar = userImageUrl;
    story.timestamp = dateString;
    story.url = u;
    
    return story;
}
- (IBAction)refreshView:(id)sender {
    [self updateTimeline];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
//    _tweetTable.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
	// Do any additional setup after loading the view, typically from a nib.
    _nameLabel.text = @"";
    [self updateTimeline];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_statuses count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TWTweetCell"];
    
    if(cell == nil) {
        cell = [[TWTweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TWTweetCell"];
    }
    
    TWStory *story = [_statuses objectAtIndex:indexPath.row];
    
    cell.titleText.text = story.title;
    cell.titleImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:story.avatar]]];
    
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
