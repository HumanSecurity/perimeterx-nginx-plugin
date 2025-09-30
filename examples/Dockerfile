FROM openresty/openresty:bookworm

ENV VER_LUA_NETTLE=1.5

RUN apt-get update && apt-get -qq -y install \
    build-essential \
    ca-certificates \
    curl \
    wget luarocks

RUN luarocks install lustache
RUN luarocks install luasocket
RUN luarocks install lua-resty-http
RUN luarocks install lua-resty-nettle


RUN mkdir -p /tmp/px
COPY Makefile /tmp/px/
COPY lib /tmp/px/lib
COPY t /tmp/t
RUN make -C /tmp/px install

COPY examples/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY examples/creds.json /tmp/creds.json
COPY examples/pxconfig.lua /usr/local/lib/lua/px/

CMD ["nginx", "-g", "daemon off;"]

