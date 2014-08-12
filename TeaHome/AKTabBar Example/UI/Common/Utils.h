//
//  Utils.h
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(id)getJsonDataFromWeb:(NSString *)urlStr;
+(void)showAlertViewWithMessage:(NSString *)message;
+(CGFloat)heightForString:(NSString *)value withWidth:(CGFloat)width withFont:(CGFloat)fontSize;
+(NSString *)getHtmlStringFromString:(NSString *)origin;


+(id)fetchDataFromUserDefaults:(NSString *)key;
+(void)saveDataToUserDefaults:(NSString *)key withValue:(id)value;

+(UIColor *) hexStringToColor: (NSString *) stringToConvert;
@end
