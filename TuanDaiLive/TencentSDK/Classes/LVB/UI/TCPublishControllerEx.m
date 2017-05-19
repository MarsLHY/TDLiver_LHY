//
//  ViewController.m
//  PituMotionDemo
//
//  Created by billwang on 16/5/11.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import "TCPublishControllerEx.h"
#if POD_PITU
#import "MCCameraDynamicView.h"
#import "MCTip.h"
#import "MaterialManager.h"
#import <AVFoundation/AVFoundation.h>
#import <PituAlgorithm/MCFilterManager.h>
#import "TXRTMPSDK/TXLivePlayer.h"

#define MCDATAOUTPUT_DEBUG 0

@interface TCPublishControllerEx () <AVCaptureVideoDataOutputSampleBufferDelegate, MCFilterDelegate, MCDataOutputDelegate, MCCameraDynamicDelegate, MCFilterManagerDelegate>

@property (nonatomic, assign) BOOL viewAppeared;

@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;

#if MCDATAOUTPUT_DEBUG
@property (nonatomic, strong) UIImageOrientationFilter *previewFilter;
#endif
@property (nonatomic, strong) GPUImageView *previewView;
@property (nonatomic, strong) MCFilterManager *filterManager;
@property (atomic, strong) MCSampleBuffer *mcSampleBuffer;

@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, strong) MCCameraDynamicView *tmplBar;

@end

@implementation TCPublishControllerEx {
    BOOL _torch_switch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // setup UI
    self.previewView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.previewView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.previewView];
    
    [self.view addSubview:self.previewView];
    [self.view sendSubviewToBack:self.previewView];
    /*
    self.filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.filterBtn setBackgroundColor:[UIColor clearColor]];
    [self.filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    self.filterBtn.frame = CGRectMake(self.view.bounds.size.width - 70.f, self.view.bounds.size.height - 60.f, 60.f, 40.f);
    self.filterBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.filterBtn addTarget:self action:@selector(filterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.filterBtn];
    self.filterBtn.hidden = YES;
    
    self.tmplBar = [[MCCameraDynamicView alloc] initWithFrame:CGRectMake(0.f, self.view.bounds.size.height - 80.f, self.view.bounds.size.width - 80.f, 80.f)];
    self.tmplBar.delegate = self;
    [self.view addSubview:self.tmplBar];
    self.tmplBar.hidden = YES;
    */
#if MCDATAOUTPUT_DEBUG
    self.previewFilter = (UIImageOrientationFilter *)[FilterFactory createGPUFilter:MIC_ORIENTATION];
    [self.previewFilter addTarget:self.previewView];
#endif
    
//#warning step 1 初始化FilterManager
    MCFilterManager *filterManager = [[MCFilterManager alloc] initWithFaceDetectTargetMaxEdge:180.f];
    if ([self isSuitableMachine:5]) {
        filterManager.preferedVideoSize = CGSizeMake(540, 960);
    } else {
        filterManager.preferedVideoSize = CGSizeMake(360, 640);
    }
    filterManager.preferedVideoSize = CGSizeMake(540, 960);
    filterManager.delegate = self;
    filterManager.outputFormat = MCDataOutputFormatBGRA;
    filterManager.outputRotation = MCFilterOutputRotationPortrait;
//    filterManager.outputRotation = MCFilterOutputRotationLandscapeLeft;
#if !MCDATAOUTPUT_DEBUG
    filterManager.previewFilter = self.previewView;
#endif
    self.filterManager = filterManager;
    // 防止其它地方错误调用freezeGPU导致FilterFactory单例被锁
    [FilterFactory unfreezeGPU];
//#warning step 1.1 设置美颜等级1~5
    [self.filterManager setupBeautyLevel:3];
    
    // init camera
    [self setupCameraDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageDownloadProgress:) name:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaServiceReseted:) name:AVAudioSessionMediaServicesWereResetNotification object:[AVAudioSession sharedInstance]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.filterManager.delegate = nil;
}

