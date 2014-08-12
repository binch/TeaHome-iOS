//
//  ThreadReplysViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define update_comment_cmd @"get_thread"

@interface ThreadReplysViewController : UITableViewController

@property(nonatomic,strong) NSString *name;

@property(nonatomic,strong) NSArray *comments;

@property(nonatomic,strong) NSDictionary *thread;

@property(nonatomic,assign) int tid;
@end
