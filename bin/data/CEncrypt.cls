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
'����ģ�������������ݵļ��ܺͽ���
'���ߣ�����ǿ    ��ˣ�������
'����ʱ�䣺2004/05/08
'2005/05/09:�ı�������BUG�У�������������2004��ͬ
'2006/05/13:���ƻῼ��GetResponseCode������StrToNum���������˵�strPrompt��strKey�еķ���ֵ�ַ���������������

Option Explicit
Private gnRandomSeed As Long '���������
Const DEFAULT_KEY = "123456"

'���ܣ���������[a����b]�ϵ�һ�����������ʹ�ò��ı��������seed}
'������inta-��Сֵ,intb-���ֵ
'���أ���������[a����b]�ϵ�һ������
'�޸ģ�2004/05/08��ȥ�����������Ӹ���ΪgnRandomSeed��Integer���ͣ�
Private Function GenRandomInt() As Integer
    Const intMaxseed = 32768
    Const intMultiplier = 25173
    Const intAdder = 13849
    
    gnRandomSeed = (intMultiplier * gnRandomSeed Mod intMaxseed + intAdder) Mod intMaxseed
    '2004/05/08:GenRandomInt = inta gnRandomSeed * (intb - inta + 1) \ intMaxseed
    GenRandomInt = gnRandomSeed
End Function

'���ܣ���ʼ�������������
'������pnSeed - �µ�����ֵ
Private Sub InitRandomSeed(pnSeed As Integer)
    gnRandomSeed = pnSeed
End Sub

'���ܣ����ַ������ܺ�ת��Ϊ�ֽ�����
'������strSource-��ת�����ַ���,strKey-��Կ�ַ���
'����ֵ���ֽ�����
'ԭ�������Ƚ�strKey�и��ַ���ASCWֵ�������õ���������ӣ�Ȼ�󽫱������ַ�����ÿ���ַ���ASCWֵ��
'      ����������еĶ�Ӧֵ������򣬽����Ҫת��Ϊ�����ֽڴ洢������Ҫ��ת���ɲ���
Public Function EncryptStr(strSource As String, strKey As String) As Byte()
    Dim intAscw As Integer  'ASCW()ֵ
    Dim bytFirst As Byte    '����ת��Ϊ�ֽ�-��1���ֽ�
    Dim bytSecond As Byte   '����ת��Ϊ�ֽ�-��2���ֽ�
    Dim bytArr() As Byte    '�ֽ�����, ��ż��ܽ��
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
    
    '������Կ
    intLen = Len(strKey)
    intRndKey = 0
    For lngI = 1 To intLen
        '2005/05/09:intTmpAsc = AscW(Mid(strKey, lngfn, 1))
        intTmpAsc = AscW(Mid(strKey, lngI, 1))
        intRndKey = intRndKey Xor intTmpAsc
    Next
    
    '�����ֽ�����
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

'���ܣ����ֽ�������ܳ��ַ���,
'������bytarr-Ϊ�ֽ�����,strkey-����
'���أ��ַ���
'˵���������±��0��ʼ��ÿ��������һ���֣����ܳ�һ���ַ�
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
    
    '������Կ
    intMaLen = Len(strKey)
    intRndKey = 0
    For lngfn = 1 To intMaLen
        intTmpAsc = AscW(Mid(strKey, lngfn, 1))
        intRndKey = intRndKey Xor intTmpAsc
    Next
    
    '�������������򣬵õ�ԭ�ַ�ASC�룬�ٻ�ԭΪԭ�ַ�
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

