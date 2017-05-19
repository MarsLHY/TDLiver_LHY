//
//  TCTLSPlatform.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/4.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCTLSPlatform.h"

static TCTLSPlatform *_sharedInstance = nil;

@interface TCTLSPlatform()
{
    // 保存对应的函数指针
    TLSSucc _pwdRegSucc;
    TLSFail _pwdRegFail;
    TLSSucc _pwdLoginSucc;
    TLSFail _pwdLoginFail;
    TLSSucc _guestLoginSucc;
    TLSFail _guestLoginFail;
}
@end

@implementation TCTLSPlatform

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCTLSPlatform alloc] init];
    });
    return _sharedInstance;
}

- (int)pwdRegister:(NSString *)identifier andPassword:(NSString *)password succ:(TLSSucc)succ fail:(TLSFail)fail {
    _pwdRegSucc = succ;
    _pwdRegFail = fail;
    
    int ret = [[TLSHelper getInstance] TLSStrAccountReg:identifier andPassword:password andTLSStrAccountRegListener:self];
    if (ret != 0) {
        return ret;
    }
    return 0;
}

- (int)pwdLogin:(NSString *)identifier andPassword:(NSString *)password succ:(TLSSucc)succ fail:(TLSFail)fail {
    _pwdLoginSucc = succ;
    _pwdLoginFail = fail;
    
    int ret = [[TLSHelper getInstance] TLSPwdLogin:identifier andPassword:password andTLSPwdLoginListener:self];
    if (ret != 0) {
        return ret;
    }
    return 0;
}

- (int)guestLogin:(TLSSucc)succ fail:(TLSFail)fail {
    _guestLoginSucc = succ;
    _guestLoginFail = fail;
    TLSUserInfo *info = [[TLSHelper getInstance] getGuestIdentifier];
    
    if (info && ![[TLSHelper getInstance] needLogin:[info identifier]]) {
        if (_guestLoginSucc) {
            _guestLoginSucc(info);
        }
    }
    else {
        int ret = [[TLSHelper getInstance] TLSGuestLogin:self];
        if (ret != 0) {
            return ret;
        }
    }
    return 0;
}

#pragma mark - TLSStrAccountRegListener

- (void)OnStrAccountRegSuccess:(TLSUserInfo *)userInfo {
    if (_pwdRegSucc) {
        _pwdRegSucc(userInfo);
    }
}

- (void)OnStrAccountRegFail:(TLSErrInfo *)errInfo {
    if (_pwdRegFail) {
        _pwdRegFail(errInfo);
    }
}

- (void)OnStrAccountRegTimeout:(TLSErrInfo *)errInfo {
    if (_pwdRegFail) {
        _pwdRegFail(errInfo);
    }
}


#pragma mark - TLSPwdLoginListener

- (void)OnPwdLoginNeedImgcode:(NSData *)picData andErrInfo:(TLSErrInfo *)errInfo {
    [[HUDHelper sharedInstance] syncStopLoading];
    // ...
}

- (void)OnPwdLoginReaskImgcodeSuccess:(NSData *)picData {
    [[HUDHelper sharedInstance] syncStopLoading];
    // ...
}

- (void)OnPwdLoginSuccess:(TLSUserInfo *)userInfo {
    if (_pwdLoginSucc) {
        _pwdLoginSucc(userInfo);
    }
}

- (void)OnPwdLoginFail:(TLSErrInfo *)errInfo {
    if (_pwdLoginFail) {
        _pwdLoginFail(errInfo);
    }
}

- (void)OnPwdLoginTimeout:(TLSErrInfo *)errInfo {
    if (_pwdLoginFail) {
        _pwdLoginFail(errInfo);
    }
}

#pragma mark - TLSGuestLoginListener

- (void)OnGuestLoginSuccess:(TLSUserInfo *)userInfo {
    if (_guestLoginSucc) {
        _guestLoginSucc(userInfo);
    }
}

- (void)OnGuestLoginFail:(TLSErrInfo *)errInfo {
    if (_guestLoginFail) {
        _guestLoginFail(errInfo);
    }
}

- (void)OnGuestLoginTimeout:(TLSErrInfo *)errInfo {
    if (_guestLoginFail) {
        _guestLoginFail(errInfo);
    }
}


@end


