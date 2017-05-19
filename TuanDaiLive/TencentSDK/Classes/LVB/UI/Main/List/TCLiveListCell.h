//
//  TCLivePusherInfo.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveListMgr.h"

@class TCLiveInfo;

/**
 *  直播/点播列表的Cell类，主要展示封面、标题、昵称、在线数、点赞数、定位位置
 */
@interface TCLiveListCell : UICollectionViewCell
{
    TCLiveInfo *_model;
    NSInteger  _type;  // type为1表示UGC，其余为0
}

- (instancetype)initWithFrame:(CGRect)frame videoType:(VideoType)type;

@property (nonatomic , retain) TCLiveInfo *model;
@property (nonatomic, assign) NSInteger type;

@end
