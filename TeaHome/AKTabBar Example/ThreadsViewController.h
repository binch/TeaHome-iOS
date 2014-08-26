//
//  ThreadsViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-10.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadsViewController : UITableViewController

@property(nonatomic,assign) int bid;//板块id
@property(nonatomic,strong) NSString *name;//板块名
@property(nonatomic,strong) NSString *his_username;//板块名

@property(nonatomic,assign) int type;//0 board, 1 favor, 2 user threads
@property(nonatomic,strong) NSMutableArray *threads;

@end
