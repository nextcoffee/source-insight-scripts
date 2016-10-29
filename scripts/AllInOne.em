//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================

/////////////////////////////////////////////////////////////// insert_define.em /////////////////////////////////////////////////////////////

//
// #if defined(XXX)...#endif
//
macro InsertIfdef(sz)
{
    hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#if defined(@sz@)")
	InsBufLine(hbuf, lnLast+2, "#endif /*@sz@*/")

	if (lnFirst==lnLast )
	{
		SetBufIns (hbuf, lnFirst+1, 0)
		//RunCmd ("Simple Tab")
	}

	return Nil
}

// 使用先前保存的宏定义字串
macro InsertIfdef_OldStr()
{
	sz = GetReg(define_sz)
	if (sz == Nil)
	{
		InsertIfdef_NewStr()
	}
	else
	{
		InsertIfdef(sz);
	}

	return Nil
}

//更新宏定义字串
macro InsertIfdef_NewStr()
{
    sz = Ask("Enter ifdef condition:")
    if (sz == Nil)
		stop

    SetReg(define_sz, sz)
	InsertIfdef(sz);

	return Nil
}


/////////////////////////////////////////////////////////////// insert_func_header.em /////////////////////////////////////////////////////////////
//
//
//
macro RegExReplaceInBuf(hbuf, oldPattern, newPattern)
{
	fMatchCase = False
	fRegExp = True
	fWholeWordsOnly = False
	fConfirm = False

	lnStart = 0
	lnLim = GetBufLineCount (hbuf)

	return ReplaceInBuf(hbuf, oldPattern, newPattern, lnStart, lnLim, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
}

macro ParseFuncPara(sz)
{
	// int a
	// int a[]
	// unsigned int a
	// unsigned int a[]
	oldPattern = "^\\w*\\([0-9A-Za-z_]+.*\\)\\([0-9A-Za-z_]+\\)\\([\\[\\]]*\\)$"
	newPattern = "Type=\"\\1\\3\";Name=\"\\2\""
	recRet = _ReplaceInStr(sz, oldPattern, newPattern, False, True, False, False)
	if (1 == recRet.fSuccess)
		return recRet.szData

	// int (*pfunc)(...)
	// int (*pfunc[])(...)
	oldPattern = "^\\w*\\([0-9A-Za-z_]+.*\\)\\((.*\\)\\([0-9A-Za-z_]+\\)\\(.*)\\)\\(.*\\)$"
	newPattern = "Type=\"\\1\\2\\4\\5\";Name=\"\\3\""
	recRet = _ReplaceInStr(sz, oldPattern, newPattern, False, True, False, False)
	if (1 == recRet.fSuccess)
		return recRet.szData

	return Nil
}

macro MultiLineToOneLine(hbuf, lnStart, lnLim)
{
	ln = lnStart
	sz = ""
	while (ln < lnLim)
	{
		szTmp = GetBufLine(hbuf, ln)
		sz = Cat(sz, szTmp)
		ln = ln + 1
	}
	return sz
}

macro GetFuncSymLoc(ln)
{
	var hbuf
	var loc

	_ASSERT(IsNumber(ln) == True)

	hbuf = GetCurrentBuf()
	loc = GetSymbolLocationFromLn(hbuf, ln)
	if(loc == Nil)
	{
		Msg "No valid symbol"
		return Nil
	}
	if ("Function" == loc.Type || "Function Prototype" == loc.Type)
		return loc

	return Nil
}

// save return type at the first line, that parameters followed.
macro GetFuncElements(loc)
{
	hbuf = GetCurrentBuf()
	fnCur = GetBufName (hbuf)
	symCur = loc.Symbol
	hwnd = GetCurrentWnd()

	if ("Function" != loc.Type && "Function Prototype" != loc.Type)
	{
		Msg "No Valid Function Found"
		//_ASSERT(0)
		stop
	}

	if (fnCur != loc.File)
	{
		hbuf = OpenBuf(loc.File)
		if (hNil == hbuf)
		{
			Msg "Can not open file: @loc.File@"
			stop
		}
	}

	//copy to tmp buffer
	rondom = _UniNum()
	hDirtyBuf = NewBuf("@rondom@")

	ln = loc.lnFirst
	while (ln < loc.lnLim)
	{
		sz = GetBufLine(hbuf, ln)
		ich = _StrStr(sz, "{")
		if (invalid != ich)
		{
			sz = strtrunc(sz, ich)
			AppendBufLine(hDirtyBuf, sz)
			break
		}

		AppendBufLine(hDirtyBuf, sz)
		ln = ln + 1
	}

	//----------------------------------------
	//cut off code body
	//----------------------------------------
	RegExReplaceInBuf(hDirtyBuf, "^[^{]+\\(/\\*.*\\*/\\)", Nil)

	//----------------------------------------
	//cut off comment string in parameter list
	//----------------------------------------
	//for ("/\\*.*\\*/")
	//RegExReplaceInBuf(hDirtyBuf, "\\(/\\*.*\\*/\\)", Nil)

	//for ("//.*$")
	RegExReplaceInBuf(hDirtyBuf, "\\(//.*$\\)", Nil)

	//for ("#if...#endif")
	RegExReplaceInBuf(hDirtyBuf, "\\w*#.*$", Nil)

	//----------------------------------------
	//one line only operation
	//----------------------------------------
	//construct the multi-line to one line only
	lnLim = GetBufLineCount (hDirtyBuf)
	sz = MultiLineToOneLine(hDirtyBuf, 0, lnLim)
	sz = _StrCls(sz)
	_LogI(sz)
	//refresh the file with one-line string
	ClearBuf(hDirtyBuf)
	AppendBufLine(hDirtyBuf, sz)

	//cut off comment block in parameter list
	//for ("/\\*.*\\*/")
	RegExReplaceInBuf(hDirtyBuf, "\\(/\\*.*\\*/\\)", Nil)

	//cut off last ';'
	RegExReplaceInBuf(hDirtyBuf, "\\w*;\\w*$", Nil)

	//cut off last '='
	RegExReplaceInBuf(hDirtyBuf, "\\w*=.*$", Nil)

	// cut off superfluous blank chars in parameter list string
	RegExReplaceInBuf(hDirtyBuf, "\\w\\w+", " ")

	//----------------------------------------
	//get return type
	//----------------------------------------
	//cut off symbol
	RegExReplaceInBuf(hDirtyBuf, "\\w*@symCur@\\w*", Nil)

	//get return type string
	sz = GetBufLine(hDirtyBuf, 0)
	sz = _GetStrByIndex(sz, 0, "(")
	if (sz != Nil)
		szRetType = sz.szData
	else
		szRetType = Nil

	//cut off static
	sz = _ReplaceInStr(szRetType, "\\(static\\)", Nil, False, True, False, False)
	szRetType = sz.szData

	//chomp
	szRetType = _StrCls(szRetType)
	_LogI(szRetType)

	//----------------------------------------
	//get parameter list
	//----------------------------------------
	//get clear parameter string - cut off the string before "(" or after ")"
	//and the blank string just after "(" or before ")"
	oldPattern = "^.*(\\w*\\([^\\t\\s].*[^\\t\\s]\\)\\w*)[^)]*$"
	newPattern = "\\1"
	RegExReplaceInBuf(hDirtyBuf, oldPattern, newPattern)
	//_Assert(False)

	//trans the one-line string into multi-line with "," as the delims
	sz = GetBufLine(hDirtyBuf, 0)
	_LogI(sz)
	while(True)
	{
		//no "," so no need to trans to multi-line
		ich = _StrStr(sz, ",")
		if (invalid == ich)
		{
			//last parameter
			szTmp = ParseFuncPara(sz)
			if (Nil != szTmp)
				AppendBufLine(hDirtyBuf, szTmp)
			_LogV(szTmp)
			break
		}

		szTmp = ParseFuncPara(strtrunc(sz, ich))
		if (Nil != szTmp)
			AppendBufLine(hDirtyBuf, szTmp)
		_LogV(szTmp)
		sz = StrMid(sz, ich+1, StrLen(sz))
	}
	DelBufLine (hDirtyBuf, 0)

	InsBufLine (hDirtyBuf, 0, szRetType)

	////construct parameter structure
	//oldPattern = "\\w*\\([^\\t\\s].+[^a-zA-Z0-9_]+\\)\\([a-zA-Z0-9_\\[\\]]+\\)\\([^\t\s]*\\)\\w*$"
	//newPattern = "Type=\"\\1\\3\";Name=\"\\2\""
	//ret = RegExReplaceInBuf(hDirtyBuf, oldPattern, newPattern)

	////del the invalid parameter structure string
	//ln = 0
	//lnLim = GetBufLineCount (hDirtyBuf)
	//if (ret < lnLim)
	//{
	//	ln = 0
	//	while (ln < lnLim)
	//	{
	//		sz = GetBufLine(hDirtyBuf, ln)
	//		if (invalid == _StrStr(sz, "="))
	//			DelBufLine(hDirtyBuf, ln)
	//		ln = ln + 1
	//	}
	//}

	return hDirtyBuf
}

/*****************************************************************************
* Function:  InsertFuncHeader
* Purpose:
* Params:
*
*   Name                    Type                In/Out              Description
*   -----                   ----                ------              ----------
*
* Return:  (0) success; (-1) failure
* Note:
*******************************************************************************/
macro InsFuncHeader_Normal(ln)
{
    var szMyName
	var hbuf
	var loc
	var szFunc
	var hDirtyBuf
	var lnCnt
	var i
	var para
	var sz
	var szRetType
	var szParaName
	var szParaType
	var paraLnFirst
	var paraLnLast

	szMyName = getenv(USERNAME)
	hbuf = GetCurrentBuf()
	loc = GetFuncSymLoc(ln)
	if (loc == Nil)
		stop
	szFunc = loc.Symbol

	hDirtyBuf = GetFuncElements(loc)

	InsBufLine(hbuf, ln++, "/*****************************************************************************")
	InsBufLine(hbuf, ln++, "* Function:  @szFunc@")
	InsBufLine(hbuf, ln++, "* Purpose:   ")
	InsBufLine(hbuf, ln++, "* Author:    @szMyName@")

	lnCnt = GetBufLineCount(hDirtyBuf)
	if (lnCnt > 1)
		InsBufLine(hbuf, ln++, "* Params:")

	i = 1
	paraLnFirst = ln
	while (i < lnCnt)
	{
		para = GetBufLine(hDirtyBuf, i)
		szParaName = para.Name
		szParaType = para.Type
		sz = "*     @szParaName@    [IN]    "
		InsBufLine(hbuf, ln++, sz)
		i++
	}
	paraLnLast = ln-1
	TableFormatInner("[^\\t\\s]+", paraLnFirst, paraLnLast)

	szRetType = GetBufLine(hDirtyBuf, 0)
	DelBufLine(hDirtyBuf, 0)

	//InsBufLine(hbuf, ln++, "* ")
	if (szRetType == "void")
	{
		//InsBufLine(hbuf, ln++, "* Return:    void")
	}
	else
	{
		InsBufLine(hbuf, ln++, "* Return:    (@szRetType@)")
	}

	InsBufLine(hbuf, ln++, "*******************************************************************************/")

	// put the insertion point inside the header comment
	//SetBufIns(hbuf, ln, 4)

	SetBufDirty(hDirtyBuf, FALSE)
	CloseBuf(hDirtyBuf)

	return Nil
}

/**
 *
 *
 *  @param[in]
 *      channel_id
 *  @param[in]
 *      buffer
 *  @param[in]
 *      length
 *  @param[in]
 *      stuff
 *  @return
 *
 *  @header{"simcom_adapter_at_mode.c"}
 */
macro InsFuncHeader_Doxy(sel)
{
    //szMyName = getenv(USERNAME)
	var fnCur
	var hbuf
	var loc
	var szFunc
	var ln
	var hDirtyBuf
	var lnCnt
	var i
	var blnk
	var para
	var sz
	var szRetType
	var szParaName
	var szFileShortName
	var pattern
	var recRet

	var bEnaBrief

	bEnaBrief = False

    hbuf = GetCurrentBuf()
	fnCur = GetBufName (hbuf)
	loc = GetCurSymLoc()
	szFunc = loc.Symbol
	ln = sel.lnFirst

	hDirtyBuf = GetFuncElements(loc)

	// begin assembling the title string
	if (bEnaBrief)
	{
		InsBufLine(hbuf, ln++, "/** @@brief ")
		InsBufLine(hbuf, ln++, " *")
	}
	else
	{
		InsBufLine(hbuf, ln++, "/** ")
	}
	InsBufLine(hbuf, ln++, " *  ")
	InsBufLine(hbuf, ln++, " *")

	lnCnt = GetBufLineCount(hDirtyBuf)
	i = 1
	while (i < lnCnt)
	{
		InsBufLine(hbuf, ln++, " *  @@param[in]")

		para = GetBufLine(hDirtyBuf, i)
		szParaName = para.Name
		sz = " *      @szParaName@    "
		InsBufLine(hbuf, ln++, sz)
		i++
	}

	szRetType = GetBufLine(hDirtyBuf, 0)
	DelBufLine(hDirtyBuf, 0)

	if (szRetType != "void")
	{
		if (szRetType == "eat_bool")
		{
			InsBufLine(hbuf, ln++, " *  @@return")
			InsBufLine(hbuf, ln++, " *      EAT_TRUE if success, otherwise EAT_FALSE.")
		}
		else
		{
			InsBufLine(hbuf, ln++, " *  @@return")
			InsBufLine(hbuf, ln++, " *      ")
		}
	}

	pattern = "\\\\"
	recRet = _GetStrByIndex(fnCur, _GetStrCount(fnCur, pattern)-1, pattern)
	szFileShortName = recRet.szData
	InsBufLine(hbuf, ln++, " *  @@header{\"@szFileShortName@\"}")
	InsBufLine(hbuf, ln++, " */")

	// put the insertion point inside the header comment
	//SetBufIns(hbuf, ln, 4)

	SetBufDirty(hDirtyBuf, FALSE)
	CloseBuf(hDirtyBuf)

	return Nil
}

/**
 * @defgroup UART_func UART Function
 * @{
 */
 /** @} end of UART_func */
macro InsGroup_Doxy(sel)
{
	var hbuf
	var lnFirst var lnLast
	var ret

	hbuf = GetCurrentBuf()
	lnFirst = sel.lnFirst
	lnLast = sel.lnLast

	ret = Ask("Input group name:")

	InsBufLine(hbuf, lnLast+1, "/** @@} end of @ret@ */")

	InsBufLine(hbuf, lnFirst, " */")
	InsBufLine(hbuf, lnFirst, " *  @@{")
	InsBufLine(hbuf, lnFirst, " *  @@defgroup @ret@ NO_TITLE")
	InsBufLine(hbuf, lnFirst, "/**")
}

macro InsCommentBlk_Doxy(sel)
{
	var hbuf
	var lnFirst

	hbuf = GetCurrentBuf()
	lnFirst = sel.lnFirst

	PutBufLine(hbuf, lnFirst, " */")
	InsBufLine(hbuf, lnFirst, " *  ")
	InsBufLine(hbuf, lnFirst, "/** ")
	SetBufIns(hbuf, lnFirst+1, 4)
}

macro InsCommentLn_Doxy(sel)
{
	var hbuf
	var lnFirst

	hbuf = GetCurrentBuf()
	lnFirst = sel.lnFirst

	InsBufLine(hbuf, lnFirst, "/**  */")
	SetBufIns(hbuf, lnFirst, 4)
}

macro AppendCommentLn_Doxy(sel)
{
	var hbuf
	var lnFirst
	var ichFirst

	hbuf = GetCurrentBuf()
	lnFirst = sel.lnFirst
	ichFirst = sel.ichFirst

	SetBufSelText (hbuf, "/**<  */")
	SetBufIns(hbuf, lnFirst, ichFirst+5)
}

macro ReplaceRegularCmt_Doxy(sel)
{
	var hbuf
	var ln
	var ret

	hbuf = GetCurrentBuf()

	if (sel.lnFirst != sel.lnLast)
	{
		Msg "Not support multiline yet!"
		stop
	}

	ln = sel.lnFirst
	ret = GetBufSelText(hbuf)

	//cut off "/*" and "*/"
	ret = _ReplaceInStr(ret, "^\\w*/\\*\\w*\\(.*\\)\\w*\\*/\\w*$", "\\1", False, True, False, False)
	ret = ret.szData

	//cut off "//"
	ret = _ReplaceInStr(ret, "^\\w*//\\w*\\(.*\\)\\w*$", "\\1", False, True, False, False)
	ret = ret.szData

	SetBufSelText (hbuf, "/**< @ret@ */")
}

macro InsDoxygenDoc()
{
	var sel

	sel = _GetCurSelEx()
	if (sel.type == "WLNS")
		InsFuncHeader_Doxy(sel.sel)
	else if (sel.type == "TLS")
		InsGroup_Doxy(sel.sel)
	else if (sel.type == "ELNS")
		InsCommentBlk_Doxy(sel.sel)
	else if (sel.type == "BLNS")
		InsCommentLn_Doxy(sel.sel)
	else if (sel.type == "ALNS")
		AppendCommentLn_Doxy(sel.sel)
	else if (sel.type == "WLS")
		ReplaceRegularCmt_Doxy(sel.sel)
	else
		_Assert(False)

	return Nil
}

macro InsNormal()
{
	var sel
	var sele
	var ln

	sele = _GetCurSelEx()
	if (sele.type == "WLNS")
	{
		sel = sele.sel
		ln = sel.lnFirst
		InsFuncHeader_Normal(ln)
	}
	else
		_Assert(False)

	return Nil
}

macro InsComment()
{
	InsNormal()

	return Nil
}


/////////////////////////////////////////////////////////////// leo.em /////////////////////////////////////////////////////////////

//
// extern "C"
//
macro IfdefCpp()
{
    hwnd = GetCurrentWnd()
	sel = GetWndSel(hwnd)
	hbuf = GetWndBuf(hwnd)

	lnFirst = sel.lnFirst
	lnLast = sel.lnLast

	InsBufLine(hbuf, lnLast+1, "#endif")
	InsBufLine(hbuf, lnLast+1, "}")
	InsBufLine(hbuf, lnLast+1, "#ifdef	__cplusplus")
	InsBufLine(hbuf, lnLast+1, "")

	InsBufLine(hbuf, lnFirst, "")
	InsBufLine(hbuf, lnFirst, "#endif")
	InsBufLine(hbuf, lnFirst, "extern \"C\" {")
	InsBufLine(hbuf, lnFirst, "#ifdef	__cplusplus")

	return Nil
}

//
// run cmd shell
// NOTE: SI gets the environment variables (like path etc.) ONLY at startup
//
macro Build_Shell()
{
	hprj = GetCurrentProj()
	prjdir = GetProjDir(hprj)

	recTime = _GetLocalTime()
	szTime = recTime.szTime
	ShellExecute("", "cmd", "/k \"cd @prjdir@ && title @szTime@\" ", "", 1)

	return Nil
}

macro Git_GetRootDir()
{
	var recRet
	var sz

	recRet = _RumCmdWithReturn("reg query HKCU\\Software\\Git-Cheetah /v PathToMsys | findstr \"PathToMsys\"", Nil, True)
	_Assert(recRet.fRet == true)

	sz = GetBufLine(recRet.hbuf, 0)
	sz = StrMid(sz, StrLen("    PathToMsys	REG_SZ	"), StrLen(sz))
	_LogI(sz)

	CloseBuf(recRet.hbuf)
	return sz
}

macro Git_Shell()
{
	var hProj
	var szProjDir
	var szRootDir
	var szShBin

	hProj = GetCurrentProj()
	szProjDir = GetProjDir(hProj)

	szRootDir = GetReg(git_root_dir)
	if(szRootDir == Nil)
	{
		szRootDir = Git_GetRootDir()
		SetReg(git_root_dir, szRootDir)
	}

	szShBin = Cat(szRootDir, "\\bin\\sh.exe")
	_LogI(szShBin)

	ShellExecute("", "cmd", "/k \"\"@szShBin@\" --login -i\" ", szProjDir, 3)
	return Nil
}

//
// copy the whole filepath to clipboard
//
macro GetFilePath()
{
	hbuf = GetCurrentBuf()
	sz = GetBufName(hbuf)
	//Msg(sz)

	hDirtyBuf = NewBuf("DirtyBuf")
	AppendBufLine(hDirtyBuf, sz)
	ln = GetBufLineCount(hDirtyBuf)
	CopyBufLine(hDirtyBuf, ln-1)
	SetBufDirty(hDirtyBuf, FALSE)
	CloseBuf(hDirtyBuf)

	return Nil
}

//
// search string and touch the file contains the string
//
macro LookupRefs ()
{
	sz = Ask("Reference String:")

    hbuf = NewBuf("Results") // create output buffer
    if (hbuf == 0)
        stop
    SearchForRefs(hbuf, sz, 1) // fTouchFiles = True
    SetCurrentBuf(hbuf) // put buffer in a window
    SetBufDirty(hBuf, FALSE)
    CloseBuf(hBuf)

    return Nil
}

//
// subst current root path to drive L:
//
macro SubstToDrvH()
{
	hprj = GetCurrentProj()
	prjdir = GetProjDir(hprj)

	ShellExecute("", "CMD", "/C \"(IF EXIST H: subst H: /D) & (SUBST H: \"@prjdir@ \") & (PAUSE)\" ", "", 1)

	return Nil
}

/////////////////////////////////////////////////////////////// prototype_gen.em /////////////////////////////////////////////////////////////

/*======================================================
eg:
	void function_name(T para1,
					T para2,
					T para3)
	--------------------------------------------------->
	void function_name(T para1,\nT para2, \nT para3);

	\n is the delims
========================================================*/
macro get_prototype_str(hbuf, sym, delims)
{
    if ("Function" != sym.Type)
		return Nil

	lnFirst = sym.lnFirst
	lnLim = sym.lnLim
	sz = Nil

	while(lnFirst <= lnLim)
	{
		szTmp = GetBufLine(hbuf, lnFirst)
		if (invalid != _strstr(szTmp, "{"))
			break

		if (sz != Nil)
			szTmp = Cat(delims, szTmp)
		sz = Cat(sz, szTmp)

		lnFirst = lnFirst + 1
	}

	if (lnFirst > lnLim)
	{
		Msg "Error! debug or not?"
		_Assert(False)
		stop
	}

	//add ";" at last
	sz = Cat(sz, ";")
	return sz
}


macro prototype_gen()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)
	isym = GetBufSymCount (hbuf)
	delims = "YMYS"

	while (isym)
    {
    	isym = isym - 1
	    symbol = GetBufSymLocation (hbuf, isym)
		sz = get_prototype_str(hbuf, symbol, delims)
		if (sz == Nil)
			continue

		//Msg sz
		cnt = _GetStrCount(sz, delims)
		//Msg cnt
		while (cnt)
		{
			cnt = cnt - 1
			recRet = _GetStrByIndex(sz, cnt, delims)
			InsBufLine(hbuf, ln, recRet.szData)
		}
    }

    return Nil
}