- (void)mediaServiceReseted:(NSNotification *)notification {
    [self.filterManager mediaServicesReseted:notification];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    // 恢复动效
//    self.filterManager.motionInactive = NO;
//    @try {
//        // 启动摄像头
//        if (self.captureSession) {
//            [self.captureSession startRunning];
//            // 启动推流回吐
//            [self.filterManager startOutputData];
//        }
//    } @catch (NSException *exception) {
//        NSLog(@"some crazy happen");
//    } @finally {
//        
//    }
//
//    
//    self.viewAppeared = YES;
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    

//}


//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    // 暂停摄像头
//    if (self.captureSession) {
//        [self.captureSession stopRunning];
//    }
//    
//    // 暂停动效
//    self.filterManager.motionInactive = YES;
    
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

//}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    // 暂停摄像头
    if (self.captureSession) {
        [self.captureSession stopRunning];
        // 暂停推流回吐
        [self.filterManager stopOutputData:nil];
    }
    
    // 暂停动效
    self.filterManager.motionInactive = YES;
    
    // 锁住FilterFactory
    [FilterFactory freezeGPU];
    
    [super onAppDidEnterBackGround:app];
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    
    [super onAppWillEnterForeground:app];
    
    // 恢复FilterFactory
    [FilterFactory unfreezeGPU];
    
    // 恢复动效
    self.filterManager.motionInactive = NO;
    
    // 恢复摄像头
    if (self.captureSession) {
        [self.captureSession startRunning];
        // 启动推流回吐
        [self.filterManager startOutputData];
    }
}
/*
//#warning step 5.1 退后台暂停动效并锁住FilterFactory
- (void)viewWillResignActive:(NSNotification *)noti {
    // 暂停摄像头
    if (self.captureSession) {
        [self.captureSession stopRunning];
        // 暂停推流回吐
        [self.filterManager stopOutputData];
    }
    
    // 暂停动效
    self.filterManager.motionInactive = YES;
    
    // 锁住FilterFactory
    [FilterFactory freezeGPU];

    if ([self.txLivePublisher isPublishing]) {
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self.txLivePublisher resumePush];
        }];
        [self.txLivePublisher pausePush];
    }

}
//#warning step 5.2 后台返回恢复动效并解锁FilterFactory
- (void)viewDidBecomeActive:(NSNotification *)noti {

    if ([self.txLivePublisher isPublishing]) {
        [self.txLivePublisher resumePush];
    }
    
    // 恢复FilterFactory
    [FilterFactory unfreezeGPU];
    
    // 恢复动效
    self.filterManager.motionInactive = NO;
    
    // 恢复摄像头
    if (self.captureSession) {
        [self.captureSession startRunning];
        // 启动推流回吐
        [self.filterManager startOutputData];
    }
}
*/
//#warning step 2 传入帧数据
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.filterManager) {
        [self.filterManager receiveVideoSampleBuffer:sampleBuffer withFormat:UIImageFormat420V];
    }
}

//#warning step 3 处理提示语回调
#pragma mark - MCFilterDelegate

- (void)MCFilterNeedShowTips:(NSString *)type text:(NSString *)tips withDuration:(NSTimeInterval)duration {
    
}
- (void)MCFilterNeedHideTips:(NSString *)type {
    
}

//#warning step 4 传给后续模块继续处理帧数据，此时返回的帧数据和采样时的帧数据格式(420f)和方向(横屏右转)是一致的
#pragma mark - MCDataOutputDelegate

-(void)MCDataOutputProcessedSampleBuffer:(MCSampleBuffer *)mcSampleBuffer {
    // 确保sampleBuffer没用了之后再释放，释放时会free(data)
    self.mcSampleBuffer = mcSampleBuffer;
    if (!self.filterManager.motionInactive) {
        [self.txLivePublisher sendVideoSampleBuffer:mcSampleBuffer.sampleBuffer];
    }
}

#pragma mark - private

//#warning step 1.2 切换滤镜
- (void)filterButtonPressed {
    self.currentFilterIndex = (self.currentFilterIndex + 1) % 10;
    switch (self.currentFilterIndex) {
        case 1:
            [self.filterManager setupEffectFilter:MIC_PTU_FBBS params:@{@"style":@"LANGMAN"}];
            [self.filterBtn setTitle:@"浪漫" forState:UIControlStateNormal];
            break;
            
        case 2:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_LIGHTWHITE params:nil];
            [self.filterBtn setTitle:@"圣代" forState:UIControlStateNormal];
            break;
            
        case 3:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_MAPLERED params:nil];
            [self.filterBtn setTitle:@"莫斯科" forState:UIControlStateNormal];
            break;
            
        case 4:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_LIGHTRED params:nil];
            [self.filterBtn setTitle:@"樱红" forState:UIControlStateNormal];
            break;
            
        case 5:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_TIANMEI params:nil];
            [self.filterBtn setTitle:@"甜美" forState:UIControlStateNormal];
            break;
            
        case 6:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_RICHRED params:nil];
            [self.filterBtn setTitle:@"首尔" forState:UIControlStateNormal];
            break;
            
        case 7:
            [self.filterManager setupEffectFilter:MIC_PTU_FBBS params:@{@"style":@"NUANYANG"}];
            [self.filterBtn setTitle:@"暖阳" forState:UIControlStateNormal];
            break;
            
        case 8:
            [self.filterManager setupEffectFilter:MIC_PTU_ZIPAI_NEXTDOOR params:nil];
            [self.filterBtn setTitle:@"邻家" forState:UIControlStateNormal];
            break;
            
        case 9:
            [self.filterManager setupEffectFilter:MIC_PTU_FEN2_REAL params:nil];
            [self.filterBtn setTitle:@"粉嫩" forState:UIControlStateNormal];
            break;
            
        default:
            [self.filterManager setupEffectFilter:MIC_LENS params:nil];
            [self.filterBtn setTitle:@"原图" forState:UIControlStateNormal];
            break;
    }
}
//#warning step 1.3 切换动效素材
#pragma mark - MCCameraDynamicDelegate

