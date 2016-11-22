//
//  JCParallaxCollectionLayout.m
//  JCBannerKit
//
//  Created by pg on 16/11/14.
//  Copyright © 2016年 starkShen. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "JCParallaxCollectionLayout.h"

@implementation JCParallaxCollectionLayout
- (instancetype) init{
    self = [super init];
    if (self) {
    }
    return self;
}

/* overwrite prepareLayout*/
- (void)prepareLayout{
    CGSize boundSize = self.collectionView.bounds.size;
    boundSize.width = boundSize.width;
    self.parallaxItemSize = boundSize;
}

/* define contentSize */
- (CGSize)collectionViewContentSize{
    NSInteger itemNum = [self.collectionView numberOfItemsInSection:0];
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width *itemNum, self.collectionView.bounds.size.height);
    return size;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = _parallaxItemSize;
    attributes.center = CGPointMake(indexPath.row *self.collectionView.bounds.size.width + self.collectionView.bounds.size.width/2, self.collectionView.bounds.size.height/2);
    
    return attributes;
}

/* 返回指定区域cell、Supplementary View和Decoration View的布局属性 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0,j = [self.collectionView numberOfItemsInSection:0]; i<j; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}


@end
