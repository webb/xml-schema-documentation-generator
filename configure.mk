
# Copyright 2015-2017 Georgia Tech Research Corporation (GTRC). All rights reserved.

this_makefile := ${lastword ${MAKEFILE_LIST}}

autoreconf = autoreconf
find = find
glibtoolize = glibtoolize
sed = sed

.PHONY: default #Default target is "all".
default: all

#HELP:Targets include:

.PHONY: help #  Print this help
help:
	@ ${sed} -e '/^\.PHONY:/s/^\.PHONY: *\([^ #]*\) *\#\( *\)\([^ ].*\)/\2\1: \3/p;/^[^#]*#HELP:/s/[^#]*#HELP:\(.*\)/\1/p;d' ${this_makefile}

.PHONY: all #  build everything so that ./configure will work
all: install-sh configure

.PHONY: clean #  Remove everything built by make
clean:
	${RM} configure install-sh ${wildcard *~ .*~} 
	${RM} -r autom4te.cache
	- if [[ -f Makefile ]]; then make distclean; fi

configure: configure.ac
	${autoreconf} --install --verbose

install-sh:
	${glibtoolize} -icf
	${RM} ltmain.sh config.guess config.sub
