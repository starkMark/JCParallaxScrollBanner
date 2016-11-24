//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

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

/** Banner Settings*/

/** 是否自动滚动,默认Yes */
@property (nonatomic, assign) BOOL autoScroll;

/** 是否无限循环,默认Yes */
@property (nonatomic, assign) BOOL infiniteLoop;

/** 是否需要视差特效，默认Yes */
@property (nonatomic, assign) BOOL needParallax;

/** 自动滚动间隔时间,默认 5s */
@property (nonatomic, assign) CGFloat autoScrollInterval;

/** 网络图片 URL字符串数组 */
@property (nonatomic, strong) NSMutableArray *imageURLArray;

/** 本地图片 */
@property (nonatomic, strong) NSMutableArray *imageViewArray;

/** JCBannerDelegate */
@property (nonatomic, weak) id<JCBannerDelegate> bannerDelegate;

/** 当前Index */
@property (nonatomic, assign) NSInteger currentIndex;

/** 占位图，用于网络未加载到图片时 */
@property (nonatomic, strong) UIImage *placeholderImage;

/** 当 imageURLArray 为空时的背景图 */
@property (nonatomic, weak) UIImageView *backgroundImageView;

/** 视差模式 */
@property (nonatomic, assign) JCParallaxType parallaxType;

/** Define PageControl*/

/** 点大小 */
@property (nonatomic, assign) CGSize dotSize;

/** 点颜色 */
@property (nonatomic, strong) UIColor *dotColor;

/** PageControl 显示开关 */
@property (nonatomic, assign) BOOL showPageControl;

/** PageControl 只有一页时不显示，默认 YES */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/** PageControl 样式 */
@property (nonatomic, assign) JCPageContolStyle pageControlStyle;

/** PageControl 位置枚举 */
@property (nonatomic, assign) JCPageContolAliment pageControlAliment;

/**
 *  imageURLArray ：网络图片URL数组
 *  placeholderImage : 占位图
 */
+ (instancetype)parallaxBannerViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)placeholderImage imageURLArray:(NSArray *)imageURLArray;

@end
