//
//  LayoutSpyView.h
//  GSAutoLayoutEngineTests
//
//  Created by Benjamin Johnson on 10/10/22.
//

#ifndef LayoutSpyView_h
#define LayoutSpyView_h

#import <AppKit/AppKit.h>

@interface LayoutSpyView: NSView

@property (nonatomic) NSUInteger layoutEngineDidChangeAlignmentRectCallCount;

@end

#endif /* LayoutSpyView_h */
