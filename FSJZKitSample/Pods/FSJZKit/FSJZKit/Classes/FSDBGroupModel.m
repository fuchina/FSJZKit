//
//  FSDBGroupModel.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSDBGroupModel.h"

@implementation FSDBGroupModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"name",@"type",@"link",@"freq"];
}

@end

