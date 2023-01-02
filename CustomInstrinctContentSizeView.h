
#ifndef CustomInstrinctContentSizeView_h
#define CustomInstrinctContentSizeView_h

#import <AppKit/AppKit.h>

@interface CustomInstrinctContentSizeView : NSView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (NSSize)size;

@property NSSize _intrinsicContentSize;

@end

#endif /* CustomInstrinctContentSizeView_h */
