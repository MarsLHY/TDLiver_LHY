//
//  TCTLSPlatform.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/4.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSSDK/TLSPwdLoginListener.h"
#import "TLSSDK/TLSSmsLoginListener.h"
#import "TLSSDK/TLSGuestLoginListener.h"
#import "TLSSDK/TLSStrAccountRegListener.h"
#import "TLSSDK/TLSUserInfo.h"
#import "TLSSDK/TLSErrInfo.h"
#import "TLSSDK/TLSHelper.h"
#import "TCTLSCommon.h"

typedef void (^TLSSucc)(TLSUserInfo *userInfo);
typedef void (^TLSFail)(TLSErrInfo *errInfo);

/**
 *  TLS注册登录相关接口封装
 *  在TLS注册/登录前 必须先初始化IMSDK：[[TCIMPlatform sharedInstance] initIMSDK];
 */
@interface TCTLSPlatform : NSObject <TLSPwdLoginListener, TLSGuestLoginListener, TLSStrAccountRegListener>

+ (instancetype)sharedInstance;

/**  用户名密码注册
 *   返回值：0：接口调用成功
 *         非0：内部错误
 */
- (int)pwdRegister:(NSString *)identifier andPassword:(NSString *)password succ:(TLSSucc)succ fail:(TLSFail)fail;

/**  用户名密码登录
 *   返回值：0：接口调用成功
 *         非0：内部错误
 */
- (int)pwdLogin:(NSString *)identifier andPassword:(NSString *)password succ:(TLSSucc)succ fail:(TLSFail)fail;

/**  游客登录
 *   返回值：0：接口调用成功
 *         非0：内部错误
 */
- (int)guestLogin:(TLSSucc)succ fail:(TLSFail)fail;



@end
