//
//  XMGInfiniteScrollView.m
//  无限轮播器
//
//  Created by xiaomage on 16/4/21.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGInfiniteScrollView.h"
//#import <UIImageView+WebCache.h>
#import "UIImageView+WebCache.h" // 使用双引号导入的目的是为了防止别人将SD_WebImage文件直接拽进去,然后报错.


/************** XMGImageCell begin **************/
#pragma mark - XMGImageCell begin
@interface XMGImageCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation XMGImageCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        // 注意:这里要加在contentView上面
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 由于坐标系的问题,这里必须使用self.bounds
    self.imageView.frame = self.bounds;
}
@end
/************** XMGImageCell end **************/

/************** XMGInfiniteScrollView begin **************/
#pragma mark - XMGInfiniteScrollView begin
@interface XMGInfiniteScrollView()  <UICollectionViewDataSource, UICollectionViewDelegate>
/** 定时器 */
@property (nonatomic, weak) NSTimer *timer;
/** 用来显示图片的collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation XMGInfiniteScrollView

static NSInteger XMGItemCount = 20; // 这里应该是item个数的倍数,用来将传入的数据整除
static NSString * const XMGImageCellId = @"XMGImageCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        
        // UICollectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        [collectionView registerClass:[XMGImageCell class] forCellWithReuseIdentifier:XMGImageCellId];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        // 默认属性值
        self.placeholderImage = [UIImage imageNamed:@"XMGInfiniteScrollView.bundle/placeholderImage"];
    }
    return self;
}


// 重写set方法是因为,一开始并不知道有多少图片,将这两句代码写入viewdidload中不合适,计算出来的偏移量是错误的
- (void)setImages:(NSArray *)images
{
    _images = images;
    
    // 设置默认显示最中间的图片
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(XMGItemCount * images.count) / 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    });
    
    // 开启定时器
    [self startTimer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // collectionView
    self.collectionView.frame = self.bounds;
    
    // layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = self.bounds.size;
}

#pragma mark - 定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    // 加入到runloop中,防止主线程UI堵塞
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage
{
    CGPoint offset = self.collectionView.contentOffset;
    offset.x += self.collectionView.frame.size.width;
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 返回的item个数是传图数组count * 倍数(用来整除)
    return XMGItemCount * self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMGImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XMGImageCellId forIndexPath:indexPath];
    NSLog(@"%zd",indexPath.item);
    
    // 这里一进来是中间的位置比如 100 % 5 == 0 ///
    // 注意:显示本地图片,用的是字符串拼接的方法,显示外界传给我们的图片时,采用的是利用数组角标0~5 然后使用indexPath.item 得到当前item的角标位置然后模 数组个数,得到对应的图片或则URL
    id data = self.images[indexPath.item % self.images.count];
    // NSLog(@"%zd",indexPath.item % self.images.count);
    if ([data isKindOfClass:[UIImage class]]) {
        cell.imageView.image = data;
    } else if ([data isKindOfClass:[NSURL class]]) {
        [cell.imageView sd_setImageWithURL:data placeholderImage:self.placeholderImage];
    }
      NSLog(@"%zd ",indexPath.item);
    
    //NSLog(@"%zd", indexPath.item);
    
    return cell;
}

#pragma mark - 其他
/**
 *  重置cell的位置到中间
 */
- (void)resetPosition
{
    // 滚动完毕时，自动显示最中间的cell
    
    
    // 使用当前内容的偏移量x值 除以整个collection的宽度,来获得旧item的角标
    NSInteger oldItem = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    
    // 总item的个数除以2 然后加上旧角标摸上数组的长度
    NSInteger newItem = (XMGItemCount * self.images.count / 2) + (oldItem % self.images.count);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newItem inSection:0];
    
    // 滚动index位置( 中间位置+ (0~(数组长度)) )
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didClickImageAtIndex:)]) {
        [self.delegate infiniteScrollView:self didClickImageAtIndex:indexPath.item % self.images.count];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 开启定时器
    [self startTimer];
}

/**
 *  scrollView滚动完毕的时候调用（通过setContentOffset:animated:滚动）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self resetPosition];
}

/**
 *  scrollView滚动完毕的时候调用（人为拖拽滚动）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetPosition];
}
/************** XMGInfiniteScrollView end **************/
@end
