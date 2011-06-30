STARTERKIT=tapper-starterkit
EXAMPLEFILES = $(STARTERKIT)/etc/log4perl.cfg \
               $(STARTERKIT)/etc/apache2/conf.d/tapper_reports_web.conf \
               $(STARTERKIT)/etc/init.d/tapper_reports_receiver_daemon \
               $(STARTERKIT)/etc/init.d/tapper_reports_api_daemon \
               $(STARTERKIT)/etc/init.d/tapper_mcp_msg_receiver_daemon \
               $(STARTERKIT)/etc/init.d/tapper_mcp_daemon \
               $(STARTERKIT)/etc/init.d/tapper_action_daemon \
               $(STARTERKIT)/etc/init.d/tapper \
               $(STARTERKIT)/etc/init.d/tapper.baseimage \
               $(STARTERKIT)/etc/init.d/opentftp \
               $(STARTERKIT)/etc/opentftp.ini \
               $(STARTERKIT)/etc/dhcp.conf \
               $(STARTERKIT)/etc/tapper.cfg \
               $(STARTERKIT)/misc/MAKEDEV \
               $(STARTERKIT)/misc/CPAN-Config.pm \
               $(STARTERKIT)/misc/starterkit.tap \
               $(STARTERKIT)/misc/starterkit.query \
               $(STARTERKIT)/misc/starterkit.query.mas \
               $(STARTERKIT)/misc/disable_useless_consoles.patch \
               $(STARTERKIT)/utils/prepare-common-development-packages \
               $(STARTERKIT)/utils/prepare-installer-nfsroot-in-chroot \
               $(STARTERKIT)/utils/prepare-baseimage-in-chroot \
               $(STARTERKIT)/utils/prepare-clientpkg-in-chroot \
               $(STARTERKIT)/utils/prepare-optperl \
               $(STARTERKIT)/utils/prepare-perlmodule \
               $(STARTERKIT)/utils/prepare-optpython \
               $(STARTERKIT)/utils/create-symlinks \
               $(STARTERKIT)/usecases/kernel_build.mpc \
               $(STARTERKIT)/usecases/tests.yml \
               $(STARTERKIT)/tftpboot/bzImage

CLEANFILES = $(STARTERKIT).tgz

all:
	@echo "For starterkit maintainer:"
	@echo ""
	@echo "  make starterkit  - create tgz archive"
	@echo "  make clean       - cleanup"
	@echo ""
	@echo "For Tapper users:"
	@echo ""
	@echo "  make install     - install the whole system"

starterkit: $(STARTERKIT).tgz

$(STARTERKIT).tgz: $(EXAMPLEFILES)
	tar -czf $(STARTERKIT).tgz $(STARTERKIT)/
	@echo "Don't forget to deploy $(STARTERKIT).tgz to final place."

clean:
	rm -f $(CLEANFILES)

install:
	cd installer && $(MAKE) it so
