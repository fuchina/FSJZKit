//
//  FSDBMaster.m
//  Demo
//
//  Created by fudon on 2017/5/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSDBMaster.h"
#import <sqlite3.h>

@interface FSDBMaster ()

@property (nonatomic,assign) sqlite3   *sqlite3;

@end

static const char *_sync_queue = "fsdbmaster.sync";
@implementation FSDBMaster{
    dispatch_queue_t    _queue;
}

static FSDBMaster *_instance = nil;

+(FSDBMaster *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[FSDBMaster alloc] init];
    });
    return _instance;
}

+ (FSDBMaster *)sharedInstanceWithDBName:(NSString *)dbName{
    FSDBMaster *master = [self sharedInstance];
    [master generateHandlerWithDBName:dbName];
    return master;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create(_sync_queue, DISPATCH_QUEUE_SERIAL);
        [self generateHandlerWithDBName:_db_first_name];
    }
    return self;
}

- (BOOL)openSqlite3DatabaseAtPath:(NSString *)path{
    if (!([path isKindOfClass:NSString.class] && path.length)) {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL fileExist = [manager fileExistsAtPath:path];
    if (!fileExist) {
        return NO;
    }
    if (_sqlite3) {
        sqlite3_close(_sqlite3);
        _sqlite3 = NULL;
    }
    BOOL openDatabaseSuccess = NO;
    int openResult = sqlite3_open([path UTF8String], &_sqlite3);
    if (openResult != SQLITE_OK) {
        sqlite3_close(_sqlite3);
        _sqlite3 = NULL;
    }else{
        openDatabaseSuccess = YES;
        int result = sqlite3_exec(_sqlite3, "PRAGMA synchronous=FULL;", NULL, NULL, NULL);
        if (result != SQLITE_OK) {
            
        }
    }
    return openDatabaseSuccess;
}

- (void)generateHandlerWithDBName:(NSString *)dbName{
    if (!([dbName isKindOfClass:NSString.class] && dbName.length)) {
        return;
    }
    
    NSString *currentDBPath = [self dbPath];
    NSString *currentDBName = [currentDBPath lastPathComponent];
    NSString *nowDBName = [[NSString alloc] initWithFormat:@"%@%@",dbName,_db_extension];
    if ([currentDBName isEqualToString:nowDBName] && _sqlite3 != NULL) {
        return;
    }
    
    NSString *dbPath = [self dbPathWithFileName:dbName];
    int openResult = sqlite3_open([dbPath UTF8String], &_sqlite3);
    if (openResult != SQLITE_OK) {
        sqlite3_close(_sqlite3);
        _sqlite3 = NULL;
    }else{
        int result = sqlite3_exec(_sqlite3, "PRAGMA synchronous=FULL;", NULL, NULL, NULL);
        if (result != SQLITE_OK) {
        }
    }
}

- (NSString *)dbPath{// 数据库只能放在Documents目录下
    return [self dbPathWithFileName:_db_first_name];
}

// param: 不需要带扩展名
- (NSString *)dbPathWithFileName:(NSString *)name{
    if (!([name isKindOfClass:NSString.class] && name.length)) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%@",name,_db_extension]];
    return path;
}

- (NSString *)createTableIfNotExists:(nonnull NSString *)tableName fields:(nonnull NSArray<NSString *> *)properties{
    if (!([properties isKindOfClass:NSArray.class] && properties.count)) {
        return @"fields 为空";
    }
    for (NSString *s in properties) {
        if (!([s isKindOfClass:NSString.class] && s.length)) {
            return @"field不是字符串";
        }
    }
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return @"表名为空";
    }
    BOOL exist = [self checkTableExist:tableName];
    if (exist) {
        return nil;
    }
    static NSString *_static_aid = @"aid";
    NSString *primaryKey = [[NSString alloc] initWithFormat:@"%@ INTEGER PRIMARY KEY autoincrement,",_static_aid];// 因为PRIMARY KEY，id自动是8个字节
    NSMutableString *append = [[NSMutableString alloc] initWithString:primaryKey];
    NSArray *keywords = [self keywords];
    for (int x = 0; x < properties.count; x ++) {
        NSString *name = properties[x];
        BOOL isKeyword = [keywords containsObject:name];
        if (isKeyword) {
            continue;
            //            name = [[NSString alloc] initWithFormat:@"[%@]",name];
        }
        if ([_static_aid isEqualToString:name]) {
            continue;
        }
        if (x == (properties.count - 1)){
            [append appendString:[[NSString alloc] initWithFormat:@"%@ TEXT NULL",name]];
        }else{
            [append appendString:[[NSString alloc] initWithFormat:@"%@ TEXT NULL,",name]];
        }
    }
    
    // PRIMARY KEY 是唯一的，每条数据不能相同
    //    NSString *sql = @"CREATE TABLE IF NOT EXISTS UserTable ( time TEXT NOT NULL PRIMARY KEY,atype TEXT NOT NULL,btype TEXT NOT NULL,je TEXT,bz TEXT,sr TEXT, cb TEXT, ys TEXT, xj TEXT, ch TEXT, tz TEXT, tx TEXT, fz TEXT);";
    NSString *sql = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);",tableName,append];
    NSString *e = [self execSQL:sql];
    if (e) {
        return [[NSString alloc] initWithFormat:@"发生错误，%@",e];
    }
    return nil;
}

