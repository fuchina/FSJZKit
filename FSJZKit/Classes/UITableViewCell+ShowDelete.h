//
//  UITableViewCell+ShowDelete.h
//  Expand
//
//  Created by Fudongdong on 2017/11/3.
//  Copyright © 2017年 china. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSShowDeleteView.h"

@interface UITableViewCell (ShowDelete)

@property (nonatomic,strong) FSShowDeleteView   *view;
- (void)setView:(FSShowDeleteView *)view;
- (FSShowDeleteView *)view;

- (void)showNotice:(BOOL)show textIfShow:(NSString *)text andNotice:(NSString *)notice;

@end
