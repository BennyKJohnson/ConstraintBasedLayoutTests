
#import <XCTest/XCTest.h>
#import "GSAutoLayoutEngine.h"
#import "CustomBaselineView.h"
#import "CustomInstrinctContentSizeView.h"
#import "LayoutSpyView.h"
#import "CSWSpySimplexSolver.h"

// TODO Fix priority strength to support lower priorities that have a value greater than 1
CGFloat minimalPriorityHackValue = 1.0;

@interface GSAutoLayoutEngineTestCase : XCTestCase
{
    GSAutoLayoutEngine *engine;
}
@end

@implementation GSAutoLayoutEngineTestCase

- (void)setUp {
    engine = [[GSAutoLayoutEngine alloc] init];
}

-(NSLayoutConstraint*)widthConstraintForView: (NSView*)view constant: (CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
}

-(NSLayoutConstraint*)heightConstraintForView: (NSView*)view constant: (CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
}

-(NSLayoutConstraint*)optionalLeadingConstraintForView: (NSView*)view constant: (NSInteger)constant
{
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:constant];
    leadingConstraint.priority = NSLayoutPriorityDefaultHigh;
    return leadingConstraint;
}

-(void)addPositionConstraintsForSubView: (NSView*)subView superView: (NSView*)superView position: (NSPoint)position
{
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:position.x];
    
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:position.y];

    [engine addConstraint: xConstraint];
    [engine addConstraint:yConstraint];
}

-(void)pinView: (NSView*)subView toTopLeftCornerOfSuperView: (NSView*)superView
{
    NSLayoutConstraint *subViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [engine addConstraint:subViewLeadingConstraint];
    [engine addConstraint:subViewTopConstraint];
}

-(void)pinView: (NSView*)subView toTopRightCornerOfSuperView: (NSView*)superView
{
    NSLayoutConstraint *subViewTrailing = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [engine addConstraint:subViewTrailing];
    [engine addConstraint:subViewTopConstraint];
}

-(void)pinView: (NSView*)subView toBottomLeftCornerOfSuperView: (NSView*)superView
{
    [self addPositionConstraintsForSubView:subView superView:superView position:NSMakePoint(0, 0)];
}

-(void)addInternalConstraintsToView: (NSView*)view
{
    NSLayoutConstraint *viewMinXConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:32
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    
    NSLayoutConstraint *viewMinYConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:33
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    [engine addConstraints: @[
        viewMinXConstraint,
        viewMinYConstraint,
    ]];
}

- (NSView*)createRootViewWithSize: (NSSize)size
{
    NSView *view = [[NSView alloc] init];

    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    [self addInternalConstraintsToView: view];
    [engine addConstraints: @[
        widthConstraint,
        heightConstraint
    ]];

    return view;
}

- (NSDictionary*)createConstraintsForView: (NSView*)view
{
    [self addInternalConstraintsToView: view];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:view.frame.size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:view.frame.size.height];
    
    [engine addConstraint: widthConstraint];
    [engine addConstraint: heightConstraint];

    return @{
        @"width": widthConstraint,
        @"height": heightConstraint,
    };
}

-(void)centerSubView: (NSView*)subView inSuperView: (NSView*)superView
{
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [engine addConstraint:subViewCenterXConstraint];
    [engine addConstraint:subViewCenterYConstraint];
}

-(void)verticallyStackViewsSuperView: (NSView*)superView topView:(NSView*)topView bottomView: (NSView*)bottomView
{
    [self pinView:topView toTopLeftCornerOfSuperView:superView];
    [self pinView:bottomView toBottomLeftCornerOfSuperView:superView];
    
    NSLayoutConstraint *view1ToView2Constraint = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [engine addConstraint:view1ToView2Constraint];
}

-(void)horizontallyStackViewsInsideSuperView: (NSView*)superView leftView:(NSView*)leftView rightView: (NSView*)rightView
{
    [self pinView:leftView toTopLeftCornerOfSuperView:superView];
    [self pinView:rightView toTopRightCornerOfSuperView:superView];
    NSLayoutConstraint *view1ToView2Constraint = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rightView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    [engine addConstraint:view1ToView2Constraint];
}


-(void)assertAlignmentRect:(NSRect)receivedRect expectedRect: (NSRect)expectedRect
{
    XCTAssertTrue(NSEqualRects(receivedRect, expectedRect));
}

