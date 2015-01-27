//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================
// PUBLIC API'S HERE!!!

// Markdown comments are contained between [/*''] and [''*/]
// Use below CMD to gen markdown comments
// awk '/^\/\*'\'\''/,/'\'\''\*\/$/{if($0 !~ /^\/\*'\'\''/ && $0 !~ /'\'\''\*\/$/) print}' pub.em
// or
// sed -n "/^\/\*'/,/'\*\/$/{/^\/\*'/n; /'\*\/$/b; p}" pub.em

/*''*************************************************
#pub.em
Some useful functions

**************************************************''*/

/*''*************************************************
##TEST TOOLS
***

**************************************************''*/

/*''*************************************************
###_Assert(exp)
Assert and stop the macro when enconters unrepairable errors

**************************************************''*/
macro _Assert(exp)
{
	var hBuf

	if (exp == True)
		return Nil

	Msg "[_Assert]: Show assert info?"

	hBuf = NewBuf("AssertInfo")    // create output buffer
    if (hBuf == 0)
    {
		Msg "_Debug(): NewBuf error!"
        stop
    }

	DumpMacroState (hBuf)
    SetCurrentBuf(hBuf)            // put buffer to appears in the front-most window
    SetBufDirty(hBuf, False)       // suppress save prompt
    //CloseBuf(hBuf)

	stop
}

/*''*************************************************
###_Test(exp, result)
For test case

**************************************************''*/
macro _Test(exp, result)
{
	//_Log(exp)
	//_Log(result)
	if (exp != result)
	{
		_Assert(False)
	}

	//_Log("exp={@exp@}, result={@result@}, OK")
	return Nil
}

/*''*************************************************
##LOGGING TOOL
***

**************************************************''*/

/*''*************************************************
###_GenStackInfo(iLevel)
Get function call stack info

PARAMETERS:

* `iLevel`: call stack depth

RETURN VALUE:

* Record Structure
	* `szFunc`: function name
	* `iLine`: line number
	* `szTime`: timestamp

**************************************************''*/
macro _GenStackInfo(iLevel)
{
	var hBuf
	var recSel
	var szFunc
	var iLine
	var recTime
	var szTime
	var sz
	var rec

	hBuf = NewBuf(_UniNum())
	if (hBuf == hNil)
	    return Nil

	DumpMacroState (hBuf)
	recSel = SearchInBuf(hBuf, "^@iLevel@: [^\\t\\s]+$", 0, 0, True, True, True)
	if (recSel != Nil)
	{
		sz = GetBufLine(hBuf, recSel.lnFirst)
		szFunc = StrMid(sz, recSel.ichFirst + StrLen("@iLevel@: "), recSel.ichLim)

		sz = GetBufLine(hBuf, recSel.lnFirst + 2)
    	recSel = _SearchInStr(sz, "\\([0-9]+\\)", False, True, False)
    	if (recSel != Nil)
    	    iLine = recSel.szData
	}
    SetBufDirty(hBuf, False)
    CloseBuf(hBuf)

	recTime = _GetLocalTime()
    szTime = recTime.szTime # "." # recTime.szMilliseconds

    rec.szFunc = szFunc
    rec.iLine = iLine
    rec.szTime = szTime
    return rec
}

macro ___tst_GenStackInfo()
{
    var rec

	rec = _GenStackInfo(1)
	_ASSERT(rec.szFunc == "_GenStackInfo")
	rec = _GenStackInfo(2)
	_ASSERT(rec.szFunc == "___tst_GenStackInfo")

	return Nil
}

/*''*************************************************
###_Log(sz)
Logging messages to temperary buffer

PARAMETERS:

* `sz`: message string

RETURN VALUE: `Nil`

**************************************************''*/
macro _Log(sz)
{
	global szLogFileName
	var hFileLog
	var rec

	//if (1) return Nil

    //use szLogFileName instead of hFileLog in case that the program exit unexpectedly:
    //Global variables are useful for adding counters,
    //and other persistent state.
    //They **cannot hold any kind of handle**,
    //because all handles are destroyed when a macro finishes
    hFileLog = GetBufHandle(szLogFileName)

    if (hFileLog == hNil)
    {
	    szLogFileName = _UniNum()
	    hFileLog = newbuf(szLogFileName)
	    if (hFileLog == hNil)
	    {
			Msg "Dbg_start(): NewBuf error!"
	        return Nil
	    }
	}

	rec = _GenStackInfo(3)
	if (rec != Nil)
	    sz = "[" # rec.szTime # "] " # rec.szFunc # ", " # rec.iLine # ": " # sz

	AppendBufLine (hFileLog, sz)
	SetBufDirty(hFileLog, False)

	return Nil
}

/*''*************************************************
###_LogShow()
Show logging messages in temperary buffer

PARAMETERS: N/A

RETURN VALUE: `Nil`

**************************************************''*/
macro _LogShow()
{
	var hFileLog

    hFileLog = GetBufHandle(szLogFileName)
	if (hFileLog == hNil)
		return Nil

	SetCurrentBuf (hFileLog)

	return Nil
}

macro ___tst_Log()
{
	_Log("hello, ")
	_Log("world!")
	_LogShow()

	return Nil
}

/*''*************************************************
##MISC
***

**************************************************''*/

/*''*************************************************
###_UniNum()
Generate rondom number like: "201005062239000"

PARAMETERS: N/A

RETURN VALUE:

* String

**************************************************''*/
macro _UniNum()
{
	var szTime
	var Hour
	var Minute
	var Second
	var Milliseconds
	var Day
	var Month
	var Year
	var sz
	var szCount

	// Version 3.50.0044 - Jan 26, 2006
	global g_count

	szTime = GetSysTime(1)
	Hour = szTime.Hour
	Minute = szTime.Minute
	Second = szTime.Second
	Milliseconds = szTime.Milliseconds
	Day = szTime.Day
	Month = szTime.Month
	Year = szTime.Year

	if (Hour < 10) Hour = "0@Hour@"
	if (Minute < 10) Minute = "0@Minute@"
	if (Second < 10) Second = "0@Second@"
	if (Milliseconds < 10)
		Milliseconds = "00@Milliseconds@"
	else if (Milliseconds < 100)
		Milliseconds = "0@Milliseconds@"
	if (Day < 10) Day = "0@Day@"
	if (Month < 10) Month = "0@Month@"

	//count string
	if ((g_count == Nil))
		g_count = 0

	if (g_count >= 100) g_count = 0
	if (g_count < 10)
		szCount = "0@g_count@"
	else
		szCount = "@g_count@"
	g_count++

	sz = "@Year@@Month@@Day@@Hour@@Minute@@Second@@Milliseconds@@szCount@"
	return sz
}

