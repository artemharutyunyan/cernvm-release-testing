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

# ===== OSRC specific defaults =====

DEBIANMIRROR ?= http://ftp.de.debian.org/debian/

# install Tapper libs from Git repositories
TAPPERFROMGIT ?= 0

GITPREFIXTAPPERLIBS ?= git://github.com/amd
GITPREFIXTESTSUITES ?= git://wotan

# use local starterkit instead of download from amd64.org
LOCALSTARTERKIT ?= 1

SCRIPTENVIRONMENT = TAPPERFROMGIT=$(TAPPERFROMGIT) GITPREFIXTAPPERLIBS=$(GITPREFIXTAPPERLIBS) GITPREFIXTESTSUITES=$(GITPREFIXTESTSUITES)

# ===== General configuration =====

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

# installer NFS root
# 64bit always
INSTALLERCHROOT=/mnt/chroot/squeeze-tapper-nfsroot-for-installer
INSTALLERCHROOTPREPARE=prepare-installer-nfsroot-in-chroot
INSTALLERCHROOTPREPAREPERLMODULES=prepare-installer-nfsroot-perlmodules

# baseimage
# 64bit
BASEIMAGE64FILE=$(IMAGESDIR)/debian_base64.tgz
BASEIMAGE64CHROOT=/mnt/chroot/squeeze-tapper-baseimage64
BASEIMAGE64CHROOTPREPARE=prepare-baseimage-in-chroot
# 32bit
BASEIMAGE32FILE=$(IMAGESDIR)/debian_base32.tgz
BASEIMAGE32CHROOT=/mnt/chroot/squeeze-tapper-baseimage32
BASEIMAGE32CHROOTPREPARE=prepare-baseimage-in-chroot

# client package
# 64bit
CLIENTPKG64FILE=$(TAPPERUTILSDIR)/opt-tapper64.tar.gz
CLIENTPKG64CHROOT=/mnt/chroot/squeeze-tapper-clientpkg64
CLIENTPKG64CHROOTPREPARE=prepare-clientpkg-in-chroot
# 32bit
CLIENTPKG32FILE=$(TAPPERUTILSDIR)/opt-tapper32.tar.gz
CLIENTPKG32CHROOT=/mnt/chroot/squeeze-tapper-clientpkg32
CLIENTPKG32CHROOTPREPARE=prepare-clientpkg-in-chroot

### initial machine names
TAPPER_SERVER=tapper
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

### Python setup
PERLPREPARE=prepare-optperl

### Python setup
PYTHONDIR=/opt/tapper/python
PYTHONBIN=$(PYTHONDIR)/bin
PYTHONPREPARE=prepare-optpython

# Debian automatic install
APTGETOPTIONS=-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --yes
APTGET=DEBIAN_FRONTEND=noninteractive; export DEBIAN_FRONTEND ; apt-get $(APTGETOPTIONS)

### starter kit
STARTERKITBASENAME=tapper-starterkit
STARTERKIT=$(STARTERKITBASENAME).tgz
STARTERKITURL=http://amd64.org/pub/tapper/$(STARTERKIT)
STARTERKITDIR=$(TMP)/$(STARTERKITBASENAME)

PREPAREPERLMODULE=$(STARTERKITDIR)/utils/prepare-perlmodule

### intermediate build files, not the final results
CLEANFILES = $(TMP)/$(STARTERKIT) \
             $(STARTERKITDIR) \
             $(DISTROPREFSDIR)

CLEANFILESCHROOTNFSROOT    = $(INSTALLERCHROOT)
CLEANFILESCHROOTBASEIMAGES = $(BASEIMAGE64CHROOT) $(BASEIMAGE32CHROOT)
CLEANFILESCHROOTCLIENTPKGS = $(CLIENTPKG64CHROOT) $(CLIENTPKG32CHROOT)


LOCALCLEANFILES=$(TMP)/$(STARTERKIT) \
                $(STARTERKITDIR) \
                $(DISTROPREFSDIR) \
                /opt/tapper/perl

CPUCOUNT = `cat /proc/cpuinfo | grep vendor_id|wc -l`

