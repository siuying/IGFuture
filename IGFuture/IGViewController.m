//
//  IGViewController.m
//  IGFuture
//
//  Created by Chong Francis on 13年4月2日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGViewController.h"
#import "IGFuture.h"

@interface IGViewController ()

@end

@implementation IGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[];
    self.tableView.dataSource = self;
    
    IGFuture* future = [[IGFuture alloc] initWithBlock:^id{
        [NSThread sleepForTimeInterval:3.0];
        return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    }];

    future.completionBlock = ^(NSArray* data) {
        NSLog(@"load completed!");
        self.data = data;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.data objectAtIndex:[indexPath row]];
    return cell;
}

@end