macro ___tst_UniNum()
{
	//------------------------------
	// to ensure the uninum string is unique
	//------------------------------
	//*
	var outLoopCnt
	var sz
	var szz

	outLoopCnt = 1000
	while (outLoopCnt)
	{
		sz = _UniNum()
		szz = _UniNum()

		if (sz == szz)
		{
			Msg "Need more interval!"
			_Assert(False)
		}

		outLoopCnt = outLoopCnt - 1
	}

	_Log(_UniNum())
	return Nil
}

//------------------------------------------------------------
// Get local time in aligned format
//------------------------------------------------------------
macro __AlignNum(szNum, iCount, chr)
{
    var iLen
    var sz

    sz = szNum
    iLen = StrLen(sz)
    while (iCount > iLen)
    {
        sz = chr # sz
        iLen++
    }

    return sz
}

/*''*************************************************
###_GetLocalTime()
Cut off the blank chars at the both sides of the string

PARAMETERS: N/A

RETURN VALUE:

* Record Structure:
	* `szTime`: the time of day in string format
	* `szDate`: the day of week, day, month, and year as a string
	* `szYear`: current year
	* `szMonth`: current month number. January is 1
	* `szDayOfWeek`: day of week number. Sunday is 0, Monday is 1, etc
	* `szDay`: day of month
	* `szHour`: current hour
	* `szMinute`: current minute
	* `szSecond`: current second
	* `szMilliseconds`: current milliseconds

**************************************************''*/
macro _GetLocalTime()
{
    var recTimeAligned
    var recTimeOrig
    var chrAlign

	chrAlign = "0"
    recTimeOrig = GetSysTime(True)

    recTimeAligned.szDate = recTimeOrig.date
    recTimeAligned.szTime = recTimeOrig.time
    recTimeAligned.szYear = recTimeOrig.Year
    recTimeAligned.szDayOfWeek = recTimeOrig.DayOfWeek
    recTimeAligned.szMonth        = __AlignNum(recTimeOrig.Month, 2, chrAlign)
    recTimeAligned.szDay          = __AlignNum(recTimeOrig.Day,   2, chrAlign)
    recTimeAligned.szHour         = __AlignNum(recTimeOrig.Hour,  2, chrAlign)
    recTimeAligned.szMinute       = __AlignNum(recTimeOrig.Minute, 2, chrAlign)
    recTimeAligned.szSecond       = __AlignNum(recTimeOrig.Second, 2, chrAlign)
    recTimeAligned.szMilliseconds = __AlignNum(recTimeOrig.Milliseconds, 3, chrAlign)

	return recTimeAligned
}

macro ___tst_GetLocalTime()
{
    var rec
	rec = _GetLocalTime()

	_Assert(rec.szYear > 1970)
	_Assert(rec.szMonth <= 12 && rec.szMonth > 0)
	_Assert(rec.szDay <= 31 && rec.szDay > 0)
	_Assert(rec.szHour <= 24 && rec.szHour >= 0)
	_Assert(rec.szMinute <= 60 && rec.szMinute >= 0)

	return Nil
}

/*''*************************************************
##CHARS & STRING
***

**************************************************''*/

/*''*************************************************
###_IsSpace(ch)
Generate rondom number like: "201005062239000"

PARAMETERS:

* `ch`: If ch is a string with more than one character, only the first character is tested

RETURN VALUE:

* Boolean

**************************************************''*/
macro _IsSpace(ch)
{
	var code

	code = AsciiFromChar(ch)
	return (code == 32 || code == 9)
}

macro ___tst_IsSpace()
{
	_Test(_IsSpace(" "), True)
	_Test(_IsSpace("	"), True)
	_Test(_IsSpace("a"), False)
	return Nil
}

/*''*************************************************
###_StrStrEx(s, substr, ich, fMatchCase, fReverse)
Find a sub-string in string s, start from ich (ich>=0)

PARAMETERS:

* `s`: string
* `substr`: sub-string
* `ich`: index where searching begins from
* `fMatchCase`: case sensitive
* `fReverse`: reverse searching order

RETURN VALUE:

* `invalid`: no matching substr has been found
* Integer: location of matching substr

**************************************************''*/
macro _StrStrEx(s, substr, ich, fMatchCase, fReverse)
{
	var sLen
	var substrLen
	var iCnt
	var iStep
	var ichBegin
	var ichEnd

	// fMatchCase
	if (!fMatchCase)
	{
		s = toupper(s)
		substr = toupper(substr)
	}

	// fReverse
	if (fReverse)
		iStep = -1
	else
		iStep = 1

	// ich => [0,sLen)
	sLen = strlen(s)
	substrLen = strlen(substr)
	if (ich < 0 || ich >= sLen)
		return invalid

	if (fReverse)
		iCnt = ich+1 + substrLen*iStep + 1
	else
		iCnt = sLen - (substrLen+ich) + 1

	while(iCnt--)
	{
		if (fReverse)
		{
			ichBegin = ich+1 + substrLen*iStep
			ichEnd = ich+1
		}
		else
		{
			ichBegin = ich
			ichEnd = ich + substrLen*iStep
		}

		//_Log(ichBegin)
		//_Log(ichEnd)
		if (strmid(s, ichBegin, ichEnd) == substr)
			return ichBegin

		ich = ich + iStep
	}

	return invalid
}

macro ___tst_StrStrEx()
{
	_Test(_StrStrEx("yangming", "ng", 0, False, False), 2)
	_Test(_StrStrEx("yangming", "mg", 0, False, False), invalid)
	// ich test
	_Test(_StrStrEx("yangming", "ng", 3, False, False), 6)
	// fMatchCase test
	_Test(_StrStrEx("yangming", "Ng", 0, True, False), invalid)
	// fReverse test
	_Test(_StrStrEx("yangming", "ng", 7, False, True), 6)

	return Nil
}

