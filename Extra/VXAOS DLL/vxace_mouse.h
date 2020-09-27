//--------------------
#include "main.h"
#include "vxace_sdk.h"
#include <windows.h>
//----------
#define DOWN_STATE_MASK  0x00000080
#define DEAD_KEY_MASK    0x80000000
//----------
struct Mouse {
  //----------
  uint8_t     state[256];
  //-----
  long        pos[2];
  long        old_pos[2];
  //-----
  VALUE     * triggered;
  VALUE     * pressed;
  VALUE     * released;
  uint8_t   * repeated;
  //----------
} Mouse;
//----------
void  DLL_EXPORT Mouse__setup(struct RArray * triggered, struct RArray * pressed, struct RArray * released, void * repeated);
void  DLL_EXPORT Mouse__update(void);
void  DLL_EXPORT Mouse__getPos(long pos[2]);
void  DLL_EXPORT Mouse__getOldPos(long pos[2]);
//--------------------


