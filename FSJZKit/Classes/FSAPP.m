//
//  FSAPP.m
//  myhome
//
//  Created by FudonFuchina on 2017/9/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAPP.h"
#import "FSAppConfig.h"
#import <FSKit.h>

@implementation FSAPP

/*
 @{table:message}
 */
+ (void)addMessage:(NSString *)message table:(NSString *)table{
    if (!([message isKindOfClass:NSString.class] && message.length)) {
        return;
    }
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return;
    }
    NSString *json = [self objectForKey:_table_message_ud_key];
    NSDictionary *list = [FSKit objectFromJSonstring:json];
    if ([list isKindOfClass:NSDictionary.class] && list.count) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:list];
        [dic setObject:message forKey:table];
        NSString *js = [FSKit jsonStringWithObject:dic];
        [self setObject:js forKey:_table_message_ud_key];
    }else{
        NSString *js = [FSKit jsonStringWithObject:@{table:message}];
        [self setObject:js forKey:_table_message_ud_key];
    }
    [self setObject:message forKey:_message_newest_ud_key];
}

static NSString *_table_message_ud_key = @"_table_message_ud_key";
static NSString *_message_newest_ud_key = @"_message_newest_ud_key";
+ (NSString *)messageForTable:(NSString *)table{
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return nil;
    }
    NSString *value = [self objectForKey:_table_message_ud_key];
    NSDictionary *dic = [FSKit objectFromJSonstring:value];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [dic objectForKey:table];
    }
    return nil;
}

+ (NSString *)theNewestMessage{
    return [self objectForKey:_message_newest_ud_key];
}

+ (void)setObject:(NSString *)instance  forKey:(NSString *)key{
    [FSAppConfig saveObject:instance forKey:key];
}

+ (NSString *)objectForKey:(NSString *)key{
    return [FSAppConfig objectForKey:key];
}

+ (void)removeObjectForKey:(NSString *)key{
    [FSAppConfig removeObjectForKey:key];
}

CGFloat _fs_statusAndNavigatorHeight(void){
    if (_fs_isIPhoneX()) {
        return 44 + 44;
    }
    return 20 + 44;
}

CGFloat _fs_tabbarHeight(void){
    if (_fs_isIPhoneX()) {
        return 49 + 34;
    }
    return 49;
}

CGFloat _fs_tabbarBottomMoreHeight(void){
    if (_fs_isIPhoneX()) {
        return 34;
    }
    return 0;
}

BOOL _fs_isIPhoneX (){
    if (@available(iOS 11.0, *)) {
        static dispatch_once_t onceToken;
        static BOOL result = NO;
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if (window) {
            dispatch_once(&onceToken, ^{
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                BOOL landscape = (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    if (!landscape && window.safeAreaInsets.top > 0 && window.safeAreaInsets.bottom > 0) {
                        result = YES;
                    } else if (landscape && window.safeAreaInsets.left > 0 && window.safeAreaInsets.right > 0) {
                        result = YES;
                    } else {
                        // nothing
                    }
                }
            });
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                CGSize size = [UIScreen mainScreen].bounds.size;
                if (MAX(size.width, size.height) >= 812) {
                    result = YES;
                }
            }
        }
        return result;
    }
    return NO;
}


@end
