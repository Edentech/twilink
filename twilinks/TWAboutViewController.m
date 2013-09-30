//
//  TWAboutViewController.m
//  twilink
//
//  Created by Matthew Mondok on 9/29/13.
//  Copyright (c) 2013 Edentech Solutions Group, LLC. All rights reserved.
//

#import "TWAboutViewController.h"

@interface TWAboutViewController (){
    
    __weak IBOutlet UINavigationBar *_navigationBar;
}

@end

@implementation TWAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    if ([_navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        
        UIImage *image = [UIImage imageNamed:@"logo"];
        [_navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)logoTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.edentech.net"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
