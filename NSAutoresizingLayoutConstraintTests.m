#import <XCTest/XCTest.h>
#import <AppKit/NSAutoresizingMaskLayoutConstraint.h>

@interface NSAutoresizingLayoutConstraintTests : XCTestCase

@end

@implementation NSAutoresizingLayoutConstraintTests
{
    NSView *superView;
    NSView *subView;
}

NSUInteger minXAttribute = 32;
NSUInteger minYAttribute = 33;
NSUInteger maxXAttribute = 36;
NSUInteger maxYAttribute = 37;

- (void)setUp {
    superView = [[NSView alloc] init];
    subView = [[NSView alloc] init];
}

- (void)testConstraintsWithAutoresizingMaskNotSizableReturnsNoConstraints
{
    NSRect frame = NSMakeRect(0, 0, 0, 0);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewNotSizable subitem:subView frame:frame superitem:superView bounds:NSMakeRect(0, 0, 0, 0)];
    
    XCTAssertEqual([constraints count], 0);
}

-(void)assertMinXConstraintAndConstant:(NSLayoutConstraint*)constraint constant:(CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], minXAttribute);
    XCTAssertEqual([constraint secondAttribute], NSLayoutAttributeNotAnAttribute);
    XCTAssertEqual([constraint firstItem], subView);
    XCTAssertEqual([constraint secondItem], nil);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertMinXMarginConstraintAndConstant:(NSLayoutConstraint*)constraint constant:(CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([constraint secondAttribute], maxXAttribute);
    XCTAssertEqual([constraint firstItem], superView);
    XCTAssertEqual([constraint secondItem], subView);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertMinYConstraintAndConstant:(NSLayoutConstraint*)constraint constant:(CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], minYAttribute);
    XCTAssertEqual([constraint secondAttribute], NSLayoutAttributeNotAnAttribute);
    XCTAssertEqual([constraint firstItem], subView);
    XCTAssertEqual([constraint secondItem], nil);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertMinYMarginConstraintAndConstant:(NSLayoutConstraint*)constraint constant:(CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([constraint secondAttribute], maxYAttribute);
    XCTAssertEqual([constraint firstItem], superView);
    XCTAssertEqual([constraint secondItem], subView);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertFixedWidthConstraintAndConstant: (NSLayoutConstraint*)constraint constant: (CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([constraint secondAttribute], NSLayoutAttributeNotAnAttribute);
    XCTAssertEqual([constraint firstItem], subView);
    XCTAssertEqual([constraint secondItem], nil);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertFixedHeightConstraintAndConstant: (NSLayoutConstraint*)constraint constant: (CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([constraint secondAttribute], NSLayoutAttributeNotAnAttribute);
    XCTAssertEqual([constraint firstItem], subView);
    XCTAssertEqual([constraint secondItem], nil);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertFlexibleWidthConstraint: (NSLayoutConstraint*)constraint constant: (CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([constraint secondAttribute], maxXAttribute);
    XCTAssertEqual([constraint firstItem], superView);
    XCTAssertEqual([constraint secondItem], subView);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertFlexibleHeightConstraint: (NSLayoutConstraint*)constraint constant: (CGFloat)constant
{
    XCTAssertEqual([constraint firstAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([constraint secondAttribute], maxYAttribute);
    XCTAssertEqual([constraint firstItem], superView);
    XCTAssertEqual([constraint secondItem], subView);
    XCTAssertEqual([constraint constant], constant);
}

-(void)assertSharedAttributesOnConstraints: (NSArray*)constraints {
    for (NSLayoutConstraint *constriant in constraints) {
        XCTAssertEqual([constriant priority], 1000);
        XCTAssertEqual([constriant multiplier], 1);
    }
}

-(void)testConstraintsWithNSViewWidthSizableAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 20, 100, 201);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewWidthSizable subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 3, 4)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];

    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFlexibleWidthConstraint:widthConstraint constant:-106];
    [self assertMinYConstraintAndConstant: minYConstraint constant:18];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:201];
}

-(void)testConstraintsWithNSViewHeightSizableAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewHeightSizable subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 3, 4)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYConstraintAndConstant: minYConstraint constant:23];
    [self assertFlexibleHeightConstraint:heightConstraint constant:-219];
}

-(void)testConstraintsWithNSViewMinXMarginAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinXMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 3, 4)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    XCTAssertEqual([minXConstraint firstAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([minXConstraint secondAttribute], maxXAttribute);
    XCTAssertEqual([minXConstraint firstItem], superView);
    XCTAssertEqual([minXConstraint secondItem], subView);
    XCTAssertEqual([minXConstraint constant], -106);
    
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYConstraintAndConstant: minYConstraint constant:23];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithNSViewMaxXMarginAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMaxXMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 3, 4)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYConstraintAndConstant: minYConstraint constant:23];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithNSViewMinYMarginAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinYMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 3, 4)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    
    XCTAssertEqual([minYConstraint firstAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([minYConstraint secondAttribute], maxYAttribute);
    XCTAssertEqual([minYConstraint firstItem], superView);
    XCTAssertEqual([minYConstraint secondItem], subView);
    XCTAssertEqual([minYConstraint constant], -219);
    
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithNSViewMaxYMarginAutoresizingMask
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMaxYMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 4, 8)];
    
    XCTAssertEqual([constraints count], 4);
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYConstraintAndConstant:minYConstraint constant:23];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithBothFlexibleWidthAndHeightAutoresizingOptions
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 4, 8)];
    
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:9];
    [self assertFlexibleWidthConstraint:widthConstraint constant:-105];
    [self assertMinYConstraintAndConstant:minYConstraint constant:23];
    [self assertFlexibleHeightConstraint:heightConstraint constant:-215];
}

