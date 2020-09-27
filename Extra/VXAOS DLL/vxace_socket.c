//--------------------
#include "vxace_socket.h"
//---------
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>
#include <io.h>
//---------------
int SocketLib__GetLastError(void) {
  //----------
  return WSAGetLastError();
  //----------
}
//---------------
int SocketLib__setup(void) {
  //----------
  int err = 0;
  if ((err = WSAStartup(MAKEWORD(2,2), &SocketLib.wsaData)) != 0) {
    WSASetLastError(err);
    return 1;
  }
  //-----
  return 0;
  //----------
}
//---------------
int SocketLib__connect(const char * ip, const char * port, SOCKET * to_socket) {
  //----------
  struct addrinfo * result = NULL, * ptr = NULL, hints;
  //-----
  ZeroMemory( &hints, sizeof(hints) );
  hints.ai_family   = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  //-----
  int err;
  if ((err = getaddrinfo(ip, port, &hints, &result)) != 0) {
    WSASetLastError(err);
    return -1;
  }
  //-----
  SOCKET ConnectSocket = INVALID_SOCKET;
  //-----
  // Attempt to connect to the first address returned by the call to getaddrinfo
  ptr = result;
  //-----
  while (!(result == NULL)) {
    //-----
    // Create a SOCKET for connecting to server
    ConnectSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
    //-----
    if (ConnectSocket == INVALID_SOCKET) {
      freeaddrinfo(result);
      //return 1;
    } else {
      //-----
      // Connect to server.
      int iResult = connect(ConnectSocket, result->ai_addr, (int)result->ai_addrlen);
      if (iResult == SOCKET_ERROR) {
        closesocket(ConnectSocket);
        ConnectSocket = INVALID_SOCKET;
      }
      //-----
    }
    //-----
    result = result->ai_next;
    //-----
  }
  //-----
  if ((result == NULL) && (ConnectSocket == INVALID_SOCKET)) {
    freeaddrinfo((struct addrinfo*)ptr);
    return 1;
  }
  //-----
  freeaddrinfo((struct addrinfo*)ptr);
  //-----
  if (ConnectSocket == INVALID_SOCKET) {
      return 1;
  }
  //-----
  memcpy(to_socket, &ConnectSocket, sizeof(SOCKET));
  return 0;
  //----------
}
//---------------
int SocketLib__close(SOCKET socket) {
  //----------
  if ((shutdown(socket, SD_SEND)) == SOCKET_ERROR) {
    closesocket(socket);
    return 1;
  }
  //-----
  closesocket(socket);
  return 0;
  //----------
}
//---------------
int SocketLib__send(SOCKET socket, char * datap, int len) {
  //----------
	const uint8_t * data = (const uint8_t *)datap;	/* For pointer arithmetic */
	int sent, left;
  //-----
	/* Keep sending data until it's sent or an error occurs */
	left = len;
	sent = 0;
	WSASetLastError(0);
  //-----
	do {
		len = send(socket, (const char *)data, left, 0);
		if ( len > 0 ) {
			sent += len;
			left -= len;
			data += len;
		}
	} while ( (left > 0) && ((len > 0) || (WSAGetLastError() == WSAEINTR)) );
  //-----
	return sent;
	//----------
}
//---------------
int SocketLib__recv(SOCKET socket, char * data, int maxlen) {
  //----------
  int len = 0;
	WSASetLastError(0);
  //-----
	do {
    int pos = 0;
	  while (pos != maxlen) {
      len = recv(socket, (char *)data + pos, maxlen - pos, 0);
      pos += len;
	  }
	} while ((WSAGetLastError() == WSAEINTR));
  //-----
	return len;
  //----------
}
//---------------
int SocketLib__recv_non_block(SOCKET socket, char * data, int maxlen) {
  //----------
	int len = 0;
  //-----
	WSASetLastError(0);
  //-----
	do {
		len = recv(socket, (char *)data, maxlen, 0);
	} while (WSAGetLastError() == WSAEINTR);
  //-----
	return len;
  //----------
}
//---------------
int SocketLib__eof(SOCKET socket) {
  //----------
  fd_set socks;
  FD_ZERO(&socks);
  FD_SET(socket, &socks);
  //-----
  struct timeval timeout;
  //-----
  timeout.tv_sec  = 0;
  timeout.tv_usec = 0;
  //-----
  return select(socket+1, &socks, (fd_set*)0, (fd_set*)0, &timeout);
  //----------
}
//---------------
int SocketLib__TestHost(const char * ip, const char * port) {
  //----------
  struct addrinfo * result = NULL, hints;
  //-----
  ZeroMemory(&hints, sizeof(hints));
  hints.ai_family   = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  //-----
  int err;
  if ((err = getaddrinfo(ip, port, &hints, &result)) != 0) {
    WSASetLastError(err);
    return 0;
  }
  //-----
  if (result == NULL) {
    return 0;
  } else {
    freeaddrinfo((struct addrinfo*)result);
    return 1;
  }
  //-----
  return 0;
  //----------
}
//--------------------


