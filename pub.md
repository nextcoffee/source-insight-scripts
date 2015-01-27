# pub.em
Some useful functions

## TEST TOOLS
***

### _Assert(exp)
Assert and stop the macro when enconters unrepairable errors

### _Test(exp, result)
For test case

## LOGGING TOOL
***

### _GenStackInfo(iLevel)
Get function call stack info

PARAMETERS:

* `iLevel`: call stack depth

RETURN VALUE:

* Record Structure
	* `szFunc`: function name
	* `iLine`: line number
	* `szTime`: timestamp

### _Log(sz)
Logging messages to temperary buffer

PARAMETERS:

* `sz`: message string

RETURN VALUE: `Nil`

### _LogShow()
Show logging messages in temperary buffer

PARAMETERS: N/A

RETURN VALUE: `Nil`

## MISC
***

###_UniNum()
Generate rondom number like: "201005062239000"

PARAMETERS: N/A

RETURN VALUE:

* String

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

## CHARS & STRING
***

### _IsSpace(ch)
Generate rondom number like: "201005062239000"

PARAMETERS:

* `ch`: If ch is a string with more than one character, only the first character is tested

RETURN VALUE:

* Boolean

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

