//--------------------
#include "main.h"
#include "vxace_mouse.h"
//---------------
void  DLL_EXPORT Mouse__setup(struct RArray * triggered, struct RArray * pressed, struct RArray * released, void * repeated) {
  //----------
  Mouse.triggered   = triggered->as.heap.ptr;
  Mouse.pressed     = pressed->as.heap.ptr;
  Mouse.released    = released->as.heap.ptr;
  Mouse.repeated    = (uint8_t*)repeated;
  //-----
  Mouse.pos[0]     = 0;
  Mouse.pos[1]     = 0;
  Mouse.old_pos[0] = 0;
  Mouse.old_pos[1] = 0;
  //----------
}
//---------------
void Mouse__update(void) {
  //----------
  memcpy(Mouse.old_pos, Mouse.pos, sizeof(long) * 2);
  POINT point = {0, 0};
  if (GetCursorPos(&point) != 0) {
    ScreenToClient(rmvxace_hWnd, &point);
    Mouse.pos[0] = point.x;
    Mouse.pos[1] = point.y;
  } else {
    Mouse.pos[0] = -1;
    Mouse.pos[1] = -1;
  }
  //----------
}
//---------------
void Mouse__getPos(long pos[2]) {
  //----------
  memcpy(pos, Mouse.pos, sizeof(long) * 2);
  //----------
}
//---------------
void Mouse__getOldPos(long pos[2]) {
  //----------
  memcpy(pos, Mouse.old_pos, sizeof(long) * 2);
  //----------
}
//--------------------


