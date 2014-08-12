//
//  UserInfoDetailViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "JMStaticContentTableViewController.h"

#define get_userinfo_cmd @"get_userinfo"
#define update_userinfo_cmd @"update_userinfo"

@interface UserInfoDetailViewController : UITableViewController<UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,strong) NSDictionary *userInfo;
@end
