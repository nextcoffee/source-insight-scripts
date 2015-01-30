# pub.em
Some useful functions

## TEST TOOLS

### _Assert(exp)
Assert and stop the macro when enconters unrepairable errors

### _Test(exp, result)
For test case

## LOGGING TOOL

Log tag and priority is:

	`V`    Verbose
	`D`    Debug
	`I`    Info
	`W`    Warn
	`E`    Error
	`F`    Fatal
	`S`    Silent (supress all output)

Use **_Log{tag}(sz)** like `_LogV`, `_LogD`, `_LogI`, ...etc to output messages respectively

### _SetLogLevel(level)
Set log level

PARAMETERS:

* `szLevel`: character like 'V', 'D', ..., 'S', represent log level, its case sensitive

RETURN VALUE: `Nil`

### _LogShow()
Show logging messages in temperary buffer

PARAMETERS: N/A

RETURN VALUE: `Nil`

### _GenStackInfo(iLevel)
Get function call stack info

PARAMETERS:

* `iLevel`: call stack depth

RETURN VALUE:

* Record Structure
	* `szFunc`: function name
	* `iLine`: line number
	* `szTime`: timestamp

## CHARS & STRING

### _IsSpace(ch)
Generate rondom number like: "201005062239000"

PARAMETERS:

* `ch`: If ch is a string with more than one character, only the first character is tested

RETURN VALUE:

* Boolean

### _AlignStr(sz, length, chr, fAppend)
Expand string length with specific character

PARAMETERS:

* `sz`: source string
* `length`: required length after expanding
* `chr`: character used
* `fAppend`: if true, append character to the end. Otherwise insert it at the begining

RETURN VALUE:

* String

### _StrStrEx(s, substr, ich, fMatchCase, fReverse)
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

### _StrStr(s, substr)
Find a sub-string in string s

PARAMETERS:

* `s`: string
* `substr`: sub-string

RETURN VALUE:

* `invalid`: no matching substr has been found
* Integer: location of matching substr

### _StrCmp(sz1, sz2)
String comparation

PARAMETERS:

* `sz1`: string
* `sz2`: string

RETURN VALUE:

* `0`: sz1 == sz2
* `1`: sz1 > sz2
* `-1`: sz1 < sz2

### _StrCls(sz)
Cut off the blank chars at the both sides of the string

PARAMETERS:

* `sz`: string

RETURN VALUE:

* String: trimmed string

### _SearchInStr (sz, pattern, fMatchCase, fRegExp, fWholeWordsOnly)
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

### _ReplaceInStr (sz, oldPattern, newPattern, fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
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

### _GetFileNameExtension(path)
Get filename extension

PARAMETERS:

* `path`: filename path

RETURN VALUE:

* Record Structure:
	* `Nil`: no extension
	* String: extension text

### _GetStrByIndex(sz, idx, pattern)
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

### _GetStrCount(sz, pattern)
Calculate the number of parts of a string which is delimited by a regexp pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Integer

## DYNAMIC ARRAY

The structure of dynamic array buffer:

	line0: size of array
	line1: first item, index of 0
	line2: second item, index of 1
	...
	lineX: the (X)th item, index of (X-1)

### _NewDArray()
New a dynamic array buffer

PARAMETERS: N/A

RETURN VALUE:

* Handle

### _FreeDArray(hDArray)
Free the dynamic array buffer by handle

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE: `Nil`

### _PushDArray(hDArray, sz)
Append one new item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

### _PopDArray(hDArray)
Pop out the last item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

### _PullDArray(hDArray)
Pull out the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* String: content of the item

### _InsDArray(hDArray, sz)
Insert a new item as the first item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `sz`: content of the new item

RETURN VALUE: `Nil`

### _GetDArray(hDArray, index)
Read out the content of required item

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item

RETURN VALUE:

* String: content of the item

### _SetDArray(hDArray, index, sz)
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer
* `index`: index number of required item
* `sz`: content of the new item

RETURN VALUE: `Nil`

### _CountDArray(hDArray)
Replace the content of required item with new string

PARAMETERS:

* `hDArray`: handle of the dynamic array buffer

RETURN VALUE:

* Integer: array size

## STRING SET

### _NewStrSet(sz, pattern)
Split string by delims identified by regular expression pattern

PARAMETERS:

* `sz`: text
* `pattern`: delims pattern text

RETURN VALUE:

* Record Structure:
	* `hDataArray`: dynamic array handle of split text
	* `hPatternArray`: dynamic array handle of matching text by pattern

## MISC

### _GetLocalTime()
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

### _UniNum()
Generate rondom number like: "201005062239000"

PARAMETERS: N/A

RETURN VALUE:

* String

### _MIN(a, b)
Get the minimal number

PARAMETERS:

RETURN VALUE:

* Integer

### _MAX(a, b)
Get the maximal number

PARAMETERS:

RETURN VALUE:

* Integer

### _GetSIVer()
Get the source insight version number

PARAMETERS: N/A

RETURN VALUE:

* String

### _GetCurSelEx()
Get current selection info and type

PARAMETERS: N/A

RETURN VALUE:

* Record Structure:
	`sel`: record structure, contains some selection infomation
	`type`: string, indicate the selection type

### _GetSIBaseDir()
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

### _IsFileExist()
Get the directory of source insight project named "Base"

PARAMETERS: N/A

RETURN VALUE:

* String

NOTE:

*This function has no effect for source insight project file*

### _CopyBuf(hSrc, hDst)
Copy buffer content from one to another

PARAMETERS:

* `hSrc`: handle of source buffer
* `hDst`: handle of destination buffer

RETURN VALUE: `Nil`

