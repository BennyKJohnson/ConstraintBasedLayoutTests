@interface ConstraintLayoutSpyView: NSView

@property (nonatomic) NSUInteger layoutCalledCount;

@property (nonatomic) NSUInteger updateConstraintsCalledCount;

@property (nonatomic) NSUInteger updateConstraintsForSubtreeIfNeededCalledCount;

@property (nonatomic) BOOL superViewWasLayedOut;

-(BOOL)updateConstraintsCalled;

@end

@implementation ConstraintLayoutSpyView

-(void)layout
{
    if (self.superview && [self.superview isKindOfClass:[ConstraintLayoutSpyView class]]) {
        if ([(ConstraintLayoutSpyView*)self.superview layoutCalledCount]) {
            self.superViewWasLayedOut = true;
        }
    }
    self.layoutCalledCount++;
}

-(void)updateConstraints {
    BOOL subViewHasBeenUpdated = YES;
    for (NSView *subView in self.subviews) {
        if ([subView isKindOfClass:[ConstraintLayoutSpyView class]]) {
            if (![(ConstraintLayoutSpyView*) subView updateConstraintsCalled]) {
                subViewHasBeenUpdated = NO;
            }
        }
    }
    
    if (subViewHasBeenUpdated) {
        self.updateConstraintsCalledCount++;
    }
     [super updateConstraints];
}

-(BOOL)updateConstraintsCalled
{
    return self.updateConstraintsCalledCount > 0;
}

-(void)updateConstraintsForSubtreeIfNeeded {
    self.updateConstraintsForSubtreeIfNeededCalledCount++;
    [super updateConstraintsForSubtreeIfNeeded];
}

@end