- (void)motionTmplSelected:(NSString *)materialID {
    if (materialID == nil) {
        [MCTip hideText];
    }
    if ([MaterialManager isOnlinePackage:materialID]) {
        [self.filterManager selectMotionTmpl:materialID inDir:[MaterialManager packageDownloadDir]];
    } else {
        NSString *localPackageDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resource"];
        [self.filterManager selectMotionTmpl:materialID inDir:localPackageDir];
    }
}

- (void)setupCameraDevice {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            NSArray *cameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *cameraDevice in cameraDevices) {
                self.cameraDevice = cameraDevice;
                if (cameraDevice.position == AVCaptureDevicePositionFront) {
                    break;
                }
            }
            if (self.cameraDevice) {
//#warning step 1.4 前置摄像头可设置翻转
                self.filterManager.frontCameraMirror = self.cameraDevice.position == AVCaptureDevicePositionFront;
                
                [self.cameraDevice lockForConfiguration:nil];
                self.cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, 20);
                self.cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 10);
                [self.cameraDevice unlockForConfiguration];
                
                AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:nil];
                if (cameraInput) {
                    self.captureSession = [[AVCaptureSession alloc] init];
                    self.captureSession.sessionPreset = [self cameraSessionPreset];
                    if ([self.captureSession canAddInput:cameraInput]) {
                        [self.captureSession addInput:cameraInput];
                
                        
                        dispatch_queue_t videoDataQueue = dispatch_queue_create("com.tencent.pitu.videodata", NULL);
                        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
                        videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
                        [videoDataOutput setSampleBufferDelegate:self queue:videoDataQueue];
                        
                        NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
                        videoDataOutput.videoSettings = captureSettings;
                        
                        if ([self.captureSession canAddOutput:videoDataOutput]) {
                            [self.captureSession addOutput:videoDataOutput];
                            
                            if (self.viewAppeared || 1) {
                                [self.captureSession startRunning];
                                [self.filterManager startOutputData];
                            }
                        }
                    }
                }
            }
        }
    }];
}

- (void)packageDownloadProgress:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *progressDic = [notification object];
        CGFloat progress = [progressDic[kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS] floatValue];
        if (progress <= 0.f) {
            [MCTip showText:@"素材下载失败" inView:self.view afterDelay:2.f];
        }
    }
}

#pragma mark - overwrite selectors

-(BOOL)startRtmp{
    
    [super startRtmp];
    
    if (self.rtmpUrl.length == 0) {
        [self toastTip:@"无推流地址，请重新登录后重试!"];
        return NO;
    }
    
    if (!([self.rtmpUrl hasPrefix:@"rtmp://"] )) {
        [self toastTip:@"推流地址不合法，目前支持rtmp推流!"];
        return NO;
    }
    
    
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        //        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        [self.logicView closeVCWithError:kErrorMsgOpenCameraFailed Alert:YES Result:NO];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        //        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        [self.logicView closeVCWithError:kErrorMsgOpenMicFailed Alert:YES Result:NO];
        return NO;
    }
    
    NSArray* ver = [TXLivePlayer getSDKVersion];
    if ([ver count] >= 3) {
        NSString *logMsg = [NSString stringWithFormat:@"rtmp sdk version: %@.%@.%@",ver[0],ver[1],ver[2]];
        [self.logicView.logViewEvt setText:logMsg];
    }
    
    if(self.txLivePublisher != nil)
    {
        self.txLivePublisher.delegate = self;
        TXLivePushConfig *config = self.txLivePublisher.config;
        config.customModeType = CUSTOM_MODE_VIDEO_CAPTURE;
        config.videoResolution = VIDEO_RESOLUTION_TYPE_360_640;
        config.autoSampleBufferSize = YES;

        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            config.enableHWAcceleration  = NO;
        }else{
            config.enableHWAcceleration  = YES;
        }
        
        [self.txLivePublisher setBeautyFilterDepth:0 setWhiteningFilterDepth:0];
        self.txLivePublisher.config = config;
        if ([self.txLivePublisher startPush:self.rtmpUrl] != 0) {
//        if ([self.txLivePublisher startPush:@"rtmp://2157.livepush.myqcloud.com/live/2157_429f7b5f18ba11e6b91fa4dcbef5e35a?bizid=2157"] != 0) {
            NSLog(@"推流器启动失败");
            return NO;
        }
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    return YES;
}

