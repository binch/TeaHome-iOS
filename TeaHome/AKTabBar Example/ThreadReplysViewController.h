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
@property(nonatomic,assign) int favorCount;
@property(nonatomic,assign) int likeCount;
@property(nonatomic,strong) UIImageView *likeView;
@property(nonatomic,strong) UIImageView *favView;
@property(nonatomic,strong) UILabel *favorLabel;
@property(nonatomic,strong) UILabel *likeLabel;
@property(nonatomic,assign) bool get_data;
@property(nonatomic,assign) bool like;
@property(nonatomic,assign) bool favor;
@property(nonatomic,assign) bool fav_state;
@property(nonatomic,assign) bool like_state;
@property(nonatomic,strong) UIImageView *shareView;
@end