# default target
help:
	@echo ""
	@echo "Try most common targets:"
	@echo "------------------------"
	@echo "  make web              -- update WebGUI"
	@echo "  make mcp              -- update MCP"
	@echo "  make cli              -- update CLI"
	@echo "  make api              -- update Reports::API"
	@echo "  make receiver         -- update Reports::Receiver"
	@echo "  make nfsrootperl      -- update Tapper::Installer & friends in nfsroot"
	@echo "  make clientpkgs       -- create client packages (64bit + 32bit)"
	@echo "  make clientpkgs++     -- update client packages (64bit + 32bit)"
	@echo "  make baseimages       -- create base images     (64bit + 32bit)"
	@echo ""
	@echo "  make allautomation    -- everything for automation"
	@echo "                           *except* the MCP-MessageReceiver"
	@echo "                              . cleanups to force rebuild"
	@echo "                              . nfsrootdir"
	@echo "                              . baseimages"
	@echo "                              . clientpkgs"
	@echo "                              . mcp"
	@echo ""
	@echo "Special target:"
	@echo "---------------"
	@echo "  make mcpmsgreceiver   -- MCP-MessageReceiver"
	@echo "                           => only do if *REALLY* needed"
	@echo "                              because it risks MCP persistence!"
	@echo ""
	@echo "Other targets:"
	@echo "--------------"
	@echo "  make nfsrootdir       -- a base OS subdir bootable from NFS for Tapper::Installer"
	@echo "  make localsetup       -- most stuff to run a central Tapper host"
	@echo "                           but WITHOUT automation. Contains:"
	@echo "                              . reports receiver"
	@echo "                              . reports api"
	@echo "                              . web frontend"
	@echo "  make tapperhost       -- everything to run a central Tapper control host"
	@echo "                           INCLUSIVE automation. Contains:"
	@echo "                              . make installerchroot"
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
	-umount $(BASEIMAGE32CHROOT)/sys
	-umount $(BASEIMAGE32CHROOT)/proc
	-umount $(BASEIMAGE32CHROOT)/dev/pts
	-umount $(CLIENTPKG64CHROOT)/sys
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	-umount $(CLIENTPKG32CHROOT)/sys
	-umount $(CLIENTPKG32CHROOT)/proc
	-umount $(CLIENTPKG32CHROOT)/dev/pts
	-rm -fr $(CLEANFILES)

cleanchrootnfs:
	-umount $(INSTALLERCHROOT)/sys
	-umount $(INSTALLERCHROOT)/proc
	-umount $(INSTALLERCHROOT)/dev/pts
	-rm -fr $(CLEANFILESCHROOTNFSROOT)

 cleanchrootbaseimages:
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-umount $(BASEIMAGE32CHROOT)/sys
	-umount $(BASEIMAGE32CHROOT)/proc
	-umount $(BASEIMAGE32CHROOT)/dev/pts
	-rm -fr $(CLEANFILESCHROOTBASEIMAGES)

 cleanchrootclientpkgs:
	-umount $(CLIENTPKG64CHROOT)/sys
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	-umount $(CLIENTPKG32CHROOT)/sys
	-umount $(CLIENTPKG32CHROOT)/proc
	-umount $(CLIENTPKG32CHROOT)/dev/pts
	-rm -fr $(CLEANFILESCHROOTCLIENTPKGS)

cleanchroots: cleanchrootnfs cleanchrootbaseimages cleanchrootclientpkgs


cleanlocal:
	@echo "########## Remove local machine setup"
	-$(APTGET) remove --purge expect-dev
	-$(APTGET) remove --purge expect
	-$(APTGET) remove --purge libssl-dev
	-$(APTGET) remove --purge mysql-server
	-$(APTGET) remove --purge libmysqlclient-dev
	-$(APTGET) remove --purge libsqlite3-0
	-$(APTGET) remove --purge sqlite3
	-$(APTGET) remove --purge libxml2-dev
	-$(APTGET) remove --purge libxml2
	-$(APTGET) remove --purge libexpat1-dev
	-$(APTGET) remove --purge libexpat1
	-$(APTGET) remove --purge libapache2-mod-fcgid
	-$(APTGET) remove --purge apache2
	-$(APTGET) remove --purge atftpd
	-$(APTGET) autoremove
	-rm -fr $(LOCALCLEANFILES)

