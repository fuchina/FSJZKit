//
//  FSDBSupport.m
//  myhome
//
//  Created by FudonFuchina on 2017/8/26.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSDBSupport.h"
#import "FSKitDuty.h"
#import "FSTuple.h"
#import "FSDate.h"
#import "FSRuntime.h"
#import "FSFile.h"

@implementation FSDBSupport

+ (NSMutableArray *)querySQL:(NSString *)sql class:(Class)cname tableName:(NSString *)tableName{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSMutableArray *list = [master querySQL:sql tableName:tableName];
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:list.count];
    for (NSDictionary *dic in list) {
        id model = [FSRuntime entity:cname dic:dic];
        if (model) {
            [models addObject:model];
        }
    }
    return models.count?models:nil;
}

+ (NSMutableArray *)querySQL:(NSString *)sql class:(Class)cname tableName:(NSString *)tableName eachCallback:(void(^)(id model))preCount{
    NSAssert(preCount != nil, @"preCount必须实现才调用这个方法");
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSMutableArray *list = [master querySQL:sql tableName:tableName];
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:list.count];
    for (NSDictionary *dic in list) {
        id model = [FSRuntime entity:cname dic:dic];
        if (model) {
            [models addObject:model];
            preCount(model);
        }
    }
    return models.count?models:nil;
}

// @[Tuple2:year + @[Tuple3:date + sr + cb]]
+ (NSArray<Tuple2<NSString *,NSArray<Tuple3 *> *> *> *)incomesAndcostsByMonth:(NSInteger)year table:(NSString *)table first:(NSTimeInterval)first{
    first = MAX(first, 0);
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return nil;
    }
    NSInteger count = [master countForTable:table];
    if (count == 0) {
        return nil;
    }
    NSInteger firstYear = year - 1;
    NSString *str = [[NSString alloc] initWithFormat:@"%@-01-01 00:00:00",@(firstYear)];
    NSDate *date = [FSDate dateByString:str formatter:nil];
    NSTimeInterval time = [date timeIntervalSince1970];
    if (time < first) {
        time = first;
        date = [[NSDate alloc] initWithTimeIntervalSince1970:first];
    }
    NSDateComponents *ct = [FSDate componentForDate:date];
    NSDateComponents *cn = [FSDate componentForDate:[NSDate date]];
    NSInteger days = [FSDate daysForMonth:cn.month year:cn.year];
    NSString *max = [[NSString alloc] initWithFormat:@"%@-%@-%@ 23:59:59",@(cn.year),[FSKit twoChar:cn.month],@(days)];
    NSDate *maxDate = [FSDate dateByString:max formatter:nil];
    NSTimeInterval maxTI = [maxDate timeIntervalSince1970];
    NSString *start = [[NSString alloc] initWithFormat:@"%@-%@-01 00:00:00",@(ct.year),[FSKit twoChar:ct.month]];
    NSDate *startDate = [FSDate dateByString:start formatter:nil];
    NSTimeInterval startTI = [startDate timeIntervalSince1970];
    
    NSMutableArray *tuples = [[NSMutableArray alloc] init];
    while (startTI < maxTI) {
        NSDate *sDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTI];
        NSDateComponents *sc = [FSDate componentForDate:sDate];
        NSInteger nYear = sc.year;
        NSInteger nMonth = sc.month;
        NSInteger nDays = [FSDate daysForMonth:nMonth year:nYear];
        NSString *sMax = [[NSString alloc] initWithFormat:@"%@-%@-%@ 23:59:59",@(nYear),[FSKit twoChar:nMonth],@(nDays)];
        NSDate *mDate = [FSDate dateByString:sMax formatter:nil];
        NSTimeInterval mTI = [mDate timeIntervalSince1970];
        // startTI mTI
        Tuple3 *t3 = [self requestSROrCB:startTI end:mTI table:table];
        NSString *ye = @(nYear).stringValue;
        if (tuples.count > 0) {
            BOOL saved = NO;
            for (Tuple2 *t in tuples) {
                NSString *y = t._1;
                if ([y isEqualToString:ye]) {
                    NSMutableArray *as = t._2;
                    if ([as isKindOfClass:NSMutableArray.class]) {
                        [as addObject:t3];
                    }
                    saved = YES;
                    break;
                }
            }
            if (!saved) {
                NSMutableArray *a = [[NSMutableArray alloc] init];
                [a addObject:t3];
                Tuple2 *t2 = [Tuple2 v1:ye v2:a];
                [tuples addObject:t2];
            }
        }else{
            NSMutableArray *a = [[NSMutableArray alloc] init];
            [a addObject:t3];
            Tuple2 *t2 = [Tuple2 v1:ye v2:a];
            [tuples addObject:t2];
        }
        
        if (sc.month < 12) {
            nMonth ++;
        }else{
            nYear ++;
            nMonth = 1;
        }
        NSString *nStr = [[NSString alloc] initWithFormat:@"%@-%@-01 00:00:00",@(nYear),[FSKit twoChar:nMonth]];
        NSDate *nDate = [FSDate dateByString:nStr formatter:nil];
        startTI = [nDate timeIntervalSince1970];
    }
    
    [tuples sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    
    for (Tuple2 *t in tuples) {
        NSMutableArray *t3 = t._2;
        if ([t3 isKindOfClass:NSMutableArray.class]) {
            [t3 sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return NSOrderedDescending;
            }];
        }
    }
    return tuples;
}

