//
//  LoginViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"
#import <TencentOpenAPI/TencentMessageObject.h>

#define login_cmd @"login_user"

@interface LoginViewController () <TencentSessionDelegate>

@end

@implementation LoginViewController

#pragma mark - TencentLoginDelegate

- (void)tencentDidLogin
{
    [self.oauth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{

}

- (void)tencentDidNotNetWork
{

}


- (void)responseDidReceivedNotify:(NSNotification *)notify
{
    APIResponse *response = [[notify userInfo] objectForKey:kResponse];
    NSString    *messsage = [[notify userInfo] objectForKey:kMessage];
    [self responseDidReceived:response forMessage:messsage];
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogout
{

}

- (void)getUserInfoResponse:(APIResponse*) response
{
    NSDictionary *dic = response.jsonResponse;
    NSString *nickname = [dic objectForKey:@"nickname"];
    NSString *openid = self.oauth.openId;
    
    NSString *str = [NSString stringWithFormat:@"%@%@",CMD_URL,@"reg_user"];
    str = [str stringByAppendingFormat:@"&username=%@",[openid substringToIndex:30]];
    str = [str stringByAppendingFormat:@"&password=%@",@"qqpassword"];
    str = [str stringByAppendingFormat:@"&mobile=%@",@"11111111111"];
    
    id jsonObj = [Utils getJsonDataFromWeb:str];
    if (jsonObj != nil) {
        NSString *result = [jsonObj objectForKey:@"ret"];
        if ([result isEqualToString:@"ok"]) {
            [Utils showAlertViewWithMessage:@"注册成功."];
            TeaHomeAppDelegate.username = self.usernameField.text;
            TeaHomeAppDelegate.password = self.passwordField.text;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //[Utils showAlertViewWithMessage:@"用户名重复，请使用其他用户名."];
            
        }
    }else{
        [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
    }
    
    str = [NSString stringWithFormat:@"%@%@",CMD_URL,login_cmd];
    str = [str stringByAppendingFormat:@"&username=%@",[openid substringToIndex:30]];
    str = [str stringByAppendingFormat:@"&password=%@",@"qqpassword"];
    str = [str stringByAppendingFormat:@"&deviceid=%@",TeaHomeAppDelegate.deviceId];
    NSLog(@"%@", str);
    jsonObj = [Utils getJsonDataFromWeb:str];
    if (jsonObj != nil) {
        NSString *result = [jsonObj objectForKey:@"ret"];
        if ([result isEqualToString:@"ok"]) {
            [Utils showAlertViewWithMessage:@"登录成功."];
            TeaHomeAppDelegate.username = [openid substringToIndex:30];
            TeaHomeAppDelegate.password = @"qqpassword";
            [TeaHomeAppDelegate.timer fire];
            [[NSUserDefaults standardUserDefaults]  setObject:TeaHomeAppDelegate.username forKey:Username];
            [[NSUserDefaults standardUserDefaults] setObject:TeaHomeAppDelegate.password forKey:Password];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self backAction];
        }else{
            [Utils showAlertViewWithMessage:@"登录失败，请重试."];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"网络链接出错，请稍后再试."
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}

- (void)analysisResponse:(NSNotification *)notify
{
    if (notify)
    {
        APIResponse *response = [[notify userInfo] objectForKey:kResponse];
        if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode)
        {
            NSMutableString *str=[NSMutableString stringWithFormat:@""];
            for (id key in response.jsonResponse)
            {
                [str appendString: [NSString stringWithFormat:@"%@:%@\n",key,[response.jsonResponse objectForKey:key]]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作成功" message:[NSString stringWithFormat:@"%@",str]
                                  
                                                           delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            NSString *errMsg = [NSString stringWithFormat:@"errorMsg:%@\n%@", response.errorMsg, [response.jsonResponse objectForKey:@"msg"]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败" message:errMsg delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
            [alert show];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (TeaHomeAppDelegate.login_from_home == NO) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    self.oauth = [[TencentOAuth alloc] initWithAppId:@"1102093062" andDelegate:self];
    self.oauth.redirectURI = @"teahome://login/";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analysisResponse:) name:kGetUserInfoResponse object:self.oauth];

    self.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    //[self.navigationItem setHidesBackButton:YES];
    
    self.usernameField.placeholder = @"字母，数字和下划线";
    self.passwordField.secureTextEntry = YES;
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    
    UIBarButtonItem *registItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(registAction:)];
    self.navigationItem.rightBarButtonItem = registItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![TeaHomeAppDelegate.username isEqualToString:@""]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)loginAction:(id)sender
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
    
    if ([self.usernameField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"用户名为空."];
        return;
    }
    
    if ([self.passwordField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"密码为空."];
        return;
    }
    
    
    NSString *str = [NSString stringWithFormat:@"%@%@",CMD_URL,login_cmd];
    str = [str stringByAppendingFormat:@"&username=%@",self.usernameField.text];
    str = [str stringByAppendingFormat:@"&password=%@",self.passwordField.text];
    str = [str stringByAppendingFormat:@"&deviceid=%@",TeaHomeAppDelegate.deviceId];
    NSLog(@"%@", str);
    id jsonObj = [Utils getJsonDataFromWeb:str];
    if (jsonObj != nil) {
        NSString *result = [jsonObj objectForKey:@"ret"];
        if ([result isEqualToString:@"ok"]) {
            [Utils showAlertViewWithMessage:@"登录成功."];
            TeaHomeAppDelegate.username = self.usernameField.text;
            TeaHomeAppDelegate.password = self.passwordField.text;
            [TeaHomeAppDelegate.timer fire];
            [[NSUserDefaults standardUserDefaults]  setObject:TeaHomeAppDelegate.username forKey:Username];
            [[NSUserDefaults standardUserDefaults] setObject:TeaHomeAppDelegate.password forKey:Password];
            [[NSUserDefaults standardUserDefaults] synchronize];
            TeaHomeAppDelegate.login_from_home = NO;
            [self backAction];
        }else{
            [Utils showAlertViewWithMessage:@"登录失败，请重试."];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"网络链接出错，请稍后再试."
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)registAction:(id)sender
{
    RegistViewController *rvc = [[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil];
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark -- uitextfield delegate method
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.usernameField]) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            if (rect.size.height > 480) {
                rect.origin.y -= 20;
            }else{
                rect.origin.y -= 108;
            }
            self.view.frame = rect;
        }];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.usernameField isEqual:textField]) {
        [self.passwordField becomeFirstResponder];
    }
    if ([self.passwordField isEqual:textField]) {
        [self loginAction:nil];
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


- (IBAction)qqLogin:(id)sender {
    NSArray *permissions = [NSArray arrayWithObjects:@"all", nil];
    [self.oauth authorize:permissions inSafari:NO];
}
@end