cleanbaseimage64chroot:
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	-rm -fr $(BASEIMAGE64CHROOT)

cleanbaseimage32chroot:
	-umount $(BASEIMAGE32CHROOT)/sys
	-umount $(BASEIMAGE32CHROOT)/proc
	-umount $(BASEIMAGE32CHROOT)/dev/pts
	-rm -fr $(BASEIMAGE32CHROOT)

cleanbaseimage64file:
	-rm -f $(BASEIMAGE64FILE)

cleanbaseimage32file:
	-rm -f $(BASEIMAGE32FILE)

cleanstarterkit:
	-rm -f $(STARTERKITDIR)/etc/log4perl.cfg

cleanoptpython:
	-rm -fr $(PYTHONDIR)

cleandb:
	-echo "drop database testrundb; drop database reportsdb; drop user tapper;" | mysql -uroot -p$${MYSQL_ROOT_PW}

mrproper: clean localclean localcleandb nfsrootclean
	-rm -fr $(CLIENTPKG64FILE)
	-rm -fr $(CLIENTPKG32FILE)
	-rm -fr $(BASEIMAGE64FILE)
	-rm -fr $(BASEIMAGE32FILE)

# ==============================================================
# *
# *
# *
# *                      General setup utils
# *
# *
# *
# ==============================================================

distroprefs: $(DISTROPREFSDIR)/00.README

$(DISTROPREFSDIR)/00.README:
	mkdir -p $(DISTROPREFSDIR)/
	wget -r --no-parent -nd -N -P $(DISTROPREFSDIR)/ $(DISTROPREFS)
# fix non-fitting distroprefs
	perl -pni -e 's/disabled: +1/disabled: 0/' $(DISTROPREFSDIR)/PARDUS.File-MimeInfo.yml

dependencies: distroprefs starterkit

starterkit:
ifeq ($(LOCALSTARTERKIT),1)
	cd .. ; tar -czf $(STARTERKIT) $(STARTERKITBASENAME)/ ; cp $(STARTERKIT) $(TMP)/$(STARTERKIT)
else
	curl -z$(TMP)/$(STARTERKIT) -L $(STARTERKITURL) -o $(TMP)/$(STARTERKIT)
endif
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

installerchroot: dependencies $(INSTALLERCHROOT)/etc/log4perl.cfg

$(INSTALLERCHROOT)/etc/log4perl.cfg:
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
### ssh authorized_keys for reboot via ssh
#
	mkdir -p $(INSTALLERCHROOT)/root/.ssh
	cat /root/.ssh/id_dsa.pub >> $(INSTALLERCHROOT)/root/.ssh/authorized_keys
	cat /root/.ssh/id_rsa.pub >> $(INSTALLERCHROOT)/root/.ssh/authorized_keys
	chmod 600 $(INSTALLERCHROOT)/root/.ssh/authorized_keys
	chmod 700 $(INSTALLERCHROOT)/root/.ssh
#
### run remaining configuration from inside the chroot
#
	@echo "########## run remaining configuration from inside the chroot"
	cd $(INSTALLERCHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) chroot $(INSTALLERCHROOT) /tmp/tapper-starterkit/utils/$(INSTALLERCHROOTPREPARE)

nfsrootperl: installerchrootperl nfsrootdir

installerchrootperl: installerchroot
	@echo "########## prepare subdirs"
	-umount $(INSTALLERCHROOT)/sys
	-umount $(INSTALLERCHROOT)/proc
	-umount $(INSTALLERCHROOT)/dev/pts
	mount -t proc proc $(INSTALLERCHROOT)/proc
	mount -t devpts devpts $(INSTALLERCHROOT)/dev/pts
	@echo "########## run remaining configuration from inside the chroot"
	cd $(INSTALLERCHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) chroot $(INSTALLERCHROOT) /tmp/tapper-starterkit/utils/$(INSTALLERCHROOTPREPAREPERLMODULES)

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

