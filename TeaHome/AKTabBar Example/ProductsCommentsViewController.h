//
//  ProductsCommentsViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductsCommentsViewController : UITableViewController

@property(nonatomic,strong) NSArray *comments;
@property(nonatomic,assign) int pid;

@end
