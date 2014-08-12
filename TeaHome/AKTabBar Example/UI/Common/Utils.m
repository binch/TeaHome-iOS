//
//  Utils.m
//  TeaHome
//
//  Created by andylee on 14-6-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+(id)getJsonDataFromWeb:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data != nil) {
        NSError *error;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if ([jsonObj isKindOfClass:[NSDictionary class]] ||
            [jsonObj isKindOfClass:[NSArray class]]) {
            return jsonObj;
        }
        return nil;
    }else{
        return nil;
    }
}

+(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                        message:message
                                        delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
    [alert performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:1];
}


+(CGFloat)heightForString:(NSString *)value withWidth:(CGFloat)width withFont:(CGFloat)fontSize
{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize strSize = [value boundingRectWithSize:CGSizeMake(width, 0)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:dic
                                         context:nil].size;
    return strSize.height;
}

+(NSString *)getHtmlStringFromString:(NSString *)origin
{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)origin ,
                                            NULL,
                                            (CFStringRef)@"!*'@()[]:;&=+$,/?%#",
                                            kCFStringEncodingUTF8));
    return outputStr;
}

+(id)fetchDataFromUserDefaults:(NSString *)settingKey
{
    if ([settingKey isEqualToString:PayMethodSetting]) {
        if ([[TeaHomeAppDelegate.userSettings objectForKey:settingKey] intValue] == kPayMethodAlipay) {
            return @"支付宝";
        }else{
            return @"货到付款";
        }
    }
    return [TeaHomeAppDelegate.userSettings objectForKey:settingKey];
}

+(void)saveDataToUserDefaults:(NSString *)settingKey withValue:(id)settingValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([settingKey isEqualToString:PayMethodSetting]) {
        if ([settingValue isEqualToString:[NSString stringWithFormat:@"%d", kPayMethodAlipay]]) {
            [TeaHomeAppDelegate.userSettings setObject:[NSString stringWithFormat:@"%d",kPayMethodAlipay] forKey:settingKey];
        }else{
            [TeaHomeAppDelegate.userSettings setObject:[NSString stringWithFormat:@"%d",kPayMethodCOD] forKey:settingKey];
        }
    }else{
        [TeaHomeAppDelegate.userSettings setObject:settingValue forKey:settingKey];
    }
    
    [defaults setObject:TeaHomeAppDelegate.userSettings forKey:TeaHomeAppDelegate.username];
    [defaults synchronize];
}

//16进制颜色(html颜色值)字符串转为UIColor
+(UIColor *) hexStringToColor: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 charactersif ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appearsif ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end
