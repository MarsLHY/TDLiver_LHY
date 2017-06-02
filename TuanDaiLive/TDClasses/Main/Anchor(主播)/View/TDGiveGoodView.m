//
//  TDGiveGoodView.m
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TDGiveGoodView.h"
#import "XTLoveHeartView.h"

@interface TDGiveGoodView ()
/// 队列1
@property (nonatomic,strong) NSOperationQueue *queue1;
/// 操作缓存池
@property (nonatomic,strong) NSMutableArray *operationCache;

@property(nonatomic ,strong) NSTimer *timer;

@end

@implementation TDGiveGoodView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.operationCache = [NSMutableArray array];
        self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.operationCache = [NSMutableArray array];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)addGoodAnimate{
    
    @weakify(self)
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            XTLoveHeartView *heart = [[XTLoveHeartView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
            heart.image = [UIImage imageNamed:[NSString stringWithFormat:@"zan_l%d",arc4random_uniform(20) + 1]];
            heart.userInteractionEnabled = NO;
            [weak_self addSubview:heart];
            
            CGPoint fountainSource = CGPointMake(weak_self.frame.size.width * 0.5, weak_self.bounds.size.height * 0.92);
            heart.center = fountainSource;
            [heart animateInView:weak_self andfinishBlock:^{
                
            }];
        }];
    }];
    
    // 防止内存暴增
    if (self.operationCache.count >100) {
        return;
    }
    
    // 缓存池添加任务
    [self.operationCache addObject:op];
    
}



-(void)closeRoom {
    // 取消队列中所有的任务
    [self.queue1 cancelAllOperations];
    [self.timer invalidate];
}


-(void)doAnimation{
    if (self.operationCache.count == 0) {
        return;
    }
    NSBlockOperation *op = self.operationCache[0];
    [self.queue1 addOperation:op];
    [self.operationCache removeObjectAtIndex:0];
}

- (NSOperationQueue *)queue1
{
    if (_queue1==nil) {
        _queue1 = [[NSOperationQueue alloc] init];
        // 设置最大并发数
        _queue1.maxConcurrentOperationCount = 1;
        
    }
    return _queue1;
}

@end
