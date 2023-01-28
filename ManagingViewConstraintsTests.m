#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import <AppKit/NSAutoresizingMaskLayoutConstraint.h>
#import "GSAutoLayoutEngine.h"

@interface ManagingViewConstraintsTests : XCTestCase

@end

@implementation ManagingViewConstraintsTests

- (void)setUp {
    [NSApplication sharedApplication];
}

- (void)initLayoutEngineWithWidthAndHeightConstraintsForView: (NSView*)view size: (NSSize)size
{   
    NSWindow *window = [[NSWindow alloc] init];
    [window setContentView: view];
    [view setFrame: NSMakeRect(0,0, size.width, size.height)];

    [view updateConstraintsForSubtreeIfNeeded];
}

- (NSDictionary*)createSubViewConstraints: (NSView*)subView view: (NSView*)view
{
    NSLayoutConstraint *subViewTrailing = [NSLayoutConstraint
        constraintWithItem:subView 
        attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint
        constraintWithItem:subView
        attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:view
        attribute:NSLayoutAttributeTop
        multiplier:1.0 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
        constraintWithItem:subView
        attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute
        multiplier:1.0 constant:150];
    
    return @{
        @"trailing": subViewTrailing,
        @"top": subViewTopConstraint,
        @"width": widthConstraint,
        @"height": heightConstraint
    };
}

-(NSView*)makeSubView
{
    NSView *superview = [[NSView alloc] init];
    [superview _initializeLayoutEngine];
    NSView *view = [[NSView alloc] init];
    [superview addSubview: view];

    return view;
}

- (void)testViewAddConstraintUpdatesLayoutEngine
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];
    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    
    [subView addConstraint: subViewConstraints[@"top"]];
    [subView addConstraint: subViewConstraints[@"trailing"]];
    [subView addConstraint: subViewConstraints[@"width"]];
    [subView addConstraint: subViewConstraints[@"height"]];

    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(400, 350, 100, 150)));
}

- (void)testViewAddConstraintsUpdatesLayoutEngine
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];

    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];

    [subView addConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];
    
    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(400, 350, 100, 150)));
}

- (void)testViewRemoveConstraintUpdatesLayoutEngnie
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView:view size: NSMakeSize(500, 500)];

    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];

    [subView addConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];

    NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];

    [subView removeConstraint: subViewConstraints[@"width"]];
    [subView addConstraint: newWidthConstraint];
    
    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(300, 350, 200, 150)));
}

- (void)testViewRemoveConstraintsUpdatesLayoutEngine
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];

    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    [subView addConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];

    NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    NSLayoutConstraint *newHeightConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];

    [subView removeConstraints: @[
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];
    [subView addConstraints: @[
       newWidthConstraint,
        newHeightConstraint
    ]];
    
    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(300, 400, 200, 100)));
}

- (NSView*)createViewWithLayoutEngine: (NSSize)size
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];
    return view;
}

- (void)testSettingConstraintToActiveAddsConstraintToLayoutEngine
{
    NSView *view = [self createViewWithLayoutEngine: NSMakeSize(500, 500)];
    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    [subViewConstraints[@"top"] setActive: YES];
    [subViewConstraints[@"trailing"] setActive: YES];
    [subViewConstraints[@"width"] setActive: YES];
    [subViewConstraints[@"height"] setActive: YES];

    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(400, 350, 100, 150)));
}

- (void)testSettingConstraintToInactiveRemovesConstraintFromLayoutEngine
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];

    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    [subView addConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];

    [subViewConstraints[@"width"] setActive: NO];

    NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    
    [subView addConstraints: @[
        newWidthConstraint
    ]];

    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(300, 350, 200, 150)));
}

- (void)testActivateConstraintsAddsConstraintsToLayoutEnigne
{
    NSView *view = [self createViewWithLayoutEngine: NSMakeSize(500, 500)];
    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    [NSLayoutConstraint activateConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];

    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(400, 350, 100, 150)));
}

- (void)testDeactivateConstraintsRemovesConstraintsFromLayoutEngine
{
    NSView *view = [self createViewWithLayoutEngine: NSMakeSize(500, 500)];
    NSView *subView = [[NSView alloc] init];
    [view addSubview: subView];

    NSDictionary *subViewConstraints = [self createSubViewConstraints: subView view: view];
    [NSLayoutConstraint activateConstraints: @[
        subViewConstraints[@"top"],
        subViewConstraints[@"trailing"],
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];

    NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    NSLayoutConstraint *newHeightConstraint = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];

    [NSLayoutConstraint deactivateConstraints: @[
        subViewConstraints[@"width"],
        subViewConstraints[@"height"]
    ]];
    [subView addConstraints: @[
        newWidthConstraint,
        newHeightConstraint
    ]];
    
    NSRect subViewRect = [[view _layoutEngine] alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subViewRect,NSMakeRect(300, 400, 200, 100)));
}

- (void)testViewConstraintsReturnsEmptyArrayWhenNoActivateConstraintsOnView
{
    NSView *view = [[NSView alloc] init];
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    [view _setLayoutEngine: engine];
    [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];

    NSArray *viewConstraints = [view constraints];
    XCTAssertEqual([viewConstraints count], 0);
}

- (void)testViewConstraintsReturnsAllActiveConstraintsOnView
{
    NSView *rootView = [[NSView alloc] init];
    [rootView _initializeLayoutEngine];
    NSView *view = [[NSView alloc] init];
    [rootView addSubview: view];

    NSLayoutConstraint *width = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    NSLayoutConstraint *height = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    width.active = YES;
    height.active = YES;
    
    NSArray *first = [view constraints];
    XCTAssertEqual([first count], 2);
    XCTAssertTrue([first indexOfObject: width] != NSNotFound);
    XCTAssertTrue([first indexOfObject: height] != NSNotFound);

    width.active = NO;
    
    NSArray *second = [view constraints];
    XCTAssertEqual([second count], 1);
    XCTAssertTrue([second indexOfObject: height] != NSNotFound);
}


-(void)testConstraintsAffectingLayoutForOrientationHorizontal
{
    NSView *view = [self makeSubView];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [view.superview addConstraint: leadingConstraint];
    
    NSArray *constraints = [view constraintsAffectingLayoutForOrientation:NSLayoutConstraintOrientationHorizontal];
    XCTAssertEqual([constraints count], 1);
    XCTAssertEqual([constraints objectAtIndex:0], leadingConstraint);
}

-(void)testConstraintsAffectingLayoutForOrientationVertical
{
    NSView *view = [self makeSubView];

    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [view.superview addConstraint: bottomConstraint];
    
    NSArray *constraints = [view constraintsAffectingLayoutForOrientation:NSLayoutConstraintOrientationVertical];

    XCTAssertEqual([constraints count], 1);
    XCTAssertEqual([constraints objectAtIndex:0], bottomConstraint);
}

-(void)testViewWithoutConstraintsDoesNotHaveAmbiguousLayout
{
    NSView *view = [[NSView alloc] init];
    XCTAssertFalse([view hasAmbiguousLayout]);
}

-(void)testViewWithConflictingHasAmbiguousLayout
{
    NSView *view = [self makeSubView];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    leadingConstraint.priority = NSLayoutPriorityDefaultHigh;
    [view.superview addConstraint: leadingConstraint];
    
    NSLayoutConstraint *conflictingLeadingConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20];
    conflictingLeadingConstraint.priority = NSLayoutPriorityDefaultHigh;
    [view.superview addConstraint: conflictingLeadingConstraint];

    XCTAssertTrue([view hasAmbiguousLayout]);
}

@end
