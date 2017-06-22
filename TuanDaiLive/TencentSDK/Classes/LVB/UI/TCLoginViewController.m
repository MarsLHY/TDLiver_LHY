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
#import "TDAnchorViewController.h"
#import "TDUserInfoMgr.h"
#import "MD5And3DES.h"
#import "TDRequestModel.h"
#import "TDNetworkManager.h"
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景图
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImgView.image = [UIImage imageNamed:@"loginBG.jpg"];
    [self.view addSubview:bgImgView];
    
    // 先判断是否自动登录
    BOOL isAutoLogin = [TCIMPlatform isAutoLogin];
    if (isAutoLogin) {
        _loginParam = [TCLoginParam loadFromLocal];
        //自动登录前需要先初始化IMSDK，手动登录在tls登录中初始化
        [[TCIMPlatform sharedInstance] initIMSDK];
    }
    else {
        _loginParam = [[TCLoginParam alloc] init];
    }
    
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
//        [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
        [self pullLoginUI];
    }
    else {
        [self loginIMSDK];
    }
}

- (void)pullLoginUI {
    TCTLSLoginViewController *tlsLoginViewController = [[TCTLSLoginViewController alloc] init];
    tlsLoginViewController.loginListener = self;
    [self.navigationController pushViewController:tlsLoginViewController animated:NO];
}

- (void)loginWith:(TLSUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo) {
            _loginParam.identifier = userInfo.identifier;
            _loginParam.userSig = userInfo.userSig;
            _loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
            //第一版新增
            _loginParam.accountType = userInfo.accountTypes;
            _loginParam.appidAt3rd = userInfo.appidAt3rd;
            _loginParam.sdkAppId = [userInfo.appidAt3rd intValue];
            
            [self loginIMSDK];
        }
    });
}

- (void)loginIMSDK {
    __weak TCLoginViewController *weakSelf = self;
    [[TCIMPlatform sharedInstance] login:_loginParam succ:^{
        //第一版新增 登录成功之后获取礼物列表并存储在本地
        [self getGiftList];
        // 持久化param
        [_loginParam saveToLocal];
        [SVProgressHUD dismiss];
        // 进入主界面
        [[AppDelegate sharedAppDelegate] enterMainUI];
        
    } fail:^(int code, NSString *msg) {
        [SVProgressHUD showWithStatus:msg];
        [SVProgressHUD dismissWithDelay:1];
        [weakSelf pullLoginUI];
    }];
}

#pragma mark - 登录成功即刻获取礼物列表并存储
- (void)getGiftList{
    //参数配置
    TDRequestModel *loginModel = [[TDRequestModel alloc] init];
    loginModel.methodName = giftList;
    //获取时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timer=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", timer];
    //token
    NSString *token = [NSString stringWithFormat:@"appid=%@&appkey=%@&timestamp=%@",TDAppid,TDAppkey,timeString];
    token = [MD5And3DES md5:token];
    //加密密码
    loginModel.param = @{@"appid":TDAppid,
                         @"timestamp":timeString,
                         @"token":token,
                         };
    loginModel.requestType = TDTuandaiSourceType;
    //发送请求
    //__weak typeof(self) weakSelf = self;
    [[TDNetworkManager sharedInstane] postRequestWithRequestModel:loginModel hubModel:nil modelClass:nil callBack:^(TDResponeModel *responeModel) {
        if (responeModel.code == 1) {//成功
            //存储所有礼物信息
            NSArray *giftListArr = responeModel.responeData;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:giftListArr forKey:GiftListInfo];
        }else{//获取礼物列表失败
            [SVProgressHUD showWithStatus:@"获取礼物列表失败"];
            [SVProgressHUD dismissWithDelay:1];
        }
    }];
}

#pragma mark - delegate<TLSUILoginListener>

- (void)TLSUILoginOK:(TLSUserInfo *)userinfo {
    [self loginWith:userinfo];
    [SVProgressHUD showWithStatus:@"正在登录"];
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
