//
//  FSPublic.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FSPublicActionType) {
    FSPublicActionTypeScreenShot = 0,
    FSPublicActionTypePageShot
};

@interface FSPublic : NSObject

+ (void)shareAction:(UIViewController *)controller view:(UIScrollView *)scrollView;

+ (void)action:(FSPublicActionType)actionType view:(UIView *)scrollView controller:(UIViewController *)controller;

// 根据两个颜色值生成渐变色图片
+ (UIImage *)imageWithSizeWidth:(CGFloat)width height:(CGFloat)height aColorRed:(CGFloat)aRed aColorGreen:(CGFloat)aGreen aColorBlue:(CGFloat)aBlue aColorAlpha:(CGFloat)aAlpha bColorRed:(CGFloat)bRed bColorGreen:(CGFloat)bGreen bColorBlue:(CGFloat)bBlue bColorAlpha:(CGFloat)bAlpha;

@end
