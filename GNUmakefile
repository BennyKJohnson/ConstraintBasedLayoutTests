include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = constraintstest
BUNDLE_NAME = constraintslayouttest

constraintslayouttest_HEADER_FILES = \
	ConstraintsSpyWindow.h LayoutSpyView.h \
	GSAutoLayoutEngine.h
constraintslayouttest_OBJC_FILES = \
	LayoutConstraintTestCase.m \
	NSAutoresizingLayoutConstraintTests.m \
	NSLayoutConstraintTests.m
ADDITIONAL_TOOL_LIBS = -lxctest
constraintslayouttest_INCLUDE_DIRS = -I./../tools-xctest
constraintslayouttest_LDFLAGS = --verbose
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
