//
//  JCParallaxBanner.m
//  JCBannerKit
//
//  Created by pg on 16/11/11.
//  Copyright © 2016年 starkShen. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SDImageCache.h"
#import "SDWebImageManager.h"

#import "JCParallaxCollectionLayout.h"
#import "JCCollectionViewCell.h"
#import "JCParallaxBanner.h"

@interface JCParallaxBanner ()

// 处理图片加载失败
@property (nonatomic, assign) NSInteger networkFailedRetryCount;
@property (nonatomic, assign) NSInteger totalItemsCount;
@end
@implementation JCParallaxBanner

#pragma mark - Life Cycle
//- (instancetype)initWithFrame:(CGRect)frame picArray:(NSArray *)picArr{
//    return [self initWithFrame:frame picArray:picArr parallaxType:JCParallaxTypeHorizontal];
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setParallaxBanner];
    }
    return self;
}

- (void)setParallaxBanner{
    JCParallaxCollectionLayout *parallaxLayout = [[JCParallaxCollectionLayout alloc]init];
    _parallaxCollectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:parallaxLayout];
    [_parallaxCollectionView registerClass:[JCCollectionViewCell class] forCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier]];
    _parallaxCollectionView.delegate = self;
    _parallaxCollectionView.dataSource = self;
    _parallaxCollectionView.pagingEnabled = YES;
    _parallaxCollectionView.showsHorizontalScrollIndicator = NO;
    _parallaxCollectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:_parallaxCollectionView];
    _infiniteLoop = YES;
    _minOffset = self.frame.size.width * 0.2;

}

+ (instancetype)parallaxBannerViewWithFrame:(CGRect)frame imageURLArray:(NSArray *)imageURLArray{
    JCParallaxBanner *parallaxBanner = [[JCParallaxBanner alloc]initWithFrame:frame];
    parallaxBanner.imageURLArray = [NSMutableArray arrayWithArray:imageURLArray];;
    return parallaxBanner;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _parallaxCollectionView.frame = self.bounds;
    if (_parallaxCollectionView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop && _totalItemsCount) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_parallaxCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItemsCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    long itemIndex = indexPath.item % self.imageViewArray.count;
    NSLog(@"========index:%ld\n==========%@",indexPath.row,self.imageViewArray);
    UIImage *image = self.imageViewArray[itemIndex];
    if (image.size.width == 0 && self.placeholderImage) {
        image = self.placeholderImage;
        [self loadImageAtIndex:itemIndex];
    }
    cell.parallaxImageView.image = image;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.bannerDelegate respondsToSelector:@selector(didSelectStarkBannerAtIndex:)]) {
        [self.bannerDelegate didSelectStarkBannerAtIndex:indexPath.row];
    }
}

#pragma mark - Scroll Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
  
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {

    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _currentIndex = scrollView.contentOffset.x/self.frame.size.width;//  .不调用 setter 方法

    NSInteger leftIndex = -1;
    NSInteger rightIndex = -1;

    leftIndex = _currentIndex;
    
    if(_currentIndex < (_totalItemsCount - 1)) {
        rightIndex = leftIndex + 1;
    }

    CGFloat leftImageMargingLeft = scrollView.contentOffset.x > 0 ? ((fmod(scrollView.contentOffset.x + self.frame.size.width,self.frame.size.width))):0.0f;
    CGFloat leftImageWidth = (self.frame.size.width) - (fmod(fabs(scrollView.contentOffset.x),self.frame.size.width));
    CGFloat rightImageMarginLeft = 0.0f;
    CGFloat rightImageWidth = leftImageMargingLeft;

    if(leftIndex >= 0){
        JCCollectionViewCell * leftCell = (JCCollectionViewCell*)[self.parallaxCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leftIndex inSection:0]];
        CGRect frame = leftCell.parallaxImageView.frame;
        frame.origin.x = leftImageMargingLeft;
        frame.size.width = leftImageWidth;
        leftCell.parallaxImageView.frame = frame;
    }
    if(rightIndex >= 0){
        JCCollectionViewCell * rightCell = (JCCollectionViewCell*)[self.parallaxCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:rightIndex inSection:0]];
        CGRect frame = rightCell.parallaxImageView.frame;
        frame.origin.x = rightImageMarginLeft;
        frame.size.width = rightImageWidth;
        rightCell.parallaxImageView.frame = frame;
    }

    
