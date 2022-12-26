#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import <AppKit/NSAutoresizingMaskLayoutConstraint.h>
#import "GSAutoLayoutEngine.h"

@interface BootstrapAutoLayoutTests : XCTestCase

@end

@implementation BootstrapAutoLayoutTests

- (void)setUp {
    [NSApplication sharedApplication];
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
    NSWindow *window = [[NSWindow alloc] init];
    [window setContentView: view];
    [view setFrame: NSMakeRect(0,0, 500, 500)];

    [view updateConstraintsForSubtreeIfNeeded];

    NSRect viewAlignmentRect = [[view _layoutEngine] alignmentRectForView: view];
    XCTAssertTrue(NSEqualRects(viewAlignmentRect,NSMakeRect(0, 0, 500, 500)));
}

-(void)testAddingConstraintsToViewInWindowBootstrapsAutolayout
{
    NSWindow *window = [[NSWindow alloc] init];
    NSView *view = [[NSView alloc] init];
    [window.contentView addSubview: view];

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute
        multiplier:1.0 constant:1];
    
    [view addConstraint: heightConstraint];
    
    XCTAssertNotNil([window _layoutEngine]);
}

@end