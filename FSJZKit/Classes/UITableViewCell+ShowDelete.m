//
//  UITableViewCell+ShowDelete.m
//  Expand
//
//  Created by Fudongdong on 2017/11/3.
//  Copyright © 2017年 china. All rights reserved.
//

#import "UITableViewCell+ShowDelete.h"
#import <objc/runtime.h>

static void *strKey = &strKey;
@implementation UITableViewCell (ShowDelete)

- (void)setView:(FSShowDeleteView *)view{
    objc_setAssociatedObject(self, &strKey, view, OBJC_ASSOCIATION_RETAIN);
}

- (FSShowDeleteView *)view{
    id object = objc_getAssociatedObject(self, &strKey);
    return object;
}

- (void)showNotice:(BOOL)show textIfShow:(NSString *)text andNotice:(NSString *)notice{
    if (show) {
        if (self.view) {
            [self.view removeFromSuperview];
            self.view = nil;
        }
        self.view = [[FSShowDeleteView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 49.5)];
        [self addSubview:self.view];
        [self.view setText:text];
        [self.view setNotice:notice];
        [self.view startAnimation];
    }else{
        if (self.view) {
            self.view.hidden = YES;
            [self.view removeFromSuperview];
            self.view = nil;
        }
    }
}


@end
