#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import "ConstraintsSpyWindow.h"
#import "ConstraintLayoutSpyView.h"
#import "LayoutSpyView.h"
#import "CustomInstrinctContentSizeView.h"

@interface TriggeringAutoLayoutTests : XCTestCase
{
}
@end

@implementation TriggeringAutoLayoutTests

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

-(void)testInvalidateIntrinsicContentSizeUpdatesConstraintsOnTheNextLayoutPass
{
    NSWindow *window = [[NSWindow alloc] init];
    NSView *view = [[NSView alloc] init];
    CustomInstrinctContentSizeView *subView = [CustomInstrinctContentSizeView withInstrinctContentSize: NSMakeSize(20,20)];
    [view addSubview:subView];
    [window setContentView:view];

    // Create constraints to pin to bottom
    NSLayoutConstraint *pinSubViewToBottom = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual
        toItem: view
        attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *pinSubViewToLeft = [NSLayoutConstraint
        constraintWithItem:subView attribute:NSLayoutAttributeLeft
        relatedBy:NSLayoutRelationEqual
        toItem: view
        attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    [view addConstraints: @[pinSubViewToBottom, pinSubViewToLeft]];
    [view layoutSubtreeIfNeeded];
    NSLog(@"frame: %@", NSStringFromRect([subView frame]));
    XCTAssertTrue(NSEqualRects([subView frame], NSMakeRect(0,0, 20, 20)));

    subView._intrinsicContentSize = NSMakeSize(40,40);
    [subView invalidateIntrinsicContentSize];
    [view layoutSubtreeIfNeeded];
    XCTAssertTrue(NSEqualRects([subView frame], NSMakeRect(0,0, 40, 40)));
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

/*
* When the user resizes the window, the width and height constraints for the window view are updated to reflect the new size
* when these constraints are updated the alignment rects of the window's views are recalculated
*/
- (void)testUpdatesLayoutAfterWindowResize
{
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0,0, 400, 400)
        styleMask: NSTitledWindowMask
        backing: NSBackingStoreBuffered
        defer: NO];
    NSView *windowView = [window contentView];
    [windowView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    NSView *rightBottomPinView = [[NSView alloc] init];
    [windowView addSubview: rightBottomPinView];

    rightBottomPinView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:rightBottomPinView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:windowView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:rightBottomPinView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:windowView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:rightBottomPinView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:rightBottomPinView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [windowView addConstraints:@[rightConstraint, bottomConstraint, widthConstraint, heightConstraint]];

    [window layoutIfNeeded];
 
    XCTAssertTrue(NSEqualRects([rightBottomPinView frame], NSMakeRect(300,0, 100, 100)));

    // Simulate window resize event
    NSEvent *windowResizeEvent = [NSEvent
         otherEventWithType: NSAppKitDefined
                       location: NSMakePoint(0,0)
                  modifierFlags: 0
                      timestamp: 0
                   windowNumber: window.windowNumber
                        context: nil
                        subtype: GSAppKitWindowResized
                          data1: 300
                          data2: 400];

    [window sendEvent: windowResizeEvent];
    [window layoutIfNeeded];

    XCTAssertTrue(NSEqualRects([rightBottomPinView frame], NSMakeRect(200,0, 100, 100))); 
}

@end