baseimage32chroot: dependencies $(BASEIMAGE32CHROOT)/etc/log4perl.cfg

$(BASEIMAGE64CHROOT)/etc/log4perl.cfg:
	@echo "########################################################"
	@echo "# "
	@echo "#         ,**********************."
	@echo "# Set up  *   BASE IMAGE 64bit   *  to be used for Tests"
	@echo "#         '**********************'"
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
	echo 'PS1="CHROOT-Tapper-BaseImage64:\w# "'      >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'CPUCOUNT=`cat /proc/cpuinfo | grep vendor_id | wc -l`' >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export TEST_JOBS=$$CPUCOUNT'             >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export PERL_AUTOINSTALL="--defaultdeps"' >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export PERLBREW_ROOT=/opt/tapper/perl'   >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export PATH=/opt/tapper/python/bin:$${PATH}' >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'export TWMC_TEST_PORT=9876'              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'alias dir="ls -Flart --color"'           >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'rm="rm -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'cp="cp -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	echo 'mv="mv -i"'                              >> $(BASEIMAGE64CHROOT)/root/.bashrc
	mkdir -p $(BASEIMAGE64CHROOT)/root/.ssh
	cat /root/.ssh/id_dsa.pub >> $(BASEIMAGE64CHROOT)/root/.ssh/authorized_keys
	cat /root/.ssh/id_rsa.pub >> $(BASEIMAGE64CHROOT)/root/.ssh/authorized_keys
	chmod 600 $(BASEIMAGE64CHROOT)/root/.ssh/authorized_keys
	chmod 700 $(BASEIMAGE64CHROOT)/root/.ssh
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
	cd $(BASEIMAGE64CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) chroot $(BASEIMAGE64CHROOT) /tmp/tapper-starterkit/utils/$(BASEIMAGE64CHROOTPREPARE)

$(BASEIMAGE32CHROOT)/etc/log4perl.cfg:
	@echo "########################################################"
	@echo "# "
	@echo "#         ,**********************."
	@echo "# Set up  *   BASE IMAGE 32bit   *  to be used for Tests"
	@echo "#         '**********************'"
	@echo "# "
	@echo "########################################################"
#
### prepare subdirs
#
	@echo "########## prepare subdirs"
	-umount $(BASEIMAGE32CHROOT)/proc
	-umount $(BASEIMAGE32CHROOT)/dev/pts
	-rm -fr $(BASEIMAGE32CHROOT)
	mkdir -p $(BASEIMAGE32CHROOT)
#
### bootstrap new debian in it
#
	@echo "########## bootstrap new debian in it"
	debootstrap --arch i386 squeeze $(BASEIMAGE32CHROOT) $(DEBIANMIRROR)
	mount -t proc proc $(BASEIMAGE32CHROOT)/proc
	mount -t devpts devpts $(BASEIMAGE32CHROOT)/dev/pts
#
### set shell environment
#
	@echo "########## set shell environment"
	echo 'PS1="CHROOT-Tapper-BaseImage32:\w# "'      >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'CPUCOUNT=`cat /proc/cpuinfo | grep vendor_id | wc -l`' >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'export TEST_JOBS=$$CPUCOUNT'             >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'export PERL_AUTOINSTALL="--defaultdeps"' >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'export PERLBREW_ROOT=/opt/tapper/perl'   >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'export PATH=/opt/tapper/python/bin:$${PATH}' >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'export TWMC_TEST_PORT=9876'              >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'alias dir="ls -Flart --color"'           >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'rm="rm -i"'                              >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'cp="cp -i"'                              >> $(BASEIMAGE32CHROOT)/root/.bashrc
	echo 'mv="mv -i"'                              >> $(BASEIMAGE32CHROOT)/root/.bashrc
	mkdir -p $(BASEIMAGE32CHROOT)/root/.ssh
	cat /root/.ssh/id_dsa.pub >> $(BASEIMAGE32CHROOT)/root/.ssh/authorized_keys
	cat /root/.ssh/id_rsa.pub >> $(BASEIMAGE32CHROOT)/root/.ssh/authorized_keys
	chmod 600 $(BASEIMAGE32CHROOT)/root/.ssh/authorized_keys
	chmod 700 $(BASEIMAGE32CHROOT)/root/.ssh
