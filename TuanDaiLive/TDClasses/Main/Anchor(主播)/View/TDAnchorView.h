//
//  TDAnchorView.h
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TXLivePush,AVIMMsgHandler;

@interface TDAnchorView : UIView
{

}

// 群组相关处理
@property (nonatomic, strong) AVIMMsgHandler *msgHandler;

@property (nonatomic, strong) TXLivePush *txLivePublisher;

@property (nonatomic, assign) BOOL isOpenMic;

//关闭直播房间
- (void)closeRoom;
@end
