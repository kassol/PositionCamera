//
//  FirstViewController.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/15.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "FirstViewController.h"
#import "RegisterInfo.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoLabel.text = @"等待注册...";
    [NSThread detachNewThreadSelector:@selector(scanRegisterInfo) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)scanRegisterInfo {
    while (![[RegisterInfo sharedRegisterInfo] isRegisterEnd]) {
        usleep(30000);
    }
    self.infoLabel.text = [[RegisterInfo sharedRegisterInfo] ErrorInfo];
}
- (IBAction)startButtonDidTouch:(id)sender {
    if ([[RegisterInfo sharedRegisterInfo] isRegisterSuccess]) {
        [self performSegueWithIdentifier:@"MainSegue" sender:self];
    }
}

@end
