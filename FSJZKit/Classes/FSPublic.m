//
//  FSPublic.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSPublic.h"
#import "FSKit.h"
#import "FSShare.h"
#import "FSTrackKeys.h"
#import "FSToast.h"
#import "FSUIKit.h"
#import "FSViewToImage.h"

typedef NS_ENUM(NSInteger, FSPublicActionType) {
    FSPublicActionTypeScreenShot = 0,
    FSPublicActionTypePageShot
};

@implementation FSPublic

+ (void)shareAction:(UIViewController *)controller view:(UIScrollView *)scrollView{
    NSString *screenShot = @"屏幕截图";
    NSString *pageShot = @"页面截图";
    [FSUIKit alert:UIAlertControllerStyleAlert controller:controller title:NSLocalizedString(@"Share screenshot to Wechat?", nil) message:nil actionTitles:@[pageShot,screenShot] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:screenShot]) {
            [self action:0 view:scrollView controller:controller];
        }else if ([action.title isEqualToString:pageShot]){
            [self action:1 view:scrollView controller:controller];
        }
    }];
}

+ (void)action:(FSPublicActionType)actionType view:(UIView *)scrollView controller:(UIViewController *)controller{
    NSString *wechat = @"发到微信";
    NSString *album = @"存入相册";
    [FSUIKit alert:UIAlertControllerStyleAlert controller:controller title:@"分享图片" message:nil actionTitles:@[wechat,album] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        UIImage *image = nil;
        if (actionType == FSPublicActionTypePageShot) {
            image = [FSViewToImage imageForUIView:scrollView];
        }else if (actionType == FSPublicActionTypeScreenShot){
            image = [FSViewToImage screenShot];
        }
        
        if (![image isKindOfClass:UIImage.class]) {
            return;
        }
        if ([action.title isEqualToString:album]) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }else{
            [FSShare wxImageShareActionWithImage:image controller:controller result:^(NSString *bResult) {
            }];
        }
    }];
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        [FSToast show:@"保存成功"];
    }
}

+ (UIImage *)imageWithSizeWidth:(CGFloat)width height:(CGFloat)height aColorRed:(CGFloat)aRed aColorGreen:(CGFloat)aGreen aColorBlue:(CGFloat)aBlue aColorAlpha:(CGFloat)aAlpha bColorRed:(CGFloat)bRed bColorGreen:(CGFloat)bGreen bColorBlue:(CGFloat)bBlue bColorAlpha:(CGFloat)bAlpha {
    CGRect frame = CGRectMake(0, 0, width, height);
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:frame];
    UIGraphicsBeginImageContext(imgview.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGContextScaleCTM(context, frame.size.width, frame.size.height);
    CGFloat colors[] = {
        aRed/255.0, aGreen/255.0, aBlue/255.0, aAlpha,
        bRed/255.0, bGreen/255.0, bBlue/255.0, bAlpha,
    };
    CGGradientRef backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    //设置颜色渐变的方向，范围在(0,0)与(1.0,1.0)之间，如(0,0)(1.0,0)代表水平方向渐变,(0,0)(0,1.0)代表竖直方向渐变
    CGContextDrawLinearGradient(context, backGradient, CGPointMake(0, 0), CGPointMake(1.0, 0), kCGGradientDrawsBeforeStartLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

@end
