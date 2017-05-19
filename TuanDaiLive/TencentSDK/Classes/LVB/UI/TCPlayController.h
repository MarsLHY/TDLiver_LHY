//
//  PlayController.h
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXRTMPSDK/TXLivePlayer.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TCPlayDecorateView.h"
#import "TCLiveListModel.h"
#import "TCPlayUGCDecorateView.h"
#import "TXRTMPSDK/TXUGCRecordTypeDef.h"
#import "TXRTMPSDK/TXUGCRecordListener.h"

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000

/**
 *  播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */
extern NSString *const kTCLivePlayError;

@interface TCPlayController : UIViewController<UITextFieldDelegate, TXLivePlayListener,TCPlayDecorateDelegate, TCPlayUGCDecorateViewDelegate, TXVideoRecordListener>

typedef void(^videoIsReadyBlock)();

@property (nonatomic, assign) BOOL  enableLinkMic;
@property (nonatomic, assign) BOOL  log_switch;
@property (nonatomic, retain) TCPlayDecorateView *logicView;

-(id)initWithPlayInfo:(TCLiveInfo *)info  videoIsReady:(videoIsReadyBlock)videoIsReady;

-(BOOL)startRtmp;

- (void)stopRtmp;

- (void)onAppDidEnterBackGround:(UIApplication*)app;

- (void)onAppWillEnterForeground:(UIApplication*)app;
@end
