//
//  AnswersViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define update_answer_cmd @"get_question"
#define accepted_answer_cmd @"accept_answer"

@interface AnswersViewController : UITableViewController

@property(nonatomic,strong) NSArray *answers;

@property(nonatomic,strong) NSDictionary *question;

@property(nonatomic,assign) int qid;

@end
