//--------------------
#include "main.h"
#include "vxace_sdk.h"
//---------------
void VXAceSDK__Setup(void) {
  //----------
  RGSSDLL  = LoadLibrary("./System/RGSS300.dll");
  RGSSEval = GetProcAddress(RGSSDLL, "RGSSEval");
  //----------
}
//--------------------


