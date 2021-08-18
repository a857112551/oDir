VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CEncrypt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'本类模块用来进行数据的加密和解密
'作者：信世强    审核：刘增锁
'定稿时间：2004/05/08
'2005/05/09:改本程序中BUG行，其它不动，与2004相同
'2006/05/13:复制会考的GetResponseCode（）和StrToNum（），过滤掉strPrompt，strKey中的非数值字符，否则会产生错误

Option Explicit
Private gnRandomSeed As Long '随机数种子
Const DEFAULT_KEY = "123456"

'功能：产生区间[a··b]上的一个随机整数，使用并改变整体变量seed}
'参数：inta-最小值,intb-最大值
'返回：产生区间[a··b]上的一个整数
'修改：2004/05/08：去掉参数；种子改名为gnRandomSeed，Integer类型；
Private Function GenRandomInt() As Integer
    Const intMaxseed = 32768
    Const intMultiplier = 25173
    Const intAdder = 13849
    
    gnRandomSeed = (intMultiplier * gnRandomSeed Mod intMaxseed + intAdder) Mod intMaxseed
    '2004/05/08:GenRandomInt = inta gnRandomSeed * (intb - inta + 1) \ intMaxseed
    GenRandomInt = gnRandomSeed
End Function

'功能：初始化随机书数种子
'参数：pnSeed - 新的种子值
Private Sub InitRandomSeed(pnSeed As Integer)
    gnRandomSeed = pnSeed
End Sub

'功能：将字符串加密后转换为字节数组
'参数：strSource-被转换的字符串,strKey-密钥字符串
'返回值：字节数组
'原理：首先将strKey中各字符的ASCW值进行异或得到随机数种子，然后将被加密字符串中每个字符的ASCW值与
'      随机数序列中的对应值进行异或，结果还要转换为两个字节存储，负数要先转换成补码
Public Function EncryptStr(strSource As String, strKey As String) As Byte()
    Dim intAscw As Integer  'ASCW()值
    Dim bytFirst As Byte    '整数转换为字节-第1个字节
    Dim bytSecond As Byte   '整数转换为字节-第2个字节
    Dim bytArr() As Byte    '字节数组, 存放加密结果
    Dim lngStrLen As Long
    Dim lngl As Long
    Dim lngI As Long
    Dim strTmp As String
    Dim intLen As Integer
    Dim lngfn As Integer
    Dim intRndKey As Integer
    Dim intTmpAsc As Integer
    Dim intRandom As Integer
    
    If strKey = "" Then
       strKey = DEFAULT_KEY
    End If
    
    '生成密钥
    intLen = Len(strKey)
    intRndKey = 0
    For lngI = 1 To intLen
        '2005/05/09:intTmpAsc = AscW(Mid(strKey, lngfn, 1))
        intTmpAsc = AscW(Mid(strKey, lngI, 1))
        intRndKey = intRndKey Xor intTmpAsc
    Next
    
    '生成字节数组
    InitRandomSeed intRndKey
    lngStrLen = Len(strSource)
    ReDim bytArr(lngStrLen * 2 - 1) As Byte
    lngl = 0
    For lngI = 1 To lngStrLen
        strTmp = ""
        strTmp = Mid(strSource, lngI, 1)
        intRandom = GenRandomInt()
        intAscw = AscW(strTmp) Xor intRandom
        If intAscw >= 0 Then
            bytFirst = intAscw \ 256
            bytSecond = intAscw Mod 256
        Else
            bytFirst = (intAscw + 65536) \ 256
            bytSecond = (intAscw + 65536) Mod 256
        End If
        bytArr(lngl) = bytFirst
        lngl = lngl + 1
        bytArr(lngl) = bytSecond
        lngl = lngl + 1
    Next lngI
    EncryptStr = bytArr
End Function

'功能：将字节数组解密成字符串,
'参数：bytarr-为字节数组,strkey-密码
'返回：字符串
'说明：数组下标从0开始，每两个构成一个字，解密成一个字符
Public Function DecryptToStr(bytArr() As Byte, strKey As String) As String
    Dim lngArrub As Long
    Dim Lngval As Long
    Dim intI As Long
    Dim intAscw As Integer
    Dim strTmp As String
    Dim intMaLen As Integer
    Dim lngfn As Integer
    Dim intTmpAsc As Integer
    Dim intRndKey As Integer
    Dim intRandom As Integer
    
    If strKey = "" Then
       strKey = DEFAULT_KEY
    End If
    
    '生成密钥
    intMaLen = Len(strKey)
    intRndKey = 0
    For lngfn = 1 To intMaLen
        intTmpAsc = AscW(Mid(strKey, lngfn, 1))
        intRndKey = intRndKey Xor intTmpAsc
    Next
    
    '与随机序列相异或，得到原字符ASC码，再还原为原字符
    InitRandomSeed intRndKey
    lngArrub = UBound(bytArr)
    For intI = 0 To lngArrub Step 2
        Lngval = CLng(bytArr(intI)) * 256 + bytArr(intI + 1)
        If Lngval < 32768 Then
            intAscw = Lngval
        Else
            intAscw = Lngval - 65536
        End If
        intRandom = GenRandomInt()
        intAscw = intAscw Xor intRandom
        strTmp = strTmp & ChrW(intAscw)
    Next intI
    DecryptToStr = strTmp
End Function

