//
//  CartItem.m
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "CartItem.h"

@implementation CartItem

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.product = [aDecoder decodeObjectForKey:@"product"];
        self.mount = [aDecoder decodeIntForKey:@"mount"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.product forKey:@"product"];
    [aCoder encodeInt:self.mount forKey:@"mount"];
}

@end
