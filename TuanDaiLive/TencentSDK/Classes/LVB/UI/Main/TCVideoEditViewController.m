//
//  TCVideoEditViewController.m
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/10.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoEditViewController.h"
#import <TXRTMPSDK/TXUGCEditer.h>
#import "TCVideoPreview.h"
#import "TXVideoRangeSlider.h"
#import "TXVideoRangeConst.h"
#import "TCVideoPublishController.h"
#import "UIView+Additions.h"
#import "UIColor+MLPFlatColors.h"
#import <MBProgressHUD/MBProgressHUD.h>

typedef  NS_ENUM(NSInteger,ActionType)
{
    ActionType_Save,
    ActionType_Publish,
    ActionType_Save_Publish,
};

@interface TCVideoEditViewController ()<TXVideoGenerateListener,TXVideoComposeListener,TCVideoPreviewDelegate, TXVideoRangeSliderDelegate,UIActionSheetDelegate>

@end

@implementation TCVideoEditViewController
{
    TXUGCEditer         *_ugcEdit;
    TCVideoPreview      *_videoPreview;
    TXVideoRangeSlider  *_videoRangeSlider;
    
    NSMutableArray      *_imageList;
    NSMutableArray      *_cutPathList;
    NSString            *_videoOutputPath;
    int                _duration;
    unsigned long long _fileSize;
    ActionType         _actionType;
    
    UILabel            *_timeTipsLabel;
    UIColor            *_barTintColor;
}



-(instancetype)init
{
    self = [super init];
    if (self) {
        _cutPathList = [NSMutableArray array];
        _videoOutputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"outputCut.mp4"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _barTintColor =  self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.barTintColor =  UIColorFromRGB(0x181818);
    self.navigationController.navigationBar.translucent  =  NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor =  _barTintColor;
    self.navigationController.navigationBar.translucent  =  YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)dealloc
{
    [_videoPreview removeNotification];
    _videoPreview = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *barTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    barTitleLabel.backgroundColor = [UIColor clearColor];
    barTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    barTitleLabel.textColor = [UIColor whiteColor];
    barTitleLabel.textAlignment = NSTextAlignmentCenter;
    barTitleLabel.text = @"编辑视频";
    self.navigationItem.titleView = barTitleLabel;
    
    self.view.backgroundColor = UIColorFromRGB(0x181818);
    
    _videoPreview = [[TCVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 225 * self.view.width / 375) coverImage:nil];
    _videoPreview.delegate = self;
    [self.view addSubview:_videoPreview];
    
    UILabel *cutTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _videoPreview.bottom + 60, self.view.width, 20)];
    cutTipsLabel.text = @"设定想要截取的片段";
    cutTipsLabel.textAlignment = NSTextAlignmentCenter;
    cutTipsLabel.font = [UIFont systemFontOfSize:15];
    cutTipsLabel.textColor = UIColorFromRGB(0x777777);
    [self.view addSubview:cutTipsLabel];
    
    _timeTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cutTipsLabel.bottom + 30, self.view.width, 20)];
    _timeTipsLabel.text = @"0 s";
    _timeTipsLabel.textAlignment = NSTextAlignmentCenter;
    _timeTipsLabel.font = [UIFont systemFontOfSize:14];
    _timeTipsLabel.textColor = UIColorFromRGB(0x777777);
    [self.view addSubview:_timeTipsLabel];
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;
    _ugcEdit = [[TXUGCEditer alloc] initWithPreview:param];
    _ugcEdit.generateDelegate = self;
    _ugcEdit.previewDelegate = _videoPreview;
    
    [_ugcEdit setVideoPath:_videoPath];
    TXVideoInfo *videoMsg = [TXUGCVideoInfoReader getVideoInfo:_videoPath];
    _duration   = videoMsg.duration;
    _fileSize   = videoMsg.fileSize;

    //显示微缩图列表
    _imageList = [NSMutableArray new];
    int imageNum = 10;
    
    [TXUGCVideoInfoReader getSampleImages:imageNum videoPath:_videoPath progress:^(int number, UIImage *image) {
        if (number == 1) {
            _videoRangeSlider = [[TXVideoRangeSlider alloc] initWithFrame:CGRectMake(0, cutTipsLabel.bottom + 50, self.view.width, MIDDLE_LINE_HEIGHT)];
            [self.view addSubview:_videoRangeSlider];
            _videoRangeSlider.delegate = self;
            for (int i = 0; i < imageNum; i++) {
                [_imageList addObject:image];
            }
            [_videoRangeSlider setImageList:_imageList];
            [_videoRangeSlider setDurationMs:_duration];
        } else {
            _imageList[number-1] = image;
            [_videoRangeSlider updateImage:image atIndex:number-1];
        }
    }];
    
    
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                    action:@selector(goBack)];
    customBackButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.leftBarButtonItem = customBackButton;
    
    UIBarButtonItem *customSaveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goSave)];
    customSaveButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.rightBarButtonItem = customSaveButton;
}

