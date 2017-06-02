//
//  TDChatToolView.h
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TDChatToolViewDelegate <NSObject>

- (void)barrageSwitch:(BOOL)isOpen;
- (void)btnSendText:(UITextField*)textField;

@end


@interface TDChatToolView : UIView
{
    UIButton *_sendMsg;
    UISwitch *_barrageSwitch;
}
//代理
@property (nonatomic, weak) id<TDChatToolViewDelegate> delegate;

@property (nonatomic,strong)UITextField *chatTextTield;
@end
