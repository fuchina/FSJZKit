//
//  FSAlertView.m
//  Expand
//
//  Created by Fudongdong on 2017/10/11.
//  Copyright © 2017年 china. All rights reserved.
//

#import "FSAlertView.h"
#import <FSWindow.h>

@implementation FSAlertView{
    UIView              *_mainView;
    NSLayoutConstraint  *_mainViewHeight;
}

#if DEBUG
- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
#endif

- (instancetype)init{
    self = [super init];
    if (self) {
        [self alertDesignViews];
    }
    return self;
}

- (void)alertDesignViews{
    UIView *backView = [[UIView alloc] init];
    backView.translatesAutoresizingMaskIntoConstraints = NO;
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = .382;
    [self addSubview:backView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backView)]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [backView addGestureRecognizer:tap];
    
    _mainView = [[UIView alloc] init];
    _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.layer.cornerRadius = 10;
    [self addSubview:_mainView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_mainView(280)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mainView)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_mainView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_mainView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    _mainViewHeight = [NSLayoutConstraint constraintWithItem:_mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:280];
    [self addConstraint:_mainViewHeight];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = @"Tips";
    [_mainView addSubview:label];
    [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    CGFloat rate = 230/ 255.0;
    UIColor *color = [UIColor colorWithRed:rate green:rate blue:rate alpha:1.0];
    UIButton *ok = [UIButton buttonWithType:UIButtonTypeSystem];
    ok.translatesAutoresizingMaskIntoConstraints = NO;
    [ok setTitle:@"OK" forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:ok];
    [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[ok]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ok)]];
    [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[ok(44)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ok)]];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = color;
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [ok addSubview:line];
    [ok addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[line]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
    [ok addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[line(0.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
}

- (void)setContent:(NSString *)content{
    _content = content;
    NSArray *list = [content componentsSeparatedByString:@"\n"];
    self.contents = list;
}

- (void)setContents:(NSArray<NSString *> *)contents{
    _contents = contents;
    
    NSInteger tag = 1000;
    for (UIView *sub in _mainView.subviews) {
        if ([sub isKindOfClass:UILabel.class] && sub.tag >= tag) {
            [sub removeFromSuperview];
        }
    }
    
    NSInteger count = MIN(8, contents.count);
    UILabel *label = nil;
    NSMutableArray *tops = [[NSMutableArray alloc] initWithCapacity:count];
    for (int x = 0; x < count; x ++) {
        label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.tag = tag + x;
        label.font = [UIFont systemFontOfSize:13];
        label.text = contents[x];
        [_mainView addSubview:label];
        [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[label]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [_mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(25)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_mainView attribute:NSLayoutAttributeTop multiplier:1 constant:44];
        [_mainView addConstraint:c];
        [tops addObject:c];
    }
    
    for (int x = 0; x < tops.count; x ++) {
        NSLayoutConstraint *c = [tops objectAtIndex:x];
        c.constant = 44 + x * 25;
    }
    _mainViewHeight.constant = tops.count * 25 + 108;
}

- (void)okAction{
    if (self.okCallback) {
        self.okCallback();
    }
    [self tapClick];
}

- (void)tapClick{
    [FSWindow dismiss];
}

+ (void)showString:(NSString *)string callback:(void(^)(void))callback{
    NSArray *list = [string componentsSeparatedByString:@"\n"];
    [self showList:list callback:callback];
}

+ (void)showList:(NSArray<NSString *> *)list callback:(void(^)(void))callback{
    FSAlertView *alert = [[FSAlertView alloc] init];
    alert.translatesAutoresizingMaskIntoConstraints = NO;
    FSWindow *w = [FSWindow sharedInstance];
    [FSWindow showView:alert];
    [w addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[alert]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alert)]];
    [w addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[alert]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alert)]];
    if (callback) {
        alert.okCallback = callback;
    }
    alert.contents = list;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
