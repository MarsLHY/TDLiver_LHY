//
//  TLSUserInfo+TDAdd.m
//  TuanDaiLive
//
//  Created by TD on 2017/5/23.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TLSUserInfo+TDAdd.h"
static const void *tagKey = &tagKey;
static const void *tagKey1 = &tagKey1;
static const void *tagKey2 = &tagKey2;

@implementation TLSUserInfo (TDAdd)

//userSig
- (NSString *)userSig {
    return objc_getAssociatedObject(self, tagKey);
}

- (void)setUserSig:(NSString *)userSig{
    objc_setAssociatedObject(self, tagKey, userSig, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//appidAt3rd
- (NSString *)appidAt3rd{
    return objc_getAssociatedObject(self, tagKey1);
}

- (void)setAppidAt3rd:(NSString *)appidAt3rd{
    objc_setAssociatedObject(self, tagKey1, appidAt3rd, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//accountType
- (NSString *)accountTypes{
    return objc_getAssociatedObject(self, tagKey2);
}

- (void)setAccountTypes:(NSString *)accountTypes{
    objc_setAssociatedObject(self, tagKey2, accountTypes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
