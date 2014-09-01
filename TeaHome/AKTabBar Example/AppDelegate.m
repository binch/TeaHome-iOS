//
//  AppDelegate.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 03/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import "AppDelegate.h"
#import "AKTabBarController.h"

#import "FirstViewController.h"
#import "FourthViewController.h"
#import "QuestionsViewController.h"
#import "HomeViewController.h"
#import "BoardsViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

#import "CartItem.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [ShareSDK registerApp:@"2c53a0305290"];
    
    [ShareSDK connectWeChatWithAppId:@"wx2ffd4bce6eb8488d"
                           wechatCls:[WXApi class]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      UnDefined,Username,
      UnDefined,Password,
      nil]];
    
    self.login_from_home = NO;
    
    self.username = [[[NSUserDefaults standardUserDefaults] objectForKey:Username] isEqualToString:UnDefined]
    ? @""
    : [[NSUserDefaults standardUserDefaults] objectForKey:Username];
    self.password = [[[NSUserDefaults standardUserDefaults] objectForKey:Password] isEqualToString:UnDefined]
    ? @""
    : [[NSUserDefaults standardUserDefaults] objectForKey:Password];

    self.deviceId = @"";
    if (![self.username isEqualToString:@""]){
        self.userSettings = [[NSUserDefaults standardUserDefaults] objectForKey:self.username];
    }
    if (self.userSettings == nil) {
        self.userSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSMutableDictionary dictionary],CartItems,
                             UnDefined,NameSetting,
                             UnDefined,AddrSetting,
                             UnDefined,PhoneSetting,
                             [NSString stringWithFormat:@"%d",kPayMethodCOD],PayMethodSetting,
                             nil];
    }
    
    if ([[Utils fetchDataFromUserDefaults:CartItems] isKindOfClass:[NSMutableDictionary class]]) {
        self.cartsDic = [Utils fetchDataFromUserDefaults:CartItems];
    }else{
        self.cartsDic = [NSMutableDictionary dictionary];
    }
    
    //判断当前网络
    //BOOL isreach = [[Reachability reachabilityWithHostName:TeaHome_HOST] isReachable];
    //if (isreach) {
    //    self.networkIsReachable = YES;
    //}else{
    //    self.networkIsReachable = NO;
    //}
    self.networkIsReachable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    [[Reachability reachabilityWithHostName:TeaHome_HOST] startNotifier];
    
    
    //设置uinavigationbar的属性
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    
    // If the device is an iPad, we make it taller.
    _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];
    
    [_tabBarController setTextColor:[UIColor greenColor]];
    [_tabBarController setIconColors:@[[UIColor greenColor], [UIColor greenColor]]];
    
    
    UITableViewController *tableViewController = [[FirstViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    BoardsViewController *svc = [[BoardsViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:svc];
    
    QuestionsViewController *qvc = [[QuestionsViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:qvc];
    
    FourthViewController *fvc = [[FourthViewController alloc] init];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:fvc];
    
//    FifthViewController *fifvc = [[FifthViewController alloc] init];
//    UINavigationController *nav5 = [[UINavigationController alloc] initWithRootViewController:fifvc];
    UINavigationController *nav5;

    HomeViewController *fifvc = [[HomeViewController alloc] init];
    nav5 = [[UINavigationController alloc] initWithRootViewController:fifvc];

    
    [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:
                                               navigationController,
                                               nav2,
                                               nav3,
                                               nav4,
                                           nav5,nil]];
    
    [_window setRootViewController:_tabBarController];
    [_window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    

    self.timer = [NSTimer timerWithTimeInterval:fetch_atmessages_time_inteval target:self selector:@selector(fetchAtmessages) userInfo:nil repeats:YES];
    [self.timer fire];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(userInfo) {
        
        [self handleRemoteNotification:application userInfo:userInfo];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadAtmessagesNotification:) name:kReadAtmessageNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}


-(NSString *)timeAgo:(NSDate*) date {
    NSDate *todayDate = [NSDate date];
    
    double ti = [date timeIntervalSinceNow];
    ti = ti * -1;
    if (ti < 1) {
        return @"1秒前";
    } else if (ti < 60) {
        return @"1分钟前";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d分钟前", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d小时前", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d天前", diff];
    } else if (ti < 31556926) {
        int diff = round(ti / 60 / 60 / 24 / 30);
        return [NSString stringWithFormat:@"%d月前", diff];
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30 / 12);
        return [NSString stringWithFormat:@"%d年前", diff];
    }
}

#pragma mark -- 定时获取通知
-(void)fetchAtmessages
{
    if (self.networkIsReachable == NO) {
        return;
    }
    if (![TeaHomeAppDelegate.username isEqualToString:@""]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_user_atmessages_cmd,TeaHomeAppDelegate.username];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
              if (data != nil) {
                  NSError *error;
                  id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                  if (json != nil) {
                      NSArray *messages = [json objectForKey:@"atmessages"];
                      TeaHomeAppDelegate.atMessages = [NSArray arrayWithArray:messages];
                      if ([TeaHomeAppDelegate.atMessages count] > 0) {
                          self.unreadMessages = [NSMutableArray array];
                          self.readMessages = [NSMutableArray array];
                          for (NSDictionary *message in TeaHomeAppDelegate.atMessages) {
                              NSString *readStatus = [message objectForKey:@"read"];
                              if ([readStatus isEqualToString:message_status_unread]) {
                                  [self.unreadMessages addObject:message];
                              }else{
                                  [self.readMessages addObject:message];
                              }
                          }
                          [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self.unreadMessages count]];
                          [self setItemBageNumberView];
                      }
                  }
              }
        }];
    }
}

