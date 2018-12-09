//
//  FSDBGroupModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDBBaseGroupModel.h"

@interface FSDBGroupModel : FSDBBaseGroupModel

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *name;
@property (nonatomic,copy) NSString     *type; // 类型，密码，日记，卡号等
@property (nonatomic,copy) NSString     *link; // 链接
@property (nonatomic,copy) NSString     *freq; // 频率

+ (NSArray<NSString *> *)tableFields;

@end
