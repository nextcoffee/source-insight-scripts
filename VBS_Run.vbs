'YangMing @sim.com 2013-09-22

Dim Args
Dim szFunc
Dim ParamLine
Dim fRet

'获取操作函数
Set Args = WScript.Arguments
If Args.Count = 0 Then
	Wscript.Echo "[ERROR][VBS_Run.vbs]参数数目不对"                  & vbcrlf & vbcrlf & _
                 "USAGE："                                           & vbcrlf & _
	             "Wscript //B VBS_Run.vbs <function> [<para_list>] " & vbcrlf
	
	Wscript.quit 1
End If

szFunc          = Args(0)

ReDim Params(Args.Count-1)
For i = 1 To Args.Count-1
  If InStr(Args(i), " ") > 0 Then
    Params(i) = Chr(34) & Args(i) & Chr(34)
  Else
    Params(i) = Args(i)
  End If
Next

ParamLine = Trim(Join(Params, " "))

fRet = 0
'函数分支
Select Case szFunc
	Case "CreateTmpFile"
		If Args.Count <> 2 Then
			Wscript.Echo "[CreateTmpFile] Parameter error"
			Wscript.quit 1
		End If
		fRet = CreateTmpFile(ParamLine)
	
	Case "DeleteTmpFile"
		If Args.Count <> 2 Then
			Wscript.Echo "[DeleteTmpFile] Parameter error"
			Wscript.quit 1
		End If
		fRet = DeleteTmpFile(ParamLine)
		
	Case "RunCMD"
		fRet = RunCMD(ParamLine)
		
	Case "Test"
	Case Else
		Wscript.Echo "[VBS_Run.vbs] Unkonwn function"
		Wscript.quit 2
End Select

Set Args = Nothing
Wscript.quit fRet

'=====================================FUNCTIONs============================================
function CreateTmpFile(fPath)
	Set fsObj = CreateObject("Scripting.FileSystemObject")
	fsObj.CreateTextFile fPath, False
	Set fsObj = Nothing

	CreateTmpFile = 0
End Function

function DeleteTmpFile(fPath)
	Set fsObj = CreateObject("Scripting.FileSystemObject")
	fsObj.DeleteFile fPath, True
	Set fsObj = Nothing

	DeleteTmpFile = 0
End Function

function RunCMD(cmd)
	Dim ret
	
	Set ws = CreateObject("wscript.shell")
	ret = ws.run(cmd, 0, True)
	Set ws = Nothing

	RunCMD = ret
End Function
