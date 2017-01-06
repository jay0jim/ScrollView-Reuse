//
//  ZoomingScrollView.m
//  ScrollViewTest
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "ZoomingScrollView.h"

@interface ZoomingScrollView ()
    <UIScrollViewDelegate>

@property (assign) CGSize imageSize;

@property (assign) CGFloat ratio;
@property (assign) CGRect zoomRect;

@end

@implementation ZoomingScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initials];
    }
    return self;
}

- (void)initials {
    self.delegate = self;
//    self.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)setDisplayImage:(UIImage *)image {
    self.contentSize = image.size;
    _imageSize = image.size;
    CGFloat ratioW = self.frame.size.width / image.size.width;
    CGFloat ratioH = self.frame.size.height / image.size.height;
    _ratio = ratioW < ratioH? ratioW : ratioH;
    
    _imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_imageView];
    
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = _ratio;
    [self setZoomScale:_ratio];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat zoomW = _imageSize.width * self.zoomScale;
    CGFloat zoomH = _imageSize.height * self.zoomScale;
    CGFloat rectX = (self.frame.size.width - zoomW) * 0.5;
    CGFloat rectY = (self.frame.size.height - zoomH) * 0.5;
    _zoomRect = CGRectMake(rectX, rectY, zoomW, zoomH);
    
    if (self.zoomScale <= _ratio) {
        _imageView.frame = _zoomRect;
    } else {
        _imageView.frame = CGRectMake(0, 0, zoomW, zoomH);
    }
    
}

#pragma mark - UIScorllViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Handle Gesture
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer {
    
    if (self.zoomScale < 0.99) {
        CGPoint point = [recognizer locationInView:recognizer.view];
        CGFloat touchX = point.x / _ratio - self.bounds.size.width * 0.5;
        CGFloat touchY = point.y / _ratio - self.bounds.size.width * 0.5;
        CGRect zoomToRect = CGRectMake(touchX, touchY, self.bounds.size.width, self.bounds.size.height);
        [self zoomToRect:zoomToRect animated:YES];
        
    } else {
        [self setZoomScale:_ratio animated:YES];
    }
}

- (void)dealloc {
    NSLog(@"zoomingView dealloc");
}

@end











