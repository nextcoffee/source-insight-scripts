//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================

//2014-09-26
macro __GetCurProjShrtName()
{
    var szProj
    var rec

	szProj = GetProjName(GetCurrentProj())

	rec = _ReplaceInStr(szProj, "^.*\\([^\\\\]+\\)$", "\\1", False, True, False, False)
	if (!rec.fSuccess)
	{
		_Assert(False)
		stop
	}

	return rec.szData
}

macro __ConstructCommentKey()
{
    var sz

	//sz = GetCurProjShrtName()
	if (Nil == sz)
	    return "comment"
	else
	    return "comment__@sz@"
}

macro __GenCommentElement()
{
    var rec
    var szUser
    var szCmtPara
    var recTime
    var szDate
    var szFirm

	szUser = ToUpper(GetReg(user_name))
	if (Nil == szUser)
	{
		szUser = Ask("For the first time, Please sign your name")
		SetReg(user_name, szUser)
	}

	szCmtPara = GetReg(__ConstructCommentKey())

	recTime = _GetLocalTime()
	szDate = recTime.szYear # recTime.szMonth # recTime.szDay

	szFirm = "INNODZN"

    rec.szUser = szUser
    rec.szCmtPara = szCmtPara
    rec.szDate = szDate
    rec.szFirm = szFirm

	return rec
}

macro __ConstructComment(szType)
{
    var recCmt
    var sz
    var szBugID
    var szDscr
    var szPara
    var i

    recCmt = __GenCommentElement()

    if (szType == "ANCHOR")
    {
        sz = "/*" # recCmt.szUser # "*/"
    }
    else
    {
        i = _StrStr(recCmt.szCmtPara, ": ")
        if (i == invalid)
        {
            szPara = recCmt.szCmtPara
            szPara = "@szPara@"
        }
        else
        {
            szBugID = StrTrunc(recCmt.szCmtPara, i)
            szDscr = StrMid(recCmt.szCmtPara, i+2, StrLen(recCmt.szCmtPara))

            szPara = "@szBugID@: @szDscr@"
        }

        sz = recCmt.szFirm # "," # recCmt.szUser # "," # recCmt.szDate
        if (szType == "APPEND")
            sz = "//" # sz # "," # szPara
        else if (szType == "BEGIN")
            sz = "//BEGIN " # sz # "," # szPara
        else if (szType == "END")
            sz = "//END " # sz # "," # "@szBugID@"
        else
            Msg("Invalid Comment Type: " # szType)
    }
    return sz
}

macro __InsertComment_wlns(sel)
{
    var hBuf
    var recCmt
    var sz

    hBuf = GetCurrentBuf()
    sz = __ConstructComment("ANCHOR")
    SetBufSelText(hBuf, sz)
    return Nil
}

macro __InsertComment_tls(sel)
{
    var hBuf
    var sz
    var szPrefix
    var szBegin
    var szEnd

    hBuf = GetCurrentBuf()

    sz = GetBufLine(hBuf, sel.lnFirst)
    szPrefix = StrTrunc(sz, sel.ichFirst)

    szBegin = __ConstructComment("BEGIN")
    szEnd = __ConstructComment("END")

    InsBufLine(hBuf, sel.lnLast + 1, szPrefix # szEnd)
    InsBufLine(hBuf, sel.lnFirst, szPrefix # szBegin)
    return Nil
}

macro __InsertComment_elns(sel)
{
    __InsertComment_tls(sel)

    SetBufIns(GetCurrentBuf(), sel.lnFirst + 1, sel.ichFirst)
    return Nil
}

macro __InsertComment_blns(sel)
{
    __InsertComment_elns(sel)
    return Nil
}

macro __InsertComment_alns(sel)
{
    var hBuf
    var recCmt
    var sz

    hBuf = GetCurrentBuf()
    sz = __ConstructComment("APPEND")
    SetBufSelText(hBuf, sz)
    return Nil
}

macro __InsertComment_wls(sel)
{
    Msg("Not support")
    return Nil
}
macro __InsertComment()
{
	var sel

	sel = _GetCurSelEx()
	if (sel.type == "WLNS")
		__InsertComment_wlns(sel.sel)
	else if (sel.type == "TLS")
		__InsertComment_tls(sel.sel)
	else if (sel.type == "ELNS")
		__InsertComment_elns(sel.sel)
	else if (sel.type == "BLNS")
		__InsertComment_blns(sel.sel)
	else if (sel.type == "ALNS")
		__InsertComment_alns(sel.sel)
	else if (sel.type == "WLS")
		__InsertComment_wls(sel.sel)
	else
		_Assert(False)

	return Nil
}

macro __InsertCommnet_CreateCmt()
{
    var sz

	sz = Ask("Input Comment String:")
	SetReg(__ConstructCommentKey(), sz)
	return Nil
}

macro InsertComment()
{
	//_InvokeMacro(__InsertComment)
	_CheckIfPubEmExistsAndSWVersionRequirement()
	__InsertComment()
    _LogShow()

    return Nil
}

macro InsertCommnet_CreateCmt()
{
	//_InvokeMacro(__InsertCommnet_CreateCmt)
	_CheckIfPubEmExistsAndSWVersionRequirement()
	__InsertCommnet_CreateCmt()
    _LogShow()

    return Nil
}

