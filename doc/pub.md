
* [TEST](#TEST)
  * [_Assert(exp)](#_Assertexp)
  * [_Test(exp, result)](#_Testexpresult)
* [LOGGING](#LOGGING)
  * [_Log{tag}(sz)](#_Logtagsz)
  * [_SetLogLevel(szLevel)](#_SetLogLevelszLevel)
  * [_LogShow()](#_LogShow)
  * [_GenStackInfo(iLevel)](#_GenStackInfoiLevel)
* [CHARS & STRING](#CHARSSTRING)
  * [_IsSpace(ch)](#_IsSpacech)
  * [_AlignStr(sz, length, chr, fAppend)](#_AlignStrszlengthchrfAppend)
  * [_StrStrEx(s, substr, ich, fMatchCase, fReverse)](#_StrStrExssubstrichfMatchCasefReverse)
  * [_StrStr(s, substr)](#_StrStrssubstr)
  * [_StrCmp(sz1, sz2)](#_StrCmpsz1sz2)
  * [_StrCls(sz)](#_StrClssz)
  * [_SearchInStr (sz, pattern, fMatchCase, fRegExp, fWholeWordsOnly)](#_SearchInStrszpatternfMatchCasefRegExpfWholeWordsOnly)
  * [_ReplaceInStr (sz, oldPattern, newPattern, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)](#_ReplaceInStrszoldPatternnewPatternfMatchCasefRegExpfWholeWordsOnlyfConfirm)
  * [_GetFileNameExtension(path)](#_GetFileNameExtensionpath)
  * [_GetStrByIndex(sz, idx, pattern)](#_GetStrByIndexszidxpattern)
  * [_GetStrCount(sz, pattern)](#_GetStrCountszpattern)
* [DYNAMIC ARRAY](#DYNAMICARRAY)
  * [_NewDArray()](#_NewDArray)
  * [_FreeDArray(hDArray)](#_FreeDArrayhDArray)
  * [_PushDArray(hDArray, sz)](#_PushDArrayhDArraysz)
  * [_PopDArray(hDArray)](#_PopDArrayhDArray)
  * [_PullDArray(hDArray)](#_PullDArrayhDArray)
  * [_InsDArray(hDArray, sz)](#_InsDArrayhDArraysz)
  * [_GetDArray(hDArray, index)](#_GetDArrayhDArrayindex)
  * [_SetDArray(hDArray, index, sz)](#_SetDArrayhDArrayindexsz)
  * [_CountDArray(hDArray)](#_CountDArrayhDArray)
* [STRING SET](#STRINGSET)
  * [_NewStrSet(sz, pattern)](#_NewStrSetszpattern)
  * [_GetStrSet(hStr)](#_GetStrSethStr)
  * [_FreeStrSet(hStr)](#_FreeStrSethStr)
  * [_GetStr(hStr, index)](#_GetStrhStrindex)
  * [_SetStr(hStr, index, sz)](#_SetStrhStrindexsz)
  * [_GetPStr(hStr, index)](#_GetPStrhStrindex)
  * [_SetPStr(hStr, index, sz)](#_SetPStrhStrindexsz)
  * [_CountStr(hStr)](#_CountStrhStr)
* [MISC](#MISC)
  * [_GetLocalTime()](#_GetLocalTime)
  * [_UniNum()](#_UniNum)
  * [_MIN(a, b)](#_MINab)
  * [_MAX(a, b)](#_MAXab)
  * [_GetSIVer()](#_GetSIVer)
  * [_GetCurSelEx()](#_GetCurSelEx)
  * [_GetDir()](#_GetDir)
  * [_GetSIBaseDir()](#_GetSIBaseDir)
  * [_GetExternalBase()](#_GetExternalBase)
  * [_IsFileExist()](#_IsFileExist)
  * [_CopyBuf(hSrc, hDst)](#_CopyBufhSrchDst)

<h1 id="TEST">TEST</h1 >

<h2 id="_Assertexp">_Assert(exp)</h2 >
Assert and stop the macro when enconters unrepairable errors

<h2 id="_Testexpresult">_Test(exp, result)</h2 >
For test case

<h1 id="LOGGING">LOGGING</h1 >

<h2 id="_Logtagsz">_Log{tag}(sz)</h2 >

Log tag and priority is:

	`V`    Verbose
	`D`    Debug
	`I`    Info
	`W`    Warn
	`E`    Error
	`F`    Fatal
	`S`    Silent (supress all output)

Use `_LogV`, `_LogD`, `_LogI`, ...etc to output messages respectively

<h2 id="_SetLogLevelszLevel">_SetLogLevel(szLevel)</h2 >
Set log level

PARAMETERS:

* `szLevel`: character like 'V', 'D', ..., 'S', represent log level, its case sensitive

RETURN VALUE: `Nil`

<h2 id="_LogShow">_LogShow()</h2 >
Show logging messages in temperary buffer

PARAMETERS: N/A

RETURN VALUE: `Nil`

<h2 id="_GenStackInfoiLevel">_GenStackInfo(iLevel)</h2 >
Get function call stack info

PARAMETERS:

* `iLevel`: call stack depth

RETURN VALUE:

* Record Structure
	* `szFunc`: function name
	* `iLine`: line number
	* `szTime`: timestamp

<h1 id="CHARSSTRING">CHARS & STRING</h1 >

<h2 id="_IsSpacech">_IsSpace(ch)</h2 >
Generate rondom number like: "201005062239000"

PARAMETERS:

* `ch`: If ch is a string with more than one character, only the first character is tested

RETURN VALUE:

* Boolean

<h2 id="_AlignStrszlengthchrfAppend">_AlignStr(sz, length, chr, fAppend)</h2 >
Expand string length with specific character

PARAMETERS:

* `sz`: source string
* `length`: required length after expanding
* `chr`: character used
* `fAppend`: if true, append character to the end. Otherwise insert it at the begining

RETURN VALUE:

* String

<h2 id="_StrStrExssubstrichfMatchCasefReverse">_StrStrEx(s, substr, ich, fMatchCase, fReverse)</h2 >
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

<h2 id="_StrStrssubstr">_StrStr(s, substr)</h2 >
Find a sub-string in string s

PARAMETERS:

* `s`: string
* `substr`: sub-string

RETURN VALUE:

* `invalid`: no matching substr has been found
* Integer: location of matching substr

<h2 id="_StrCmpsz1sz2">_StrCmp(sz1, sz2)</h2 >
String comparation

PARAMETERS:

* `sz1`: string
* `sz2`: string

RETURN VALUE:

* `0`: sz1 == sz2
* `1`: sz1 > sz2
* `-1`: sz1 < sz2

<h2 id="_StrClssz">_StrCls(sz)</h2 >
Cut off the blank chars at the both sides of the string

PARAMETERS:

* `sz`: string

RETURN VALUE:

* String: trimmed string

<h2 id="_SearchInStrszpatternfMatchCasefRegExpfWholeWordsOnly">_SearchInStr (sz, pattern, fMatchCase, fRegExp, fWholeWordsOnly)</h2 >
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

<h2 id="_ReplaceInStrszoldPatternnewPatternfMatchCasefRegExpfWholeWordsOnlyfConfirm">_ReplaceInStr (sz, oldPattern, newPattern, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)</h2 >
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

<h2 id="_GetFileNameExtensionpath">_GetFileNameExtension(path)</h2 >
Get filename extension

PARAMETERS:

* `path`: filename path

RETURN VALUE:

* Record Structure:
	* `Nil`: no extension
	* String: extension text

<h2 id="_GetStrByIndexszidxpattern">_GetStrByIndex(sz, idx, pattern)</h2 >
Given a string isolated by delims to some parts, each part is given a index number

PARAMETERS:

* `sz`: text
* `idx`: index number of which part is required
* `pattern`: delims pattern text

RETURN VALUE:

* `Nil`: no valid text found
* Record Structure:
	* `ichFirst`: the index of the first character of  matching text
	* `ichLim`: the limit index (one past the last) of the last character of  matching text
	* `szData`: the matching text

<h2 id="_GetStrCountszpattern">_GetStrCount(sz, pattern)</h2 >
Calculate the number of parts of a string which is delimited by a regexp pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Integer

<h1 id="DYNAMICARRAY">DYNAMIC ARRAY</h1 >

The structure of dynamic array buffer:

	line0: size of array
	line1: first item, index of 0
	line2: second item, index of 1
	...
	lineX: the (X)th item, index of (X-1)

<h2 id="_NewDArray">_NewDArray()</h2 >
New a dynamic array buffer

PARAMETERS: N/A

RETURN VALUE:

* Handle

<h2 id="_FreeDArrayhDArray">_FreeDArray(hDArray)</h2 >
Free the dynamic array buffer by handle

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE: `Nil`

<h2 id="_PushDArrayhDArraysz">_PushDArray(hDArray, sz)</h2 >
Append one new item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_PopDArrayhDArray">_PopDArray(hDArray)</h2 >
Pop out the last item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

<h2 id="_PullDArrayhDArray">_PullDArray(hDArray)</h2 >
Pull out the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

<h2 id="_InsDArrayhDArraysz">_InsDArray(hDArray, sz)</h2 >
Insert a new item as the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_GetDArrayhDArrayindex">_GetDArray(hDArray, index)</h2 >
Read out the content of required item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item

RETURN VALUE:

* String: content of the item

<h2 id="_SetDArrayhDArrayindexsz">_SetDArray(hDArray, index, sz)</h2 >
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_CountDArrayhDArray">_CountDArray(hDArray)</h2 >
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* Integer: array size

<h1 id="STRINGSET">STRING SET</h1 >

<h2 id="_NewStrSetszpattern">_NewStrSet(sz, pattern)</h2 >
Split string by delims identified by regular expression pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Record Structure:
	* `hDataArray`: dynamic array handle of split text
	* `hPatternArray`: dynamic array handle of matching text by pattern

<h2 id="_GetStrSethStr">_GetStrSet(hStr)</h2 >
Combines all the element back to one single string

PARAMETERS:

* `hStr`: handle of string set

RETURN VALUE:

* String

<h2 id="_FreeStrSethStr">_FreeStrSet(hStr)</h2 >
Free string set

PARAMETERS:

* `hStr`: handle of string set

RETURN VALUE: `Nil`

<h2 id="_GetStrhStrindex">_GetStr(hStr, index)</h2 >
Get string by index

PARAMETERS:

* `hStr`: handle of string set
* `index`: index number

RETURN VALUE:

* String

<h2 id="_SetStrhStrindexsz">_SetStr(hStr, index, sz)</h2 >
Set string by index

PARAMETERS:

* `hStr`: handle of string set
* `index`: index number
* `sz`: text

RETURN VALUE: `Nil`

<h2 id="_GetPStrhStrindex">_GetPStr(hStr, index)</h2 >
Get pattern match string by index

PARAMETERS:

* `hStr`: handle of string set
* `index`: index number

RETURN VALUE:

* String

<h2 id="_SetPStrhStrindexsz">_SetPStr(hStr, index, sz)</h2 >
Set pattern match string by index

PARAMETERS:

* `hStr`: handle of string set
* `index`: index number
* `sz`: text

RETURN VALUE: `Nil`

<h2 id="_CountStrhStr">_CountStr(hStr)</h2 >
Get the number of elements

PARAMETERS:

* `hStr`: handle of string set

RETURN VALUE:

* Integer

<h1 id="MISC">MISC</h1 >

<h2 id="_GetLocalTime">_GetLocalTime()</h2 >
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

<h2 id="_UniNum">_UniNum()</h2 >
Generate rondom number like: "201005062239000"

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_MINab">_MIN(a, b)</h2 >
Get the minimal number

PARAMETERS:

RETURN VALUE:

* Integer

<h2 id="_MAXab">_MAX(a, b)</h2 >
Get the maximal number

PARAMETERS:

RETURN VALUE:

* Integer

<h2 id="_GetSIVer">_GetSIVer()</h2 >
Get the source insight version number

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_GetCurSelEx">_GetCurSelEx()</h2 >
Get current selection info and type

PARAMETERS: N/A

RETURN VALUE:

* Record Structure:
	* `sel`: record structure, contains some selection infomation
	* `type`: string, indicate the selection type

<h2 id="_GetDir">_GetDir()</h2 >
Get the directory of szFile

PARAMETERS:

* `szFile`: file path

RETURN VALUE:

* String

<h2 id="_GetSIBaseDir">_GetSIBaseDir()</h2 >
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_GetExternalBase">_GetExternalBase()</h2 >
Get the base directory of external source insight macro scripts

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_IsFileExist">_IsFileExist()</h2 >
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

NOTE:

*This function has no effect for source insight project file*

<h2 id="_CopyBufhSrchDst">_CopyBuf(hSrc, hDst)</h2 >
Copy buffer content from one to another

PARAMETERS:

* `hSrc`: handle of source buffer
* `hDst`: handle of destination buffer

RETURN VALUE: `Nil`

