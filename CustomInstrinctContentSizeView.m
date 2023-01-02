#import "CustomInstrinctContentSizeView.h"

@implementation CustomInstrinctContentSizeView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (NSSize)size {
    CustomInstrinctContentSizeView *view = [[CustomInstrinctContentSizeView alloc] init];
    view._intrinsicContentSize = size;
    return view;
}

-(NSSize)intrinsicContentSize
{
    return self._intrinsicContentSize;
}

@end

