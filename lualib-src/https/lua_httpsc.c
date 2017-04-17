/* Lua HTTPSC - a HTTPS library for Lua
 *
 * Copyright (c) 2016  chenweiqi
 *
 * The MIT License (MIT)
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <time.h>

#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include "openssl/ssl.h"
#include "openssl/err.h"
#include <poll.h>


#define CACHE_SIZE 0x1000
#define ERROR_FD -1
#define SEND_RETRY 10

static SSL_CTX *ctx = NULL;

typedef struct {
	int is_init;
} cutil_conf_t;

enum conn_st
{
	CONNECT_INIT = 1,
	CONNECT_PORT = 2,
	CONNECT_SSL = 3,
	CONNECT_DONE = 4
};

typedef struct {
	int fd;
	SSL* ssl;
	enum conn_st status;
} cutil_fd_t;

static cutil_conf_t* fetch_config(lua_State *L) {
	cutil_conf_t* cfg;
	cfg = lua_touserdata(L, lua_upvalueindex(1));
	if (!cfg)
		luaL_error(L, "httpsc: Unable to fetch cfg");

	return cfg;
}

static void close_fd_t(cutil_fd_t* fd_t) {
	if ( fd_t == NULL )
		return;

	SSL* ssl = fd_t->ssl;
	if ( ssl != NULL ) {
		SSL_shutdown(ssl);
		SSL_free(ssl);
	}
	
	int fd = fd_t->fd;
	if (fd != ERROR_FD)
		close(fd);

	free(fd_t);
}

static int try_connect_ssl(SSL* ssl) {
	int ret,err;
	ret = SSL_connect(ssl);
	err = SSL_get_error(ssl, ret);
	if (ret == 1) 
		return 0;

	if (err != SSL_ERROR_WANT_WRITE && err != SSL_ERROR_WANT_READ ) {
		return -1;
	}
	return 1;
}

static int lconnect(lua_State *L) {
	cutil_conf_t* cfg = fetch_config(L);
	if(!cfg->is_init)
	{
		luaL_error(L, "httpsc: Not inited");
		return 0;
	}
	
	const char * addr = luaL_checkstring(L, 1);
	int port = luaL_checkinteger(L, 2);

	cutil_fd_t* fd_t = (cutil_fd_t *)malloc(sizeof(cutil_fd_t));
	if ( fd_t == NULL )
		return luaL_error(L, "httpsc: Create fd %s %d failed", addr, port);
	fd_t->fd = ERROR_FD;
	fd_t->ssl = NULL;
	fd_t->status = CONNECT_INIT;

	
	int fd = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in my_addr;
	fd_t->fd = fd;

	bzero(&my_addr, sizeof(my_addr));
	my_addr.sin_addr.s_addr = inet_addr(addr);
	my_addr.sin_family = AF_INET;
	my_addr.sin_port = htons(port);

	int ret;
	struct timeval timeo = {3, 0};
	socklen_t len = sizeof(timeo);
	ret = setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeo, len);
	if (ret) {
		close_fd_t(fd_t);
		return luaL_error(L, "httpsc: Setsockopt %s %d failed", addr, port);
	}

	int flag = fcntl(fd, F_GETFL, 0);
	fcntl(fd, F_SETFL, flag | O_NONBLOCK);

	ret = connect(fd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr_in));
	if (ret != 0) {
		if (errno == EINPROGRESS) {
			fd_t->status = CONNECT_PORT;
		} else {
			close_fd_t(fd_t);
			return luaL_error(L, "httpsc: Connect %s %d failed", addr, port);
		}

	} else {
		fd_t->status = CONNECT_SSL;
		SSL *ssl = SSL_new(ctx);
		fd_t->ssl = ssl;
		SSL_set_fd(ssl, fd);
		ret = try_connect_ssl(ssl);
		if (ret == 0) {
			fd_t->status = CONNECT_DONE;
		} else if (ret == -1) {
			close_fd_t(fd_t);
			return luaL_error(L, "httpsc ssl_connect error, errno = %d", errno);
		}
	}
	
	lua_pushlightuserdata(L, fd_t);

	return 1;
}

static int lcheck_connect(lua_State *L) {
	cutil_fd_t* fd_t = (cutil_fd_t* ) lua_touserdata(L, 1);
	if ( fd_t == NULL )
		return luaL_error(L, "httpsc fd error");

	switch (fd_t->status) {
		case CONNECT_DONE:
			lua_pushboolean(L, 1);
			return 1;
		case CONNECT_PORT: 
			{
				struct pollfd fds;
				int ret, err;
				fds.fd = fd_t->fd;
				fds.events = POLLIN | POLLOUT;
				/* get status immediately */
				ret = poll(&fds, 1, 0);

				if (ret != -1) {
					socklen_t len = sizeof(int);
					ret = getsockopt(fd_t->fd, SOL_SOCKET, SO_ERROR, &err, &len);
					if (ret < 0) {
						close_fd_t(fd_t);
						return luaL_error(L, "httpsc getsockopt error, ret = %d", ret);
					}
					if (err == 0) {
						fd_t->status = CONNECT_SSL;
						SSL *ssl = SSL_new(ctx);
						fd_t->ssl = ssl;
						SSL_set_fd(ssl, fd_t->fd);
						ret = try_connect_ssl(ssl);
						if (ret == 0) {
							fd_t->status = CONNECT_DONE;
							lua_pushboolean(L, 1);
							return 1;
						} else if (ret == -1) {
							close_fd_t(fd_t);
							return luaL_error(L, "httpsc connect ssl error, errno = %d", errno);
						}
					} else {
						if (errno == EAGAIN || errno == EINTR || errno == EINPROGRESS ) {
							return 0;
						} else {
							close_fd_t(fd_t);
							return luaL_error(L, "httpsc connect sockopt error, errno = %d", errno);
						}
					}
				} else {
					close_fd_t(fd_t);
					return luaL_error(L, "httpsc connect poll error, ret = %d", ret);
				}
				return 0;
			}
		case CONNECT_SSL:
			{
				int ret = try_connect_ssl(fd_t->ssl);
				if (ret == 0) {
					fd_t->status = CONNECT_DONE;
					lua_pushboolean(L, 1);
					return 1;
				} else if (ret == -1) {
					close_fd_t(fd_t);
					return luaL_error(L, "httpsc connect ssl 2 error, errno = %d", errno);
				}
				return 0;
			}
		default:
			;
	}

	close_fd_t(fd_t);
	return luaL_error(L, "httpsc connect fator error");
}