-(void)testSolvesLayoutForRootViewWithWidthAndHeightConstraints
{
    NSView *rootView = [[NSView alloc] init];
    NSLayoutConstraint *viewMinXConstraint = [NSLayoutConstraint
            constraintWithItem:rootView attribute:32
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    
    NSLayoutConstraint *viewMinYConstraint = [NSLayoutConstraint
            constraintWithItem:rootView attribute:33
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    [engine addConstraints: @[viewMinXConstraint, viewMinYConstraint]];
;
    // Define width and height
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:rootView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:800];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:rootView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:600];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];

    NSRect rootViewFrame = [engine alignmentRectForView: rootView];
    [self assertAlignmentRect:rootViewFrame expectedRect: NSMakeRect(0, 0, 800, 600)];
}

-(void)testSolvesLayoutForSubviewWithLeadingTrailingTopAndBottomConstraintsToSuperView
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(800, 600)];
    NSView *subView = [[NSView alloc] init];
    NSArray *layoutAttributes = @[
        @(NSLayoutAttributeLeading),
        @(NSLayoutAttributeTrailing),
        @(NSLayoutAttributeTop),
        @(NSLayoutAttributeBottom),
    ];
    
    for (id attribute in layoutAttributes) {
        NSLayoutAttribute layoutAttribute = [(NSNumber*)attribute unsignedIntegerValue];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:rootView attribute:layoutAttribute multiplier:1.0 constant:10];
        [engine addConstraint: constraint];
    }

    NSRect subViewFrame = [engine alignmentRectForView:subView];
    NSLog(@"%@", NSStringFromRect(subViewFrame));
    [self assertAlignmentRect:subViewFrame expectedRect: NSMakeRect(10, 10, 780, 580)];
}

-(void)testSolvesLayoutForSubViewWithLeftRightConstraintToSuperView
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(500, 500)];
    NSView *subView = [[NSView alloc] init];
    NSArray *layoutAttributes = @[
        @(NSLayoutAttributeLeft),
        @(NSLayoutAttributeRight),
        @(NSLayoutAttributeTop),
        @(NSLayoutAttributeBottom),
    ];
    for (id attribute in layoutAttributes) {
        NSLayoutAttribute layoutAttribute = [(NSNumber*)attribute unsignedIntegerValue];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:rootView attribute:layoutAttribute multiplier:1.0 constant:10];
        [engine addConstraint: constraint];
    }
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    [self assertAlignmentRect:subViewFrame expectedRect:NSMakeRect(10, 10, 480, 480)];
}

-(void)testSolvesLayoutWithHorizontalCenterConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:subViewTopConstraint];
    [engine addConstraint:subViewCenterXConstraint];
        
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    [self assertAlignmentRect:subViewFrame expectedRect:NSMakeRect(150, 280, 100, 100)];
}

-(void)testSolvesLayoutWithVerticalCenterConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:subViewCenterXConstraint];
    [engine addConstraint:subViewCenterYConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(150, 150, 100, 100)));
}

-(void)testSolvesLayoutWithRequiredAndNonRequiredPriorityConstraints
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *nonRequiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    nonRequiredWidthConstraint.priority = NSLayoutPriorityDefaultHigh;
    NSLayoutConstraint *requiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    requiredWidthConstraint.priority = NSLayoutPriorityRequired;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];

    [engine addConstraint:requiredWidthConstraint];

    [engine addConstraint:nonRequiredWidthConstraint];
    [engine addConstraint:heightConstraint];
    [self centerSubView:subView inSuperView:rootView];

    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintsUsingCustomPriorities
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *nonRequiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    nonRequiredWidthConstraint.priority = 499;
    NSLayoutConstraint *requiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    requiredWidthConstraint.priority = 500;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];

    [engine addConstraint:nonRequiredWidthConstraint];
    [engine addConstraint:heightConstraint];
    [self centerSubView:subView inSuperView:rootView];
    [engine addConstraint:requiredWidthConstraint];

    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(100, 150, 200, 100)));
}

-(void)testSolvesLayoutAfterRemovingConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *constraintToRemove = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    widthConstraint.priority = 999;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [engine addConstraint:heightConstraint];
    
    [engine addConstraint:constraintToRemove];
    [engine addConstraint:widthConstraint];
    [self centerSubView:subView inSuperView:rootView];

    NSRect subViewFrameBeforeRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeRemovingConstraint, NSMakeRect(150, 150, 100, 100)));
    
    [engine removeConstraint: constraintToRemove];
    NSRect subViewFrameAfterRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterRemovingConstraint, NSMakeRect(100, 150, 200, 100)));
}