'���ܣ��˺���������������ʾ��һ��������֤��
'������strPrompt����ʾ�룬strkey�����λ򿼵����
'���أ��ַ���
'˵������strkey��λASC�������Ϊ������ӣ�������strPrompt��ͬ���ȵ�����ַ���
'������Ȼ����strPrompt����򣬲�������ַ������ӽ���ַ����ȡstrPrompt���ȵı�����Ϊ��֤�뷵�ء�
Public Function GetResponseCode(strPrompt As String, strKey As String) As String
    Dim strTmp As String
    Dim intLen As Integer
    Dim intAsc As Integer
    Dim intI As Integer
    '2007/10/17:�޸ļ����� Dim intRndKey As Integer
    Dim intRndKey As Long
    
    Dim intRndVal As Integer
    Dim StrtmpPassWord As String
    Dim lngfn As Long
    Dim lnPrompt As String
    Dim lnKey As String
    
    Dim lcPrompt As String   '2007/10/17
    Dim lcKey As String    '2007/10/17
    
    '2007/10/17:�޸�InitRandomSeed()�õ�������ֵ�Ĳ����㷨
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
    '��strKey������ͬ�Ĵ���
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
    For intI = 1 To Len(lnPrompt)   'ȡǰintLen���������ĩλ���γɶ�Ӧ�Ļ�Ӧ��
        strTmp = strTmp & Right((GenRandomInt() & ""), 1)
    Next
    GetResponseCode = strTmp
 End Function
 
'2006/04/01:���˵������еķ���ֵ�ַ�,���ֵ������8λ
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

'���ܣ�����ָ��λ���������ʾ��
'������intbitsum��λ��
'���أ��ַ���
 Public Function GenPromptCode(intBitNum As Integer) As String
    Dim strTmp As String
    
    Randomize CLng(Day(Date) & Hour(Time) & Minute(Time) & Second(Time)) '��ʱ�������������
    strTmp = ""
    strTmp = CStr(Round(Rnd() * (10 ^ intBitNum))) 'ȡ������ת��Ϊ�ַ���
    GenPromptCode = Format(strTmp, String(intBitNum, "0"))
 End Function

'���ܣ����ɼ����ܣ���������������ֵ���Ա��໥ӡ֤
'������strPassword-��Կ������ʹ�ÿ������������ǿ��ţ�lngPoint-�ɼ�
'���أ�2Ԫ�ص���������
Public Function PointEncrypt(strPassword As String, lngPoint As Integer) As Integer()
    Dim intArray(1) As Integer
    Dim intI As Integer
    Dim intMa As Integer
    Dim intX1 As Integer
    Dim intX2 As Integer
    
    'ǰ����λ�������Ϊ�������
    intMa = 0
    For intI = 1 To Len(strPassword)
        intMa = intMa Xor AscW(Mid(strPassword, intI, 1))
    Next
    gnRandomSeed = intMa
    intX1 = GenRandomInt() '���������
    intX2 = GenRandomInt()
    '�ɼ�����������������ó���������������
    intArray(0) = intX1 Xor lngPoint
    intArray(1) = intX2 Xor lngPoint
    PointEncrypt = intArray
End Function

'���ܣ��ɼ�����
'������strPassword-���룬intPoint1��intPoint2���������ܺ�ĳɼ�
'���أ����ܳɹ����سɼ������򷵻�-999��˵����������ֵ��ƥ��
Public Function PointDecrypt(strPassword As String, intPoint1 As Integer, intPoint2 As Integer) As Integer
    Dim intArray(1) As Integer
    Dim intI As Integer
    Dim intMa As Integer
    Dim intX1 As Integer
    Dim intX2 As Integer
    
    'ǰ����λ�������Ϊ�������
    intMa = 0
    For intI = 1 To Len(strPassword)
        intMa = intMa Xor AscW(Mid(strPassword, intI, 1))
    Next
    gnRandomSeed = intMa
    intX1 = GenRandomInt() '����������
    intX2 = GenRandomInt()
    
    '�����������ļ��������������������ֵ��ȣ���ɼ���ȷ������x1��X2�Ѿ���Ϊ�Ķ������Ǽ���ֵ
    If (intX1 Xor intPoint1) = (intX2 Xor intPoint2) Then
        PointDecrypt = (intX1 Xor intPoint1)
    Else
        PointDecrypt = -999
    End If
End Function