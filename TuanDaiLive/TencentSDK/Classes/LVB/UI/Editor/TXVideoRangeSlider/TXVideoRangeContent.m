//
//  TXVideoRangeContent.m
//  SAVideoRangeSliderExample
//
//  Created by annidyfeng on 2017/4/18.
//  Copyright © 2017年 Andrei Solovjev. All rights reserved.
//

#import "TXVideoRangeContent.h"
#import "UIView+Additions.h"
#import "TXVideoRangeConst.h"

@interface TXVideoRangeContent()

@property CGFloat   leftPinCenterX;
@property CGFloat   rightPinCenterX;

@end

@implementation TXVideoRangeContent {
    CGFloat _imageWidth;
}


- (instancetype)initWithImageList:(NSArray *)images
{
    _imageList = images;
    
    CGRect frame = {.origin = CGPointZero, .size = [self intrinsicContentSize]};
    self = [super initWithFrame:frame];
    
    NSMutableArray *tmpList = [NSMutableArray new];
    for (int i = 0; i < images.count; i++) {
        CGRect imgFrame = CGRectMake(PIN_WIDTH+i*[self imageWidth],
                                     BORDER_HEIGHT,
                                     [self imageWidth],
                                     THUMB_HEIGHT);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame];
        imgView.image = images[i];
        imgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:imgView];
        [tmpList addObject:imgView];
    }
    _imageViewList = tmpList;
   
//    self.centerCover = ({
//        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
//        [self addSubview:view];
//        view.userInteractionEnabled = YES;
//        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
//        [view addGestureRecognizer:panGes];
//        view.accessibilityIdentifier = @"center";
//        view;
//    });
    
    self.leftCover = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        view;
    });
    
    self.rightCover = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        view;
    });
    
    self.leftPin = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left.png"]];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [imageView addGestureRecognizer:panGes];
        imageView;
    });
    
    self.rightPin = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [imageView addGestureRecognizer:panGes];
        imageView;
    });
    
    self.topBorder = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:0.14 green:0.80 blue:0.67 alpha:1];
        view;
    });
    
    self.bottomBorder = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:0.14 green:0.80 blue:0.67 alpha:1];
        view;
    });
    
    self.leftPinCenterX = PIN_WIDTH/2;
    self.rightPinCenterX = frame.size.width-PIN_WIDTH/2;
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([self imageWidth]*self.imageList.count+2*PIN_WIDTH, THUMB_HEIGHT+2*BORDER_HEIGHT);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.leftPin.center = CGPointMake(self.leftPinCenterX, self.center.y);
    self.rightPin.center = CGPointMake(self.rightPinCenterX, self.center.y);
    
    self.topBorder.height = BORDER_HEIGHT;
    self.topBorder.width = self.rightPinCenterX - self.leftPinCenterX;
    self.topBorder.y = 0;
    self.topBorder.x = self.leftPinCenterX;
    
    self.bottomBorder.height = BORDER_HEIGHT;
    self.bottomBorder.width = self.rightPinCenterX - self.leftPinCenterX;
    self.bottomBorder.y = self.leftPin.bottom-BORDER_HEIGHT;
    self.bottomBorder.x = self.leftPinCenterX;
    
    self.centerCover.height = THUMB_HEIGHT-2*BORDER_HEIGHT;
    self.centerCover.width = self.rightPinCenterX - self.leftPinCenterX-PIN_WIDTH;
    self.centerCover.y = BORDER_HEIGHT;
    self.centerCover.x = self.leftPinCenterX+PIN_WIDTH/2;
    
    self.leftCover.height = THUMB_HEIGHT;
    self.leftCover.width = self.leftPinCenterX;
    self.leftCover.y = BORDER_HEIGHT;
    self.leftCover.x = 0;
    
    self.rightCover.height = THUMB_HEIGHT;
    self.rightCover.width = self.width - self.rightPinCenterX;
    self.rightCover.y = BORDER_HEIGHT;
    self.rightCover.x = self.rightPinCenterX;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPinCenterX += translation.x;
        if (_leftPinCenterX < PIN_WIDTH/2) {
            _leftPinCenterX = PIN_WIDTH/2;
        }
        if (_rightPinCenterX-_leftPinCenterX <= PIN_WIDTH) {
            _leftPinCenterX = _rightPinCenterX - PIN_WIDTH;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            [self.delegate onVideoRangeLeftChangeEnded:self];
        }else{
            [self.delegate onVideoRangeLeftChanged:self];
        }
    }
}


- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _rightPinCenterX += translation.x;
        if (_rightPinCenterX > self.width - PIN_WIDTH) {
            _rightPinCenterX = self.width - PIN_WIDTH;
        }
        if (_rightPinCenterX-_leftPinCenterX <= PIN_WIDTH) {
            _rightPinCenterX = _leftPinCenterX + PIN_WIDTH;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            [self.delegate onVideoRangeRightChangeEnded:self];
        }else{
            [self.delegate onVideoRangeRightChanged:self];
        }
    }
}


- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPinCenterX += translation.x;
        _rightPinCenterX += translation.x;
        
        if (_rightPinCenterX > self.width - PIN_WIDTH || _leftPinCenterX < PIN_WIDTH/2){
            _leftPinCenterX -= translation.x;
            _rightPinCenterX -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self.delegate onVideoRangeLeftAndRightChanged:self];
        
    }
}

- (CGFloat)pinWidth
{
    return PIN_WIDTH;
}

- (CGFloat)imageWidth
{
    UIImage *img = self.imageList[0];
    _imageWidth = img.size.width/img.size.height*THUMB_HEIGHT;
    return _imageWidth;
}

- (CGFloat)imageListWidth {
    return self.imageList.count * [self imageWidth];
}

- (CGFloat)leftScale {
    CGFloat imagesLength = [self imageWidth] * self.imageViewList.count;
    return (_leftPinCenterX - PIN_WIDTH/2) / imagesLength;
}

- (CGFloat)rightScale {
    CGFloat imagesLength = [self imageWidth] * self.imageViewList.count;
    return (_rightPinCenterX - PIN_WIDTH/2 - PIN_WIDTH) / imagesLength;
}
@end