- (NSString *)execSQL:(NSString *)sql{
    __block NSString *errMSG = nil;
    dispatch_sync(_queue, ^{
        sqlite3_stmt *stmt = nil;
        int result = sqlite3_prepare_v2(self->_sqlite3, sql.UTF8String, -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            int code = sqlite3_step(stmt);
            if (code != SQLITE_DONE) {
                errMSG = [[NSString alloc] initWithFormat:@"错误码:%d",code];
            }
        } else {
            errMSG = [[NSString alloc] initWithFormat:@"错误码:%d",result];
        }
        sqlite3_finalize(stmt);stmt = NULL;
    });
    return errMSG;
}

- (NSString *)insertSQL:(NSString *)sql{
    return [self execSQL:sql];
}

- (NSString *)insert_fields_values:(NSDictionary<NSString *,id> *)list table:(NSString *)table{
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return @"insertSQL : table name's length is zero";
    }
    
    if (!([list isKindOfClass:NSDictionary.class] && list.count)) {
        return nil;
    }
    
    NSArray *keys = list.allKeys;
    BOOL isTableExist = [self checkTableExist:table];
    if (!isTableExist) {
        NSString *e = [self createTableIfNotExists:table fields:keys];
        if (e) {
            return e;
        }
    }
    
    NSInteger count = keys.count;
    NSMutableString *whys = [[NSMutableString alloc] init];
    NSString *fies = [keys componentsJoinedByString:@","];
    for (int x = 0; x < count; x ++) {
        if (x == 0) {
            [whys appendFormat:@":%@",keys[x]];
        }else{
            [whys appendFormat:@",:%@",keys[x]];
        }
    }
    NSString *insert_sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",table,fies,whys];

    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_sqlite3, insert_sql.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        Class _class_NSString = NSString.class;
        for (NSString *k in keys) {
            NSString *nk = [[NSString alloc] initWithFormat:@":%@",k];
            const char *kc = nk.UTF8String;
            int idx = sqlite3_bind_parameter_index(stmt, kc);
            if (idx > 0) {
                NSString *v = [list objectForKey:k];
                if (![v isKindOfClass:_class_NSString]) {
                    v = v.description;
                }
                sqlite3_bind_text(stmt, idx, v.UTF8String, -1, SQLITE_STATIC);
            }else{
                NSAssert(idx > 0, @"idx <= 0");
            }
        }
    }
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        sqlite3_finalize(stmt);stmt = NULL;
        return @"insertSQL : sqlite3_step(stmt) failed";
    }
    return nil;
}

