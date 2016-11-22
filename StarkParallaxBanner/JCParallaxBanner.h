//
//  JCParallaxBanner.h
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

#import <UIKit/UIKit.h>
/** Define Enum */
typedef enum {
    JCParallaxTypeHorizontal = 0,   // 水平视差
    JCParallaxTypeVertical = 1      // 垂直视差
}JCParallaxType;

typedef enum {
    JCPageContolAlimentRight,
    JCPageContolAlimentCenter
} JCPageContolAliment;               // PageControl 显示位置

typedef enum {
    JCPageContolStyleClassic,        // PageControl 经典样式
    JCPageContolStyleAnimated,       // PageControl 动画效果
    JCPageContolStyleNone            // PageControl 不显示
} JCPageContolStyle;


/** Protocol */
@protocol JCBannerDelegate <NSObject>
- (void)didSelectStarkBannerAtIndex:(NSInteger)index;

@end

@interface JCParallaxBanner : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * parallaxCollectionView;

@property (nonatomic, assign) JCParallaxType parallaxType;// 视差模式


/** Banner Settings*/

// 是否自动滚动,默认Yes
@property (nonatomic, assign) BOOL autoScroll;

// 是否无限循环,默认Yes
@property(nonatomic,assign) BOOL infiniteLoop;

@property (nonatomic, assign) CGFloat autoScrollInterval;// 自动滚动间隔时间,默认 5s

@property (nonatomic, strong) NSMutableArray *imageURLArray;// 网络图片 URL字符串数组

@property (nonatomic, strong) NSArray *titleArray;// 图片对应要显示的文字数组

@property (nonatomic, weak) id<JCBannerDelegate> bannerDelegate;

@property (nonatomic, assign) NSInteger currentIndex;// 当前Index

// 占位图，用于网络未加载到图片时
@property (nonatomic, strong) UIImage *placeholderImage;

/** Define PageControl*/
@property (nonatomic, assign) CGSize dotSize; // 点大小

@property (nonatomic, strong) UIColor *dotColor;// 点颜色

@property (nonatomic, assign) BOOL showPageControl;// PageControl 是否显示

@property (nonatomic, assign) JCPageContolAliment pageControlAliment;// 位置

@property (nonatomic, assign) JCPageContolStyle pageControlStyle;// 样式

@property (nonatomic, strong) UIColor *titleLabelTextColor;

@property (nonatomic, strong) UIFont  *titleLabelTextFont;

@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;

@property (nonatomic, assign) CGFloat titleLabelHeight;

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@property (nonatomic, assign) double minOffset;
/**
 * JCParallaxType ：设置水平视差与垂直视差
 */
//- (instancetype)initWithFrame:(CGRect)frame picArray:(NSArray *)picArr parallaxType:(JCParallaxType)parallaxType;

+ (instancetype)parallaxBannerViewWithFrame:(CGRect)frame imageURLArray:(NSArray *)imageURLArray;
@end
