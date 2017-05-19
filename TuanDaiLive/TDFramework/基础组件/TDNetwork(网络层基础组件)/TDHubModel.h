//
//  TDHubModel.h
//  TuanDaiLive
//
//  Created by tuandai on 2017/5/12.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TDHubType) {
    TDHubDefalut = 0, // 默认hub样式
    
};

@interface TDHubModel : NSObject
// 加载中的文字
@property (nonatomic, copy) NSString *title;

// hub类型
@property (nonatomic, assign) TDHubType hubType;

@end
