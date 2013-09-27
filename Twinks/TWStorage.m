//
//  TWStorage.m
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWStorage.h"

@implementation TWStorage

@synthesize selectedAccount;

+ (TWStorage *)shared
{
    static dispatch_once_t onceQueue;
    static TWStorage *twStorage = nil;
    
    dispatch_once(&onceQueue, ^{ twStorage = [[self alloc] init]; });
    return twStorage;
}

- (id)init
{
    self = [super init];
    if (self) {
        // set first account
        [self twitterAccounts];
    }
    return self;
}

-(NSArray *) twitterAccounts{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [account accountsWithAccountType:accountType];
    if (!selectedAccount){
        selectedAccount = [accounts firstObject];
    }
    return accounts;
}

@end