-(void)testConstraintsWithBothMinXAndMinYMarginAutoresizingOptions
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 4, 8)];
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
        
    [self assertMinXMarginConstraintAndConstant:minXConstraint constant:-105];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYMarginConstraintAndConstant:minYConstraint constant:-215];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithBothMaxXAndMaxYMarginAutoresizingOptions
{
    NSRect frame = NSMakeRect(10, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(1, 2, 4, 8)];
    
    [self assertSharedAttributesOnConstraints:constraints];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
        
    [self assertMinXConstraintAndConstant: minXConstraint constant:9];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertMinYConstraintAndConstant:minYConstraint constant:23];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithBothMinXAndMaxXMarginsAutoresizingOptions
{
    NSRect frame = NSMakeRect(20, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(0, 10, 2, 0)];
    
    NSLayoutConstraint *widthConstraint = constraints[0];
    NSLayoutConstraint *minXConstraint = constraints[1];
    NSLayoutConstraint *minYConstraint = constraints[2];
    NSLayoutConstraint *heightConstraint = constraints[3];
    
    XCTAssertEqual([widthConstraint firstAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([widthConstraint secondAttribute], NSLayoutAttributeNotAnAttribute);
    XCTAssertEqual([widthConstraint firstItem], subView);
    XCTAssertEqual([widthConstraint secondItem], nil);
    XCTAssertEqual([widthConstraint constant], 100);
    
    XCTAssertEqual([minXConstraint firstAttribute], minXAttribute);
    XCTAssertEqual([minXConstraint secondAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([minXConstraint firstItem], subView);
    XCTAssertEqual([minXConstraint secondItem], superView);
    XCTAssertEqualWithAccuracy([minXConstraint constant], 20.4081632653, 0.00000000001);
    XCTAssertEqualWithAccuracy([minXConstraint multiplier], -0.204081, 0.000001);
        
    [self assertMinYConstraintAndConstant:minYConstraint constant:15];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
}

-(void)testConstraintsWithBothMinYAndMaxYMarginsAutoresizingOptions
{
    NSRect frame = NSMakeRect(20, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinYMargin | NSViewMaxYMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(10, 20, 40, 80)];
    
    NSLayoutConstraint *minXConstraint = constraints[0];
    NSLayoutConstraint *widthConstraint = constraints[1];
    NSLayoutConstraint *heightConstraint = constraints[2];
    NSLayoutConstraint *minYConstraint = constraints[3];
    
    [self assertMinXConstraintAndConstant:minXConstraint constant:10];
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
    
    XCTAssertEqual([minYConstraint firstAttribute], minYAttribute);
    XCTAssertEqual([minYConstraint secondAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([minYConstraint firstItem], subView);
    XCTAssertEqual([minYConstraint secondItem], superView);
    XCTAssertEqualWithAccuracy([minYConstraint constant], 8.33333333333, 0.00000000001);
    XCTAssertEqualWithAccuracy([minYConstraint multiplier], -0.0416666679084, 0.000001);
}

-(void)testConstraintsWithAllMarginsAutoresizingOptions
{
    NSRect frame = NSMakeRect(20, 25, 100, 200);
    NSArray *constraints = [NSAutoresizingMaskLayoutConstraint constraintsWithAutoresizingMask:NSViewMinYMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMaxXMargin subitem:subView frame:frame superitem:superView bounds:NSMakeRect(10, 20, 40, 80)];
        
    NSLayoutConstraint *widthConstraint = constraints[0];
    NSLayoutConstraint *minXConstraint = constraints[1];
    NSLayoutConstraint *heightConstraint = constraints[2];
    NSLayoutConstraint *minYConstraint = constraints[3];
    
    [self assertFixedWidthConstraintAndConstant:widthConstraint constant:100];
    
    XCTAssertEqual([minXConstraint firstAttribute], minXAttribute);
    XCTAssertEqual([minXConstraint secondAttribute], NSLayoutAttributeWidth);
    XCTAssertEqual([minXConstraint firstItem], subView);
    XCTAssertEqual([minXConstraint secondItem], superView);
    XCTAssertEqualWithAccuracy([minXConstraint constant], 16.6666666667, 0.00000001);
    XCTAssertEqualWithAccuracy([minXConstraint multiplier], -0.166666671634, 0.000001);
    
    [self assertFixedHeightConstraintAndConstant:heightConstraint constant:200];
    
    XCTAssertEqual([minYConstraint firstAttribute], minYAttribute);
    XCTAssertEqual([minYConstraint secondAttribute], NSLayoutAttributeHeight);
    XCTAssertEqual([minYConstraint firstItem], subView);
    XCTAssertEqual([minYConstraint secondItem], superView);
    XCTAssertEqualWithAccuracy([minYConstraint constant], 8.33333333333, 0.00000000001);
    XCTAssertEqualWithAccuracy([minYConstraint multiplier], -0.0416666679084, 0.000001);
}

@end
