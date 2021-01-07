//
//  FSOtherAccountsController.m
//  FSJZKit
//
//  Created by FudonFuchina on 2021/1/7.
//

#import "FSOtherAccountsController.h"
#import "FSAccountsAPI.h"

@interface FSOtherAccountsController ()

@end

@implementation FSOtherAccountsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self otherAccountsHandleDatas];
}

- (void)otherAccountsHandleDatas {
    [FSAccountsAPI otherAccounts:^(NSArray * _Nonnull list) {
        
        [self otherAccountsDesignViews];
    }];
}

- (void)otherAccountsDesignViews {
    
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