/////////////////////////////////////////////////////////////// quick_modify.em /////////////////////////////////////////////////////////////

//
// Modify lines in *.SearchResult file and then, effect the modification to all the files linked
//
macro Quick_Modify()
{
	hbuf = GetCurrentBuf()
	lnCnt = GetBufLineCount(hbuf)

	// check the file extension name
	zfpath = GetBufName (hbuf)
	zfex = _GetFileNameExtension(zfpath)
	if ("SearchResults" != zfex)
	{
		msg("请在搜索记录中使用本MENU!")
		stop
	}

	i = 1
	oldFile = Nil
	fbuf = hNil
	while (i < lnCnt)
	{
		lnk = GetSourceLink (hbuf, i)
		if (Nil == lnk)
		{
			AppendBufLine(hbuf, "Invalid Link at line @i@")
			i = i + 1
			continue
		}

		sz = GetBufLine(hbuf, i)
		ich = _StrStr(sz, ":")
		if (invalid == ich)
		{
			AppendBufLine(hbuf, "Invalid Line @i@, no \":\"")
			i = i + 1
			continue
		}
		sz = StrMid(sz, ich+1, StrLen(sz))

		//another file
		if (oldFile != lnk.File)
		{
			oldFile = lnk.File
			if (hNil != fbuf)
			{
				SaveBuf(fbuf)
				//CloseBuf(fbuf)
			}

			fbuf = OpenBuf(lnk.File)
			if (hNil == fbuf)
				AppendBufLine(hbuf, Cat("Can not open file: ", lnk.File))
		}

		if (hNil != fbuf)
			PutBufLine(fbuf, lnk.ln, sz)
		i = i + 1
	}

	if (hNil != fbuf)
	{
		SaveBuf(fbuf)
		CloseBuf(fbuf)
	}

	return Nil
}


