//
//  PostThreadViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-25.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPopupView.h"


typedef NS_ENUM(int, kPostStyle) {
    kPostStyleThread = 1,
    kPostStyleReply,
    kPostStyleQuestion,
    kPostStyleAnswer,
    };

#define kPostThreadSuccessNotification @"kPostThreadSuccessNotification"
#define kPostQuestionSuccessNotification @"kPostQuestionSuccessNotification"

@interface PostThreadViewController : UIViewController<UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDataDelegate>

@property(nonatomic,assign) kPostStyle style;

@property(nonatomic,assign) int postId;

@property(nonatomic,strong)  UITextField *titeLabel;
@property(nonatomic,strong)  UITextView *contentView;
@property(nonatomic,strong)  UIButton *addImageBtn;


@property(nonatomic,strong) UIScrollView *imageView;

@property(nonatomic,strong) NSArray *questionCats;


@property(nonatomic,strong) NSMutableArray *uploadImages;//上传后接受到的图片名称;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) NSMutableData *recievedData;

//-(IBAction)closeKeyboard:(id)sender;

@property(nonatomic,strong) NSString *nickname;
@end
