VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CImportFromExcel"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

Public C_EXCEL_FILE_NAME As String   'Excel文件全路径名
Public C_EXM_NO As String            '要导入的题库代码
Public C_EXM_NAME As String          '要导入的题库名称
Public C_ASP_PATH As String          'ASP文件夹所在位置，含ASP，末尾没有“\”
Public C_EXAM_PATH As String         'EXAM文件夹所在位置，含EXAM，末尾没有“\”
Public C_CONNECT_STR As String       '数据库连接字符串
Public C_OVERWRITE_EXIST As Boolean  '替换题号相同的题否
Public C_SHEET_NAME As String        '第一个sheet工作表的名字
Public C_SHEET2_NAME As String       '第二个sheet工作表的名字
Public C_SHEET3_NAME As String       '第三个sheet工作表的名字
Public C_Test_Id As String           'TestID值

Private ccCourseNo As String         '追加知识点时的默认课程代码
Private ccCourseName As String       '追加知识点时的默认课程名称
Private ccImportPath As String       'Excel文件所在目录，末尾有“\”
Private coConnExcel As ADODB.Connection
Private coRecordExcel As ADODB.Recordset
Private coConnSQL As ADODB.Connection
Private coRecordSQL As ADODB.Recordset

Private Sub Class_Initialize()
   Set coConnExcel = New ADODB.Connection
   Set coRecordExcel = New ADODB.Recordset
   Set coConnSQL = New ADODB.Connection
   Set coRecordSQL = New ADODB.Recordset
End Sub

Private Sub Class_Terminate()
   'coConnSQL.Close
   'coConnExcel.Close
   Set coConnSQL = Nothing
   Set coConnExcel = Nothing
End Sub

