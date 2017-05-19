#ifndef __TCStreamMerge_h__
#define __TCStreamMerge_h__

#import <Foundation/Foundation.h>

@interface TCStreamMergeMgr : NSObject

+(instancetype) shareInstance;

-(void) setMainVideoStream:(NSString*) streamUrl;

-(void) setMainVideoStreamResolution:(CGSize) size;

-(void) addSubVideoStream:(NSString*) streamUrl;

-(void) delSubVideoStream:(NSString*) streamUrl;

-(void) resetMergeState;


@end

#endif