/*''*************************************************
###_StrStr(s, substr)
Find a sub-string in string s

PARAMETERS:

* `s`: string
* `substr`: sub-string

RETURN VALUE:

* `invalid`: no matching substr has been found
* Integer: location of matching substr

**************************************************''*/
macro _StrStr(s, substr)
{
	return _StrStrEx(s, substr, 0, False, False)
}

macro ___tst_StrStr()
{
	_Test(_StrStr("yangming", "ng"), 2)
	_Test(_StrStr("yangming", "mg"), invalid)

	return Nil
}

/*''*************************************************
###_StrCmp(sz1, sz2)
String comparation

PARAMETERS:

* `sz1`: string
* `sz2`: string

RETURN VALUE:

* `0`: sz1 == sz2
* `1`: sz1 > sz2
* `-1`: sz1 < sz2

**************************************************''*/
macro _StrCmp(sz1, sz2)
{
	var szLen1
	var szLen2
	var szLenMin
	var cnt

	// ==
	//_Log(sz1)
	//_Log(sz2)
	if (sz1 == sz2)
		return 0

	szLen1 = StrLen(sz1)
	szLen2 = StrLen(sz2)
	szLenMin = _MIN(szLen1, szLen2)

	cnt = 0
	while(szLenMin > cnt)
	{
		if (AsciiFromChar(sz1[cnt]) == AsciiFromChar(sz2[cnt]))
		{
			cnt = cnt + 1
			continue
		}
		else if (AsciiFromChar(sz1[cnt]) > AsciiFromChar(sz2[cnt]))
			return 1
		else
			return (-1)
	}

	if (szLen1 > szLen2)
		return 1
	else if (szLen1 < szLen2)
		return (-1)

	return Nil
}

macro ___tst_StrCmp()
{
	_Test(_StrCmp("yang", "yin"), (-1))
	_Test(_StrCmp("yang", "yang"), 0)
	_Test(_StrCmp("yang", "yaag"), 1)

	return Nil
}

/*''*************************************************
###_StrCls(sz)
Cut off the blank chars at the both sides of the string

PARAMETERS:

* `sz`: string

RETURN VALUE:

* String: trimmed string

**************************************************''*/
macro _StrCls(sz)
{
	//var recRet
	//recRet = _ReplaceInStr(sz, "^\\w*\\(.*\\)\\w*$", "\\1", False, True, False, False)
	//return recRet.szData

	var i
	var iLen
	var iFirst
	var iLimit

	i = 0
	iLen = StrLen(sz)

	while (i <= iLen)
	{
		if (!_IsSpace(sz[i]))
			break

		i++
	}

	if (i == iLen)
		return Nil
	else
		iFirst = i

	i = iLen - 1

	while (i > iFirst)
	{
		if (!_IsSpace(sz[i]))
			break

		i--
	}

	iLimit = i + 1

	return StrMid(sz, iFirst, iLimit)
}

macro ___tst_StrCls()
{
	_Test(_StrCls(" void    "), "void")
	return Nil
}

/*''*************************************************
###_SearchInStr (sz, pattern, fMatchCase, fRegExp, fWholeWordsOnly)
Searches for pattern in the string

PARAMETERS:

* `sz`: string
* `pattern`: pattern string
* `fMatchCase`: if true, then the search is case sensitive
* `fRegExp`: if true, then the pattern contains a regular expression. Otherwise, the pattern is a simple string
* `fWholeWordsOnly`: if true, then only whole words will cause a match

RETURN VALUE:

* `Nil`: nothing matches the pattern
* Record Structure:
	* `ichFirst`: the index of the first character of  matching text
	* `ichLim`: the limit index (one past the last) of the last character of  matching text
	* `szData`: the matching text

**************************************************''*/
macro _SearchInStr (sz, pattern, fMatchCase, fRegExp, fWholeWordsOnly)
{
	var recSearchResult
	var hbuf
	var recSel
	var szRet

	recSearchResult = Nil    // init a record to store the return string and it's offset

	hbuf = NewBuf(_UniNum())  // create output buffer
	if (hbuf == 0)
	{
		Msg "Create DirtyBuffer Error!"
	    stop
	}

	AppendBufLine(hbuf, sz)
	recSel = SearchInBuf(hbuf, pattern, 0, 0, fMatchCase, fRegExp, fWholeWordsOnly)
	//_Assert(False)
	if (recSel == Nil)
	{
		SetBufDirty(hbuf, FALSE)  // don't bother asking to save
		CloseBuf(hbuf)
		return Nil
	}

	szRet = StrMid(sz, recSel.ichFirst, recSel.ichLim)
	SetBufDirty(hbuf, FALSE)      // don't bother asking to save
	CloseBuf(hbuf)

	recSearchResult.ichFirst = recSel.ichFirst
	recSearchResult.ichLim = recSel.ichLim
	recSearchResult.szData = szRet
	return recSearchResult
}

macro ___tst_SearchInStr()
{
	// TODO: need more...
	_Test(_SearchInStr("hello, world", "\\w+.+$", False, True, False), "ichFirst=\"6\";ichLim=\"12\";szData=\" world\"")
	return Nil
}

