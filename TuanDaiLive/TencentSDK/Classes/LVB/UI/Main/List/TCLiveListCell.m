//
//  TCLivePusherInfo.m
//  TCLVBIMDemo
//
//  Created by lynxzhang on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLiveListCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "TCLiveListModel.h"
#import "UIView+Additions.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@interface TCLiveListCell()
{
    UIImageView *_headImageView;
    UILabel     *_titleLabel;
    UILabel     *_nameLabel;
    UILabel     *_visitorCountLabel;
    UILabel     *_likeCountLabel;
    UILabel     *_locationLabel;
    UIImageView *_bigPicView;
    UIImageView *_flagView;
    UIImageView *_timeView;
    UILabel     *_timeLable;
    UIImageView *_locationImageView;
    UIView      *_userMsgView;
    UIView      *_lineView;
    UIImageView *_visitorView;
    UIImageView *_likeView;
    UIImageView *_locationView;
    UIImage     *_defaultImage;
    CGRect      _titleRect;
}

@end

@implementation TCLiveListCell

- (instancetype)initWithFrame:(CGRect)frame videoType:(VideoType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        if (1 == type) {
             [self initUIForUGC];
        }else{
             [self initUIForLiveAndVOD];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (1 == _type) {
        [self layoutForUGC];
    }
    else {
        [self layoutForLiveAndVOD];
    }
}

- (void)initUIForUGC {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.contentView.backgroundColor = UIColorFromRGB(0xEFEFEF);
    //背景图
    _bigPicView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bigPicView.contentMode = UIViewContentModeScaleAspectFill;
    _bigPicView.clipsToBounds = YES;
    [self.contentView addSubview:_bigPicView];
    
    //右上角的时间
    _timeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _timeView.image = [UIImage imageNamed:@"time"];
    _timeLable = [[UILabel alloc] initWithFrame:CGRectZero];
    [_timeLable setFont:[UIFont systemFontOfSize:12]];
    [_timeLable setTextColor:UIColorFromRGB(0xFFFFFF)];
    [_timeLable setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_timeView];
    [self.contentView addSubview:_timeLable];
    
    //用户信息
    _userMsgView = [[UIView alloc] initWithFrame:CGRectZero];
    _userMsgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:_userMsgView];
    
    //line
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_lineView setBackgroundColor:UIColorFromRGB(0xD8D8D8)];
    [_userMsgView addSubview:_lineView];
    
    //头像
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_userMsgView addSubview:_headImageView];
    
    //用户名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [_nameLabel setTextColor:UIColorFromRGB(0x000000)];
    [_userMsgView addSubview:_nameLabel];
    
    if (_defaultImage == nil) {
        _defaultImage = [self scaleClipImage:[UIImage imageNamed:@"bg.jpg"] clipW: [UIScreen mainScreen].bounds.size.width * 2 clipH:274 * 2 ];
    }
}

- (void)initUIForLiveAndVOD {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.contentView.backgroundColor = UIColorFromRGB(0xF6F2F4);
    //背景图
    _bigPicView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bigPicView.contentMode = UIViewContentModeScaleAspectFill;
    _bigPicView.clipsToBounds = YES;
    [self.contentView addSubview:_bigPicView];
    
    //LIVE标记
    _flagView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _flagView.image = [UIImage imageNamed:@"living"];
    [self.contentView addSubview:_flagView];
    
    //用户信息
    _userMsgView = [[UIView alloc] initWithFrame:CGRectZero];
    _userMsgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:_userMsgView];
    
    //line
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_lineView setBackgroundColor:UIColorFromRGB(0xD8D8D8)];
    [_userMsgView addSubview:_lineView];
    
    //头像
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_userMsgView addSubview:_headImageView];
    
    //标题名
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_titleLabel setTextColor:UIColorFromRGB(0x000000)];
    [_userMsgView addSubview:_titleLabel];
    
    //用户名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [_nameLabel setTextColor:UIColorFromRGB(0x777777)];
    [_userMsgView addSubview:_nameLabel];
    
    //拜访者图标
    _visitorView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_visitorView setImage:[UIImage imageNamed:@"visitors"]];
    [_userMsgView addSubview:_visitorView];
    
    //拜访者人数
    _visitorCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_visitorCountLabel setFont:[UIFont systemFontOfSize:12]];
    [_visitorCountLabel setTextColor:UIColorFromRGB(0x777777)];
    [_userMsgView addSubview:_visitorCountLabel];
    
    //点赞图标
    _likeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_likeView setImage:[UIImage imageNamed:@"like"]];
    [_userMsgView addSubview:_likeView];
    
    //点赞人数
    _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_likeCountLabel setFont:[UIFont systemFontOfSize:12]];
    [_likeCountLabel setTextColor:UIColorFromRGB(0x777777)];
    [_userMsgView addSubview:_likeCountLabel];
    
    //位置图标
    _locationView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_locationView setImage:[UIImage imageNamed:@"position"]];
    [_userMsgView addSubview:_locationView];
    
    //位置详情
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_locationLabel setFont:[UIFont systemFontOfSize:12]];
    [_locationLabel setTextColor:UIColorFromRGB(0x777777)];
    [_userMsgView addSubview:_locationLabel];
    
    if (_defaultImage == nil) {
        _defaultImage = [self scaleClipImage:[UIImage imageNamed:@"bg.jpg"] clipW: [UIScreen mainScreen].bounds.size.width * 2 clipH:274 * 2 ];
    }
}

