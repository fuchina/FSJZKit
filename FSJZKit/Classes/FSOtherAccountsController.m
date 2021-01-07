//
//  FSOtherAccountsController.m
//  FSJZKit
//
//  Created by FudonFuchina on 2021/1/7.
//

#import "FSOtherAccountsController.h"
#import "FSAccountsAPI.h"
#import <MJRefresh.h>
#import "FSUIKit.h"
#import "FSMacro.h"

@interface FSOtherAccountsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSInteger         page;
@property (nonatomic, strong) NSMutableArray    *dataSource;
@property (nonatomic, strong) UITableView       *tableView;

@end

@implementation FSOtherAccountsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self otherAccountsHandleDatas];
}

- (void)otherAccountsHandleDatas {
    [FSAccountsAPI otherAccounts:self.page type:self.type results:^(NSArray<FSABNameModel *> * _Nonnull list) {
        if (self.page) {
            [self.dataSource addObjectsFromArray:list];
        }else{
            self->_dataSource = list;
        }
        [self otherAccountsDesignViews];
    }];
}

- (void)otherAccountsDesignViews {
    if (_tableView) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
        return;
    }
    self.title = @"隐藏的账本";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _fs_statusAndNavigatorHeight(), WIDTHFC, HEIGHTFC - _fs_statusAndNavigatorHeight() - _fs_tabbarBottomMoreHeight()) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    WEAKSELF(this);
    _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        this.page = 0;
        [this otherAccountsHandleDatas];
    }];
    this.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        this.page ++;
        [this otherAccountsHandleDatas];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    FSABNameModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.name;
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"恢复显示" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        FSABNameModel *model = self->_dataSource[indexPath.row];
        NSString *error = [FSAccountsAPI hideAccount:model.aid hidden:NO];
        if (error) {
            [FSToast show:error];return;
        }
        [self otherAccountsHandleDatas];
    }];
    action0.backgroundColor = THISCOLOR;
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [FSUIKit alert:(UIAlertControllerStyleActionSheet) controller:self title:@"删除后将无法恢复" message:nil actionTitles:@[@"确定删除"] styles:@[@(UIAlertActionStyleDestructive)] handler:^(UIAlertAction *action) {
            FSABNameModel *model = self->_dataSource[indexPath.row];
            NSString *error = [FSAccountsAPI deleteAccount:model.aid table:model.tb];
            if (error) {
                [FSToast show:error];return;
            }
            [self otherAccountsHandleDatas];
        }];
    }];
    action1.backgroundColor = UIColor.redColor;
    
    return @[action1,action0];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSABNameModel *model = _dataSource[indexPath.row];
    if (self.push) {
        self.push(model.tb, model.name);
    }
    [FSBaseAPI addFreq:_tb_abname field:@"freq" model:model];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