'功能：此函数用来产生与提示码一样长的认证码
'参数：strPrompt－提示码，strkey－场次或考点代码
'返回：字符串
'说明：用strkey各位ASC码相加作为随机种子，产生与strPrompt相同长度的随机字符串
'　　　然后与strPrompt相异或，产生结果字符串，从结果字符左边取strPrompt长度的倍数作为认证码返回。
Public Function GetResponseCode(strPrompt As String, strKey As String) As String
    Dim strTmp As String
    Dim intLen As Integer
    Dim intAsc As Integer
    Dim intI As Integer
    '2007/10/17:修改见下行 Dim intRndKey As Integer
    Dim intRndKey As Long
    
    Dim intRndVal As Integer
    Dim StrtmpPassWord As String
    Dim lngfn As Long
    Dim lnPrompt As String
    Dim lnKey As String
    
    Dim lcPrompt As String   '2007/10/17
    Dim lcKey As String    '2007/10/17
    
    '2007/10/17:修改InitRandomSeed()用到的种子值的产生算法
    lcPrompt = ""
    For intI = 1 To Len(strPrompt)
      lcPrompt = lcPrompt & Abs(AscW(Mid(strPrompt, intI, 1)))
    Next
    
    lnPrompt = 0
    Do While lcPrompt <> ""
       If Len(lcPrompt) > 6 Then
          lnPrompt = lnPrompt Xor CLng(Left(lcPrompt, 6))
          lcPrompt = Right(lcPrompt, Len(lcPrompt) - 6)
       Else
          lnPrompt = lnPrompt Xor CLng(lcPrompt)
          lcPrompt = ""
       End If
    Loop
    '对strKey进行相同的处理
    lcKey = ""
    For intI = 1 To Len(strKey)
      lcKey = lcKey & Abs(AscW(Mid(strKey, intI, 1)))
    Next
    
    lnKey = 0
    Do While lcKey <> ""
       If Len(lcKey) > 6 Then
          lnKey = lnKey Xor CLng(Left(lcKey, 6))
          lcKey = Right(lcKey, Len(lcKey) - 6)
       Else
          lnKey = lnKey Xor CLng(lcKey)
          lcKey = ""
       End If
    Loop
    intRndKey = lnPrompt Xor lnKey
    InitRandomSeed (intRndKey Mod 32768)
    
    strTmp = ""
    For intI = 1 To Len(lnPrompt)   '取前intLen个随机数的末位，形成对应的回应码
        strTmp = strTmp & Right((GenRandomInt() & ""), 1)
    Next
    GetResponseCode = strTmp
 End Function
 
'2006/04/01:过滤掉参数中的非数值字符,输出值最少是8位
Public Function StrToNum(strValue As String) As String
   Dim i As Integer
   Dim strTmp As String
   Dim lnTmp
   
   strTmp = ""
   For i = 1 To Len(strValue)
      lnTmp = Mid(strValue, i, 1)
      If IsNumeric(lnTmp) = True Then
         strTmp = strTmp & lnTmp
      End If
   Next
   If Len(strTmp) < 8 Then
      StrToNum = Format(strTmp, "00000000")
   Else
      StrToNum = strTmp
  End If
End Function

'功能：产生指定位数的随机提示码
'参数：intbitsum－位数
'返回：字符串
 Public Function GenPromptCode(intBitNum As Integer) As String
    Dim strTmp As String
    
    Randomize CLng(Day(Date) & Hour(Time) & Minute(Time) & Second(Time)) '用时间来做随机种子
    strTmp = ""
    strTmp = CStr(Round(Rnd() * (10 ^ intBitNum))) '取整数并转换为字符串
    GenPromptCode = Format(strTmp, String(intBitNum, "0"))
 End Function

'功能：给成绩加密，产生两个加密数值，以便相互印证
'参数：strPassword-密钥，建议使用考生姓名而不是考号；lngPoint-成绩
'返回：2元素的整型数组
Public Function PointEncrypt(strPassword As String, lngPoint As Integer) As Integer()
    Dim intArray(1) As Integer
    Dim intI As Integer
    Dim intMa As Integer
    Dim intX1 As Integer
    Dim intX2 As Integer
    
    '前后两位相异或结果为随机种子
    intMa = 0
    For intI = 1 To Len(strPassword)
        intMa = intMa Xor AscW(Mid(strPassword, intI, 1))
    Next
    gnRandomSeed = intMa
    intX1 = GenRandomInt() '产生随机数
    intX2 = GenRandomInt()
    '成绩与两个随机数相异或得出两个整数型密文
    intArray(0) = intX1 Xor lngPoint
    intArray(1) = intX2 Xor lngPoint
    PointEncrypt = intArray
End Function

'功能：成绩解密
'参数：strPassword-密码，intPoint1、intPoint2是两个加密后的成绩
'返回：解密成功返回成绩，否则返回-999，说明两个加密值不匹配
Public Function PointDecrypt(strPassword As String, intPoint1 As Integer, intPoint2 As Integer) As Integer
    Dim intArray(1) As Integer
    Dim intI As Integer
    Dim intMa As Integer
    Dim intX1 As Integer
    Dim intX2 As Integer
    
    '前后两位相异或结果为随机种子
    intMa = 0
    For intI = 1 To Len(strPassword)
        intMa = intMa Xor AscW(Mid(strPassword, intI, 1))
    Next
    gnRandomSeed = intMa
    intX1 = GenRandomInt() '产生随序列
    intX2 = GenRandomInt()
    
    '两个整数密文件与两个随机数相异或，如果值相等，则成绩正确，否则x1、X2已经人为改动，不是加密值
    If (intX1 Xor intPoint1) = (intX2 Xor intPoint2) Then
        PointDecrypt = (intX1 Xor intPoint1)
    Else
        PointDecrypt = -999
    End If
End Function