#pragma mark -- network status changed notification 
-(void)handleNetworkStatusChanged:(NSNotification*)note
{
    BOOL isreach = [[Reachability reachabilityWithHostName:TeaHome_HOST] isReachable];
    if (isreach) {
        self.networkIsReachable = YES;
    }else{
        self.networkIsReachable = NO;
    }
    self.networkIsReachable = YES;
}

#pragma mark -- 设置tabbar下方的未读通知数
-(void)setItemBageNumberView
{
    UIButton *v = (UIButton *)[self.tabBarController.tabBar viewWithTag:10086];
    if (v) {
        if ([TeaHomeAppDelegate.unreadMessages count] > 0) {
            [v setTitle:[NSString stringWithFormat:@"%d",[TeaHomeAppDelegate.unreadMessages count]] forState:UIControlStateNormal];
        }else{
            [v removeFromSuperview];
        }
    }else{
        if ([TeaHomeAppDelegate.unreadMessages count] > 0) {
            UIImage *redSpotImage = [UIImage imageNamed:@"red_spot"];
            UIButton *numberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            numberBtn.tag = 10086;
            numberBtn.frame = CGRectMake(self.tabBarController.tabBar.bounds.size.width - 20, 2, 20, 20);
            [numberBtn setBackgroundImage:redSpotImage forState:UIControlStateNormal];
            [numberBtn setTitle:[NSString stringWithFormat:@"%d",[TeaHomeAppDelegate.unreadMessages count]] forState:UIControlStateNormal];
            [numberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            numberBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.tabBarController.tabBar insertSubview:numberBtn atIndex:0];
            self.tabBarController.tabBar.opaque = YES;
        }
    }
}

#pragma mark -- 通知中心点击未读通知的处理
-(void)handleReadAtmessagesNotification:(NSNotification *)note
{
    NSDictionary *message = note.object;
    [self.unreadMessages removeObject:message];
    [self.readMessages addObject:message];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self.unreadMessages count]];
}


-(void)applicationWillTerminate:(UIApplication *)application
{
    [self.timer invalidate];
}

#pragma mark -- 注册远程通知服务
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceId = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"my device token is %@",deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error is %@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:application userInfo:userInfo];
}

- (void)handleRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    [self fetchAtmessages];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshNoteCenterViewNotification object:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //    NSString *strUrl = @"http://dajdklajdka?";
    //    url = [NSURL URLWithString:strUrl];
    
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)[QQAPIDemoEntry class]];
#endif
    
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Where from" message:url.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        //[alertView show];
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)[QQAPIDemoEntry class]];
#endif
    
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

@end
