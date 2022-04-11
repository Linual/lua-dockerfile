FROM debian:9 as build

RUN apt update && apt install -y wget gcc make libpcre3-dev zlib1g-dev libluajit-5.1-dev libssl-dev
RUN wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz && tar xvfz LuaJIT-2.0.5.tar.gz && cd LuaJIT-2.0.5 && make && make install PREFIX=/usr/local/LuaJIT
RUN export LUAJIT_LIB=/usr/local/LuaJIT/lib 
RUN export LUAJIT_INC=/usr/local/LuaJIT/include/luajit-2.0
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz && tar xvfz v0.3.0.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v0.10.9rc7.tar.gz && tar xvfz v0.10.9rc7.tar.gz 
RUN wget https://openresty.org/download/nginx-1.19.3.tar.gz && tar xvfz nginx-1.19.3.tar.gz && cd nginx-1.19.3 && ./configure  --add-module=/lua-nginx-module-0.10.9rc7 --add-module=/ngx_devel_kit-0.3.0 && make && make install

FROM debian:9
RUN apt update && apt install -y libluajit-5.1-dev
WORKDIR /usr/local/nginx/sbins
COPY --from=build /usr/local/nginx/sbin/nginx .
RUN mkdir ../logs ../conf && touch ../logs/error.log && chmod +x nginx
CMD ["./nginx", "-g", "daemon off;"]