// date   sr   cb
+ (Tuple3 *)requestSROrCB:(NSTimeInterval)start end:(NSTimeInterval)end table:(NSString *)table{
    static NSString *sring = nil;
    static NSString *_subject_SR = @"sr";    // 收入
    static NSString *_subject_CB = @"cb";    // 成本
    static NSString *_ING_KEY    = @"p";    // 加
    static NSString *_ED_KEY     = @"m";    // 减

    if (sring == nil) {
        sring = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ING_KEY];
    }
    static NSString *sred = nil;
    if (sred == nil) {
        sred = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ED_KEY];
    }
    static NSString *cbing = nil;
    if (cbing == nil) {
        cbing = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ING_KEY];
    }
    static NSString *cbed = nil;
    if (cbed == nil) {
        cbed = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ED_KEY];
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@') and cast(time as REAL) BETWEEN %@ AND %@;",table,sring,sring,sred,sred,cbing,cbing,cbed,cbed,@(start),@(end)];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:table];
    CGFloat sr = 0;
    CGFloat cb = 0;
    for (NSDictionary *model in list) {
        CGFloat je = [model[@"je"] doubleValue];
        NSString *atype = model[@"atype"];
        NSString *btype = model[@"btype"];
        if ([atype isEqualToString:sring] || [btype isEqualToString:sring]) {
            sr += je;
        }else if ([atype isEqualToString:sred] || [btype isEqualToString:sred]){
            sr = sr - je;
        }else if ([atype isEqualToString:cbing] || [btype isEqualToString:cbing]){
            cb += je;
        }else if ([atype isEqualToString:cbed] || [btype isEqualToString:cbed]){
            cb = cb - je;
        }
    }
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:((start + end) / 2)];
    Tuple3 *t3 = [Tuple3 v1:date v2:@(sr).stringValue v3:@(cb).stringValue];
    return t3;
}

+ (NSString *)addField:(NSString *)field defaultValue:(NSString *)value toTable:(NSString *)table{
    BOOL checkField = [field isKindOfClass:NSString.class] && field.length;
    if (!checkField) {
        return @"字段不是字符串";
    }
    BOOL checkTable = [table isKindOfClass:NSString.class] && table.length;
    if (!checkTable) {
        return @"表不是字符串";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *keys = [master keywords];
    if ([keys containsObject:field]) {
        return @"字段名不能使用关键字";
    }
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return @"表不存在";
    }
    NSArray *fs = [master allFields:table];
    BOOL fe = NO;
    for (NSDictionary *dic in fs) {
        NSString *f = [dic objectForKey:@"field_name"];
        if ([f isEqualToString:field]) {
            fe = YES;
            break;
        }
    }
    if (fe) {
        return @"表中已有该字段";
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"ALTER TABLE '%@' ADD '%@' TEXT NULL DEFAULT '%@';",table,field,value?:@""];
    NSString *error = [master execSQL:sql];
    // NSString *error = [master execSQL:sql type:nil];
    return error;
}

+ (NSString *)updateField:(NSString *)field value:(NSString *)value ofTable:(NSString *)table{
    BOOL checkField = [field isKindOfClass:NSString.class] && field.length;
    if (!checkField) {
        return @"字段不是字符串";
    }
    BOOL checkTable = [table isKindOfClass:NSString.class] && table.length;
    if (!checkTable) {
        return @"表不是字符串";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return @"表不存在";
    }
    NSArray<NSDictionary *> *tfs = [master allFields:table];
    BOOL fieldExist = NO;
    for (NSDictionary *dic in tfs) {
        NSString *fi = [dic objectForKey:@"field_name"];
        if ([fi isEqualToString:field]) {
            fieldExist = YES;
            break;
        }
    }
    if (!fieldExist) {
        return @"字段不存在";
    }

    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@';",table,field,value?:@""];
    NSString *error = [master updateSQL:sql];
    // NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (void)dayFlowOfAccount:(NSString *)account date:(NSDate *)date completion:(void(^)(CGFloat sr,CGFloat cb))completion{
//    NSInteger todayStart = [FSDate theFirstSecondOfDay:date];
//    NSInteger todayEnd = [FSDate theLastSecondOfDay:date];
//    NSString *srp = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ING_KEY];
//    NSString *srm = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ED_KEY];
//    NSString *cbp = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ING_KEY];
//    NSString *cbm = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ED_KEY];
//    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (atype = '%@' OR atype = '%@' OR btype = '%@' OR btype = '%@') and time BETWEEN %@ AND %@ order by time DESC limit 0,10;",account,srp,srm,cbp,cbm,@(todayStart),@(todayEnd)];
//    NSMutableArray *array = [self querySQL:sql class:[FSABModel class] tableName:account];

}

@end
