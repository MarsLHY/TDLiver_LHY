//
//  TXVideoRangeSlider.m
//  SAVideoRangeSliderExample
//
//  Created by annidyfeng on 2017/4/18.
//  Copyright © 2017年 Andrei Solovjev. All rights reserved.
//

#import "TXVideoRangeSlider.h"
#import "UIView+Additions.h"
#import "UIView+CustomAutoLayout.h"
#import "TXVideoRangeConst.h"


@interface TXVideoRangeSlider()<TXVideoRangeContentDelegate, UIScrollViewDelegate>

@property BOOL disableSeek;

@end

@implementation TXVideoRangeSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1];
    self.bgScrollView = ({
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [self addSubview:scroll];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.scrollsToTop = NO;
        scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        scroll.delegate = self;
        scroll;
    });
    self.middleLine = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mline.png"]];
        [self addSubview:imageView];
        imageView;
    });

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgScrollView.width = self.width;
    self.middleLine.center = self.bgScrollView.center = CGPointMake(self.width/2, self.height/2);
}

- (void)setImageList:(NSArray *)images
{
    if (self.rangeContent) {
        [self.rangeContent removeFromSuperview];
    }
    self.rangeContent = [[TXVideoRangeContent alloc] initWithImageList:images];
    self.rangeContent.delegate = self;
    
    [self.bgScrollView addSubview:self.rangeContent];
    self.bgScrollView.contentSize = [self.rangeContent intrinsicContentSize];
    self.bgScrollView.height = self.bgScrollView.contentSize.height;
    self.bgScrollView.contentInset = UIEdgeInsetsMake(0, self.width/2-self.rangeContent.pinWidth,
                                                      0, self.width/2-self.rangeContent.pinWidth);
    
    [self setCurrentPos:0];
}

- (void)updateImage:(UIImage *)image atIndex:(NSUInteger)index;
{
    self.rangeContent.imageViewList[index].image = image;
}

- (void)setDurationMs:(CGFloat)durationMs {
    _durationMs = durationMs;
    _leftPos = 0;
    _rightPos = _durationMs;
    [self setCurrentPos:_currentPos];
}

- (void)setCurrentPos:(CGFloat)currentPos
{
    _currentPos = currentPos;
    if (_durationMs <= 0) {
        return;
    }
    CGFloat off = currentPos * self.rangeContent.imageListWidth / _durationMs;
//    off += self.rangeContent.leftPin.width;
    off -= self.bgScrollView.contentInset.left;
    
    self.disableSeek = YES;
    self.bgScrollView.contentOffset = CGPointMake(off, 0);
    self.disableSeek = NO;
}


#pragma Delegate -
#pragma TXVideoRangeContentDelegate

- (void)onVideoRangeLeftChanged:(TXVideoRangeContent *)sender
{
    _leftPos  = self.durationMs * sender.leftScale;
    _rightPos = self.durationMs * sender.rightScale;
    
    [self.delegate onVideoRangeLeftChanged:self];
}

- (void)onVideoRangeLeftChangeEnded:(TXVideoRangeContent *)sender
{
    _leftPos  = self.durationMs * sender.leftScale;
    _rightPos = self.durationMs * sender.rightScale;
    
    [self.delegate onVideoRangeLeftChangeEnded:self];
    
}

- (void)onVideoRangeRightChanged:(TXVideoRangeContent *)sender
{
    _leftPos  = self.durationMs * sender.leftScale;
    _rightPos = self.durationMs * sender.rightScale;
    
    [self.delegate onVideoRangeRightChanged:self];
}

- (void)onVideoRangeRightChangeEnded:(TXVideoRangeContent *)sender
{
    _leftPos  = self.durationMs * sender.leftScale;
    _rightPos = self.durationMs * sender.rightScale;
    
    [self.delegate onVideoRangeRightChangeEnded:self];
}

- (void)onVideoRangeLeftAndRightChanged:(TXVideoRangeContent *)sender
{
    _leftPos  = self.durationMs * sender.leftScale;
    _rightPos = self.durationMs * sender.rightScale;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pos = scrollView.contentOffset.x;
    pos += scrollView.contentInset.left;
    if (pos < 0) pos = 0;
    if (pos > self.rangeContent.imageListWidth) pos = self.rangeContent.imageListWidth;
    
    _currentPos = self.durationMs * pos/self.rangeContent.imageListWidth;
    if (self.disableSeek == NO) {
        NSLog(@"seek %f", _currentPos);
        [self.delegate onVideoRange:self seekToPos:self.currentPos];
    }
}
@end
