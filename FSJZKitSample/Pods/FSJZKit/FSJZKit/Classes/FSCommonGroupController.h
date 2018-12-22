//
//  FSCommonGroupController.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

/*
    支持组的表，必须有个'zone'字段，表示该条数据的组名
 */

#import "FSBaseController.h"

@interface FSCommonGroupController : FSBaseController

@property (nonatomic,copy) NSString *table; // 表名，密码、日记、卡号等
@property (nonatomic,copy) NSString *link;  // 在**文件夹内，link为空是顶级文件夹

// 添加数据
@property (nonatomic,copy) void (^addData)(NSString *zone,NSString *name);
// 查看数据
@property (nonatomic,copy) void (^seeData)(NSString *zone,NSString *name);

@end
