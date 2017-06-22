//
//  TLSUserInfo+TDAdd.h
//  TuanDaiLive
//
//  Created by TD on 2017/5/23.
//  Copyright © 2017年 tuandai. All rights reserved.
//

//#import <TLSSDK/>
#import <TLSSDK/TLSUserInfo.h>
@interface TLSUserInfo (TDAdd)

@property (nonatomic,copy)NSString *userSig;

@property (nonatomic,copy)NSString *appidAt3rd;

@property (nonatomic,copy)NSString *accountTypes;

@end
