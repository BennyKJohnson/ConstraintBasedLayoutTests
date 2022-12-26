#import "CSWSpySimplexSolver.h"
#import "CSWConstraint.h"

@implementation CSWSpySimplexSolver

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.addedConstraints = [NSMutableArray array];
        self.removedConstraints = [NSMutableArray array];
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
    [self.addedConstraints addObject: constraint];
}

@end