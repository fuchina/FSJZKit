//
//  FSShowDeleteView.m
//  Expand
//
//  Created by Fudongdong on 2017/11/3.
//  Copyright © 2017年 china. All rights reserved.
//

#import "FSShowDeleteView.h"

@implementation FSShowDeleteView{
    UILabel     *_label;
    UILabel     *_title;
}

#if DEBUG
- (void)dealloc{
    
}
#endif

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 80, 0, 80, self.bounds.size.height)];
        _label.backgroundColor = [UIColor redColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor colorWithRed:64/255.0 green:171/255.0 blue:62/255.0 alpha:1.0];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.bounds.size.width - 15, self.bounds.size.height)];
        _title.font = [UIFont systemFontOfSize:16];
        _title.backgroundColor = [UIColor whiteColor];
        [self addSubview:_title];
    }
    return self;
}

- (void)startAnimation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.6 animations:^{
            self->_title.frame = CGRectMake(- 65, 0, self->_title.bounds.size.width, self->_title.bounds.size.height);
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.6 animations:^{
                    self->_title.frame = CGRectMake(15, 0, self->_title.bounds.size.width, self->_title.bounds.size.height);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.3 animations:^{
                        self.alpha = 0;
                    } completion:^(BOOL finished) {
                        [self removeFromSuperview];
                    }];
                }];
            });
        }];
    });
}

- (void)setText:(NSString *)text{
    _title.text = text;
}

- (void)setNotice:(NSString *)notice{
    _label.text = notice;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
