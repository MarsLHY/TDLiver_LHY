//
//  TCTLSRegisterViewController.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCTLSRegisterViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "TLSSDK/TLSHelper.h"
#import "TLSSDK/TLSErrInfo.h"
#import "TCTLSCommon.h"
#import "TCTLSPlatform.h"

@interface TCTLSRegisterViewController ()

@property (nonatomic) TLSSmsState smsState;

@end

@implementation TCTLSRegisterViewController
{
    UITextField    *_accountTextField;  // 用户名/手机号
    UITextField    *_pwdTextField;      // 密码/验证码
    UITextField    *_pwdTextField2;     // 确认密码（用户名注册）
    UIButton       *_sendSMSBtn;        // 获取验证码
    UIButton       *_regBtn;            // 注册
    UIButton       *_switchBtn;         // 切换注册方式
    UIView         *_lineView1;
    UIView         *_lineView2;
    UIView         *_lineView3;
    BOOL           _isSMSRegType;       // YES 表示手机号注册，NO 表示用户名注册
    
    // 验证码相关
    NSString       *_curCountry;
    NSString       *_curPhone;
    NSTimer        *_smsTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _isSMSRegType = YES;
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
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
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
    
    _pwdTextField2 = [[UITextField alloc] init];
    _pwdTextField2.font = [UIFont systemFontOfSize:14];
    _pwdTextField2.textColor = [UIColor colorWithWhite:1 alpha:1];
    _pwdTextField2.secureTextEntry = YES;
    [_pwdTextField2 setPlaceholder:@"确认密码"];
    _pwdTextField2.returnKeyType = UIReturnKeyDone;
    _pwdTextField2.delegate = self;
    
    _lineView1 = [[UIView alloc] init];
    [_lineView1 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView2 = [[UIView alloc] init];
    [_lineView2 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView3 = [[UIView alloc] init];
    [_lineView3 setBackgroundColor:[UIColor whiteColor]];
    
    _sendSMSBtn = [[UIButton alloc] init];
    _sendSMSBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_sendSMSBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_sendSMSBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendSMSBtn setBackgroundImage:[UIImage imageNamed:@"get"] forState:UIControlStateNormal];
    [_sendSMSBtn setBackgroundImage:[UIImage imageNamed:@"get_pressed"] forState:UIControlStateSelected];
    [_sendSMSBtn addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    _regBtn = [[UIButton alloc] init];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_regBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [_regBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
    _switchBtn = [[UIButton alloc] init];
    _switchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_switchBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
    [_switchBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_switchBtn addTarget:self action:@selector(switchRegWay:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    [self.view addSubview:_pwdTextField2];
    [self.view addSubview:_lineView3];
    [self.view addSubview:_sendSMSBtn];
    [self.view addSubview:_regBtn];
    [self.view addSubview:_switchBtn];
    
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
    
    if (_isSMSRegType) {
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
    
    if (_isSMSRegType) {
        [_regBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
        [_regBtn layoutBelow:_lineView2 margin:36];
        [_regBtn alignParentLeftWithMargin:22];
    }
    else {
        [_pwdTextField2 sizeWith:CGSizeMake(screen_width - 50, 33)];
        [_pwdTextField2 layoutBelow:_lineView2 margin:6];
        [_pwdTextField2 alignParentLeftWithMargin:25];
        
        [_lineView3 sizeWith:CGSizeMake(screen_width - 44, 1)];
        [_lineView3 layoutBelow:_pwdTextField2 margin:6];
        [_lineView3 alignParentLeftWithMargin:22];
        
        [_regBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
        [_regBtn layoutBelow:_lineView3 margin:36];
        [_regBtn alignParentLeftWithMargin:22];
    }
    
    [_switchBtn sizeWith:CGSizeMake(100, 15)];
    [_switchBtn layoutBelow:_regBtn margin:25];
    [_switchBtn alignParentRightWithMargin:25];
    
    
    if (_isSMSRegType) {
        [_accountTextField setPlaceholder:@"输入手机号"];
        [_accountTextField setText:@""];
        _accountTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_pwdTextField setPlaceholder:@"输入验证码"];
        [_pwdTextField setText:@""];
        [_switchBtn setTitle:@"用户名注册" forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = NO;
        _pwdTextField2.hidden = YES;
        _sendSMSBtn.hidden = NO;
        _lineView3.hidden = YES;
        
        _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    }
    else {
        [_accountTextField setPlaceholder:@"用户名为小写字母、数字、下划线"];
        [_accountTextField setText:@""];
        _accountTextField.keyboardType = UIKeyboardTypeDefault;
        [_pwdTextField setPlaceholder:@"用户密码为8~16个字符"];
        [_pwdTextField setText:@""];
        [_pwdTextField2 setText:@""];
        [_switchBtn setTitle:@"手机号注册" forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = YES;
        _pwdTextField2.hidden = NO;
        _sendSMSBtn.hidden = YES;
        _lineView3.hidden = NO;
        
        _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        _pwdTextField2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField2.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    }
}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_pwdTextField2 resignFirstResponder];
}

- (void)switchRegWay:(UIButton *)button {
    _isSMSRegType = !_isSMSRegType;
    [self clickScreen];
    [self relayout];
}

- (void)reg:(UIButton *)button {
    if (_isSMSRegType) {
        NSString *code = _pwdTextField.text;
        if (code == nil || [code length] == 0) {
            [HUDHelper alert:@"请输入验证码"];
            return;
        }
        if (self.smsState != SENDED_SMS || ![_curPhone isEqualToString:_accountTextField.text]) {
            [HUDHelper alert:@"请先发送短信验证码"];
            return;
        }
        int ret = [[TLSHelper getInstance] TLSSmsRegVerifyCode:code andTLSSmsRegListener:self];
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
        if ([userName length] < 4 || [userName length] > 24) {
            [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能小于4位或者大于24位" cancel:@"确定"];
            return;
        }
        NSString *pattern = @"^[0-9]*$";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:userName options:NSMatchingReportCompletion range:NSMakeRange(0, userName.length)];
        if (result.count > 0) {
            [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能是全数字" cancel:@"确定"];
            return;
        }
        
        pattern = @"[a-z0-9_]{4,24}$";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        result = [regex matchesInString:userName options:NSMatchingReportCompletion range:NSMakeRange(0, userName.length)];
        if (result.count <= 0) {
            [HUDHelper alertTitle:@"用户名错误" message:@"用户名不符合规范" cancel:@"确定"];
            return;
        }
        
        NSString *pwd = _pwdTextField.text;
        if (pwd == nil || [pwd length] == 0) {
            [HUDHelper alertTitle:@"密码错误" message:@"密码不能为空" cancel:@"确定"];
            return;
        }
        if ([pwd length] < 8 || [pwd length] > 16) {
            [HUDHelper alertTitle:@"密码错误" message:@"密码必须为8到16位" cancel:@"确定"];
            return;
        }
        NSString *pwd2 = _pwdTextField2.text;
        if ([pwd compare:pwd2] != NSOrderedSame) {
            [HUDHelper alertTitle:@"密码错误" message:@"两次密码不一致" cancel:@"确定"];
            return;
        }
        
        // 用户名密码注册
        __weak typeof(self) weakSelf = self;
        [[HUDHelper sharedInstance] syncLoading];
        int ret = [[TCTLSPlatform sharedInstance] pwdRegister:userName andPassword:pwd succ:^(TLSUserInfo *userInfo) {
            // 注册成功后直接登录
            dispatch_async(dispatch_get_main_queue(), ^{
                int ret2 = [[TCTLSPlatform sharedInstance] pwdLogin:userName andPassword:pwd succ:^(TLSUserInfo *userInfo) {
                    [[HUDHelper sharedInstance] syncStopLoading];
                    id listener = weakSelf.loginListener;
                    [listener TLSUILoginOK:userInfo];
                } fail:^(TLSErrInfo *errInfo) {
                    [[HUDHelper sharedInstance] syncStopLoading];
                    [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
//                    NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
                }];
                if (ret2 != 0) {
                    [[HUDHelper sharedInstance] syncStopLoading];
                    [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret2] cancel:@"确定"];
                }
            });
            
        } fail:^(TLSErrInfo *errInfo) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
//            NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
        }];
        
        if (ret != 0) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
        }
    }
}

- (void)sendSMS:(UIButton *)button {
    NSString *phoneNumber = _accountTextField.text;
    if (phoneNumber == nil || [phoneNumber length] == 0) {
        [HUDHelper alert:@"请输入手机号"];
        return;
    }
    
    int ret = 0;
    if (self.smsState != START && [phoneNumber isEqualToString:_curPhone]) {
        ret = [[TLSHelper getInstance] TLSSmsRegReaskCode:self];
    }
    else {
        _curPhone = [phoneNumber copy];
        ret = [[TLSHelper getInstance] TLSSmsRegAskCode:[NSString stringWithFormat:@"%@-%@", _curCountry, _curPhone] andTLSSmsRegListener:self];
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

#pragma mark - TLSSmsRegListener

- (void)OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration {
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

- (void)OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration {
    [self OnSmsRegAskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
}

- (void)OnSmsRegVerifyCodeSuccess {
    [[TLSHelper getInstance] TLSSmsRegCommit:self];
}

- (void)OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *nc = self.navigationController;
        UIViewController *vc = nc.viewControllers[nc.viewControllers.count - 2];  // TCTLSLoginViewController在倒数第二个
        if ([vc conformsToProtocol:@protocol(TLSSmsLoginListener)]) {
            int ret = [[TLSHelper getInstance] TLSSmsLogin:userInfo.identifier andTLSSmsLoginListener:(id<TLSSmsLoginListener>)vc];
            if (ret != 0) {
                [[HUDHelper sharedInstance] syncStopLoading];
                [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
            }
        }
        else {
            // bug
//            NSLog(@"%@ not conform TLSSmsLoginListener", vc);
            [[HUDHelper sharedInstance] syncStopLoading];
        }
    });
}

- (void)OnSmsRegFail:(TLSErrInfo *)errInfo {
    switch (self.smsState) {
        case SENDED_SMS:
            if (errInfo.dwErrorCode != TLS_ACCOUNT_SMSCODE_INVALID) {
                self.smsState = START;
            }
            break;
        default:
            self.smsState = START;
            break;
    }
    [[HUDHelper sharedInstance] syncStopLoading];
    [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
//    NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
}

- (void)OnSmsRegTimeout:(TLSErrInfo *)errInfo {
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

@end
