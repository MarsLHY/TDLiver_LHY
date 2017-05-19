#import <Foundation/Foundation.h>
#import "TCStreamMergeMgr.h"
#import "TCUtil.h"
#import "TCUserInfoMgr.h"

#define MAX_SUB_VIDEO_STREAM        3

static TCStreamMergeMgr * _sharedInstance = NULL;


@interface TCStreamMergeMgr()
{
    NSString *              _mainStreamId;
    NSMutableArray *        _subStreamIds;
    
    int                     _mainStreamWidth;
    int                     _mainStreamHeight;
}
@end


@implementation TCStreamMergeMgr

-(instancetype) init
{
    if (self = [super init])
    {
        _subStreamIds = [NSMutableArray new];
        _mainStreamWidth = 540;
        _mainStreamHeight = 960;
    }
    return self;
}

+(instancetype) shareInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCStreamMergeMgr alloc] init];
    });
    return _sharedInstance;
}

-(void) setMainVideoStream:(NSString*) streamUrl
{
    _mainStreamId = [TCUtil getStreamIDByStreamUrl:streamUrl];
    
    NSLog(@"MergeVideoStream: setMainVideoStream %@", _mainStreamId);
}

-(void) setMainVideoStreamResolution:(CGSize) size
{
    if (size.width > 0 && size.height > 0) {
        _mainStreamWidth  = size.width;
        _mainStreamHeight = size.height;
    }
}

-(void) addSubVideoStream:(NSString*) streamUrl
{
    if ([_subStreamIds count] >= MAX_SUB_VIDEO_STREAM) {
        return;
    }
    
    NSString * streamId = [TCUtil getStreamIDByStreamUrl:streamUrl];
    NSLog(@"MergeVideoStream: addSubVideoStream %@", streamId);
    
    for (NSString* item in _subStreamIds) {
        if ([item isEqualToString:streamId] == YES) {
            return;
        }
    }
    
    [_subStreamIds addObject:streamId];
    [self sendStreamMergeRequest: 5];
}

-(void) delSubVideoStream:(NSString*) streamUrl
{
    NSString * streamId = [TCUtil getStreamIDByStreamUrl:streamUrl];
    
    NSLog(@"MergeVideoStream: delSubVideoStream %@", streamId);
    
    BOOL bExist = NO;
    for (NSString* item in _subStreamIds) {
        if ([item isEqualToString:streamId] == YES) {
            bExist = YES;
            break;
        }
    }
    
    if (bExist == YES) {
        [_subStreamIds removeObject:streamId];
        [self sendStreamMergeRequest: 1];
    }
}

-(void) resetMergeState
{
    NSLog(@"MergeVideoStream: resetMergeState");
    
    [_subStreamIds removeAllObjects];
    
    if (_mainStreamId != nil && [_subStreamIds count] > 0) {
        [self sendStreamMergeRequest: 1];
    }
    
    _mainStreamId = nil;
    _mainStreamWidth = 540;
    _mainStreamHeight = 960;
}

-(void) sendStreamMergeRequest: (int) retryCount
{
    if (_mainStreamId == nil) {
        return;
    }
    
    NSDictionary * mergeDictParam = [self createRequestParam];
    if (mergeDictParam == nil) {
        return;
    }
    
    [self performSelectorInBackground: @selector(internalSendRequest:) withObject:@[[NSNumber numberWithInt:retryCount], mergeDictParam]];
}

