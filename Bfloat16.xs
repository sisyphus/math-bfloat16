
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define MPFR_WANT_BFLOAT16 1
#include <mpfr.h>

SV * _itsa(pTHX_ SV * a) {
  if(SvIOK(a)) {
    return newSVuv(2);               /* IV */
  }
  if(SvPOK(a)) {
    return newSVuv(4);               /* PV */
  }
  if(SvNOK(a)) return newSVuv(3);    /* NV */
  if(sv_isobject(a)) {
    const char* h = HvNAME(SvSTASH(SvRV(a)));

    if(strEQ(h, "Math::MPFR")) return newSVuv(5);
    if(strEQ(h, "Math::GMPf")) return newSVuv(6);
    if(strEQ(h, "Math::GMPq")) return newSVuv(7);
    if(strEQ(h, "Math::GMPz")) return newSVuv(8);
    if(strEQ(h, "Math::GMP")) return newSVuv(9);

    if(strEQ(h, "Math::Bfloat16")) return newSVuv(20);
    if(strEQ(h, "Math::Float16")) return newSVuv(21);
    if(strEQ(h, "Math::Float32")) return newSVuv(22);
  }
  return newSVuv(0);
}

int is_nan(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, 8);

    mpfr_set_bfloat16(temp, *obj, MPFR_RNDN);
    ret = mpfr_nan_p(temp);
    mpfr_clear(temp);
    return ret;
}

int is_inf(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, 8);

    mpfr_set_bfloat16(temp, *obj, MPFR_RNDN);
    ret = mpfr_inf_p(temp);
    if(ret) {
      if(mpfr_signbit(temp)) ret = -1;
      else ret = 1;
    }
    mpfr_clear(temp);
    return ret;
}

int is_zero(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, 8);

    mpfr_set_bfloat16(temp, *obj, MPFR_RNDN);
    ret = mpfr_zero_p(temp);
    if(ret) {
      if(mpfr_signbit(temp)) ret = -1;
      else ret = 1;
    }
    mpfr_clear(temp);
    return ret;
}