/////////////////////////////////////////////////////////////// table_format.em /////////////////////////////////////////////////////////////

// format
macro TableFormatInner(pattern, lnFirst, lnLast)
{
	var hbuf
	var lnIndex
	var iColIndex
	var fAlignEnd
	var daLines
	var daLine
	var daInfo
	var sz
	var size
	var iSizeDaInfo

	if (pattern[0] == "-")
	{
		fAlignEnd = False // align to the begining of matched text
		pattern = StrMid(pattern, 1, StrLen(pattern))
	}
	else
	{
		fAlignEnd = True // align to the end of matched text
	}

	hbuf = GetCurrentBuf ()

	// save medium string for each line
	daLines = _NewDArray()

	// save string set infomations
	daInfo = _NewDArray()

	// string parsing and update length info
	lnIndex = lnFirst
	while (lnIndex <= lnLast)
	{
		var ss

		sz = GetBufLine(hbuf, lnIndex)
		ss = _NewStrSet(sz, pattern)

		// medium string
		daLine = _NewDArray()
		_PushDArray(daLines, daLine)

		// update max length of every column
		size = _CountStr(ss)
		iSizeDaInfo = _CountDArray(daInfo)

		// add info about new column
		while (size > iSizeDaInfo)
		{
			_PushDArray(daInfo, 0)
			iSizeDaInfo++
		}

		// update length info about each column
		iColIndex = 0
		while (iColIndex < size)
		{
			var old
			var new
			var psz
			var ssz

			if (fAlignEnd)
			{
				if (iColIndex == (size - 1))
					psz = Nil
				else
					psz = _GetPStr(ss, iColIndex)

				ssz = _GetStr(ss, iColIndex) # psz
			}
			else
			{
				if (iColIndex == 0)
					psz = Nil
				else
					psz = _GetPStr(ss, iColIndex-1)

				ssz = psz # _GetStr(ss, iColIndex)
			}

			//Msg ssz
			_PushDArray(daLine, ssz)

			old = _GetDArray(daInfo, iColIndex)
			new = StrLen(ssz)

			if (new > old)
				_SetDArray(daInfo, iColIndex, new)

			iColIndex++
		}

		_FreeStrSet(ss)
		lnIndex++
	}

	// align lines and release string set
	lnIndex = lnFirst
	while (lnIndex <= lnLast)
	{
		daLine = _PullDArray(daLines)
		size = _CountDArray(daLine)

		iColIndex = 0
		sz = Nil
		while (iColIndex < (size - 1)) // no need to align the last item
		{
			var len
			var iLenMax
			var ssz

			ssz = _PullDArray(daLine)
			iLenMax = _GetDArray(daInfo, iColIndex)
			ssz = _AlignStr(ssz, iLenMax, " ", True)
			sz = sz # ssz

			iColIndex++
		}

		sz = sz # _PullDArray(daLine)
		PutBufLine(hbuf, lnIndex, sz)

		_FreeDArray(daLine)
		lnIndex++
	}

	_FreeDArray(daInfo)
	_FreeDArray(daLines)
	return Nil
}

