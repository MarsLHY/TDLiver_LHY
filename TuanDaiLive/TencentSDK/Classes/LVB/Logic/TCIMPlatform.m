//
//  TCIMPlatform.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCIMPlatform.h"
#import "ImSDK/TIMManager.h"
#import "ImSDK/IMSdkInt.h"
#import "TLSSDK/TLSHelper.h"
#import "TCLoginParam.h"
#import "TCUserInfoMgr.h"
#import "TCConstants.h"
#import "TCUtil.h"
#ifndef APP_EXT
#import "AppDelegate.h"
#endif

#define kIMAutoLoginKey       @"kIMAutoLoginKey"
#define kEachKickErrorCode    6208   //互踢下线错误码

static TCIMPlatform *_sharedInstance = nil;

@interface TCIMPlatform()
{
    TIMLoginParam *_loginParam;
}
@end

@implementation TCIMPlatform

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCIMPlatform alloc] init];
    });
    return _sharedInstance;
}

+ (BOOL)isAutoLogin {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    NSNumber *num = [defaults objectForKey:kIMAutoLoginKey];
    return [num boolValue];
}

+ (void)setAutoLogin:(BOOL)autoLogin {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    [defaults setObject:@(autoLogin) forKey:kIMAutoLoginKey];
}

- (void)initIMSDK {
    //kTCIMSDKAppId
    //kTCIMSDKAccountType
    static dispatch_once_t predicate;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *tencentSdkInfo = [ud objectForKey:TencentSdkInfo];
    int sdkid = [[tencentSdkInfo objectForKey:@"sdkId"] intValue];
    NSString *accountType = [tencentSdkInfo objectForKey:@"accountType"];
    
    dispatch_once(&predicate, ^{
        [[TIMManager sharedInstance] setLogLevel:TIM_LOG_ERROR];
        [[TIMManager sharedInstance] setEnv:0]; // 0 正式环境（默认） 1 测试环境
        [[TIMManager sharedInstance] initSdk:sdkid accountType:accountType];
        [[TIMManager sharedInstance] setUserStatusListener:self];
    });
}

#ifndef APP_EXT
- (void)guestLogin:(TLSSucc)succ fail:(TLSFail)fail {
    // 先初始化IMSDK
//    [self initIMSDK];
    
    TLSErrInfo *err = [[TLSErrInfo alloc] init];
    __weak typeof(self) weakSelf = self;
    int ret = [[TCTLSPlatform sharedInstance] guestLogin:^(TLSUserInfo *userInfo) {
        DebugLog(@"guestlogin success,id:%@", userInfo.identifier);
        if (succ) {
            // TLS登录成功后再登录IMSDK
            TCLoginParam *param = [[TCLoginParam alloc] init];
            param.identifier = userInfo.identifier;
            param.userSig = [[TLSHelper getInstance] getTLSUserSig:userInfo.identifier];
            param.tokenTime = [[NSDate date] timeIntervalSince1970];
            
            [weakSelf login:param succ:^{
                [param saveToLocal];  // 持久化param
                if (succ) {
                    succ(userInfo);
                }
            } fail:^(int code, NSString *msg) {
                DebugLog(@"guestlogin failed,code:%d, msg:%@", code, msg);
                err.dwErrorCode = code;
                err.sErrorMsg = msg;
                err.sExtraMsg = @"IMSDK login failed";
                if (fail) {
                    fail(err);
                }
            }];
        }
        
    } fail:^(TLSErrInfo *errInfo) {
        if (fail) {
            fail(errInfo);
        }
    }];
    if (ret != 0) {
        if (fail) {
            TLSErrInfo *err = [[TLSErrInfo alloc] init];
            err.dwErrorCode = ret;
            err.sErrorMsg = @"内部错误";
            fail(err);
        }
    }
}
#endif

- (void)login:(TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail {
    if (!param) {
        return;
    }
    
    // 登录超时要十几秒，所以先检测网络状态，如果网络不通，就直接跳转到登录页面
    if ([[TIMManager sharedInstance] networkStatus] == TIM_NETWORK_STATUS_DISCONNECTED) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(-20001, @"网络超时，请稍后重试");
            });
        }
        return;
    }
    
    _loginParam = param;
    __weak TCIMPlatform *weakSelf = self;
    
    [[TIMManager sharedInstance] login:param succ:^{
        DebugLog(@"login success:%@ sig:%@", param.identifier, param.userSig);
        [TCIMPlatform setAutoLogin:YES];
        [[TCUserInfoMgr sharedInstance] setIdentifier:param.identifier];
        
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        DebugLog(@"login failed: code=%d err=%@", code, msg);
#ifdef APP_EXT
        if (fail) {
            fail(code, msg);
        }
#else
        if (code == kEachKickErrorCode) {
            [weakSelf offlineKicked:param succ:succ fail:fail];
        }
        else {
            if (fail) {
                fail(code, msg);
            }
        }
#endif
    }];
}

