#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import "ConstraintsSpyWindow.h"
#import "ConstraintLayoutSpyView.h"
#import "GSAutoLayoutEngine.h"
#import "LayoutSpyView.h"

@interface LayoutConstraintTestCase : XCTestCase
{
}
@end

@implementation LayoutConstraintTestCase

-(void)setUp
{
    // Using window requires NSApplication
    NSApplication *app = [NSApplication sharedApplication];
}

-(void)testLayoutIfNeededCallsUpdateConstraintsIfNeededWithSubclassView
{
    ConstraintsSpyWindow *window = [[ConstraintsSpyWindow alloc] init];
    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    [window setContentView:windowView];

    [window layoutIfNeeded];
    XCTAssertTrue(window.updateConstraintsIfNeededCalled);
}

-(void)testUpdateConstraintsIfNeededInvokesUpdateConstraintsFromLeafViewsToRootView
{
    NSWindow *window = [[NSWindow alloc] init];
    
    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];

    [windowView addSubview:subView];
    [window setContentView:windowView];
    [window updateConstraintsIfNeeded];
    
    XCTAssertTrue(subView.updateConstraintsCalled);
    XCTAssertTrue(windowView.updateConstraintsCalled);
}

-(void)testUpdateConstraintsIfNeededOnlyCallsUpdateConstraintsOnViewsWithNeedsUpdateConstraints
{
    NSWindow *window = [[NSWindow alloc] init];

    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];
    [windowView addSubview:subView];

    ConstraintLayoutSpyView *subSubView = [[ConstraintLayoutSpyView alloc] init];
    [subView addSubview:subSubView];

    [window setContentView:windowView];
    [window updateConstraintsIfNeeded];
    [subView setNeedsUpdateConstraints:YES];
    [window updateConstraintsIfNeeded];
    
    XCTAssertEqual(subView.updateConstraintsCalledCount, 2);
    XCTAssertEqual(subSubView.updateConstraintsCalledCount, 1);
    XCTAssertEqual(windowView.updateConstraintsCalledCount, 1);
}

-(void)testNeedsUpdateConstraintsDefaultsToTrue
{
    NSView *view = [[NSView alloc] init];
    XCTAssertTrue(view.needsUpdateConstraints);
}

-(void)testUpdateConstraintsSetsViewNeedsUpdateConstraintsToFalse
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    XCTAssertTrue(windowView.needsUpdateConstraints);
    [window setContentView:windowView];
    [window updateConstraintsIfNeeded];
    XCTAssertFalse(windowView.needsUpdateConstraints);
}

-(void)testSettingNeedsUpdateConstraintsToFalseDoesNothing
{
    NSView *view = [[NSView alloc] init];
    [view setNeedsUpdateConstraints:NO];
    XCTAssertTrue(view.needsUpdateConstraints);
}

-(void)testSetNeedsUpdateConstraintsUpdatesWhenPreviouslyFalse
{
    NSWindow *window = [[NSWindow alloc] init];
    NSView *windowView = [[NSView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];
    [windowView addSubview:subView];

    [window setContentView:windowView];
    [window updateConstraintsIfNeeded];
    XCTAssertFalse(subView.needsUpdateConstraints);
    [subView setNeedsUpdateConstraints:YES];
    XCTAssertTrue(subView.needsUpdateConstraints);
}

-(void)testUpdateConstraintsForSubTreeIfNeededInvokesUpdateConstraintsOfSubtree
{
    NSWindow *window = [[NSWindow alloc] init];
    
    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];
    [windowView addSubview:subView];
    
    ConstraintLayoutSpyView *subSubView = [[ConstraintLayoutSpyView alloc] init];
    [subView addSubview:subSubView];
    
    [window setContentView:windowView];
    [subView updateConstraintsForSubtreeIfNeeded];
    
    XCTAssertTrue(subSubView.updateConstraintsCalled);
    XCTAssertTrue(subView.updateConstraintsCalled);
    XCTAssertFalse(windowView.updateConstraintsCalled);
}

-(void)testUpdateConstraintsForSubTreeSetsNeedsUpdateConstraintsToFalse
{
    NSWindow *window = [[NSWindow alloc] init];
    
    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];
    [windowView addSubview:subView];
    
    ConstraintLayoutSpyView *subSubView = [[ConstraintLayoutSpyView alloc] init];
    [subView addSubview:subSubView];
    
    [window setContentView:windowView];
    [subView updateConstraintsForSubtreeIfNeeded];
    
    XCTAssertFalse(subSubView.needsUpdateConstraints);
    XCTAssertFalse(subView.needsUpdateConstraints);
    // Window view should be unchanged by call
    XCTAssertTrue(windowView.needsUpdateConstraints);
}

-(void)testUpdateConstraintsForSubTreeSetsOnlyCallsUpdateConstraintsOnViewsWithNeedsUpdateConstraints
{
    NSWindow *window = [[NSWindow alloc] init];

    ConstraintLayoutSpyView *windowView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subView = [[ConstraintLayoutSpyView alloc] init];
    [windowView addSubview:subView];

    ConstraintLayoutSpyView *subSubView = [[ConstraintLayoutSpyView alloc] init];
    [subView addSubview:subSubView];

    [window setContentView:windowView];
    [subView updateConstraintsForSubtreeIfNeeded];
    [subSubView setNeedsUpdateConstraints:YES];
    [subView updateConstraintsForSubtreeIfNeeded];
    
    XCTAssertEqual(subView.updateConstraintsCalledCount, 1);
    XCTAssertEqual(subSubView.updateConstraintsCalledCount, 2);
}