-(void)testSolvesLayoutAfterRemovingSeveralConstraints
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraintToRemove = [self widthConstraintForView:subView constant:100];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:subView constant:200];
    widthConstraint.priority = 999;
    NSLayoutConstraint *heightConstraintToRemove = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:200];
    heightConstraint.priority = 999;

    [self centerSubView:subView inSuperView:rootView];

    [engine addConstraint:widthConstraintToRemove];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraintToRemove];
    [engine addConstraint:heightConstraint];
    

    NSRect subViewFrameBeforeRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeRemovingConstraint, NSMakeRect(150, 150, 100, 100)));
    
    [engine removeConstraints: [NSArray arrayWithObjects:widthConstraintToRemove, heightConstraintToRemove, nil]];
    NSRect subViewFrameAfterRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterRemovingConstraint, NSMakeRect(100, 100, 200, 200)));
}

-(void)testSolvesLayoutWithConstraintThatHasAMultiplier
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    [self centerSubView:subView inSuperView:rootView];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(100, 100, 200, 200)));
}

-(CustomBaselineView*)createBaselineViewInsideSuperView:(NSView*)superView
{
    CustomBaselineView *baselineView = [[CustomBaselineView alloc] init];
    NSLayoutConstraint *baselineWidth = [self widthConstraintForView:baselineView constant:20];
    NSLayoutConstraint *baselineHeight = [self heightConstraintForView:baselineView constant:20];
    NSLayoutConstraint *baselineX = [NSLayoutConstraint constraintWithItem:baselineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *baselineY = [NSLayoutConstraint constraintWithItem:baselineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineWidth];
    [engine addConstraint:baselineHeight];
    [engine addConstraint:baselineX];
    [engine addConstraint:baselineY];
    
    return baselineView;
}

-(void)addSizeConstraintsToView: (NSView*)view size: (NSSize)size
{
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:size.width];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:view constant:size.height];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
}

-(void)testSolvesLayoutWithFirstBaselineConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    
    CustomBaselineView *baselineView = [self createBaselineViewInsideSuperView:rootView];
    baselineView.firstBaselineOffsetFromTop = 5;
    
    NSView *baselineOffsetView = [[NSView alloc] init];
    [self addSizeConstraintsToView:baselineOffsetView size:NSMakeSize(20, 20)];

    NSLayoutConstraint *baselineOffsetX = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *baselineOffsetYConstraint = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:baselineView attribute:NSLayoutAttributeFirstBaseline multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineOffsetX];
    [engine addConstraint:baselineOffsetYConstraint];
    
    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:baselineOffsetView];
    NSLog(@"subview frame: %@", NSStringFromRect(subViewFrameAfterUpdatingConstraint));
    CGFloat expectedY = 400 - 5 - 20;
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, NSMakeRect(0, expectedY, 20, 20)));
}

-(void)testSolvesLayoutWithLastBaselineConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    
    CustomBaselineView *baselineView = [self createBaselineViewInsideSuperView:rootView];
    baselineView.baselineOffsetFromBottom = 10;
    
    NSView *baselineOffsetView = [[NSView alloc] init];
    [self addSizeConstraintsToView:baselineOffsetView size:NSMakeSize(20, 20)];

    NSLayoutConstraint *baselineOffsetX = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *baselineOffsetYConstraint = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:baselineView attribute:NSLayoutAttributeLastBaseline multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineOffsetX];
    [engine addConstraint:baselineOffsetYConstraint];
    
    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:baselineOffsetView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, NSMakeRect(0, 370, 20, 20)));
}

-(void)testAddingConflictingConstraintsDoesNotThrow
{
    NSView *view = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:100];
    NSLayoutConstraint *conflictingWidthConstraint = [self widthConstraintForView:view constant:200];
    
    [engine addConstraint: widthConstraint];
    [engine addConstraint: conflictingWidthConstraint];
}

-(void)testRemovingAConstraintThatHasNotBeenAddedDoesNotThrow
{
    NSView *view = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:100];
    [engine removeConstraint:widthConstraint];
}

