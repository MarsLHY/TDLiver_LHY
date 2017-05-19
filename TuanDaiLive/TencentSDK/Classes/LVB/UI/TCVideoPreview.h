//
//  TCVideoPreview.h
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TXRTMPSDK/TXUGCRecordListener.h>

@protocol TCVideoPreviewDelegate <NSObject>
- (void)onVideoPlay;
- (void)onVideoPause;
- (void)onVideoResume;
- (void)onVideoPlayProgress:(CGFloat)time;
- (void)onVideoPlayFinished;
@end

@interface TCVideoPreview : UIView<TXVideoPreviewListener>

@property(nonatomic,weak) id<TCVideoPreviewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame coverImage:(UIImage *)image;

@property(nonatomic,strong) UIView *renderView;

- (void)setPlayBtnHidden:(BOOL)isHidden;

- (void)setPlayBtn:(BOOL)videoIsPlay;

- (void)removeNotification;
@end
