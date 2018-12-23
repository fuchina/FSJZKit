//
//  FSSelectSectionController.h
//  ShareEconomy
//
//  Created by FudonFuchina on 16/6/10.
//  Copyright © 2016年 FudonFuchina. All rights reserved.
//

#import "FSBaseController.h"

@class FSSelectSectionController;
typedef void(^FSSelectSectionBlock)(FSSelectSectionController *bSelectController,NSArray *bArray, NSInteger bSection,NSInteger bIndex);

@interface FSSelectSectionController : FSBaseController

@property (nonatomic,strong) NSArray                        *array; // 二维数组
@property (nonatomic,copy) FSSelectSectionBlock             block;

@end
