//
//  TDAnchorView.m
//  TuanDaiLive
//
//  Created by TD on 2017/6/1.
//  Copyright © 2017年 tuandai. All rights reserved.
//

#import "TDAnchorView.h"
#import "TCMsgHandler.h"
#import "chatCell.h"
#import "TDGiveGoodView.h"
#import "TCMsgBulletView.h"
#import "TDChatToolView.h"
#import "TDBeautyView.h"
@interface TDAnchorView ()<UITableViewDataSource,UITableViewDelegate,AVIMMsgListener,TDBeautyViewDelegate,TDChatToolViewDelegate>

@property (nonatomic, strong) TDBeautyView *beautyView;
@property (nonatomic, assign) BOOL isFlash;
// no - 前置摄像头  yes - 后置摄像头
@property (nonatomic, assign) BOOL camera_switch;
// 美颜
@property (nonatomic, assign) float beauty_level;
// 美白
@property (nonatomic, assign) float whitening_level;
// 眼
@property (nonatomic, assign) float eye_level;
// 瘦脸
@property (nonatomic, assign) float face_level;
//聊天tableview
@property (nonatomic, strong)UITableView *chatTableView;
// 聊天数组
@property (nonatomic, strong) NSMutableArray *chatArr;
// 是否打开了弹幕
@property (nonatomic, assign) BOOL isOpenBarrage;
// 用来点击编辑结束
@property (nonatomic, strong) UIView *coverView;
// 弹幕的父view
@property (nonatomic,strong)UIView *bulletsupview;
// 弹幕view
@property (nonatomic, strong) TCMsgBulletView *bulletViewOne;
@property (nonatomic, strong) TCMsgBulletView *bulletViewTwo;

// 点赞区域
@property (nonatomic,strong)TDGiveGoodView *giveGoodView;
// 键盘工具栏
@property (nonatomic,strong)TDChatToolView *chatToolView;

@end


@implementation TDAnchorView

static NSInteger chatToolViewHeight = 64;

- (id)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        //创建UI
        [self createUI];
        self.backgroundColor = [UIColor purpleColor];
    }
    return self;
}

