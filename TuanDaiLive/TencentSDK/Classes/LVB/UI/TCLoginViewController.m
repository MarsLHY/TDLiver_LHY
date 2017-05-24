//
//  TCLoginViewController.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLoginViewController.h"
#import "TCIMPlatform.h"
#import "ImSDK/TIMComm.h"
#import "TLSSDK/TLSHelper.h"
#import "TCUtil.h"
#import "TCLoginParam.h"
#import "TCTLSLoginViewController.h"
#import "TCTLSRegisterViewController.h"
#import "TLSUserInfo+TDAdd.h"

@interface TCLoginViewController ()
{
    TCLoginParam *_loginParam;
}
@end

@implementation TCLoginViewController

- (void)dealloc {
    if (_loginParam) {
        // 持久化param
        [_loginParam saveToLocal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 先判断是否自动登录
    BOOL isAutoLogin = [TCIMPlatform isAutoLogin];
    if (isAutoLogin) {
        _loginParam = [TCLoginParam loadFromLocal];
    }
    else {
        _loginParam = [[TCLoginParam alloc] init];
    }
    
    // 登录前需要先初始化IMSDK
    [[TCIMPlatform sharedInstance] initIMSDK];

    if (isAutoLogin && [_loginParam isValid]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoLogin];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pullLoginUI];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - login

- (void)autoLogin {
    if ([_loginParam isExpired]) {
        // 刷新票据
        [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
    }
    else {
        [self loginIMSDK];
    }
}

- (void)pullLoginUI {
    TCTLSLoginViewController *tlsLoginViewController = [[TCTLSLoginViewController alloc] init];
    tlsLoginViewController.loginListener = self;
    [self.navigationController pushViewController:tlsLoginViewController animated:YES];
}

- (void)loginWith:(TLSUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo) {
            _loginParam.identifier = userInfo.identifier;
            _loginParam.userSig = userInfo.userSig;
            _loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
            
            [self loginIMSDK];
        }
    });
}

- (void)loginIMSDK {
    __weak TCLoginViewController *weakSelf = self;
    
    [[TCIMPlatform sharedInstance] login:_loginParam succ:^{
        [SVProgressHUD dismiss];
        // 持久化param
        [_loginParam saveToLocal];
        // 进入主界面
        [[AppDelegate sharedAppDelegate] enterMainUI];
        
    } fail:^(int code, NSString *msg) {
        [weakSelf pullLoginUI];
    }];
}

#pragma mark - delegate<TLSUILoginListener>

- (void)TLSUILoginOK:(TLSUserInfo *)userinfo {
    [SVProgressHUD showWithStatus:@"登录中..."];
    [self loginWith:userinfo];
}

#pragma mark - 刷新票据代理

- (void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo {
    NSLog(@"OnRefreshTicketSuccess");
    [self loginWith:userInfo];
}

- (void)OnRefreshTicketFail:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketFail");
    _loginParam.tokenTime = 0;
    [self pullLoginUI];
}

- (void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketTimeout");
    [self OnRefreshTicketFail:errInfo];
}

@end