SV * _fromBfloat16(pTHX_ __bf16 * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromNV function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  *f_obj = *in;

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromNV(pTHX_ SV * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromNV function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  *f_obj = (__bf16)SvNV(in);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromIV(pTHX_ SV * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromIV function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  if(SvUOK(in)) *f_obj = (__bf16)SvUV(in);
  else *f_obj = (__bf16)SvIV(in);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromPV(pTHX_ SV * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;

  mpfr_init2(temp, 8);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromPV function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_strtofr(temp, SvPV_nolen(in), NULL, 0, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromMPFR(pTHX_ mpfr_t * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromMPFR function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  *f_obj = mpfr_get_bfloat16(*in, MPFR_RNDN);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromGMPf(pTHX_ mpf_t * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;

  mpfr_init2(temp, 8);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromGMPf function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_f(temp, *in, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromGMPq(pTHX_ mpq_t * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;

  mpfr_init2(temp, 8);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromGMPq function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_q(temp, *in, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * toNV(pTHX_  __bf16 * obj) {
   return newSVnv(*obj);
}

SV * toMPFR(pTHX_ __bf16 * f16_obj) {

  mpfr_t * mpfr_t_obj;
  SV * obj_ref, * obj;

  Newx(mpfr_t_obj, 1, mpfr_t);
  if(mpfr_t_obj == NULL) croak("Failed to allocate memory in toMPFR function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::MPFR");

  mpfr_init2(*mpfr_t_obj, 8);
  mpfr_set_bfloat16(*mpfr_t_obj, *f16_obj, MPFR_RNDN);

  sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
  SvREADONLY_on(obj);
  return obj_ref;

}

SV * _oload_add(pTHX_ __bf16 * a, __bf16 * b, SV * third) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_add function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  *f_obj = *a + *b;

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_sub(pTHX_ __bf16 * a, __bf16 * b, SV * third) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_sub function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  if(SvTRUE_nomg_NN(third)) *f_obj = *b - *a;
  else *f_obj = *a - *b;

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_mul(pTHX_ __bf16 * a, __bf16 * b, SV * third) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_mul function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  *f_obj = *a * *b;

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_div(pTHX_ __bf16 * a, __bf16 * b, SV * third) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_div function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  if(SvTRUE_nomg_NN(third)) *f_obj = *b / *a;
  else *f_obj = *a / *b;

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

int _oload_equiv(__bf16 * a, __bf16 * b, SV * third) {
  if(*a == *b) return 1;
  return 0;
}

int _oload_not_equiv(__bf16 * a, __bf16 * b, SV * third) {
  if(*a != *b) return 1;
  return 0;
}

int _oload_gt(pTHX_ __bf16 * a, __bf16 * b, SV * third) {
  if(SvTRUE_nomg_NN(third)) {
    if(*b > *a) return 1;
    return 0;
  }
  if(*a > *b) return 1;
  return 0;
}

int _oload_gte(pTHX_ __bf16 * a, __bf16 * b, SV * third) {
  if(SvTRUE_nomg_NN(third)) {
    if(*b >= *a) return 1;
    return 0;
  }
  if(*a >= *b) return 1;
  return 0;
}

int _oload_lt(pTHX_ __bf16 * a, __bf16 * b, SV * third) {
  if(SvTRUE_nomg_NN(third)) {
    if(*b < *a) return 1;
    return 0;
  }
  if(*a < *b) return 1;
  return 0;
}

int _oload_lte(pTHX_ __bf16 * a, __bf16 * b, SV * third) {
  if(SvTRUE_nomg_NN(third)) {
    if(*b <= *a) return 1;
    return 0;
  }
  if(*a <= *b) return 1;
  return 0;
}

SV * _oload_spaceship(pTHX_ __bf16 * a, __bf16 * b, SV * third) {
  if(*a == *b) return newSViv(0);
  if(is_nan(a) || is_nan(b)) return &PL_sv_undef;
  if(SvTRUE_nomg_NN(third)) {
    if(*b > *a) return newSViv(1);
    return newSViv(-1);
  }
  if(*a > *b) return newSViv(1);
  return newSViv(-1);
}

void DESTROY(SV * obj) {
  /* printf("Destroying object\n"); *//* debugging check */
  Safefree(INT2PTR(__bf16 *, SvIVX(SvRV(obj))));
}





MODULE = Math::Bfloat16  PACKAGE = Math::Bfloat16

PROTOTYPES: DISABLE


SV *
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

int
is_nan (obj)
	__bf16 *	obj

int
is_inf (obj)
	__bf16 *	obj

int
is_zero (obj)
	__bf16 *	obj

SV *
_fromBfloat16 (in)
	__bf16 *	in
CODE:
  RETVAL = _fromBfloat16 (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromNV (in)
	SV *	in
CODE:
  RETVAL = _fromNV (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromIV (in)
	SV *	in
CODE:
  RETVAL = _fromIV (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromPV (in)
	SV *	in
CODE:
  RETVAL = _fromPV (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromMPFR (in)
	mpfr_t *	in
CODE:
  RETVAL = _fromMPFR (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromGMPf (in)
	mpf_t *	in
CODE:
  RETVAL = _fromGMPf (aTHX_ in);
OUTPUT:  RETVAL

SV *
_fromGMPq (in)
	mpq_t *	in
CODE:
  RETVAL = _fromGMPq (aTHX_ in);
OUTPUT:  RETVAL

SV *
toNV (obj)
	__bf16 *	obj
CODE:
  RETVAL = toNV (aTHX_ obj);
OUTPUT:  RETVAL

SV *
toMPFR (f16_obj)
	__bf16 *	f16_obj
CODE:
  RETVAL = toMPFR (aTHX_ f16_obj);
OUTPUT:  RETVAL

SV *
_oload_add (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_oload_sub (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_oload_mul (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_oload_div (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

int
_oload_equiv (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third

int
_oload_not_equiv (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third

int
_oload_gt (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

int
_oload_gte (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

int
_oload_lt (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

int
_oload_lte (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_oload_spaceship (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_spaceship (aTHX_ a, b, third);
OUTPUT:  RETVAL

void
DESTROY (obj)
	SV *	obj
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        DESTROY(obj);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

