#import <Foundation/Foundation.h>
#import "CSWSimplexSolver.h"

@class NSView;
@class NSLayoutConstraint;

NS_ASSUME_NONNULL_BEGIN

@interface GSAutoLayoutEngine : NSObject

-(void)addConstraint: (NSLayoutConstraint*)constraint;

-(void)addConstraints: (NSArray*)constraints;

-(void)removeConstraint: (NSLayoutConstraint*)constraint;

-(void)removeConstraints: (NSArray*)constraints;

-(void)addInternalConstraintsToView: (NSView*)view;

-(NSRect)alignmentRectForView: (NSView*)view;

-(NSArray*)constraintsForView: (NSView*)view;

-(void)debugSolver;

-(instancetype)initWithSolver: (CSWSimplexSolver*)solver;

@end

NS_ASSUME_NONNULL_END
