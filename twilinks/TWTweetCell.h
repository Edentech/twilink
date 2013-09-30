//
//  TWTweetCell.h
//  Twilinks
//
//  Created by Matthew Mondok on 9/26/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWTweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;

@property (weak, nonatomic) IBOutlet UITextView *titleText;

@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@end
