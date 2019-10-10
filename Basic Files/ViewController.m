//
//  ViewController.m
//
//  Created by dyf on 17/5/27.
//  Copyright © 2017 dyf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//@property (nonatomic, strong) DYFDisplayViewController *dvc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)loadBaidu:(id)sender {
    [self pushWithUrl:@"https://www.baidu.com/"];
}

- (IBAction)loadMyGithub:(id)sender {
    [self pushWithUrl:@"https://github.com/dgynfi/"];
}

- (void)pushWithUrl:(NSString *)urlStr {
   // self.dvc.urlString = urlStr;
    //[self.navigationController pushViewController:self.dvc animated:YES];
}

@end
