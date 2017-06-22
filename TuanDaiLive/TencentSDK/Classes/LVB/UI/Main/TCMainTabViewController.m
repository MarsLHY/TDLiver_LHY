//
//  TCMainTabViewController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCMainTabViewController.h"
#import "TCNavigationController.h"
//#import "TCShowViewController.h"
#import "TCLiveListViewController.h"
#import "TCPushController.h"
#import "UIImage+Additions.h"
#import "TCPushSettingViewController.h"
#import "TCUserInfoController.h"
#import "UIAlertView+BlocksKit.h"
#import "TCVideoRecordViewController.h"
#import <QBImagePickerController/QBImagePickerController.h>
#import "TXVideoLoadingController.h"

#define BOTTOM_VIEW_HEIGHT              225

typedef enum : NSUInteger {
    PickerCut = 1,
    PickerComposite = 2
} PickerType;

@interface TCMainTabViewController ()<UITabBarControllerDelegate, TCLiveListViewControllerListener>
//QBImagePickerControllerDelegate

@property UIButton *liveBtn;

@end

@implementation TCMainTabViewController
{
    TCLiveListViewController *_showVC;
    
    UIView *                 _botttomView;
    PickerType               _pickerType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    [self initBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addChildViewMiddleBtn];
}

- (void)setup {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -15, self.tabBar.width, 64)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setImage:[UIImage imageNamed:@"blur"]];
    [self.tabBar insertSubview:imageView atIndex:0];
    
    _showVC = [TCLiveListViewController new];
    _showVC.listener = self;
    
    UIViewController *_ = [UIViewController new];
    UIViewController *v3 = [TCUserInfoController new];
    self.viewControllers = @[_showVC, _, v3];
    
    [self addChildViewController:_showVC imageName:@"video_normal" selectedImageName:@"video_click" title:nil];
    [self addChildViewController:_ imageName:@"" selectedImageName:@"" title:nil];
    [self addChildViewController:v3 imageName:@"User_normal" selectedImageName:@"User_click" title:nil];
    
    self.delegate = self; // this make tabBaController call
    [self setSelectedIndex:2];
}

//添加推流按钮
- (void)addChildViewMiddleBtn {
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tabBar addSubview:bgBtn];
    bgBtn.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
    //bgBtn.backgroundColor = [UIColor redColor];
    [bgBtn addTarget:self action:@selector(onLiveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    bgBtn.frame = CGRectMake(self.tabBar.frame.size.width/2-80, 0, 160, 120);
    bgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 35, 70, 35);
    
    self.liveBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.tabBar addSubview:btn];
        
        [btn setImage:[UIImage imageNamed:@"play_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"play_click"] forState:UIControlStateSelected];
        btn.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
        [btn addTarget:self action:@selector(onLiveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(self.tabBar.frame.size.width/2-60, -8, 120, 120);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 35, 70, 35);
        btn;
    });
}

