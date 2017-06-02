//
//  TDHelperMacros.h
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#ifndef TDHelperMacros_h
#define TDHelperMacros_h

//屏幕比例适配
#define TDMain_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define TDMain_Screen_Width       [[UIScreen mainScreen] bounds].size.width
//以iphone5，5s，5c为基本机型，其他型号机器按比例系数做乘法.
#define TDAutoSizeScaleX          TDMain_Screen_Width/320.f
#define TDAutoSizeScaleY          TDMain_Screen_Height/568.f

// 当前版本
#define FSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])
#define DSystemVersion          ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define SSystemVersion          ([[UIDevice currentDevice] systemVersion])

// RGB颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]


#endif /* TDHelperMacros_h */
