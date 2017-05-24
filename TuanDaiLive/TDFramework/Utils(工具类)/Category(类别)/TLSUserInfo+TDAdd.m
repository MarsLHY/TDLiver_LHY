//
//  TLSUserInfo+TDAdd.m
//  TuanDaiLive
//
//  Created by TD on 2017/5/23.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TLSUserInfo+TDAdd.h"
static const void *tagKey = &tagKey;

@implementation TLSUserInfo (TDAdd)

- (NSString *)userSig {
    return objc_getAssociatedObject(self, tagKey);
}

- (void)setUserSig:(NSString *)userSig{
    objc_setAssociatedObject(self, tagKey, userSig, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
