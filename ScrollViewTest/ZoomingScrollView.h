//
//  ZoomingScrollView.h
//  ScrollViewTest
//
//  Created by Tony on 2017/1/3.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomingScrollView : UIScrollView

@property (nonatomic) UIImageView *imageView;

- (void)setDisplayImage:(UIImage *)image;

@end