- (void)layoutForUGC {
    //背景图
    _bigPicView.frame = CGRectMake(0 , 0, self.width, self.height - 50);
    
    //右上角的时间
    _timeView.frame = CGRectMake(self.width - 67, 5, 62, 20);
    _timeLable.frame = _timeView.frame;
    
    //用户信息
    _userMsgView.frame = CGRectMake(0, _bigPicView.bottom, self.width, 50);
    
    //line
    _lineView.frame = CGRectMake(0, _userMsgView.height - 1, _userMsgView.width, 1);
    
    //头像
    _headImageView.frame = CGRectMake(14, 7.5, 35, 35);
    _headImageView.layer.cornerRadius  = _headImageView.height * 0.5;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderWidth   = 1;
    _headImageView.layer.borderColor   = kClearColor.CGColor;
    
    //用户名
    _nameLabel.frame = CGRectMake(_headImageView.right + 12, 18, self.width - _headImageView.right - 12, 14);
}

- (void)layoutForLiveAndVOD {
    //背景图
    _bigPicView.frame = CGRectMake(0 , 0, self.width, 274);
    
    //LIVE标记
    _flagView.frame = CGRectMake(7, 7, 60, 30);
    
    //用户信息
    _userMsgView.frame = CGRectMake(0, _bigPicView.bottom, self.width, 60);
    
    //line
    _lineView.frame = CGRectMake(0, _userMsgView.height - 1, _userMsgView.width, 1);
    
    //头像
    _headImageView.frame = CGRectMake(15, 8, 45, 45);
    _headImageView.layer.cornerRadius  = _headImageView.height * 0.5;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderWidth   = 1;
    _headImageView.layer.borderColor   = kClearColor.CGColor;
    
    //标题名
    _titleLabel.frame = CGRectMake(_headImageView.right + 13, 8, _titleRect.size.width, 23);
    if (self.width -  _titleLabel.right < 100) {
        _titleLabel.width = self.width - 100 - 18 - _titleLabel.left;
    }
    
    //用户名
    _nameLabel.frame = CGRectMake(_titleLabel.right + 18, 12, self.width - 10 - _titleLabel.right - 18 ,15);
    
    //拜访者图标
    _visitorView.frame = CGRectMake(_headImageView.right + 13, _lineView.top - 10 - 15, 15, 15);
    
    //拜访者人数
    _visitorCountLabel.frame = CGRectMake(_visitorView.right + 5, _lineView.top - 12 - 11, 44, 11);
    
    //点赞图标
    _likeView.frame = CGRectMake(_visitorCountLabel.right, _lineView.top - 10 - 15, 15, 15);
    
    //点赞人数
    _likeCountLabel.frame = CGRectMake(_likeView.right + 5, _lineView.top - 12 - 11, 44, 11);
    
    //位置图标
    _locationView.frame = CGRectMake(_likeCountLabel.right, _lineView.top - 10 - 15, 15, 15);
    
    //位置详情
    _locationLabel.frame = CGRectMake(_locationView.right + 5, _lineView.top - 12 - 11, self.width - _locationView.right - 5 - 8, 11);
}

