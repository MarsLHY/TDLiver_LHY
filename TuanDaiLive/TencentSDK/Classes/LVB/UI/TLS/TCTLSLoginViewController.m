//
//  TCTLSLoginViewController.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCTLSLoginViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "HUDHelper.h"
#import "TLSSDK/TLSHelper.h"
#import "TLSSDK/TLSErrInfo.h"
#import "TCTLSRegisterViewController.h"
#import "TCTLSPlatform.h"
#import "TCIMPlatform.h"
#import "TCUserInfoMgr.h"
#import "TDNetworkManager.h"
#import "TDRequestModel.h"
#import "TDHubModel.h"
#import "MD5And3DES.h"
#import "TLSUserInfo+TDAdd.h"
#import <MJExtension/MJExtension.h>
#import "TDUserInfoMgr.h"
@interface TCTLSLoginViewController ()

@property (nonatomic) TLSSmsState smsState;

@end

@implementation TCTLSLoginViewController
{
    UITextField    *_accountTextField;  // 用户名/手机号
    UITextField    *_pwdTextField;      // 密码/验证码
    UIButton       *_sendSMSBtn;        // 获取验证码
    UIButton       *_loginBtn;          // 登录
    UIButton       *_switchBtn;         // 切换登录方式
    UIButton       *_regBtn;            // 注册
    UIButton       *_touristBtn;        // 游客登录
    UIView         *_lineView1;
    UIView         *_lineView2;
    UIView         *_touristView;
    BOOL           _isSMSLoginType;     // YES 表示手机号登录，NO 表示用户名登录
    
    // 验证码相关
    NSString       *_curCountry;
    NSString       *_curPhone;
    NSTimer        *_smsTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isSMSLoginType = NO;
    [self initUI];
    [self initState];
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    [self.view addGestureRecognizer:tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)initUI {
    UIImage *image = [UIImage imageNamed:@"loginBG.jpg"];
    self.view.layer.contents = (id)image.CGImage;
 
    _accountTextField = [[UITextField alloc] init];
    _accountTextField.font = [UIFont systemFontOfSize:14];
    _accountTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _accountTextField.returnKeyType = UIReturnKeyDone;
    _accountTextField.delegate = self;
    
    _pwdTextField = [[UITextField alloc] init];
    _pwdTextField.font = [UIFont systemFontOfSize:14];
    _pwdTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.delegate = self;
    
    _lineView1 = [[UIView alloc] init];
    [_lineView1 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView2 = [[UIView alloc] init];
    [_lineView2 setBackgroundColor:[UIColor whiteColor]];
    
    _sendSMSBtn = [[UIButton alloc] init];
    _sendSMSBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_sendSMSBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_sendSMSBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendSMSBtn setBackgroundImage:[UIImage imageNamed:@"get"] forState:UIControlStateNormal];
    [_sendSMSBtn setBackgroundImage:[UIImage imageNamed:@"get_pressed"] forState:UIControlStateSelected];
    [_sendSMSBtn addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    _loginBtn = [[UIButton alloc] init];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    _switchBtn = [[UIButton alloc] init];
    _switchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_switchBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
    [_switchBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_switchBtn addTarget:self action:@selector(switchLoginWay:) forControlEvents:UIControlEventTouchUpInside];
    
    _regBtn = [[UIButton alloc] init];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_regBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
    [_regBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_regBtn setTitle:@"注册新用户" forState:UIControlStateNormal];
    [_regBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _touristView = [[UIView alloc] init];
    [_touristView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    
    _touristBtn = [[UIButton alloc] init];
    _touristBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_touristBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_touristBtn setTitle:@"游客登录" forState:UIControlStateNormal];
    [_touristBtn setImage:[UIImage imageNamed:@"tourist"] forState:UIControlStateNormal];
    [_touristBtn addTarget:self action:@selector(guestLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_touristView addSubview:_touristBtn];
    
    
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    [self.view addSubview:_sendSMSBtn];
    [self.view addSubview:_loginBtn];
    [self.view addSubview:_switchBtn];
    [self.view addSubview:_regBtn];
    [self.view addSubview:_touristView];
    
    [self relayout];
}

- (void)relayout {
    CGFloat screen_width = self.view.bounds.size.width;
    
    [_accountTextField sizeWith:CGSizeMake(screen_width - 50, 33)];
    [_accountTextField alignParentTopWithMargin:97];
    [_accountTextField alignParentLeftWithMargin:25];
    
    [_lineView1 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView1 layoutBelow:_accountTextField margin:6];
    [_lineView1 alignParentLeftWithMargin:22];
    
    if (_isSMSLoginType) {
        [_pwdTextField sizeWith:CGSizeMake(150, 33)];
    } else {
        [_pwdTextField sizeWith:CGSizeMake(screen_width - 50, 33)];
    }
    [_pwdTextField layoutBelow:_lineView1 margin:6];
    [_pwdTextField alignParentLeftWithMargin:25];
    
    [_lineView2 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView2 layoutBelow:_pwdTextField margin:6];
    [_lineView2 alignParentLeftWithMargin:22];
    
    [_sendSMSBtn sizeWith:CGSizeMake(90, 33)];
    [_sendSMSBtn layoutBelow:_lineView1 margin:6];
    [_sendSMSBtn alignParentRightWithMargin:25];
    
    [_loginBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
    [_loginBtn layoutBelow:_lineView2 margin:36];
    [_loginBtn alignParentLeftWithMargin:22];
    
    [_switchBtn sizeWith:CGSizeMake(100, 15)];
    [_switchBtn layoutBelow:_loginBtn margin:25];
    [_switchBtn alignParentLeftWithMargin:25];
    
    [_regBtn sizeWith:CGSizeMake(100, 15)];
    [_regBtn layoutBelow:_loginBtn margin:25];
    [_regBtn alignParentRightWithMargin:25];
    
    [_touristView sizeWith:CGSizeMake(screen_width, 60)];
    [_touristView alignParentBottomWithMargin:0];
    [_touristView alignParentLeftWithMargin:0];
    
    [_touristBtn sizeWith:CGSizeMake(50, 42)];
    [_touristBtn layoutParentCenter];
    CGSize titleSize = [_touristBtn.titleLabel.text sizeWithFont:_touristBtn.titleLabel.font];
    CGSize imageSize = _touristBtn.imageView.image.size;
    CGFloat intervalY = 3.0;
    _touristBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleSize.height + intervalY, -titleSize.width);
    _touristBtn.titleEdgeInsets = UIEdgeInsetsMake(imageSize.height + intervalY, -imageSize.width, 0, 0);
    if (_isSMSLoginType) {
        [_accountTextField setPlaceholder:@"输入手机号码"];
        [_accountTextField setText:@""];
        _accountTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_pwdTextField setPlaceholder:@"输入验证码"];
        [_pwdTextField setText:@""];
        [_switchBtn setTitle:@"用户名登录" forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = NO;
        _sendSMSBtn.hidden = NO;
        
        _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    }
    else {
        [_accountTextField setPlaceholder:@"输入用户名"];
        [_accountTextField setText:@""];
        _accountTextField.keyboardType = UIKeyboardTypeDefault;
        [_pwdTextField setPlaceholder:@"输入密码"];
        [_pwdTextField setText:@""];
        [_switchBtn setTitle:@"手机号登录" forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = YES;
        _sendSMSBtn.hidden = YES;
        
        _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    }
}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

- (void)reg:(UIButton *)button {
    [SVProgressHUD showWithStatus:@"暂未开通此功能"];
    [SVProgressHUD dismissWithDelay:1];
//    TCTLSRegisterViewController *regViewController = [[TCTLSRegisterViewController alloc] init];
//    regViewController.loginListener = _loginListener;
//    [self.navigationController pushViewController:regViewController animated:YES];
}

- (void)switchLoginWay:(UIButton *)button {
    [SVProgressHUD showWithStatus:@"暂未开通此功能"];
    [SVProgressHUD dismissWithDelay:1];
//    _isSMSLoginType = !_isSMSLoginType;
//    [self clickScreen];
//    [self relayout];
}

- (void)login:(UIButton *)button {
    if (_isSMSLoginType) {
        NSString *code = _pwdTextField.text;
        if (code == nil || [code length] == 0) {
            [HUDHelper alert:@"请输入验证码"];
            return;
        }
        if (self.smsState != SENDED_SMS || ![_curPhone isEqualToString:_accountTextField.text]) {
            [HUDHelper alert:@"请先发送短信验证码"];
            return;
        }
        int ret = [[TLSHelper getInstance] TLSSmsVerifyCode:[NSString stringWithFormat:@"%@-%@", _curCountry, _curPhone] andCode:code andTLSSmsLoginListener:self];
        if (ret != TLS_ACCOUNT_SUCCESS) {
            self.smsState = START;
            [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
        }
        else {
            [[HUDHelper sharedInstance] syncLoading];
        }
    }
    else {
        NSString *userName = _accountTextField.text;
        if (userName == nil || [userName length] == 0) {
            [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能为空" cancel:@"确定"];
            return;
        }
        NSString *pwd = _pwdTextField.text;
        if (pwd == nil || [pwd length] == 0) {
            [HUDHelper alertTitle:@"密码错误" message:@"密码不能为空" cancel:@"确定"];
            return;
        }
        //第一版新增 走团贷登录
        [self loginTD];
    }
        /*
        //2、走腾讯TLS登录
        __weak typeof(self) weakSelf = self;
        [[HUDHelper sharedInstance] syncLoading];
        int ret = [[TCTLSPlatform sharedInstance] pwdLogin:userName andPassword:pwd succ:^(TLSUserInfo *userInfo) {
            [[HUDHelper sharedInstance] syncStopLoading];
            id listener = weakSelf.loginListener;
            [listener TLSUILoginOK:userInfo];
            
        } fail:^(TLSErrInfo *errInfo) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
            NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
        }];
        if (ret != 0) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
        }
         */
}

//走团贷网登录
- (void)loginTD{
    //先执行团贷网的登录
    //参数配置
    TDRequestModel *loginModel = [[TDRequestModel alloc] init];
    loginModel.methodName = push_login;
    //获取时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timer = [dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", timer];
    //token
    NSString *token = [NSString
                       stringWithFormat:@"appid=%@&appkey=%@&timestamp=%@",TDAppid,TDAppkey,timeString];
    token = [MD5And3DES md5:token];
    //加密密码
    NSString *passWord = [MD5And3DES doEncryptStr:_pwdTextField.text];
    loginModel.param = @{@"appid":TDAppid,
                         @"timestamp":timeString,
                         @"token":token,
                         @"user_id":_accountTextField.text,
                         @"password":passWord};
    loginModel.requestType = TDTuandaiSourceType;
    //发送请求
    __weak typeof(self) weakSelf = self;
    [[TDNetworkManager sharedInstane] postRequestWithRequestModel:loginModel hubModel:nil modelClass:nil callBack:^(TDResponeModel *responeModel) {
        if (responeModel.code == 1) {
            //userinfoModel  单例管理、存储用户信息
            TDUserInfoModel *userModel = [TDUserInfoModel mj_objectWithKeyValues:responeModel.responeData];
            [[TDUserInfoMgr sharedInstance] cacheUserInfo:userModel];
            // 用户名密码登录
            //1、走团贷TLS登录 获取sig
            //参数配置
            TDRequestModel *requestModel = [[TDRequestModel alloc] init];
            requestModel.methodName = push_getUserSig;
            //获取时间戳
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timer=[dat timeIntervalSince1970];
            NSString*timeString = [NSString stringWithFormat:@"%0.f", timer];
            //token
            NSString *token = [NSString stringWithFormat:@"appid=%@&appkey=%@&timestamp=%@",TDAppid,TDAppkey,timeString];
            token = [MD5And3DES md5:token];
            
            NSString *userid = [NSString stringWithFormat:@"%@",responeModel.responeData[@"user_id"]];
            requestModel.param = @{@"appid":TDAppid,
                                   @"timestamp":timeString,
                                   @"token":token,
                                   @"user_id":userid};
            requestModel.requestType = TDTuandaiSourceType;
            //发送请求
            [[TDNetworkManager sharedInstane] postRequestWithRequestModel:requestModel hubModel:nil modelClass:nil callBack:^(TDResponeModel *responeModel) {
                if (responeModel.code==1) {
                    //设置tls登录之后获取的用户信息
                    TDUserInfoModel *userInfoModel = [[TDUserInfoMgr sharedInstance] loadCacheUserInfo];
                    TLSUserInfo *userInfo = [[TLSUserInfo alloc] init];
                    userInfo.accountType = [responeModel.responeData[@"accountType"] intValue];
                    userInfo.identifier = [NSString stringWithFormat:@"%@",userInfoModel.user_id];
                    userInfo.userSig = responeModel.responeData[@"userSig"];
                    userInfo.appidAt3rd = responeModel.responeData[@"sdkAppID"];
                    userInfo.accountTypes = responeModel.responeData[@"accountType"];
                    
                    //设置腾讯sdkappid、accountType、sig
                    NSString *accountType = [NSString stringWithFormat:@"%@",responeModel.responeData[@"accountType"]];
                    NSString *sdkappid = [NSString stringWithFormat:@"%@",responeModel.responeData[@"sdkAppID"]];
                    NSString *userSigStr = [NSString stringWithFormat:@"%@",responeModel.responeData[@"userSig"]];
                    NSDictionary *tencentSdkInfo = @{@"sdkId":sdkappid,
                                                     @"accountType":accountType,
                                                     @"userSig":userSigStr
                                                     };
                    //缓存腾讯sdkappid、accountType、sig
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:tencentSdkInfo forKey:TencentSdkInfo];
                    
                    id listener = weakSelf.loginListener;
                    
                    // 手动 登录前需要先初始化IMSDK
                    [[TCIMPlatform sharedInstance] initIMSDK];
                    //登录
                    [listener TLSUILoginOK:userInfo];
                }else{
                    [SVProgressHUD showWithStatus:responeModel.message];
                    [SVProgressHUD dismissWithDelay:1];
                }
            }];
        }else{
            [SVProgressHUD showWithStatus:responeModel.message];
            [SVProgressHUD dismissWithDelay:1];
        }
    }];

}

- (void)guestLogin:(UIButton *)button {
    [SVProgressHUD showWithStatus:@"暂未开通此功能"];
    [SVProgressHUD dismissWithDelay:1];
    return;
    
    // 游客登录
    [[HUDHelper sharedInstance] syncLoading];
    
    [[TCIMPlatform sharedInstance] guestLogin:^(TLSUserInfo *userInfo) {
        [[HUDHelper sharedInstance] syncStopLoading];
        
        // 游客登录成功后弹出昵称编辑框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请修改昵称" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = @"游客";
        textField.keyboardType = UIKeyboardTypeDefault;
        [alert show];
        
    } fail:^(TLSErrInfo *errInfo) {
        [[HUDHelper sharedInstance] syncStopLoading];
        [HUDHelper alertTitle:@"登录错误" message:[NSString stringWithFormat:@"%@:%d", errInfo.sErrorMsg, errInfo.dwErrorCode] cancel:@"确定"];
    }];
}

- (void)sendSMS:(UIButton *)button {
    NSString *phoneNumber = _accountTextField.text;
    if (phoneNumber == nil || [phoneNumber length] == 0) {
        [HUDHelper alert:@"请输入手机号"];
        return;
    }
    
    int ret = 0;
    if (self.smsState != START && [phoneNumber isEqualToString:_curPhone]) {
        ret = [[TLSHelper getInstance] TLSSmsReaskCode:[NSString stringWithFormat:@"%@-%@", _curCountry, _curPhone] andTLSSmsLoginListener:self];
    }
    else {
        _curPhone = [phoneNumber copy];
        ret = [[TLSHelper getInstance] TLSSmsAskCode:[NSString stringWithFormat:@"%@-%@", _curCountry, _curPhone] andTLSSmsLoginListener:self];
    }
    
    if (ret != TLS_ACCOUNT_SUCCESS) {
        [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
        self.smsState = START;
    }
    else {
        self.smsState = SENDING_SMS;
        [[HUDHelper sharedInstance] syncLoading];
    }
}

- (void)initState {
    self.smsState = START;
    _curCountry = @"86";
    _curPhone = @"";
}

- (void)setSmsState:(TLSSmsState)smsState {
    switch (smsState) {
        case START:
            if (_sendSMSBtn) {
                _sendSMSBtn.enabled = YES;
                _sendSMSBtn.alpha = 1;
                _sendSMSBtn.titleLabel.text = @"获取验证码";
            }
            if (_smsTimer) {
                [_smsTimer invalidate];
                _smsTimer = nil;
            }
            break;
            
        case SENDING_SMS:
            if (_sendSMSBtn) {
                _sendSMSBtn.enabled = NO;
                _sendSMSBtn.alpha = 0.5;
                _sendSMSBtn.titleLabel.text = @"获取验证码";
            }
            if (_smsTimer) {
                [_smsTimer invalidate];
                _smsTimer = nil;
            }
            break;
            
        case SENDED_SMS:
            break;
            
        default:
            return;
    }
    _smsState = smsState;
}

- (void)onTimer:(NSTimer *)timer {
    SmsTimerData *data = (SmsTimerData *)timer.userInfo;
    data.remainSecond -= 1;
    if (data.remainSecond <= 0) {
        [timer invalidate];
        _sendSMSBtn.alpha = 1;
        _sendSMSBtn.enabled = YES;
    }
    else {
        [_sendSMSBtn setTitle:[NSString stringWithFormat:@"%ds", data.remainSecond] forState:_sendSMSBtn.state];
    }
}

#pragma mark -TLSSmsLoginListener

- (void)OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration {
    [[HUDHelper sharedInstance] syncStopLoading];
    [HUDHelper alertTitle:@"发送短信成功" message:[NSString stringWithFormat:@"%d分钟后过期", expireDuration/60] cancel:@"确定"];
    if (_smsTimer) {
        [_smsTimer invalidate];
    }
    
    SmsTimerData *data = [[SmsTimerData alloc] init];
    data.remainSecond = reaskDuration;
    _smsTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:data repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_smsTimer forMode:NSDefaultRunLoopMode];
    
    self.smsState = SENDED_SMS;
}

- (void)OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration {
    [self OnSmsLoginAskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
}

- (void)OnSmsLoginVerifyCodeSuccess {
    [[TLSHelper getInstance] TLSSmsLogin:[NSString stringWithFormat:@"%@-%@", _curCountry, _curPhone] andTLSSmsLoginListener:self];
}

- (void)OnSmsLoginSuccess:(TLSUserInfo *)userInfo {
    [[HUDHelper sharedInstance] syncStopLoading];
    id listener = self.loginListener;
    [listener TLSUILoginOK:userInfo];
}

- (void)OnSmsLoginFail:(TLSErrInfo *)errInfo {
    if (errInfo.dwErrorCode != TLS_LOGIN_WRONG_SMSCODE) {
        self.smsState = START;
    }
    [[HUDHelper sharedInstance] syncStopLoading];
    [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
//    NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
}

- (void)OnSmsLoginTimeout:(TLSErrInfo *)errInfo {
    if (self.smsState == SENDING_SMS) {
        self.smsState = START;
    }
    [[HUDHelper sharedInstance] syncStopLoading];
    [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
//    NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *nickName = [alertView textFieldAtIndex:0].text;
    if (nickName.length == 0) {
        nickName = @"游客";
    }
    
    [[TCUserInfoMgr sharedInstance] saveUserNickName:nickName handler:^(int errCode, NSString *strMsg) {
        
    }];
    
    // 进入主界面
    [[AppDelegate sharedAppDelegate] enterMainUI];
}

@end
