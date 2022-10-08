#import <AppKit/AppKit.h>

@interface ConstraintsSpyWindow: NSWindow

@property (nonatomic) BOOL updateConstraintsIfNeededCalled;

@end

@implementation ConstraintsSpyWindow

- (void)updateConstraintsIfNeeded {
    self.updateConstraintsIfNeededCalled = YES;
    [super updateConstraintsIfNeeded];
}

@end