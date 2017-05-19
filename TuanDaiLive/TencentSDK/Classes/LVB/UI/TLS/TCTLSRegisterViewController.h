//
//  TCTLSRegisterViewController.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCTLSCommon.h"
#import "TLSSDK/TLSSmsRegListener.h"


@interface TCTLSRegisterViewController : UIViewController <TLSSmsRegListener, UITextFieldDelegate>

@property (nonatomic, weak) id<TLSUILoginListener> loginListener;

@end
