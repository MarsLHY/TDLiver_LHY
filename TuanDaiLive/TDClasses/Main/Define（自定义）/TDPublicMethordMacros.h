//
//  TDPublicMethordMacros.h
//  TuanDaiV4
//
//  Created by Arlexovincy on 16/3/17.
//  Copyright © 2016年 Dee. All rights reserved.
//

#ifndef TDPublicMethordMacros_h
#define TDPublicMethordMacros_h

/**
 *  @author AndreaArlex, 16-03-19 11:03:09
 *
 *  强引用弱引用相关
    Example:
    @weakify(self)
    [self doSomething^{
    @strongify(self)
    if (!self) return;
    ...
    }];
 *
 */

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* TDPublicMethordMacros_h */
