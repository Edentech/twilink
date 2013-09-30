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
#import <QuartzCore/QuartzCore.h>

@interface TWTwitterFeedViewController (){
    
    __weak IBOutlet UITableView *_tweetTable;
    __weak IBOutlet UILabel *_nameLabel;
    NSMutableDictionary *_statusCache;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButton;

@end

@implementation TWTwitterFeedViewController

#pragma mark loading stuff
- (void)viewDidLoad
{
    _statusCache = [[NSMutableDictionary alloc] init];
    [self.revealButton setAction: @selector(revealToggle:)];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(accountSwitched)
     name:kAccountSwitchNotification
     object:nil];
    
    [super viewDidLoad];
    _nameLabel.text = @"";
    [self updateTimeline];
}

- (IBAction)refreshView:(id)sender {
    [[TWStorage shared] twitterAccounts];
    [self updateTimeline];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        
        UIImage *image = [UIImage imageNamed:@"logo"];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [_tweetTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(void) accountSwitched{
    [_tweetTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[TWUtilities makeDateKeyForUser]];
    [defaults synchronize];
    [self updateTimeline];
    [self.revealViewController revealToggleAnimated:YES];
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

-(NSString *) currentUserName {
    return [TWStorage shared].selectedAccount.username;
}

-(NSArray *) statusList{
    NSArray *objs = [_statusCache objectForKey:[self currentUserName]];
    if (!objs) return @[];
    return objs;
}

- (void)updateTimeline {
    [self showActivityStatusBar];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self runTimelineUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

-(void) accountError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have no Twitter accounts configured.  Please first configure a Twitter account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [self stopActivityStatusBar];
    [alert show];
}

-(void) runTimelineUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dateKey = [TWUtilities makeDateKeyForUser];
    
    NSDate *date = [defaults objectForKey:dateKey];
    
    if (!date){
        [defaults setObject:[NSDate date] forKey:dateKey];
    } else {
        int elapsedMinutes = abs([date timeIntervalSinceNow]/60);
        if (elapsedMinutes < 5  && [self statusList].count > 0){
            [self stopActivityStatusBar];
            return;
        }
        [defaults setObject:[NSDate date] forKey:dateKey];
    }
    [defaults synchronize];
    
    _nameLabel.text = @"";
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithAccount:[TWStorage shared].selectedAccount];

    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        if ([TWStorage shared].selectedAccount == nil){
            [[TWStorage shared] twitterAccounts];
        }
        if (![TWStorage shared].selectedAccount){
            [self performSelectorOnMainThread:@selector(accountError) withObject:nil waitUntilDone:NO];
            return;
        }
        
        _nameLabel.text = [NSString stringWithFormat:@"Fetching timeline for @%@", username];
        NSString *lastId = nil;
        NSArray *filteredStatuses = [self statusList];
        if (filteredStatuses.count > 0){
            TWStory *stry = (TWStory *)[filteredStatuses firstObject];
            lastId = stry.tweetId;
        }
        [twitter getHomeTimelineSinceID:lastId
                                  count:50
                           successBlock:^(NSArray *statuses) {
                               
                               NSLog(@"-- statuses: %lu", (unsigned long)statuses.count);
                               
                               _nameLabel.text = [NSString stringWithFormat:@"@%@", username];
                               
                               //                               self.statuses = statuses;
                               NSMutableArray *tempStatuses = [[NSMutableArray alloc] initWithArray:filteredStatuses];
                               for (NSDictionary *d in statuses) {
                                   NSArray *urls = [d valueForKeyPath:@"entities.urls"];
                                   if (urls.count > 0){
                                       TWStory *story = [self storyFromStatus:d];
                                       if (story){
                                           story.forAccount = username;
                                           [tempStatuses addObject:story];
                                       }
                                   }
                               }
 
                               [_statusCache setObject:tempStatuses forKey:[self currentUserName]];

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
    
    NSArray *existing = [[self statusList] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tweetId = %@", idStr]];
    if (existing.count > 0){
        return nil;
    }

    TWStory *story = [[TWStory alloc] init];
    
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    NSArray *urls = [status valueForKeyPath:@"entities.urls"];
    
    NSString *url = urls[0][@"expanded_url"];
    
    NSURL *u = [NSURL URLWithString:url];
    
    NSString *userImageUrl = [status valueForKeyPath:@"user.profile_image_url"];
    story.tweetId = idStr;
    story.user = screenName;
    story.tweet = [status valueForKey:@"text"];
    story.avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageUrl]]];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE MMM dd H:mm:ss ZZZZ yyyy"];
    story.timestamp = [format dateFromString:dateString];
    story.url = u;
    
    return story;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self statusList] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TWTweetCell"];
    
    if(cell == nil) {
        cell = [[TWTweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TWTweetCell"];
    }
    
   // NSLog(@"Index path is %i", indexPath.row);
    if ([self statusList].count <= indexPath.row) return cell;
    
    TWStory *story = [[self statusList] objectAtIndex:indexPath.row];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *tempTitle = [story titleForStory];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.titleText.text = tempTitle;
        });
    });
    
    cell.titleImage.image = story.avatar;
    cell.titleImage.layer.cornerRadius = 15.0f;
    cell.titleImage.clipsToBounds = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:story.timestamp];

    
    cell.tweetLabel.text = [NSString stringWithFormat:@"@%@ | %@", story.user, formattedDateString];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TWStory *story = [[self statusList] objectAtIndex:indexPath.row];
    TWStoryViewController *viewController = (TWStoryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TWStoryViewController"];
    viewController.story = story;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
