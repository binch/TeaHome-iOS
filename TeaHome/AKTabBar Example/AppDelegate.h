//
//  AppDelegate.h
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 03/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

//#import "UserSetting.h"
@class AKTabBarController;

typedef NS_ENUM(int, kPayMethod) {
    kPayMethodAlipay = 1,//支付宝
    kPayMethodCOD,
};

#define TeaHomeAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define Username @"Username"
#define Password @"Password"

#define CartItems @"CartItems"
#define NameSetting @"NameSetting"
#define AddrSetting @"AddrSetting"
#define PhoneSetting @"PhoneSetting"
#define PayMethodSetting @"PayMethodSetting"
#define UnDefined @"未设置"

#define kReadAtmessageNotification @"kReadAtmessageNotification"
#define kRefreshNoteCenterViewNotification @"kRefreshNoteCenterViewNotification"

#define navigation_bar_color @"#82cf23"
#define tabbar_bar_color @"#93d73e"
#define view_back_color @"#f4f4f4"

#define get_user_atmessages_cmd @"get_user_atmessages"
#define fetch_atmessages_time_inteval 10 * 60

#define message_status_unread @"unread"
#define message_status_read @"read"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AKTabBarController *tabBarController;

@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *deviceId;

@property(nonatomic,assign) bool login_from_home;

@property(nonatomic,strong) NSMutableDictionary *userSettings;
@property(nonatomic,strong) NSMutableDictionary *cartsDic;

@property(nonatomic,strong) NSTimer *timer;//定时获取用户的通知
@property(nonatomic,strong) NSArray *atMessages;
@property(nonatomic,strong) NSMutableArray *unreadMessages;
@property(nonatomic,strong) NSMutableArray *readMessages;

-(void)setItemBageNumberView;

@property(nonatomic,assign) BOOL networkIsReachable;
//-(void)handleNetworkStatusChanged;
@end