static int lclose(lua_State *L) {
	cutil_fd_t* fd_t = (cutil_fd_t* ) lua_touserdata(L, 1);
	if ( fd_t == NULL )
		return luaL_error(L, "httpsc fd error");
	
	close_fd_t(fd_t);

	return 0;
}

static void block_send(lua_State *L, SSL *ssl, const char * buffer, int sz) {
	int retry = SEND_RETRY;
	while(sz > 0) {
		if (retry <= 0) {
			luaL_error(L, "httpsc: socket error: retry timeout");
			return;
		}
		retry -= 1;
		int r = SSL_write(ssl, buffer, sz);
		if (r < 0) {
			if (errno == EAGAIN || errno == EINTR)
				continue;
			luaL_error(L, "httpsc: socket error: %s", strerror(errno));
			return;
		}
		buffer += r;
		sz -= r;
	}
}

static int lsend(lua_State *L) {
	cutil_conf_t* cfg = fetch_config(L);
	if(!cfg->is_init)
	{
		luaL_error(L, "httpsc: Not inited");
		return 0;
	}
	
	size_t sz = 0;
	cutil_fd_t* fd_t = (cutil_fd_t* ) lua_touserdata(L, 1);
	if ( fd_t == NULL )
		return luaL_error(L, "httpsc fd error");
	SSL* ssl = fd_t->ssl;
	const char * msg = luaL_checklstring(L, 2, &sz);

	block_send(L, ssl, msg, (int)sz);

	return 0;
}


static int lrecv(lua_State *L) {
	cutil_conf_t* cfg = fetch_config(L);
	if(!cfg->is_init)
	{
		luaL_error(L, "httpsc: Not inited");
		return 0;
	}
	cutil_fd_t* fd_t = (cutil_fd_t* ) lua_touserdata(L, 1);
	if ( fd_t == NULL )
		return luaL_error(L, "httpsc fd error");
	SSL* ssl = fd_t->ssl;
	int top = lua_gettop(L);

	char buffer[CACHE_SIZE];
	int size = CACHE_SIZE;
	if ( top > 1 && lua_isnumber(L, 2)) {
		int _size = lua_tointeger(L, 2);
		size = _size > size ? size : _size;
	}

	int r = SSL_read(ssl, buffer, size);
	// if (r == 0) {
	// 	lua_pushliteral(L, "");
	// 	/* close */
	// 	return 1;
	// }
	if (r <= 0) {
		if (errno == EAGAIN || errno == EINTR) {
			return 0;
		}
		return luaL_error(L, "httpsc: socket error: %s", strerror(errno));
	}
	lua_pushlstring(L, buffer, r);
	return 1;
}


static int lusleep(lua_State *L) {
	int n = luaL_checknumber(L, 1);
	usleep(n);
	return 0;
}


/* GC, clean up the buf */
static int _gc(lua_State *L)
{
	cutil_conf_t *cfg;
	cfg = lua_touserdata(L, 1);

	if (ctx != NULL){
		SSL_CTX_free(ctx);
		ctx = NULL;
	}
	
	/* todo: auto gc */

	cfg = NULL;
	return 0;
}

static void _create_config(lua_State *L)
{
	cutil_conf_t *cfg;
	cfg = lua_newuserdata(L, sizeof(*cfg));
	cfg->is_init = !!NULL;
	/* Create GC method to clean up buf */
	lua_newtable(L);
	lua_pushcfunction(L, _gc);
	lua_setfield(L, -2, "__gc");
	lua_setmetatable(L, -2);

	/* openssl init */
	if ( ctx == NULL) {
		SSL_library_init();
		OpenSSL_add_all_algorithms();
		SSL_load_error_strings();
		ctx = SSL_CTX_new(SSLv23_client_method());
		if (ctx == NULL)
		{
			ERR_print_errors_fp(stdout);
			luaL_error(L, "httpsc: Unable to init openssl");
			return;
		}
	}

	cfg->is_init = !NULL;
}


int luaopen_httpscdriver(lua_State *L)
{
	static const luaL_Reg funcs[] = {
		{ "connect", lconnect },
		{ "check_connect", lcheck_connect },
		{ "recv", lrecv },
		{ "send", lsend },
		{ "close", lclose },
		{ "usleep", lusleep },
		{NULL, NULL}
	};

	lua_newtable(L);
	_create_config(L);
	luaL_setfuncs(L, funcs, 1);

	return 1;
}