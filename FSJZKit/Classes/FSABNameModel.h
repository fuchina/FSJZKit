//
//  FSABNameModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/7/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSABNameModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString   *time;
@property (nonatomic,copy) NSString   *name;  // 显示名称
@property (nonatomic,copy) NSString   *tb;    // 表名
@property (nonatomic,copy) NSString   *type;  // 类型   1.公司，2.个人
@property (nonatomic,copy) NSString   *freq;  // 频率，点一次+1
@property (nonatomic,copy) NSString   *flag;  // 标志，0为显示，1为已删除

+ (NSArray<NSString *> *)tableFields;

@end
