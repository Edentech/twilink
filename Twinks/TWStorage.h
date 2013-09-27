//
//  TWStorage.h
//  Twinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWStorage : NSObject

+(TWStorage *)shared;

-(NSArray *) twitterAccounts;

@property (nonatomic, retain) ACAccount *selectedAccount;

@end
