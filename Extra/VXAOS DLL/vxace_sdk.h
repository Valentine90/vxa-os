//--------------------
#ifndef __VXACE_SDK_H__
#define __VXACE_SDK_H__
//----------
#ifdef __cplusplus
extern "C" {
#endif
//----------
#include <windows.h>
//----------
HMODULE RGSSDLL;
typedef int (*pRGSSEval)(const char * pScriptsLine);
pRGSSEval RGSSEval;
void VXAceSDK__Setup(void);
//----------
typedef unsigned long VALUE;
typedef unsigned long ID;
//----------
#define FL_SINGLETON FL_USER0
#define FL_MARK      (((VALUE)1)<<5)
#define FL_RESERVED  (((VALUE)1)<<6) /* will be used in the future GC */
#define FL_FINALIZE  (((VALUE)1)<<7)
#define FL_TAINT     (((VALUE)1)<<8)
#define FL_UNTRUSTED (((VALUE)1)<<9)
#define FL_EXIVAR    (((VALUE)1)<<10)
#define FL_FREEZE    (((VALUE)1)<<11)
//----------
#define FL_USHIFT    12
//----------
#define FL_USER0     (((VALUE)1)<<(FL_USHIFT+0))
#define FL_USER1     (((VALUE)1)<<(FL_USHIFT+1))
#define FL_USER2     (((VALUE)1)<<(FL_USHIFT+2))
#define FL_USER3     (((VALUE)1)<<(FL_USHIFT+3))
#define FL_USER4     (((VALUE)1)<<(FL_USHIFT+4))
#define FL_USER5     (((VALUE)1)<<(FL_USHIFT+5))
#define FL_USER6     (((VALUE)1)<<(FL_USHIFT+6))
#define FL_USER7     (((VALUE)1)<<(FL_USHIFT+7))
#define FL_USER8     (((VALUE)1)<<(FL_USHIFT+8))
#define FL_USER9     (((VALUE)1)<<(FL_USHIFT+9))
#define FL_USER10    (((VALUE)1)<<(FL_USHIFT+10))
#define FL_USER11    (((VALUE)1)<<(FL_USHIFT+11))
#define FL_USER12    (((VALUE)1)<<(FL_USHIFT+12))
#define FL_USER13    (((VALUE)1)<<(FL_USHIFT+13))
#define FL_USER14    (((VALUE)1)<<(FL_USHIFT+14))
#define FL_USER15    (((VALUE)1)<<(FL_USHIFT+15))
#define FL_USER16    (((VALUE)1)<<(FL_USHIFT+16))
#define FL_USER17    (((VALUE)1)<<(FL_USHIFT+17))
#define FL_USER18    (((VALUE)1)<<(FL_USHIFT+18))
#define FL_USER19    (((VALUE)1)<<(FL_USHIFT+19))
//----------
/* special constants - i.e. non-zero and non-fixnum constants */
enum ruby_special_consts {
    RUBY_Qfalse = 0,
    RUBY_Qtrue  = 2,
    RUBY_Qnil   = 4,
    RUBY_Qundef = 6,

    RUBY_IMMEDIATE_MASK = 0x03,
    RUBY_FIXNUM_FLAG    = 0x01,
    RUBY_SYMBOL_FLAG    = 0x0e,
    RUBY_SPECIAL_SHIFT  = 8
};
//----------
#define Qfalse ((VALUE)RUBY_Qfalse)
#define Qtrue  ((VALUE)RUBY_Qtrue)
#define Qnil   ((VALUE)RUBY_Qnil)
#define Qundef ((VALUE)RUBY_Qundef)	/* undefined value for placeholder */
#define IMMEDIATE_MASK RUBY_IMMEDIATE_MASK
#define FIXNUM_FLAG RUBY_FIXNUM_FLAG
#define SYMBOL_FLAG RUBY_SYMBOL_FLAG
//----------
#define SIGNED_VALUE long
#define INT2FIX(i) ((VALUE)(((SIGNED_VALUE)(i))<<1 | FIXNUM_FLAG))
#define LONG2FIX(i) INT2FIX(i)
//---------------
typedef unsigned int RGBA;
//---------------
struct RBasic {
  VALUE flags;
  VALUE klass;
};
//----------
struct RData {
  struct RBasic basic;
  void (*dmark)(void*);
  void (*dfree)(void*);
  void *data;
};
//----------
#define RARRAY_EMBED_LEN_MAX 3
struct RArray {
  struct RBasic basic;
  union {
    struct {
      long len;
      union {
        long capa;
        VALUE shared;
      } aux;
      VALUE *ptr;
    } heap;
    VALUE ary[RARRAY_EMBED_LEN_MAX];
  } as;
};
//-----
#define RARRAY_EMBED_LEN_MASK (FL_USER4|FL_USER3)
#define RARRAY_EMBED_LEN_SHIFT (FL_USHIFT+3)
#define RARRAY_LEN(a) ((RBASIC(a)->flags & RARRAY_EMBED_FLAG) ? (long)((RBASIC(a)->flags >> RARRAY_EMBED_LEN_SHIFT) & (RARRAY_EMBED_LEN_MASK >> RARRAY_EMBED_LEN_SHIFT)) : RARRAY(a)->as.heap.len)
#define RARRAY_PTR(a) ((RBASIC(a)->flags & RARRAY_EMBED_FLAG) ? RARRAY(a)->as.ary : RARRAY(a)->as.heap.ptr)
//---------------
typedef struct{
  DWORD unk1;
  DWORD unk2;
  BITMAPINFOHEADER *infoheader;
  RGBA * firstRow;
  RGBA * lastRow;
} RGSSBitmapInfo;
//----------
typedef struct{
  DWORD unk1;
  DWORD unk2;
  RGSSBitmapInfo * info;
} RGSSBitmap;
//---------------
#define R_CAST(st)   (struct st*)
#define RBASIC(obj)  (R_CAST(RBasic)(obj))
//#define ROBJECT(obj) (R_CAST(RObject)(obj))
//#define RCLASS(obj)  (R_CAST(RClass)(obj))
//#define RMODULE(obj) RCLASS(obj)
//#define RFLOAT(obj)  (R_CAST(RFloat)(obj))
//#define RSTRING(obj) (R_CAST(RString)(obj))
//#define RREGEXP(obj) (R_CAST(RRegexp)(obj))
#define RARRAY(obj)  (R_CAST(RArray)(obj))
//#define RHASH(obj)   (R_CAST(RHash)(obj))
#define RDATA(obj)   (R_CAST(RData)(obj))
//#define RTYPEDDATA(obj)   (R_CAST(RTypedData)(obj))
//#define RSTRUCT(obj) (R_CAST(RStruct)(obj))
//#define RBIGNUM(obj) (R_CAST(RBignum)(obj))
//#define RFILE(obj)   (R_CAST(RFile)(obj))
//#define RRATIONAL(obj) (R_CAST(RRational)(obj))
//#define RCOMPLEX(obj) (R_CAST(RComplex)(obj))
//----------
#define DATA_PTR(dta) (RDATA(dta)->data)
//----------
#define RGSSBitmap(obj) ((RGSSBitmap*)DATA_PTR(obj))
#define RGSSBitmapInfo(obj) ((RGSSBitmapInfo*)(((RGSSBitmap*)DATA_PTR(obj)))->info)
//----------
#ifdef __cplusplus
}
#endif
//---------------
#endif // __VXACE_SDK_H__
//--------------------


