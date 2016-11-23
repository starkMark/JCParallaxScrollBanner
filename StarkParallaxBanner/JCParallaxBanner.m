//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

/**
 1.视差动画
 2.无限轮播
 3.自动轮播
 4.PageControl 动画
 */

//适配各种屏幕 设计稿按iPhone6的屏幕来适配
#define kFitH(oHeight) (oHeight)*kSCREEN_HEIGHT/667.0
#define kFitW(oWidth) (oWidth)*kSCREEN_WIDTH/375.0

#import "JCAnimatedPageControl.h"
#import "JCParallaxBanner.h"
#import "JCCollectionViewCell.h"
#import "JCParallaxCollectionLayout.h"

#import "SDImageCache.h"
#import "SDWebImageManager.h"

@interface JCParallaxBanner ()

@property (nonatomic, weak) UIControl *pageControl;

@property (nonatomic, weak) NSTimer *parallaxTimer;

/** 处理图片加载失败重试次数，默认为3 */
@property (nonatomic, assign) NSInteger networkFailedRetryCount;

@property (nonatomic, assign) NSInteger totalItemsCount;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayOut;
@property (nonatomic, strong) JCParallaxCollectionLayout *parallaxLayout;

@property (nonatomic, strong) UICollectionView * parallaxCollectionView;

@end

@implementation JCParallaxBanner
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setParallaxCollection];
    }
    return self;
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
    
    [self initPageControl];
    
    if (!self.backgroundImageView) {
        self.backgroundImageView.frame = self.bounds;
    }
}

- (void)setParallaxCollection{
    if (_needParallax) {
        _parallaxLayout = [[JCParallaxCollectionLayout alloc]init];
        _parallaxCollectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:_parallaxLayout];
    }else{
        _flowLayOut = [[UICollectionViewFlowLayout alloc] init];
        _flowLayOut.itemSize = self.frame.size;
        _flowLayOut.minimumLineSpacing = 0;
        _flowLayOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _parallaxCollectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:_flowLayOut];
    }
    
    [_parallaxCollectionView registerClass:[JCCollectionViewCell class] forCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier]];
    _parallaxCollectionView.bounces = NO;
    _parallaxCollectionView.delegate = self;
    _parallaxCollectionView.dataSource = self;
    _parallaxCollectionView.pagingEnabled = YES;
    _parallaxCollectionView.backgroundColor = [UIColor lightGrayColor];
    _parallaxCollectionView.showsHorizontalScrollIndicator = NO;
    _parallaxCollectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:_parallaxCollectionView];
        
}

- (void)initialization{
    _autoScroll = YES;
    _infiniteLoop = YES;
    _needParallax = YES;
    _autoScrollInterval = 5.0;
    _pageControlAliment = JCPageContolAlimentRight;
    _showPageControl = YES;
    _dotSize = CGSizeMake(10, 10);
    _pageControlStyle = JCPageContolStyleAnimated;
    _hidesForSinglePage = YES;

}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItemsCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    long itemIndex = indexPath.item % self.imageViewArray.count;
    UIImage *image = self.imageViewArray[itemIndex];
    if (image.size.width == 0 && self.placeholderImage) {
        image = self.placeholderImage;
        [self loadImageAtIndex:itemIndex];
    }
    cell.parallaxImageView.image = image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.bannerDelegate respondsToSelector:@selector(didSelectStarkBannerAtIndex:)]) {
        [self.bannerDelegate didSelectStarkBannerAtIndex:indexPath.item % self.imageViewArray.count];
    }
}

