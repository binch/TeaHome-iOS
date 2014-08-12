//
//  LoginViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>


@property(nonatomic,strong) IBOutlet UITextField *usernameField;
@property(nonatomic,strong) IBOutlet UITextField *passwordField;

@property(nonatomic,strong) IBOutlet UIButton *loginBtn;
-(IBAction)loginAction:(id)sender;

-(IBAction)registAction:(id)sender;
-(IBAction)closeKeyboard:(id)sender;
@end
