//
//  RegistViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "RegistViewController.h"


#define req_user_cmd @"reg_user"


@interface RegistViewController ()

@end

@implementation RegistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.usernameField.placeholder = @"字母，数字和下划线";
    self.mobileField.placeholder = @"您的手机号，用以取回密码";
    self.passwordField.secureTextEntry = YES;
    self.confirmField.secureTextEntry = YES;
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmField.delegate = self;
    self.mobileField.delegate = self;
    
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.confirmField.returnKeyType = UIReturnKeyNext;
    self.mobileField.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)registnAction:(id)sender
{
    [self.passwordField resignFirstResponder];
    [self.confirmField resignFirstResponder];
    [self.mobileField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
    
    if ([self.usernameField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"用户名为空."];
        return;
    }else{
        //正则匹配_,abc,122
        NSString *regex = @"[0-9a-zA-Z_]*";
        NSPredicate *predict = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL isMatch = [predict evaluateWithObject:self.usernameField.text];
        if (!isMatch) {
            [Utils showAlertViewWithMessage:@"用户名包含非法字符."];
            return;
        }
    }
    
    if ([self.passwordField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"密码为空."];
        return;
    }else{
        if (![self.passwordField.text isEqualToString:self.confirmField.text]) {
            [Utils showAlertViewWithMessage:@"两次输入密码不一致."];
            return;
        }
    }
    
    if ([self.mobileField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"手机号码为空."];
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@%@",CMD_URL,req_user_cmd];
    str = [str stringByAppendingFormat:@"&username=%@",self.usernameField.text];
    str = [str stringByAppendingFormat:@"&password=%@",self.passwordField.text];
    str = [str stringByAppendingFormat:@"&mobile=%@",self.mobileField.text];
    
    id jsonObj = [Utils getJsonDataFromWeb:str];
    if (jsonObj != nil) {
        NSString *result = [jsonObj objectForKey:@"ret"];
        if ([result isEqualToString:@"ok"]) {
            [Utils showAlertViewWithMessage:@"注册成功."];
            TeaHomeAppDelegate.username = self.usernameField.text;
            TeaHomeAppDelegate.password = self.passwordField.text;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [Utils showAlertViewWithMessage:@"用户名重复，请使用其他用户名."];
           
        }
    }else{
        [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
    }
}

#pragma mark -- uitextfield delegate method
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if ([textField isEqual:self.usernameField]) {
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rect = self.view.frame;
//            if (rect.size.height > 480) {
//                rect.origin.y -= 20;
//            }else{
//                rect.origin.y -= 54;
//            }
//            
//            self.view.frame = rect;
//        }];
//    }
//    if ([textField isEqual:self.passwordField]) {
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rect = self.view.frame;
//            rect.origin.y -= 20;
//            self.view.frame = rect;
//        }];
//    }
    if ([self.confirmField isEqual:textField]) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            if (rect.size.height > 480) {
                rect.origin.y -= 40;
            }else{
                rect.origin.y -= 94;
            }
            self.view.frame = rect;
        }];
    }
//    if ([self.mobileField isEqual:textField]){
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rect = self.view.frame;
//            rect.origin.y -= 20;
//            self.view.frame = rect;
//        }];
//    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    }else if ([textField isEqual:self.passwordField]){
        [self.confirmField becomeFirstResponder];
    }else if ([textField isEqual:self.confirmField]){
        [self.mobileField becomeFirstResponder];
    }else if ([textField isEqual:self.mobileField]){
         [self registnAction:nil];
    }

    return YES;
}

-(IBAction)closeKeyboard:(id)sender
{
    //点击背景，收起数字键盘
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
}

@end
