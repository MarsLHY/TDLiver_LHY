//
//  TCVideoEditPrevController
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/4/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoEditPrevController.h"
#import "TCVideoPublishController.h"
#import <TXRTMPSDK/TXUGCEditer.h>
#import <MBProgressHUD/MBProgressHUD.h>

typedef  NS_ENUM(NSInteger,ActionType)
{
    ActionType_Save,
    ActionType_Publish,
    ActionType_Save_Publish,
};

@interface TCVideoEditPrevController ()<TXVideoGenerateListener,TXVideoComposeListener,TCVideoPreviewDelegate>

@end

@implementation TCVideoEditPrevController {
    TCVideoPreview  *_videoPreview;
    TXUGCJoiner     *_ugcJoin;
    TXUGCEditer     *_ugcEdit;
    CGFloat         _currentPos;
    BOOL            _saveToLocal;
    NSString        *_outFilePath;
    
    ActionType      _actionType;
}

//- (id)init
//{
//    self = [super initWithNibName:@"Myview" bundle:nil];
//    if (self != nil)
//    {
//        // Further initialization if needed
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if 0
    _outFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _outFilePath = [documentsDirectory stringByAppendingPathComponent:@"output.mp4"];
#endif
  
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    customBackButton.tintColor = UIColorFromRGB(0x0accac);
    self.navigationItem.title = @"视频预览";
    
    _actionType = -1;
}

- (void)goBack
{
    [self onVideoPause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _videoPreview = [[TCVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.prevPlaceHolder.width, self.prevPlaceHolder.height) coverImage:[TXUGCVideoInfoReader getVideoInfo:_composeArray.firstObject].coverImage];
    _videoPreview.delegate = self;
    [self.prevPlaceHolder addSubview:_videoPreview];

    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;

    _ugcJoin = [[TXUGCJoiner alloc] initWithPreview:param];
    [_ugcJoin setVideoPathList:_composeArray];
    _ugcJoin.previewDelegate = _videoPreview;
    _ugcJoin.composeDelegate = self;
    [self play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_ugcJoin pausePlay];
}

- (void)play{
    [_ugcJoin startPlay];
    [_videoPreview setPlayBtn:YES];
}


#pragma mark TCVideoPreviewDelegate
- (void)onVideoPlay
{
    if (_ugcJoin) {
        [_ugcJoin startPlay];
    }else{

    }
}

- (void)onVideoPause
{
    if (_ugcJoin) {
        [_ugcJoin pausePlay];
    }else{
        
    }
}

- (void)onVideoResume
{
    if (_ugcJoin) {
        [_ugcJoin resumePlay];
    } else {
        
    }
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _currentPos = time;
    
}
- (void)onVideoPlayFinished
{
    [_ugcJoin startPlay];
}

-(void) onComposeComplete:(TXComposeResult *)result
{
    if(result.retCode == 0)
    {
        if (_actionType == ActionType_Save || _actionType == ActionType_Save_Publish) {
            UISaveVideoAtPathToSavedPhotosAlbum(_outFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else{
            [self performSelector:@selector(video:didFinishSavingWithError:contextInfo:) withObject:nil];
        }
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频合成失败"
                                                            message:[NSString stringWithFormat:@"错误码：%ld 错误信息：%@",(long)result.retCode,result.descMsg]
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void) onComposeProgress:(float)progress {
    [MBProgressHUD HUDForView:self.view].progress = progress;
}
// ------

- (IBAction)saveToLocal:(id)sender {
    _actionType = ActionType_Save;
    [self process];
}
- (IBAction)publish:(id)sender {
    _actionType = ActionType_Publish;
    [self process];
}
- (IBAction)saveAndPublish:(id)sender {
    _actionType = ActionType_Save_Publish;
    [self process];
}


- (void)process {
    [_videoPreview setPlayBtn:NO];
    [self onVideoPause];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"视频生成中...";
    if (_ugcJoin) {
        [_ugcJoin composeVideo:VIDEO_COMPRESSED_540P videoOutputPath:_outFilePath];
    }
    
    // Set the bar determinate mode to show task progress.
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (_actionType == ActionType_Save) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self publish];
}

- (void)publish {
    TCVideoPublishController *vc = [[TCVideoPublishController alloc] initWithPath:_outFilePath
                                                                         videoMsg:[TXUGCVideoInfoReader getVideoInfo:_outFilePath]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
