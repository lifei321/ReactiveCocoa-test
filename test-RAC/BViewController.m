//
//  BViewController.m
//  test-RAC
//
//  Created by lzh on 2016/12/28.
//  Copyright © 2016年 lzh. All rights reserved.
//

#import "BViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "BViewModel.h"

@interface BViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@property (nonatomic, strong) NSString *text;

@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatViewModel];
    
}

- (void)creatViewModel {
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view resignFirstResponder];
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

@end
