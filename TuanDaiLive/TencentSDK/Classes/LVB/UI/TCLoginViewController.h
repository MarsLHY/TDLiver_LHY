//
//  TCLoginViewController.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TLSSDK/TLSRefreshTicketListener.h"
#import "TCTLSCommon.h"

/**
 *  TLS登录相关界面层代码，如果需要重新登录，则拉起TLSUI登录界面，否则直接调用ImSDK的登录接口
 */
@interface TCLoginViewController : UIViewController <TLSRefreshTicketListener, TLSUILoginListener>

@end
