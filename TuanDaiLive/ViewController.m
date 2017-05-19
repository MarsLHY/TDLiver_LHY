//
//  ViewController.m
//  TuanDaiLive
//
//  Created by tuandai on 2017/5/12.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "ViewController.h"
#import "TDNetworkManager.h"
#import "TDRequestModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1、参数
    TDRequestModel *model = [[TDRequestModel alloc] init];
    //user_wealthp2p  Home_GetBannerList
    //http://p.3.cn/prices/mgets?skuIds=J_954086&type=1
    model.methodName = @"Home_GetBannerList";
    model.requestType = TDTuandaiSourceType;
    model.param = @{@"Type":@"1"};
    
    //2、
    TDHubModel *hubmodel = [[TDHubModel alloc] init];
    hubmodel.title = @"测试";
    hubmodel.hubType = TDHubDefalut;
    
    [[TDNetworkManager sharedInstane] postRequestWithRequestModel:model hubModel:hubmodel modelClass:nil callBack:^(TDResponeModel *responeModel) {
        NSLog(@"%@",responeModel);
    }];
}




@end
