//
//  TDNetworkManager.h
//  TuanDaiLive
//
//  Created by tuandai on 2017/5/12.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TDNetworkBase.h"
#import "TDRequestModel.h"
#import "TDResponeModel.h"
#import "TDHubModel.h"

typedef void(^responeModelCallBack)(TDResponeModel *responeModel);

@interface TDNetworkManager : TDNetworkBase


/**
 *  @author AndreaArlex, 16-03-10 16:03:50
 *
 *  单例
 *
 *  @return 本类对象
 */
+ (instancetype)sharedInstane;


- (void)postRequestWithRequestModel:(TDRequestModel *)requestModel hubModel:(TDHubModel*)hubModel modelClass:(Class)modelClass callBack:(responeModelCallBack)callBack;




@end
