//
//  FSAPP.h
//  myhome
//
//  Created by FudonFuchina on 2017/9/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSAPP : NSObject

+ (void)setObject:(NSString *)instance  forKey:(NSString *)key;
+ (NSString *)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

+ (void)addMessage:(NSString *)message table:(NSString *)table;
+ (NSString *)messageForTable:(NSString *)table;
+ (NSString *)theNewestMessage;

/*
 * 状态栏和导航栏高度
 */
CGFloat _fs_statusAndNavigatorHeight(void);

/*
 * Tabbar高度
 */
CGFloat _fs_tabbarHeight(void);

/**
 底部多出来的高度
 */
CGFloat _fs_tabbarBottomMoreHeight(void);

/*
 * 是否为iPhoneX
 */
BOOL _fs_isIPhoneX (void);

@end
