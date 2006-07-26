#ifndef __FILE_BI__
#define __FILE_BI__

#ifdef __FB_MT__
# if __FB_MT__
#  inclib "fbxmt"
# else
#  inclib "fbx"
# endif
#else
# inclib "fbx"
#endif

const fbFileAttrMode     = 1
const fbFileAttrHandle   = 2
const fbFileAttrEncoding = 3

const fbFileModeInput    = 1
const fbFileModeOutput   = 2
const fbFileModeRandom   = 4
const fbFileModeAppend   = 8
const fbFileModeBinary   = 32

const fbFileEncodASCII   = 0
const fbFileEncodUTF8    = 1
const fbFileEncodUTF16   = 2
const fbFileEncodUTF32   = 3

declare function FileCopy alias "fb_FileCopy" ( byval source as zstring ptr, byval destination as zstring ptr ) as integer
declare function FileAttr alias "fb_FileAttr" ( byval handle as integer, byval returntype as integer = 1 ) as integer
declare function FileLen alias "fb_FileLen" ( byval filename as zstring ptr ) as integer
declare function FileExists alias "fb_FileExists" ( byval filename as zstring ptr ) as integer
declare function FileDateTime alias "fb_FileDateTime" ( byval filename as zstring ptr ) as double

#endif
