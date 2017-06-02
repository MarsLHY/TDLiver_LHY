//
//  TDBeautyView.h
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDBeautyViewDelegate <NSObject>
// 根据tag值判断，0-大眼 1-瘦脸 2-美颜 3-美白
-(void)slidersValueChange:(UISlider *)sender;
@end

@interface TDBeautyView : UIView
//代理
@property (nonatomic, weak) id<TDBeautyViewDelegate> delegate;

@end
