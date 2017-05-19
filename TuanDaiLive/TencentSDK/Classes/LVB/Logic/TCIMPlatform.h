//
//  TCIMPlatform.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImSDK/ImSDK.h"
#import "ImSDK/TIMComm.h"
#import "ImSDK/TIMCallback.h"
#import "TLSSDK/TLSRefreshTicketListener.h"
#ifndef APP_EXT
#import "TCTLSPlatform.h"
#endif

#define  logoutNotification  @"logoutNotification"

/**
 *  ImSDK登录相关接口封装
 */
@interface TCIMPlatform : NSObject <TIMUserStatusListener, TLSRefreshTicketListener, TIMGroupAssistantListener>

+ (instancetype)sharedInstance;

+ (BOOL)isAutoLogin;

+ (void)setAutoLogin:(BOOL)autoLogin;

// 初始化IMSDK，传入appid等信息
- (void)initIMSDK;

#ifndef APP_EXT
// 游客登录，调用该接口后可以直接进行IM通信（内部已经完成TLS账号注册登录以及IM登录）
- (void)guestLogin:(TLSSucc)succ fail:(TLSFail)fail;
#endif

// 登录IMSDK，调用该接口前需要先完成TLS登录
- (void)login:(TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

// 退出IMSDK
- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

// 获取login传入的login param参数
- (TIMLoginParam *)getLoginParam;

- (void)onForceOfflineAlert;

- (void)reLogin:(TIMLoginSucc)succ fail:(TIMFail)fail;

@end
