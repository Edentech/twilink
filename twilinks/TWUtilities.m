//
//  TWUtilities.m
//  Twinks
//
//  Created by Matthew Mondok on 9/27/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWUtilities.h"

@implementation TWUtilities

+(NSString *) makeDateKeyForUser{    
    return [NSString stringWithFormat:@"%@_DATE_KEY", [TWStorage shared].selectedAccount.username];
}

@end
