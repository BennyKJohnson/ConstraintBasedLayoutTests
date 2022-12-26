#import "LayoutSpyView.h"

@implementation LayoutSpyView

-(void)layoutEngineDidChangeAlignmentRect {
    self.layoutEngineDidChangeAlignmentRectCallCount++;
}

@end