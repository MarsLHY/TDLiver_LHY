//
//  TDDomainManager.m
//  TuanDaiV4
//
//  Created by AndreaArlex on 16/11/10.
//  Copyright © 2016年 Dee. All rights reserved.
//

#import "TDDomainManager.h"


#pragma mark - 测试服务器域名
//P2P
static NSString *TD110Server = @"http://10.100.11.110:9108/api";
//定期理财
static NSString *DQ110Server = @"http://10.100.11.110:9109/api";
//业务运营
static NSString *TDTestExtentServer = @"http://10.100.11.110:9120/api";

#pragma mark - 19环境服务器域名

#pragma mark - beta服务器域名

#pragma mark - 正式服务器域名

@implementation TDDomainManager


#pragma mark- 域名选择
/**
 获取对应的域名

 @param methodName 接口方法名
 @param requestSourceType 请求服务类型(p2p 或定期理财 或业务运营)
 @return 返回域名和方法名拼接的字符串
 */
+ (NSString *)domainWithMethodName:(NSString *)methodName
                 requestSourceType:(TDRequstSourceType)requestSourceType{

    NSString *host = @"";
    
    //1:测试服务器  2:19服务器 3:beta服务器  4：线上服务器
#if TDDomainType == 1

    host = [TDDomainManager testServerDomainWithMethodName:methodName requestSourceType:requestSourceType];
    
#elif TDDomainType == 2
    
    host = [TDDomainManager prePublishDomainWithMethodName:methodName requestSourceType:requestSourceType];
    
#elif TDDomainType == 3
    
    host = [TDDomainManager betaServerDomainWithMethodName:methodName requestSourceType:requestSourceType];
    
#elif TDDomainType == 4
    
    host = [TDDomainManager onlineServerDomainWithMethodName:methodName requestSourceType:requestSourceType];
    
#endif

    if (methodName) {
        
        host = [NSString stringWithFormat:@"%@/%@",host,methodName];
    }
    
    return host;
}


/**
 上线版本的服务器

 @param methodName        请求方法
 @param requestSourceType 请求方式

 @return 域名
 */
+ (NSString *)onlineServerDomainWithMethodName:(NSString *)methodName
                             requestSourceType:(TDRequstSourceType)requestSourceType {
    
    NSString *host = @"";
 
    return host;
}


/**
 测试版的服务器

 @param methodName        请求方法名
 @param requestSourceType 请求方式

 @return 域名
 */
+ (NSString *)testServerDomainWithMethodName:(NSString *)methodName
                           requestSourceType:(TDRequstSourceType)requestSourceType {
    
    NSString *host = @"";
   
    //1.p2p
    if (requestSourceType == TDTuandaiSourceType) {
        
        host = TD110Server;
    }
    //2.定期理财
    else if (requestSourceType == TDRegularFinancialSourceType) {
        
        host = DQ110Server;
    }
    //3.业务运营
    else if (requestSourceType == TDOperationSourceType){
        host = TDTestExtentServer;
    }
    
    return host;
}


/**
 预发布的服务器

 @param methodName        请求方法名
 @param requestSourceType 请求方式

 @return 域名
 */
+ (NSString *)prePublishDomainWithMethodName:(NSString *)methodName
                           requestSourceType:(TDRequstSourceType)requestSourceType {

    NSString *host = @"";

    
    return host;
}


/**
 beta版本的服务器

 @param methodName        请求方法名
 @param requestSourceType 请求方式

 @return 域名
 */
+ (NSString *)betaServerDomainWithMethodName:(NSString *)methodName
                           requestSourceType:(TDRequstSourceType)requestSourceType {

    NSString *host = @"";
    return host;
}
@end