- (void)setModel:(TCLiveInfo *)model {
    _model = model;
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_model.userinfo.headpic]]
                      placeholderImage:[UIImage imageNamed:@"face"]];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:_model.title];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    _titleRect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (_titleLabel) _titleLabel.attributedText = title;
   
    
    NSMutableString* name = [[NSMutableString alloc] initWithString:@"@"];
    if (1 == _type) {  // UGC
        name = [[NSMutableString alloc] initWithString:@""];
    }
    if (0 == _model.userinfo.nickname.length) {
        [name appendString:_model.userid];
    }
    else {
        [name appendString:_model.userinfo.nickname];
    }
    if (_nameLabel) _nameLabel.text = name;
    
    if (_visitorCountLabel) _visitorCountLabel.text = [NSString stringWithFormat:@"%d", _model.viewercount];
    if (_likeCountLabel) _likeCountLabel.text = [NSString stringWithFormat:@"%d", _model.likecount];
    if (_locationLabel) _locationLabel.text = _model.userinfo.location;
    
    //self.locationImageView.hidden = NO;
    if (_locationLabel && _locationLabel.text.length == 0) {
        _locationLabel.text = @"不显示地理位置";
    }
    
    __weak typeof(_bigPicView) weakPicView =  _bigPicView;
    [_bigPicView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.userinfo.frontcover]] placeholderImage:_defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        UIImage *newImage = [self scaleClipImage:image clipW:_bigPicView.width clipH:_bigPicView.height];
        if (image != nil) {
            weakPicView.image = image;
        }
    }];
    
    if (_flagView) {
        switch (_model.type) {
            case 0:
                _flagView.image = [UIImage imageNamed:@"living"];
                break;
            case 1:
                _flagView.image = [UIImage imageNamed:@"playback"];
                break;
            case 2:
                _flagView.image = nil;
                break;
            default:
                break;
        }
    }
    
    if (_timeLable) {
        [self setTimeLable:_model.timestamp];
    }
    
    if (1 == _type) {
        [self layoutForUGC];
    }
    else {
        [self layoutForLiveAndVOD];
    }
}

- (void)setType:(NSInteger)type {
    _type = type;
    if (1 == _type) {
        [self initUIForUGC];
    }
    else {
        [self initUIForLiveAndVOD];
    }
}

-(TCLiveInfo *)model{
    _model.userinfo.frontcoverImage = _bigPicView.image;
    return _model;
}

-(UIImage *)scaleClipImage:(UIImage *)image clipW:(CGFloat)clipW clipH:(CGFloat)clipH{
    UIImage *newImage = nil;
    if (image != nil) {
        if (image.size.width >=  clipW && image.size.height >= clipH) {
            newImage = [self clipImage:image inRect:CGRectMake((image.size.width - clipW)/2, (image.size.height - clipH)/2, clipW,clipH)];
        }else{
            CGFloat widthRatio = clipW / image.size.width;
            CGFloat heightRatio = clipH / image.size.height;
            CGFloat imageNewHeight = 0;
            CGFloat imageNewWidth = 0;
            UIImage *scaleImage = nil;
            if (widthRatio < heightRatio) {
                imageNewHeight = clipH;
                imageNewWidth = imageNewHeight * image.size.width / image.size.height;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }else{
                imageNewWidth = clipW;
                imageNewHeight = imageNewWidth * image.size.height / image.size.width;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }
            newImage = [self clipImage:image inRect:CGRectMake((scaleImage.size.width - clipW)/2, (scaleImage.size.height - clipH)/2, clipW,clipH)];
        }
    }
    return newImage;
}

/**
 *缩放图片
 */
-(UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *裁剪图片
 */
-(UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)setTimeLable:(int)timestamp {
    NSString *timeStr = @"刚刚";
    int interval = [[NSDate date] timeIntervalSince1970] - timestamp;
    
    if (interval >= 60 && interval < 3600) {
        timeStr = [[NSString alloc] initWithFormat:@"%d分钟前", interval/60];
    } else if (interval >= 3600 && interval < 60*60*24) {
        timeStr = [[NSString alloc] initWithFormat:@"%d小时前", interval/3600];
    } else if (interval >= 60*60*24 && interval < 60*60*24*365) {
        timeStr = [[NSString alloc] initWithFormat:@"%d天前", interval/3600/24];
    } else if (interval >= 60*60*24*265) {
        timeStr = [[NSString alloc] initWithFormat:@"很久前"];
    }
    
    _timeLable.text = timeStr;
}

@end
