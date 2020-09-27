//--------------------
#ifndef __VXACE_INPUT_H__
#define __VXACE_INPUT_H__
//----------
#include "main.h"
#include "vxace_sdk.h"
//----------
#define DOWN_STATE_MASK  0x00000080
#define DEAD_KEY_MASK    0x80000000
//----------
struct Input {
  //----------
  VALUE   * triggered;  // Array.new(256, false)
  VALUE   * pressed;    // Array.new(256, false)
  VALUE   * released;   // Array.new(256, false)
  uint8_t * repeated;   // Array.new(256, 0)
  //-----
  HKL       keyb_layout;
  uint8_t   state[256];
  uint8_t   last_acent;
  //----------
} Input;
//---------------
uint8_t AccentsCharsConv[16][5] = {
  //-----
  {128, 129, 130, 131, 132},
  {136, 137, 138,   0, 139},
  {140, 141, 142,   0, 143},
  {146, 147, 10,  149, 150},
  {153, 154, 155,   0, 156},
  {  0, 135,   0,   0,   0},
  {  0,   0,   0, 145,   0},
  {  0, 157,   0,   0, 184},
  {160, 161, 162, 163, 164},
  {168, 169, 170,   0, 171},
  {172, 173, 174,   0, 175},
  {178, 179, 180, 181, 182},
  {185, 186, 187,   0, 188},
  {  0, 167,   0,   0,   0},
  {  0,   0,   0, 177,   0},
  {  0, 189,   0,   0, 191},
  //-----
};
#define IS_ACCENT(x) ((x == 96) || (x == 180) || (x == 94) || (x == 126) || (x == 168))
#define ACENT_ID(x) ((x == 96) ? 0 : ((x == 180) ? 1 : ((x == 94) ? 2 : ((x == 126) ? 3 : ((x == 168) ? 4 : -1)))))
#define IS_ACCENTABLE(x) ((x==65)||(x==69)||(x==73)||(x==79)||(x==85)||(x==67)||(x==78)||(x==89)||(x==97)||\
                          (x==101)||(x==105)||(x==111)||(x==117)||(x==99)||(x==110)||(x==121))
#define ACCENTABLE_ID(x) ((x==65) ? 0 : ((x==69) ? 1 : ((x==73) ? 2 : ((x==79) ? 3 : ((x==85) ? 4 : ((x==67) ? 5 : \
                          ((x==78) ? 6 : ((x==89) ? 7 : ((x==97) ? 8 : ((x==101) ? 9 : ((x==105) ? 10 : ((x==111) ? 11 :\
                           ((x==117) ? 12 : ((x==99) ? 13 : ((x==110) ? 14 : ((x==121) ? 15 :  0))))))))))))))))
//---------------
void DLL_EXPORT Input__setup(struct RArray*, struct RArray*, struct RArray*, void *);
void DLL_EXPORT Input__update(void);
int  DLL_EXPORT Input__key2char(uint8_t, uint16_t * _char);
int  DLL_EXPORT Input__UTF8String(char *, int);
int  DLL_EXPORT Input__dir4(void);
int  DLL_EXPORT Input__dir8(void);
//---------------
#endif // __VXACE_INPUT__
//--------------------
