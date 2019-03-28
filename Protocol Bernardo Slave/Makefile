############################################
### Position Acquisition Engine Makefile ###
############################################

# This makefiles compile all available sources (cpp) starting fron this directory and
# including child directories recursively.
# All compiled objects are then assembled in a static library inside the `./build`
# folder.

# MARK: The Target

TARGETNAME := pb-slave
BUILDDIR := build/
TARGET := $(BUILDDIR)$(TARGETNAME)

# ###########
# MARK: Setup

CXX := clang++
SRCDIR := .
SRCEXT := cpp
LIBDIR := libs

UNAME_S := $(shell uname -s)

# #########################
# MARK: Find Sources

ifeq ($(OS),Windows_NT)
SOURCES := $(shell tree $(SRCDIR) -type f -name "**.$(SRCEXT)" -not -path "./$(LIBDIR)/*")
else
SOURCES := $(shell find $(SRCDIR) -type f -name "**.$(SRCEXT)" -not -path "./$(LIBDIR)/*")
endif

OBJECTS := $(SOURCES:.$(SRCEXT)=.o)


################
# MARK: - Cross-Plateform Build Settings

# Build Flags
GCCOPTIONS = -g -std=c++11 -Wall -pedantic #-O2 -pipe -fno-common -fno-strict-aliasing

# Include Flags
INCFLAGS = -I../ \
		   -I/usr/local/include/

# Linker Flags
LDFLAGS = -L/usr/local/lib/

# Libraries
LDLIBS = -lPAE \
         -lsioclient \
		 -lboost_system \
		 -lboost_exception \
		 -lNiTE2


# #######################
# OS-Dependant Properties

# ifeq ($(OS),Windows_NT)

# MARK: - OS X Build Settings
ifeq ($(UNAME_S),Darwin)

INCFLAGS += -I/usr/local/include/ni2/ \
			-I/usr/local/include/opencv4/ \
			-I/usr/local/opt/ncurses/include/

LDFLAGS += -L/usr/local/opt/ncurses/lib/ \
		   -L../PositionAcquisitionEngine/build/

LDLIBS += -lopencv_core \
		  -lopencv_highgui \
		  -lopencv_imgproc \
		  -lncursesw \
		  -lOpenNI2


# MARK: - UNIX Build Settings
else

INCFLAGS += `pkg-config opencv --cflags` \
			`pkg-config libopenni2 --cflags` \
			-I/usr/include/eigen3/

LDFLAGS += `pkg-config opencv --cflags` \
		   `pkg-config ncursesw --cflags` \
		   `pkg-config libopenni2 --cflags` \

LDLIBS +=

endif


CXXFLAGS := $(GCCOPTIONS) -I$(LIBDIR) -I. $(INCFLAGS)

# #######################
# MARK: - Build Sequence
#
# The makefile compiles the objects itself using the defaults CXX and CXXFLAGS.
# We only have to take care of the

$(TARGET): linker

$(info )
$(info ========================================)
$(info    $(TARGETNAME) Makefile )
$(info ========================================)
$(info )

# Link Everything
linker: $(OBJECTS)
	@echo "\n  Compiling ok!"; mkdir -p $(BUILDDIR)
	@echo "\n========================================"
	@echo "   LINKING $(TARGETNAME) on $(UNAME_S)"
	@echo "========================================\n"
	@echo " Working... "; $(CXX) $^ -o $(TARGET) $(LDFLAGS) $(LDLIBS)
# 	@echo "  Cleaning objects..."
# 	@$(RM) -r $(OBJECTS)
	@echo "\n========================================"
	@echo "   $(TARGETNAME) successfully compiled!"
	@echo "   Type \"./$(TARGET)\" to launch $(TARGETNAME)"
	@echo "========================================\n"

# Remove objects
clean:
	@echo " Cleaning..."; $(RM) -r $(OBJECTS) $(TARGET)
	@echo " Done!\n"

.PHONY: clean