//    当滚动到最后一张图片时，继续滚向后动跳到第一张
//            if (scrollView.contentOffset.x > self.frame.size.width * (self.imageURLArray.count -1) + _minOffset)
//            {
//                _currentIndex = 0;
//                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//                [self.parallaxCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
//            }
//    
//    //当滚动到第一张图片时，继续向前滚动跳到最后一张
//    
//            if (scrollView.contentOffset.x < - _minOffset)
//            {
//                _currentIndex = _imageURLArray.count -1;
//                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
//                [self.parallaxCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//            }
//    NSLog(@"============%.2f==========",scrollView.contentOffset.x);
    
}
//  占位图
//   自动轮播
#pragma mark - 自动轮播
- (void)setCurrentIndex:(NSInteger)index {
    [self setCurrentIndex:index animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL) animated {
    _currentIndex = index;
    [_parallaxCollectionView setContentOffset:CGPointMake(index * self.frame.size.width, 0.0f) animated:animated];
}

- (void)setImageURLArray:(NSMutableArray *)imageURLArray
{
    _imageURLArray = imageURLArray;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLArray.count];
    for (int i = 0; i < imageURLArray.count; i++) {
        UIImage *image = [[UIImage alloc] init];
        [images addObject:image];
    }
    self.imageViewArray = images;
    [self loadImageWithImageURLsGroup:imageURLArray];

}


- (void)loadImageWithImageURLsGroup:(NSArray *)imageURLsGroup
{
    for (int i = 0; i < imageURLsGroup.count; i++) {
        [self loadImageAtIndex:i];
    }
}

- (void)loadImageAtIndex:(NSInteger)index
{
    NSString *urlStr = self.imageURLArray[index];
    NSURL *url = nil;
    
    
    if ([urlStr isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlStr];
    } else if ([urlStr isKindOfClass:[NSURL class]]) { // 兼容NSURL
        url = (NSURL *)urlStr;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (image) {
        [self.imageViewArray setObject:image atIndexedSubscript:index];
    } else {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                if (index < self.imageURLArray.count && [self.imageURLArray[index] isEqualToString:urlStr]) { // 修复频繁刷新异步数组越界问题
                    [self.imageViewArray setObject:image atIndexedSubscript:index];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.parallaxCollectionView reloadData];
                    });
                }
            } else {
                if (self.networkFailedRetryCount > 30) return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadImageAtIndex:index];
                });
                self.networkFailedRetryCount++;
            }
        }];
    }
}


- (void)setImageViewArray:(NSMutableArray *)imageViewArray{
    _imageViewArray = imageViewArray;
    
    _totalItemsCount = self.infiniteLoop ? self.imageViewArray.count * 100 : self.imageViewArray.count;
    
    if (imageViewArray.count != 1) {
        self.parallaxCollectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.parallaxCollectionView.scrollEnabled = NO;
    }
    
    [self.parallaxCollectionView reloadData];
}


#pragma mark - 图片缓存
- (void)loadImage:(UIImageView *)imageView atIndex:(NSInteger)index
{
    NSString *urlStr = self.imageURLArray[index];
    NSURL *url = nil;
    
    if ([urlStr isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlStr];
    } else if ([urlStr isKindOfClass:[NSURL class]]) { // 兼容NSURL
        url = (NSURL *)urlStr;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (image) {
        [imageView setImage:image];
    } else {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                if (index < self.imageURLArray.count && [self.imageURLArray[index] isEqualToString:urlStr]) { // 修复频繁刷新异步数组越界问题
                    [imageView setImage:image];
                }
            } else {
                //  处理加载异常
                if (self.networkFailedRetryCount > 30) return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadImage:imageView atIndex:index];
                });
                self.networkFailedRetryCount++;
            }
        }];
    }
}


- (void)dealloc{
    _parallaxCollectionView = nil;
}

@end
