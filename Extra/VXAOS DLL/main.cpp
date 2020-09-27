//--------------------
#include <windows.h>
//-----------
#include "main.h"
#include "vxace_sdk.h"
//---------------
BOOL Bitmap__vertical_flip(struct RData * _bitmap) {
  //----------
  DWORD i, rowsize, width, height;
  //-----
  RGSSBitmapInfo * bitmap = RGSSBitmapInfo(_bitmap);
  //----------
  if(!bitmap) {  return FALSE;  }
  //-----
  width   = bitmap->infoheader->biWidth;
  height  = bitmap->infoheader->biHeight;
  rowsize = width * 4;
  //-----
  RGBA * tmpData = (RGBA *)malloc(rowsize);
  if (!tmpData) {  return FALSE;  }
  RGBA * top    = (RGBA*)bitmap->lastRow;
  RGBA * bottom = (RGBA*)bitmap->firstRow;
  //-----
  for (i = 0; i < (height / 2); ++i) {
    memcpy(tmpData, top, rowsize);
    memcpy(top, bottom, rowsize);
    memcpy(bottom, tmpData, rowsize);
    //-----
    top = (RGBA*)((unsigned char*)top + rowsize);
    bottom = (RGBA*)((unsigned char*)bottom - rowsize);
  }
  //-----
  free(tmpData);
  //-----
  return TRUE;
}
//---------------
BOOL Bitmap__horizontal_flip(struct RData * _bitmap) {
  //----------
  DWORD y, rowsize, width, height;
  //-----
  RGSSBitmapInfo * bitmap = RGSSBitmapInfo(_bitmap);
  //----------
  if(!bitmap) {  return FALSE;  }
  //-----
  width   = bitmap->infoheader->biWidth;
  height  = bitmap->infoheader->biHeight;
  rowsize = width * 4;
  //-----
  RGBA * tmpData2, * tmpData = (RGBA *)malloc(rowsize);
  int temp_w;
  if (!tmpData) {  return FALSE;  }
  RGBA * top2, * top = (RGBA*)bitmap->firstRow;
  //-----
  for (y = 0; y < height; ++y) {
    memcpy(tmpData, top, rowsize);
    top2 = top;
    tmpData2 = tmpData + width - 1;
    //-----
    temp_w = width;
    while (temp_w-- > 0) {
      *top2++ = *tmpData2--;
    }
    //-----
    top = (RGBA*)((unsigned char*)top - rowsize);
  }
  //-----
  free(tmpData);
  //-----
  return TRUE;
  //----------
}
//---------------
LRESULT CALLBACK VXAcePUPWindowProcedure(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  //----------
  if (message) {
    switch (message) {
      case WM_KILLFOCUS:
        SystemWindowRunning = 0;
        break;
      case WM_SETFOCUS:
        SystemWindowRunning = 1;
        break;
      case WM_CLOSE:
        RGSSEval("crd_exit()");
        return 0;//break;
        //-----
      case WM_DESTROY:
        return VXAceWindowProcedure(hwnd, message, wParam, lParam);break;
      default:
        //return VXAceWindowProcedure(hwnd, message, wParam, lParam);
        break;
     }
     //-----
     return DefWindowProc(hwnd, message, wParam, lParam);
  }
  //-----
  return 0;
  //----------
}
//---------------
void System__setCompatibility(void) {
  //----------
  rmvxace_hWnd  = GetActiveWindow();
  //VXAceSDK__Setup();
  //VXAceWindowProcedure = (WNDPROC)GetWindowLong(rmvxace_hWnd, GWL_WNDPROC);
  //SetWindowLong(rmvxace_hWnd, GWL_WNDPROC, (LONG)VXAcePUPWindowProcedure);
  //-----
  //SystemWindowRunning = 1;
  ShowCursor(0);
  //----------
}
//---------------
HWND System__getHWND(void) {
  //----------
  return rmvxace_hWnd;
  //----------
}
//---------------
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    printf("<{%d}>\n", (int)hinstDLL);
    switch (fdwReason) {
        case DLL_PROCESS_ATTACH:
            // attach to process
            // return FALSE to fail DLL load
            break;

        case DLL_PROCESS_DETACH:
            // detach from process
            break;

        case DLL_THREAD_ATTACH:
            // attach to thread
            break;

        case DLL_THREAD_DETACH:
            // detach from thread
            break;
    }
    return TRUE; // succesful
}
//--------------------


