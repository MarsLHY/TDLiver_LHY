//
//  TDChatToolView.m
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TDChatToolView.h"

@implementation TDChatToolView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        //创建UI
        [self createUI];
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)createUI{
    if (!_barrageSwitch) {
        _barrageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.f, 0.f, 40*TDAutoSizeScaleX, self.height)];
        [_barrageSwitch addTarget:self action:@selector(barrageSwitchChange:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_barrageSwitch];
    }
    if (!_chatTextTield) {
        _chatTextTield = [[UITextField alloc] initWithFrame:CGRectMake(_barrageSwitch.right, 0, 200*TDAutoSizeScaleX, self.height)];
        _chatTextTield.backgroundColor = [UIColor grayColor];
        [self addSubview:_chatTextTield];
    }
    
    if (!_sendMsg) {
        _sendMsg = [[UIButton alloc] initWithFrame:CGRectMake(_chatTextTield.right+10*TDAutoSizeScaleX, _barrageSwitch.top+10*TDAutoSizeScaleX, 30*TDAutoSizeScaleX, _chatTextTield.height)];
        [_sendMsg setTitle:@"发送" forState:UIControlStateNormal];
        [_sendMsg addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendMsg];
    }
}

//发送弹幕消息还是文本消息的switch
- (void)barrageSwitchChange:(UISwitch *)sender{
    if ([self.delegate respondsToSelector:@selector(barrageSwitch:)]) {
        [self.delegate barrageSwitch:sender.isOn];
    }

}

//发送消息
- (void)sendAction:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(btnSendText:)]) {
        [self.delegate btnSendText:self.chatTextTield];
    }

}
@end
