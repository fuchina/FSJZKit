//
//  FSTextImageController.m
//  FSBaseController
//
//  Created by FudonFuchina on 2019/8/31.
//

#import "FSTextImageController.h"
#import "FSCalculator.h"
#import "FSPublic.h"
#import "FSDate.h"

@interface FSTextImageController ()

@end

@implementation FSTextImageController{
    UIImageView     *_mainView;
    UITextField     *_aTextField;
    UITextField     *_bTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self textImageDesignViews];
}

- (void)textImageDesignViews{
    self.title = @"图片生成";
    
    _mainView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 30, self.view.frame.size.width - 10, 100)];
    _mainView.layer.cornerRadius = 6;
    _mainView.layer.masksToBounds = YES;
    [self.scrollView addSubview:_mainView];
    
    UIFont *font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    CGFloat textMargin = 20;
    CGFloat labelWidth = _mainView.frame.size.width - textMargin * 2;
    CGFloat height = [FSCalculator textHeight:self.text font:font labelWidth:labelWidth];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, 80, labelWidth, height)];
    label.font = font;
    label.numberOfLines = 0;
    label.text = self.text;
    [_mainView addSubview:label];
    _mainView.height = height + 160;
    
    UIImage *image = [FSPublic imageWithSizeWidth:self.view.frame.size.width - 10 height:_mainView.height aColorRed:0xea aColorGreen:0xed aColorBlue:0xf6 aColorAlpha:1 bColorRed:0xa3 bColorGreen:0xcd bColorBlue:0xce bColorAlpha:.5];
    _mainView.image = image;
    
    self.scrollView.contentSize = CGSizeMake(0, MAX(_mainView.bottom + 10, self.view.frame.size.height + 10));
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, 45, _mainView.frame.size.width - textMargin * 2, 25)];
    toLabel.font = font;
    toLabel.text = @"To 念";
    [_mainView addSubview:toLabel];
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, _mainView.frame.size.height - 45, _mainView.frame.size.width - textMargin * 2, 25)];
    fromLabel.font = font;
    fromLabel.text = [[NSString alloc] initWithFormat:@"From 冬 %@",[FSDate stringWithDate:NSDate.date formatter:nil]];
    fromLabel.textAlignment = NSTextAlignmentRight;
    [_mainView addSubview:fromLabel];
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
