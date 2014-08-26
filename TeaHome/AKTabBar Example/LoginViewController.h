//
//  LoginViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

//response
#define kCGIRequest @"kTencentCGIRequest"
#define kResponse @"kResponse"
#define kTencentOAuth @"oauth"
#define kUIViewController @"UIViewController"
#define kTencentRespObj @"kTencentRespObj"
//qzone
#define kGetUserInfoResponse @"getUserInfoResponse"
#define kAddShareResponse @"addShareResponse"
#define kUploadPicResponse @"uploadPicResponse"
#define kGetListAlbumResponse @"getListResponse"
#define kGetListPhotoResponse @"getListPhotoResponse"
#define kAddTopicResponse @"addTopicResponse"
#define kChangePageFansResponse @"changePageFansResponse"
#define kAddAlbumResponse @"kAddAlbumResponse"
#define kAddOneBlogResponse @"kAddOneBlogResponse"
#define kSetUserHeadPicResponse @"kSetUserHeadPicResponse"
#define kGetVipInfoResponse @"kGetVipInfoResponse"
#define kGetVipRichInfoResponse @"kGetVipRichInfoResponse"
#define kSendStoryResponse @"kSendStoryResponse"
#define kCheckPageFansResponse @"kCheckPageFansResponse"

//delagate

//login
#define kLoginSuccessed @"loginSuccessed"
#define kLoginFailed    @"loginFailed"
//openApiResponse
#define kResponseDidReceived @"kResponseDidReceived"
#define kMessage  @"kMessage"


@interface LoginViewController : UIViewController<UITextFieldDelegate>

- (IBAction)qqLogin:(id)sender;

@property(nonatomic,strong) IBOutlet UITextField *usernameField;
@property(nonatomic,strong) IBOutlet UITextField *passwordField;

@property(nonatomic,strong) IBOutlet UIButton *loginBtn;
-(IBAction)loginAction:(id)sender;

-(IBAction)registAction:(id)sender;
-(IBAction)closeKeyboard:(id)sender;

@property (nonatomic, retain)TencentOAuth *oauth;

@end
