
#ifndef CustomInstrinctContentSizeView_h
#define CustomInstrinctContentSizeView_h

@interface CustomInstrinctContentSizeView : NSView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (NSSize)size;

@property NSSize _intrinsicContentSize;

@end

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

#endif /* CustomInstrinctContentSizeView_h */