-(void)testViewNeedsLayoutDefaultsToTrue
{
    NSView *view = [[NSView alloc] init];
    XCTAssertTrue(view.needsLayout);
}

-(void)testSettingNeedLayoutsToFalseDoesNothing
{
    NSView *view = [[NSView alloc] init];
    [view setNeedsLayout:NO];
    XCTAssertTrue(view.needsLayout);
}

-(void)testLayoutSubTreeIfNeededSetsNeedsLayoutToFalse
{
    NSWindow *window = [[NSWindow alloc] init];
    NSView *view = [[NSView alloc] init];
    NSView *subView = [[NSView alloc] init];
    [view addSubview:subView];
    [window setContentView:view];
    [view layoutSubtreeIfNeeded];

    XCTAssertFalse(view.needsLayout);
    XCTAssertFalse(subView.needsLayout);
}

-(void)testLayoutSubTreeIfNeededCallsViewLayoutOnlyWhenRequired
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *layoutSpyView = [[ConstraintLayoutSpyView alloc] init];
    [window setContentView:layoutSpyView];
    [layoutSpyView layoutSubtreeIfNeeded];
    XCTAssertFalse(layoutSpyView.needsLayout);
    [layoutSpyView layoutSubtreeIfNeeded];
    XCTAssertEqual(layoutSpyView.layoutCalledCount, 1);
}

-(void)testLayoutSubTreeIfNeededCallsViewLayoutWhenNeedsLayoutIsTrue
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *layoutSpyView = [[ConstraintLayoutSpyView alloc] init];
    [window setContentView:layoutSpyView];
    [layoutSpyView layoutSubtreeIfNeeded];
    [layoutSpyView setNeedsLayout:YES];
    [layoutSpyView layoutSubtreeIfNeeded];
    XCTAssertEqual(layoutSpyView.layoutCalledCount, 2);
}

-(void)testLayoutSubTreeIfNeededInvokesLayoutFromRootViewToLeafViews
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *windowSpyView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subViewSpyView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subSubViewSpyView = [[ConstraintLayoutSpyView alloc] init];

    [windowSpyView addSubview:subViewSpyView];
    [subViewSpyView addSubview:subSubViewSpyView];
    
    [window setContentView:windowSpyView];
    [windowSpyView layoutSubtreeIfNeeded];
    
    XCTAssertTrue(subViewSpyView.superViewWasLayedOut);
    XCTAssertTrue(subSubViewSpyView.superViewWasLayedOut);
}

-(void)testLayoutSubTreeIfNeededCallsUpdateConstraintsOnlyWhenRequired
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *layoutSpyView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subLayoutSpyView = [[ConstraintLayoutSpyView alloc] init];

    [layoutSpyView addSubview:subLayoutSpyView];
    [window setContentView:layoutSpyView];

    [layoutSpyView layoutSubtreeIfNeeded];
    [layoutSpyView layoutSubtreeIfNeeded];
    // Apple's documentation states that updateConstraintsForSubtreeIfNeeded is called however I was unable to write a test to verify this claim
    XCTAssertEqual(layoutSpyView.updateConstraintsCalledCount, 1);
    XCTAssertEqual(subLayoutSpyView.updateConstraintsCalledCount, 1);
}

-(void)testLayoutIfNeededCallsLayoutOnViews
{
    NSWindow *window = [[NSWindow alloc] init];
    ConstraintLayoutSpyView *layoutSpyView = [[ConstraintLayoutSpyView alloc] init];
    ConstraintLayoutSpyView *subViewSpyView = [[ConstraintLayoutSpyView alloc] init];
    [layoutSpyView addSubview:subViewSpyView];
    
    [window setContentView:layoutSpyView];
    [window layoutIfNeeded];
    [window layoutIfNeeded];
    
    XCTAssertEqual(layoutSpyView.updateConstraintsCalledCount, 1);
    XCTAssertEqual(subViewSpyView.updateConstraintsCalledCount, 1);

    XCTAssertEqual(layoutSpyView.layoutCalledCount, 1);
    XCTAssertEqual(subViewSpyView.layoutCalledCount, 1);
}

// -(void)testLayoutEngineDidChangeAlignmentRectSetsNeedLayoutOfSuperview
// {
//     NSView *rootView = [self createViewWithLayoutEngine:NSMakeSize(400, 400)];
//     LayoutSpyView *subView = [[LayoutSpyView alloc] init];
//     [rootView addSubview:subView];
//     NSLog(@"After adding sub view: %@", subView.superview);

//     [rootView layoutSubtreeIfNeeded];
//     XCTAssertFalse(rootView.needsLayout);

//     [self centerSubView:subView inSuperView:rootView];

//     XCTAssertTrue(rootView.needsLayout);
// }

@end