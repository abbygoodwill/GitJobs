//
//  ViewController.m
//  Github Jobs
//
//  Created by Abby Goodwill on 6/19/14.
//  Copyright (c) 2014 Abby Goodwill. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *jobs;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *endpoint = [[NSBundle bundleForClass: [self class]] infoDictionary][@"GithubJobsEndpoint"];
    NSURL *url = [NSURL URLWithString: [endpoint stringByAppendingString: @"?description=ios&location=NY"]];
    
    NSURLSessionDataTask *jobTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An error occured"
                                                                message: error.localizedDescription delegate: nil cancelButtonTitle: @"Meh" otherButtonTitles: nil];
                
                [alert show];
            });
            return;
        }
        
        NSError *jsonError = nil;
        
        self.jobs = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &jsonError];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [SVProgressHUD showSuccessWithStatus: [NSString stringWithFormat: @"%lu jobs fetched", (unsigned long)[self.jobs count]]];
            [self.tableView reloadData];
        });
        
    }];
    
    [SVProgressHUD showWithStatus: @"Fetching jobs..."];
    [jobTask resume];
    
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.jobs[indexPath.row][@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *jobUrl = [NSURL URLWithString: self.jobs[indexPath.row][@"url"]];
    [[UIApplication sharedApplication] openURL: jobUrl];
}

@end