-(void)testSolvesLayoutAfterUpdatingConstraint
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:subView constant:100];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    
    [self centerSubView:subView inSuperView:rootView];

    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    
    NSRect subViewFrameBeforeUpdatingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeUpdatingConstraint, NSMakeRect(150, 150, 100, 100)));
    [widthConstraint setConstant:200];

    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, NSMakeRect(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintRelationGreaterThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthGreaterThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthGreaterThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(75, 150, 250, 100)));
}

-(void)testSolvesLayoutWithConstraintRelationLessThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthLessThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthLessThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintAssociatedRelationLessThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthLessThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthLessThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(75, 150, 250, 100)));
}

-(void)testSolvesLayoutWithConstraintAssociatedRelationGreaterThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    NSView *subView = [[NSView alloc] init];
    NSView *associatedView = [[NSView alloc] init];
    
    NSLayoutConstraint *associatedViewWidthConstraint = [self widthConstraintForView:associatedView constant:100];
    NSLayoutConstraint *associatedViewHeightConstraint = [self heightConstraintForView:associatedView constant:100];
    
    
    [self centerSubView:subView inSuperView:rootView];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthGreaterThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:associatedView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:associatedViewWidthConstraint];
    [engine addConstraint:associatedViewHeightConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthGreaterThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, NSMakeRect(75, 150, 250, 100)));
}

-(void)testSolvesLayoutUsingViewIntrinsicContentSize
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    CustomInstrinctContentSizeView *subView = [CustomInstrinctContentSizeView withInstrinctContentSize: NSMakeSize(40, 20)];
    [self addPositionConstraintsForSubView:subView superView:rootView position:NSMakePoint(0, 0)];
    
    NSRect subviewAlignRect = [engine alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subviewAlignRect, NSMakeRect(0, 0, 40, 20)));
}

-(void)testSolvesLayoutWithCompetingIntrinsicContentSizeVerticalHuggingResistancePriorities
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 50)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 50)];
    
    [view1 setContentHuggingPriority:250 forOrientation:NSLayoutConstraintOrientationVertical];
    // TODO Fix priority strength to support content hugging priorities greater than 1
    [view2 setContentHuggingPriority:100 forOrientation:NSLayoutConstraintOrientationVertical];
    
    [self verticallyStackViewsSuperView:rootView topView:view1 bottomView:view2];
        
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view1], NSMakeRect(0, 350, 50, 50)));
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view2], NSMakeRect(0, 0, 50, 350)));
}

 -(void)testSolvesLayoutWithCompetingInstrinctContentSizeHorizonalCompressionResistance
 {
     NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
     CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(250, 20)];
     CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(250, 20)];
    
     [view1 setContentCompressionResistancePriority:750 forOrientation:NSLayoutConstraintOrientationHorizontal];
     [view2 setContentCompressionResistancePriority:700 forOrientation:NSLayoutConstraintOrientationHorizontal];
    
     [self horizontallyStackViewsInsideSuperView:rootView leftView:view1 rightView:view2];
     
     XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view1], NSMakeRect(0, 380, 250, 20)));
     XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view2], NSMakeRect(250, 380, 150, 20)));
 }

-(void)testSolvesLayoutWithCompetingIntrinsicContentSizeHorizontalHuggingResistancePriorities
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 20)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 20)];
   
    [view1 setContentHuggingPriority:250 forOrientation:NSLayoutConstraintOrientationHorizontal];
    [view2 setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];

    [self horizontallyStackViewsInsideSuperView:rootView leftView:view1 rightView:view2];
   
    NSRect view1Rect = [engine alignmentRectForView:view1];
    NSRect view2Rect = [engine alignmentRectForView:view2];
   
    XCTAssertTrue(NSEqualRects(view1Rect, NSMakeRect(0, 380, 50, 20)));
    XCTAssertTrue(NSEqualRects(view2Rect, NSMakeRect(50, 380, 350, 20)));
}

-(void)testSolvesLayoutWithCompetingInstrinctContentSizeVerticalCompressionResistance
{
    NSView *rootView = [self createRootViewWithSize:NSMakeSize(400, 400)];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 250)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(50, 250)];
    
    [view1 setContentCompressionResistancePriority:800 forOrientation:NSLayoutConstraintOrientationVertical];
    [view2 setContentCompressionResistancePriority:700 forOrientation:NSLayoutConstraintOrientationVertical];

    [self verticallyStackViewsSuperView:rootView topView:view1 bottomView:view2];
    
    [self assertAlignmentRect:[engine alignmentRectForView:view1] expectedRect:NSMakeRect(0, 150, 50, 250)];
    [self assertAlignmentRect:[engine alignmentRectForView:view2] expectedRect:NSMakeRect(0, 0, 50, 150)];
}

