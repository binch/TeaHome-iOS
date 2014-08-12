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
@property(nonatomic,strong) NSMutableArray *threads;

@end
