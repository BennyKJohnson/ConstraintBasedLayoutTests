include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = constraintstest
BUNDLE_NAME = constraintslayouttest

constraintslayouttest_HEADER_FILES = \
	ConstraintsSpyWindow.h
constraintslayouttest_OBJC_FILES = \
	LayoutConstraintTestCase.m
ADDITIONAL_TOOL_LIBS = -lxctest
constraintslayouttest_INCLUDE_DIRS = -I./../tools-xctest

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