-(void)assertEveryAddedConstraintsWasRemoved: (CSWSpySimplexSolver*)solver
{
    for (CSWConstraint *addedConstraint in solver.constraints) {
        XCTAssertTrue([solver.removedConstraints containsObject: addedConstraint]);
    }
}

-(void)assertRemovedSupporingConstraints: (CSWSpySimplexSolver*)solver 
{
    // First two constraints are the width and height for the view
    XCTAssertEqual([solver.removedConstraints count], 4);
    // Supporting internal constraint
    XCTAssertEqual(solver.removedConstraints[1], solver.constraints[2]);
    // internal width maxX-minX constraint
    XCTAssertEqual(solver.removedConstraints[2], solver.constraints[0]);
    // internal height maxY-minY constraint
    XCTAssertEqual(solver.removedConstraints[3], solver.constraints[1]);

    [self assertEveryAddedConstraintsWasRemoved: solver];
}

-(CSWSpySimplexSolver*)addAndRemoveConstraintWithAttribute: (NSLayoutAttribute)attribute
{
    NSView *view = [[NSView alloc] init];
    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:view attribute:attribute
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    return solver;
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithLeadingAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeLeading];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithTrailingAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeTrailing];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithLeftAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeLeft];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithRightAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeRight];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithTopAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeTop];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithBottomAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeBottom];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithCenterXAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeCenterX];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithCenterYAttribute
{
    CSWSpySimplexSolver *solver = [self addAndRemoveConstraintWithAttribute: NSLayoutAttributeCenterY];
    [self assertRemovedSupporingConstraints:solver];
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithBaselineAttribute
{
    CustomBaselineView *view = [[CustomBaselineView alloc] init];

    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:view attribute:NSLayoutAttributeBaseline
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    // Baseline constraint will add width + height + baseline property constraints + baseline internal
    XCTAssertEqual([solver.removedConstraints count], 5);
    // Removes baseline property edit constraint
    XCTAssertEqual(solver.removedConstraints[2], solver.constraints[3]);
    // Removes baseline minY constraint
    XCTAssertEqual(solver.removedConstraints[1], solver.constraints[2]);
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithFirstBaselineAttribute
{
    CustomBaselineView *view = [[CustomBaselineView alloc] init];

    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:view attribute:NSLayoutAttributeFirstBaseline
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    XCTAssertEqual([solver.removedConstraints count], 5);
    // Removes baseline property edit constraint
    XCTAssertEqual(solver.removedConstraints[2], solver.constraints[3]);
    // Removes baseline minY constraint
    XCTAssertEqual(solver.removedConstraints[1], solver.constraints[2]);
}

-(void)testRemovesSupportingInternalConstraintWhenRemovingConstraintWithFirstAndSecondItem
{
    NSView *firstView = [[NSView alloc] init];
    NSView *secondView = [[NSView alloc] init];

    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:firstView attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:secondView
        attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    // It should remove the following constraints:
    // first view = width + height + supporting trailing constraint
    // second view = width + height + supporting leading constraint
    // +1 main constraint
    XCTAssertEqual([solver.removedConstraints count], 7);
    [self assertEveryAddedConstraintsWasRemoved: solver];
}

-(void)testDoesNotRemoveSupportingInternalViewConstraintsIfUsedByAnotherConstraint
{
    NSView *firstView = [[NSView alloc] init];
    NSView *secondView = [[NSView alloc] init];

    NSLayoutConstraint *topConstraint = [NSLayoutConstraint
        constraintWithItem:[[NSView alloc] init] attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:secondView
        attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:firstView attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:secondView
        attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: topConstraint];
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    // It should remove the following constraints:
    // first view = width + height + supporting trailing constraint
    // second view = supporting leading constraint
    // +1 main constraint
    XCTAssertEqual([solver.removedConstraints count], 5);
    XCTAssertFalse([solver.removedConstraints containsObject: solver.constraints[0]]);
    XCTAssertFalse([solver.removedConstraints containsObject: solver.constraints[1]]);
}

-(void)testRemovesInstrictSizeConstraintsWhenRemovingConstraint
{
    CustomInstrinctContentSizeView *view = [CustomInstrinctContentSizeView withInstrinctContentSize:NSMakeSize(1, 1)];
    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:view attribute:NSLayoutAttributeLeft
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    CSWSpySimplexSolver *solver = [[CSWSpySimplexSolver alloc] init];
    GSAutoLayoutEngine *alEngine = [[GSAutoLayoutEngine alloc] initWithSolver: solver];
    
    [alEngine addConstraint: constraint];
    [alEngine removeConstraint: constraint];

    XCTAssertEqual([solver.removedConstraints count], 10);
    [self assertEveryAddedConstraintsWasRemoved: solver];
}

//-(void)testNotifyViewsOfAlignmentRectChanges
//{
//    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400)];
//    LayoutSpyView *subView = [[LayoutSpyView alloc] init];
//    
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
//            constraintWithItem:subView attribute:NSLayoutAttributeWidth
//            relatedBy:NSLayoutRelationEqual
//            toItem:nil
//            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
//    [self centerSubView:subView inSuperView:rootView];
//    [rootView addSubview:subView];
//    
//    [engine addConstraint:widthConstraint];
//    [engine addConstraint:heightConstraint];
//    XCTAssertEqual(subView.layoutEngineDidChangeAlignmentRectCallCount, 3);
//    widthConstraint.constant = 200;
//    XCTAssertEqual(subView.layoutEngineDidChangeAlignmentRectCallCount, 4);
//}

-(void)testConstraintsAffectingLayoutForOrientationViewWithoutConstraintsReturnsEmptyArray {
    NSView *view = [[NSView alloc] init];
    
    NSArray *constraints = [engine constraintsAffectingVerticalOrientationForView: view];
    XCTAssertEqual([constraints count], 0);
}

-(void)assertConstraintIsIncludedWithAttribute: (NSLayoutAttribute)attribute orientation: (NSLayoutConstraintOrientation)orientation expectedConstraints: (NSArray*)expectedConstraintNames
{
    NSView *rootView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    NSDictionary *rootViewConstraints = [self createConstraintsForView:rootView];
    NSView *view = [[NSView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [rootView addSubview:view];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:1.0 constant:0];
    [engine addConstraint:constraint];
    
    NSArray *constraints;
    if (orientation == NSLayoutConstraintOrientationHorizontal) {
        constraints = [engine constraintsAffectingHorizontalOrientationForView:view];
    } else {
        constraints = [engine constraintsAffectingVerticalOrientationForView:view];
    }
    XCTAssertEqual([constraints count], [expectedConstraintNames count]);
    
    NSInteger index = 0;
    for (NSString *name in expectedConstraintNames) {
        if ([name isEqualToString:@"constraint"]) {
            XCTAssertEqual([constraints objectAtIndex: index], constraint);
        } else {
            XCTAssertEqual([constraints objectAtIndex:index], rootViewConstraints[name]);
        }
        
        index++;
    }
}

-(void)testLeftConstraintIsIncludedForHorizontal
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeLeft orientation:NSLayoutConstraintOrientationHorizontal expectedConstraints:@[@"constraint"]];
}

-(void)testLeadingConstraintIsIncludedForHorizontal
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeLeading orientation:NSLayoutConstraintOrientationHorizontal expectedConstraints:@[@"constraint"]];
}

