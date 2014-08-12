//
//  RegistViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic,strong) IBOutlet UITextField *usernameField;
@property(nonatomic,strong) IBOutlet UITextField *passwordField;
@property(nonatomic,strong) IBOutlet UITextField *confirmField;
@property(nonatomic,strong) IBOutlet UITextField *mobileField;

@property(nonatomic,strong) IBOutlet UIButton *registBtn;
-(IBAction)registnAction:(id)sender;
-(IBAction)closeKeyboard:(id)sender;


@end