#pragma mark - Scroll Delegate
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
    
    if (_needParallax) {
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
    
    }
    
    if (self.infiniteLoop) {
        [self infiniteLoopScroll];
    }
    
    int itemIndex = (scrollView.contentOffset.x + self.parallaxCollectionView.frame.size.width * 0.5) / self.parallaxCollectionView.frame.size.width;
    if (!self.imageViewArray.count) return; // 解决清除timer时偶尔会出现的问题
    int indexOnPageControl = itemIndex % self.imageViewArray.count;
    
    if ([self.pageControl isKindOfClass:[JCAnimatedPageControl class]]) {
        JCAnimatedPageControl *pageControl = (JCAnimatedPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 手动滑动时自动轮播关闭
    if (self.autoScroll) {
        [_parallaxTimer invalidate];
        _parallaxTimer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 手动滑动结束时自动轮播继续
    if (self.autoScroll) {
        [self setParallaxTimer];
    }
}

#pragma mark - 自动轮播
- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [_parallaxTimer invalidate];
    _parallaxTimer = nil;
    
    if (_autoScroll) {
        [self setParallaxTimer];
    }
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval{
    _autoScrollInterval = autoScrollInterval;
    [self setAutoScroll:self.autoScroll];
}

- (void)setParallaxTimer{
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval  target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _parallaxTimer  = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)automaticScroll{
    if (_parallaxTimer == 0) return;
    int currentIndex = _parallaxCollectionView.contentOffset.x / _parallaxLayout.parallaxItemSize.width;
    if (!_needParallax) {
       currentIndex =  _parallaxCollectionView.contentOffset.x / _flowLayOut.itemSize.width;
    }
    int targetIndex = currentIndex + 1;
    if (targetIndex == _totalItemsCount) {
        
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_parallaxCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    [_parallaxCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)infiniteLoopScroll{
    if (self.infiniteLoop) {

        int currentIndex = _parallaxCollectionView.contentOffset.x / _flowLayOut.itemSize.width;

        if (_needParallax) {
            currentIndex = _parallaxCollectionView.contentOffset.x / _parallaxLayout.parallaxItemSize.width;
        }
        int targetIndex = currentIndex + 1;
        if (targetIndex == _totalItemsCount) {
            targetIndex = _totalItemsCount * 0.5;
            [_parallaxCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
        
        if (currentIndex == 0) {
            targetIndex = _totalItemsCount * 0.5;
            [_parallaxCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

- (void)setCurrentIndex:(NSInteger)index {
    [self setCurrentIndex:index animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL) animated {
    _currentIndex = index;
    [_parallaxCollectionView setContentOffset:CGPointMake(index * self.frame.size.width, 0.0f) animated:animated];
}

#pragma mark - setter
- (void)setImageURLArray:(NSMutableArray *)imageURLArray{
    _imageURLArray = imageURLArray;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLArray.count];
    for (int i = 0; i < imageURLArray.count; i++) {
        UIImage *image = [[UIImage alloc] init];
        [images addObject:image];
    }
    self.imageViewArray = images;
    [self loadImageWithImageURLsGroup:imageURLArray];
    
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
    
    [self setupPageControl];
    [self.parallaxCollectionView reloadData];
}

/* placeholderImage */
- (void)setPlaceholderImage:(UIImage *)placeholderImage{
    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView) {
        UIImageView *imageView = [UIImageView new];
        [self insertSubview:imageView belowSubview:self.parallaxCollectionView];
        self.backgroundImageView.frame = self.bounds;
    }
}

#pragma mark - 图片缓存
- (void)loadImageWithImageURLsGroup:(NSArray *)imageURLsGroup{
    for (int i = 0; i < imageURLsGroup.count; i++) {
        [self loadImageAtIndex:i];
    }
}

- (void)loadImageAtIndex:(NSInteger)index{
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

#pragma mark - PageControl
- (void)initPageControl{
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[JCAnimatedPageControl class]]) {
        JCAnimatedPageControl *pageControl = (JCAnimatedPageControl *)_pageControl;
        size = [pageControl sizeForNumberOfPages:self.imageViewArray.count];
    } else {
        size = CGSizeMake(self.imageViewArray.count * self.dotSize.width * 1.2, self.dotSize.height);
    }
    CGFloat x = (self.frame.size.width - size.width) * 0.5;
    if (self.pageControlAliment == JCPageContolAlimentRight) {
        x = self.parallaxCollectionView.frame.size.width - size.width - 10;
    }
    CGFloat y = self.parallaxCollectionView.frame.size.height - size.height - 10;
    
    if ([self.pageControl isKindOfClass:[JCAnimatedPageControl class]]) {
        JCAnimatedPageControl *pageControl = (JCAnimatedPageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    _pageControl.frame = CGRectMake(x, y, size.width, size.height);
    
    _pageControl.hidden = !_showPageControl;
    
}
- (void)setupPageControl{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    
    if ((self.imageViewArray.count <= 1) && self.hidesForSinglePage) {
        return;
    }
    
    switch (self.pageControlStyle) {
        case JCPageContolStyleAnimated:
        {
            JCAnimatedPageControl *pageControl = [[JCAnimatedPageControl alloc] init];
            pageControl.numberOfPages = self.imageViewArray.count;
            pageControl.dotColor = self.dotColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        case JCPageContolStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imageViewArray.count;
            pageControl.currentPageIndicatorTintColor = self.dotColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            break;
    }
}

- (void)setPageControlStyle:(JCPageContolStyle)pageControlStyle{
    _pageControlStyle = pageControlStyle;
    
    [self setupPageControl];
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize{
    _dotSize = pageControlDotSize;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[JCAnimatedPageControl class]]) {
        JCAnimatedPageControl *pageContol = (JCAnimatedPageControl *)_pageControl;
        pageContol.dotSize = pageControlDotSize;
    }
}

- (void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
}

- (void)setDotColor:(UIColor *)dotColor{
    _dotColor = dotColor;
    if ([self.pageControl isKindOfClass:[JCAnimatedPageControl class]]) {
        JCAnimatedPageControl *pageControl = (JCAnimatedPageControl *)_pageControl;
        pageControl.dotColor = dotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = dotColor;
    }
    
}

- (void)dealloc{
    _parallaxCollectionView.delegate = nil;
    _parallaxCollectionView.dataSource = nil;
}

@end
