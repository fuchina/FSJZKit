//
//  FSDBGroupAPI.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSDBGroupAPI.h"
#import "FSDBSupport.h"
#import "FSMacro.h"
#import "FSKit.h"

@implementation FSDBGroupAPI

+ (NSMutableArray<FSDBGroupModel *> *)groups:(NSString *)type link:(NSString *)link page:(NSInteger)page{
    if (!_fs_isValidateString(type)) {
        return nil;
    }
    if (!_fs_isValidateString(link)) {
        link = @"-1";
    }
    NSInteger unit = 30;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@  WHERE (link = '%@' and type = '%@') order by cast(freq as INTEGER) DESC limit %@,%@;",_tb_group,link,type,@(page * unit),@(unit)];
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSDBGroupModel.class tableName:_tb_group];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    for (FSDBGroupModel *m in list) {
        NSString *cs = [[NSString alloc] initWithFormat:@"select count(*) from %@ Where zone = '%@';",type,m.time];
        NSInteger count = [master countWithSQL:cs table:type];
        m.count = @(count).stringValue;
    }
    return list;
}

+ (NSString *)addGroup:(NSString *)name type:(NSString *)type link:(NSString *)link{
    if (!_fs_isValidateString(name)) {
        return @"请输入组名";
    }
    if (!_fs_isValidateString(type)) {
        return @"类型错误";
    }
    if (!_fs_isValidateString(link)) {
        link = @"-1";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger time = _fs_integerTimeIntevalSince1970();
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and time = '%@';",_tb_group,type,@(time)];
    NSArray *list = [master querySQL:sql tableName:_tb_group];
    while (_fs_isValidateArray(list)) {
        time ++;
        sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and time = '%@';",_tb_group,type,@(time)];
        list = [master querySQL:sql tableName:_tb_group];
    }
    
//    NSString *iSql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,name,type,link,freq) VALUES ('%@','%@','%@','%@','0');",_tb_group,@(time),name,type,link];
    NSString *error = [master insert_fields_values:@{
                                                     @"time":@(time),
                                                     @"name":name,
                                                     @"type":type,
                                                     @"link":link,
                                                     @"freq":@"0"
                                                     } table:_tb_group];
//    NSString *error = [master insertSQL:iSql fields:FSDBGroupModel.tableFields table:_tb_group];
    return error;
}

+ (BOOL)hasData:(NSString *)table group:(NSString *)group{
    if (!(_fs_isValidateString(table) && _fs_isValidateString(group))) {
        return NO;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE zone = '%@' limit 0,1;",table,group];
    NSArray *list = [master querySQL:sql tableName:table];
    return list.count;
}

+ (void)versionInterimFunction:(NSString *)table{
//    if (![FSKit isValidateString:table]) {
//        return;
//    }
//    if ([table isEqualToString:_tb_diary] || [table isEqualToString:_tb_password] || [table isEqualToString:_tb_card]) {
//        FSDBMaster *master = [FSDBMaster sharedInstance];
//        NSString *grp = [[NSString alloc] initWithFormat:@"UPDATE %@ SET link = '-1' where type = '%@';",_tb_group,table];
//        [master updateWithSQL:grp];
//
//        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (link = '-1' and type = '%@') order by cast(freq as INT) DESC limit 0,1;",_tb_group,table];
//        NSArray *list = [master querySQL:sql tableName:_tb_group];
//        if ([FSKit isValidateArray:list]) {
//            NSDictionary *dic = list.firstObject;
//            NSString *time = dic[@"time"];
//            NSString *s = [[NSString alloc] initWithFormat:@"UPDATE %@ SET zone = '%@';",table,time];
//            [master updateWithSQL:s];
//        }
//    }
}

+ (BOOL)canDeleteWithTable:(NSString *)table zone:(NSString *)zone{
    if (!(_fs_isValidateString(table) && _fs_isValidateString(zone))) {
        return NO;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE zone = '%@';",table,zone];
    NSArray *list = [master querySQL:sql tableName:table];
    
    NSString *sqlZone = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE link = '%@' and type = '%@';",_tb_group,zone,table];
    NSArray *listZone = [master querySQL:sqlZone tableName:_tb_group];
    return (list.count == 0 && listZone.count == 0);
}

/*
 1.只能移到数据目录下，不能移到组目录下;
 2.不需要移到当前目录下。
 */
+ (NSArray<NSDictionary *> *)allZones:(NSString *)table zone:(NSString *)myZone{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ Where type = '%@' limit 0,300;",_tb_group,table];
    NSMutableArray *array = [master querySQL:sql tableName:_tb_group];
    NSMutableArray *ds = [[NSMutableArray alloc] init];
    for (NSDictionary *d in array) {
        NSString *sid = d[@"time"];
        BOOL hasZone = NO;
        for (NSDictionary *m in array) {
            NSString *link = m[@"link"];
            if ([link isEqualToString:sid]) {
                hasZone = YES;
                break;
            }
        }
        BOOL isSu = [sid isEqualToString:myZone];
        if (hasZone || isSu) {
            [ds addObject:d];
        }
    }
    [array removeObjectsInArray:ds];
    return array;
}

+ (void)updateFreq:(FSDBGroupModel *)model{
    if (!model) {
        return;
    }
    NSInteger freq = [model.freq integerValue] + 1;
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET freq = '%@' WHERE aid = %@;",_tb_group,@(freq),model.aid];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    [master updateSQL:sql];
    // [master updateWithSQL:sql];
}

+ (NSString *)titleForTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *text = [self mapOfTable:table];
    NSString *title = [[NSString alloc] initWithFormat:@"%@(%@)",text,@([master countForTable:table])];
    return title;
}

+ (NSString *)mapOfTable:(NSString *)table{
    static NSDictionary *dic = nil;
    if (!dic) {
        dic = @{
                _tb_diary:@"日记",
                _tb_password:@"密码",
                _tb_card:@"号码",
                };
    }
    return [dic objectForKey:table];
}

/*
 1.不能移到自己目录下，也不能移到自己的子目录下；
 2.如果目标目录下有数据，也不能移入；
 3.不能移入到父目录下，因为已经在该目录下。
 */
+ (NSArray<NSDictionary *> *)zonesForChange:(NSString *)table model:(FSDBGroupModel *)model{
    if (!(_fs_isValidateString(table) && [model isKindOfClass:FSDBGroupModel.class])) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ Where type = '%@' order by cast(freq as INTEGER) DESC limit 0,500;",_tb_group,table];
    NSMutableArray *array = [master querySQL:sql tableName:_tb_group]; // 这是所有的组
    NSMutableArray *needDeletes = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in array) {
        NSString *link = dic[@"link"];
        NSString *n = dic[@"time"];
        BOOL son = [link isEqualToString:model.time];  // 子目录
        BOOL me = [n isEqualToString:model.time];      // 自己
        BOOL su = [model.link isEqualToString:n];      // 已经在该目录下
        if (son || me || su) {
            [needDeletes addObject:dic];
        }
    }
    
    for (NSDictionary *dic in array) {
        NSString *zone = dic[@"time"];
        NSString *tSql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE zone = '%@';",table,zone];
        NSArray *list = [master querySQL:tSql tableName:table];
        if (_fs_isValidateArray(list)) {
            if (![needDeletes containsObject:dic]) {
                [needDeletes addObject:dic];
            }
        }
    }
    [array removeObjectsInArray:needDeletes];
    return [array copy];
}

+ (NSString *)changeModel:(FSDBGroupModel *)model toZone:(NSString *)zone table:(NSString *)table{
    if (![model isKindOfClass:FSDBGroupModel.class]) {
        return @"参数错误";
    }
    if (!_fs_isValidateString(zone)) {
        return @"参数错误";
    }
    NSArray *list = [self zonesForChange:table model:model];
    BOOL canMove = NO;
    for (NSDictionary *dic in list) {
        NSString *sid = dic[@"time"];
        if ([zone isEqualToString:sid]) {
            canMove = YES;
            break;
        }
    }
    if (!canMove) {
        return @"不可以更改到这一组";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET link = '%@' WHERE aid = %@;",_tb_group,zone,model.aid];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *error = [master updateSQL:sql];
    // NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (NSString *)renameModel:(FSDBGroupModel *)model newName:(NSString *)name forTable:(NSString *)table{
    if ((![model isKindOfClass:FSDBGroupModel.class]) || (!_fs_isValidateString(name)) || (!_fs_isValidateString(table))) {
        return @"Params error";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *select = [[NSString alloc] initWithFormat:@"UPDATE %@ SET name = '%@' WHERE (type = '%@' and aid = %@);",_tb_group,name,table,model.aid];
    NSString *error = [master updateSQL:select];
    // NSString *error = [master updateWithSQL:select];
    return error;
}

@end
