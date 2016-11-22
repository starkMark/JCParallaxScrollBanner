//
//  JCCollectionViewCell.m
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

#import "JCCollectionViewCell.h"

@implementation JCCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setParallaxImage];
    }
    return self;
}

- (void)setParallaxImage{
    _parallaxImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _parallaxImageView.contentMode = UIViewContentModeScaleAspectFill;
    _parallaxImageView.clipsToBounds = YES;
    [self.contentView addSubview:_parallaxImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

+ (NSString*) reuseIdentifier{
    return NSStringFromClass([JCCollectionViewCell class]);
}
@end