- (void)goBack
{
    [self pause];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)goSave
{
    [self pause];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存并发布" otherButtonTitles:@"仅保存",@"仅发布", nil];
    [sheet showInView:self.view];
    
}

- (void)pause
{
    [_ugcEdit pausePlay];
    [_videoPreview setPlayBtn:NO];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        _actionType = ActionType_Save_Publish;
    }
    else if (buttonIndex == 1){
        _actionType = ActionType_Save;
    }
    else if (buttonIndex == 2){
        _actionType = ActionType_Publish;
    }
    
    if (buttonIndex == 0 || buttonIndex == 1 || buttonIndex == 2) {
        if (_fileSize > 200 * 1024 * 1024) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频文件过大,超过200M,暂不支持裁剪！" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"视频剪切中...";
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        
        TXOperationParam *param = [[TXOperationParam alloc] init];
        param.type      = OPERATION_TYPE_CUT;
        param.startTime = _videoRangeSlider.leftPos;
        param.endTime   = _videoRangeSlider.rightPos;
        [_ugcEdit setOperationList:@[param]];
        
        [_ugcEdit generateVideo:VIDEO_COMPRESSED_540P videoOutputPath:_videoOutputPath];
        
        [self onVideoPause];
        [_videoPreview setPlayBtn:NO];
    }
}

#pragma mark TXVideoGenerateListener
-(void) onGenerateProgress:(float)progress
{
    [MBProgressHUD HUDForView:self.view].progress = progress;
}

-(void) onGenerateComplete:(TXGenerateResult *)result
{
    if (result.retCode == 0) {
        if (_actionType == ActionType_Save_Publish || _actionType == ActionType_Save) {
            UISaveVideoAtPathToSavedPhotosAlbum(_videoOutputPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else if (_actionType == ActionType_Publish){
             [self publish];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频生成失败"
                                                            message:[NSString stringWithFormat:@"错误码：%ld 错误信息：%@",(long)result.retCode,result.descMsg]
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (_actionType == ActionType_Save) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self publish];
}


- (void)publish
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //TXVideoInfo *videoMsg = [TXUGCVideoInfoReader getVideoInfo:_videoOutputPath];
    TCVideoPublishController *vc = [[TCVideoPublishController alloc] initWithPath:_videoOutputPath
                                                                         videoMsg:[TXUGCVideoInfoReader getVideoInfo:_videoOutputPath]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TCVideoPreviewDelegate
- (void)onVideoPlay
{
    [_ugcEdit startPlayFromTime:_videoRangeSlider.currentPos toTime:_videoRangeSlider.rightPos];
}

- (void)onVideoPause
{
    [_ugcEdit pausePlay];
}

- (void)onVideoResume
{
    [self onVideoPlay];
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _videoRangeSlider.currentPos = time;
    _timeTipsLabel.text = [NSString stringWithFormat:@"%.2f s",time];

}
- (void)onVideoPlayFinished
{
    [_ugcEdit startPlayFromTime:_videoRangeSlider.leftPos toTime:_videoRangeSlider.rightPos];
}

- (void)onVideoRangeLeftChanged:(TXVideoRangeSlider *)sender {
    [_ugcEdit pausePlay];
    [_videoPreview setPlayBtn:NO];
}

- (void)onVideoRangeLeftChangeEnded:(TXVideoRangeSlider *)sender
{
    _videoRangeSlider.currentPos = sender.leftPos;
    _timeTipsLabel.text = [NSString stringWithFormat:@"%.2f s",sender.leftPos];
    [_ugcEdit startPlayFromTime:sender.leftPos toTime:sender.rightPos];
    [_videoPreview setPlayBtn:YES];
}


- (void)onVideoRangeRightChanged:(TXVideoRangeSlider *)sender {
    [_ugcEdit pausePlay];
    [_videoPreview setPlayBtn:NO];
}

- (void)onVideoRangeRightChangeEnded:(TXVideoRangeSlider *)sender
{
    _videoRangeSlider.currentPos = sender.leftPos;
    _timeTipsLabel.text = [NSString stringWithFormat:@"%.2f s",sender.leftPos];
    [_ugcEdit startPlayFromTime:sender.leftPos toTime:sender.rightPos];
    [_videoPreview setPlayBtn:YES];
}


- (void)onVideoRangeLeftAndRightChanged:(TXVideoRangeSlider *)sender {
    
}

- (void)onVideoRange:(TXVideoRangeSlider *)sender seekToPos:(CGFloat)pos {
    [_ugcEdit previewAtTime:pos];
    [_videoPreview setPlayBtn:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
