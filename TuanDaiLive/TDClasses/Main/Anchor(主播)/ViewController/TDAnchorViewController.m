//
//  TDAnchorViewController.m
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TDAnchorViewController.h"
#import "TCIMPlatform.h"
#import "TCLiveListModel.h"
#import "TCMsgHandler.h"
#import "TDAnchorView.h"
#import "TDRequestModel.h"
#import "MD5And3DES.h"
#import "TDNetworkManager.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TCPusherMgr.h"

@interface TDAnchorViewController ()<TXLivePushListener>
{

}

//视频画面的父view
@property (nonatomic,strong) UIView *playerView;
//关闭button
@property (nonatomic,strong) UIButton *closeBtn;
//是否正在播放
@property (nonatomic,assign)BOOL isPlayer;
//是否打开麦克风
@property (nonatomic,assign)BOOL isOpenMic;
//是否打开了预览
@property (nonatomic,assign)BOOL isPreviewing;
// 是否打开了闪光灯
@property (nonatomic, assign) BOOL isFlash;
//腾讯直播推流
@property (nonatomic, strong) TXLivePush *txLivePublisher;
// 腾讯推流参数配置
@property (nonatomic, strong) TXLivePushConfig *txLivePushonfig;
// 直播用户信息
@property (nonatomic, strong) TCLiveInfo *liveInfo;
//群组相关处理
@property (nonatomic,strong) AVIMMsgHandler *msgHandler;
//主播页面的im、弹幕、礼物逻辑处理view
@property (nonatomic,strong) TDAnchorView *audienceView;

@end

@implementation TDAnchorViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"销毁了");
}

//test
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self startPush];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主播页";
    //前后台切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //创建UI
    [self createUI];
    
}

- (void)createUI{
    //1、视频画面的父Veiw
    _playerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, TDMain_Screen_Width, TDMain_Screen_Height)];
    _playerView.backgroundColor = UIColorFromRGB(0xFF4040);
    [self.view addSubview:_playerView];
    
    //2、创建关闭页面Button
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(TDMain_Screen_Width-40*TDAutoSizeScaleX, 10*TDAutoSizeScaleX, 30*TDAutoSizeScaleX, 50*TDAutoSizeScaleX)];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(exitRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
}

#pragma mark - 启动推流页面
- (void)startPush{
    TCLiveInfo *publishInfo = [[TCLiveInfo alloc] init];
    publishInfo.userinfo = [[TCLiveUserInfo alloc] init];
    publishInfo.userinfo.location = @"东莞";
    publishInfo.title = @"主题";
    publishInfo.userid = @"用户ID";
    
    self.liveInfo = publishInfo;
    
    //初始化对象
    [self initPushObject];
    //创建直播聊天室
    [self createLiveRoom];
    
}

#pragma mark - 初始化腾讯推流对象
- (void)initPushObject{
    //1、推流参数_config
    self.txLivePublisher = [[TXLivePush alloc] initWithConfig:_txLivePushonfig];
    self.audienceView.txLivePublisher = self.txLivePublisher;
}

#pragma mark - 创建直播聊天室
- (void)createLiveRoom{
    // 创建群组
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDic = [ud objectForKey:@"userInfo"];
    //    TCUserInfoData  *profile = [[TCUserInfoMgr sharedInstance] getUserProfile];
    _liveInfo.userinfo.headpic = [userInfoDic objectForKey:@"head"];
    _liveInfo.userinfo.nickname = [userInfoDic objectForKey:@"nickname"];
    
    __weak typeof(self) weakSelf = self;
    _msgHandler = [[AVIMMsgHandler alloc] init];
    
    _liveInfo.groupid = [NSString stringWithFormat:@"%@",[userInfoDic objectForKey:@"user_id"]];
    //申请加入群组
    [_msgHandler joinLiveRoom:_liveInfo.groupid handler:^(int errCode) {
        if (errCode==0) {
            //获取推流url
            //参数配置
            TDRequestModel *starPushModel = [[TDRequestModel alloc] init];
            starPushModel.methodName = push_starPush;
            //获取时间戳
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timer=[dat timeIntervalSince1970];
            NSString*timeString = [NSString stringWithFormat:@"%0.f", timer];
            //token
            NSString *token = [NSString stringWithFormat:@"appid=%@&appkey=%@&timestamp=%@",TDAppid,TDAppkey,timeString];
            token = [MD5And3DES md5:token];
            starPushModel.param = @{@"appid":TDAppid,
                                    @"timestamp":timeString,
                                    @"token":token,
                                    @"room_id":[userInfoDic objectForKey:@"user_id"]
                                    };
            starPushModel.requestType = TDTuandaiSourceType;
            //发送请求
            [[TDNetworkManager sharedInstane] postRequestWithRequestModel:starPushModel hubModel:nil modelClass:nil callBack:^(TDResponeModel *responeModel) {
                if (responeModel.code==1) {
                    //启动rtmp
                    weakSelf.liveInfo.playurl = responeModel.responeData[@"push_url"];
                    //获取时间戳
                    weakSelf.liveInfo.timestamp = [timeString intValue];
                    if (0) {//添加分享
                    
                    } else {
                        [weakSelf startRtmp];
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:@"直播请求失败"];
                }
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"加入群组失败"];
        }
    }];
}

#pragma mark - 推流
- (BOOL)startRtmp{
    [self clearLog];
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgOpenCameraFailed];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgOpenMicFailed];
        return NO;
    }
    
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = self;
        [self.txLivePublisher setVideoQuality:VIDEO_QUALITY_HIGH_DEFINITION];
        
        if (!_isPreviewing) {
            [_txLivePublisher startPreview:self.playerView];
            _isPreviewing = YES;
        }
        if ([_txLivePublisher startPush:self.liveInfo.playurl] != 0) {
            [SVProgressHUD showErrorWithStatus:@"推流器启动失败"];
            return NO;
        }
        self.audienceView.isOpenMic = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    return YES;

}

