//
//  ViewController.m
//  ScrollViewTest
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "ViewController.h"

#import "ZoomingScrollView.h"

#define kFirstDisplayView 0
#define kTotalImage 16
#define kScreenFrame [UIScreen mainScreen].bounds

@interface ViewController ()
    <UIScrollViewDelegate>

@property (nonatomic) NSMutableSet *visibleViews;
@property (nonatomic) NSMutableSet *reusableViews;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *imageArray;

@property (assign) NSInteger currentIndex;
@property (assign) NSInteger previousIndex;
@property (assign) NSInteger nextIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
//    [self displayImage];
}

- (void)initial {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    _visibleViews = [[NSMutableSet alloc] initWithCapacity:1000];
    _reusableViews = [[NSMutableSet alloc] initWithCapacity:10];
    
    _currentIndex = 0;
    _previousIndex = _currentIndex - 1;
    _nextIndex = _currentIndex + 1;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:screenFrame];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.contentSize = CGSizeMake(kTotalImage * screenFrame.size.width, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    ZoomingScrollView *zoomingView = [self viewAtIndex:_currentIndex];
    [_scrollView addSubview:zoomingView];
}

- (ZoomingScrollView *)viewAtIndex:(NSUInteger) index {
    ZoomingScrollView *zoomingView = [self dequeReusableView];
    
    NSString *imageName = [NSString stringWithFormat:@"%lu", index+1];
//    // 这是一个坑爹的方法，用这个方法load的图无法自动释放
//    UIImage *image = [UIImage imageNamed:imageName];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [zoomingView setDisplayImage:image];
    
    CGFloat xPosition = index * kScreenFrame.size.width;
    CGRect viewFrame = CGRectMake(xPosition, 0, kScreenFrame.size.width, kScreenFrame.size.height);
    zoomingView.frame = viewFrame;
    zoomingView.tag = 1000 + index;
    
    [_visibleViews addObject:zoomingView];
    
    return zoomingView;
}

- (ZoomingScrollView *)dequeReusableView {
    ZoomingScrollView *reusableView = [_reusableViews anyObject];
    if (reusableView == nil) {
        reusableView = [[ZoomingScrollView alloc] initWithFrame:kScreenFrame];
    } else {
        [_reusableViews removeObject:reusableView];
    }
    return reusableView;
}

- (void)showNewImage {
    ZoomingScrollView *previousView = nil;
    ZoomingScrollView *nextView = nil;
    
    NSInteger previousIndex = _currentIndex - 1;
    NSInteger nextIndex = _currentIndex + 1;
    
    // 滑动时最多保留n+2个图，n是页面显示数，加上左右的2个
    if (_currentIndex == 0) {
        // 第一张图
        previousIndex = 0;
    } else if (_currentIndex == kTotalImage - 1) {
        // 最后一张图
        nextIndex = kTotalImage - 1;
    }
    
    if (![self isShowingViewAtIndex:previousIndex]) {
        previousView = [self viewAtIndex:previousIndex];
    }
    if (![self isShowingViewAtIndex:nextIndex]) {
        nextView = [self viewAtIndex:nextIndex];
    }
    
    [_scrollView addSubview:previousView];
    [_scrollView addSubview:nextView];
    
    // 其余全部放到reusableViews里
    for (ZoomingScrollView *view in _visibleViews) {
        NSInteger viewIndex = view.tag - 1000;
        if (viewIndex < previousIndex || viewIndex > nextIndex) {
            [_reusableViews addObject:view];
            view.imageView.image = nil;
            [view removeFromSuperview];
        }
    }
    
    // 从visibleViews里删除刚刚去掉的view
    [_visibleViews minusSet:_reusableViews];
    // reusableViews中最多保留2个view
    while (_reusableViews.count > 2) {
        [_reusableViews removeObject:[_reusableViews anyObject]];
    }
    
}

- (BOOL)isShowingViewAtIndex:(NSInteger) index {
    for (ZoomingScrollView *view in _visibleViews) {
        if (view.tag - 1000 == index) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showNewImage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentIndex = _scrollView.contentOffset.x / 320;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
