//
//  FSSearchViewController.m
//  FSSearchDemo
//
//  Created by fudon on 2017/1/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABSearchController.h"

@interface FSABSearchController ()<UISearchBarDelegate>

@end

@implementation FSABSearchController{
    UIView  *_searchView;
}

+ (CGFloat)searchViewHeight{
    CGFloat vh = 70 + FS_StatusBar_Height - 20;
    return vh;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self searchDesignViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)searchDesignViews{
    CGFloat vh = [self.class searchViewHeight];
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, vh)];
    _searchView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self.view addSubview:_searchView];
    [_searchView addSubview:[FSViewManager seprateViewWithFrame:CGRectMake(0, vh - FS_LineThickness, WIDTHFC, FS_LineThickness)]];
    
    UISearchBar *tf = [[UISearchBar alloc] initWithFrame:CGRectMake(0, FS_StatusBar_Height, self.view.bounds.size.width, 50)];
    tf.placeholder = self.placeholder?:@"请输入";
    tf.delegate = self;
    [_searchView addSubview:tf];
    for (UIView *subview in [[tf.subviews firstObject] subviews]) {
        // iOS 13 解决崩溃问题
        if (IOSGE(13)) {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                  subview.layer.contents = nil;
                  break;
              }
        } else {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subview removeFromSuperview];
            }
        }
    }
    
    tf.barTintColor = [UIColor whiteColor];
    UIView *searchTextField = [[[tf.subviews firstObject] subviews] lastObject];
    searchTextField.backgroundColor = [UIColor whiteColor];
    
    tf.showsCancelButton = YES;
    self.navigationController.navigationBarHidden = YES;
    [tf becomeFirstResponder];
}

- (void)setResultView:(UIView *)resultView{
    if ([resultView isKindOfClass:UIView.class]) {
        _resultView = resultView;
        [self.view addSubview:resultView];
    }
}

#pragma Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{                     // return NO to not become first responder
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{                       // return NO to not resign first responder
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{                       // called when text ends editing
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{    // called when text changes (including clear)
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // 这里可做边输入边搜索
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{                  // called when keyboard search button pressed
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    if (self.searchEvent) {
        NSString *text = searchBar.text;
        self.searchEvent(self,text);
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{ // called when bookmark button pressed
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{  // called when cancel button pressed
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{ // called when search results button pressed
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
