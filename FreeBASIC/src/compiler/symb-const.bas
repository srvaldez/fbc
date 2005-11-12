''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


'' symbol table module for constants
''
'' chng: sep/2004 written [v1ctor]
''		 jan/2005 updated to use real linked-lists [v1ctor]

option explicit
option escape

#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\hash.bi"
#include once "inc\list.bi"
#include once "inc\ir.bi"

'':::::
function symbAddConst( byval symbol as zstring ptr, _
					   byval typ as integer, _
					   byval subtype as FBSYMBOL ptr, _
					   byval value as FBVALUE ptr _
					 ) as FBSYMBOL ptr static

    dim as FBSYMBOL ptr c

    function = NULL

    c = symbNewSymbol( NULL, iif( typ = FB_SYMBTYPE_ENUM, @subtype->enum.elmtb, symb.symtb ), _
    				   FB_SYMBCLASS_CONST, TRUE, _
    				   symbol, NULL, _
    				   fbIsLocal( ), typ, subtype )
	if( c = NULL ) then
		exit function
	end if

	c->con.val = *value

	function = c

end function

'':::::
function symbAllocFloatConst( byval value as double, _
						   	  byval typ as integer _
						 	) as FBSYMBOL ptr static

    static as zstring * FB_MAXINTNAMELEN+1 cname, aname
	dim as FBSYMBOL ptr s
	dim as FBARRAYDIM dTB(0)
	dim as string svalue

	function = NULL

	'' can't use STR() because GAS doesn't support the 1.#INF notation
	svalue = hFloatToStr( value, typ )

	cname = "{fbnc}"
	cname += svalue

	s = symbFindByNameAndSuffix( @cname, typ, FALSE )
	if( s <> NULL ) then
		return s
	end if

	aname = *hMakeTmpStr( FALSE )

	'' it must be declare as SHARED, because even if currently inside an
	'' proc, the global symbol tb should be used, so just one constant
	'' will be ever allocated over the module
	s = symbAddVarEx( @cname, @aname, typ, NULL, 0, 0, 0, dTB(), _
					  FB_ALLOCTYPE_SHARED, TRUE, FALSE, FALSE )

	''
	s->var.initialized = TRUE

	s->var.inittext = ZstrAllocate( len( svalue ) )
	*s->var.inittext = svalue

	function = s

end function

'':::::
function symbAllocStrConst( byval sname as zstring ptr, _
							byval lgt as integer _
						  ) as FBSYMBOL ptr static

    static as zstring * FB_MAXINTNAMELEN+1 cname, aname
	dim as FBSYMBOL ptr s
	dim as FBARRAYDIM dTB(0)
	dim as integer strlen

	function = NULL

	'' the lgt passed isn't the real one because it doesn't
	'' take into acount the escape characters
	strlen = len( *sname )
	if( lgt < 0 ) then
		lgt = strlen
	end if

	if( strlen <= FB_MAXNAMELEN-6 ) then
		cname = "{fbsc}"
		cname += *sname
	else
		cname = *hMakeTmpStr( FALSE )
	end if

	''
	s = symbFindByNameAndClass( @cname, FB_SYMBCLASS_VAR, TRUE )
	if( s <> NULL ) then
		return s
	end if

	aname = *hMakeTmpStr( FALSE )

	'' lgt += the null-char (rtlib wrappers will take it into account)

	'' it must be declare as SHARED, see symbAllocFloatConst()
	s = symbAddVarEx( @cname, @aname, FB_SYMBTYPE_CHAR, NULL, _
					  0, lgt + 1, 0, dTB(), _
					  FB_ALLOCTYPE_SHARED, FALSE, TRUE, FALSE )

	''
	s->var.initialized = TRUE

	s->var.inittext = ZstrAllocate( strlen )
	*s->var.inittext = *sname

	function = s

end function

'':::::
function symbAllocWStrConst( byval sname as wstring ptr, _
						  	 byval lgt as integer _
						   ) as FBSYMBOL ptr static

    static as zstring * FB_MAXINTNAMELEN+1 cname, aname
	dim as FBSYMBOL ptr s
	dim as FBARRAYDIM dTB(0)
	dim as integer strlen

	function = NULL

	'' the lgt passed isn't the real one because it doesn't
	'' take into acount the escape characters
	strlen = len( *sname )
	if( lgt < 0 ) then
		lgt = strlen
	end if

	'' hEscapeWstr() can use up to 4 chars p/ unicode char (\ooo)
	if( strlen * (3+1) <= FB_MAXNAMELEN-6 ) then
		cname = "{fbwc}"
		cname += *hEscapeWstr( sname )
	else
		cname = *hMakeTmpStr( FALSE )
	end if

	''
	s = symbFindByNameAndClass( @cname, FB_SYMBCLASS_VAR, TRUE )
	if( s <> NULL ) then
		return s
	end if

	aname = *hMakeTmpStr( FALSE )

	'' lgt = (lgt + null-char) * sizeof( wstring ) (see parser-decl-symbinit.bas)
	'' it must be declare as SHARED, see symbAllocFloatConst()
	s = symbAddVarEx( @cname, @aname, FB_SYMBTYPE_WCHAR, NULL, _
					  0, (lgt+1) * len( wstring ), 0, dTB(), _
					  FB_ALLOCTYPE_SHARED, FALSE, TRUE, FALSE )

	''
	s->var.initialized = TRUE

	s->var.inittextw = WstrAllocate( strlen )
	*s->var.inittextw = *sname

	function = s

end function

'':::::
sub symbDelConst( byval s as FBSYMBOL ptr, _
				  byval dolookup as integer )

    if( dolookup ) then
    	s = symbFindByClass( s, FB_SYMBCLASS_CONST )
    end if

    if( s = NULL ) then
    	exit sub
    end if

    '' if it's a string, the symbol attached will be deleted be delVar()

	symbFreeSymbol( s )

end sub

'':::::
function symbGetConstValueAsStr( byval s as FBSYMBOL ptr ) as string

  	select case as const symbGetType( s )
  	case IR_DATATYPE_STRING, IR_DATATYPE_FIXSTR, IR_DATATYPE_CHAR
  		function = *symbGetConstValStr( s )->var.inittext

  	case IR_DATATYPE_LONGINT
  		function = str( symbGetConstValLong( s ) )

  	case IR_DATATYPE_ULONGINT
  	    function = str( cunsg( symbGetConstValLong( s ) ) )

  	case IR_DATATYPE_SINGLE, IR_DATATYPE_DOUBLE
  		function = str( symbGetConstValFloat( s ) )

  	case IR_DATATYPE_UBYTE, IR_DATATYPE_USHORT, IR_DATATYPE_UINT
  		function = str( cunsg( symbGetConstValInt( s ) ) )

  	case else
  		function = str( symbGetConstValInt( s ) )
  	end select

end function

