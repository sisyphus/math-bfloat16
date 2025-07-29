
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

#define TYPE_PRECISION 8
#define TYPE_EMIN -132
#define TYPE_EMAX 128

/* Bfloat16.pm sets emin and emax to the desired values so  *
 * we no longer need SET_EMIN_EMAX and RESET_EMIN_EMAX.     */
/*
#define SET_EMIN_EMAX \
  mpfr_prec_t emin = mpfr_get_emin(); \
  mpfr_prec_t emax = mpfr_get_emax(); \
  mpfr_set_emin(TYPE_EMIN);           \
  mpfr_set_emax(TYPE_EMAX);
*/
/*
#define RESET_EMIN_EMAX \
  mpfr_set_emin(emin); \
  mpfr_set_emax(emax);
*/

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
    if(strEQ(h, "Math::Bfloat16")) return newSVuv(20);
    croak("The Math::Bfloat16::_itsa XSub does not accept %s objects.", h);
  }
  croak("The Math::Bfloat16::_itsa XSub has been given an invalid argument (probably undefined)");
}

int is_bf16_nan(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, TYPE_PRECISION);

    mpfr_set_bfloat16(temp, *obj, MPFR_RNDN);
    ret = mpfr_nan_p(temp);
    mpfr_clear(temp);
    return ret;
}

int is_bf16_inf(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, TYPE_PRECISION);

    mpfr_set_bfloat16(temp, *obj, MPFR_RNDN);
    ret = mpfr_inf_p(temp);
    if(ret) {
      if(mpfr_signbit(temp)) ret = -1;
      else ret = 1;
    }
    mpfr_clear(temp);
    return ret;
}

