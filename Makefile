PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install

.PHONY: all package install docker test

all:

docker:
	docker build -t perimeterx/pxnginx .

package:
	tar zvcf pxNginxPlugin.tgz Dockerfile Makefile README.md nginx* lib/ vendor/ www/

install:
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/px
	@if test -f $(DESTDIR)/$(LUA_LIB_DIR)/px/pxconfig.lua; then \
		echo "pxconfig.lua exists - skipping"; \
	else \
		$(INSTALL) lib/px/pxconfig.lua $(DESTDIR)/$(LUA_LIB_DIR)/px/pxconfig.lua; fi

	$(INSTALL) lib/px/pxnginx.lua $(DESTDIR)/$(LUA_LIB_DIR)/px/pxnginx.lua
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/px/block
	$(INSTALL) lib/px/block/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/px/block
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/px/block/templates
	$(INSTALL) lib/px/block/templates/* $(DESTDIR)/$(LUA_LIB_DIR)/px/block/templates
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/px/utils
	$(INSTALL) lib/px/utils/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/px/utils
	- ln -s /usr/local/lib/lua/px /usr/local/share/lua/5.1/px >/dev/null 2>&1 || true
	- ln -s /usr/local/lib/lua/px /usr/local/openresty/lualib/px >/dev/null 2>&1 || true

docker-test: docker
	docker run -it -w /tmp -v logs:/var/log/nginx perimeterx/pxnginx:latest prove -v t

docker-sh: docker
	docker run -it -w /tmp -v logs:/var/log/nginx perimeterx/pxnginx:latest sh

test:
	prove -v t

clean:
	rm -rf pxNginxPlugin.tgz