-(void)testRightAndWidthConstraintIsIncludedForHorizontal
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeRight orientation:NSLayoutConstraintOrientationHorizontal expectedConstraints:@[@"width", @"constraint"]];
}

-(void)testTrailingAndWidthConstraintIsIncludedForHorizontal
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeTrailing orientation:NSLayoutConstraintOrientationHorizontal expectedConstraints:@[@"width", @"constraint"]];
}

-(void)testConstraintWithBottomAttributeIsIncludedForVertical
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeBottom orientation:NSLayoutConstraintOrientationVertical expectedConstraints:@[@"constraint"]];;
}

-(void)testConstraintWithTopAttributeIsIncludedForVertical
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeTop orientation:NSLayoutConstraintOrientationVertical expectedConstraints:@[@"height",  @"constraint"]];
}

-(void)testConstraintWithCenterXAttibuteIsIncludedForHorizontal
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeCenterX orientation:NSLayoutConstraintOrientationHorizontal expectedConstraints:@[@"width", @"constraint"]];
}

-(void)testConstraintWithCenterYAttibuteIsIncludedForVertical
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeCenterY orientation:NSLayoutConstraintOrientationVertical expectedConstraints:@[@"height", @"constraint"]];
}

-(void)testConstraintWithBaselineAttributeIsIncludedForVertical
{
    [self assertConstraintIsIncludedWithAttribute:NSLayoutAttributeBaseline orientation:NSLayoutConstraintOrientationVertical expectedConstraints:@[@"constraint"]];
}

