NAME=wg-p2p-nm-plugin
VERSION=0.1.0

all: compile

compile:
	cargo build --release

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
	rm wg-p2p-nm*.deb
	rm wg-p2p-nm*.rpm

.PHONY: clean

