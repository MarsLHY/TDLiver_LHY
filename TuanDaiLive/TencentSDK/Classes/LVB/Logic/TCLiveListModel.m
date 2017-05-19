//
//  TCLiveListModel.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLiveListModel.h"


@implementation TCLiveUserInfo

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:_nickname forKey:@"nickname" ];
    [coder encodeObject:_headpic forKey:@"headpic" ];
    [coder encodeObject:_frontcover forKey:@"frontcover" ];
    [coder encodeObject:_location forKey:@"location" ];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if (self) {
        self.nickname = [coder decodeObjectForKey:@"nickname" ];
        self.headpic = [coder decodeObjectForKey:@"headpic" ];
        self.frontcover = [coder decodeObjectForKey:@"frontcover" ];
        self.location = [coder decodeObjectForKey:@"location" ];
    }
    return self;
}

@end

@implementation TCLiveInfo

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:_userid forKey:@"userid" ];
    [coder encodeObject:_groupid forKey:@"groupid" ];
    [coder encodeObject:@(_type) forKey:@"type" ];
    [coder encodeObject:@(_viewercount) forKey:@"viewercount" ];
    [coder encodeObject:@(_likecount) forKey:@"likecount" ];
    [coder encodeObject:_title forKey:@"title" ];
    [coder encodeObject:_playurl forKey:@"playurl" ];
    [coder encodeObject:_fileid forKey:@"fileid" ];
    [coder encodeObject:_userinfo forKey:@"userinfo" ];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [super init];
    if (self) {
        self.userid = [coder decodeObjectForKey:@"userid" ];
        self.groupid = [coder decodeObjectForKey:@"groupid" ];
        self.type = [[coder decodeObjectForKey:@"type" ] intValue];
        self.viewercount = [[coder decodeObjectForKey:@"viewercount" ] intValue];
        self.likecount = [[coder decodeObjectForKey:@"likecount" ] intValue];
        self.title = [coder decodeObjectForKey:@"title" ];
        self.playurl = [coder decodeObjectForKey:@"playurl" ];
        self.fileid = [coder decodeObjectForKey:@"fileid" ];
        self.userinfo = [coder decodeObjectForKey:@"userinfo" ];
    }
    return self;
}

@end
