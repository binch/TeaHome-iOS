//
//  CartDetailViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property(nonatomic,strong) UITextField * nameTF;
@property(nonatomic,strong) UITextField * phoneTF;
@property(nonatomic,strong) UITextField * addrTF;

@property(nonatomic,strong) UITableView *cartItemsView;
@property(nonatomic,strong) NSArray *cartItems;

@end
