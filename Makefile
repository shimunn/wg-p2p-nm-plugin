NAME=wg-p2p-nm-plugin
VERSION=0.1.0
USE_DOCKER := false

all: compile

compile:
	if [ "${USE_DOCKER}" == "false" ]; then \
		cargo build --release; \
	else \
		docker build . -t $(shell pwd | sha1sum | cut -c -32) && \
		docker run -ti -v "$(shell pwd)":/host $(shell pwd | sha1sum | cut -c -32) sh -c "chown $(shell id -u):$(shell id -u) -R /build/target && yes | cp -rf /build/target /host/"; \
	fi
	
install: compile
	@install -Dm755 -t "$(DESTDIR)/usr/lib/NetworkManager/VPN/" nm-wg-p2p-vpn-service.name
	@install -Dm755 -t "$(DESTDIR)/etc/dbus-1/system.d/" nm-wg-p2p-vpn-service.conf
	
	@install -Dm755 -t "$(DESTDIR)/usr/lib/NetworkManager/" ./target/release/wg-p2p-vpn-service
	@install -Dm755 -t "$(DESTDIR)/usr/lib/x86_64-linux-gnu/NetworkManager/" ./target/release/libwg_p2p_nm_plugin.so
	@install -Dm755 -t "$(DESTDIR)/usr/share/gnome-vpn-properties/wg-p2p/" ./src/gui/wg-p2p-vpn-editor.ui

TMPDIR := $(shell mktemp -d)
package: compile
	mkdir -p $(TMPDIR)/etc/dbus-1/system.d/
	mkdir -p $(TMPDIR)/usr/lib/NetworkManager/VPN/
	mkdir -p $(TMPDIR)/usr/lib/x86_64-linux-gnu/NetworkManager/
	mkdir -p $(TMPDIR)/usr/share/gnome-vpn-properties/wg-p2p/

	cp nm-wg-p2p-vpn-service.name $(TMPDIR)/usr/lib/NetworkManager/VPN/
	cp nm-wg-p2p-vpn-service.conf $(TMPDIR)/etc/dbus-1/system.d/

	cp ./target/release/wg-p2p-vpn-service $(TMPDIR)/usr/lib/NetworkManager/
	cp ./target/release/libwg_p2p_nm_plugin.so $(TMPDIR)/usr/lib/x86_64-linux-gnu/NetworkManager/
	cp ./src/gui/wg-p2p-vpn-editor.ui $(TMPDIR)/usr/share/gnome-vpn-properties/wg-p2p/

#	for PKG in deb rpm; do
	for PKG in deb; do \
		fpm -s dir -t $$PKG -n $(NAME) -v $(VERSION) \
			-p wg-p2p-nm_VERSION_ARCH.$$PKG \
			-d 'libgtk-3-0' \
			-d 'libnm0' \
			-f \
			-C $(TMPDIR) \
			.; \
	done

	rm -R $(TMPDIR)

clean:
	-rm wg-p2p-nm*.deb
	-rm wg-p2p-nm*.rpm
	-docker rmi -f $(shell pwd | sha1sum | cut -c -32)

.PHONY: clean

