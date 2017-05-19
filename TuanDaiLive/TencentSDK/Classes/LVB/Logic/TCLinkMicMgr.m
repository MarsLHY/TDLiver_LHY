#import <Foundation/Foundation.h>
#import "TCLinkMicMgr.h"
#import "TCUserInfoMgr.h"

static TCLinkMicMgr *_sharedInstance = nil;


@implementation TCLinkMicMgr

-(instancetype)init {
    self = [super init];

    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCLinkMicMgr alloc] init];
    });
    return _sharedInstance;
}

-(void) sendLinkMicRequest:(NSString*)toUserID {
    [self sendMessage:toUserID command:LINKMIC_CMD_REQUEST withParam:@""];
}

-(void) sendLinkMicResponse:(NSString*)toUserID withType:(TCLinkMicResponseType)rspType andParams:(NSDictionary*)param {
    int cmd = -1;
    NSDictionary* dict = nil;
    switch (rspType) {
        case LINKMIC_RESPONSE_TYPE_ACCEPT:
            cmd = LINKMIC_CMD_ACCEPT;
            dict = @{@"sessionID": param[@"sessionID"], @"streams": param[@"streams"]};
            break;

        case LINKMIC_RESPONSE_TYPE_REJECT:
            cmd = LINKMIC_CMD_REJECT;
            dict = @{@"reason": param[@"reason"]};
            break;
 
        default:
            break;
    }
    
    if (cmd != -1) {
        NSData* data = [TCUtil dictionary2JsonData:dict];
        if (data) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self sendMessage:toUserID command:cmd withParam:content];
        }
    }
}

-(void) sendMemberJoinNotify:(NSString*)toUserID withJoinerID:(NSString*)joinerID andJoinerPlayUrl:(NSString*)playUrl {
    NSDictionary* dict = @{@"joinerID": joinerID, @"playUrl": playUrl};
    NSData* data = [TCUtil dictionary2JsonData:dict];
    if (data) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self sendMessage:toUserID command:LINKMIC_CMD_MEMBER_JOIN_NOTIFY withParam:content];
    }
}

-(void) sendMemberExitNotify:(NSString*)toUserID withExiterID:(NSString*)exiterID{
    NSDictionary* dict = @{@"exiterID": exiterID};
    NSData* data = [TCUtil dictionary2JsonData:dict];
    if (data) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self sendMessage:toUserID command:LINKMIC_CMD_MEMBER_EXIT_NOTIFY withParam:content];
    }
}

-(void) kickoutLinkMicMember:(NSString*)toUserID {
    [self sendMessage:toUserID command:LINKMIC_CMD_KICK_MEMBER withParam:@""];
}

- (void)sendMessage:(NSString *)userID command:(int)cmd withParam:(NSString*) param {
    if (userID == nil || userID.length == 0) {
        return;
    }
    
    TCUserInfoData* userInfo = [[TCUserInfoMgr sharedInstance] getUserProfile];
    NSDictionary* dict = @{@"userAction":@(cmd), @"userId":TC_PROTECT_STR(userInfo.identifier),@"nickName":TC_PROTECT_STR(userInfo.nickName),@"param":TC_PROTECT_STR(param)};
    
    NSData* data = [TCUtil dictionary2JsonData:dict];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    [textElem setText:content];
    
    TIMMessage *timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:textElem];
    
    TIMConversation * c2cConversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:userID];
    
    [c2cConversation sendMessage:timMsg succ:^{
        DebugLog(@"sendMessage success, cmd:%d, toUser:%s", cmd, [userID UTF8String]);
    } fail:^(int code, NSString *msg) {
        DebugLog(@"sendMessage failed, cmd:%d, toUser:%s, code:%d, errmsg:%@", cmd, [userID UTF8String], code, msg);
    }];
}

