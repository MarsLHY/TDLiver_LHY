//
//  TXVideoRangeContent.h
//  SAVideoRangeSliderExample
//
//  Created by annidyfeng on 2017/4/18.
//  Copyright © 2017年 Andrei Solovjev. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TXVideoRangeContentDelegate;

@interface TXVideoRangeContent : UIView

@property (weak) id<TXVideoRangeContentDelegate> delegate;

@property UIImageView   *leftPin;
@property UIImageView   *rightPin;
@property UIView        *topBorder;
@property UIView        *bottomBorder;
@property UIImageView   *middleLine;
@property UIView        *centerCover;
@property UIView        *leftCover;
@property UIView        *rightCover;

@property NSArray<UIImageView *>       *imageViewList;
@property NSArray       *imageList;

@property (readonly) CGFloat pinWidth;
@property (readonly) CGFloat imageWidth;
@property (readonly) CGFloat imageListWidth;

@property (readonly) CGFloat leftScale;
@property (readonly) CGFloat rightScale;

- (instancetype)initWithImageList:(NSArray *)images;

@end


@protocol TXVideoRangeContentDelegate <NSObject>

- (void)onVideoRangeLeftChanged:(TXVideoRangeContent *)sender;
- (void)onVideoRangeLeftChangeEnded:(TXVideoRangeContent *)sender;
- (void)onVideoRangeRightChanged:(TXVideoRangeContent *)sender;
- (void)onVideoRangeRightChangeEnded:(TXVideoRangeContent *)sender;
- (void)onVideoRangeLeftAndRightChanged:(TXVideoRangeContent *)sender;
@end