macro TableFormat()
{
	var hwnd
	var sel
	var pattern

    hwnd = GetCurrentWnd()
	sel = GetWndSel (hwnd)

	//get pattern
	pattern = Ask("Enter delims pattern:")
	if (pattern == Nil)
		stop
	TableFormatInner(pattern, sel.lnFirst, sel.lnLast)
}

/////////////////////////////////////////////////////////////// true_copy.em /////////////////////////////////////////////////////////////

//------------------------------
//
//------------------------------
macro __GetRefStr(szOld)
{
	var szNew
	var chr

	if (szOld != Nil)
	{
		StartMsg("[@szOld@] --Press Key N/n For Reset")
		chr = GetChar()
		EndMsg()

		if (invalid == _StrStr("Nn", chr))
		{
			return szOld
		}
	}

	szNew = Ask("New Reference String: ")
	return szNew
}

//
// copy files that listed in *.SearchResults file to another folder.
// 2009-10-01
//
macro TreeCopy()
{
	hbuf = GetCurrentBuf()

	// check the file extension name
	zfpath = GetBufName (hbuf)
	zfex = _GetFileNameExtension(zfpath)
	if ("SearchResults" != zfex)
	{
		msg("请在搜索记录中使用本MENU!")
		stop
	}

	// select a filename.
	sz = GetBufLine(hbuf, 0)
	//---- xxx Matches (6 in 4 files) ----
	ret = _ReplaceInStr(sz, "^---- \\(.*\\) Matches (.*---$", "\\1", False, True, True, False)
	if (0 == ret.fSuccess)
	{
		msg("ERROR!")
		stop
	}

	szPurpose = __GetRefStr(ret.szData)
	//_Assert(False)

	// replace the file information to file path
	oldPattern = "^\\(.*\\)\\s*(\\(.*\\)):.*$"
	newPattern = "\\2\\\\\\1"
	lnStart = 1
	lnLim = GetBufLineCount (hbuf)
	fMatchCase = False
	fRegExp = True
	fWholeWordsOnly = True
	fConfirm = False
	ReplaceInBuf(hbuf, oldPattern, newPattern, lnStart, lnLim, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)

	// delete the first line
	DelBufLine(hbuf, 0)

	// delete the duplicated file
	lnIdx = 1
	lnMax = lnLim - 1
	while(lnIdx < lnMax)
	{
		hbuf1 = GetBufLine(hbuf, lnIdx-1)
		hbuf2 = GetBufLine(hbuf, lnIdx)
		if (hbuf1 == hbuf2)
		{
			DelBufLine(hbuf, lnIdx)
			lnMax = lnMax - 1
		}
		else
		{
			lnIdx = lnIdx + 1
		}
	}


	// save the result to a file
	cplst = _SINewTmpFile()
	savebufAs(hbuf, cplst)
	fbuf = GetBufHandle(cplst)
	SaveBuf(fbuf)

	//_Assert(False)

	hprj = GetCurrentProj()
	szPrjDir = GetProjDir(hprj)
	//MSG szPrjDir

	dirName = szPrjDir
	while(True)
	{
		ich = _StrStr(dirName, "\\")
		if (ich == invalid)
			break

		dirName = StrMid(dirName, ich+1, StrLen(dirName))
	}

	dirName = "@dirName@__BAK__@szPurpose@"
	cmd = "For /F \"usebackq\" %i in (\"@cplst@\") DO @@ECHO %i && ECHO F | XCOPY /y \"@szPrjDir@\\%i\" \"@szPrjDir@\\..\\@dirName@\\%i\" >NUL "
	ShellExecute("", "cmd", "/k \"@cmd@\" ", "", 1)

	CloseBuf(fbuf)
	_SIDelTmpFile(cplst)
	return Nil
}

