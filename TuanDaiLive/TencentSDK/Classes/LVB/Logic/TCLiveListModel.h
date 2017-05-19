//
//  TCLiveListModel.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  直播/点播列表的数据层定义以及序列化/反序列化实现
 */

@interface TCLiveUserInfo : NSObject

@property NSString *nickname;
@property NSString *headpic;
@property NSString *frontcover;
@property UIImage  *frontcoverImage;
@property NSString *location;

@end

@interface TCLiveInfo : NSObject

@property NSString *userid;
@property NSString *groupid;
@property int       type;
@property int       viewercount;         // 当前在线人数
@property int       likecount;           // 点赞数
@property NSString  *title;
@property NSString  *playurl;
@property NSString  *fileid;
@property TCLiveUserInfo *userinfo;
@property int       timestamp;

@end