-(BOOL) handleC2CMessageReceived:(TIMMessage *)msg {
    if (msg == nil || _listener == nil) {
        return NO;
    }
    
    TCUserInfoData* userInfo = [[TCUserInfoMgr sharedInstance] getUserProfile];
    if (userInfo == nil) {
        DebugLog(@"getUserProfile failed");
        return NO;
    }
    
    if([msg.sender isEqualToString:userInfo.identifier]) {
        DebugLog(@"recevie a self-msg");
        return NO;
    }
    
    for(int index = 0; index < [msg elemCount]; index++) {
        TIMElem *elem = [msg getElem:index];
        if(elem && [elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem *textElem = (TIMTextElem *)elem;
            if (textElem == nil) {
                DebugLog(@"invalid msg-element");
                continue;
            }
            
            NSString *msgText   = textElem.text;
            NSDictionary* dict  = [TCUtil jsonData2Dictionary:msgText];
            
            if (dict) {
                NSNumber * action   = dict[@"userAction"];
                NSString * userID   = dict[@"userId"];
                NSString * nickName = dict[@"nickName"];
                NSString * param    = dict[@"param"];
                
                int actionValue = 0;
                if (action) {
                    actionValue = [action intValue];
                }
                
                if (actionValue >= LINKMIC_CMD_REQUEST && actionValue <= LINKMIC_CMD_KICK_MEMBER) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int actionValue = [action intValue];
                        switch (actionValue) {
                            case LINKMIC_CMD_REQUEST:
                                [_listener onReceiveLinkMicRequest: userID withNickName:nickName];
                                break;
                                
                            case LINKMIC_CMD_ACCEPT:
                            {
                                NSDictionary* dictBody = nil;
                                if (param) {
                                    dictBody = [TCUtil jsonData2Dictionary:param];
                                }
                                [_listener onReceiveLinkMicResponse: userID withType:LINKMIC_RESPONSE_TYPE_ACCEPT andParam:dictBody];
                                break;
                            }
                                
                            case LINKMIC_CMD_REJECT:
                            {
                                NSDictionary* dictBody = nil;
                                if (param) {
                                    dictBody = [TCUtil jsonData2Dictionary:param];
                                }
                                [_listener onReceiveLinkMicResponse: userID withType:LINKMIC_RESPONSE_TYPE_REJECT andParam:dictBody];
                                break;
                            }
                                
                            case LINKMIC_CMD_MEMBER_JOIN_NOTIFY:
                            {
                                NSString * strJoinerID = nil;
                                NSString * strPlayUrl = nil;
                                if (param) {
                                    NSDictionary* dictBody  = [TCUtil jsonData2Dictionary:param];
                                    if (dictBody) {
                                        if ([[dictBody allKeys] containsObject:@"joinerID"]) {
                                            strJoinerID = [dictBody objectForKey:@"joinerID"];
                                        }
                                        if ([[dictBody allKeys] containsObject:@"playUrl"]) {
                                            strPlayUrl = [dictBody objectForKey:@"playUrl"];
                                        }
                                    }
                                }
                                if (strJoinerID != nil && strPlayUrl != nil) {
                                    [_listener onReceiveMemberJoinNotify: strJoinerID withPlayUrl:strPlayUrl];
                                }
                                break;
                            }
                        
                            case LINKMIC_CMD_MEMBER_EXIT_NOTIFY:
                            {
                                NSString * strExiterID = nil;
                                if (param) {
                                    NSDictionary* dictBody  = [TCUtil jsonData2Dictionary:param];
                                    if (dictBody && [[dictBody allKeys] containsObject:@"exiterID"]) {
                                        strExiterID = [dictBody objectForKey:@"exiterID"];
                                    }
                                }
                                if (strExiterID != nil) {
                                    [_listener onReceiveMemberExitNotify: strExiterID];
                                }
                                break;
                            }
                                
                            case LINKMIC_CMD_KICK_MEMBER:
                                if ([_listener respondsToSelector:@selector(onReceiveKickoutNotify)]) {
                                    [_listener onReceiveKickoutNotify];
                                }
                                break;
                                
                            default:
                                break;
                        }
                    });
                    return YES;
                }
                else {
                    return NO;
                }
            }
        }
    }
    return NO;
}

@end