-(void)testSiblingViewWidthConstraintIsIncludedOrientationHorizontal
{
    NSView *rootView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    [self createConstraintsForView:rootView];
    
    NSView *view = [[NSView alloc] init];
    [rootView addSubview:view];
    
    NSView *view2 = [[NSView alloc] init];
    [rootView addSubview:view2];
    
    NSLayoutConstraint *widthConstraintForView2 = [NSLayoutConstraint constraintWithItem:view2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [engine addConstraint:widthConstraintForView2];
    
    NSLayoutConstraint *widthViewEqualsWidthView2 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [engine addConstraint:widthViewEqualsWidthView2];
    
    NSArray *constraints = [engine constraintsAffectingHorizontalOrientationForView:view];
    XCTAssertEqual([constraints count], 2);
    
    XCTAssertEqual([constraints objectAtIndex:0], widthConstraintForView2);
    XCTAssertEqual([constraints objectAtIndex:1], widthViewEqualsWidthView2);
}

-(void)testImplicitSiblingViewConstraintsAreIncludedForVerticialOrientation
{
    NSView *rootView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];

    NSView *view = [[NSView alloc] init];
    [rootView addSubview:view];
    
    NSView *view2 = [[NSView alloc] init];
    [rootView addSubview:view2];
    
    NSView *view3 = [[NSView alloc] init];
    [rootView addSubview:view3];
    
    NSLayoutConstraint *heightView1EqualsWidthView2 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [engine addConstraint:heightView1EqualsWidthView2];
    
    NSLayoutConstraint *widthView2EqualsHeightView3 = [NSLayoutConstraint constraintWithItem:view2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view3 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [engine addConstraint:widthView2EqualsHeightView3];
    
    NSLayoutConstraint *heightConstraintForView3 = [NSLayoutConstraint constraintWithItem:view3 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [engine addConstraint:heightConstraintForView3];
    
    NSArray *constraints = [engine constraintsAffectingVerticalOrientationForView:view];
    XCTAssertEqual([constraints count], 3);
    
    XCTAssertEqual([constraints objectAtIndex:0], heightView1EqualsWidthView2);
    XCTAssertEqual([constraints objectAtIndex:1], widthView2EqualsHeightView3);
    XCTAssertEqual([constraints objectAtIndex:2], heightConstraintForView3);
}


-(void)addConflictingConstraintsWithAttribute: (NSLayoutAttribute)attribute toView: (NSView*)view
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:1.0 constant:200];
    constraint.priority = NSLayoutPriorityDefaultHigh;
    [engine addConstraint:constraint];
    
    NSLayoutConstraint *conflictingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:1.0 constant:100];
    conflictingConstraint.priority = NSLayoutPriorityDefaultHigh;
    [engine addConstraint:conflictingConstraint];
}

-(NSView*)viewWithConflictingConstraintsWithAttribute: (NSLayoutAttribute)attribute
{
    NSView *view = [[NSView alloc] init];
    [self addConflictingConstraintsWithAttribute:attribute toView:view];

    return view;
}

-(NSView*)subviewWithConflictingConstraintsWithAttribute: (NSLayoutAttribute)attribute
{
    NSView *superView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    [self createConstraintsForView:superView];

    NSView *view = [[NSView alloc] init];
    [superView addSubview:view];
    [self addConflictingConstraintsWithAttribute:attribute toView:view];

    return view;
}

-(void)testViewDoesNotHaveAmbiguousLayoutWithNoConstraints
{
    NSView *view = [[NSView alloc] init];
    XCTAssertFalse([engine hasAmbiguousLayoutForView: view]);
}