- (NSString *)deleteSQL:(NSString *)sql{
    return [self execSQL:sql];
}

- (NSString *)deleteSQL:(NSString *)table aid:(NSNumber *)aid{
    if (([table isKindOfClass:NSString.class] && table.length && aid)) {
        return @"参数错误";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE aid = %@;",table,aid];
    return [self deleteSQL:sql];
}

/*
 更新  eg.
 @"UPDATE %@ SET lati = '%@',loti = '%@' WHERE aid = %@;"
 */
- (NSString *)updateSQL:(NSString *)sql{
    return [self execSQL:sql];
}

//- (NSString *)update:(NSString *)table keyValues:(NSDictionary *)keyValues{
//    if (!([table isKindOfClass:NSString.class] && table.length && [keyValues isKindOfClass:NSDictionary.class] && keyValues.count)) {
//        return @"参数错误";
//    }
//    NSArray *keys = keyValues.allKeys;
//    NSMutableArray *bids = [[NSMutableArray alloc] init];
//    for (int x = 0; x < keys.count; x ++) {
//
//    }
//    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET lati = '%@',loti = '%@' WHERE aid = %@;",table];
//    return nil;
//}

// 被high_execSQL:方法替代
- (NSString *)execSQL:(NSString *)SQL type:(NSString *)type{
    if (!([SQL isKindOfClass:NSString.class] && SQL.length)) {
        return @"语句为空";
    }
    __block NSString *errMSG = nil;
    dispatch_sync(_queue, ^{
        char *error = NULL;
        int result = sqlite3_exec(self->_sqlite3, [SQL UTF8String], NULL, NULL, &error);
        if (result != SQLITE_OK) {
            errMSG = [[NSString alloc] initWithFormat:@"%@失败，原因:%s",type,error];
        }
    });
    return errMSG;
}

/*
 【SELECT DISTINCT name FROM %@;】// 从%@表中查询name字段的所有不重复的值
 【SELECT * FROM %@ WHERE name = 'ddd';】
 【SELECT * FROM %@ order by time DESC limit 0,10;】    ASC
 【SELECT * FROM %@ WHERE atype = ? OR btype = ? and time BETWEEN 1483228800 AND 1514764799 order by time DESC limit 0,10;】
 */
- (NSMutableArray<NSDictionary *> *)querySQL:(NSString *)sql tableName:(NSString *)tableName{
    return [self execQuerySQL:sql tableName:tableName];
}

- (NSMutableArray *)execQuerySQL:(NSString *)sql tableName:(NSString *)tableName{
    if (!([sql isKindOfClass:NSString.class] && sql.length)) {
        return nil;
    }
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return nil;
    }
    BOOL exist = [self checkTableExist:tableName];
    if (!exist) {
        return nil;
    }
    __block NSMutableArray *mArr = nil;
    dispatch_sync(_queue, ^{
        sqlite3_stmt *stmt = nil;
        int prepare = sqlite3_prepare_v2(self->_sqlite3, [sql UTF8String], -1, &stmt, NULL);
        if (prepare != SQLITE_OK) {
            sqlite3_finalize(stmt);stmt = NULL;
            return;
        }
        mArr = [[NSMutableArray alloc] init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id entity = [self dictionaryFromStmt:stmt];
            if (entity) {
                [mArr addObject:entity];
            }
        }
        sqlite3_finalize(stmt);stmt = NULL;
    });
    if (mArr.count) {
        return mArr;
    }
    return nil;
}

- (int)countForTable:(NSString *)tableName{
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return 0;
    }
    BOOL exist = [self checkTableExist:tableName];
    if (!exist) {
        return 0;
    }
    __block int count = 0;
    dispatch_sync(_queue, ^{
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@;",tableName];
        sqlite3_stmt *stmt = nil;
        int prepare = sqlite3_prepare_v2(self->_sqlite3, [sql UTF8String], -1, &stmt, NULL);
        if (prepare != SQLITE_OK) {
            return;
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            count += sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);stmt = NULL;
    });
    return count;
}