/*''*************************************************
###_ReplaceInStr (sz, oldPattern, newPattern, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
Replace for pattern in the string

PARAMETERS:

* `sz`: string
* `oldPattern`: searching pattern
* `newPattern`: replacement pattern
* `fMatchCase`: if true, then the search is case sensitive
* `fRegExp`: if true, then the pattern contains a regular expression. Otherwise, the pattern is a simple string
* `fWholeWordsOnly`: if true, then only whole words will cause a match
* `fConfirm`: if true, then the user will be prompted before each replacement

RETURN VALUE:

* Record Structure:
	* `szData`: new string after replacement
	* `fSuccess`: if true, then szData returns new string. Otherwise, old string is returned

**************************************************''*/
macro _ReplaceInStr (sz, oldPattern, newPattern, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
	var recReplaceResult
	var hbuf
	var ret
	var szRet

	recReplaceResult = Nil    // init a record to store the return string and it's status

	hbuf = NewBuf(_UniNum())        // create output buffer
	if (hbuf == 0)
	{
		Msg "Create DirtyBuffer Error!"
	    stop
	}

	AppendBufLine(hbuf, sz)
	ret = ReplaceInBuf(hbuf, oldPattern, newPattern, 0, 1, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
	if (ret == False)
	{
		SetBufDirty(hbuf, False)   // don't bother asking to save
		CloseBuf(hbuf)
		recReplaceResult.szData = sz
		recReplaceResult.fSuccess = False  // replace failed...
		return recReplaceResult
	}

	szRet = GetBufLine(hbuf, 0)
	SetBufDirty(hbuf, False)      // don't bother asking to save
	CloseBuf(hbuf)
	recReplaceResult.szData = szRet
	recReplaceResult.fSuccess = True  // replace success

	//_Assert(False)
	return recReplaceResult
}

macro ___tst_ReplaceInStr()
{
	// TODO: need more...
	_Test(_ReplaceInStr("hello, world", "\\(\\w+.+$\\)", " WORLD", False, True, False, False), "szData=\"hello, WORLD\";fSuccess=\"1\"")

	return Nil
}


/*''*************************************************
###_GetFileNameExtension(path)
 Get filename extension

PARAMETERS:

* `path`: filename path

RETURN VALUE:

* Record Structure:
	* `Nil`: no extension
	* String: extension text

**************************************************''*/
macro _GetFileNameExtension(path)
{
	var namelen
	var i

    namelen = strlen(path)
	i = namelen
	while (i--)
	{
		if ("." == path[i])
		{
			break;
		}
    }

    if (i <= 0)
	{
		return Nil
	}

	return strmid(path, i + 1, namelen)
}

macro ___tst_GetFileNameExtension()
{
	_Test(_GetFileNameExtension("file.ext"), "ext")
	_Test(_GetFileNameExtension("file."), Nil)
	_Test(_GetFileNameExtension("file"), Nil)

	return Nil
}

//------------------------------------------------------------
//
// Given a string isolated by delims to some parts, each part is given a index number...
// sz      string
// idx     index
// delims  delims charactors
//
/*
 e.g.
 	sz = "a,b ,c,d"
	szz = _GetStrByIndex(sz, 1, ",")
	Msg @szz@
result.
	"ichFirst="2";ichLim="4";data="b ""

 [NOTE]
 	"\\n" represent two char '\','n' in string,
 	but one char '\n' in search pattern, so as "\\t", "\\s" and "\\w"
*/
//------------------------------------------------------------
macro _GetStrByIndex(sz, idx, pattern)
{
	//--------------------------------------------------------------------------------
	// each part is combined with begin pattern delims(or line begin), pure string and end delims(or line ends)
	//--------------------------------------------------------------------------------
	var recRet
	var ret
	var cnt
	var len

	recRet = Nil
	ret = Nil
	cnt = 0
	len = 0

	//special produce
	//the func strmid makes influence on pattern meta data "^"
	//*
	if (pattern[0] == "^")
	{
		ret = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		if (ret == Nil)
		{
			if (idx > 0)
			{
				_Assert(False)
				stop
				//return Nil
			}

			recRet.ichFirst = 0
			recRet.ichLim = StrLen(sz)
			recRet.data = sz
			return recRet
		}
		else
		{
			if (idx > 1)
			{
				_Assert(False)
				stop
				//return Nil
			}
			else if (idx == 0)
			{
				return Nil
			}
			else if (idx == 1)
			{
				recRet.ichFirst = ret.ichLim
				recRet.ichLim = StrLen(sz)
				recRet.data = StrMid(sz, recRet.ichFirst, recRet.ichLim)
				return recRet
			}
		}
	}
	//*/

	// find the begin delims...
	cnt = idx
	while (cnt--)
	{
		ret = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		_Log(ret)
		if (ret == Nil)
		{
			_Assert(False)
			stop
			//return Nil
		}

		sz = StrMid(sz, ret.ichLim, StrLen(sz))
		len = len + ret.ichLim
	}

	// find the end delims...
	ret = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
	_Log(ret)
	if (ret == Nil)
	{
		recRet.ichFirst = len
		recRet.ichLim = len + StrLen(sz)
		recRet.data = sz
		return recRet
	}

	recRet.ichFirst = len
	recRet.ichLim = len + ret.ichFirst
	recRet.data = StrTrunc(sz, ret.ichFirst)
	return recRet
}

macro ___tst_GetStrByIndex()
{
	_Test(_GetStrByIndex("file ext", 0, " "), "ichFirst=\"0\";ichLim=\"4\";data=\"file\"")
	_Test(_GetStrByIndex("file ext", 0, "\\w+"), "ichFirst=\"0\";ichLim=\"4\";data=\"file\"")
	_Test(_GetStrByIndex("file ext", 1, "\\w+"), "ichFirst=\"5\";ichLim=\"8\";data=\"ext\"")
	_Test(_GetStrByIndex("file ext", 0, "^"), Nil)
	_Test(_GetStrByIndex("file ext", 1, "^"), "ichFirst=\"0\";ichLim=\"8\";data=\"file ext\"")
	_Test(_GetStrByIndex("file ext", 1, "^.+\\w+"), "ichFirst=\"5\";ichLim=\"8\";data=\"ext\"")

	return Nil
}


//------------------------------------------------------------
//
// Get parts count.
//
/*
 e.g.
 	sz = "a,b ,c,d"
	Msg _GetStrCount(sz, ",")
result.
	"4"
*/
//------------------------------------------------------------
macro _GetStrCount(sz, pattern)
{
	var cch
	var cnt
	var ret

	cch = StrLen(sz)    // string length.
	cnt = 0             // delims count.

	if (pattern[0] == "^")
	{
		ret = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		if (ret == Nil) /* null string */
			return (1)
		else
			return (2)
	}

	while(True)
	{
		ret = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		if (ret == Nil)
			break
		cnt++

		sz = StrMid(sz, ret.ichLim, StrLen(sz))
	}

	return (cnt + 1)    // strCount = delimsCount + 1
}

macro ___tst_GetStrCount()
{
	_Test(_GetStrCount("file ext", " "), 2)
	_Test(_GetStrCount("file ext", "\\w+"), 2)
	_Test(_GetStrCount("file ext", "^"), 2)
	_Test(_GetStrCount("file ext more", "\\w+"), 3)

	return Nil
}

//------------------------------------------------------------
// string parse
//------------------------------------------------------------
macro _NewStrSet(sz, pattern, fPatternOnStart)
{
	var hStr
	var recRet
	var len
	var err

	_Log(pattern)

	// pattern string check
	if (pattern[0] == "^")
	{
		Msg "Pattern ^ is not supported!"
		stop
	}

	if (pattern[StrLen(pattern) - 1] == "$")
	{
		// '\\*' '\$' '$'
		recRet = _SearchInStr(pattern, "\\\\*\\$$", TRUE, TRUE, FALSE)
		len = recRet.ichLim - recRet.ichFirst
		if (len != (len / 2 * 2))
		{
			Msg "Pattern $ is not supported!"
			stop
		}
		//_Assert(False)
	}


	hStr = Nil
	hStr.ssDataArray = _NewDArray()
	hStr.ssPatternArray = _NewDArray()
	hStr.ssfPatternOnStart = fPatternOnStart

	//special produce
	//the func strmid will effect pattern meta data "^"
	/*
	if (pattern[0] == "^")
	{
		recRet = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		if (recRet == Nil)
		{
			rec.validData = sz
			rec.patternData = Nil
			AppendBufLine(hStr.sshBuf, rec)
			hStr.ssCount = 1
			return hStr
		}
		else
		{
			AppendBufLine(hStr.sshBuf, Nil)
			rec.validData = StrMid(sz, recRet.ichLim, StrLen(sz))
			rec.patternData = StrMid(sz, recRet.ichFirst, recRet.ichLim)
			AppendBufLine(hStr.sshBuf, rec)
			hStr.ssCount = 2
			return hStr
		}
	}
	//*/

	// find the begin delims...
	len = 0
	while(True)
	{
		recRet = _SearchInStr(sz, pattern, TRUE, TRUE, FALSE)
		if (recRet == Nil)
		{
			_PushDArray(hStr.ssDataArray, sz)
			if (fPatternOnStart)
				_InsDArray(hStr.ssPatternArray, Nil)
			else
				_PushDArray(hStr.ssPatternArray, Nil)
			//_Assert(False)
			return hStr
		}

		if (recRet.ichFirst == recRet.ichLim)
		{
			err = "Error pattern: Pattern cant represents Nil!"
			break
		}

		_PushDArray(hStr.ssDataArray, StrTrunc(sz, recRet.ichFirst))
		_PushDArray(hStr.ssPatternArray, StrMid(sz, recRet.ichFirst, recRet.ichLim))

		sz = StrMid(sz, recRet.ichLim, StrLen(sz))
		len = len + recRet.ichLim
	}

	//error!
	_FreeDArray(hStr.ssPatternArray)
	_FreeDArray(hStr.ssDataArray)

	Msg err
	//return Nil
	stop
}

macro _GetStrSet(hStr)
{
	var cnt
	var index
	var sz
	var szData
	var szPattern

	cnt = _CountStr(hStr)
	index = 0
	sz = Nil
	while (index < cnt)
	{
		szData = _GetDArray(hStr.ssDataArray, index)
		szPattern = _GetDArray(hStr.ssPatternArray, index)

		if (hStr.ssfPatternOnStart)
			sz = sz#szPattern#szData
		else
			sz = sz#szData#szPattern

		index = index + 1
	}

	return sz
}

macro _FreeStrSet(hStr)
{
	_FreeDArray(hStr.ssPatternArray)
	_FreeDArray(hStr.ssDataArray)

	return Nil
}

macro _GetStr(hStr, index)
{
	return _GetDArray(hStr.ssDataArray, index)
}

macro _SetStr(hStr, index, sz)
{
	return _SetDArray(hStr.ssDataArray, index, sz)
}

macro _GetPStr(hStr, index)
{
	return _GetDArray(hStr.ssPatternArray, index)
}

macro _SetPStr(hStr, index, sz)
{
	return _SetDArray(hStr.ssPatternArray, index, sz)
}

macro _CountStr(hStr)
{
	return _CountDArray(hStr.ssDataArray)
}

macro ___tst_StrSet()
{
	var sz
	var szTmp
	var pattern
	var hstr
	var cnt

	// normal test
	{
		sz = "a$; b; c;  d; e"
		szTmp = sz
		pattern = ";\\w"

		hstr = _NewStrSet(sz, pattern, False)
		sz = _GetStrSet(hstr)
		_Test(sz, szTmp)

		_Test(_GetStr(hstr, 0), "a$")
		_SetStr(hstr, 0, "A")
		_Test(_GetPStr(hstr, 0), "; ")
		_Test(_GetStr(hstr, 0), "A")

		_Test(_CountStr(hstr), 5)

		_FreeStrSet(hstr)
	}

	// pattern '$' test
	{
		sz = "a$; b; c;  d; e"
		szTmp = sz
		pattern = "\\$" //"\$"

		hstr = _NewStrSet(sz, pattern, False)
		sz = _GetStrSet(hstr)
		_Test(sz, szTmp)

		_Test(_GetPStr(hstr, 0), "$")
		_Test(_CountStr(hstr), 2)

		_FreeStrSet(hstr)
	}

	// pattern '\$' test
	{
		sz = "a\\$; b; c;  d; e"
		szTmp = sz
		pattern = "\\\\\\$" //"\\\$"

		hstr = _NewStrSet(sz, pattern, False)
		sz = _GetStrSet(hstr)
		_Test(sz, szTmp)

		_Test(_GetPStr(hstr, 0), "\\$")
		_Test(_CountStr(hstr), 2)

		_FreeStrSet(hstr)
	}

	return Nil
}



//------------------------------------------------------------
// dynamic array
//------------------------------------------------------------
macro _NewDArray()
{
	var hDArray
	var rec

	hDArray = NewBuf(_UniNum())
	if (hDArray == hNil)
	{
		Msg "Create dynamic array failed"
		stop
	}

	//first line to store array count
	rec = Nil
	rec.daCount = 0
	AppendBufLine(hDArray, rec)

	return hDArray
}

macro _FreeDArray(hDArray)
{
	SetBufDirty(hDArray, FALSE)
	CloseBuf(hDArray)

	return Nil
}

macro _PushDArray(hDArray, sz)
{
	var recRet

	recRet = GetBufLine(hDArray, 0)
	recRet.daCount = recRet.daCount + 1
	PutBufLine(hDArray, 0, recRet)
	AppendBufLine(hDArray, sz)

	return Nil
}

macro _PopDArray(hDArray)
{
	var sz
	var recRet

	recRet = GetBufLine(hDArray, 0)
	if (recRet.daCount == 0)
	{
		Msg "[_PopDArray] Out of range"
		_Assert(False)
		stop
	}

	sz = GetBufLine(hDArray, recRet.daCount)
	DelBufLine(hDArray, recRet.daCount)

	recRet.daCount = recRet.daCount - 1
	PutBufLine(hDArray, 0, recRet)
	return sz
}

macro _PullDArray(hDArray)
{
	var sz
	var recRet

	recRet = GetBufLine(hDArray, 0)
	if (recRet.daCount == 0)
	{
		Msg "[_PopDArray] Out of range"
		_Assert(False)
		stop
	}

	sz = GetBufLine(hDArray, 1)
	DelBufLine(hDArray, 1)

	recRet.daCount = recRet.daCount - 1
	PutBufLine(hDArray, 0, recRet)
	return sz
}

macro _InsDArray(hDArray, sz)
{
	var recRet

	recRet = GetBufLine(hDArray, 0)
	recRet.daCount = recRet.daCount + 1
	PutBufLine(hDArray, 0, recRet)

	InsBufLine(hDArray, 1, sz)
	return Nil
}

macro _GetDArray(hDArray, index)
{
	var recRet

	recRet = GetBufLine(hDArray, 0)
	if (recRet.daCount <= index)
	{
		Msg "[_GetDArray] Out of range"
		_Assert(False)
		stop
	}

	return GetBufLine(hDArray, index + 1)
}

macro _SetDArray(hDArray, index, sz)
{
	var recRet

	recRet = GetBufLine(hDArray, 0)
	if (recRet.daCount <= index)
	{
		Msg "[_SetDArray] Out of range"
		_Assert(False)
		stop
	}

	PutBufLine(hDArray, index + 1, sz)
	return Nil
}

macro _CountDArray(hDArray)
{
	var recRet

	recRet = GetBufLine(hDArray, 0)
	return recRet.daCount
}

macro ___tst_DArray()
{
	var hDArray

	hDArray = _NewDArray()

	_PushDArray(hDArray, "yang")
	_PushDArray(hDArray, "ming")
	_PushDArray(hDArray, "yin")
	_PushDArray(hDArray, "shu")

	_Test(_CountDArray(hDArray), 4)

	_SetDArray(hDArray, 0, "Yang")
	_Test(_PullDArray(hDArray), "Yang")

	_InsDArray(hDArray, "yang")

	_Test(_PopDArray(hDArray), "shu")
	_Test(_PopDArray(hDArray), "yin")
	_Test(_PopDArray(hDArray), "ming")
	_Test(_PopDArray(hDArray), "yang")
	_Test(_CountDArray(hDArray), 0)

	_FreeDArray(hDArray)

	return Nil
}

macro _MIN(a, b)
{
	if (a > b)
		return b
	else
		return a
}

macro _MAX(a, b)
{
	if (a > b)
		return a
	else
		return b
}

macro _GetSIVer()
{
	var pinfo
	var verMjr
	var verMnr
	var verBld
	var szVer

	pinfo = GetProgramInfo()
	if (pinfo == Nil)
	{
		Msg "Unexpected error occurs, Please restart SI program and try again, Thank you!"
		stop
	}

	verMjr = pinfo.versionMajor
	verMnr = pinfo.versionMinor
	verBld = pinfo.versionBuild

	if (verMnr < 10)
		verMnr = "0"#verMnr

	if (verBld < 10)
		verBld = "000"#verBld
	else if (verBld < 100)
		verBld = "00"#verBld
	else if (verBld < 1000)
		verBld = "0"#verBld

	szVer = "@verMjr@.@verMnr@.@verBld@"

	return szVer
}

macro ___tst_GetSIVer()
{
	var szVer
	var szLen
	var verMjr
	var verMnr
	var verBld

	szVer = _GetSIVer()

	szLen = StrLen(szVer)
	_Test(szLen, StrLen("3.50.0070"))

	verMjr = StrMid(szVer, 0, 1)
	_Assert(IsNumber(verMjr))
	_Test(szVer[1], ".")

	verMnr = StrMid(szVer, 2, 4)
	_Assert(IsNumber(verMnr))
	_Test(szVer[4], ".")

	verBld = StrMid(szVer, 5, 9)
	_Assert(IsNumber(verBld))

	return Nil
}

//------------------------------------------------------------
//Get current selection info and type
//------------------------------------------------------------
macro _GetCurSelEx()
{
	var hwnd
	var hbuf
	var sel
	var recSelInfo

    hwnd = GetCurrentWnd()
    hbuf = GetWndBuf (hwnd)
	sel = GetWndSel (hwnd)
	recSelInfo.sel = sel

	//--------------------------------------------------------------------------------
	//"ELNS" :Empty Line and No Selection
	//sel = "lnFirst="1210";ichFirst="0";lnLast="1210";ichLim="0";fExtended="0";fRect="0""

	//"BLNS" :Before Line and No Selection
	//sel = "lnFirst="1200";ichFirst="0";lnLast="1200";ichLim="0";fExtended="0";fRect="0""

	//"ALNS" :After Line and No Selection
	//sel = "lnFirst="1208";ichFirst="36";lnLast="1208";ichLim="36";fExtended="0";fRect="0""

	//"WLNS" :Wherein Line and No Selection
	//sel = "lnFirst="1214";ichFirst="19";lnLast="1214";ichLim="19";fExtended="0";fRect="0""

	//"TLS" :Total Lines and Seclection
	//sel = "lnFirst="1217";ichFirst="0";lnLast="1218";ichLim="4";fExtended="1";fRect="0""

	//"WLS" :Wherein Lines and Selection
	//sel = "lnFirst="1220";ichFirst="8";lnLast="1220";ichLim="35";fExtended="1";fRect="0""

	//[SUMMARY] (~= MEANS match)
	//[NoSelection] fExtended="0"
	//    [EmptyLine] sz ~= "^\w*$"
	//    [BeforeLine] !EmptyLine && (ichFirst == "0" || sz[0:ichFirst] ~= "^\w*$")
	//    [AfterLine] !EmptyLine && (ichLim == StrLen(sz) || sz[ichLim:StrLen(sz)] ~= "^\w*$")
	//    [WhereinLine] !EmptyLine && !BeforeLine && !AfterLine
	//[Selection] fExtended="1"
	//    [TotalLines] (ichFirst == "0" || sz[0:ichFirst] ~= "^\w*$") && (ichLim >= StrLen(sz) || sz[ichLim:StrLen(sz)] ~= "^\w*$")
	//    [WhereinLines] !TotalLines

	//[Note] Total lines selection has two forms
	//WithLastNewLineChr:     sel = "lnFirst="1200";ichFirst="0";lnLast="1202";ichLim="24";fExtended="1";fRect="0""
	//WithoutLastNewLineChr:  sel = "lnFirst="1200";ichFirst="0";lnLast="1202";ichLim="23";fExtended="1";fRect="0""
	//--------------------------------------------------------------------------------
	if (sel.fExtended == "0")
	{
		var sz
		var szSub

		sz = GetBufLine(hbuf, sel.lnFirst)

		//EmptyLine?
		if (Nil != _SearchInStr(sz, "^\\w*$", False, True, False))
		{
			recSelInfo.type = "ELNS"
			return recSelInfo
		}

		//BeforeLine?
		szSub = StrTrunc(sz, sel.ichFirst)
		if (Nil == szSub || Nil != _SearchInStr(szSub, "^\\w*$", False, True, False))
		{
			recSelInfo.type = "BLNS"
			return recSelInfo
		}

		//AfterLine?
		szSub = StrMid(sz, sel.ichLim, StrLen(sz))
		if (Nil == szSub || Nil != _SearchInStr(szSub, "^\\w*$", False, True, False))
		{
			recSelInfo.type = "ALNS"
			return recSelInfo
		}

		//WhereinLine?
		recSelInfo.type = "WLNS"
		return recSelInfo
	}
	else if (sel.fExtended == "1")
	{
		var szFirst
		var szLast
		var szPrefix
		var szPostfix
		var iLen

		szFirst = GetBufLine(hbuf, sel.lnFirst)
		szLast = GetBufLine(hbuf, sel.lnLast)

		//WhereinLines?
		szPrefix = StrTrunc(szFirst, sel.ichFirst)
		//szLastSub = StrMid(szLast, sel.ichLim, StrLen(szLast))
		iLen = StrLen(szLast)
		if (sel.ichLim >= iLen)
			szPostfix = Nil
		else
			szPostfix = StrMid(szLast, sel.ichLim, StrLen(szLast))

		if ((Nil == szPrefix || Nil != _SearchInStr(szPrefix, "^\\w*$", False, True, False))
		&& (Nil == szPostfix || Nil != _SearchInStr(szPostfix, "^\\w*$", False, True, False)))
		{
			recSelInfo.type = "TLS"
			return recSelInfo
		}

		recSelInfo.type = "WLS"
		return recSelInfo
	}

	_Assert(False)
	return Nil
}

macro ___tst_GetCurSelEx()
{
	// TODO:
	_Log(_GetCurSelEx())
	return Nil
}

macro _GetSIBaseDir()
{
	var recProgEnvInfo
	var projDirFile
	var ich
	var projDir
	var projBaseDir

	recProgEnvInfo = GetProgramEnvironmentInfo()
	projDirFile = recProgEnvInfo.ProjectDirectoryFile

	ich = _StrStrEx(projDirFile, "\\", StrLen(projDirFile)-1, False, True)
	if (ich == invalid)
	{
		_Assert(False)
		stop
	}

	projDir = StrTrunc(projDirFile, ich+1)
	projBaseDir = Cat(projDir, "Base\\")

	return projBaseDir
}

macro ___tst_GetSIBaseDir()
{
	var projBaseDir
	var filePubEm

	projBaseDir = _GetSIBaseDir()
	filePubEm = Cat(projBaseDir, "pub.em")

	// open test
	_Assert(_IsFileExist(filePubEm))

	return Nil
}

// NOTE: This func cannot effect on source insight project file
macro _IsFileExist(fileFullName)
{
	var hbuf

	_Log(fileFullName)
	hbuf = OpenBuf(fileFullName)
	if (hNil == hbuf)
		return False
	CloseBuf(hbuf)
	return True
}

macro ___tst_IsFileExist()
{
	var hbuf
	hbuf = GetCurrentBuf()
	_Assert(_IsFileExist(GetBufName(hbuf)))
	//_Assert(_IsFileExist(_GetSIBaseDir()#"Base.PR"))
	//_Assert(_IsFileExist(_GetSIBaseDir()#"Base.PRI"))

	return Nil
}

macro _CopyBuf(hSrc, hDst)
{
	var iCnt
	var sz

	if (hSrc == hDst)
		return Nil

	ClearBuf(hDst)

	iCnt = GetBufLineCount(hSrc)
	while(iCnt--)
	{
		sz = GetBufLine(hSrc, iCnt)
		InsBufLine(hDst, 0, sz)
	}

	return Nil
}

macro ___tst_CopyBuf()
{
	var hSrc
	var hDst

	hSrc = NewBuf(_UniNum())
	_Assert(hSrc != hNil)
	hDst = NewBuf(_UniNum())
	_Assert(hDst != hNil)

	InsBufLine(hSrc, 0, "ming")
	InsBufLine(hSrc, 0, "yang")
	_CopyBuf(hSrc, hDst)
	_Test(GetBufLine(hDst, 0), "yang")
	_Test(GetBufLine(hDst, 1), "ming")

	SetBufDirty(hDst, FALSE)
	CloseBuf(hDst)
	SetBufDirty(hSrc, FALSE)
	CloseBuf(hSrc)
	return Nil
}

macro _SINewTmpFile()
{
	var szDir
	var szFile
	var ret

	szDir = GetEnv("TEMP")
	szFile = szDir # "\\" # _UniNum()
	_Log(szFile)

	ret = _RunVBS("CreateTmpFile @szFile@")
	if(ret != 0)
	{
		Msg "[ERR][_RunVBS] CreateTmpFile @szFile@"
		stop
	}

	return szFile
}

macro _SIDelTmpFile(szFile)
{
	var ret

	_Log(szFile)

	ret = _RunVBS("DeleteTmpFile @szFile@")
	if(ret != 0)
	{
		Msg "[ERR][_RunVBS] DeleteTmpFile @szFile@"
		stop
	}

	return Nil
}

macro ___tst_SITempFile()
{
	var flname

	flname = _SINewTmpFile()
	_Test(_IsFileExist(flname), True)
	_SIDelTmpFile(flname)
	_Test(_IsFileExist(flname), False)

	return Nil
}

macro _RumCmdWithReturn(sCmdLine, sWorkingDirectory, fWait)
{
	var recRet
	var flname
	var hbuf
	var fRet
	var szCmd
	var hTmp
	var iCnt

	recRet.fRet = False
	recRet.hbuf = hNil

	hbuf = NewBuf(_UniNum())
	_Assert(hNil != hbuf)

	flname = _SINewTmpFile()

	szCmd = "cmd /c (@sCmdLine@>\"@flname@\")"
	fRet = _Run(szCmd)

	hTmp = OpenBuf(flname)
	_Assert(hTmp != hNil)
	_CopyBuf(hTmp, hbuf)
	CloseBuf(hTmp)

	_SIDelTmpFile(flname)

	if(fRet == 0)
		recRet.fRet = true
	else
		recRet.fRet = false
	recRet.hbuf = hbuf
	SetBufDirty(hbuf, FALSE)

	_Assert(recRet.fRet == true)
	_Assert(recRet.hbuf != hNil)
	return recRet
}

macro ___tst_RumCmdWithReturn()
{
	var recRet

	recRet = _RumCmdWithReturn("echo yang", Nil, True)
	_Assert(recRet.hbuf != hNil)
	_Test(GetBufLine(recRet.hbuf, 0), "yang")
	CloseBuf(recRet.hbuf)
	return Nil
}

macro _RunVBS(sz)
{
	_Log(sz)
	return RunCmdLine("wscript.exe //B VBS_Run.vbs @sz@", _GetSIBaseDir(), True)
}

macro ___tst_RunVBS()
{
	_Test(_RunVBS("Test"), 0)
	return Nil
}

macro _Run(sz)
{
	_Log(sz)
	return _RunVBS("RunCMD @sz@")
}

macro ___tst_Run()
{
	_Test(_Run("cmd /c \"D:\\Program Files\\Notepad++\\notepad++.exe\""), 0)

	return Nil
}

macro _TestCaseCollection()
{
	var hbuf
	var szName
	var cmd

	hbuf = GetCurrentBuf()
	szName = GetBufName(hbuf)

	cmd = "for /f \"tokens=1,2*\" %i in ('findstr /B /R /C:\"macro ___\" \"@szName@\"') do @@if not \"%j\" equ \"\" echo %j"
	_Log(cmd)
	RunCmdLine("cmd /k \"@cmd@\"", ".", False);

	return Nil
}

macro ___tst_all()
{
	___tst_UniNum()
	___tst_IsSpace()
	___tst_StrStrEx()
	___tst_StrStr()
	___tst_StrCmp()
	___tst_StrCls()
	___tst_GetLocalTime()
	___tst_SearchInStr()
	___tst_ReplaceInStr()
	___tst_GetFileNameExtension()
	___tst_GetStrByIndex()
	___tst_GetStrCount()
	___tst_StrSet()
	___tst_DArray()
	___tst_GetSIVer()
	___tst_GetCurSelEx()
	___tst_GetSIBaseDir()
	___tst_IsFileExist()
	___tst_CopyBuf()
	___tst_SITempFile()
	___tst_RumCmdWithReturn()
	___tst_RunVBS()

	//keep this at the last line
	___tst_Log()
	return Nil
}


macro _CheckIfPubEmExistsAndSWVersionRequirement()
{
	var szCurVersion
	var szVersionRequire

	szVersionRequire = "3.50.0070"
	szCurVersion = _GetSIVer()

	if (_StrCmp(szVersionRequire, szCurVersion) > 0)
	{
		Msg "Please update your software up to @szVersionRequire@ or higher"
		stop
	}

	return Nil
}

// TODO: After the execution of RunCmd(), the key ctrl-z will not response
macro _InvokeMacro(szMacro)
{
    _CheckIfPubEmExistsAndSWVersionRequirement()

    if (szMacro != Nil && szMacro != "szMacro")
        RunCmd(szMacro)

    _LogShow()
    return Nil
}

//////////////////////////////////////////////////
// FUNCTION NAME REGULATION:
//     xxx      : buildin func and user macro interface
//     _xxx     : common function
//     __xxx    : static function
//     ___xxx   : test case function
//
//////////////////////////////////////////////////


//////////////////////////////////////////////////
// NOTE:
// # all are base on SI ver 3.50.0064
// 01, Regular Expression does not support '\w' in '[ ]', use '\t\s' instead.
// 02, Do not use "return" without following, or enclose it in brace like "{return}"
// 03, left side bar selection will increase the sel.ichLim by 1 (1 more than strlen), which may be means the line break
// 04, RegExp is greedy
// 05, Operator like ||,&&,does not act as C with a first-second sequence
// 06, every macro need a return before end, it's for Run Macro cmd
// 07, register operation path: [HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\3.0]
// 08, SI macro just support Call-by-Value style for function call, which means the function's behavior just effects a copy of the parameter.
// 09, operator "++" and "--" sometimes are not effective in singal statement. [fixed since 3.50.0070]
// 10, When pass parameter like -1, need brace it like (-1), otherwise, wrong parse result.
// 11, OpenBuf can not open source insight project file like *.PR or *.PRI and so on
// 12,
//////////////////////////////////////////////////
