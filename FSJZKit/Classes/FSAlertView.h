//
//  FSAlertView.h
//  Expand
//
//  Created by Fudongdong on 2017/10/11.
//  Copyright © 2017年 china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSAlertView : UIView

@property (nonatomic,copy) void (^okCallback)(void);
@property (nonatomic,strong) NSArray<NSString *>    *contents;
@property (nonatomic,copy) NSString                 *content;

+ (void)showList:(NSArray<NSString *> *)list callback:(void(^)(void))callback;
+ (void)showString:(NSString *)string callback:(void(^)(void))callback;

@end
