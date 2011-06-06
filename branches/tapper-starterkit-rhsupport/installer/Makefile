#########################################################
#
# Tapper - Test infrastructure
# ----------------------------
#
# More information about Tapper:
#
#  - https://github.com/amd/Tapper-Doc/
#  - http://search.cpan.org/~amd/Tapper-Doc/
#
#########################################################
#
# Initial setup of a Tapper central control machine:
#
#  - chroot for installer to be booted over nfs
#
#  - chroot and image file for baseimage
#    to be installed on testmachines
#
#  - a client package with Tapper toolchain
#    to be installed on testmachines
#
#  - local setup for central Tapper host
#      . databases
#      . nfs exports
#      . tftpserver
#      . Tapper daemons
#      . initial Tapper config
#      . Web frontend on Apache
#      . initial example test report
# 
#########################################################

TMP=/tmp

DATATAPPER      = /data/tapper
# meta-reports
METAREPORTSDIR  = $(DATATAPPER)/live/metareports
# intermediate output
OUTPUTDIR       = $(DATATAPPER)/live/output
# OS images
IMAGESDIR       = $(DATATAPPER)/live/repository/images
# packages
PACKAGESDIR     = $(DATATAPPER)/live/repository/packages
# Tapper clientlib
TAPPERUTILSDIR  = $(DATATAPPER)/live/repository/packages/tapperutils
# test programs
TESTPROGRAMDIR  = $(DATATAPPER)/live/testprogram
# auto-generated configs
CONFIGSDIR      = $(DATATAPPER)/live/configs
# complete use-case specfiles
USECASEDIR      = $(CONFIGSDIR)/use_cases
# grub configs via TFTP
TFTPBOOTDIR     = $(DATATAPPER)/live/configs/tftpboot
# sync'ing interdependent tests
SYNCDIR         = $(DATATAPPER)/live/sync
# network bootable OS image
NFSROOTDIR      = $(DATATAPPER)/live/nfsroot

DEBIANMIRROR ?= http://ftp.de.debian.org/debian/
#DEBIANMIRROR=http://alzey/debian/

# installer NFS root
# 64bit always
INSTALLERCHROOT=/mnt/chroot/squeeze-tapper-nfsroot-for-installer
INSTALLERCHROOTPREPARE=prepare-installer-nfsroot-in-chroot

# baseimage
# 64bit
BASEIMAGE64FILE=$(IMAGESDIR)/debian_base64.tgz
BASEIMAGE64CHROOT=/mnt/chroot/squeeze-tapper-nfsroot-for-baseimage64
BASEIMAGE64CHROOTPREPARE=prepare-baseimage64-in-chroot
# 32bit
BASEIMAGE32=$(IMAGESDIR)/debian_base32.tgz
BASEIMAGE32CHROOT=/mnt/chroot/squeeze-tapper-nfsroot-for-baseimage32
BASEIMAGE32CHROOTPREPARE=prepare-baseimage32-in-chroot

# client package
# 64bit
CLIENTPKG64FILE=$(TAPPERUTILSDIR)/opt-tapper64.tar.gz
CLIENTPKG64CHROOT=/mnt/chroot/squeeze-tapper-clientpkg64
CLIENTPKG64CHROOTPREPARE=prepare-clientpkg64-in-chroot
# 32bit
CLIENTPKG32FILE=$(TAPPERUTILSDIR)/opt-tapper32.tar.gz
CLIENTPKG32CHROOT=/mnt/chroot/squeeze-tapper-clientpkg32
CLIENTPKG32CHROOTPREPARE=prepare-clientpkg32-in-chroot

### initial machine names
TAPPER_SERVER?=tapper
TESTMACHINE1=johnconnor
TESTMACHINE2=sarahconnor
TESTMACHINE3=bullock

### Perl setup
### if version changed, also change it in the *CHROOTPREPARE scripts
PERLVERSION=5.12.3
DISTROPREFS=http://cpansearch.perl.org/src/ANDK/CPAN-1.9600/distroprefs/
DISTROPREFSDIR=/root/.cpan/prefs
PERLBIN=/opt/tapper/perl/perls/current/bin
CPAN=$(PERLBIN)/cpan
PERL=$(PERLBIN)/perl