-(void)testViewWithNoConflictingConstraintsDoesNotHaveAmbiguousLayout
{
    NSView *superview = [self createRootViewWithSize:NSMakeSize(100, 100)];
    NSView *view = [[NSView alloc] init];
    [superview addSubview:view];

    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:view.frame.size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:view.frame.size.height];
    [view addConstraints:@[widthConstraint, heightConstraint]];
    [self pinView:view toBottomLeftCornerOfSuperView:superview];
    
    XCTAssertFalse([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingWithConstraintsHasAmbiguousLayout
{
    NSView *view = [self viewWithConflictingConstraintsWithAttribute:NSLayoutAttributeWidth];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingHeightConstraintsHasAmbiguousLayout
{
    NSView *view = [self viewWithConflictingConstraintsWithAttribute:NSLayoutAttributeHeight];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingLeadingConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeLeading];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingTrailingConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeTrailing];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingBottomConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeBottom];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingTopConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeTop];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingCenterXConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeCenterX];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingCenterYConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeCenterY];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingLastBaselineConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeLastBaseline];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingFirstBaselineConstraintsHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeFirstBaseline];
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testViewWithConflictingConstraintsOfDifferentDimensionHasAmbiguousLayout
{
    NSView *view = [self subviewWithConflictingConstraintsWithAttribute:NSLayoutAttributeHeight];
    [self addConflictingConstraintsWithAttribute:NSLayoutAttributeWidth toView:view];
    
    XCTAssertTrue([engine hasAmbiguousLayoutForView:view]);
}

-(void)testExerciseAmbiguityInLayoutDoesNothingWhenViewDoesNotAmbiguity
{
    NSView *superview = [self createRootViewWithSize:NSMakeSize(100, 100)];
    LayoutSpyView *view = [[LayoutSpyView alloc] init];
    [superview addSubview:view];
    
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView: view constant:10];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView: view constant:10];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    leadingConstraint.priority = NSLayoutPriorityDefaultHigh;
    
    [engine addConstraints:@[widthConstraint, heightConstraint, bottomConstraint, leadingConstraint]];

    int callCountBeforeExercise = [view layoutEngineDidChangeAlignmentRectCallCount];
    [engine exerciseAmbiguityInLayoutForView: view];
    XCTAssertEqual([view layoutEngineDidChangeAlignmentRectCallCount], callCountBeforeExercise);
}

-(void)testExerciseAmbiguityInLayoutWhenViewDoesHaveAmbiguity
{
    NSView *superview = [self createRootViewWithSize:NSMakeSize(100, 100)];
    LayoutSpyView *view = [[LayoutSpyView alloc] init];
    [superview addSubview:view];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    [engine addConstraints: @[
        [self widthConstraintForView: view constant:10],
        [self heightConstraintForView: view constant:10],
        bottomConstraint,
        [self optionalLeadingConstraintForView:view constant:50],
        [self optionalLeadingConstraintForView:view constant:0]
    ]];

    int callCountBeforeExercise = [view layoutEngineDidChangeAlignmentRectCallCount];
    [engine exerciseAmbiguityInLayoutForView: view];
    NSRect newFrame = [engine alignmentRectForView: view];

    XCTAssertEqual([view layoutEngineDidChangeAlignmentRectCallCount], callCountBeforeExercise + 1);
    XCTAssertTrue(NSEqualRects(newFrame, NSMakeRect(50, 0, 10, 10)));
}

-(void)testExerciseAmbiguityInLayoutCyclesOverSolutions
{
    NSView *superview = [self createRootViewWithSize:NSMakeSize(100, 100)];
    LayoutSpyView *view = [[LayoutSpyView alloc] init];
    [superview addSubview:view];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    [engine addConstraints: @[
        [self widthConstraintForView: view constant:10],
        [self heightConstraintForView: view constant:10],
        bottomConstraint,
        [self optionalLeadingConstraintForView:view constant:10],
        [self optionalLeadingConstraintForView:view constant:0]
    ]];

    int callCountBeforeExercise = [view layoutEngineDidChangeAlignmentRectCallCount];
    [engine exerciseAmbiguityInLayoutForView: view];
    [engine exerciseAmbiguityInLayoutForView: view];
    
    NSRect newFrame = [engine alignmentRectForView: view];
    XCTAssertEqual([view layoutEngineDidChangeAlignmentRectCallCount], callCountBeforeExercise + 2);
    XCTAssertTrue(NSEqualRects(newFrame, NSMakeRect(0, 0, 10, 10)));
}

@end
