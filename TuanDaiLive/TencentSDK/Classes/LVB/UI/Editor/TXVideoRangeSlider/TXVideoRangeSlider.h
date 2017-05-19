//
//  TXVideoRangeSlider.h
//  SAVideoRangeSliderExample
//
//  Created by annidyfeng on 2017/4/18.
//  Copyright © 2017年 Andrei Solovjev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXVideoRangeContent.h"


@protocol TXVideoRangeSliderDelegate;

@interface TXVideoRangeSlider : UIView

@property (weak) id<TXVideoRangeSliderDelegate> delegate;

@property UIScrollView  *bgScrollView;
@property UIImageView   *middleLine;
@property TXVideoRangeContent *rangeContent;
@property (nonatomic) CGFloat        durationMs;
@property (nonatomic) CGFloat        currentPos;
@property (readonly)  CGFloat        leftPos;
@property (readonly)  CGFloat        rightPos;

- (void)setImageList:(NSArray *)images;
- (void)updateImage:(UIImage *)image atIndex:(NSUInteger)index;

@end


@protocol TXVideoRangeSliderDelegate <NSObject>
- (void)onVideoRangeLeftChanged:(TXVideoRangeSlider *)sender;
- (void)onVideoRangeLeftChangeEnded:(TXVideoRangeSlider *)sender;
- (void)onVideoRangeRightChanged:(TXVideoRangeSlider *)sender;
- (void)onVideoRangeRightChangeEnded:(TXVideoRangeSlider *)sender;
- (void)onVideoRangeLeftAndRightChanged:(TXVideoRangeSlider *)sender;
- (void)onVideoRange:(TXVideoRangeSlider *)sender seekToPos:(CGFloat)pos;
@end
