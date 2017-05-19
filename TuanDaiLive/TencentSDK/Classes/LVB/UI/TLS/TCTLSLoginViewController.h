//
//  TCTLSLoginViewController.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCTLSCommon.h"
#import "TLSSDK/TLSSmsLoginListener.h"


@interface TCTLSLoginViewController : UIViewController <TLSSmsLoginListener, UITextFieldDelegate>

@property (nonatomic, weak) id<TLSUILoginListener> loginListener;

@end
