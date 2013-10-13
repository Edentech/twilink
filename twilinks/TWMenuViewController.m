//
//  TWMenuViewController.m
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWMenuViewController.h"
#import "TWMenuCell.h"

@interface TWMenuViewController (){
    NSArray *_accounts;
    __weak IBOutlet UITableView *_menuTable;
}

@end

@implementation TWMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated{
    [self loadAccounts];
    [_menuTable reloadData];
}
- (IBAction)aboutClicked:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadAccounts{
    _accounts = [[TWStorage shared] twitterAccounts];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TWMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ACAccount *account = [_accounts objectAtIndex:indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"@%@", account.username];
    cell.checkLabel.hidden = ![account.username isEqualToString:[TWStorage shared].selectedAccount.username];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ACAccount *account = [_accounts objectAtIndex:indexPath.row];
    if ([[TWStorage shared].selectedAccount.username isEqualToString:account.username])
    {
        return;
    }
    
    [TWStorage shared].selectedAccount = account;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kAccountSwitchNotification
     object:self];
    [_menuTable reloadData];
}


@end
