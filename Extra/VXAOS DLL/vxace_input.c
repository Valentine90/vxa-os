//--------------------
#include "vxace_input.h"
#include <winuser.h>
//---------------
void Input__setup(struct RArray * triggered, struct RArray * pressed, struct RArray * released, void * repeated) {
  //----------
  Input.triggered   = triggered->as.heap.ptr;
  Input.pressed     = pressed->as.heap.ptr;
  Input.released    = released->as.heap.ptr;
  Input.repeated    = (uint8_t*)repeated;
  Input.keyb_layout = GetKeyboardLayout(0);
  Input.last_acent  = 0;
  //-----
  memset(Input.repeated, 0, 256);
  //----------
}
//---------------
void Input__update(void) {
  //----------
  if (GetKeyboardState((PBYTE)Input.state) !=0 ) {
    //-----
    uint8_t * state     = (uint8_t*)Input.state;
    VALUE   * triggered = (VALUE*)Input.triggered;
    VALUE   * pressed   = (VALUE*)Input.pressed;
    VALUE   * released  = (VALUE*)Input.released;
    uint8_t * repeated  = (uint8_t*)Input.repeated;
    //-----
    uint16_t i;
    for (i = 0;i < 256;i++) {
      if ((state[i] & DOWN_STATE_MASK) == DOWN_STATE_MASK) {
        released[i] = Qfalse;
        // if not pressed yet
        if (pressed[i] == Qfalse) {
          // pressed and triggered
          pressed[i]   = Qtrue;
          triggered[i] = Qtrue;
        } else {
          // not triggered anymore
          triggered[i] = Qfalse;
        }
        // update of repeat counter
        if (repeated[i] < 17) {
          repeated[i] += 1;
        } else {
          repeated[i] = 15;
        }
      // not released yet
      } else if (released[i] == Qfalse) {
        // if still pressed
        if (pressed[i] == Qtrue) {
          // not triggered, pressed or repeated, but released
          triggered[i] = Qfalse;
          pressed[i]   = Qfalse;
          repeated[i]  = 0;
          released[i]  = Qtrue;
        }
      } else {
        // not released anymore
        released[i] = Qfalse;
      }
    }
  }
  //----------
}
//---------------
int Input__dir4(void) {
  //----------
  VALUE * pressed = (VALUE*)Input.pressed;
  //-----
  if (pressed[0x28] == Qtrue) {
    return 2;
  } else if (pressed[0x25] == Qtrue) {
    return 4;
  } else if (pressed[0x27] == Qtrue) {
    return 6;
  } else if (pressed[0x26] == Qtrue) {
    return 8;
  }
  //-----
  return 0;
  //----------
}
//---------------
int Input__dir8(void) {
  //----------
  VALUE * pressed = (VALUE*)Input.pressed;
  //-----
  uint8_t left  = (pressed[0x25] == Qtrue);
  uint8_t up    = (pressed[0x26] == Qtrue);
  uint8_t right = (pressed[0x27] == Qtrue);
  uint8_t down  = (pressed[0x28] == Qtrue);
  //-----
  if (down && left)       {  return 1;  }
  else if (down && right) {  return 3;  }
  else if (up && left)    {  return 7;  }
  else if (up && right)   {  return 9;  }
  else if (down)          {  return 2;  }
  else if (left)          {  return 4;  }
  else if (right)         {  return 6;  }
  else if (up)            {  return 8;  }
  //-----
  return 0;
  //----------
}
//---------------
inline int Input__unicode2utf8(uint16_t c, char result[3]) {
  //----------
  if (c < 0x0080) {
    result[0] = (char)c;
    return 1;
  } else if ((c == 180) || (c == 168)) {
    result[0] = c;
    return 1;
  } else if (c < 0x0800) {
    result[0] = (char)(0xC0 | (c >> 6));
    result[1] = (char)(0x80 | (c & 0x3F));
    return 2;
  } else {
    result[0] = (char)(0xE0 | (c  >> 12));
    result[1] = (char)(0x80 | ((c >> 12) & 0x3F));
    result[2] = (char)(0x80 | (c  & 0x3F));
    return 3;
  }
  //-----
  return 0;
  //----------
}
//---------------
int Input__key2char(uint8_t key, uint16_t * _char) {
  //----------
  *_char = 0;
  //-----
  // get corresponding character from virtual key
  int c = MapVirtualKeyEx(key, 2, Input.keyb_layout);
  // stop if character is non-printable and not a dead key
  if ((c < 32) && ((c & DEAD_KEY_MASK) != DEAD_KEY_MASK)) {
    return 0;
  }
  //-----
  // get scan code
  uint8_t vsc = MapVirtualKeyEx(key, 0, Input.keyb_layout);
  // get input string from Win32 API
  int length = ToUnicodeEx(key, vsc, (LPBYTE)Input.state, (LPWSTR)_char, 2, 0, Input.keyb_layout);
  //-----
  if (length == 0) {
    *_char = 0;
  }
  //-----
  return length;
  //----------
}
//---------------
int Input__UTF8String(char * string, int buff_sz) {
  //----------
  uint8_t i2          = 0;
  int  i, sz, szm, size  = 0;
  uint8_t c, * result = (char*)malloc(buff_sz);
  uint8_t * repeated  = (uint8_t*)Input.repeated;
  char keychar[3]     = {0, 0, 0};
  uint16_t keychar_u  = 0;
  //-----
  memset(result, 0, buff_sz);
  //-----
  for (i = 32;i < 256;i++) {
    if ((repeated[i] == 1) || (repeated[i] == 16)) {
      szm = 0;
      Input__key2char(i, &keychar_u);
      sz    = Input__unicode2utf8(keychar_u, keychar);
      for (i2 = size;i2 < size + sz;i2++) {
        c = keychar[i2 - size];
        if (c > 31) {
          result[i2] = c;
        } else {
          szm += 1;
        }
      }
      size += (sz - szm);
    }
  }
  //-----
  if (size != 0) {
    if (Input.last_acent) {
      for (i = size;i > 0;i--) {
        result[i] = result[i-1];
      }
      result[0]   = Input.last_acent;
      size++;
      Input.last_acent = 0;
    }
    //-----
    uint8_t   ac, nc, frp = 0;
    uint8_t * f_result    = (char*)malloc(buff_sz);
    char      jump        = 0;
    uint8_t   a_id        = 0;
    //-----
    memset(f_result, 0, buff_sz);
    for (i = 0;i < size;i++) {
      c = result[i];
      if (jump) {
        jump = 0;
      } else {
        if (IS_ACCENT(c)) {
          a_id =  ACENT_ID(c);
          if ((nc = result[i+1]) != 0) {
            if (IS_ACCENTABLE(nc) && ((ac = AccentsCharsConv[ACCENTABLE_ID(nc)][a_id]) != 0)) {
              f_result[frp++] = 195;
              f_result[frp++] = ac;
              jump = 1;
            } else {
              if      (c == 180) {  f_result[frp++] = 194;  }
              else if (c == 168) {  f_result[frp++] = 194;  }
              f_result[frp++] = c;
              //-----
              if      (nc == 180) {  f_result[frp++] = 194;  }
              else if (nc == 168) {  f_result[frp++] = 194;  }
              f_result[frp++] = nc;
              jump = 1;
            }
          } else {
            Input.last_acent = c;
          }
        } else {
          f_result[frp++] = c;
        }
      }
    }
    //-----
    memcpy(string, f_result, buff_sz);
    free(f_result);
    free(result);
    //-----
    return frp;
    //-----
  }
  //-----
  free(result);
  return 0;
  //----------
}
//--------------------


