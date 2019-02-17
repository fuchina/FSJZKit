//
//  FSAccessController.h
//  ShareEconomy
//
//  Created by FudonFuchina on 16/9/11.
//  Copyright © 2016年 FudonFuchina. All rights reserved.
//

#import "FSBaseController.h"

#define Text_Name       @"Text_Name"

@interface FSAccessController : FSBaseController

@property (nonatomic,strong) NSArray        *datas; // 存储字典，@{@"":@"",@"":@"",@"":@""};
@property (nonatomic,copy) void (^selectBlock)(FSAccessController *bController,NSIndexPath *bIndexPath);

@end