#
### Perl/CPAN setup
#
	@echo "########## Perl/CPAN setup"
	mkdir -p $(BASEIMAGE32CHROOT)/$(DISTROPREFSDIR)/
	rsync -r $(DISTROPREFSDIR)/ $(BASEIMAGE32CHROOT)/$(DISTROPREFSDIR)/
	-perl -pni -e 's/disabled: +1/disabled: 0/' $(BASEIMAGE32CHROOT)/$(DISTROPREFSDIR)/PARDUS.File-MimeInfo.yml
#
### enable console login
#
	@echo "########## enable console login"
	echo 's0:12345:respawn:/sbin/getty 115200 ttyS0 vt100' >> $(BASEIMAGE32CHROOT)/etc/inittab
#
### prepare writeable directories
#
	@echo "########## prepare writeable directories"
	echo 'proc  /proc      proc  defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'sysfs /sys       sysfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'tmpfs /tmp       tmpfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'ramfs /var/log   ramfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'ramfs /var/lock  ramfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'ramfs /var/run   ramfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
	echo 'ramfs /var/spool ramfs defaults 0 0' >> $(BASEIMAGE32CHROOT)/etc/fstab
#
### configure NFS working directory
#
	@echo "########## configure NFS working directory"
	echo "$(TAPPER_SERVER):$(DATATAPPER) $(DATATAPPER) nfs auto,defaults 0 0" >> $(BASEIMAGE32CHROOT)/etc/fstab
#
### run remaining configuration from inside the chroot
#
	@echo "########## run remaining configuration from inside the chroot"
	cd $(BASEIMAGE32CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) linux32 chroot $(BASEIMAGE32CHROOT) /tmp/tapper-starterkit/utils/$(BASEIMAGE32CHROOTPREPARE)

clientpkgs: clientpkg64 clientpkg32
clientpkgs++: clientpkg64++ clientpkg32++

allautomation: cleanstarterkit \
               cleanchroots \
               cleanbaseimage64file cleanbaseimage64chroot \
               cleanbaseimage32file cleanbaseimage32chroot \
               starterkit \
               installerchroot \
               nfsrootdir \
               baseimage64file \
               baseimage32file \
               clientpkgs \
               mcp


# ==============================================================
# *
# *
# *
# *                      64 bit client pkg
# *
# *
# *
# ==============================================================

clientpkg64:   prepareclientchroot64                updateclientpkg64
clientpkg64++: prepareclientchroot64 addclientpkg64 updateclientpkg64

prepareclientchroot64: baseimage64file
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
	cd $(CLIENTPKG64CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)

addclientpkg64:
	tar -C $(CLIENTPKG64CHROOT) -xzf $(CLIENTPKG64FILE)

updateclientpkg64:
#
# Prepare client-side opt-tapper package
#
	@echo "##############################################################"
	@echo "# "
	@echo "#         ,**************************."
	@echo "# SET UP  *   CLIENT PACKAGE 64bit   *"
	@echo "#         '**************************'"
	@echo "# "
	@echo "##############################################################"
	cd $(CLIENTPKG64CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) chroot $(CLIENTPKG64CHROOT) /tmp/tapper-starterkit/utils/$(CLIENTPKG64CHROOTPREPARE)
	-umount $(CLIENTPKG64CHROOT)/proc
	-umount $(CLIENTPKG64CHROOT)/dev/pts
	cd $(CLIENTPKG64CHROOT) ; \
	  cp $(CLIENTPKG64FILE) $(CLIENTPKG64FILE)_bak_`date +%Y%m%d%H%M` ; \
	  tar -czf $(CLIENTPKG64FILE) opt/


# ==============================================================
# *
# *
# *
# *                      32 bit client pkg
# *
# *
# *
# ==============================================================


clientpkg32:   prepareclientchroot32                updateclientpkg32
clientpkg32++: prepareclientchroot32 addclientpkg32 updateclientpkg32