# Debian automatic install/uninstall
APTGETOPTIONS=-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --yes
APTGETREMOVE=remove --purge
APTGETCLEANUP=autoremove
APTGET=DEBIAN_FRONTEND=noninteractive; export DEBIAN_FRONTEND ; apt-get $(APTGETOPTIONS)
# Debian packages to remove on cleanup
APTREMOVEPKG := expect-dev \
				expect \
				libssl-dev \
				mysql-server \
				libmysqlclient-dev \
				libsqlite3-0 \
				sqlite3 \
				libxml2-dev \
				libxml2 \
				libexpat1-dev \
				libexpat1 \
				libapache2-mod-fcgid \
				apache2 \
				atftpd

# Redhat automatic install/uninstall
YUMOPTIONS=--assumeyes --quiet --errorlevel=0
YUMREMOVE=remove
YUMCLEANUP=clean all
YUM=yum $(YUMOPTIONS)
# Redhat packages to remove on cleanup
YUMREMOVEPKG := expect-devel \
				expect \
				openssl-devel \
				mysql-server \
				mysql-devel \
				libsqlite3x \
				sqlite \
				libxml2-devel \
				libxml2 \
				expat-devel \
				expat \
				mod_fcgid \
				httpd \
				tftp-server

# Determine whether the system is Redhat or Debian based and set the
# appropriate PKGMRG interface and the corresponding packages to install
OS := $(shell uname -o)
ifeq ($(OS),GNU/Linux)
	# Check if distribution is Redhat based 
	ifeq ($(findstring redhat-release,$(wildcard /etc/*)),redhat-release)
		PKGMGR=$(YUM)
		REMOVE=$(YUMREMOVE)
		CLEANUP=$(YUMCLEANUP)
		REMOVEPKG=$(YUMREMOVEPKG)
	# Check if distribution is Debian based 
	else ifeq ($(findstring debian_version,$(wildcard /etc/*)),debian_version)
		PKGMGR=$(APTGET)
		REMOVE=$(APTGETREMOVE)
		CLEANUP=$(APTGETCLEANUP)
		REMOVEPKG=$(APTREMOVEPKG)
	else
		#TODO (not priority) Implement support for other distros
	endif
else
	#TODO (not a priority) support other operating systems 
endif
### starter kit
STARTERKITBASENAME=tapper-starterkit
STARTERKIT=$(STARTERKITBASENAME).tgz
STARTERKITURL=http://amd64.org/pub/tapper/$(STARTERKIT)
STARTERKITDIR=$(TMP)/$(STARTERKITBASENAME)

### intermediate build files, not the final results
CLEANFILES = $(TMP)/$(STARTERKIT) \
             $(STARTERKITDIR) \
             $(DISTROPREFSDIR)

NFSROOTCLEANFILES = $(INSTALLERCHROOT) \
                    $(BASEIMAGE64CHROOT) \
                    $(CLIENTPKG64CHROOT)

LOCALCLEANFILES=$(TMP)/$(STARTERKIT) \
                $(STARTERKITDIR) \
                $(DISTROPREFSDIR) \
                /etc/tapper.cfg \
                /opt/tapper/perl

CPUCOUNT = `cat /proc/cpuinfo | grep vendor_id|wc -l`

# default target
all:
	@echo "Try "
	@echo "  make installernfsroot -- a base OS subdir bootable from NFS for Tapper::Installer"
	@echo "  make baseimage64      -- a Debian imagefile used as base system for tests"
	@echo "  make clientpkg64      -- the Tapper client package for tests"
	@echo "  make localsetup       -- most stuff to run a central Tapper host"
	@echo "                           but WITHOUT automation. Contains:"
	@echo "                              . reports receiver"
	@echo "                              . reports api"
	@echo "                              . web frontend"
	@echo "  make tapperhost       -- everything to run a central Tapper control host"
	@echo "                           INCLUSIVE automation. Contains:"
	@echo "                              . make installernfsroot"
	@echo "                              . make baseimage64"
	@echo "                              . make clientpkg64"
	@echo "                              . make localsetup"
	@echo "  make it so            -- same as 'make tapperhost'"
	@echo "  make clean            -- remove intermediate build files+chroots"
	@echo "                           (keeps the final /data/tapper/... intact)"

clean:
	-umount $(INSTALLERCHROOT)/sys
	-umount $(INSTALLERCHROOT)/proc
	-umount $(INSTALLERCHROOT)/dev/pts
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-umount $(CLIENTPKG64CHROOT)/sys
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	-rm -fr $(CLEANFILES)

cleannfsroot:
	-umount $(INSTALLERCHROOT)/sys
	-umount $(INSTALLERCHROOT)/proc
	-umount $(INSTALLERCHROOT)/dev/pts
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-umount $(CLIENTPKG64CHROOT)/sys
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	-rm -fr $(NFSROOTCLEANFILES)

$(REMOVEPKG):
	@echo "########## Remove local machine setup"
	@echo $(PKGMGR) $(REMOVE) $@
	#-$(PKGMGR) $(REMOVE) $@

cleanlocal: $(REMOVEPKG)
	-$(PKGMGR) $(CLEANUP)
	-rm -fr $(LOCALCLEANFILES)

cleanbaseimage64chroot:
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-rm -fr $(BASEIMAGE64CHROOT)

cleanbaseimage64file:
	-rm -fr $(BASEIMAGE64FILE)

cleandb:
	-echo "drop database testrundb; drop database reportsdb; drop user tapper;" | mysql -uroot -p$${MYSQL_ROOT_PW}

mrproper: clean localclean localcleandb nfsrootclean
	-rm -fr $(CLIENTPKG64FILE)
	-rm -fr $(BASEIMAGE64FILE)

# ==============================================================
# *
# *
# *
# *                      General setup utils
# *
# *
# *
# ==============================================================
# Simple Debug, call make debug to use
debug: $(REMOVEPKG)
	@echo "### configuring the package manager ###"
	@echo $(PKGMGR) $(REMOVE)

distroprefs: $(DISTROPREFSDIR)/00.README

$(DISTROPREFSDIR)/00.README:
	mkdir -p $(DISTROPREFSDIR)/
	wget -r --no-parent -nd -N -P $(DISTROPREFSDIR)/ $(DISTROPREFS)
# fix non-fitting distroprefs
	perl -pni -e 's/disabled: +1/disabled: 0/' $(DISTROPREFSDIR)/PARDUS.File-MimeInfo.yml

dependencies: distroprefs $(STARTERKITDIR)/etc/log4perl.cfg

$(STARTERKITDIR)/etc/log4perl.cfg:
	@echo "########## install some build dependencies"
	$(APTGET) update
	$(APTGET) install debootstrap
	$(APTGET) install patch
	$(APTGET) install makepatch
	$(APTGET) install curl
	$(APTGET) install wget
	$(APTGET) install rsync
	$(APTGET) install gcc
	$(APTGET) install perl-modules
	curl -k -z$(TMP)/$(STARTERKIT) -L $(STARTERKITURL) -o $(TMP)/$(STARTERKIT)
	cd $(TMP) ; tar xzf $(STARTERKIT)


# ==============================================================
# *
# *
# *
# *                      Installer NFS root
# *
# *
# *
# ==============================================================

installernfsroot: dependencies $(INSTALLERNFSROOT)/etc/log4perl.cfg

$(INSTALLERNFSROOT)/etc/log4perl.cfg:
	@echo "##################################################################"
	@echo "# "
	@echo "# "
	@echo "#         ,************************."
	@echo "# Set up  *   INSTALLER NFS ROOT   *  for net booting testmachines"
	@echo "#         '************************'"
	@echo "# "
	@echo "# "
	@echo "##################################################################"
#
### prepare subdirs
#
	@echo "########## prepare subdirs"
	-umount $(INSTALLERCHROOT)/sys
	-umount $(INSTALLERCHROOT)/proc
	-umount $(INSTALLERCHROOT)/dev/pts
	-rm -fr $(INSTALLERCHROOT)
	mkdir -p $(INSTALLERCHROOT)
#
### bootstrap new debian in chroot
#
	@echo "########## bootstrap new debian in chroot"
	debootstrap --arch amd64 squeeze $(INSTALLERCHROOT) $(DEBIANMIRROR)
	mount -t proc proc $(INSTALLERCHROOT)/proc
	mount -t devpts devpts $(INSTALLERCHROOT)/dev/pts
#
### set shell environment
#
	@echo "########## set shell environment"
	echo 'PS1="CHROOT-Tapper-NFS-Installer:\w# "'  >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'CPUCOUNT=`cat /proc/cpuinfo | grep vendor_id | wc -l`' >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'export TEST_JOBS=$$CPUCOUNT'             >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'export PERL_AUTOINSTALL="--defaultdeps"' >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'export TWMC_TEST_PORT=9876'              >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'alias dir="ls -Flart --color"'           >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'rm="rm -i"'                              >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'cp="cp -i"'                              >> $(INSTALLERCHROOT)/root/.bashrc
	echo 'mv="mv -i"'                              >> $(INSTALLERCHROOT)/root/.bashrc
#
### Perl/CPAN setup
#
	@echo "########## Perl/CPAN setup"
	mkdir -p $(INSTALLERCHROOT)/$(DISTROPREFSDIR)/
	rsync -r $(DISTROPREFSDIR)/ $(INSTALLERCHROOT)/$(DISTROPREFSDIR)/
	perl -pni -e 's/disabled: +1/disabled: 0/' $(INSTALLERCHROOT)/$(DISTROPREFSDIR)/PARDUS.File-MimeInfo.yml
#
### enable console login
#
	@echo "########## enable console login"
	echo 's0:12345:respawn:/sbin/getty 115200 ttyS0 vt100' >> $(INSTALLERCHROOT)/etc/inittab
#
### set NFS read-only
#
	@echo "########## set NFS read-only"
	sed -i -e 's/rootmode=rw/rootmode=ro/' $(INSTALLERCHROOT)/etc/init.d/checkroot.sh
#
### prepare writeable directories
#
	@echo "########## prepare writeable directories"
	echo 'proc  /proc      proc  defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'sysfs /sys       sysfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'tmpfs /tmp       tmpfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'ramfs /var/log   ramfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'ramfs /var/lock  ramfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'ramfs /var/run   ramfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'ramfs /var/spool ramfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
	echo 'ramfs /var/lib/nfs ramfs defaults 0 0' >> $(INSTALLERCHROOT)/etc/fstab
#
### configure NFS working directory
#
	@echo "########## configure NFS working directory"
	echo "$(TAPPER_SERVER):$(DATATAPPER) $(DATATAPPER) nfs auto,defaults 0 0" >> $(INSTALLERCHROOT)/etc/fstab
#
### run remaining configuration from inside the chroot
#
	@echo "########## run remaining configuration from inside the chroot"
	cp $(STARTERKITDIR)/utils/$(INSTALLERCHROOTPREPARE) $(INSTALLERCHROOT)/
	cp $(TMP)/$(STARTERKIT) $(INSTALLERCHROOT)/tmp/
	chmod +x $(INSTALLERCHROOT)/$(INSTALLERCHROOTPREPARE)
	chroot $(INSTALLERCHROOT) /$(INSTALLERCHROOTPREPARE)
	rm -f $(INSTALLERCHROOT)/$(INSTALLERCHROOTPREPARE)
	rm $(INSTALLERCHROOT)/tmp/$(STARTERKIT)

# ==============================================================
# *
# *
# *
# *                      Base Image
# *
# *
# *
# ==============================================================

baseimage64chroot: dependencies $(BASEIMAGE64CHROOT)/etc/log4perl.cfg

$(BASEIMAGE64CHROOT)/etc/log4perl.cfg:
	@echo "########################################################"
	@echo "# "
	@echo "#         ,****************."
	@echo "# Set up  *   BASE IMAGE   *  to be used for Tests"
	@echo "#         '****************'"
	@echo "# "
	@echo "########################################################"
#
### prepare subdirs
#
	@echo "########## prepare subdirs"
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-rm -fr $(BASEIMAGE64CHROOT)
	mkdir -p $(BASEIMAGE64CHROOT)
#
### bootstrap new debian in it
#
	@echo "########## bootstrap new debian in it"
	debootstrap --arch amd64 squeeze $(BASEIMAGE64CHROOT) $(DEBIANMIRROR)
	mount -t proc proc $(BASEIMAGE64CHROOT)/proc
	mount -t devpts devpts $(BASEIMAGE64CHROOT)/dev/pts
#
### set shell environment
#
	@echo "########## set shell environment"
	echo 'PS1="CHROOT-Tapper-BaseImage:\w# "'      >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'CPUCOUNT=`cat /proc/cpuinfo | grep vendor_id | wc -l`' >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export TEST_JOBS=$$CPUCOUNT'             >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export PERL_AUTOINSTALL="--defaultdeps"' >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export PERLBREW_ROOT=/opt/tapper/perl'   >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export TWMC_TEST_PORT=9876'              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'alias dir="ls -Flart --color"'           >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'rm="rm -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'cp="cp -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'mv="mv -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
#
### Perl/CPAN setup
#
	@echo "########## Perl/CPAN setup"
	mkdir -p $(BASEIMAGE64CHROOT)/$(DISTROPREFSDIR)/
	rsync -r $(DISTROPREFSDIR)/ $(BASEIMAGE64CHROOT)/$(DISTROPREFSDIR)/
	-perl -pni -e 's/disabled: +1/disabled: 0/' $(BASEIMAGE64CHROOT)/$(DISTROPREFSDIR)/PARDUS.File-MimeInfo.yml
#
### enable console login
#
	@echo "########## enable console login"
	echo 's0:12345:respawn:/sbin/getty 115200 ttyS0 vt100' >> $(BASEIMAGE64CHROOT)/etc/inittab
#
### prepare writeable directories
#
	@echo "########## prepare writeable directories"
	echo 'proc  /proc      proc  defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'sysfs /sys       sysfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'tmpfs /tmp       tmpfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'ramfs /var/log   ramfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'ramfs /var/lock  ramfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'ramfs /var/run   ramfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
	echo 'ramfs /var/spool ramfs defaults 0 0' >> $(BASEIMAGE64CHROOT)/etc/fstab
#
### configure NFS working directory
#
	@echo "########## configure NFS working directory"
	echo "$(TAPPER_SERVER):$(DATATAPPER) $(DATATAPPER) nfs auto,defaults 0 0" >> $(BASEIMAGE64CHROOT)/etc/fstab
#
### run remaining configuration from inside the chroot
#
	@echo "########## run remaining configuration from inside the chroot"
	cp $(STARTERKITDIR)/utils/$(BASEIMAGE64CHROOTPREPARE) $(BASEIMAGE64CHROOT)/
	cp $(TMP)/$(STARTERKIT) $(BASEIMAGE64CHROOT)/tmp/
	chmod +x $(BASEIMAGE64CHROOT)/$(BASEIMAGE64CHROOTPREPARE)
	chroot $(BASEIMAGE64CHROOT) /$(BASEIMAGE64CHROOTPREPARE)
	rm -f $(BASEIMAGE64CHROOT)/$(BASEIMAGE64CHROOTPREPARE)
	rm $(BASEIMAGE64CHROOT)/tmp/$(STARTERKIT)


clientpkg64: $(CLIENTPKG64FILE)

$(CLIENTPKG64FILE): baseimage64file
#
# Prepare client-side opt-tapper package
#
	@echo "##############################################################"
	@echo "# "
	@echo "#         ,********************."
	@echo "# Set up  *   CLIENT PACKAGE   *  to be installed in Test-OS"
	@echo "#         '********************'"
	@echo "# "
	@echo "##############################################################"
#
### prepare subdirs
#
	@echo "########## Prepare client-side opt-tapper package"
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	-rm -fr $(CLIENTPKG64CHROOT)
	mkdir -p $(CLIENTPKG64CHROOT)
	tar -C $(CLIENTPKG64CHROOT) -xzf $(BASEIMAGE64FILE)
	mount -t proc proc $(CLIENTPKG64CHROOT)/proc
	mount -t devpts devpts $(CLIENTPKG64CHROOT)/dev/pts

	cp $(STARTERKITDIR)/utils/$(CLIENTPKG64CHROOTPREPARE) $(CLIENTPKG64CHROOT)/
	chmod +x $(CLIENTPKG64CHROOT)/$(CLIENTPKG64CHROOTPREPARE)
	chroot $(CLIENTPKG64CHROOT) /$(CLIENTPKG64CHROOTPREPARE)
	rm -f $(CLIENTPKG64CHROOT)/$(CLIENTPKG64CHROOTPREPARE)
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	cd $(CLIENTPKG64CHROOT) ; tar -czf $(CLIENTPKG64FILE) opt/

# ==============================================================
# *
# *
# *
# *                      Tapper Central Server
# *
# *
# *
# ==============================================================

intro:
	@echo "########################################################"
	@echo "# "
	@echo "# "
	@echo "# Set up central Tapper host"
	@echo "# "
	@echo "# "
	@echo "########################################################"


WORKDIRS := $(METAREPORTSDIR) \
             $(OUTPUTDIR) \
             $(IMAGESDIR) \
             $(PACKAGESDIR) \
             $(TAPPERUTILSDIR) \
             $(TESTPROGRAMDIR) \
             $(CONFIGSDIR) \
			 $(USECASEDIR) \
             $(TFTPBOOTDIR) \
             $(SYNCDIR) \
             $(NFSROOTDIR)

$(WORKDIRS):
	mkdir -p $@

workingdirs: $(WORKDIRS)

baseimage64file: baseimage64chroot workingdirs $(BASEIMAGE64FILE)

$(BASEIMAGE64FILE): $(BASEIMAGE64CHROOT)/etc/log4perl.cfg
#
# Pack baseimage64
#
	@echo "########## Pack baseimage64"
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	cd $(BASEIMAGE64CHROOT) ; tar -czf $(BASEIMAGE64FILE) .

nfsrootdir: $(NFSROOTDIR)/etc/log4perl.cfg

$(NFSROOTDIR)/etc/log4perl.cfg: installernfsroot workingdirs
#
# Prepare network boot OS
#
	@echo "########## Prepare network boot OS"
	rsync -ax --delete $(INSTALLERCHROOT)/ $(NFSROOTDIR)/

optperl: dependencies $(PERLBIN)/perl

$(PERLBIN)/perl:
#
# Install Perl
#
	@echo "########## Install Perl"
#	chmod +x $(STARTERKITDIR)/utils/prepare-optperl
	$(STARTERKITDIR)/utils/prepare-optperl

nfsserver:
#
# Install an NFS server and export $(DATATAPPER)
#
	@echo "########## Install an NFS server and export $(DATATAPPER)"
	$(APTGET) install nfs-kernel-server
	-# find out IP in a clever way, hopefully not too clever...
	for IP in $$(ip addr | awk '/inet / {print $$2}'); do echo "$(DATATAPPER) $$IP(fsid=0,no_root_squash,no_subtree_check,rw,insecure) 192.168.1.0/255.255.255.0(fsid=0,no_root_squash,no_subtree_check,rw)" >> /etc/exports ; done
	-# later append: 192.168.1.0/255.255.255.0(fsid=0,no_root_squash,no_subtree_check,rw)
	/etc/init.d/nfs-kernel-server restart

libdeps:
#
# Prepare packages
#
	@echo "########## Prepare packages"
	$(APTGET) install expect
	$(APTGET) install expect-dev
	$(APTGET) install libssl-dev
	$(APTGET) install mysql-server
	$(APTGET) install libmysqlclient-dev
	$(APTGET) install libsqlite3-0
	$(APTGET) install sqlite3
	$(APTGET) install libxml2
	$(APTGET) install libxml2-dev
	$(APTGET) install libexpat1
	$(APTGET) install libexpat1-dev
	$(APTGET) install apache2
	$(APTGET) install libapache2-mod-fcgid

perlpkgs:
#
# Prepare CPAN libs
#
	@echo "########## Prepare CPAN libs"
	-# File::Slurp 9999.14 from 22 Mar 2011 introduced silly test bug, force install.
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) -f File::Slurp
	-# work around forgotten dependency in T::R::Web 3.0.4
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) File::Copy::Recursive
	-# fails sometimes in non-critical tests
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) -f Test::WWW::Mechanize
	-#PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) TWMC_TEST_PORT=9876 $(CPAN) -f Test::WWW::Mechanize::Catalyst
	-# work around missing deps in HTML::FormFu
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) -f IO::Interactive
	-# work around bug in Tapper::Config 3.0.4
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) TAPPER_CONFIG_FILE=lib/auto/Tapper/Config/tapper.yml $(CPAN) Tapper::Config
	-# missing dependency in T::R::Web 3.0.5
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) -f Tapper::Testplan
	-# missing dependency in T::R::Web
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) TAP::Parser
	-# non problematic rest
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBI
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBD::mysql
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBD::SQLite
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::Schema
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::CLI

databases:
#
# Prepare mysql-server
#
	@echo "########## Prepare mysql-server"
	-echo "create user tapper identified by 'tapper'; \
               create database reportsdb; \
               grant all on reportsdb.* to tapper@'%'; \
               create database testrundb;\
               grant all on testrundb.* to tapper@'%';" | \
	mysql -uroot -p$${MYSQL_ROOT_PW}
	-yes | $(PERL) $(PERLBIN)/tapper-db-deploy init --db ReportsDB
	-yes | $(PERL) $(PERLBIN)/tapper-db-deploy init --db TestrunDB
	@echo "(Newqueue fails if already exists. Ignore.)"
	-$(PERL) $(PERLBIN)/tapper-testrun newqueue --name AdHoc --prio 1000

examplemachines:
#
# Add known test machines
#
	@echo "########## Add known test machines"
	-$(PERL) $(PERLBIN)/tapper-testrun newhost --name $(TESTMACHINE1) --active
	-$(PERL) $(PERLBIN)/tapper-testrun newhost --name $(TESTMACHINE2) --active
	-$(PERL) $(PERLBIN)/tapper-testrun newhost --name $(TESTMACHINE3) --active
#
# Add machine features (no public frontend tool available)
#
	@echo "########## Add machine features"
# machine1
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE1)'),     'mem',  4096);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE1)'),   'cores',     4);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE1)'),  'vendor', 'AMD');" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE1)'), 'has_ecc',     1);" | mysql testrundb -utapper -ptapper
# machine2
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE2)'),     'mem',  2048);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE2)'),   'cores',     2);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE2)'),  'vendor', 'AMD');" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE2)'), 'has_ecc',     0);" | mysql testrundb -utapper -ptapper
# machine3
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE3)'),     'mem',  2048);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE3)'),   'cores',     2);" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE3)'),  'vendor', 'AMD');" | mysql testrundb -utapper -ptapper
	-echo "insert into host_feature(host_id, entry, value)  values ((select id from host where name = '$(TESTMACHINE3)'), 'has_ecc',     0);" | mysql testrundb -utapper -ptapper

initialdata:
#
# Add some initial data to have a better looking webgui
#
	@echo "########## Add machine features"
	-echo "insert into user (name, login)  values ('Tapper Default User', 'tapper');" | mysql testrundb -utapper -ptapper
	-echo "insert into user (name, login)  values ('A Typical Tapper User', 'root');" | mysql testrundb -utapper -ptapper
	-echo "insert into topic (name, description)  values ('Misc', 'What does not fit into other topics');" | mysql testrundb -utapper -ptapper
	-echo "insert into topic (name, description)  values ('Software', 'Non-kernel software, like libraries, programs');" | mysql testrundb -utapper -ptapper
	-echo "insert into topic (name, description)  values ('Benchmark', 'Collection of values');" | mysql testrundb -utapper -ptapper
	-echo "insert into topic (name, description)  values ('Distribution', 'OS or Compiler distribution');" | mysql testrundb -utapper -ptapper

tapperconfig:
#
# Install Tapper config
	@echo "########## Install Tapper config"
	cp $(STARTERKITDIR)/etc/tapper.cfg /etc/
	-# dynamically write local IP in tapper.cfg
	export IP=$$(ip addr | awk '/inet / {print $$2}'|grep -v 127.0.0|cut -d/ -f1) ; \
	  perl -i -pne 'my $$ip=$$ENV{IP}; s/__TAPPER_HOST_IP__/$$ip/g' /etc/tapper.cfg

receiver: workingdirs dependencies tapperconfig libdeps optperl /etc/init.d/tapper_reports_receiver_daemon

/etc/init.d/tapper_reports_receiver_daemon:
#
# start scripts for reports-receiver
#
	@echo "########## start scripts for reports-receiver"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::Reports::Receiver
	cp $(STARTERKITDIR)/etc/init.d/tapper_reports_receiver_daemon /etc/init.d/
	insserv tapper_reports_receiver_daemon
	/etc/init.d/tapper_reports_receiver_daemon restart
	sleep 2

api: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for reports-api
#
	@echo "########## start scripts for reports-api"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::Reports::API
	cp $(STARTERKITDIR)/etc/init.d/tapper_reports_api_daemon /etc/init.d/
	insserv tapper_reports_api_daemon
	/etc/init.d/tapper_reports_api_daemon restart

mcp: workingdirs dependencies tapperconfig libdeps optperl examplemachines initialdata
#
# start scripts for MCP
#
	@echo "########## start scripts for MCP"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) App::Daemon
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::MCP
	cp $(STARTERKITDIR)/etc/init.d/tapper_mcp_daemon /etc/init.d/
	insserv tapper_mcp_daemon
	/etc/init.d/tapper_mcp_daemon restart

mcpmsgreceiver: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for MCP Message Receiver
#
	@echo "########## start scripts for MCP Message Receiver"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Tapper::MCP::MessageReceiver
	cp $(STARTERKITDIR)/etc/init.d/tapper_mcp_msg_receiver_daemon /etc/init.d/
	insserv tapper_mcp_msg_receiver_daemon
	/etc/init.d/tapper_mcp_msg_receiver_daemon restart

web: workingdirs dependencies tapperconfig libdeps optperl initialdata
#
# start scripts for web frontend
#
	@echo "########## start scripts for web frontend"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) TWMC_TEST_PORT=9876 $(CPAN) Tapper::Reports::Web
	cp $(STARTERKITDIR)/usecases/kernel_build.mpc $(USECASEDIR)/
	cp $(STARTERKITDIR)/usecases/tests.yml   $(USECASEDIR)/
	cp $(STARTERKITDIR)/etc/apache2/conf.d/tapper_reports_web.conf /etc/apache2/conf.d/
	/etc/init.d/apache2 restart
	@echo "We wait some seconds for the daemons to come up..."
	sleep 5

tftpserver:
#
# Install an TFTP server and export $(DATATAPPER)
#
	@echo "########## Install an NFS server and export $(DATATAPPER)"
	$(APTGET) install atftpd
	-# symlink Debian specific dir to keep all files in our central data dir
	-rm -rf /srv/tftp
	-ln -sf $(TFTPBOOTDIR) /srv/tftp
	-ln -s $(TFTPBOOTDIR) $(TFTPBOOTDIR)/tftpboot
	cp $(STARTERKITDIR)/tftpboot/bzImage $(TFTPBOOTDIR)/
	/etc/init.d/atftpd restart

testreport: receiver
# test report
	OURHOSTNAME=$$(perl -MSys::Hostname -e 'print Sys::Hostname::hostname') ;\
	  OURTAPPERPORT=$$(echo $$(cat /etc/tapper.cfg |grep '^report_port:'|cut -d: -f2)) ; \
	  cat $(STARTERKITDIR)/misc/starterkit.tap | sed -e "s/TAPPERHOST/$$OURHOSTNAME/" | \
	  netcat -q5 -w5 $(TAPPER_SERVER) $$OURTAPPERPORT
# look at frontend
	@echo "*** You should now be able to view reports here:"
	@echo "    http://$(TAPPER_SERVER)/tapper"

testquery: receiver
# test report
	@echo "*** The following output comes from the query interface"
	cat $(STARTERKITDIR)/misc/starterkit.query | netcat -q5 -w5 $(TAPPER_SERVER)

localsetup: workingdirs dependencies \
            tapperconfig \
            libdeps optperl perlpkgs \
            databases examplemachines \
            receiver web api \
            testreport \
            nfsserver tftpserver \
            mcp mcpmsgreceiver
	@echo "**************************************************"
	@echo "*"
	@echo "* Installation done."
	@echo "*"
	@echo "* Comment about passwords:"
	@echo "*"
	@echo "* Please note that the mysql user 'tapper' got a"
	@echo "* default password which matches its default"
	@echo "* configuration in /etc/tapper.cfg."
	@echo "*"
	@echo "* If you change it, change it in config, too."
	@echo "*"
	@echo "**************************************************"

tapperhost: intro dependencies \
            installernfsroot baseimage64file nfsrootdir clientpkg64 \
            localsetup
	@echo "**************************************************"
	@echo "*"
	@echo "* Installation done."
	@echo "*"
	@echo "* Comment about passwords:"
	@echo "*"
	@echo "* The created nfsroot and the baseimage that"
	@echo "* are both used during automatic installation and"
	@echo "* test running got default passwords, respectively."
	@echo "*"
	@echo "* Change them with 'chroot' and 'passwd' if you"
	@echo "* use them in non trusted environment."
	@echo "*"
	@echo "**************************************************"

engage: tapperhost

so: engage

it:
	@echo "Make it so!"