- (void)addChildViewController:(UIViewController *)childController imageName:(NSString *)normalImg selectedImageName:(NSString *)selectImg title:(NSString *)title {
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:childController];
    childController.tabBarItem.image = [[UIImage imageNamed:normalImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:selectImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.title = title;
    [self addChildViewController:nav];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    //|| viewController == [tabBarController.viewControllers objectAtIndex:2]
    if (viewController == [tabBarController.viewControllers objectAtIndex:0]) {
        return NO;
    }
    return YES;
}

- (void)onLiveButtonClicked {
    if (_botttomView) {
        [_botttomView removeFromSuperview];
        [self.view addSubview:_botttomView];
        _botttomView.hidden = NO;
    }
}

- (void)showPushSettingView
{
    TCPushSettingViewController *publish = [TCPushSettingViewController new];
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:publish];
    [self presentViewController:nav animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void) initBottomView
{
    _botttomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.size.height - BOTTOM_VIEW_HEIGHT, self.view.width, BOTTOM_VIEW_HEIGHT)];
    _botttomView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _botttomView.hidden = YES;
    [self.view addSubview:_botttomView];
    CGSize size = _botttomView.frame.size;
    
    int btnBkgViewHeight = 65;
    
    UIView * btnBkgView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - btnBkgViewHeight, size.width, btnBkgViewHeight)];
    btnBkgView.backgroundColor = [UIColor whiteColor];
    btnBkgView.userInteractionEnabled = YES;
    [_botttomView addSubview:btnBkgView];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [btnBkgView addGestureRecognizer:singleTap];

    UIImageView * imageHidden = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    imageHidden.image = [UIImage imageNamed:@"hidden"];
    imageHidden.center = CGPointMake(self.view.width / 2, btnBkgViewHeight / 2);
    [btnBkgView addSubview:imageHidden];
    
    int btnSize = 65;
    UIButton * btnLive = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    [btnLive setImage:[UIImage imageNamed:@"liveex"] forState:UIControlStateNormal];
    [btnLive setImage:[UIImage imageNamed:@"liveex_press"] forState:UIControlStateSelected];
    [btnLive addTarget:self action:@selector(onLiveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel* labelLive = [[UILabel alloc]init];
    labelLive.frame = CGRectMake(0, 0, 150, 150);
    [labelLive setText:@"直播"];
    [labelLive setFont:[UIFont fontWithName:@"" size:14]];
    [labelLive sizeToFit];
    
    UIButton * btnVideo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    [btnVideo setImage:[UIImage imageNamed:@"videoex"] forState:UIControlStateNormal];
    [btnVideo setImage:[UIImage imageNamed:@"videoex_press"] forState:UIControlStateSelected];
    [btnVideo addTarget:self action:@selector(onVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    UILabel* labelVideo = [[UILabel alloc]init];
    labelVideo.frame = CGRectMake(0, 0, 150, 150);
    [labelVideo setText:@"小视频"];
    [labelVideo setFont:[UIFont fontWithName:@"" size:14]];
    [labelVideo sizeToFit];
    
    UIButton * btnCut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    [btnCut setImage:[UIImage imageNamed:@"cut"] forState:UIControlStateNormal];
    [btnCut setImage:[UIImage imageNamed:@"cut_press"] forState:UIControlStateSelected];
    [btnCut addTarget:self action:@selector(onLiveCutClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel* labelCut = [[UILabel alloc]init];
    labelCut.frame = CGRectMake(0, 0, 150, 150);
    [labelCut setText:@"视频编辑"];
    [labelCut setFont:[UIFont fontWithName:@"" size:14]];
    [labelCut sizeToFit];
    
    UIButton * btnComp = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    [btnComp setImage:[UIImage imageNamed:@"composite"] forState:UIControlStateNormal];
    [btnComp setImage:[UIImage imageNamed:@"composite_press"] forState:UIControlStateSelected];
    [btnComp addTarget:self action:@selector(onLiveCompClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* labelComp = [[UILabel alloc]init];
    labelComp.frame = CGRectMake(0, 0, 150, 150);
    [labelComp setText:@"视频合成"];
    [labelComp setFont:[UIFont fontWithName:@"" size:14]];
    [labelComp sizeToFit];
    
    int height = btnSize + labelLive.frame.size.height + 5;
    int totalHeight = BOTTOM_VIEW_HEIGHT - btnBkgViewHeight;
    btnLive.center = CGPointMake(self.view.width / 8, (totalHeight - height ) / 2 + btnSize / 2 );
    labelLive.center = CGPointMake(btnLive.center.x, totalHeight - (totalHeight - height ) / 2 - labelVideo.frame.size.height / 2);
    btnVideo.center = CGPointMake(self.view.width * 3 / 8, (totalHeight - height) / 2 + btnSize / 2);
    labelVideo.center = CGPointMake(btnVideo.center.x, totalHeight - (totalHeight - height ) / 2 - labelVideo.frame.size.height / 2);
    btnCut.center = CGPointMake(self.view.width * 5 / 8, (totalHeight - height ) / 2 + btnSize / 2 );
    labelCut.center = CGPointMake(btnCut.center.x, totalHeight - (totalHeight - height ) / 2 - labelVideo.frame.size.height / 2);
    btnComp.center = CGPointMake(self.view.width * 7 / 8, (totalHeight - height) / 2 + btnSize / 2);
    labelComp.center = CGPointMake(btnComp.center.x, totalHeight - (totalHeight - height ) / 2 - labelVideo.frame.size.height / 2);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _botttomView.height - 62, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = UIColorFromRGB(0xD8D8D8);
    
    [_botttomView addSubview:btnLive];
    [_botttomView addSubview:labelLive];
    [_botttomView addSubview:btnVideo];
    [_botttomView addSubview:labelVideo];
    [_botttomView addSubview:btnCut];
    [_botttomView addSubview:labelCut];
    [_botttomView addSubview:btnComp];
    [_botttomView addSubview:labelComp];
    [_botttomView addSubview:lineView];
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if (_botttomView) {
        _botttomView.hidden = YES;
    }
}

-(void)onLiveBtnClicked
{
    if (_showVC != nil && _showVC.playVC != nil) {
        _showVC.playVC = nil;
    }
    
    [self showPushSettingView];
    
    _botttomView.hidden = YES;
}

-(void)onVideoBtnClicked
{
    TCVideoRecordViewController *videoRecord = [TCVideoRecordViewController new];
//    [self.navigationController pushViewController:videoRecord animated:YES];
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:videoRecord];
    [self presentViewController:nav animated:YES completion:nil];
    _botttomView.hidden = YES;
}

-(void)onEnterPlayViewController
{
    if (_botttomView) {
        _botttomView.hidden = YES;
    }
}

/*
-(void)onLiveCutClicked
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = QBImagePickerMediaTypeVideo;
    imagePickerController.allowsMultipleSelection = NO;
    imagePickerController.showsNumberOfSelectedAssets = NO;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    _botttomView.hidden = YES;
    _pickerType = PickerCut;
}

-(void)onLiveCompClicked
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = QBImagePickerMediaTypeVideo;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 20;
    imagePickerController.showsNumberOfSelectedAssets = YES;
//    imagePickerController.maximumNumberOfSelection = 5;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    _botttomView.hidden = YES;
    _pickerType = PickerComposite;
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    [self dismissViewControllerAnimated:YES completion:^ {
        TXVideoLoadingController *loadvc = [[TXVideoLoadingController alloc] init];
        loadvc.composeMode = (_pickerType == PickerComposite);
        TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:loadvc];
        [self presentViewController:nav animated:YES completion:nil];
        [loadvc exportAssetList:assets];
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
 */
@end