- (int)countWithSQL:(NSString *)sql table:(NSString *)tableName{
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return 0;
    }
    BOOL exist = [self checkTableExist:tableName];
    if (!exist) {
        return 0;
    }
    if (!([sql isKindOfClass:NSString.class] && sql.length)) {
        return 0;
    }
    __block int count = 0;
    dispatch_sync(_queue, ^{
        sqlite3_stmt *stmt = nil;
        int prepare = sqlite3_prepare_v2(self->_sqlite3, [sql UTF8String], -1, &stmt, NULL);
        if (prepare != SQLITE_OK) {
            return;
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            count += sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);stmt = NULL;
    });
    return count;
}

- (BOOL)checkTableExist:(NSString *)tableName{
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return NO;
    }
    __block NSInteger success = 0;
    dispatch_sync(_queue, ^{
        sqlite3_stmt *statement;
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",tableName];
        const char *sql_stmt = [sql UTF8String];
        if (sqlite3_prepare_v2(self->_sqlite3, sql_stmt, -1, &statement, nil) == SQLITE_OK) {
            @try {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    int count = sqlite3_column_int(statement, 0);
                    success += count;
                    if (success > 0) {
                        break;
                    }
                }
            } @catch (NSException *exception) {
                
            } @finally {
                sqlite3_finalize(statement);statement = NULL;
            }
        }
    });
    return success > 0;
}

- (NSString *)addField:(NSString *)field defaultValue:(NSString *)value toTable:(NSString *)table{
    Class _class_NSString = NSString.class;
    BOOL checkField = [field isKindOfClass:_class_NSString] && field.length;
    if (!checkField) {
        return @"字段不是字符串";
    }
    NSArray *keys = [self keywords];
    if ([keys containsObject:field]) {
        return @"字段名不能使用关键字";
    }
    BOOL checkTable = [table isKindOfClass:_class_NSString] && table.length;
    if (!checkTable) {
        return @"表名错误";
    }
    BOOL exist = [self checkTableExist:table];
    if (!exist) {
        return @"表不存在";
    }
    NSArray *fs = [self allFields:table];
    BOOL isFieldExist = NO;
    NSString *_key_field_name = @"field_name";
    for (NSDictionary *dic in fs) {
        NSString *f = [dic objectForKey:_key_field_name];
        if ([f isEqualToString:field]) {
            isFieldExist = YES;
            break;
        }
    }
    if (isFieldExist) {   // 表中已有改字段，算是增加成功了
        return nil;
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"ALTER TABLE '%@' ADD '%@' TEXT NULL DEFAULT '%@';",table,field,value?:@""];
    NSString *error = [self execSQL:sql];
    return error;
}

- (NSString *)dropTable:(NSString *)table{
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return @"表名为空";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"DROP TABLE %@",table];
    NSString *error = [self execSQL:sql];
    return error;
}

- (BOOL)checkTableExistWithTableNamed:(NSString *)tableName{
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return NO;
    }
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        char *err;
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",tableName];
        const char *sql_stmt = [sql UTF8String];
        int result = sqlite3_exec(self->_sqlite3, sql_stmt, checkTableCallBack, (void *)[tableName UTF8String], &err);
        if(result != SQLITE_OK){
            return;
        }
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *exist = [ud objectForKey:tableName];
        success = exist.length?YES:NO;
    });
    return success;
}

/*
 int (*callback)(void*,int,char**,char**)
 * 函数参数:
 void *param 传递给callback回调函数的参数,对应于sqlite3_exec函数的第四个参数
 int f_num 查找到的记录中包含的字段数目
 char **f_value 包含查找到每个记录的字段值
 char **f_name 包含查找到每个记录的字段名称
 */

