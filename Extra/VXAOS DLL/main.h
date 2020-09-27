//--------------------
#ifndef __MAIN_H__
#define __MAIN_H__
//---------------
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
//----------
#include "vxace_sdk.h"
//----------
#ifdef BUILD_DLL
  #define DLL_EXPORT __declspec(dllexport)
#else
  #define DLL_EXPORT __declspec(dllimport)
#endif
//----------
#ifdef __cplusplus
extern "C" {
#endif
//----------
#define ABS(x) (x < 0 ? -(x) : x)
//----------
WNDPROC VXAceWindowProcedure;
int SystemWindowRunning;
HWND        rmvxace_hWnd;
//----------
void DLL_EXPORT System__setCompatibility(void);
HWND DLL_EXPORT System__getHWND(void);
//----------
BOOL DLL_EXPORT Bitmap__vertical_flip(struct RData * _bitmap);
BOOL DLL_EXPORT Bitmap__horizontal_flip(struct RData * _bitmap);
//----------
#ifdef __cplusplus
}
#endif
//---------------
#endif // __MAIN_H__
//--------------------
