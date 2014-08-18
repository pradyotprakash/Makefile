.SUFFIXES: .cpp .hpp
WORKING_DIR = .
EXT = ${WORKING_DIR}/external
EXTINC = ${WORKING_DIR}/external/include/
EXTLIB = ${WORKING_DIR}/external/lib/
EXTSRC = ${WORKING_DIR}/external/src/
SRCDIR = ${WORKING_DIR}/src
OBJDIR = ${WORKING_DIR}/myobjs
CPPFILES := $(wildcard $(SRCDIR)/*.cpp)
HPPFILES := $(wildcard $(EXTSRC)/*.hpp)
OBJS := $(CPPFILES:${SRCDIR}/%.cpp=$(OBJDIR)/%.o)
STATIC_FILES := $(filter-out ./myobjs/main.o , $(OBJS))
GLUI_ROOT=/usr
LIBS = -lBox2D -lglui -lglut -lGLU -lGL
TARGET = cs251_exe_31
CPPFLAGS =-g -O3 -Wall -fno-strict-aliasing -fPIC
CPPFLAGS+=-I $(EXTINC) -I $(GLUI_ROOT)/include
LDFLAGS+=-L $(EXTLIB) -L $(GLUI_ROOT)/lib -L ./mylibs/
BINDIR = ${WORKING_DIR}/mybins
STATIC_LIB = FALSE
PWD = $(shell pwd)
#Programs

.PHONY: all makefolders extract exelib makelib

all: makefolders extract $(BINDIR)/$(TARGET) makelib

makefolders:
	@if [ ! -d $(WORKING_DIR)/myobjs ] || [ ! -d $(WORKING_DIR)/mylibs ] || [ ! -d $(WORKING_DIR)/mybins ] ; then \
		mkdir -p myobjs mylibs mybins ; \
	fi

extract:
	@if [ ! -d $(EXTINC)/Box2D ] || [ ! -f ${EXTLIB}/libBox2D.a ]; then \
		cd $(EXTSRC) ; \
		tar -xzvf Box2D.tgz ; \
		cd Box2D ; \
		mkdir -p build251 ; \
		cd build251 ; \
		cmake ../ ; \
		make ; \
		make install ; \
		cd ../../../../ ; \
	fi
	
$(BINDIR)/$(TARGET): $(OBJS)
	@g++ -o $@ $(LDFLAGS) $(OBJS) $(LIBS)	
	
makelib: makefolders extract $(OBJS) 
	@if [ $(STATIC_LIB) = TRUE ] ; then \
		ar rcs ./mylibs/libCS251.a $(STATIC_FILES) ; \
	else \
		g++ -shared -o ./mylibs/libCS251.so $(STATIC_FILES) ; \
	fi

$(OBJS): $(OBJDIR)/%.o : $(SRCDIR)/%.cpp
	@g++ $(CPPFLAGS) -c $< -o $@
	
exelib: makelib
	@if [ $(STATIC_LIB) = TRUE ] ; then \
		g++ -o mybins/cs251_exelib_31 myobjs/main.o $(LDFLAGS) -L mylibs/ -lCS251 $(LIBS) ; \
	else \
		g++ $(LDFLAGS) -o mybins/cs251_exelib_31 myobjs/main.o -lCS251 $(LIBS) ; \
		export LD_LIBRARY_PATH=$(PWD)/mylibs/ ; \
	fi


distclean: clean
	@rm -rf $(EXTINC)* $(EXTSRC)Box2D $(EXTLIB)*

clean:
	@if [ -d $(WORKING_DIR)/myobjs ] && [ -d $(WORKING_DIR)/mylibs ] && [ -d $(WORKING_DIR)/mybins ] ; then \
		rm -rf myobjs mylibs mybins; \
	fi