- (void)reLogin:(TIMLoginSucc)succ fail:(TIMFail)fail {
    if (_loginParam == nil) {
        if (fail) {
            fail(kError_InvalidParam, @"参数错误");
        }
        return;
    }
    
    [[TIMManager sharedInstance] login:_loginParam succ:^{
        DebugLog(@"relogin success,id:%@", _loginParam.identifier);
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        DebugLog(@"relogin failed,code:%d, msg:%@", code, msg);
        if (fail) {
            fail(code, msg);
        }
    }];
}

- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail {
    __weak TCIMPlatform *weakSelf = self;
    
    [[TIMManager sharedInstance] logout:^{
        [weakSelf onLogoutCompletion];
        [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotification object:nil];
        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        [weakSelf onLogoutCompletion];
        if (fail) {
            fail(code, msg);
        }
    }];
}

- (TIMLoginParam *)getLoginParam {
    if (_loginParam) {
        return _loginParam;
    }
    return [[TIMLoginParam alloc] init];
}

//离线被踢
//用户离线时，在其它终端登录过，再次在本设备登录时，会提示被踢下线，需要重新登录
- (void)offlineKicked:(TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail {
#ifndef APP_EXT
    TCLoginParam *tcParam = [TCLoginParam loadFromLocal];
    if (tcParam.isLastAppExt) {
        // 重新登录
        [tcParam saveToLocal];
        [self alertView:nil clickedButtonAtIndex:1];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知"
                                                    message:@"您的账号于另一台手机上登录"
                                                   delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"重新登录", nil];
    [alert show];
#endif
}

- (void)onLogoutCompletion {
    [TCIMPlatform setAutoLogin:NO];
}

#pragma mark - TIMUserStatusListener

/**
 *  踢下线通知
 */
- (void)onForceOffline {
#ifndef APP_EXT
    TCLoginParam *tcParam = [TCLoginParam loadFromLocal];
    if (tcParam.isLastAppExt) {
        // 重新登录
        [tcParam saveToLocal];
        [self alertView:nil clickedButtonAtIndex:1];
        return;
    }
    // 在线被踢，先发送logout通知
    [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotification object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知"
                                                    message:@"您的账号于另一台手机上登录"
                                                   delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"重新登录", nil];
    [alert show];
#endif
}

/**
 *  踢下线通知
 */
- (void)onForceOfflineAlert {
#ifndef APP_EXT
    // 在线被踢，先发送logout通知
    [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotification object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知"
                                                    message:@"您的账号于另一台手机上登录."
                                                   delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"重新登录", nil];
    [alert show];
#endif
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err {
    NSLog(@"断线重连失败");
}

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired {
    // 刷新票据
    [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
}

#pragma mark - TLSRefreshTicketListener

/**
 *  刷新票据成功
 *
 *  @param userInfo 用户信息
 */
- (void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo {
    // 更新本地票据
    TCLoginParam *param = [TCLoginParam loadFromLocal];
    param.userSig = [[TLSHelper getInstance] getTLSUserSig:userInfo.identifier];
    param.tokenTime = [[NSDate date] timeIntervalSince1970];
    [param saveToLocal];
    
    // 重新登录
    [[TIMManager sharedInstance] login: param succ:^{
        [TCIMPlatform setAutoLogin:YES];
    } fail:^(int code, NSString *msg) {
        NSLog(@"刷新票据，登录失败: code=%d err=%@", code, msg);
    }];
}

/**
 *  刷新票据失败
 *
 *  @param errInfo 错误信息
 */
- (void)OnRefreshTicketFail:(TLSErrInfo *)errInfo {
    NSString *err = [[NSString alloc] initWithFormat:@"刷新票据失败\ncode:%d, error:%@", errInfo.dwErrorCode, errInfo.sErrorTitle];
    NSLog(@"%@",err);
    
    TCLoginParam *param = [TCLoginParam loadFromLocal];
    param.tokenTime = 0;
    [param saveToLocal];
#ifndef APP_EXT
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [self logout:^{
        [app enterLoginUI];
    } fail:^(int code, NSString *msg) {
        [app enterLoginUI];
    }];
#endif
}

/**
 *  刷新票据超时
 *
 *  @param errInfo 错误信息
 */
- (void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo {
    [self OnRefreshTicketFail:errInfo];
}

#pragma mark - UIAlertViewDelegate

//根据被点击按钮的索引处理点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
#ifndef APP_EXT
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    if (buttonIndex == 0) {
        // 退出
        [self logout:^{
            [app enterLoginUI];
        } fail:^(int code, NSString *msg) {
            [app enterLoginUI];
        }];
    }
    else {
        // 重新登录
        [self login:_loginParam succ: ^{
            [app enterMainUI];
        } fail:^(int code, NSString *msg) {
            [app enterLoginUI];
        }];
    }
#endif
}

@end
