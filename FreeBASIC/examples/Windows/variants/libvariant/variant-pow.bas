

#define VARIANT_NOASSIGNMENT
#include once "variant.bi"
#include once "intern.bi"

VAR_GEN_BOP( ^, VarPow, integer, I4 )
VAR_GEN_BOP( ^, VarPow, uinteger, UI4 )
VAR_GEN_BOP( ^, VarPow, longint, I8 )
VAR_GEN_BOP( ^, VarPow, ulongint, UI8 )
VAR_GEN_BOP( ^, VarPow, single, R4 )
VAR_GEN_BOP( ^, VarPow, double, R8 )

'':::::
operator ^ _
	( _
		byref lhs as CVariant, _
		byref rhs as CVariant _
	) as CVariant
	
	dim as VARIANT res = any
	
	VarPow( @lhs.var, @rhs.var, @res )
	
	return CVariant( res, FALSE )
	
end operator

'':::::
operator ^ _
	( _
		byref lhs as CVariant, _
		byref rhs as VARIANT _
	) as CVariant
	
	dim as VARIANT res = any
	
	VarPow( @lhs.var, @rhs, @res )
	
	return CVariant( res, FALSE )
	
end operator

