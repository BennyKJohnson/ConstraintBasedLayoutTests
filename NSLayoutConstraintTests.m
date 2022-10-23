#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import <AppKit/NSAutoresizingMaskLayoutConstraint.h>
#import "GSAutoLayoutEngine.h"

@interface NSLayoutConstraintTests : XCTestCase

@end

@implementation NSLayoutConstraintTests

- (void)setUp {
    [NSApplication sharedApplication];
}

- (void)initLayoutEngineWithWidthAndHeightConstraintsForView: (NSView*)view size: (NSSize)size
{    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant: size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    [view _initializeLayoutEngine];
    GSAutoLayoutEngine *engine = [view _layoutEngine];
    [engine addConstraint: widthConstraint];
    [engine addConstraint: heightConstraint];
}

- (void)testCanSetLayoutEngineOnView {
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    NSView *view = [[NSView alloc] init];
    [view _setLayoutEngine: engine];
    XCTAssertEqual([view _layoutEngine], engine);
}

-(void)testSetLayoutEngineSetsLayoutEngineOnSubViews
{
    NSView *view = [[NSView alloc] init];
    NSView *subView = [[NSView alloc] init];
    NSView *subSubView = [[NSView alloc] init];

    [view addSubview: subView];
    [subView addSubview:  subSubView];

    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    [view _setLayoutEngine: engine];

    XCTAssertEqual([subView _layoutEngine], engine);
    XCTAssertEqual([subSubView _layoutEngine], engine);
}

- (void)testWindowLayoutEngineReturnsLayoutEngineOfBorderView {
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    NSWindow *window = [[NSWindow alloc] init];
    [[window _windowView] _setLayoutEngine: engine];
    XCTAssertEqual([window _layoutEngine], engine);
}

// - (void)testInitializesLayoutEngineAfterAddingViewThatRequiresLayoutEngine {
//     NSWindow *window = [[NSWindow alloc] init];
//     XCTAssertNil([window _layoutEngine]);
//     NSView *view = [[NSView alloc ]init];
//     NSLayoutConstraint *widthConstraint = [[NSLayoutConstraint alloc] init]

//     XCTAssertTrue([[window _layoutEngine] isKindOfClass: [GSAutoLayoutEngine class]]);
// }

- (void)testCanInitalizeAutoLayoutEngineOnView {
    NSView *view = [[NSView alloc] init];
    [view _initializeLayoutEngine];
    XCTAssertNotNil([view _layoutEngine]);
}

-(void)testSetSuperViewUpdatesViewLayoutEngineToSuperViewLayoutEngine
{
    NSView *view = [[NSView alloc] init];
    NSView *subView = [[NSView alloc] init];

    [view _initializeLayoutEngine];
    [view addSubview: subView];

    XCTAssertEqual([subView _layoutEngine], [view _layoutEngine]);
}

-(void)testViewInitalizeLayoutEngineAddsInternalConstraints
{
    NSView *view = [[NSView alloc] init];
    [self initLayoutEngineWithWidthAndHeightConstraintsForView: view size: NSMakeSize(500,500)];

    NSRect viewAlignmentRect = [[view _layoutEngine] alignmentRectForView: view];
    XCTAssertTrue(NSEqualRects(viewAlignmentRect,NSMakeRect(0, 0, 500, 500)));
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
    NSView *view = [[NSView alloc] init];
    [view _initializeLayoutEngine];
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

- (void)testViewTranslatesAutoresizingMaskIntoConstraintsDefaultsToTrue
{
    NSView *view = [[NSView alloc] init];
    XCTAssertTrue(view.translatesAutoresizingMaskIntoConstraints);
}

- (void)testViewSetTranslatesAutoresizingMaskIntoConstraints
{
    NSView *view = [[NSView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    XCTAssertFalse([view translatesAutoresizingMaskIntoConstraints]);
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    XCTAssertTrue([view translatesAutoresizingMaskIntoConstraints]);
}

- (void)testUpdateConstraintsInstallsAutoresizingConstraints
{
    NSView *superview = [[NSView alloc] init];
    NSView *view = [[NSView alloc] init];
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    [superview _setLayoutEngine: engine];
    [superview addSubview: view];

    [view setAutoresizingMask:NSViewWidthSizable];
    [view updateConstraints];

    NSUInteger superViewConstraintCount = [[superview constraints] count];
    XCTAssertEqual([[view constraints] count], 3);
    XCTAssertEqual(superViewConstraintCount, 1);
}


@end
