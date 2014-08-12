//
//  OrderDetailViewController.h
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

//订单状态
#define order_status_new @"new"  //新建
#define order_status_paid @"paid"  //已付款
#define order_status_shipped @"shipped"  //已发货
#define order_status_completed @"completed"  //已完成
#define order_status_cancelled @"cancelled"  //已取消

@interface OrderDetailViewController : UIViewController

@property(nonatomic,strong) NSDictionary *order;
@property(nonatomic,assign) int orderId;

@end
