#Set this to @ to keep the makefile quiet
SILENCE = @

#---- Outputs ----#
COMPONENT_NAME = Flash

#--- Inputs ----#
PROJECT_HOME_DIR = .

SRC_FILES = Flash.c IOReadWrite.c

TEST_SRC_FILES = AllTests.cpp FlashTest.cpp \
			IOReadWrite_CppUMock.cpp IOReadWrite_CppUMockTest.cpp\

#Add these to TEST_SRC_FILES to see the example run:  

INCLUDE_DIRS =\
  .\
  $(CPPUTEST_HOME)/include/ \
  $(CPPUTEST_HOME)/include/Platforms/Gcc\

CPPUTEST_USE_EXTENSIONS = Y
CPPUTEST_WARNINGFLAGS += -Wall 
CPPUTEST_WARNINGFLAGS += -Werror
CPPUTEST_WARNINGFLAGS += -Wswitch-default
CPPUTEST_WARNINGFLAGS += -Wfatal-errors
CPPUTEST_WARNINGFLAGS +=-Wno-shadow
CPPUTEST_CXXFLAGS +=  -std=c++0x
CPPUTEST_CFLAGS += -std=c99
CPPUTEST_CFLAGS +=  -Wno-missing-prototypes -Wno-unused-parameter
CPPUTEST_CXXFLAGS += $(CPPUTEST_PLATFORM_CXXFLAGS)
CPPUTEST_CXXFLAGS += -Wno-shadow

include $(CPPUTEST_HOME)/build/MakefileWorker.mk

