//
//  TCTLSCommon.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSSDK/TLSUserInfo.h"

typedef NS_ENUM(NSInteger, TLSSmsState) {
    START        = 1,
    SENDING_SMS  = 2,
    SENDED_SMS   = 3,
};

@interface SmsTimerData : NSObject

@property int remainSecond;

@end


@protocol TLSUILoginListener <NSObject>

/**
 *  TLS帐号登录成功
 *
 *  @param userinfo 登录成功的用户
 */
- (void)TLSUILoginOK:(TLSUserInfo *)userinfo;

@end
