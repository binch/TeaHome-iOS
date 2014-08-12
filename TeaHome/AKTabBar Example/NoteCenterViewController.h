//
//  NoteCenterViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-28.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCenterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UISegmentedControl *seg;

@property(nonatomic,strong) UITableView *tableView;

@end