#pragma mark - 停止推流 关闭按钮点击事件
- (void)exitRoom:(UIButton *)button{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDic = [ud objectForKey:@"userInfo"];
    //参数配置
    TDRequestModel *endPushModel = [[TDRequestModel alloc] init];
    endPushModel.methodName = push_endPush;
    //获取时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timer=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", timer];
    //token
    NSString *token = [NSString stringWithFormat:@"appid=%@&appkey=%@&timestamp=%@",TDAppid,TDAppkey,timeString];
    token = [MD5And3DES md5:token];
    endPushModel.param = @{@"appid":TDAppid,
                           @"timestamp":timeString,
                           @"token":token,
                           @"room_id":[userInfoDic objectForKey:@"user_id"]
                           };
    endPushModel.requestType = TDTuandaiSourceType;
    //发起请求
    [[TDNetworkManager sharedInstane] postRequestWithRequestModel:endPushModel hubModel:nil modelClass:nil callBack:^(TDResponeModel *responeModel) {
        if (responeModel.code == 1) {
            if(_txLivePublisher != nil)
            {
                _txLivePublisher.delegate = nil;
                [_txLivePublisher stopPreview];
                _isPreviewing = NO;
                [_txLivePublisher stopPush];
                _txLivePublisher.config.pauseImg = nil;
                _txLivePublisher = nil;
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                [[TCPusherMgr sharedInstance] changeLiveStatus:_liveInfo.userid status:TCLiveStatus_Offline handler:^(int errCode) {
                    
                }];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"退出房间失败"];
        }
    }];
}

#pragma mark - 清除聊天信息框信息
- (void)clearLog {
    
}

#pragma mark - 前后台切换
- (void)onAppDidEnterBackGround:(UIApplication*)app {
    
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
   
}

#pragma mark - 播放背景音乐


#pragma mark - MPMediaPickerControllerDelegate
//选中后调用
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *item = [items objectAtIndex:0];
    
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"MPMediaItemPropertyAssetURL = %@", url);
    
    if (mediaPicker.editing) {
        mediaPicker.editing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.txLivePublisher stopBGM];
            // 保存url去播放
            // [self saveAssetURLToFile: url];
        });
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//点击取消时回调
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 推流状态变化
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    if (EvtID == 1002) { // 开始推流
        self.isPlayer = YES;
    }
    //    NSLog(@"----------%d\n%@",EvtID,param);
}

// 推流画面的码率等
-(void) onNetStatus:(NSDictionary*) param {
    //    NSLog(@"----------\n%@",param);
}

#pragma mark - 懒加载
-(TXLivePushConfig *)txLivePushonfig {
    if (!_txLivePushonfig) {
        _txLivePushonfig = [[TXLivePushConfig alloc] init];
        
        _txLivePushonfig.frontCamera = YES;
        _txLivePushonfig.enableAutoBitrate = NO;
        _txLivePushonfig.videoBitratePIN = 1000;
        _txLivePushonfig.enableHWAcceleration = YES;
        
        //background push
        _txLivePushonfig.pauseFps = 10;
        _txLivePushonfig.pauseTime = 300;
        _txLivePushonfig.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
        _txLivePushonfig.enableAEC = YES;
        _txLivePushonfig.enableNAS = YES;
        
        //耳返
        _txLivePushonfig.enableAudioPreview = YES;
        
    }
    return _txLivePushonfig;
}

-(AVIMMsgHandler *)msgHandler {
    if (!_msgHandler) {
        _msgHandler = [[AVIMMsgHandler alloc] init];
    }
    return _msgHandler;
}

-(TDAnchorView *)audienceView {
    if (!_audienceView) {
        _audienceView = [[TDAnchorView alloc] initWithFrame:self.view.frame];
        [self.playerView insertSubview:_audienceView atIndex:0];
        _audienceView.msgHandler = self.msgHandler;
        
        [_audienceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.playerView);
        }];
    }
    return _audienceView;
}

@end