-(void) internalSendRequest: (NSArray*)array
{
    if ([array count] < 2) {
        return;
    }
    
    NSNumber * numRetryIndex = [array objectAtIndex:0];
    NSDictionary* mergeParams = [array objectAtIndex:1];
    
    TCUserInfoData * profile = [[TCUserInfoMgr sharedInstance] getUserProfile];
    NSDictionary* dictParam = @{@"Action": @"MergeVideoStream", @"userid": profile.identifier, @"mergeparams": mergeParams};
    
    NSString * streamsLog = [NSString stringWithFormat:@"mainStream: %@", _mainStreamId];
    int streamIndex = 1;
    for (NSString* item in _subStreamIds) {
        streamsLog = [NSString stringWithFormat:@"%@ subStream%d: %@", streamsLog, streamIndex++, item];
    }
    NSLog(@"MergeVideoStream: send request, %@ ,retryIndex: %d", streamsLog, [numRetryIndex intValue]);
    
    [TCUtil asyncSendHttpRequest:dictParam handler:^(int result, NSDictionary *resultDict) {
        NSString * strMessage = @"";
        if (resultDict != nil) {
            strMessage = resultDict[@"msg"];
        }
        
        NSLog(@"MergeVideoStream: recv response, message = %@", strMessage);
        
        BOOL bSuccess = NO;
        NSDictionary * dictMessage = [TCUtil jsonData2Dictionary:strMessage];
        if (dictMessage != nil) {
            int code = [dictMessage[@"code"] intValue];
            if (code == 0) {
                bSuccess = YES;
            }
        }
        
        if (bSuccess != YES) {
            int retryIndex = [numRetryIndex intValue];
            --retryIndex;
            if (retryIndex > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self performSelectorInBackground: @selector(internalSendRequest:) withObject:@[[NSNumber numberWithInt:retryIndex], mergeParams]];
                });
            }
        }
    }];
}

-(NSDictionary*) createRequestParam
{
    NSString * appid = kXiaoZhiBoAppId;
    
    NSMutableArray * inputStreamList = [NSMutableArray new];
    
    //大主播
    NSDictionary * mainStream = @{
                                    @"input_stream_id": _mainStreamId,
                                    @"layout_params": @{@"image_layer": [NSNumber numberWithInt:1]}
                                 };
    [inputStreamList addObject:mainStream];
    
    
    int subWidth  = 160;
    int subHeight = 240;
    int offsetHeight = 90;
    if (_mainStreamWidth < 540 || _mainStreamHeight < 960) {
        subWidth  = 120;
        subHeight = 180;
        offsetHeight = 60;
    }
    int subLocationX = _mainStreamWidth - subWidth;
    int subLocationY = _mainStreamHeight - subHeight - offsetHeight;
    
    //小主播
    int index = 0;
    for (NSString * item in _subStreamIds) {
        NSDictionary * subStream = @{
                                        @"input_stream_id": item,
                                        @"layout_params": @{
                                                                @"image_layer": [NSNumber numberWithInt:(index + 2)],
                                                                @"image_width": [NSNumber numberWithInt: subWidth],
                                                                @"image_height": [NSNumber numberWithInt: subHeight],
                                                                @"location_x": [NSNumber numberWithInt:subLocationX],
                                                                @"location_y": [NSNumber numberWithInt:(subLocationY - index * subHeight)]
                                                           }
                                    };
        ++index;
        [inputStreamList addObject:subStream];
    }
    
    //para
    NSDictionary * para = @{
                                @"app_id": [NSNumber numberWithInt:[appid intValue]] ,
                                @"interface": @"mix_streamv2.start_mix_stream_advanced",
                                @"mix_stream_session_id": _mainStreamId,
                                @"output_stream_id": _mainStreamId,
                                @"input_stream_list": inputStreamList
                           };
    
    //interface
    NSDictionary * interface = @{
                                    @"interfaceName":@"Mix_StreamV2",
                                    @"para":para
                                };
    

    //mergeParams
    NSDictionary * mergeParams = @{
                                        @"timestamp": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                        @"eventId": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                        @"interface": interface
                                  };
    return mergeParams;
}

-(NSString*) dictionaryToString:(NSDictionary*)dict
{
    NSError *error;
    NSData *jsonData = [TCUtil dictionary2JsonData:dict];
    
    NSString *jsonString = @"";
    if (!jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonString;
}

@end
