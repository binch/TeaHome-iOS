//
//  CartItem.h
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartItem : NSObject<NSCoding>

@property(nonatomic,strong) NSDictionary *product;
@property(nonatomic,assign) int mount;

@end
