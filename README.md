# JCParallaxScrollBanner
iOS OC Banner Parallax (视差无限轮播)
迅速集成 视差特效 无限轮播
1.引用头文件并遵守协议

	#import "JCParallaxBanner.h"
	<JCBannerDelegate>
2.初始化

	NSArray *urlArr = @[
	@"http://www.jc.com/site/about/upload/cms/56a8785e6672a.jpg",
	@"http://www.jc.com/site/about/upload/cms/55c1c23de1e09.jpg",
	@"http://www.jc.com/site/about/upload/cms/55ac6bb93c56b.jpg",
	@"http://www.jc.com/site/about/upload/cms/5656d844ccc40.jpg"];
	
	JCParallaxBanner *banner = [JCParallaxBanner parallaxBannerViewWithFrame:
	CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200) imageURLArray:urlArr]; 
    
    banner.bannerDelegate = self;
    
    [self.view addSubview:banner];

3.实现代理方法
	
	- (void)didSelectStarkBannerAtIndex:(NSInteger)index
	{
	    
	    NSLog(@"================%ld===============",index);
	}


