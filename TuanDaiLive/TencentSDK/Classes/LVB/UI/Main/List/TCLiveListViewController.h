//
//  TCLiveListViewController.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPlayController.h"

@protocol TCLiveListViewControllerListener <NSObject>
-(void)onEnterPlayViewController;
@end


/**
 *  直播/点播列表的TableViewController，负责展示直播、点播列表，点击后跳转播放界面
 */
@interface TCLiveListViewController : UIViewController
@property(nonatomic,retain) TCPlayController *playVC;
@property(nonatomic, weak)  id<TCLiveListViewControllerListener> listener;

- (void)showUGCVideoList;
@end
