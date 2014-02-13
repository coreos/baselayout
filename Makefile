# baselayout Makefile
# Copyright 2006-2011 Gentoo Foundation
# Copyright 2014 The CoreOS Authors
# Distributed under the terms of the GNU General Public License v2

DESTDIR =
ETC_DIRS = env.d
LIB_DIRS = modprobe.d sysctl.d tmpfiles.d
SHARE_DIRS = baselayout sudoers.d vim

all: baselayout/shadow baselayout/gshadow

baselayout/shadow: baselayout/passwd Makefile
	awk 'BEGIN {FS = ":"} { print $$1 ":*:15887:0:::::" }' <$< >$@

baselayout/gshadow: baselayout/group Makefile
	awk 'BEGIN {FS = ":"} { print $$1 ":*::" $$4 }' <$< >$@

clean:
	rm -f baselayout/shadow baselayout/gshadow

install:
	mkdir -m 0755 -p $(DESTDIR)/etc
	cp -pPR $(ETC_DIRS) $(DESTDIR)/etc
	mkdir -m 0755 -p $(DESTDIR)/usr/lib
	cp -pPR $(LIB_DIRS) $(DESTDIR)/usr/lib
	mkdir -m 0755 -p $(DESTDIR)/usr/share
	cp -pPR $(SHARE_DIRS) $(DESTDIR)/usr/share
	# no secrets in our shadow or sudoers but this is the proper way
	chmod 0640 $(DESTDIR)/usr/share/sudoers.d/*
	chmod 0640 $(DESTDIR)/usr/share/baselayout/*shadow
	# created by systemd's tmpfiles.d/tmp.conf but that is installed later
	install -m 1777 -d $(DESTDIR)/tmp $(DESTDIR)/var/tmp
	# FHS compatibility symlinks stuff
	ln -snf /var/tmp $(DESTDIR)/usr/tmp

.PHONY: all clean install
