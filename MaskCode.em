//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================

//2014-09-26
macro __DoMask(hbuf, line, cmt)
{
	sz = GetBufLine(hbuf, line)
	szlen = strlen(sz)
	cmtLen = StrLen(cmt)

	//if blank, just return
	if (sz == "")
	{
		return Nil
	}

	//skip the blank char, like blank, tab...
	i = 0
	while (i<szLen && (sz[i]==" " || sz[i]=="	"))
	{
		i = i + 1
	}

	/*if (szLen >= cmtLen+i)
	{
		//If the line has been masked, just return
		if (strmid (sz, i, cmtLen+i) == cmt)
		{
			return
		}
	}*/

	SetBufIns (hbuf, line, i)
	SetBufSelText (hbuf, cmt)

	return Nil
}

//
// Unmask specified line, skip the blank line and un-masked line
//
macro __UnDoMask(hbuf, line, cmt)
{
	sz = GetBufLine(hbuf, line)
	szlen = strlen(sz)
	cmtLen = StrLen(cmt)

	i = 0
	while (i<szLen && (sz[i]==" " || sz[i]=="	"))
	{
		i = i + 1
	}

	//If the line has not been masked, just return
	if (szLen < cmtLen+i)
	{
		return Nil
	}
	else
	{
		if (strmid(sz, i, cmtLen+i) != cmt)
		{
			return Nil
		}
	}

	szBef = Strtrunc(sz, i)
	szAft = StrMid(sz, i+cmtLen, szLen)
	PutBufLine(hbuf, line, "@szBef@@szAft@")
}

//
// mask or unmasked selected line with corresponding characters
// if the first line is encountered mask line, the macro will do unmask;
// otherwise, if encountered ordinary line, the macro will do mask.
//
macro __Mask_UnMask()
{
    hwnd = GetCurrentWnd()
	sel = GetWndSel(hwnd)
	hbuf = GetWndBuf(hwnd)

	zfpath = GetBufName(hbuf)
	zfex = _GetFileNameExtension(zfpath)
	zfex = ".@zfex@"
	
	typeA = ".c;.cpp;.h"
	typeB = ".txt"
	typeC = ".pl;.min;.mak;.mk;.env"

	if (invalid !=_StrStr(typeA, zfex))
	{
		cmt = "//"
	}
	else if (invalid !=_StrStr(typeB, zfex))
	{
		cmt = ";"
	}
	else if (invalid !=_StrStr(typeC, zfex))
	{
		cmt = "#"
	}
	else
		stop

	cmtLen = StrLen(cmt)
	line = sel.lnFirst

	//to decide mask or 
	cmtFlg = True
	sz = GetBufLine(hbuf, line)
	szLen = StrLen(sz)
	i = 0
	while (i<szLen && (sz[i]==" " || sz[i]=="	"))
	{
		i = i + 1
	}

	if (szLen >= cmtLen+i)
	{
		if (strmid (sz, i, cmtLen+i) == cmt)
			cmtFlg = False
	}

	// mask and unmask
	if (cmtFlg)
	{
		//mask
		while (line <= sel.lnLast)
		{
			__DoMask(hbuf, line, cmt)
			line = line + 1
		}
	}
	else
	{
		//remove mask chars	
		while (line <= sel.lnLast)
		{
			__UnDoMask(hbuf, line, cmt)
			line = line + 1
		}
	}

	return Nil
}

macro Mask_UnMask()
{
	_CheckIfPubEmExistsAndSWVersionRequirement()
	__Mask_UnMask()
    _LogShow()
    return Nil
}
