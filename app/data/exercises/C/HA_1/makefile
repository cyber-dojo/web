#Set this to @ to keep the makefile quiet
SILENCE = @

#---- Outputs ----#
COMPONENT_NAME = HomeAutomation

#--- Inputs ----#
PROJECT_HOME_DIR = .

SRC_FILES = \
      LightScheduler.c \
      # M42LightController.c

TEST_SRC_FILES = \
      AllTests.cpp\
      FakeTimeServiceTest.cpp\
      FakeTimeService.c\
      LightControllerSpy.c\
      LightControllerSpyTest.cpp\
      LightSchedulerTest.cpp\

INCLUDE_DIRS =\
  .\
  $(CPPUTEST_HOME)/include/ \
  $(CPPUTEST_HOME)/include/Platforms/Gcc\

CPPUTEST_WARNINGFLAGS += -Wall
CPPUTEST_WARNINGFLAGS += -Werror
CPPUTEST_WARNINGFLAGS += -Wswitch-default
CPPUTEST_WARNINGFLAGS += -Wfatal-errors
CPPUTEST_CXXFLAGS += -std=c++11
CPPUTEST_CXXFLAGS += $(CPPUTEST_PLATFORM_CXXFLAGS)
CPPUTEST_CFLAGS += -std=c99 
CPPUTEST_CFLAGS += -Wno-shadow
CPPUTEST_CFLAGS += -Wno-unused-parameter

include $(CPPUTEST_HOME)/build/MakefileWorker.mk
