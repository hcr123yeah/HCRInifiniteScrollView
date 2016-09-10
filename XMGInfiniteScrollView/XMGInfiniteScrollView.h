//
//  XMGInfiniteScrollView.h
//  无限轮播器
//
//  Created by xiaomage on 16/4/21.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMGInfiniteScrollView;

@protocol XMGInfiniteScrollViewDelegate <NSObject>
@optional
- (void)infiniteScrollView:(XMGInfiniteScrollView *)infiniteScrollView didClickImageAtIndex:(NSInteger)index;
@end

@interface XMGInfiniteScrollView : UIView
/** 需要显示的图片数据(要求里面存放UIImage\NSURL对象) */
@property (nonatomic, strong) NSArray *images;
/** 下载远程图片时的占位图片 */
@property (nonatomic, strong) UIImage *placeholderImage;
/** 用来监听框架内部事件的代理 */
@property (nonatomic, weak) id delegate;
@end
