#import "CSWSpySimplexSolver.h"
#import "CSWConstraint.h"

@implementation CSWSpySimplexSolver

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.constraints = [NSMutableArray array];
        self.removedConstraints = [NSMutableArray array];
        self.suggestEditVariableCallCount = 0;
    }
    return self;
}

-(void)removeConstraint: (CSWConstraint*)constraint
{
    [super removeConstraint: constraint];
    [self.removedConstraints addObject: constraint];
}

-(void)addConstraint: (CSWConstraint*)constraint
{
    [super addConstraint: constraint];
    [self.constraints addObject: constraint];
}

-(void)suggestEditVariable: (CSWVariable*)variable equals: (CSWDouble)value
{
    self.suggestEditVariableCallCount++;
    [super suggestEditVariable: variable equals: value];
}

@end