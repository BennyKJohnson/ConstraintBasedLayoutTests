#import <AppKit/AppKit.h>
#import "CSWSimplexSolver.h"

#ifndef CSWSpySimplexSolver_h
#define CSWSpySimplexSolver_h

@interface CSWSpySimplexSolver: CSWSimplexSolver

@property (nonatomic, strong) NSMutableArray *addedConstraints;

@property (nonatomic, strong) NSMutableArray *removedConstraints;

@property (nonatomic) NSInteger suggestEditVariableCallCount;

@end

#endif /* CSWSpySimplexSolver_h */