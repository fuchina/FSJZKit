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
#import <AVFoundation/AVFoundation.h>

@interface FSTextImageController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation FSTextImageController{
    UIImageView     *_mainView;
    UITextField     *_aTextField;
    UITextField     *_bTextField;
    UIButton        *_button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self textImageDesignViews];
}

- (void)shareToWC{
    [FSPublic shareAction:self view:_mainView];
}

- (void)textImageDesignViews{
    self.title = @"图片生成";
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"发到微信" style:UIBarButtonItemStylePlain target:self action:@selector(shareToWC)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    _mainView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 30, self.view.frame.size.width - 10, 100)];
    _mainView.layer.cornerRadius = 6;
    _mainView.layer.masksToBounds = YES;
    [self.scrollView addSubview:_mainView];
    
    UIFont *font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    CGFloat textMargin = 20;
    CGFloat textTop = 200;
    CGFloat labelWidth = _mainView.frame.size.width - textMargin * 2;
    CGFloat height = [FSCalculator textHeight:self.text font:font labelWidth:labelWidth];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, textTop, labelWidth, height)];
    label.font = font;
    label.numberOfLines = 0;
    label.text = self.text;
    [_mainView addSubview:label];
    _mainView.height = height + textTop + 80;
    
    UIImage *image = [FSPublic imageWithSizeWidth:self.view.frame.size.width - 10 height:_mainView.height aColorRed:0xea aColorGreen:0xed aColorBlue:0xf6 aColorAlpha:1 bColorRed:0xa3 bColorGreen:0xcd bColorBlue:0xce bColorAlpha:1];
    _mainView.image = image;
    
    self.scrollView.contentSize = CGSizeMake(0, MAX(_mainView.bottom + 10, self.view.frame.size.height + 10));
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, textTop - 35, _mainView.frame.size.width - textMargin * 2, 25)];
    toLabel.font = font;
    toLabel.text = @"To 念";
    [_mainView addSubview:toLabel];
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, _mainView.frame.size.height - 45, _mainView.frame.size.width - textMargin * 2, 25)];
    fromLabel.font = font;
    fromLabel.text = [[NSString alloc] initWithFormat:@"From 冬 %@",[FSDate stringWithDate:NSDate.date formatter:nil]];
    fromLabel.textAlignment = NSTextAlignmentRight;
    [_mainView addSubview:fromLabel];
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.frame = CGRectMake(_mainView.frame.size.width / 2 - 60, 40, 120, 120);
    _button.backgroundColor = UIColor.lightGrayColor;
    _button.alpha = .8;
    _button.layer.cornerRadius = 6;
    _button.layer.masksToBounds = YES;
    [_button addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    _mainView.userInteractionEnabled = YES;
    [_mainView addSubview:_button];
}

-(void)showActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            //            mAlertView(@"", @"请在'设置'中打开相机权限")
            return;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //            mAlertView(@"", @"照相机不可用")
            return;
        }
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [_button setBackgroundImage:image forState:UIControlStateNormal];
    //图片在这里压缩一下
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    if (imageData.length/1024 > 1024*20)
    {
        //        mAlertView(@"温馨提示", @"请重新选择一张不超过20M的图片");
    }
    else
    {
        //        _imageType = [NSData typeForImageData:imageData];
        //        _imageBase64 = [imageData base64EncodedString];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
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