prepareclientchroot32: baseimage32file
#
### prepare subdirs
#
	@echo "########## Prepare client-side opt-tapper package"
	-umount $(CLIENTPKG32CHROOT)/proc
	-umount $(CLIENTPKG32CHROOT)/dev/pts
	-rm -fr $(CLIENTPKG32CHROOT)
	mkdir -p $(CLIENTPKG32CHROOT)
	tar -C $(CLIENTPKG32CHROOT) -xzf $(BASEIMAGE32FILE)
	mount -t proc proc $(CLIENTPKG32CHROOT)/proc
	mount -t devpts devpts $(CLIENTPKG32CHROOT)/dev/pts
	cd $(CLIENTPKG32CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)

addclientpkg32:
	tar -C $(CLIENTPKG32CHROOT) -xzf $(CLIENTPKG32FILE)

updateclientpkg32:
#
# Prepare client-side opt-tapper package
#
	@echo "##############################################################"
	@echo "# "
	@echo "#         ,**************************."
	@echo "# SET UP  *   CLIENT PACKAGE 32bit   *"
	@echo "#         '**************************'"
	@echo "# "
	@echo "##############################################################"
	cd $(CLIENTPKG32CHROOT)/tmp/ ; tar xzf $(TMP)/$(STARTERKIT)
	$(SCRIPTENVIRONMENT) linux32 chroot $(CLIENTPKG32CHROOT) /tmp/tapper-starterkit/utils/$(CLIENTPKG32CHROOTPREPARE)
	-umount $(CLIENTPKG32CHROOT)/proc
	-umount $(CLIENTPKG32CHROOT)/dev/pts
	cd $(CLIENTPKG32CHROOT) ; \
	  cp $(CLIENTPKG32FILE) $(CLIENTPKG32FILE)_bak_`date +%Y%m%d%H%M` ; \
	  tar -czf $(CLIENTPKG32FILE) opt/


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

baseimage32file: baseimage32chroot workingdirs $(BASEIMAGE32FILE)

baseimages: baseimage64file baseimage32file

$(BASEIMAGE64FILE): $(BASEIMAGE64CHROOT)/etc/log4perl.cfg
#
# Pack baseimage64
#
	@echo "########## Pack baseimage64"
	-umount $(BASEIMAGE64CHROOT)/sys
	-umount $(BASEIMAGE64CHROOT)/proc
	-umount $(BASEIMAGE64CHROOT)/dev/pts
	cd $(BASEIMAGE64CHROOT) ; \
	  cp $(BASEIMAGE64FILE) $(BASEIMAGE64FILE)_bak_`date +%Y%m%d%H%M` ; \
	  tar -czf $(BASEIMAGE64FILE) .

$(BASEIMAGE32FILE): $(BASEIMAGE32CHROOT)/etc/log4perl.cfg
#
# Pack baseimage32
#
	@echo "########## Pack baseimage32"
	-umount $(BASEIMAGE32CHROOT)/sys
	-umount $(BASEIMAGE32CHROOT)/proc
	-umount $(BASEIMAGE32CHROOT)/dev/pts
	cd $(BASEIMAGE32CHROOT) ; \
	  cp $(BASEIMAGE32FILE) $(BASEIMAGE32FILE)_bak_`date +%Y%m%d%H%M` ; \
	  tar -czf $(BASEIMAGE32FILE) .

nfsrootdir: installerchroot workingdirs
#
# Prepare network boot OS
#
	@echo "########## Prepare network boot OS"
	rsync -axc --delete $(INSTALLERCHROOT)/ $(NFSROOTDIR)/

optperl: dependencies $(PERLBIN)/perl

$(PERLBIN)/perl:
#
# Install Perl
#
	@echo "########## Install Perl"
#	chmod +x $(STARTERKITDIR)/utils/$(PERLPREPARE)
	$(STARTERKITDIR)/utils/$(PERLPREPARE)

optpython: dependencies $(PYTHONBIN)/python

$(PYTHONBIN)/python:
#
# Install Python
#
	@echo "########## Install Python"
	$(STARTERKITDIR)/utils/$(PYTHONPREPARE)

