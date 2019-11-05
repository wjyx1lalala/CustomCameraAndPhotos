//
//  PhotoDetailCollectionCell.m
//  JiPei
//
//  Created by 申屠 on 2017/11/1.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "PhotoDetailCollectionCell.h"
#import "HighSpeedImageCache.h"
#import "PhotosLoader.h"

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define BOUNDCE_DURATION 0.3f

static NSString * LoadImageOver = @"LoadImageOver";

@interface PhotoDetailCollectionCell()<UIScrollViewDelegate>{
	CGRect originFrame;
	CGFloat scale;
}

@property(nonatomic,strong)UIScrollView *scrollView;

@end

@implementation PhotoDetailCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
	
	self = [super initWithFrame:frame];
	if (self) {
		originFrame = frame;
		scale = 1.0;
		self.fixed = NO;
		[self setUpUI];
	}
	return self;
	
}

- (void)setUpUI{
	
	_imgV = [[UIImageView alloc] initWithFrame:self.bounds];
	_imgV.contentMode = UIViewContentModeScaleAspectFit;
	_imgV.userInteractionEnabled = YES;
	
	_scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
	_scrollView.delegate = self;
	//设置伸缩比例
	_scrollView.contentSize = _imgV.frame.size;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.maximumZoomScale=2.5;
	_scrollView.minimumZoomScale=1.0;
	_scrollView.decelerationRate = 0.1;
	_scrollView.bounces = NO;
	[_scrollView setZoomScale:1 animated:NO];
	//	_scrollView.panGestureRecognizer.delegate = self;
	[_scrollView addSubview:_imgV];
	[self addSubview:_scrollView];
	
}

-(void)setAsset:(PHAsset *)asset{
	_asset = asset;
	NSString * localIdentifier = [NSString stringWithFormat:@"assetdetail%@",asset.localIdentifier];
	//先从全部缓存中找图片,如果没有去图库中请求
	UIImage * image = [[HighSpeedImageCache sharedImageCache] imageFromMemoryCacheForKey:localIdentifier];
	if (image) {
		self.imgV.image = image;
		[[NSNotificationCenter defaultCenter] postNotificationName:LoadImageOver object:nil];
	}else{
		[[PhotosLoader sharePhotoTool] requestImageForAsset:_asset size:self.bounds.size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
			if(image){
				self.imgV.image = image;
				[[NSNotificationCenter defaultCenter] postNotificationName:LoadImageOver object:nil];
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
					[[HighSpeedImageCache sharedImageCache] storeImage:image forKey:localIdentifier];
				});
			}
		}];
	}
}

-(void)setFixed:(BOOL)fixed{
	if(fixed){
		_imgV.frame = self.bounds;
		_scrollView.contentSize = _imgV.frame.size;
	}
}

#pragma mark - UIScrollViewDelegate,告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return _imgV;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
	CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width) *0.5 : 0.0;
	CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?(_scrollView.bounds.size.height - _scrollView.contentSize.height) *0.5 : 0.0;
	_imgV.center =CGPointMake(_scrollView.contentSize.width *0.5 + offsetX,_scrollView.contentSize.height *0.5 + offsetY);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
	
}


@end



