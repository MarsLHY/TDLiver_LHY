//
//  TCVideoPreview.m
//  TCLVBIMDemo
//
//  Created by xiang zhang on 2017/4/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCVideoPreview.h"
#import "UIView+Additions.h"

#undef _MODULE_
#define _MODULE_ "TXVideoPreview"

#define playBtnWidth   34
#define playBtnHeight  46
#define pauseBtnWidth  27
#define pauseBtnHeight 42

#undef _MODULE_
#define _MODULE_ "TXVideoPreview"

@implementation TCVideoPreview
{
    UIButton    *_playBtn;
    UIImageView *_coverView;
    CGFloat     _currentTime;
    BOOL        _videoIsPlay;
}
- (instancetype)initWithFrame:(CGRect)frame coverImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _renderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_renderView];
        
        if (image != nil) {
            _coverView = [[UIImageView alloc] initWithFrame:_renderView.frame];
            _coverView.image = image;
            _coverView.hidden = NO;
            [self addSubview:_coverView];
        }
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setPlayBtn:_videoIsPlay];
        [_playBtn  addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(NSNotification *)noti
{
    //to do
}

- (void)applicationDidEnterBackground:(NSNotification *)noti
{
    if (_videoIsPlay) {
        [self playBtnClick];
    }
}


- (void)setPlayBtnHidden:(BOOL)isHidden
{
    _playBtn.hidden = isHidden;
}

- (void)playBtnClick
{
    _coverView.hidden = YES;
    
    if (_videoIsPlay) {
        _videoIsPlay = NO;
        [self setPlayBtn:_videoIsPlay];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoPlay)]) {
            [_delegate onVideoPause];
        }
    }else{
        _videoIsPlay = YES;
        [self setPlayBtn:_videoIsPlay];
        
        if (_currentTime == 0) {
            if (_delegate && [_delegate respondsToSelector:@selector(onVideoPlay)]) {
                [_delegate onVideoPlay];
            }
        }else{
            if (_delegate && [_delegate respondsToSelector:@selector(onVideoResume)]) {
                [_delegate onVideoResume];
            }
        }
    }
}

-(void) setPlayBtn:(BOOL)videoIsPlay
{
    if (videoIsPlay) {
        [_playBtn setFrame:CGRectMake((self.frame.size.width - pauseBtnWidth)/2, (self.frame.size.height - pauseBtnHeight)/2 , pauseBtnWidth, pauseBtnHeight)];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"pause_ugc_edit"] forState:UIControlStateNormal];
          _coverView.hidden = YES;
    }else{
        [_playBtn setFrame:CGRectMake((self.frame.size.width - playBtnWidth)/2, (self.frame.size.height - playBtnHeight)/2 , playBtnWidth, playBtnHeight)];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"play_ugc_edit"] forState:UIControlStateNormal];
    }
    _videoIsPlay = videoIsPlay;
}

-(void) onPreviewProgress:(CGFloat)time
{
    _currentTime = time;
    if (_delegate && [_delegate respondsToSelector:@selector(onVideoPlayProgress:)]) {
        [_delegate onVideoPlayProgress:time];
    }
}

-(void) onPreviewFinished
{
    if (_delegate && [_delegate respondsToSelector:@selector(onVideoPlayFinished)]) {
        [_delegate onVideoPlayFinished];
    }
}
@end