temare: optpython
#
# Install temare
#
	$(STARTERKITDIR)/utils/prepare-pythonmodule temare

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
	$(APTGET) install libsqlite3-dev
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
	-# non problematic rest
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBI
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBD::mysql
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) DBD::SQLite
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) Module::Install::Catalyst

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

tapperconfig: /etc/tapper.cfg

/etc/tapper.cfg:
#
# Install Tapper config
	@echo "########## Install Tapper config if not exists"
	if [ ! -e /etc/tapper.cfg ] ; then \
	  cp $(STARTERKITDIR)/etc/tapper.cfg /etc/ ; \
          export IP=$$(ip addr | awk '/inet / {print $$2}'|grep -v 127.0.0|cut -d/ -f1) ; \
            perl -i -pne 'my $$ip=$$ENV{IP}; s/__TAPPER_HOST_IP__/$$ip/g' /etc/tapper.cfg ; \
        fi

receiver: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for reports-receiver
#
	@echo "########## start scripts for reports-receiver"
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Reports::Receiver
	cp $(STARTERKITDIR)/etc/init.d/tapper_reports_receiver_daemon /etc/init.d/
	insserv tapper_reports_receiver_daemon
	/etc/init.d/tapper_reports_receiver_daemon restart
	sleep 2

cli: workingdirs dependencies tapperconfig libdeps optperl
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::CLI

api: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for reports-api
#
	@echo "########## start scripts for reports-api"
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Reports::API
	cp $(STARTERKITDIR)/etc/init.d/tapper_reports_api_daemon /etc/init.d/
	insserv tapper_reports_api_daemon
	/etc/init.d/tapper_reports_api_daemon restart

action: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for Tapper::Action
#
	@echo "########## start scripts for Tapper::Action"
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Config
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Action
	cp $(STARTERKITDIR)/etc/init.d/tapper_action_daemon /etc/init.d/
	chmod 755 /etc/init.d/tapper_action_daemon
	insserv tapper_action_daemon
	/etc/init.d/tapper_action_daemon restart

mcp: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for MCP
#
	@echo "########## start scripts for MCP"
	PERL_AUTOINSTALL="--defaultdeps" TEST_JOBS=$(CPUCOUNT) $(CPAN) App::Daemon
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::MCP
	cp $(STARTERKITDIR)/etc/init.d/tapper_mcp_daemon /etc/init.d/
	insserv tapper_mcp_daemon
	/etc/init.d/tapper_mcp_daemon restart

mcpmsgreceiver: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for MCP Message Receiver
#
	@echo "########## start scripts for MCP Message Receiver"
	-# force latest schema
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Schema
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::MCP::MessageReceiver
	cp $(STARTERKITDIR)/etc/init.d/tapper_mcp_msg_receiver_daemon /etc/init.d/
	insserv tapper_mcp_msg_receiver_daemon
	/etc/init.d/tapper_mcp_msg_receiver_daemon restart

web: workingdirs dependencies tapperconfig libdeps optperl
#
# start scripts for web frontend
#
	@echo "########## start scripts for web frontend"
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Schema
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Testplan
	$(SCRIPTENVIRONMENT) $(PREPAREPERLMODULE) Tapper::Reports::Web
	cp $(STARTERKITDIR)/usecases/kernel_build.mpc $(USECASEDIR)/
	cp $(STARTERKITDIR)/usecases/tests.yml   $(USECASEDIR)/
	cp $(STARTERKITDIR)/etc/apache2/conf.d/tapper_reports_web.conf /etc/apache2/conf.d/
	/etc/init.d/apache2 restart

tftpserver:
#
# Install an TFTP server and export $(DATATAPPER)
#
	@echo "########## Install an NFS server and export $(DATATAPPER)"
	$(APTGET) install atftpd
	-# symlink Debian specific dir to keep all files in our central data dir
	-rm -rf /srv/tftp
	-ln -sf $(TFTPBOOTDIR) /srv/tftp
	-ln -sf $(TFTPBOOTDIR) $(TFTPBOOTDIR)/tftpboot
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
            libdeps optperl perlpkgs optpython \
            cli databases \
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
            installerchroot baseimages nfsrootdir clientpkgs \
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