-(void)dealloc {
    TDLog(@"当前聊天view销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    //1、创建聊天tableview
    _chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 300*TDAutoSizeScaleX, 200*TDAutoSizeScaleX, 200*TDAutoSizeScaleX) style:UITableViewStylePlain];
    _chatTableView.dataSource = self;
    _chatTableView.delegate = self;
    _chatTableView.backgroundColor = [UIColor yellowColor];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.estimatedRowHeight = 30;
    self.chatTableView.showsVerticalScrollIndicator = NO;
    [self addSubview:_chatTableView];
    
    _chatToolView.hidden = YES;
    //礼物飘屏
    self.bulletViewOne.frame = CGRectMake(0, 0, Main_Screen_Width, 34);
    self.bulletViewTwo.frame = CGRectMake(0, CGRectGetMaxY(self.bulletViewOne.frame) + 10, Main_Screen_Width, 34);
    self.bulletViewOne.backgroundColor = [UIColor blueColor];
    self.bulletViewTwo.backgroundColor = [UIColor blueColor];

    //
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewClick)];
    [self.coverView addGestureRecognizer:tap];
    //送礼
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(giveGoodViewClick)];
    [self.giveGoodView addGestureRecognizer:tap1];

    //2、创建底部工具栏View
    UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(30*TDAutoSizeScaleX, Main_Screen_Height-30*TDAutoSizeScaleX, 260*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    bottomBgView.backgroundColor = [UIColor grayColor];
    [self addSubview:bottomBgView];
    
    //3、创建聊天、前后镜头切换、美颜、闪光、音效场景等button
    UIButton *chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgView addSubview:chatBtn];
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(chatBtn.right, 0, 60*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [switchBtn setTitle:@"切换镜头" forState:UIControlStateNormal];
    [bottomBgView addSubview:switchBtn];
    
    UIButton *beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(switchBtn.right, 0, 40*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [beautyBtn setTitle:@"美颜" forState:UIControlStateNormal];
    [bottomBgView addSubview:beautyBtn];
    
    UIButton *flickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(beautyBtn.right, 0, 40*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [flickerBtn setTitle:@"闪光" forState:UIControlStateNormal];
    [bottomBgView addSubview:flickerBtn];
    
    UIButton *musicBtn = [[UIButton alloc] initWithFrame:CGRectMake(flickerBtn.right, 0, 40*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [musicBtn setTitle:@"音效" forState:UIControlStateNormal];
    [bottomBgView addSubview:musicBtn];
    
    UIButton *micBtn = [[UIButton alloc] initWithFrame:CGRectMake(musicBtn.right, 0, 40*TDAutoSizeScaleX, 30*TDAutoSizeScaleX)];
    [micBtn setTitle:@"关麦" forState:UIControlStateNormal];
    [bottomBgView addSubview:micBtn];
    
    [self giveGiftView];
}

-(void)setMsgHandler:(AVIMMsgHandler *)msgHandler {
    _msgHandler = msgHandler;
    if (!_msgHandler.roomIMListener) {
        _msgHandler.roomIMListener = self;
    }
}

#pragma mark - TDChatToolViewDelegate 开关弹幕 and 发送消息
- (void)barrageSwitch:(BOOL)isOpen {
    _isOpenBarrage = isOpen;
    if (isOpen) { // 发送弹幕
        
    }else {
        
    }
}
- (void)btnSendText:(UITextField*)textField {
    NSString *pic = @"http://touxiang.qqzhi.com/uploads/2012-11/1111005600464.jpg";
    NSString *uid = @"用户id";
    NSString *uname = @"姓名";
    
    IMUserAble *able = [IMUserAble new];
//    able.msg = textField.text;
//    able.nickName = uname;
//    able.userId = uid;
    if (self.isOpenBarrage) {
        [self.msgHandler sendDanmakuMessage:uid nickName:uname headPic:pic msg:textField.text];
        able.cmdType = AVIMCMD_Custom_Danmaku;
    }else {
        [self.msgHandler sendTextMessage:uid nickName:uname headPic:pic msg:textField.text];
        able.cmdType = AVIMCMD_Custom_Text;
    }
    [self onRecvGroupSender:able textMsg:nil];
}

#pragma mark - EVENT 底部消息按钮点击事件
- (void)chatAction:(UIButton *)button{
    [self.chatToolView.chatTextTield becomeFirstResponder];
}

#pragma mark - 关闭房间
-(void)closeRoom {
    [_msgHandler releaseIMRef];
//    [self.giveGoodView closeRoom];
//    [_bulletViewOne stopAnimation];
//    [_bulletViewTwo stopAnimation];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"chatCell";
    //子类化单元格
    chatCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(cell == nil)
    {
        cell = [[chatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    if (indexPath.row==2) {
        cell.backgroundColor = [UIColor grayColor];
    }
    return cell;
}

#pragma mark - 点赞
- (void)giveGoodViewClick {
    NSString *pic = @"http://touxiang.qqzhi.com/uploads/2012-11/1111005600464.jpg";
    NSString *uid = @"用户id";
    NSString *uname = @"姓名";
    BOOL temp = [self.msgHandler sendLikeMessage:uname nickName:uid headPic:pic];
    if (temp) {
        [self.giveGoodView addGoodAnimate];
    }
}
- (void)coverViewClick {
    [self endEditing:YES];
}

#pragma mark - 键盘显示、隐藏
-(void)keyBoardShow:(NSNotification*)info {
    NSDictionary *dict = info.userInfo;
    NSValue *value = [dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = value.CGRectValue;
    self.chatToolView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.chatToolView.frame = CGRectMake(0, rect.origin.y - chatToolViewHeight, Main_Screen_Width, chatToolViewHeight);
    } completion:^(BOOL finished) {
        self.coverView.frame = CGRectMake(0, 0, Main_Screen_Width, CGRectGetMinY(self.chatToolView.frame));
        self.coverView.hidden = NO;
    }];
}
-(void)keyBoardHidden:(NSNotification*)info {
    [UIView animateWithDuration:0.25 animations:^{
        self.chatToolView.frame = CGRectMake(0, Main_Screen_Height + chatToolViewHeight, Main_Screen_Width, chatToolViewHeight);
    } completion:^(BOOL finished) {
        self.chatToolView.hidden = YES;
        self.coverView.hidden = YES;
    }];
}

#pragma mark - 懒加载
-(NSMutableArray *)chatArr {
    if (!_chatArr) {
        _chatArr = [NSMutableArray array];
    }
    return _chatArr;
}

-(TDBeautyView *)beautyView {
    if (!_beautyView) {
//        _beautyView = [TDBeautyView new];
        _beautyView = [[TDBeautyView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height-140*TDAutoSizeScaleX, Main_Screen_Width, 140*TDAutoSizeScaleX)];
        _beautyView.delegate = self;
        [self addSubview:_beautyView];
        
        [_beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _beautyView;
}

-(TDChatToolView *)chatToolView {
    if (!_chatToolView) {
//        _chatToolView = [TDChatToolView new];
        _chatToolView = [[TDChatToolView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height + chatToolViewHeight, Main_Screen_Width, chatToolViewHeight)];
        _chatToolView.delegate = self;
        [self addSubview:_chatToolView];
    }
    return _chatToolView;
}

-(UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor clearColor];
        [self addSubview:_coverView];
    }
    return _coverView;
}

- (UIView *)bulletsupview{
    if (!_bulletsupview) {
        //创建礼物飘屏view
//        _bulletsupview = [UIView new];
        _bulletsupview = [[UIView alloc] initWithFrame:CGRectMake(0, 180*TDAutoSizeScaleX, Main_Screen_Width, 100*TDAutoSizeScaleX)];
        _bulletsupview.backgroundColor = [UIColor greenColor];
        [self addSubview:_bulletsupview];
    }
    return _bulletsupview;
}

-(TCMsgBulletView *)bulletViewOne {
    if (!_bulletViewOne) {
        _bulletViewOne = [TCMsgBulletView new];
        [self.bulletsupview addSubview:_bulletViewOne];
    }
    return _bulletViewOne;
}

-(TCMsgBulletView *)bulletViewTwo {
    if (!_bulletViewTwo) {
        _bulletViewTwo = [TCMsgBulletView new];
        [self.bulletsupview addSubview:_bulletViewTwo];
    }
    return _bulletViewTwo;
}

- (TDGiveGoodView *)giveGiftView{
    if (!_giveGoodView) {
        _giveGoodView = [[TDGiveGoodView alloc] initWithFrame:CGRectMake(_chatTableView.right+10*TDAutoSizeScaleX, _bulletsupview.bottom+20*TDAutoSizeScaleX, 100*TDAutoSizeScaleX, 180*TDAutoSizeScaleX)];
        _giveGoodView.backgroundColor = [UIColor grayColor];
        [self addSubview:_giveGoodView];
    }
    return _giveGoodView;
}

@end
