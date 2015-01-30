
* [TEST](#TEST)
  * [_Assert](_Assert)
  * [_Test](_Test)
* [LOGGING](#LOGGING)
  * [_Log](_Log)
  * [_SetLogLevel](_SetLogLevel)
  * [_LogShow](_LogShow)
  * [_GenStackInfo](_GenStackInfo)
* [CHARS & STRING](#CHARS & STRING)
  * [_IsSpace](_IsSpace)
  * [_AlignStr](_AlignStr)
  * [_StrStrEx](_StrStrEx)
  * [_StrStr](_StrStr)
  * [_StrCmp](_StrCmp)
  * [_StrCls](_StrCls)
  * [_SearchInStr](_SearchInStr)
  * [_ReplaceInStr](_ReplaceInStr)
  * [_GetFileNameExtension](_GetFileNameExtension)
  * [_GetStrByIndex](_GetStrByIndex)
  * [_GetStrCount](_GetStrCount)
* [DYNAMIC ARRAY](#DYNAMIC ARRAY)
  * [_NewDArray](_NewDArray)
  * [_FreeDArray](_FreeDArray)
  * [_PushDArray](_PushDArray)
  * [_PopDArray](_PopDArray)
  * [_PullDArray](_PullDArray)
  * [_InsDArray](_InsDArray)
  * [_GetDArray](_GetDArray)
  * [_SetDArray](_SetDArray)
  * [_CountDArray](_CountDArray)
* [STRING SET](#STRING SET)
  * [_NewStrSet](_NewStrSet)
* [MISC](#MISC)
  * [_GetLocalTime](_GetLocalTime)
  * [_UniNum](_UniNum)
  * [_MIN](_MIN)
  * [_MAX](_MAX)
  * [_GetSIVer](_GetSIVer)
  * [_GetCurSelEx](_GetCurSelEx)
  * [_GetSIBaseDir](_GetSIBaseDir)
  * [_IsFileExist](_IsFileExist)
  * [_CopyBuf](_CopyBuf)

<h1 id="TEST">TEST</h1>

<h2 id="_Assert">_Assert</h2>
Assert and stop the macro when enconters unrepairable errors

<h2 id="_Test">_Test</h2>
For test case

<h1 id="LOGGING">LOGGING</h1>

<h2 id="_Log">_Log</h2>

Log tag and priority is:

	`V`    Verbose
	`D`    Debug
	`I`    Info
	`W`    Warn
	`E`    Error
	`F`    Fatal
	`S`    Silent (supress all output)

Use `_LogV`, `_LogD`, `_LogI`, ...etc to output messages respectively

<h2 id="_SetLogLevel">_SetLogLevel</h2>
Set log level

PARAMETERS:

* `szLevel`: character like 'V', 'D', ..., 'S', represent log level, its case sensitive

RETURN VALUE: `Nil`

<h2 id="_LogShow">_LogShow</h2>
Show logging messages in temperary buffer

PARAMETERS: N/A

RETURN VALUE: `Nil`

<h2 id="_GenStackInfo">_GenStackInfo</h2>
Get function call stack info

PARAMETERS:

* `iLevel`: call stack depth

RETURN VALUE:

* Record Structure
	* `szFunc`: function name
	* `iLine`: line number
	* `szTime`: timestamp

<h1 id="CHARS & STRING">CHARS & STRING</h1>

<h2 id="_IsSpace">_IsSpace</h2>
Generate rondom number like: "201005062239000"

PARAMETERS:

* `ch`: If ch is a string with more than one character, only the first character is tested

RETURN VALUE:

* Boolean

<h2 id="_AlignStr">_AlignStr</h2>
Expand string length with specific character

PARAMETERS:

* `sz`: source string
* `length`: required length after expanding
* `chr`: character used
* `fAppend`: if true, append character to the end. Otherwise insert it at the begining

RETURN VALUE:

* String

<h2 id="_StrStrEx">_StrStrEx</h2>
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

<h2 id="_StrStr">_StrStr</h2>
Find a sub-string in string s

PARAMETERS:

* `s`: string
* `substr`: sub-string

RETURN VALUE:

* `invalid`: no matching substr has been found
* Integer: location of matching substr

<h2 id="_StrCmp">_StrCmp</h2>
String comparation

PARAMETERS:

* `sz1`: string
* `sz2`: string

RETURN VALUE:

* `0`: sz1 == sz2
* `1`: sz1 > sz2
* `-1`: sz1 < sz2

<h2 id="_StrCls">_StrCls</h2>
Cut off the blank chars at the both sides of the string

PARAMETERS:

* `sz`: string

RETURN VALUE:

* String: trimmed string

<h2 id="_SearchInStr">_SearchInStr</h2>
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

<h2 id="_ReplaceInStr">_ReplaceInStr</h2>
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

<h2 id="_GetFileNameExtension">_GetFileNameExtension</h2>
Get filename extension

PARAMETERS:

* `path`: filename path

RETURN VALUE:

* Record Structure:
	* `Nil`: no extension
	* String: extension text

<h2 id="_GetStrByIndex">_GetStrByIndex</h2>
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

<h2 id="_GetStrCount">_GetStrCount</h2>
Calculate the number of parts of a string which is delimited by a regexp pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Integer

<h1 id="DYNAMIC ARRAY">DYNAMIC ARRAY</h1>

The structure of dynamic array buffer:

	line0: size of array
	line1: first item, index of 0
	line2: second item, index of 1
	...
	lineX: the (X)th item, index of (X-1)

<h2 id="_NewDArray">_NewDArray</h2>
New a dynamic array buffer

PARAMETERS: N/A

RETURN VALUE:

* Handle

<h2 id="_FreeDArray">_FreeDArray</h2>
Free the dynamic array buffer by handle

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE: `Nil`

<h2 id="_PushDArray">_PushDArray</h2>
Append one new item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_PopDArray">_PopDArray</h2>
Pop out the last item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

<h2 id="_PullDArray">_PullDArray</h2>
Pull out the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

<h2 id="_InsDArray">_InsDArray</h2>
Insert a new item as the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_GetDArray">_GetDArray</h2>
Read out the content of required item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item

RETURN VALUE:

* String: content of the item

<h2 id="_SetDArray">_SetDArray</h2>
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item
* `sz`: content of the new item

RETURN VALUE: `Nil`

<h2 id="_CountDArray">_CountDArray</h2>
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* Integer: array size

<h1 id="STRING SET">STRING SET</h1>

<h2 id="_NewStrSet">_NewStrSet</h2>
Split string by delims identified by regular expression pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Record Structure:
	* `hDataArray`: dynamic array handle of split text
	* `hPatternArray`: dynamic array handle of matching text by pattern

<h1 id="MISC">MISC</h1>

<h2 id="_GetLocalTime">_GetLocalTime</h2>
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

<h2 id="_UniNum">_UniNum</h2>
Generate rondom number like: "201005062239000"

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_MIN">_MIN</h2>
Get the minimal number

PARAMETERS:

RETURN VALUE:

* Integer

<h2 id="_MAX">_MAX</h2>
Get the maximal number

PARAMETERS:

RETURN VALUE:

* Integer

<h2 id="_GetSIVer">_GetSIVer</h2>
Get the source insight version number

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_GetCurSelEx">_GetCurSelEx</h2>
Get current selection info and type

PARAMETERS: N/A

RETURN VALUE:

* Record Structure:
	`sel`: record structure, contains some selection infomation
	`type`: string, indicate the selection type

<h2 id="_GetSIBaseDir">_GetSIBaseDir</h2>
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

<h2 id="_IsFileExist">_IsFileExist</h2>
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

NOTE:

*This function has no effect for source insight project file*

<h2 id="_CopyBuf">_CopyBuf</h2>
Copy buffer content from one to another

PARAMETERS:

* `hSrc`: handle of source buffer
* `hDst`: handle of destination buffer

RETURN VALUE: `Nil`

