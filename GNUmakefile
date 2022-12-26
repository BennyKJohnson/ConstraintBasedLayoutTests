include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = constraintstest
BUNDLE_NAME = constraintslayouttest

constraintslayouttest_HEADER_FILES = \
	ConstraintsSpyWindow.h LayoutSpyView.h \
	GSAutoLayoutEngine.h \
	CustomBaselineView.h \
	CustomInstrinctContentSizeView.h \
	CSWSpySimplexSolver.h
constraintslayouttest_OBJC_FILES = \
	TriggeringAutoLayoutTests.m \
	NSAutoresizingLayoutConstraintTests.m \
	ManagingViewConstraintsTests.m \
	AutoLayoutCompatabilityTests.m \
	GSAutoLayoutEngineTests.m \
	LayoutSpyView.m \
	CSWSpySimplexSolver.m
ADDITIONAL_TOOL_LIBS = -lxctest
constraintslayouttest_INCLUDE_DIRS = -I./../tools-xctest -I/home/benjamin/CassowaryKit/cassowary
constraintslayouttest_LDFLAGS = --verbose
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