int is_bf16_zero(__bf16 * obj) {
    int ret;
    mpfr_t temp;
    mpfr_init2(temp, TYPE_PRECISION);

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
  int inex;
  /* SET_EMIN_EMAX */

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromPV function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  inex = mpfr_strtofr(temp, SvPV_nolen(in), NULL, 0, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  /* RESET_EMIN_EMAX */
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
  int inex;
  /* SET_EMIN_EMAX */

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromGMPf function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  inex = mpfr_set_f(temp, *in, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  /* RESET_EMIN_EMAX */
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _fromGMPq(pTHX_ mpq_t * in) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;
  int inex;
  /* SET_EMIN_EMAX */

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _fromGMPq function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  inex = mpfr_set_q(temp, *in, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  /* RESET_EMIN_EMAX */
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * bf16_to_NV(pTHX_  __bf16 * obj) {
   return newSVnv(*obj);
}

SV * bf16_to_MPFR(pTHX_ __bf16 * f16_obj) {

  mpfr_t * mpfr_t_obj;
  SV * obj_ref, * obj;

  Newx(mpfr_t_obj, 1, mpfr_t);
  if(mpfr_t_obj == NULL) croak("Failed to allocate memory in bf16_to_MPFR function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::MPFR");

  mpfr_init2(*mpfr_t_obj, TYPE_PRECISION);
  mpfr_set_bfloat16(*mpfr_t_obj, *f16_obj, MPFR_RNDN);

  sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
  SvREADONLY_on(obj);
  return obj_ref;

}

void _bf16_set(__bf16 * a, __bf16 * b) {
  *a = *b;
}

void bf16_set_nan(__bf16 * a) {
  mpfr_t t;
  mpfr_init2(t, TYPE_PRECISION);

  *a = mpfr_get_bfloat16(t, MPFR_RNDN);
  mpfr_clear(t);
}

void bf16_set_inf(__bf16 * a, int is_pos) {
  mpfr_t t;
  mpfr_init2(t, TYPE_PRECISION);
  mpfr_set_inf(t, is_pos);

  *a = mpfr_get_bfloat16(t, MPFR_RNDN);
  mpfr_clear(t);
}

void bf16_set_zero(__bf16 * a, int is_pos) {
  mpfr_t t;
  mpfr_init2(t, TYPE_PRECISION);
  mpfr_set_zero(t, is_pos);

  *a = mpfr_get_bfloat16(t, MPFR_RNDN);
  mpfr_clear(t);
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

SV * _oload_pow(pTHX_ __bf16 * a, __bf16 * b, SV * third) {

  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t a0, b0;
  int inex;
  /* SET_EMIN_EMAX */

  mpfr_init2(a0, TYPE_PRECISION);
  mpfr_init2(b0, TYPE_PRECISION);

  mpfr_set_bfloat16(a0, *a, MPFR_RNDN);
  mpfr_set_bfloat16(b0, *b, MPFR_RNDN);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_pow function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  if(SvTRUE_nomg_NN(third)) inex = mpfr_pow(a0, b0, a0, MPFR_RNDN);  /* b ** a */
  else inex =  mpfr_pow(a0, a0, b0, MPFR_RNDN);                      /* a ** b */

  mpfr_subnormalize(a0, inex, MPFR_RNDN);

  *f_obj = mpfr_get_bfloat16(a0, MPFR_RNDN);
  /* RESET_EMIN_EMAX */

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
  if(is_bf16_nan(a) || is_bf16_nan(b)) return &PL_sv_undef;
  if(SvTRUE_nomg_NN(third)) {
    if(*b > *a) return newSViv(1);
    return newSViv(-1);
  }
  if(*a > *b) return newSViv(1);
  return newSViv(-1);
}

int _oload_not(__bf16 * a, SV * second, SV * third) {
  if(is_bf16_nan(a) || *a == 0) return 1;
  return 0;
}

int _oload_bool(__bf16 * a, SV * second, SV * third) {
  if(is_bf16_nan(a) || *a == 0) return 0;
  return 1;
}

SV * _oload_int(pTHX_ __bf16 * a, SV * second, SV * third) {
  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_int function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  mpfr_trunc(temp, temp); /* No need for mpfr_subnormalize */
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_log(pTHX_ __bf16 * a, SV * second, SV * third) {
  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;
  int inex;

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_log function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  inex = mpfr_log(temp, temp, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_exp(pTHX_ __bf16 * a, SV * second, SV * third) {
  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;
  int inex;

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_exp function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  inex = mpfr_exp(temp, temp, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

SV * _oload_sqrt(pTHX_ __bf16 * a, SV * second, SV * third) {
  __bf16 * f_obj;
  SV * obj_ref, * obj;
  mpfr_t temp;
  int inex;

  mpfr_init2(temp, TYPE_PRECISION);

  Newx(f_obj, 1, __bf16);
  if(f_obj == NULL) croak("Failed to allocate memory in _oload_sqrt function");
  obj_ref = newSV(0);
  obj = newSVrv(obj_ref, "Math::Bfloat16");

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  inex = mpfr_sqrt(temp, temp, MPFR_RNDN);
  mpfr_subnormalize(temp, inex, MPFR_RNDN);
  *f_obj = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);

  sv_setiv(obj, INT2PTR(IV,f_obj));
  SvREADONLY_on(obj);
  return obj_ref;
}

void unpack_bf16_hex(pTHX_ __bf16 * f) {
  dXSARGS;
  int i;
  char * buff;
  __bf16 bf16 = *f;
  void * p = &bf16;

  Newx(buff, 4, char);
  if(buff == NULL) croak("Failed to allocate memory in unpack_bf16_hex");

  sp = mark;

#ifdef WE_HAVE_BENDIAN /* Big Endian architecture */
  for (i = 0; i < 2; i++) {
#else
  for (i = 1; i >= 0; i--) {
#endif
    sprintf(buff, "%02X", ((unsigned char*)p)[i]);
    XPUSHs(sv_2mortal(newSVpv(buff, 0)));
  }
  PUTBACK;
  Safefree(buff);
  XSRETURN(2);
}

void _bf16_nextabove(__bf16 * a) {
  mpfr_t temp;
  mpfr_init2(temp, TYPE_PRECISION);

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  mpfr_nextabove(temp);
  /* mpfr_subnormalize(temp, -1, MPFR_RNDN); */
  *a = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);
}

void _bf16_nextbelow(__bf16 * a) {
  mpfr_t temp;
  mpfr_init2(temp, TYPE_PRECISION);

  mpfr_set_bfloat16(temp, *a, MPFR_RNDN);
  mpfr_nextbelow(temp);
  /* mpfr_subnormalize(temp, 1, MPFR_RNDN); */
  *a = mpfr_get_bfloat16(temp, MPFR_RNDN);
  mpfr_clear(temp);
}

SV * _XS_get_emin(pTHX) {
  return newSViv(mpfr_get_emin());
}

SV * _XS_get_emax(pTHX) {
  return newSViv(mpfr_get_emax());
}

void _XS_set_emin(pTHX_ SV * in) {
  mpfr_set_emin((mpfr_exp_t)SvIV(in));
}

void _XS_set_emax(pTHX_ SV * in) {
  mpfr_set_emax((mpfr_exp_t)SvIV(in));
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
is_bf16_nan (obj)
	__bf16 *	obj

int
is_bf16_inf (obj)
	__bf16 *	obj

int
is_bf16_zero (obj)
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
bf16_to_NV (obj)
	__bf16 *	obj
CODE:
  RETVAL = bf16_to_NV (aTHX_ obj);
OUTPUT:  RETVAL

SV *
bf16_to_MPFR (f16_obj)
	__bf16 *	f16_obj
CODE:
  RETVAL = bf16_to_MPFR (aTHX_ f16_obj);
OUTPUT:  RETVAL

void
_bf16_set (a, b)
	__bf16 *	a
	__bf16 *	b
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _bf16_set(a, b);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
bf16_set_nan (a)
	__bf16 *	a
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        bf16_set_nan(a);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
bf16_set_inf (a, is_pos)
	__bf16 *	a
	int	is_pos
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        bf16_set_inf(a, is_pos);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
bf16_set_zero (a, is_pos)
	__bf16 *	a
	int	is_pos
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        bf16_set_zero(a, is_pos);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

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

SV *
_oload_pow (a, b, third)
	__bf16 *	a
	__bf16 *	b
	SV *	third
CODE:
  RETVAL = _oload_pow (aTHX_ a, b, third);
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

int
_oload_not (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third

int
_oload_bool (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third

SV *
_oload_int (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = _oload_int (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
_oload_log (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = _oload_log (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
_oload_exp (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = _oload_exp (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
_oload_sqrt (a, second, third)
	__bf16 *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = _oload_sqrt (aTHX_ a, second, third);
OUTPUT:  RETVAL

void
unpack_bf16_hex (f)
	__bf16 *	f
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        unpack_bf16_hex(aTHX_ f);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
_bf16_nextabove (a)
	__bf16 *	a
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _bf16_nextabove(a);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
_bf16_nextbelow (a)
	__bf16 *	a
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _bf16_nextbelow(a);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

SV *
_XS_get_emin ()
CODE:
  RETVAL = _XS_get_emin (aTHX);
OUTPUT:  RETVAL


SV *
_XS_get_emax ()
CODE:
  RETVAL = _XS_get_emax (aTHX);
OUTPUT:  RETVAL


void
_XS_set_emin (in)
	SV *	in
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _XS_set_emin(aTHX_ in);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

void
_XS_set_emax (in)
	SV *	in
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _XS_set_emax(aTHX_ in);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return;

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