int checkTableCallBack(void *param, int f_num, char **f_value, char **f_name){
    NSString *p = [[NSString alloc] initWithUTF8String:param];// 传过来的参数
    NSInteger number = 0;
    if (f_num) {
        char *count = f_value[0];
        number = atoi(count);
    }
    
    if (number) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:p];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:p];
    }
    return 0;
}

// 要返回一条数据中的所有字段及其值
- (NSDictionary *)dictionaryFromStmt:(sqlite3_stmt *)stmt{
    NSMutableDictionary *last = [[NSMutableDictionary alloc] init];
    int count = sqlite3_column_count(stmt);
    static NSString *noLenghthString = @"";
    for (int x = 0; x < count; x ++) {
        const char *cname = sqlite3_column_name(stmt, x);
        if (cname == NULL) {
            continue;
        }
        NSString *name = [[NSString alloc] initWithUTF8String:cname];
        
        int cType = sqlite3_column_type(stmt, x);
        id str = noLenghthString;
        if (cType == SQLITE_TEXT) {
            const char *cValue = (char *)sqlite3_column_text(stmt, x);
            if (cValue != NULL) {
                str = [[NSString alloc] initWithUTF8String:cValue];// 如果charValue为NULL会Crash
            }
        }else if (cType == SQLITE_BLOB || cType == SQLITE_NULL){
            const void *bytes = sqlite3_column_blob(stmt, x);
            if (bytes != NULL) {
                str = [[NSData alloc] initWithBytes:bytes length:sqlite3_column_bytes(stmt,x)];
            }
        }else if (cType == SQLITE_INTEGER){
            int cValue = sqlite3_column_int(stmt,x);
            str = @(cValue);
        }else if (cType == SQLITE_FLOAT){
            float cValue = sqlite3_column_double(stmt, x);
            str = @(cValue);
        }
        
        if (str) {
            [last setObject:str forKey:name];
        }else{
            [last setObject:noLenghthString forKey:name];
        }
    }
    return last;
}

//获取表中所有字段名和类型
static NSString     *_field_name = @"field_name";
static NSString     *_field_type = @"field_type";
- (NSArray<NSDictionary *> *)allFields:(NSString *)tableName{
    __block NSMutableArray *array = nil;
    dispatch_sync(_queue, ^{
        array = [[NSMutableArray alloc] init];
        NSString *getColumn = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
        sqlite3_stmt *statement;
        sqlite3_prepare_v2(self->_sqlite3, [getColumn UTF8String], -1, &statement, nil);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *nameData = (char *)sqlite3_column_text(statement, 1);
            NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
            char *typeData = (char *)sqlite3_column_text(statement, 2);
            NSString *columntype = [NSString stringWithCString:typeData encoding:NSUTF8StringEncoding];
            NSDictionary *dic = @{_field_name:columnName,_field_type:[columntype lowercaseString]};
            [array addObject:dic];
        }
        sqlite3_finalize(statement);statement = NULL;
    });
    return [array copy];
}

- (NSArray<NSString *> *)allTables{
    NSArray *array = [self allTablesDetail];
    NSMutableArray *names = nil;
    if ([array isKindOfClass:NSArray.class] && array.count) {
        names = [[NSMutableArray alloc] initWithCapacity:array.count];
        static NSString *_name = @"name";
        static NSString *_nlString = @"";
        for (NSDictionary *m in array) {
            NSString *n = [m objectForKey:_name];
            [names addObject:n?:_nlString];
        }
    }
    return [names copy];
}

