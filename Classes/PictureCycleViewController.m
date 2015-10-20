//
//  PictureCycleViewController.m
//  S01-图片轮播()
//
//  Created by Jerry on 15/7/3.
//  Copyright (c) 2015年 Jerry. All rights reserved.
//

#import "PictureCycleViewController.h"
#import "PictureCycleCell.h"
#import "NSTimer+SRTimer.h"

@interface PictureCycleViewController ()<PictureCycleCellDelegate>

/// 当前图片索引
@property (nonatomic, assign) NSInteger currentIndex;

/// 循环时间
@property (nonatomic, strong) NSTimer *cycleTimer;

/// 循环布局
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

// pageController
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation PictureCycleViewController

static NSString * const reuseIdentifier = @"PictureCycleCellID";

//cell被选中的代理方法
- (void)pictureCycleCellDidSelected:(NSInteger)itemTag {
    NSLog(@"选中第%zd张图片",itemTag);
}

#pragma mark - CollectionView 操作函数
// 加载 view
- (void)loadView {
	
	// 创建view
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	// 创建 collection 设置frame和布局
	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout: self.layout];
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.showsVerticalScrollIndicator = NO;				// 关闭垂直滑动
	self.collectionView.pagingEnabled = YES;							// 开启分页功能
	self.collectionView.dataSource = self;								// 设置数据源代理
	self.collectionView.delegate = self;
    
    //创建pageControl
    self.pageControl = [[UIPageControl alloc] init];
    [self.collectionView.superview addSubview:self.pageControl];
    
    //设置初始化时间间隔
    self.cycleTimeInterval = 2;
}

// view 加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Register cell classes (注册cell)
    [self.collectionView registerClass:[PictureCycleCell class] forCellWithReuseIdentifier:reuseIdentifier];
	[self timeStart];
}

// view 即将显示
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    [self.cycleTimer resumeTimerAfterTimeInterval:self.cycleTimeInterval];
    
    self.pageControl.numberOfPages = self.cycleImageList.count;
    self.pageControl.center = CGPointMake(self.collectionView.superview.frame.size.width * 0.5, self.collectionView.frame.size.height * 0.9);
	// 设置从第2个页开始显示
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	
	// 设置滑动位置
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cycleTimer pauseTimer];
}

// layout 设置
- (void)viewDidLayoutSubviews {
	// 设置 item 尺寸
	self.layout.itemSize = self.view.bounds.size;
}

#pragma mark - UICollectionViewDataSource 数据源方法
// 返回组数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.cycleImageList.count;
}

/// 返回 ItemTag
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    PictureCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//	self.cellIndex = indexPath.item;
	NSInteger index = (indexPath.item - 1 + self.cycleImageList.count + self.currentIndex ) % self.cycleImageList.count;
	
	cell.image = self.cycleImageList[index];
	cell.delegate = self;
	cell.itemTag = index;
	
    return cell;
}

#pragma mark - UIScrollView滚动结束后的代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	NSInteger offset = (NSInteger)(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width) - 1;
	
	if (offset != 0) {
		
		self.currentIndex = (self.currentIndex + self.cycleImageList.count + offset) % self.cycleImageList.count;

		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
		
		[UIView setAnimationsEnabled:NO];
		[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
		[UIView setAnimationsEnabled:YES];
		
        self.pageControl.currentPage = self.currentIndex;

	}
}

#pragma mark - 定时器相关方法
// 打开定时器启动自动循环播放图片
- (void)timeStart {
	
	// 1. 创建定时器
	self.cycleTimer = [NSTimer timerWithTimeInterval:self.cycleTimeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:true];
	
	// 2. 添加定时器
	[[NSRunLoop currentRunLoop] addTimer:self.cycleTimer forMode:NSRunLoopCommonModes];
}

// 切换到下一张
- (void)nextImage {

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem: 2 inSection:0];
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

// 开始拖拽 停止定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.cycleTimer pauseTimer];
//	[self.cycleTimer invalidate];
//	self.cycleTimer = nil;
}

// 拖拽停止 添加定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

//	self.cycleTimer = [NSTimer timerWithTimeInterval:self.cycleTimeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
//	
//	[[NSRunLoop currentRunLoop] addTimer:self.cycleTimer forMode:NSRunLoopCommonModes];
    [self.cycleTimer resumeTimer];
}

// 动画执行完成后执行
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

	NSInteger offset = (NSInteger) (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width) - 1;
	
	if (offset != 0) {
		
		self.currentIndex = (self.currentIndex + self.cycleImageList.count + offset) % self.cycleImageList.count;

		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
		
		[UIView setAnimationsEnabled:NO];
		[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
		[UIView setAnimationsEnabled:YES];
		
		self.pageControl.currentPage = self.currentIndex;
	}
}

#pragma mark - 懒加载
// 懒加载返回 UICollectionItems 布局(layout)
- (UICollectionViewFlowLayout *)layout {
	
	if (!_layout) {
		_layout = [[UICollectionViewFlowLayout alloc] init];					// 创建layout
//		_layout.itemSize = self.view.bounds.size;								// 设置items 大小
		_layout.itemSize = CGSizeMake(self.view.frame.size.width, 200);			// 设置items 大小
		_layout.minimumInteritemSpacing = 0;									// 设置最小间距
		_layout.minimumLineSpacing = 0;											// 设置最小行间距
		_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;	// 设置滚动方向
	}
	return _layout;
}

@end
