//--------------------
#include "main.h"
//---------------
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>
//---------------
struct SocketLib {
  WSADATA wsaData;
  int started;
} SocketLib;
//---------------
int DLL_EXPORT SocketLib__GetLastError(void);
int DLL_EXPORT SocketLib__setup(void);
int DLL_EXPORT SocketLib__connect(const char * ip, const char * port, SOCKET * to_socket);
int DLL_EXPORT SocketLib__close(SOCKET socket);
int DLL_EXPORT SocketLib__send(SOCKET socket, char * datap, int len);
int DLL_EXPORT SocketLib__recv(SOCKET socket, char * data, int maxlen);
int DLL_EXPORT SocketLib__recv_non_block(SOCKET socket, char * data, int maxlen);
//----------
int DLL_EXPORT SocketLib__TestHost(const char * ip, const char * port);
int DLL_EXPORT SocketLib__eof(SOCKET socket);
//--------------------