//
// MTK AT CMD AUTO GEN @2012-08-06
//
macro GenATCmd()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)

	sz = Ask("Input string after \"AT+\"")
	if (_SearchInStr(sz, "^[a-zA-Z0-9]+$", False, True, True) == Nil)
	{
		Msg "Invalid AT, which contains unexpected characters"
		stop
	}

	//EXTEND_CMD("csclk", 7302775, 0, "+CSCLK: (0,1,2)", RMMI_CMD_ATCSCLK, rmmi_csclk_hdlr)
	//CMD_ENUM(RMMI_CMD_ATCSCLK)
	hash = GenATHash(sz)
	extend_cmd = "EXTEND_CMD(\""#tolower(sz)#"\", "#hash.iHashVal1#", "#hash.iHashVal2#", "#"\"\""#", RMMI_CMD_AT"#toupper(sz)#", rmmi_"#tolower(sz)#"_hdlr)"
	cmd_enum = "CMD_ENUM(RMMI_CMD_AT"#toupper(sz)#")"
	InsBufLine(hbuf, ln, cmd_enum)
	InsBufLine(hbuf, ln, extend_cmd)

	return Nil
}

// Gen AT CMD string hash value accroding to MTK code @2012-08-06
macro GenATHash(sz)
{
	/**** [MAUI_01319443] mtk02514, 090120 *************************************************************
	*  The new hash value computed method is as follows.
	*  for AT+ABCDEFGH
	*  hash_value1 = hash(A)*38^4 + hash(B)*38^3 + hash(C)*38^2 + hash(D)*38^1 + hash(E)*38^0
	*                    = ((((hash(A)+0)*38 + hash(B))*38 + hash(C))*38 + hash(D))*38 + hash(E)  <== as following statements do.
	*  hash_value2 = hash(F)*38^2 + hash(G)*38^1 + hash(H)*38^0
	*                    = ((hash(F) + 0)*38 + hash(G))*38 + hash(H)  <== as following statements do.
	**********************************************************************************************/
	var recHash
	var iCnt
	var iLen
	var iHashVal1
	var iHashVal2
	var szz

	recHash = Nil
	iLen = StrLen(sz)
	szz = tolower(sz)

	//gen hash_value1
	iHashVal1 = 0
	iHashVal2 = 0
	iCnt = 0
	while(iCnt < iLen)
	{
		if (iCnt < 5)
			iHashVal1 = iHashVal1 * 38 + (AsciiFromChar(szz[iCnt]) - AsciiFromChar("a") + 1)
		else
			iHashVal2 = iHashVal2 * 38 + (AsciiFromChar(szz[iCnt]) - AsciiFromChar("a") + 1)
		iCnt++
	}

	recHash.iHashVal1 = iHashVal1;
	recHash.iHashVal2 = iHashVal2;
	return recHash
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Parse c struct elements, make it convinient for freemind typing
macro GenStructElementList()
{
	var hbuf
	var symbolname
	var iSymNameLen
	var symbol
	var symChild
	var daLines
	var hSymChild
	var iSymListCount
	var index
	var lnFirst
	var lnLim
	var lnCount
	var lnIndex

	hbuf = GetCurrentBuf()

	symbolname = GetCurSymbol()
	iSymNameLen = StrLen(symbolname)
	_LogI("symbolname=" # symbolname)

	symbol = GetSymbolLocation(symbolname)
	_LogI(symbol)

	if (symbol.Type != "Structure" || GetBufName(hbuf) != symbol.File)
	{
		Msg("Not support, only effective in struct declaration")
		stop
	}

	daLines = _NewDArray()

	lnFirst = symbol.lnFirst
	lnLim = symbol.lnLim

	lnCount = lnLim - lnFirst
	lnIndex = 0
	while (lnIndex++ < lnCount)
		_PushDArray(daLines, Nil)

	// parse struct subsymbol list
	hSymChild = SymbolChildren(symbol)
	iSymListCount = SymListCount(hSymChild)
	index = 0
	while (index < iSymListCount)
	{
		var sz
		var lnSz
		var lnName
		var ichName
		var szName
		var iNameLen
		var rec
		var ich

		symChild = SymListItem(hSymChild, index)
		_LogV(symChild)

		lnCount = symChild.lnLim - symChild.lnFirst
		lnIndex = symChild.lnFirst
		lnName = symChild.lnName
		ichName = symChild.ichName
		szName = StrMid(symChild.Symbol, iSymNameLen+1, StrLen(symChild.Symbol))
		iNameLen = StrLen(szName)
		_LogV("szName=" # szName)

		while (lnCount--)
		{
			lnSz = GetBufLine(hbuf, lnIndex)

			// cut off symbol name
			if (lnIndex == lnName)
			{
				var szPre
				var szPost
				szPre = StrTrunc(lnSz, ichName)
				szPost = StrMid(lnSz, ichName+iNameLen, StrLen(lnSz))
				lnSz = szPre # szPost
			}

			// cut off '//' style comments
			ich = _StrStr(lnSz, "//")
			if (ich != invalid)
				lnSz = StrTrunc(lnSz, ich)

			sz = sz # lnSz

			lnIndex++
		}

		// cut off all word after ';'
		ich = _StrStr(lnSz, ";")
		if (ich != invalid)
			sz = StrTrunc(sz, ich)

		// cut off '/**/' style comments
		rec = _ReplaceInStr(sz, "\\(/\\*.*\\*/\\)", Nil, False, True, False, False)
		sz = rec.szData

		// Replace redundant blank space
		rec = _ReplaceInStr(sz, "\\w\\w+", " ", False, True, False, False)
		sz = rec.szData

		// Chomp
		sz = _StrCls(sz)

		rec = Nil //clear
		rec.szType = sz
		rec.szName = szName

		_LogV(rec)
		_SetDArray(daLines, lnName-lnFirst, rec)

		index++
	}
	SymListFree(hSymChild)

	// Format output style
	{
		var daSize

		InsBufLine(hbuf, lnFirst, Nil)

		daSize = _CountDArray(daLines)
		while (daSize--)
		{
			var daRec
			daRec = _PopDArray(daLines)
			if (daRec == Nil)
				continue

			InsBufLine(hbuf, lnFirst, daRec.szType # "    " # daRec.szName)
		}

		InsBufLine(hbuf, lnFirst, Nil)
	}

	_FreeDArray(daLines)

	return Nil
}

