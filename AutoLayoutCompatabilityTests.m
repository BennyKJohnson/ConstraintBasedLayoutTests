#import <XCTest/XCTest.h>
#import <AppKit/AppKit.h>
#import <AppKit/NSAutoresizingMaskLayoutConstraint.h>
#import "GSAutoLayoutEngine.h"

@interface AutoLayoutCompatabilityTests : XCTestCase

@end

@implementation AutoLayoutCompatabilityTests

- (void)setUp {
    [NSApplication sharedApplication];
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
    NSWindow *window = [[NSWindow alloc] init];
    [window setContentView: superview];
    [superview addSubview: view];

    [view setAutoresizingMask:NSViewWidthSizable];
    [view updateConstraints];

    NSUInteger superViewConstraintCount = [[superview constraints] count];
    XCTAssertEqual([[view constraints] count], 3);
    XCTAssertEqual(superViewConstraintCount, 1);
}

@end