- (void)stopRtmp {
    if(self.txLivePublisher != nil)
    {
        self.txLivePublisher.delegate = nil;
//        [self.txLivePublisher stopPreview];
        [self.txLivePublisher resumePush];
        [self.txLivePublisher stopPush];
        self.txLivePublisher = nil;
    }
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
    
    self.cameraDevice = nil;
    self.filterManager = nil;
    self.captureSession = nil;
    [self.previewView removeFromSuperview], self.previewView = nil;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void) clickCamera:(UIButton*) btn
{
    // 用设备初始化一个采集的输入对象
    NSArray *cameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *cameraDevice in cameraDevices) {
        if (cameraDevice.position != self.cameraDevice.position) {
            self.cameraDevice = cameraDevice;
            break;
        }
    }
	
    
    AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:nil];
    
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession.inputs count] > 0) {
        [self.captureSession removeInput:[self.captureSession.inputs objectAtIndex:0]];
    }
    
    if ([self.captureSession canAddInput:cameraInput]) {
        [self.captureSession addInput:cameraInput]; // 添加到Session
    }
    
    [self.captureSession commitConfiguration];
    self.filterManager.frontCameraMirror = self.cameraDevice.position == AVCaptureDevicePositionFront;
    
}

-(void) sliderValueChange:(UISlider*) obj
{
    if ((obj.tag == 0) ||  //美颜
        (obj.tag == 1)) { //美白
       [self.filterManager setupBeautyLevel:obj.value];
    }

    
    if (obj.tag == 2) { // 麦克风音量
        [self.txLivePublisher setMicVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 3) { // 背景音乐音量
        [self.txLivePublisher setBGMVolume:(obj.value/obj.maximumValue)];
    }
}

- (NSString *)cameraSessionPreset {
    if ([self isSuitableMachine:5]) {
        return AVCaptureSessionPresetiFrame960x540;
    }
    
    return AVCaptureSessionPreset640x480;
}

-(void) clickTorch:(UIButton*) btn
{
    if (self.txLivePublisher) {
        _torch_switch = !_torch_switch;
        if (![self toggleTorch:_torch_switch]) {
            _torch_switch = !_torch_switch;
            [self toastTip:@"闪光灯启动失败"];
        }
        
        if (_torch_switch == YES) {
            [self.logicView.btnTorch setImage:[UIImage imageNamed:@"flash_hover"] forState:UIControlStateNormal];
        }
        else
        {
            [self.logicView.btnTorch setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        }
    }
}


-(BOOL) toggleTorch:(BOOL) bEnable
{
    if(self.captureSession != nil)
    {
        AVCaptureDeviceInput * _input = [self.captureSession.inputs objectAtIndex:0];
        
        if(_input != nil)
        {
            AVCaptureDevice * _capDev = _input.device;
            
            if(_capDev != nil)
            {
                if([_capDev hasFlash] && [_capDev hasTorch] && [_capDev isTorchModeSupported:AVCaptureTorchModeOn])
                {
                    
                    if ( (bEnable == YES && _capDev.torchMode == AVCaptureTorchModeOn) ||
                        (bEnable == NO && _capDev.torchMode == AVCaptureTorchModeOff)) {
                        return YES;
                    }
                    
                    [_capDev lockForConfiguration:nil];
                    if (bEnable) {
                        _capDev.torchMode = AVCaptureTorchModeOn;
                    } else {
                        _capDev.torchMode = AVCaptureTorchModeOff;
                    }
                    [_capDev unlockForConfiguration];
                    
                    return bEnable == YES? _capDev.torchMode == AVCaptureTorchModeOn : _capDev.torchMode == AVCaptureTorchModeOff;
                }
            }
        }
    }
    
    return NO;
}

-(BOOL) isTorchON
{
    if(self.captureSession  != nil)
    {
        AVCaptureDeviceInput * _input = [self.captureSession .inputs objectAtIndex:0];
        
        if(_input != nil)
        {
            AVCaptureDevice * _capDev = _input.device;
            
            if(_capDev != nil)
            {
                return _capDev.torchMode == AVCaptureTorchModeOn;
            }
        }
    }
    
    return NO;
}

@end

#endif
