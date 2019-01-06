//
//  FSDBMaster.h
//  Demo
//
//  Created by fudon on 2017/5/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *_db_extension = @".db";
static NSString *_db_first_name = @"sql_ling";

@interface FSDBMaster : NSObject

/*
 打开默认的数据库
 */
+ (FSDBMaster *)sharedInstance;

- (BOOL)openSqlite3DatabaseAtPath:(NSString *)path;

/*
 打开的是传入的dbName数据
 */
+ (FSDBMaster *)sharedInstanceWithDBName:(NSString *)dbName;

// 根据数据库名字获取本地路径
-(NSString *)dbPath;
// 不需要带扩展名，扩展名自动补充为.db
- (NSString *)dbPathWithFileName:(NSString *)name;

/*
 新增 eg.
 @"INSERT INTO %@ (a,b,c,d) VALUES ('%@','%@','%@','%@');";
 */
- (NSString *)insertSQL:(NSString *)sql;
- (NSString *)insert_fields_values:(NSDictionary<NSString *,id> *)list table:(NSString *)table;

/*
 删除  eg
 @"DELETE FROM %@ WHERE time = '%@';"
 注意time的值，time是字符串，所以要用''来表示，如果time是字符型数字时加不加''都没关系，但如果time是155555.8888之类时，因为那个小数点导致必须加上''才能找到time
 */
- (NSString *)deleteSQL:(NSString *)sql;
- (NSString *)deleteSQL:(NSString *)table aid:(NSNumber *)aid;

// @"UPDATE %@ SET lati = '%@',loti = '%@' WHERE aid = %@;"
- (NSString *)updateSQL:(NSString *)sql;

// 直接执行SQL语句
- (NSString *)execSQL:(NSString *)sql;

/*
 【SELECT DISTINCT name FROM %@;】// 从%@表中查询name字段的所有不重复的值
 【SELECT * FROM %@ WHERE name = 'ddd';】
 【SELECT * FROM %@ order by time DESC limit 0,10;】    ASC
 【SELECT * FROM %@ WHERE atype = ? OR btype = ? and time BETWEEN 1483228800 AND 1514764799 order by time DESC limit 0,10;】
 */
- (NSMutableArray<NSDictionary *> *)querySQL:(NSString *)sql tableName:(NSString *)tableName;

//  检查表是否存在
- (BOOL)checkTableExist:(NSString *)tableName;

// 往表中增加字段  成功返回nil，失败返回原因
- (NSString *)addField:(NSString *)field defaultValue:(NSString *)value toTable:(NSString *)table;

// 删除表  成功返回nil，失败返回原因
- (NSString *)dropTable:(NSString *)table;

//  获取表名的所有数据数量
- (int)countForTable:(NSString *)tableName;

/*
 根据sql语句获取满足条件的数据数量；count(*)内部可以是*，也可是字段名来限制范围。
 【select count(*) from dbgroup Where cast(freq as INTEGER) > 30;】查询满足条件的数据条数；
 【select count(DISTINCT type) from dbgroup;】查询type不同种类，比如type有password和diary两种，就返回2;
 */
- (int)countWithSQL:(NSString *)sql table:(NSString *)table;

// 获取数据库中所有表名
- (NSArray<NSString *> *)allTables;
- (NSArray<NSDictionary *> *)allTablesDetail;
// 获取表中的所有字段
- (NSArray<NSDictionary *> *)allFields:(NSString *)table;

/*
 所有关键字，不能用作表名或字段名
 */
- (NSArray<NSString *> *)keywords;

//线程安全  iOS是2，2：支持多线程但不支持一个数据库在多线程内，即只支持一个数据库对应一个线程的多线程
+ (int)sqlite3_threadsafe;


/*
 *  存储二进制
 *  @param data：二进制
 *  @param table：表名
 *  @param key：检索字
 *
 *  返回值：错误
 */
- (NSString *)insertData:(nonnull NSData *)data table:(nonnull NSString *)table key:(nonnull NSString *)key;

@end