- (NSArray<NSDictionary *> *)allTablesDetail{
    __block NSMutableArray *array = nil;
    dispatch_sync(_queue, ^{
        array = [[NSMutableArray alloc] init];
        sqlite3_stmt *statement;
        static const char *getTableInfo = "select * from sqlite_master where type = 'table' order by name";
        if (sqlite3_prepare_v2(self->_sqlite3, getTableInfo, -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                id entity = [self dictionaryFromStmt:statement];
                if (entity) {
                    [array addObject:entity];
                }
            }
        }
        sqlite3_finalize(statement);statement = NULL;
    });
    return array.count?array:nil;
}

- (NSArray<NSString *> *)keywords{
    static NSArray *list = nil;
    if (!list) {
        list = @[@"select",@"insert",@"update",@"delete",@"from",@"creat",@"where",@"desc",@"order",@"by",@"group",@"table",@"alter",@"view",@"index",@"when"];
    }
    return list;
}

+ (int)sqlite3_threadsafe{
    return sqlite3_threadsafe();
}

/******************************************************* 二进制存储 ************************************************************/    

- (NSString *)insertData:(nonnull NSData *)data table:(nonnull NSString *)table key:(nonnull NSString *)key{
    if (![data isKindOfClass:NSData.class]) {
        return [self errorString:@"Data参数错误" sel:_cmd line:__LINE__];
    }
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return [self errorString:@"表名为空" sel:_cmd line:__LINE__];
    }
    if (!([key isKindOfClass:NSString.class] && key.length)) {
        return [self errorString:@"key为空" sel:_cmd line:__LINE__];
    }
    
    BOOL exist = [self checkTableExist:table];
    if (exist) {
        NSString *sql = [[NSString alloc] initWithFormat:@"select count(*) from %@ where ky = '%@'",table,key];
        NSInteger count = [self countWithSQL:sql table:table];
        if (count > 0) {
            return @"key值已存在";
        }
    }else{  // 创建表
        NSString *createTable = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (aid INTEGER PRIMARY KEY autoincrement,tm TEXT,ky TEXT,dt BLOB);",table];
        NSString *e = [self execSQL:createTable];
        if (e) {
            return e;
        }
    }
    
    dispatch_sync(_queue, ^{
        sqlite3_stmt *stmt;
        NSString *iSQL = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (tm,ky,dt) VALUES (:tm,:ky,:dt)",table];
        const char *charSQL = [iSQL UTF8String];
        int result = sqlite3_prepare_v2(self->_sqlite3,charSQL,-1,&stmt,0);
        
//        int count = sqlite3_bind_parameter_count(stmt);
//        const char *ont = sqlite3_bind_parameter_name(stmt, 1);
//        const char *two = sqlite3_bind_parameter_name(stmt, 2);
//        const char *thr = sqlite3_bind_parameter_name(stmt, 3);
        
        int tmIdx = sqlite3_bind_parameter_index(stmt, ":tm");
        int kyIdx = sqlite3_bind_parameter_index(stmt, ":ky");
        int dtIdx = sqlite3_bind_parameter_index(stmt, ":dt");
        
        BOOL isOK = (SQLITE_OK == result);
        if (isOK) {
            sqlite3_bind_text(stmt, tmIdx, @((NSInteger)NSDate.date.timeIntervalSince1970).stringValue.UTF8String, -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, kyIdx, key.UTF8String, -1, SQLITE_TRANSIENT);
            sqlite3_bind_blob64(stmt,dtIdx,data.bytes, data.length, SQLITE_TRANSIENT);
            
            int v = sqlite3_step(stmt);
            if (v == SQLITE_DONE) {
                // ok
            }
        }
        sqlite3_finalize(stmt);stmt = NULL;
    });
    return nil;
}

- (NSString *)errorString:(NSString *)descrition sel:(SEL)sel line:(int)line{
    if (sel && descrition) {
#if DEBUG || TEST
        NSString *error = [[NSString alloc] initWithFormat:@"\n%@\n%@\nLine:%d\n%@",self.class,NSStringFromSelector(sel),line,descrition];
        return error;
#else
        return descrition;
#endif
    }
    return @"FSDBMaster:unknown error";
}

@end
