/*
 *  libfb - FreeBASIC's runtime library
 *	Copyright (C) 2004-2005 Andre V. T. Vicentini (av1ctor@yahoo.com.br) and others.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * file_input - input function
 *
 * chng: nov/2004 written [v1ctor]
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "fb.h"
#include "fb_rterr.h"

FBCALL int fb_FileInput( int fnum );

/*:::::*/
FBCALL int fb_ConsoleInput( FBSTRING *text, int addquestion, int addnewline )
{
	FB_INPUTCTX *ctx;
	int res;

	fb_DevScrnInit_Read( );

	if( fb_IsRedirected( TRUE ) )
	{
		/* del if temp */
		fb_hStrDelTemp( text );

		return fb_FileInput( 0 );
	}

    ctx = FB_TLSGETCTX( INPUT );

	ctx->handle = 0;
	ctx->status = 0;
	ctx->index = 0;

	res = fb_LineInput( text, &ctx->str, -1, 0, addquestion, addnewline );

	return res;
}
