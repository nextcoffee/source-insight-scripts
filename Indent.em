//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================

//2011-04-27
macro __BlockIndent()
{
	var hwnd
	var sel
	var hbuf
	var tool
	var tool_para
	var fname
	var fbuf
	var i
	var sz
	var cmd
	var lnCnt

    hwnd = GetCurrentWnd()
	sel = GetWndSel (hwnd)
	hbuf = GetWndBuf (hwnd)

	//astyle tool & parameter
	tool = Cat(_GetSIBaseDir(), "AStyle.exe")

	//-A1SwYpdyjk3nZX
	tool_para = "--style=ansi --suffix=none --mode=c"

	//new a file the store the content selected temperorily
	fname = _SINewTmpFile()
	fbuf = OpenBuf (fname)
	if (hNil == fbuf)
	{
		fbuf = NewBuf(fname)
		_Assert(fbuf == hNil)
	}
	else
	{
		ClearBuf (fbuf)
	}

	_Log(sel)
	i = sel.lnFirst
	while (i <= sel.lnLast)
	{
		sz = GetBufLine (hbuf, i)
		AppendBufLine (fbuf, sz)
		i++
	}
	SaveBuf (fbuf)
	CloseBuf (fbuf)

	//run cmd to indent statements
	cmd = "cmd /C \"@tool@\" @tool_para@ \"@fname@\""
	_Log(cmd)
	if (0 != _Run(cmd))
		stop

	//handle the indented statements
	fbuf = OpenBuf (fname)
	if (hNil == fbuf)
		stop

	//clear current statements...
	lnCnt = sel.lnLast - sel.lnFirst + 1
	while (lnCnt--)
	{
		DelBufLine (hbuf, sel.lnFirst)
	}

	//paste the new statements
	lnCnt = GetBufLineCount (fbuf)
	while (lnCnt--)
	{
		sz = GetBufLine (fbuf, lnCnt)
		InsBufLine (hbuf, sel.lnFirst, sz)
	}
	SaveBuf (fbuf)
	CloseBuf (fbuf)
	_SIDelTmpFile(fname)

	return Nil
}

macro BlockIndent()
{
	//_InvokeMacro(__BlockIndent)
	_CheckIfPubEmExistsAndSWVersionRequirement()
	__BlockIndent()
	_LogShow()

	return Nil
}