'返回:成功则返回空字符串,否则就返回错误信息字符串
'exam不再对应crs_no。'2008/06/04：给此函数加参数pCoursNo，得到对应题库的知识点
'Public Function ImportExamFromExcel(pCoursNo As String) As String
Public Function ImportExamFromExcel() As String
   Dim lcRetStr As String
   Dim lcPath As String
   Dim lnPos As Long
   
   Err.Clear
   On Error Resume Next
   
   '取得Excel文件所在目录
   lcPath = C_EXCEL_FILE_NAME
   lnPos = InStrRev(lcPath, "\")
   If lnPos > 0 Then
      lcPath = Left(lcPath, lnPos - 1)
   End If
   ccImportPath = lcPath & "\"
   
   lcRetStr = ConnDB()
   '2008/07/03
   'If lcRetStr = "" And err.Number = 0 Then
   '   lcRetStr = GetCrsInfo(pCoursNo)    '取指定题库对应的课程信息到类模块全局变量中
   'End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkCell()       '检查EXCEL文件是否有NULL列
'   End If
   '2010/04/23:Excel题库导入时，不在导入课程代码信息
   'If lcRetStr = "" And err.Number = 0 Then
   '   lcRetStr = ChkCrsInfo()      '检查EXCEL文件课程信息
   'End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkKnowledge()  '检查EXCEL文件知识点填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkOpExam()  '检查EXCEL文件操作题答题文件夹和答题入口是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkQstHtmlPic()  '检查EXCEL文件网页嵌入图片信息填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkQstDld()  '检查EXCEL文件下载文档填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkQstPic()  '检查EXCEL文件附属图片填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkQstPlayFile()  '检查EXCEL文件知识点填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = ChkTZ()  '检查EXCEL文件题组信息填写是否正确
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      '如果[Sheet1]中有评分规则，检查
'      If Not ChkSheet2IsNull() Then
'         lcRetStr = ChkSheet2Rule()
'      End If
'   End If
   
   '2008/07/03：导入课程信息
   'If lcRetStr = "" And err.Number = 0 Then
   '   lcRetStr = ImpCrsInfo()
   'End If

   
   If lcRetStr = "" And Err.Number = 0 Then '导入知识点
      lcRetStr = ImpNewKnowledge()
   End If
   If lcRetStr = "" And Err.Number = 0 Then '导入题库
      lcRetStr = ImpExam()
   End If
   
   If lcRetStr = "" And Err.Number = 0 Then
      lcRetStr = ImpQst()  '导入question表
   End If
   If lcRetStr = "" And Err.Number = 0 Then
      lcRetStr = ImpTest()  '导入抽题试卷
   End If
   If lcRetStr = "" And Err.Number = 0 Then
      lcRetStr = ImpTemplate()  '导入template表
   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      If Not ChkSheet2IsNull() Then
'         lcRetStr = ImpRule()
'      End If
'   End If
'   If lcRetStr = "" And Err.Number = 0 Then
'      lcRetStr = CopyFolders()
'   End If
   
   ImportExamFromExcel = lcRetStr
End Function

'功能:建立EXCEL和SQL的数据库连接,初始化EXCEL和SQL的记录集
'返回:成功则返回空字符串,否则就返回错误信息字符串
Private Function ConnDB() As String
   Err.Clear
   On Error Resume Next
   
   coConnExcel.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _
                    "Data Source= " & Trim(C_EXCEL_FILE_NAME) & _
                    ";Extended Properties='Excel 8.0;IMEX=1'"
   If Err.Number <> 0 Then
      ConnDB = "系统错误或文件类型不正确"
      Exit Function
   Else
      coRecordExcel.ActiveConnection = coConnExcel
      coConnSQL.Open C_CONNECT_STR
      coRecordSQL.ActiveConnection = coConnSQL
      coRecordSQL.CursorLocation = adUseClient
      coRecordSQL.CursorType = adOpenKeyset
      coRecordSQL.LockType = adLockBatchOptimistic
   End If
   If Err.Number = 0 Then
      ConnDB = ""
   Else
      '2009/05/31:ConnDB = "数据库连接错误：" & err.Description
      ConnDB = "Excel文件打开错误：" & Err.Description
   End If
End Function

'得到Excel工作表Sheet1的行数
Public Function GetExlCnt(vExlPath As String) As Long
   Dim MyApp As Excel.Application
   Dim MyBook As Excel.Workbook
   Dim MySheet As Excel.Worksheet
   Dim cnt As Long
   
   Err.Clear
   On Error Resume Next
   
   Set MyApp = New Excel.Application
   MyApp.Visible = False
   '打开已经存在的 EXCEL 工件簿文件
   Set MyBook = MyApp.Workbooks.Open(vExlPath)
   If Err.Number <> 0 Then
      Err.Clear
      MsgBox "导入题库文件不是Excel格式文件"
      Exit Function
   End If
   'Set MyBook = MyApp.Workbooks.Add
   '设置活动工作表
   Set MySheet = MyBook.Worksheets(1)
   'MySheet.Activate '激活工作表
   'MyBook.RunAutoMacros (xlAutoOpen) '运行EXCEL中的启动宏
   '得到excel表sheet1的所有行数
   cnt = MySheet.UsedRange.Rows.Count
   'MyBook.RunAutoMacros (xlAutoClose) '执行EXCEL关闭宏
   MyBook.Close (True) '关闭工作簿
   MyApp.Quit '结束EXCEL对象
   Set MyApp = Nothing '释放xlApp对象
   GetExlCnt = cnt
End Function

'功能：检查Excel工作表Sheet2中标题行是否为空
'返回：空为true
Private Function ChkExlIsNull(vExlPath As String) As Boolean
   Dim MyApp As Excel.Application
   Dim MyBook As Excel.Workbook
   Dim MySheet As Excel.Worksheet
   Dim lcStrExlCells As String     'Excel单元格的值
   
   Err.Clear
   On Error Resume Next
   
   Set MyApp = New Excel.Application
   MyApp.Visible = False
   '打开已经存在的 EXCEL 工件簿文件
   Set MyBook = MyApp.Workbooks.Open(vExlPath)
   Set MySheet = MyBook.Worksheets(2)
   
   '得到Excel[sheet2]一行一列的值
   lcStrExlCells = MySheet.Cells(1, 1)
   If lcStrExlCells <> "试题代码" Then
      ChkExlIsNull = True
   End If

   MyBook.Close (True)
   MyApp.Quit
   Set MyApp = Nothing
End Function

'2008/07/03
''功能:根据题库代码得到题库的课程信息,保存到ccCourseNo和ccCourseName中
''返回:成功则返回空字符串,否则就返回错误信息字符串
''2008/06/05：给此函数加参数pSysType，即考试系统代码
'Private Function GetCrsInfo(pCoursNo As String) As String
   
'   err.Clear
'   On Error Resume Next
   
'   GetCrsInfo = ""
'   '2008/06/05：由考试系统代码判断要查询的表
'   If pCoursNo <> "" Then
'      ccCourseNo = pCoursNo
'      coRecordSQL.Open "select crs_no,crs_name from course where crs_no='" & ccCourseNo & "'"
'      ccCourseName = coRecordSQL("crs_name")
'   Else
'      GetCrsInfo = "找不到指定题库[" & C_EXM_NO & "]对应的课程"
'   End If
'   coRecordSQL.Close
'End Function

''功能:检查EXCEL中必填列是否填写,试题代码是否重复
''返回:成功则返回空字符串,否则就返回错误信息字符串
'Private Function ChkCell_Old() As String
'   ChkCell = ""
'
'   err.Clear
'   On Error Resume Next
'
'   coRecordExcel.Open "SELECT * FROM [Sheet1$] where 试题代码 is null or trim(试题代码)=''"
'   If Not coRecordExcel.EOF Then
'      ChkCell = "EXCEL文件中试题代码列标题错误或该列有空值"
'   End If
'   coRecordExcel.Close
'
'   If ChkCell = "" Then
'      coRecordExcel.Open "SELECT * FROM [Sheet1$] where  试题类型 is null or trim(试题类型)=''"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "EXCEL文件中试题类型列标题错误或该列有空值"
'      End If
'      coRecordExcel.Close
'   End If
'
'   If ChkCell = "" Then
'      coRecordExcel.Open "SELECT * FROM [Sheet1$] where 知识点代码 is null or trim(知识点代码)=''"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "EXCEL文件中知识点代码列标题错误或该列有空值"
'      End If
'      coRecordExcel.Close
'   End If
'
'   If ChkCell = "" Then
'      coRecordExcel.Open "SELECT * FROM [Sheet1$] where 试题内容 is null or trim(试题内容)=''"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "EXCEL文件中试题内容列标题错误或该列有空值"
'      End If
'      coRecordExcel.Close
'   End If
'
'   '2008/05/29：检查本题分值
'   If ChkCell = "" Then
'      coRecordExcel.Open "SELECT * FROM [Sheet1$] where 本题分值 is null or 本题分值<=0"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "EXCEL文件中本题分值列标题错误或该列有空值或0值"
'      End If
'      coRecordExcel.Close
'   End If
'
'   If ChkCell = "" Then
'      coRecordExcel.Open "select 试题代码, count(*) from [Sheet1$] group by 试题代码 having count(*)>1"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "Excel中试题代码列有重复值[" & coRecordExcel("试题代码") & "]"
'      End If
'      coRecordExcel.Close
'   End If
'
'   '2008/07/03：检查课程代码列
'   If ChkCell = "" Then
'      coRecordExcel.Open "select * from [Sheet1$] where 课程代码 is null or trim(课程代码)=''"
'      If Not coRecordExcel.EOF Then
'         ChkCell = "EXCEL文件中课程代码列标题错误或该列有空值或0值"
'      End If
'      coRecordExcel.Close
'   End If
'End Function

'功能:检查EXCEL中必填列是否填写,试题代码是否重复
'返回:成功则返回空字符串,否则就返回错误信息字符串
Private Function ChkCell() As String
   ChkCell = ""

   Err.Clear
   On Error Resume Next
   
   Dim lnRow As Long
   lnRow = 1
   coRecordExcel.Open "SELECT * FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "打开Sheet1出错，试题必须存储在Excel文件的Sheet1工作表中"
      Exit Function
   End If
   coRecordExcel.Close
    '2010/04/23:Excel题库导入时，不在导入课程代码信息
   'coRecordExcel.Open "SELECT 课程代码 FROM [Sheet1$] "
   'If err.Number <> 0 Then
   '   ChkCell = "请确定Sheet1工作表中有[课程代码]列"
   '   Exit Function
   'End If
   'coRecordExcel.Close
  
   'coRecordExcel.Open "SELECT 课程名称 FROM [Sheet1$] "
   'If err.Number <> 0 Then
   '   ChkCell = "请确定Sheet1工作表中有[课程名称]列"
   '   Exit Function
   'End If
   'coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 知识点代码 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[知识点代码]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 知识点名称 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[知识点名称]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 试题代码 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[试题代码]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 试题名称 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[试题名称]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 试题类型 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[试题类型]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 试题内容 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[试题内容]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 标准答案 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[标准答案]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 本题分值 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[本题分值]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 选项数目 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[选项数目]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 素材文件 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[素材文件]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 附属图片 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[附属图片]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 嵌入图片 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[嵌入图片]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT  下载文档 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[下载文档]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 媒体文件 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[媒体文件]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 播放类型 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[播放类型]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 播放次数 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[播放次数]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT 题组试题 FROM [" & C_SHEET_NAME & "$] "
   If Err.Number <> 0 Then
      ChkCell = "请确定Sheet1工作表中有[题组试题]列"
      Exit Function
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "SELECT * FROM [" & C_SHEET_NAME & "$] "
   Do While Not coRecordExcel.EOF
      If IsNull(coRecordExcel("试题代码")) Or Trim(coRecordExcel("试题代码")) = "" Then
         'ChkCell = "第" & lnRow & "道试题中试题代码列标题错误或该列有空值"
         ChkCell = "试题代码列标题错误或该列第" & lnRow + 2 & "行试题代码中有空值"
         Exit Do
      End If
      
      If IsNull(coRecordExcel("试题类型")) Or Trim(coRecordExcel("试题类型")) = "" Then
         'ChkCell = "第" & lnRow & "道试题中试题类型列标题错误或该列有空值"
         ChkCell = "试题类型列标题错误或该列第" & lnRow + 2 & "行试题类型中有空值"
         Exit Do
      End If
   
      If IsNull(coRecordExcel("知识点代码")) Or Trim(coRecordExcel("知识点代码")) = "" Then
         'ChkCell = "第" & lnRow & "道试题中知识点代码列标题错误或该列有空值"
         ChkCell = "知识点代码列标题错误或该列第" & lnRow + 2 & "行知识点代码中有空值"
         Exit Do
      End If
   
      If IsNull(coRecordExcel("试题内容")) Or Trim(coRecordExcel("试题内容")) = "" Then
         'ChkCell = "第" & lnRow & "道试题中试题内容列标题错误或该列有空值"
         ChkCell = "试题内容列标题错误或该列第" & lnRow + 2 & "行试题内容中有空值"
         Exit Do
      End If
   
      If IsNull(coRecordExcel("本题分值")) Or coRecordExcel("本题分值") <= 0 Then
         'ChkCell = "第" & lnRow & "道试题中本题分值列标题错误或0值"
         ChkCell = "本题分值列标题错误或第" & lnRow + 2 & "行试题分值中为0或空值"
         Exit Do
      End If
      '2010/04/27:导入时不再检查课程信息
'      If IsNull(coRecordExcel("课程代码")) Or Trim(coRecordExcel("课程代码")) = "" Then
'         ChkCell = "第" & lnRow & "道试题中课程代码列标题错误或该列有空值"
'         Exit Do
'      End If
      
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   coRecordExcel.Open "select 试题代码, count(*) from [" & C_SHEET_NAME & "$] group by 试题代码 having count(*)>1"
   If Not coRecordExcel.EOF Then
      ChkCell = "Excel中试题代码有重复值[" & coRecordExcel("试题代码") & "]"
   End If
   coRecordExcel.Close
End Function

'2008/07/03
'功能：检查课程信息
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ChkCrsInfo() As String
   Dim lcErrMsg As String
   Dim loConn_ST As New ADODB.Connection
   Dim loRs_ST As New ADODB.Recordset
   Dim lsCrsNo As String    '2008/07/03：存放新课程的课程代码
   Dim lnCrsNum As Long
   Dim lsAryCrsNo() As String
   Dim i As Long
   
   Err.Clear
   On Error Resume Next
   
   loConn_ST.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _
              "Data Source= " & Trim(C_EXCEL_FILE_NAME) & _
              ";Extended Properties='Excel 8.0;IMEX=1'"
   loRs_ST.ActiveConnection = loConn_ST
   lcErrMsg = ""
   lnCrsNum = 0
   
   '检查知识点必须对应一门课程
   coRecordExcel.Open "select distinct 知识点代码 FROM [" & C_SHEET_NAME & "$]"
   Do While Not coRecordExcel.EOF And lcErrMsg = ""
      loRs_ST.Open "select distinct 课程代码 from [" & C_SHEET_NAME & "$] where 知识点代码='" & coRecordExcel("知识点代码") & "'"
      Do While Not loRs_ST.EOF
         lnCrsNum = lnCrsNum + 1
         loRs_ST.MoveNext
      Loop
      If lnCrsNum > 1 Then
         lcErrMsg = "Excel中知识点代码" & coRecordExcel("知识点代码") & "对应多个课程"
      End If
      coRecordExcel.MoveNext
      loRs_ST.Close
      lnCrsNum = 0
   Loop
   coRecordExcel.Close
   
   '检查[Sheet1$]有课程是数据库中没有的，并且如果是新课程那么应该有知识点名称
   If lcErrMsg = "" Then
      lsCrsNo = ""
      coRecordExcel.Open "select distinct 课程代码,课程名称 FROM [" & C_SHEET_NAME & "$]"
      Do While Not coRecordExcel.EOF And lcErrMsg = ""
         coRecordSQL.Open "select crs_no from course where crs_no ='" & coRecordExcel("课程代码") & "'"
         If coRecordSQL.EOF Then
            lnCrsNum = lnCrsNum + 1
            If IsNull(coRecordExcel("课程名称")) Then
               lcErrMsg = "Excel中课程代码" & coRecordExcel("课程代码") & "没有写课程名称"
            End If
            lsCrsNo = lsCrsNo & coRecordExcel("课程代码") & "\\\"
         End If
         coRecordExcel.MoveNext
         coRecordSQL.Close
      Loop
      coRecordExcel.Close
   End If
   
   
   '如果是新课程，那么其对应的知识点也应是新的。
   If lcErrMsg = "" And lnCrsNum > 0 Then
      lsAryCrsNo = Split(lsCrsNo, "\\\")
      For i = 0 To UBound(lsAryCrsNo) - 1
         coRecordExcel.Open "select distinct 知识点代码,知识点名称 FROM [" & C_SHEET_NAME & "$] where 课程代码='" & lsAryCrsNo(i) & "'"
         coRecordSQL.Open "select knowledge_no from knowledge where knowledge_no='" & coRecordExcel("知识点代码") & "'"
         If Not coRecordSQL.EOF Then
            lcErrMsg = "Excel中课程代码" & lsAryCrsNo(i) & "的知识点不是新的知识点"
         End If
         coRecordExcel.Close
         coRecordSQL.Close
      Next
   End If
   ChkCrsInfo = lcErrMsg
End Function

'功能：检查知识点信息
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ChkKnowledge() As String
   Dim lcErrMsg As String
   
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   ''检查[Sheet1$]的知识点代码是否是别的课程的知识点
   'coRecordExcel.Open "SELECT distinct 知识点代码 FROM [Sheet1$]"
   'Do While Not coRecordExcel.EOF And ChkKnowledge = ""
   '   coRecordSQL.Open "SELECT Knowledge_no,crs_no,Knowledge_name FROM Knowledge where crs_no<>'" & ccCourseNo & _
   '                    "' and Knowledge_no =" & "'" & coRecordExcel("知识点代码") & "'"
   '   If Not coRecordSQL.EOF Then
   '      lcErrMsg = "Excel的[Sheet1]知识点[" & coRecordSQL("Knowledge_no") & "]在课程[" & coRecordSQL("crs_no") & "]中"
   '   End If
   '   coRecordExcel.MoveNext
   '   coRecordSQL.Close
   'Loop
   'coRecordExcel.Close

   '检查[Sheet1$]有知识点是数据库中没有的，并且如果是新知识点那么应该有知识点名称
   If lcErrMsg = "" Then
      coRecordExcel.Open "select distinct 知识点代码,知识点名称 FROM [" & C_SHEET_NAME & "$]"
      Do While Not coRecordExcel.EOF And ChkKnowledge = ""
         coRecordSQL.Open "select knowledge_no from knowledge where knowledge_no ='" & coRecordExcel("知识点代码") & "'"
         If coRecordSQL.EOF Then
            If IsNull(coRecordExcel("知识点名称")) Then
               lcErrMsg = "Excel中知识点代码" & coRecordExcel("知识点代码") & "没有写知识点名称"
            End If
         End If
         coRecordExcel.MoveNext
         coRecordSQL.Close
      Loop
      coRecordExcel.Close
   End If
   ChkKnowledge = lcErrMsg
         
   ''检查知识点代码同知识点名称的对应
   'Dim loConn_ST As New ADODB.Connection
   'Dim loRs_sT As New ADODB.Recordset
   'loConn_ST.Open C_CONNECT_STR
   'loRs_sT.ActiveConnection = loConn_ST
   'coRecordExcel.Open "select DISTINCT Knowledge_no from [Sheet1$]"
   'Do While Not coRecordExcel.EOF
   '   loRs_sT.Open "select DISTINCT knowledge_name from [Sheet1$] where knowledge_name is not null and Knowledge_no='" & coRecordExcel("Knowledge_no") & "'"
   '   Dim lnCnt As Integer
   '   lnCnt = 0
   '   Do While Not loRs_sT.EOF
   '      lnCnt = lnCnt + 1
   '      loRs_sT.MoveNext
   '   Loop
   '   loRs_sT.Close
   '   If lnCnt > 1 Then
   '      C_StrInfoMsg = C_StrInfoMsg & "Excel中知识点" & coRecordExcel("Knowledge_no") & "对应多个知识点名称。" & "\\"
   '   End If
   '   coRecordExcel.MoveNext
   'Loop
   'loConn_ST.Close
   'Set loConn_ST = Nothing
   'coRecordExcel.Close
End Function

'检查操作题的答题文件夹和答题入口
'答题文件夹为qst_dir列，根据Excel文件的路径\Exam+qst_dir的内容，找到答题文件夹，在把该文件拷贝到Bsschool\data\exam下
'答题入口，一般根据Excel文件的路径\Exam+qst_asw的值，查找答题入口的正确性；下面列出的是特殊的题型：
'WebMail       试题类型：35  答题入口(qst_no)：wmLogin.asp。答入口查找格式：判断qst_asw的内容是否为"wmLogin.asp"
'VFP           试题类型：24  答题入口(qst_no)：可以没有，因此不检查VFP题型的答题入口
'Inter网       试题类型：25  答题入口(qst_no)：Net\*\*形式。答入口查找格式：Excel文件的路径\+qst_asw
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ChkOpExam() As String
   Dim lcErrMsg As String
   Dim lcExamPath As String

   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   coRecordExcel.Open "select 试题代码 from [" & C_SHEET_NAME & "$] where 试题类型>20 and 素材文件 is null and 素材文件=''"
   If Not coRecordExcel.EOF Then
      lcErrMsg = "试题[" & coRecordExcel("试题代码") & "]的素材文件列为空"
   End If
   coRecordExcel.Close
   
   '检查操作题的答题入口同Exam中的是否对应
   'VFP没有答题入口，文字录入是固定的答题入口，因特网去Net中找
   '先检查除了VFP外的操作题的答案列是否为空(答题入口不空正确)
   If lcErrMsg = "" Then
      coRecordExcel.Open "select 试题代码,标准答案 from [" & C_SHEET_NAME & "$] where 试题类型>20 and 试题类型<>24 and 标准答案 is null and 标准答案<>''"
      If Not coRecordExcel.EOF Then
         lcErrMsg = "试题" & coRecordExcel("试题代码") & "没有答题入口"
      End If
      coRecordExcel.Close
   End If
   
   If lcErrMsg = "" Then
      coRecordExcel.Open "select 试题代码,标准答案,试题类型,素材文件 from [" & C_SHEET_NAME & "$] where 试题类型>20 and 试题类型<>24 and 试题类型<>29 and 试题类型<>30 and 试题类型<>31"
      Do While Not coRecordExcel.EOF
         lcExamPath = ccImportPath & "Exam\" & coRecordExcel("素材文件")
         '因特网试题
         If coRecordExcel("试题类型") = "25" Then
            '检查答题文件夹存在性
            If Dir(lcExamPath, vbDirectory) = "" Then
               lcErrMsg = "因特网试题" & coRecordExcel("试题代码") & "答题文件夹不存在"
            '检查答题入口正确性
            ElseIf Dir(ccImportPath + coRecordExcel("标准答案")) = "" Then
               C_StrInfoMsg = C_StrInfoMsg & "因特网试题" & coRecordExcel("试题代码") & "没有答题网页。" & "\\"
            End If
         'WebMail试题
         ElseIf coRecordExcel("试题类型") = "35" Then
               '检查答题文件夹存在性
               If Dir(lcExamPath + "\WebMail", vbDirectory) = "" Then
                  lcErrMsg = "WebMail试题" & coRecordExcel("试题代码") & "答题文件夹不存在。"
               '检查答题入口正确性
               ElseIf coRecordExcel("标准答案") <> "wmLogin.asp" Then
                  lcErrMsg = "WebMail试题" & coRecordExcel("试题代码") & "答题入口不正确。"
               End If
         'Windows操作题
         ElseIf coRecordExcel("试题类型") = "21" Then
               '检查答题文件夹存在性
               If Dir(lcExamPath, vbDirectory) = "" Then
                  lcErrMsg = "Windows操作题" & coRecordExcel("试题代码") & "答题文件夹不存在"
               '检查答题入口正确性
               ElseIf Dir(lcExamPath & "\" & coRecordExcel("标准答案"), vbDirectory) = "" Then
                  lcErrMsg = "Windows操作题" & coRecordExcel("试题代码") & "答题入口不正确"
               End If
         '其他的试题
         Else
            '检查答题文件夹存在性
            If Dir(lcExamPath, vbDirectory) = "" Then
               lcErrMsg = "操作题试题" & coRecordExcel("试题代码") & "答题文件夹不存在"
            '检查答题入口正确性
            ElseIf Dir(lcExamPath & "\" & coRecordExcel("标准答案")) = "" Then
               lcErrMsg = "操作题试题" & coRecordExcel("试题代码") & "答题入口不正确"
            End If
         End If
         coRecordExcel.MoveNext
      Loop
      coRecordExcel.Close
   End If
   
   ChkOpExam = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'检查网页嵌入图片
'如果Excel中的qst_htmlpic列不空，根据：Excel文件的路径\Ximages+网页潜入图片列(qst_htmlpic)查找文档
'如果一题有多个附属图片，qst_htmlpic形式为(a.bmp;b.bmp\\)，因此要根据qst_htmlpic中的";"循环查找图片
Private Function ChkQstHtmlPic() As String
   Dim lcPicPath As String
   Dim lcPNum As Integer
   Dim i As Integer
   Dim laPicFile() As String
   Dim lcErrMsg As String
   
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   coRecordExcel.Open "select 试题代码,嵌入图片 from [" & C_SHEET_NAME & "$] where 嵌入图片 is not null and 嵌入图片<>''"
   lcPicPath = ccImportPath + "Ximages\"
   Do While Not coRecordExcel.EOF And lcErrMsg = ""
      laPicFile = Split(Replace(coRecordExcel("嵌入图片"), "；", ";"), ";")
      lcPNum = UBound(laPicFile)
      For i = 0 To lcPNum
         If Dir(lcPicPath + laPicFile(i), vbDirectory) = "" Then
            lcErrMsg = "试题" & coRecordExcel("试题代码") & "的网页嵌入图片" & laPicFile(i) & "不存在"
         End If
         If lcErrMsg <> "" Then
            Exit For
         End If
      Next i
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   ChkQstHtmlPic = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'功能：检查下载文档
'如果Excel中的qst_dld列不空，根据：Excel文件的路径\Doc+下载文档列(qst_dld)查找文档
Private Function ChkQstDld() As String
   Dim lcDocPath As String
  
   Err.Clear
   On Error Resume Next
   
   ChkQstDld = ""
   lcDocPath = ccImportPath + "DOC\"
   coRecordExcel.Open "select 试题代码, 下载文档 from [" & C_SHEET_NAME & "$] where 下载文档 is not null and 下载文档<>''"
   Do While Not coRecordExcel.EOF
      If Dir(lcDocPath + coRecordExcel("下载文档"), vbDirectory) = "" Then
          ChkQstDld = "试题" & coRecordExcel("试题代码") & "的下载文档不存在"
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'检查附属图片
'如果Excel中的qst_pic列不空，根据：Excel文件的路径\Ximages+附属图片列(qst_pic)查找文档
'注意：在数据库中，如果一个题使用多个附属图片，数据库qst_pic形式为(a.bmp\\b.bmp\\)，因此要根据qst_pic中的"\\"循环查找图片
Private Function ChkQstPic() As String
   Dim lcPicPath As String
   Dim lcPNum As Integer
   Dim i As Integer
   Dim laPicFile() As String
   Dim lcErrMsg As String
  
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   coRecordExcel.Open "select 试题代码,附属图片 from [" & C_SHEET_NAME & "$] where 附属图片 is not null and 附属图片<>''"
   lcPicPath = ccImportPath + "Ximages\"
   Do While Not coRecordExcel.EOF And lcErrMsg = ""
      laPicFile = Split(coRecordExcel("附属图片"), "\\")
      lcPNum = UBound(laPicFile)
      For i = 0 To lcPNum
         If Dir(lcPicPath + laPicFile(i), vbDirectory) = "" Then
            lcErrMsg = "试题" & coRecordExcel("试题代码") & "的附属图片" & laPicFile(i) & "不存在"
         End If
         If lcErrMsg <> "" Then
            Exit For
         End If
      Next i
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   ChkQstPic = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'检查媒体文件是否存在
Private Function ChkQstPlayFile() As String
   Dim lcErrMsg As String
  
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   coRecordExcel.Open "select 试题代码, 媒体文件 from [" & C_SHEET_NAME & "$] where 媒体文件 is not null and 媒体文件<>''"
   Dim lcPlyFilePath As String
   lcPlyFilePath = ccImportPath + "media\"
   Do While Not coRecordExcel.EOF
      If Dir(lcPlyFilePath + coRecordExcel("媒体文件"), vbDirectory) = "" Then
         lcErrMsg = "试题" & coRecordExcel("试题代码") & "的媒体文件不存在"
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   ChkQstPlayFile = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'2008/06/11：检查题组试题
Private Function ChkTZ() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   coRecordExcel.Open "select 题组试题 from [" & C_SHEET_NAME & "$]"
   coRecordExcel.Close
   '如果有题组试题这一列
   If Err.Number = 0 Then
      '如果试题类型是10，那么“题组试题”列不允许有值
      coRecordExcel.Open "select 试题代码, 题组试题 from [" & C_SHEET_NAME & "$] where 试题类型=10 and 题组试题<>''"
      If Not coRecordExcel.EOF Then
         lcErrMsg = "试题：" & coRecordExcel("试题代码") & "是题组类型，不允许有题组试题"
      End If
      coRecordExcel.Close
      
      If lcErrMsg = "" Then
         Dim loConn_ST As New ADODB.Connection
         Dim loRs_ST As New ADODB.Recordset
      
         loConn_ST.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _
                    "Data Source= " & Trim(C_EXCEL_FILE_NAME) & _
                    ";Extended Properties='Excel 8.0;IMEX=1'"
         loRs_ST.ActiveConnection = loConn_ST
         
         '如果试题类型是10，那么该题应该有对应的题组试题
         coRecordExcel.Open "select 试题代码 from [" & C_SHEET_NAME & "$] where 试题类型=10"
         Do While (Not coRecordExcel.EOF) And lcErrMsg = ""
            loRs_ST.Open "select 试题代码 from [" & C_SHEET_NAME & "$] where 题组试题='" & coRecordExcel("试题代码") & "'"
            If loRs_ST.EOF Then
               lcErrMsg = "题组定义" & coRecordExcel("试题代码") & "没有题组试题"
            End If
            loRs_ST.Close
            coRecordExcel.MoveNext
         Loop
         coRecordExcel.Close
         
         '如果试题的“题组试题”不为空，那么它应该有对应的题组定义
         coRecordExcel.Open "select 试题代码,题组试题 from [" & C_SHEET_NAME & "$] where 题组试题<>''"
         Do While (Not coRecordExcel.EOF) And lcErrMsg = ""
            loRs_ST.Open "select 试题代码,试题类型 from [" & C_SHEET_NAME & "$] where 试题代码='" & coRecordExcel("题组试题") & "'"
            If loRs_ST.EOF Then
               lcErrMsg = "题组试题" & coRecordExcel("试题代码") & "没有对应的题组定义：" & coRecordExcel("题组试题")
            '如果有题组定义，但是该题的试题类型不为10
            ElseIf (Not loRs_ST.EOF) And loRs_ST("试题类型") <> 10 Then
               lcErrMsg = "题组定义" & loRs_ST("试题代码") & "的试题类型错"
            End If
            loRs_ST.Close
            coRecordExcel.MoveNext
         Loop
         coRecordExcel.Close
         
         loConn_ST.Close
         Set loRs_ST = Nothing
         Set loConn_ST = Nothing
      End If
   Else
      Err.Clear
   End If
   ChkTZ = lcErrMsg
End Function

'检查：1、[Sheet2]是否有代码列，没有，证明[Sheet2]是空的，会返回TRUE，不导入评分规则
'      2、如果有代码列，但是[Sheet2]中没有记录时，会返回TRUE，也不导入评分规则
'      3、如果有代码列，且[Sheet2]中有记录时，会返回FALSE，导入评分规则
Private Function ChkSheet2IsNull() As Boolean
   
   Err.Clear
   On Error Resume Next
   
   If Not ChkExlIsNull(C_EXCEL_FILE_NAME) Then
      'coRecordExcel.Open "select * from [Sheet2$] where (试题代码 is not null or 试题代码<>'') or (评分序号<>'' or 评分序号 is not null) " & _
      '                   "or (规则代码<>''or 规则代码 is not null)"
      coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (试题代码 is not null or 试题代码<>'')"
      If coRecordExcel.EOF Then
         ChkSheet2IsNull = True   '[Sheet2]无记录，不导入评分规则
      End If
      coRecordExcel.Close

      coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (规则代码 is not null or 规则代码<>'')"
      If coRecordExcel.EOF Then
         ChkSheet2IsNull = True   '[Sheet2]无记录，不导入评分规则
      End If
      coRecordExcel.Close
      
      coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (评分序号<>'' or 评分序号 is not null)"
      If coRecordExcel.EOF Then
         ChkSheet2IsNull = True   '[Sheet2]无记录，不导入评分规则
      End If
      coRecordExcel.Close
   Else
      ChkSheet2IsNull = True       '[Sheet2]为空，不导入评分规则
   End If
End Function

'功能：检查操作题评分规则信息
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ChkSheet2Rule() As String
   Dim lcErrMsg As String
   
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   '检查[Sheet2]的必填列
   coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (试题代码 is null or trim(试题代码)='')"
   If Not coRecordExcel.EOF Then
      lcErrMsg = "Excel文件的Sheet2中试题代码列不能有空值"
   End If
   coRecordExcel.Close
   
   If lcErrMsg = "" Then
      coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (trim(评分序号)=''or 评分序号 is null)"
      If Not coRecordExcel.EOF Then
         lcErrMsg = "Excel文件的Sheet2中评分序号列不能有空值"
      End If
      coRecordExcel.Close
   End If
   
   If lcErrMsg = "" Then
      coRecordExcel.Open "select * from [" & C_SHEET2_NAME & "$] where (trim(规则代码)='' or 规则代码 is null)"
      If Not coRecordExcel.EOF Then
         lcErrMsg = "Excel文件的Sheet2中规则代码列不能有空值"
      End If
      coRecordExcel.Close
   End If
   
   '检查[Sheet2]的prop_no列
   If lcErrMsg = "" Then
      coRecordExcel.Open "select DISTINCT 规则代码 from [" & C_SHEET2_NAME & "$]"
      Do While Not coRecordExcel.EOF And lcErrMsg = ""
         coRecordSQL.Open "select DISTINCT prop_no from property where prop_no='" & coRecordExcel("规则代码") & "'"
         If coRecordSQL.EOF Then
            lcErrMsg = "Excel文件的[Sheet2]中规则代码列值[" & coRecordExcel("规则代码") & "]非法"
         End If
         coRecordSQL.Close
         coRecordExcel.MoveNext
      Loop
      coRecordExcel.Close
   End If
   
   '检查[Sheet2]的qst_no同[Sheet1]的qst_no对应否
   If lcErrMsg = "" Then
      Dim loConn_ST As New ADODB.Connection
      Dim loRs_ST As New ADODB.Recordset
   
      loConn_ST.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _
                 "Data Source= " & Trim(C_EXCEL_FILE_NAME) & _
                 ";Extended Properties='Excel 8.0;IMEX=1'"
      loRs_ST.ActiveConnection = loConn_ST
      
      coRecordExcel.Open "select DISTINCT 试题代码 from [" & C_SHEET2_NAME & "$]"
      Do While Not coRecordExcel.EOF And lcErrMsg = ""
         loRs_ST.Open "select DISTINCT 试题代码 from [" & C_SHEET_NAME & "$] where 试题代码='" & coRecordExcel("试题代码") & "'"
         If loRs_ST.EOF Then
            lcErrMsg = "Excel文件第二张工作表中试题代码" & coRecordExcel("试题代码") & "不在第一张工作表中"
         End If
         loRs_ST.Close
         coRecordExcel.MoveNext
      Loop
      coRecordExcel.Close
   
      loConn_ST.Close
      Set loRs_ST = Nothing
      Set loConn_ST = Nothing
   End If

   ''检查[Sheet1]的操作题在[Sheet2]中是否都有评分规则
   'coRecordExcel.Open "select DISTINCT qst_no from [Sheet1$] where qst_type>20 and qst_type<>32"
   'Do While Not coRecordExcel.EOF
   '   loRs_sT.Open "select DISTINCT qst_no from [Sheet2$] where qst_no='" & coRecordExcel("qst_no") & "'"
   '   If loRs_sT.EOF Then
   '      C_StrInfoMsg = C_StrInfoMsg & "Excel[Sheet1]的操作题" & coRecordExcel("qst_no") & "在[Sheet2]中没有评分规则。" & "\\"
   '   End If
   '   loRs_sT.Close
   '   coRecordExcel.MoveNext
   'Loop
   'coRecordExcel.Close
   ChkSheet2Rule = lcErrMsg
End Function

'2008/07/03
'功能：导入新增的课程到course表
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ImpCrsInfo() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   Err.Clear
   lcErrMsg = ""
   coConnSQL.BeginTrans
   coRecordExcel.Open "select DISTINCT 课程代码,课程名称 from [" & C_SHEET_NAME & "$]"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      coRecordSQL.Open "SELECT * FROM course where crs_no='" & coRecordExcel("课程代码") & "'"
      If coRecordSQL.EOF Then
         coRecordSQL.AddNew
         coRecordSQL("crs_no") = coRecordExcel("课程代码")
         coRecordSQL("crs_name") = NullToStr(coRecordExcel("课程名称"))
         coRecordSQL.UpdateBatch
      End If
      coRecordSQL.Close
      
      If Err.Number <> 0 Then
         lcErrMsg = "导入课程[" & coRecordExcel("课程代码") & "]错误：" & Err.Description
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   ElseIf lcErrMsg = "" Then
      coConnSQL.RollbackTrans
      lcErrMsg = "导入知识点错误" & Err.Description & "\\"
   End If
   ImpCrsInfo = lcErrMsg
End Function

'功能：导入新增的知识点到Knowledge(知识点)表
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function ImpNewKnowledge() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   Err.Clear
   lcErrMsg = ""
   coConnSQL.BeginTrans
   '2010/04/23:Excel题库导入时，不在导入课程代码信息
   'coRecordExcel.Open "select DISTINCT 知识点代码, 知识点名称, 课程代码 from [Sheet1$]"
   coRecordExcel.Open "select DISTINCT 知识点代码, 知识点名称 from [" & C_SHEET2_NAME & "$]"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      coRecordSQL.Open "SELECT * FROM Knowledge where Knowledge_no='" & coRecordExcel("知识点代码") & "'"
      If coRecordSQL.EOF Then
         coRecordSQL.AddNew
         coRecordSQL("Knowledge_no") = coRecordExcel("知识点代码")
         coRecordSQL("Knowledge_name") = NullToStr(coRecordExcel("知识点名称"))
         'coRecordSQL("crs_no") = coRecordExcel("课程代码")
         coRecordSQL("crs_no") = "01"
         coRecordSQL.UpdateBatch
      End If
      coRecordSQL.Close
      
      If Err.Number <> 0 Then
         lcErrMsg = "导入知识点[" & coRecordExcel("知识点代码") & "]错误：" & Err.Description
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   ElseIf lcErrMsg = "" Then
      coConnSQL.RollbackTrans
      lcErrMsg = "导入知识点错误" & Err.Description & "\\"
   End If
   ImpNewKnowledge = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'功能：从SHEET1导入question表
Private Function ImpQst() As String
   Dim intCount As Integer
   Dim lcErrMsg As String
   Dim lbUpdate As Boolean
   Dim lbDBTZExits As Boolean
   Dim lbExlTZEXits As Boolean
   Dim strSql As String
   Dim coRecordSQL1 As New ADODB.Recordset
   
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   '判断数据库中是否有qst_no2这一列
   coRecordSQL.Open "select qst_no2 from question"
   coRecordSQL.Close
   '有qst_no2这一列
   If Err.Number = 0 Then
      lbDBTZExits = True
   End If
   Err.Clear
   
   '判断Excel中是否有“题组试题”这一列
   coRecordExcel.Open "select 题组试题 from [" & C_SHEET_NAME & "$]"
   coRecordExcel.Close
   '有题组试题这一列
   If Err.Number = 0 Then
      lbExlTZEXits = True
   End If
   Err.Clear
   
   coRecordSQL1.ActiveConnection = coConnSQL
   coRecordSQL1.CursorLocation = adUseClient
   coRecordSQL1.CursorType = adOpenKeyset
   coRecordSQL1.LockType = adLockBatchOptimistic
   
   intCount = vCount
   coConnSQL.BeginTrans
   strSql = "SELECT * FROM [" & C_SHEET_NAME & "$]"
   If Not lbDBTZExits And lbExlTZEXits Then  '如果数据库中没有qst_no2这列，且Excel中有“题组试题”列
      strSql = strSql & " where 试题类型<>10 and (题组试题='' or 题组试题 is null)"
   ElseIf Not lbDBTZExits And Not lbExlTZEXits Then  '如果数据库中没有qst_no2这列，且Excel中没有“题组试题”列
      strSql = strSql & " where 试题类型<>10"
   End If
   coRecordExcel.Open strSql
   Do While Not coRecordExcel.EOF And Err.Number = 0
      lbUpdate = False
      coRecordSQL.Open "SELECT * FROM question WHERE qst_no='" & ReplaceStr(coRecordExcel.Fields("试题代码")) & "'"
      If coRecordSQL.EOF = True Then
         coRecordSQL.AddNew
         lbUpdate = True
      Else
         lbUpdate = C_OVERWRITE_EXIST
      End If
      
      If lbUpdate = True Then
         coRecordSQL1.Open "select * from knowledge where knowledge_no='" & Left(coRecordExcel.Fields("知识点代码"), 6) & "'"
         If Not coRecordSQL1.EOF Then
            coRecordSQL.Fields("exm_no") = coRecordSQL1("knowledge_no")
         End If
         coRecordSQL1.Close
         
         'coRecordSQL.Fields("exm_no") = C_EXM_NO
         '2008/07/03：quesiton表不再有crs_no列。coRecordSQL.Fields("crs_no") = ccCourseNo
         coRecordSQL.Fields("qst_no") = ReplaceStr(coRecordExcel.Fields("试题代码"))
         'coRecordSQL.Fields("qst_type") = coRecordExcel.Fields("试题类型")
         coRecordSQL.Fields("qst_type") = GetQstType(coRecordExcel.Fields("试题类型"))
         
         coRecordSQL.Fields("qst_prm") = Replace(Replace(coRecordExcel.Fields("试题内容"), Chr(13) + Chr(10), Chr(10)), Chr(10), Chr(13) + Chr(10))
         coRecordSQL.Fields("qst_pnt") = coRecordExcel.Fields("本题分值")
         coRecordSQL.Fields("knowledge_no") = coRecordExcel.Fields("知识点代码")
         If coRecordSQL.Fields("qst_type") > 20 Then
            coRecordSQL.Fields("qst_asw") = NullToStr(coRecordExcel.Fields("标准答案"))
         ElseIf coRecordSQL.Fields("qst_type") = 6 Then
            coRecordSQL.Fields("qst_asw") = NullToStr(coRecordExcel.Fields("标准答案"))
         Else
            coRecordSQL.Fields("qst_asw") = Trim(StrConv(UCase$(coRecordExcel.Fields("标准答案")), vbNarrow))
         End If
         coRecordSQL.Fields("qst_dir") = NullToStr(coRecordExcel.Fields("素材文件"))
         coRecordSQL.Fields("qst_dld") = NullToStr(coRecordExcel.Fields("下载文档"))
         coRecordSQL.Fields("qst_pic") = NullToStr(coRecordExcel.Fields("附属图片"))
         coRecordSQL.Fields("qst_playfile") = NullToStr(coRecordExcel.Fields("媒体文件"))
         '数据库中有这一列
         If lbDBTZExits Then
            '但是Excel中没有这一列
            If Not lbExlTZEXits Then
               coRecordSQL.Fields("qst_no2") = ""
            Else
               coRecordSQL.Fields("qst_no2") = NullToStr(coRecordExcel.Fields("题组试题"))
            End If
         End If
         If IsNull(coRecordExcel.Fields("嵌入图片")) Then
            coRecordSQL.Fields("qst_htmlpic") = NullToStr(coRecordExcel.Fields("嵌入图片"))
         Else
            coRecordSQL.Fields("qst_htmlpic") = Replace(coRecordExcel.Fields("嵌入图片"), "；", ";")
         End If
         If IsNull(coRecordExcel.Fields("选项数目")) Then
            coRecordSQL.Fields("qst_itemnum") = 4
         Else
            coRecordSQL.Fields("qst_itemnum") = coRecordExcel.Fields("选项数目")
         End If
         If IsNull(coRecordExcel.Fields("试题名称")) Then
            coRecordSQL.Fields("qst_name") = "单选题"
         Else
            coRecordSQL.Fields("qst_name") = coRecordExcel.Fields("试题名称")
         End If
         If IsNull(coRecordExcel.Fields("播放类型")) Then
            coRecordSQL.Fields("qst_playtype") = 0
         Else
            coRecordSQL.Fields("qst_playtype") = coRecordExcel.Fields("播放类型")
         End If
         If IsNull(coRecordExcel.Fields("播放次数")) Then
            coRecordSQL.Fields("qst_playtimes") = 0
         Else
            coRecordSQL.Fields("qst_playtimes") = coRecordExcel.Fields("播放次数")
         End If
         
         coRecordSQL.UpdateBatch
         intCount = intCount + 1
      End If
      coRecordSQL.Close
      If Err.Number <> 0 Then
         lcErrMsg = "导入试题第[" & (intCount + 1) & "]行出错：" & Err.Description
      End If
      
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   Else
      coConnSQL.RollbackTrans
      If lcErrMsg = "" Then
         lcErrMsg = "导入question表出错：" & Err.Description
      End If
   End If
   '2010/04/23:导入题库后将导入题库的qst_html列更新
   If lcErrMsg = "" Then
      coRecordSQL.Open "select * from question where exm_no='" & C_EXM_NO & "'"
      Do While Not coRecordSQL.EOF
         'UpdateQstHtml coRecordSQL("qst_no")
         coRecordSQL.MoveNext
      Loop
      coRecordSQL.Close
   End If
   
   ImpQst = lcErrMsg
End Function

'返回：成功则返回空字符串,否则就返回错误信息字符串
'功能：将[Sheet2]的评分规则导入到rule表中，返回导入的评分规则数，-1表示失败
Private Function ImpRule() As String
   Dim intCount As Integer
   Dim lcErrMsg As String
   Dim lcQstNo As String
   Dim coRecordSQL1 As New ADODB.Recordset
   
   Err.Clear
   On Error Resume Next
   
   coRecordSQL1.ActiveConnection = coConnSQL
   coRecordSQL1.CursorLocation = adUseClient
   coRecordSQL1.CursorType = adOpenKeyset
   coRecordSQL1.LockType = adLockBatchOptimistic

   intCount = 0
   lcErrMsg = ""
   
   coConnSQL.BeginTrans
   coRecordExcel.Open "SELECT * FROM [" & C_SHEET2_NAME & "$] ORDER BY 试题代码, 评分序号"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      If lcQstNo <> coRecordExcel("试题代码") Then
         coConnSQL.Execute "delete from [rule] where qst_no='" & ReplaceStr(coRecordExcel.Fields("试题代码")) & "'"
         lcQstNo = coRecordExcel("试题代码")
      End If
      coRecordSQL1.Open "select * from question where qst_no='" & ReplaceStr(coRecordExcel.Fields("试题代码")) & "'"
      If Not coRecordSQL1.EOF Then
         coRecordSQL.Open "SELECT * FROM [rule] WHERE 1=-1"
         coRecordSQL.AddNew
         coRecordSQL.Fields("qst_no") = ReplaceStr(coRecordExcel.Fields("试题代码"))
         coRecordSQL.Fields("prop_no") = coRecordExcel.Fields("规则代码")
         coRecordSQL.Fields("rule_no") = coRecordExcel.Fields("评分序号")
         coRecordSQL.Fields("rule_para") = coRecordExcel.Fields("规则参数")
         coRecordSQL.Fields("rule_oper") = NullToStr(coRecordExcel.Fields("逻辑操作"))
         coRecordSQL.Fields("rule_cmnt") = NullToStr(coRecordExcel.Fields("评分说明"))
         If IsNull(coRecordExcel.Fields("规则分值")) Then
            coRecordSQL.Fields("rule_pnt") = 0
         Else
            coRecordSQL.Fields("rule_pnt") = coRecordExcel.Fields("规则分值")
         End If
         If IsNull(coRecordExcel.Fields("结果求反")) Then
            coRecordSQL.Fields("rule_mode") = 0
         Else
            coRecordSQL.Fields("rule_mode") = coRecordExcel.Fields("结果求反")
         End If
         coRecordSQL.UpdateBatch
         coRecordSQL.Close
      End If
      coRecordSQL1.Close
      intCount = intCount + 1
      If Err.Number <> 0 Then
         lcErrMsg = "导入Rule表出错" & Err.Description & "，第" & intCount & "行"
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   Set coRecordSQL1 = Nothing
   
   If lcErrMsg = "" And Err.Number = 0 Then
      coConnSQL.CommitTrans
   Else
      coConnSQL.RollbackTrans
      If lcErrMsg = "" Then
         lcErrMsg = "导入Rule表出错：" & Err.Description
      End If
   End If
   ImpRule = lcErrMsg
End Function
'导入题库
Private Function ImpExam() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   Err.Clear
   lcErrMsg = ""
   coConnSQL.BeginTrans

   coRecordExcel.Open "select 知识点代码,知识点名称 from [" & C_SHEET2_NAME & "$]"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      If Len(coRecordExcel("知识点代码")) = 6 Then
         coRecordSQL.Open "select * from exam where exm_no ='" & coRecordExcel("知识点代码") & "'"
         If coRecordSQL.EOF Then
            coRecordSQL.AddNew
         End If
         coRecordSQL("exm_no") = coRecordExcel("知识点代码")
         coRecordSQL("exm_name") = coRecordExcel("知识点名称")
         coRecordSQL("exm_type") = 0
         coRecordSQL("exm_minutes") = 60
         coRecordSQL("IsNew") = 1
         coRecordSQL("test_type") = 0
         coRecordSQL("test_grade") = 0
         coRecordSQL("test_id") = C_Test_Id
         coRecordSQL.UpdateBatch
         coRecordSQL.Close
      End If
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   ElseIf lcErrMsg = "" Then
      coConnSQL.RollbackTrans
      lcErrMsg = "导入数据错误" & Err.Description & "\\"
   End If
   ImpExam = lcErrMsg
End Function
'导入抽题试卷
Private Function ImpTest() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   Err.Clear
   lcErrMsg = ""
   coConnSQL.BeginTrans

   coRecordExcel.Open "select distinct 试卷代码,试卷名称,考试时长,考试类别,考试级别 from [" & C_SHEET3_NAME & "$]"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      coRecordSQL.Open "select * from exam where exm_no ='" & coRecordExcel("试卷代码") & "'"
      If coRecordSQL.EOF Then
         coRecordSQL.AddNew
      End If
      coRecordSQL("exm_no") = coRecordExcel("试卷代码")
      coRecordSQL("exm_name") = coRecordExcel("试卷名称")
      coRecordSQL("exm_type") = 1
      coRecordSQL("exm_minutes") = coRecordExcel("考试时长")
      coRecordSQL("IsNew") = 1
      coRecordSQL("test_type") = coRecordExcel("考试类别")
      coRecordSQL("test_grade") = coRecordExcel("考试级别")
      coRecordSQL("test_id") = C_Test_Id
      coRecordSQL.UpdateBatch
      coRecordSQL.Close
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   ElseIf lcErrMsg = "" Then
      coConnSQL.RollbackTrans
      lcErrMsg = "导入试卷错误" & Err.Description & "\\"
   End If
   ImpTest = lcErrMsg
End Function
'导入抽题模板
Private Function ImpTemplate() As String
   Dim lcErrMsg As String

   Err.Clear
   On Error Resume Next
   
   Err.Clear
   lcErrMsg = ""
   coConnSQL.BeginTrans
   '导入抽题模板前，首先删除本试卷已经存在的抽题代码
   coRecordExcel.Open "select distinct 试卷代码,试卷名称 from [" & C_SHEET3_NAME & "$]"
   If Not coRecordExcel.EOF Then
      Do While Not coRecordExcel.EOF
         coConnSQL.Execute "delete * from template where exm_no ='" & coRecordExcel("试卷代码") & "'"
         coRecordExcel.MoveNext
      Loop
   End If
   coRecordExcel.Close
   
   coRecordExcel.Open "select * from [" & C_SHEET3_NAME & "$]"
   Do While Not coRecordExcel.EOF And Err.Number = 0
      coRecordSQL.Open "select * from template where 1=-1"
      coRecordSQL.AddNew
      coRecordSQL("exm_no") = coRecordExcel("试卷代码")
      coRecordSQL("tpl_sno") = coRecordExcel("抽题序号")
      coRecordSQL("qst_no") = coRecordExcel("试题代码")
      coRecordSQL("qlib_no") = coRecordExcel("题库代码")
      coRecordSQL("knowledge_no") = coRecordExcel("知识点代码")
      coRecordSQL("qst_name") = coRecordExcel("试题名称")
      coRecordSQL("tpl_type") = coRecordExcel("试题类型")
      If coRecordExcel("得分率1") = "" Or IsNull(coRecordExcel("得分率1")) Then
         coRecordSQL("tpl_lvl") = 0
      Else
         coRecordSQL("tpl_lvl") = coRecordExcel("得分率1")
      End If
      If coRecordExcel("得分率2") = "" Or IsNull(coRecordExcel("得分率2")) Then
         coRecordSQL("tpl_lvl2") = 100
      Else
         coRecordSQL("tpl_lvl2") = coRecordExcel("得分率2")
      End If
      coRecordSQL("tpl_num") = coRecordExcel("抽题数目")
      coRecordSQL("tpl_point") = coRecordExcel("每题分值")
      
      coRecordSQL.UpdateBatch
      coRecordSQL.Close
      coRecordExcel.MoveNext
   Loop
   coRecordExcel.Close
   If Err.Number = 0 And lcErrMsg = "" Then
      coConnSQL.CommitTrans
   ElseIf lcErrMsg = "" Then
      coConnSQL.RollbackTrans
      lcErrMsg = "导入抽题错误" & Err.Description & "\\"
   End If
   ImpTemplate = lcErrMsg
End Function

'功能：将NULL值转换为空字符串
Private Function NullToStr(strInput) As String
   If IsNull(strInput) = True Then
      NullToStr = ""
   Else
      NullToStr = strInput
   End If
End Function

'功能：将EXAM、XIMAGES、DOC、MEIDA、ATTACHMENTS等文件夹复制到系统中
'返回：成功则返回空字符串,否则就返回错误信息字符串
Private Function CopyFolders() As String
   Dim loFileSys As New CFileSystem
   Dim lcErrMsg As String
   
   Err.Clear
   On Error Resume Next
   
   lcErrMsg = ""
   
   If Dir(ccImportPath & "Exam", vbDirectory) <> "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Exam\*.*", C_EXAM_PATH & "\") <> 0 Then
         lcErrMsg = "复制Exam文件夹出错：" & Err.Description
      End If
   End If
   If Dir(ccImportPath & "Doc", vbDirectory) <> "" And lcErrMsg = "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Doc", C_ASP_PATH & "\") <> 0 Then
         lcErrMsg = "复制Doc文件夹出错：" & Err.Description
      End If
   End If
   If Dir(ccImportPath & "Net", vbDirectory) <> "" And lcErrMsg = "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Net", C_ASP_PATH & "\") <> 0 Then
         lcErrMsg = "复制Net文件夹出错：" & Err.Description
      End If
   End If
   If Dir(ccImportPath & "Ximages", vbDirectory) <> "" And lcErrMsg = "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Ximages", C_ASP_PATH & "\") <> 0 Then
         lcErrMsg = "复制Ximages文件夹出错：" & Err.Description
      End If
   End If
   If Dir(ccImportPath & "Media", vbDirectory) <> "" And lcErrMsg = "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Media", C_ASP_PATH & "\") <> 0 Then
         lcErrMsg = "复制Media文件夹出错：" & Err.Description
      End If
   End If
   If Dir(ccImportPath & "Attachments", vbDirectory) <> "" And lcErrMsg = "" Then
      If loFileSys.CopyFolderOrFile(ccImportPath & "Attachments", C_ASP_PATH & "\WebMail\") <> 0 Then
         lcErrMsg = "复制Attachments文件夹出错：" & Err.Description
      End If
   End If
   
   CopyFolders = lcErrMsg
End Function

'功能：过滤字符串中含有回车和换行即"chr(10)","chr(13)"
'返回：经过过滤的字符串
Private Function ReplaceStr(lcStr As String) As String
    lcStr = Replace(lcStr, Chr(10), "")
    lcStr = Replace(lcStr, Chr(13), "")
    ReplaceStr = lcStr
End Function

Private Function GetQstType(lcStr As String) As Integer
      
   If IsNumeric(lcStr) Then
      GetQstType = lcStr
   Else
      Select Case lcStr
         Case "试题说明", ""
            GetQstType = 0
         Case "单项选择题", "单选"
            GetQstType = 1
         Case "多项选择题", "多选"
            GetQstType = 3
         Case "判断题", "判断"
            GetQstType = 5
         Case "填空题", "填空"
            GetQstType = 6
         Case "问答题", "计算题", "解析题", "证明题", "论述题"
            GetQstType = 7
         Case "选择填空题", "选择填空"
            GetQstType = 8
         Case "文档提交题", "文档提交"
            GetQstType = 9
         Case "题组定义", "题组"
            GetQstType = 10
       End Select
   End If
End Function















