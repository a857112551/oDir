Attribute VB_Name = "modAddTableOrFields"
Option Explicit

'2008/03/07:��modMain.bas����������Ϊһ��ģ��;���Ӳ���
Public Sub AddTableOrFields(pcConnString As String)
   Dim loConn As New ADODB.Connection
   Dim loRs As New ADODB.Recordset
   
   Dim loconn1 As New ADODB.Connection
   Dim loRs1 As New ADODB.Recordset
   
   Dim lcSql As String
   Dim lcConnstring As String
   
   Err.Clear
   On Error Resume Next
   
   lcConnstring = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & App.Path & "\project.mdb;Jet OLEDB:Database Password=6689036;admin "
   loconn1.ConnectionString = lcConnstring  '2008/03/08.strConnString
   loconn1.Open
   loRs1.ActiveConnection = loconn1
   loRs1.CursorLocation = adUseClient
   loRs1.CursorType = adOpenKeyset
   loRs1.LockType = adLockPessimistic
   
   '�Զ�����VersionS.versionT
   loRs1.Open "select versionT from VersionS"
   loRs1.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE VersionS ADD versionT nvarchar(50) default '0'"
      loconn1.Execute lcSql
   End If
   loconn1.Close
   Set loconn1 = Nothing
   
   
   loConn.ConnectionString = pcConnString  '2008/03/08.strConnString
   loConn.Open
   loRs.ActiveConnection = loConn
   loRs.CursorLocation = adUseClient
   loRs.CursorType = adOpenKeyset
   loRs.LockType = adLockPessimistic
   
   '�Զ�����Diary��
   loRs.Open "SELECT * FROM diary"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE diary (id integer identity(1,1) primary key," & _
                                  "stu_no varchar(20) Not null," & _
                                  "exm_no varchar(20) NOT NULL , " & _
                                  "datatime date," & _
                                  "exm_pnt real," & _
                                  "up_loaded integer NOT NULL ," & _
                                  "diary_type integer NOT NULL)"
                                    
      loConn.Execute lcSql
   End If

   '�Զ�����stu_exm��
   loRs.Open "SELECT * FROM stu_exm"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE stu_exm (id integer identity(1,1) primary key," & _
                                    "stu_no varchar(20) Not null," & _
                                    "exm_no varchar(20) NOT NULL , " & _
                                    "exm_datetime date," & _
                                    "exm_point real," & _
                                    "exm_type integer NOT NULL ," & _
                                    "exm_leftminutes integer NOT NULL," & _
                                    "exm_uploaded bit default 0)"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����UserReg��
   '2019/2/15 ����ע������ 1 ѧУ 2 ѧ��
   loRs.Open "select * from UserReg "
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE UserReg(id integer identity(1,1) primary key," & _
                                   "user_id varchar(20) Not null," & _
                                   "user_mac varchar(20) NOT NULL , " & _
                                   "unit_no varchar(20) NOT NULL ," & _
                                   "Province_server_ip varchar(20) NOT NULL ," & _
                                   "server_ip varchar(20) NOT NULL ," & _
                                   "user_ip varchar(20) NOT NULL )"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����UnitReg��
   '2019/2/15 ����ע������ 0 δע�� 1 ѧУ 2 ѧ��
   loRs.Open "select * from UserReg "
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE UnitReg(id integer identity(1,1) primary key," & _
                                   "regtype integer default(0) NOT NULL )"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����Police_type��
   loRs.Open "select * from Police_type "
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE Police_type(id integer identity(1,1)," & _
                                   "ptype_no varchar(10) primary key," & _
                                   "ptype_name varchar(20) NOT NULL)"
                           
      loConn.Execute lcSql
   End If
  
  '�Զ�����Police_grade��
   loRs.Open "select * from Police_grade"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE Police_grade(id integer identity(1,1)," & _
                                   "pgrade_no varchar(10) primary key," & _
                                   "pgrade_name varchar(20) NOT NULL)"
                           
      loConn.Execute lcSql
   End If
   
   
   '20190802�Զ����� question.test_id
   loRs.Open "select test_id from question"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE question ADD test_id integer"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����template.qst_name
   loRs.Open "select qst_name from template"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE template ADD qst_name nvarchar(20) default ''"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����VersionQ.UnitNo
   loRs.Open "select UnitNo from VersionQ"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE VersionQ ADD UnitNo nvarchar(20) default ''"
                                    
      loConn.Execute lcSql
   End If
   
   '�Զ�����student.pgrade_no,student.ptype_no
   loRs.Open "select pgrade_no from student"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE student ADD pgrade_no nvarchar(10) default '', ptype_no nvarchar(10) default ''"
                                    
      loConn.Execute lcSql
   End If
   
   '2007/10/11:�Զ����ӱ�server(id,unit_name,webaddress,currentserver)
   loRs.Open "select * from server"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE server(id integer identity(1,1)," & _
                                   "unit_name varchar(30) default ''," & _
                                   "province varchar(30) default ''," & _
                                   "city varchar(30) default ''," & _
                                   "county varchar(30) default ''," & _
                                   "currentserver bit default 0," & _
                                   "WebAddress varchar(50) default '' )"
                           
      loConn.Execute lcSql
   End If
   
   loRs.Open "select * from VersionS"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE VersionS(id integer identity(1,1)," & _
                                   "version varchar(20) default '' ," & _
                                   "updatetime varchar(50) default ''," & _
                                   "updatecmt varchar(50) default '' )"
      loConn.Execute lcSql
   End If
   
   '2007/11/02���Զ�����Version_U��
   loRs.Open "select * from Version_U"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE Version_U(id integer identity(1,1)," & _
                                   "version_no varchar(20) default '' ," & _
                                   "update_datetime varchar(50) default ''," & _
                                   "update_cmt varchar(50) default '' )"
      loConn.Execute lcSql
   End If
   
   loRs.Open "select * from VersionQ"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "CREATE TABLE VersionQ(id integer identity(1,1)," & _
                                   "version varchar(20) default '' ," & _
                                   "updatetime varchar(50) default ''," & _
                                   "updatecmt varchar(50) default '' )"
      loConn.Execute lcSql
   End If
   
   '�Զ�����rule.rule_mode��
   loRs.Open "SELECT rule_mode FROM [rule]"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE [rule] ADD rule_mode integer not null "
   End If
   loConn.Execute "UPDATE [rule] SET RULE_MODE=0 WHERE ISNULL(RULE_MODE)"
   
   '2007/12/12:�Զ�����template.qlib_no��
   loRs.Open "SELECT qlib_no FROM template"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE template ADD qlib_no varchar(20)"
   End If
   
   loRs.Open "select qst_prmb from question"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table question add column qst_prmb image"
   End If
   loRs.Open "select qst_no2 from question"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table question add column qst_no2 varchar(20) "
   End If
   loRs.Open "select IsNew from exam"
   loRs.Close
   '2008/03/07:��QUESTION��EXAM��KNOWLEDGE��COURSE������ISNEW�У��Ա����������ʱ����°汾����в����ڵļ�¼
   loRs.Open "select IsNew from question"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table question add column IsNew integer "
   End If
   loRs.Open "select IsNew from exam"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table exam add column IsNew integer "
   End If
   loRs.Open "select IsNew from knowledge"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table knowledge add column IsNew integer "
   End If
   loRs.Open "select IsNew from course"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table course add column IsNew integer "
   End If
   
   '2008/03/08:����ǰ�ݴ�������İ汾��
   loRs.Open "select NewVersion from VersionS"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE versionS ADD NewVersion    varchar(50) default ''"
      loConn.Execute "ALTER TABLE versionS ADD NewUpdateTime varchar(50) default ''"
      loConn.Execute "ALTER TABLE versionS ADD NewUpdateCmt  varchar(50) default ''"
   End If
   
   '2008/03/08:���´����frmMain��StartExam()�������ƶ�����
   '2007/10/18:�Զ�����VERSION_T.ScreenLocked
   loRs.Open "select * from VERSION_T"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "CREATE TABLE VERSION_T (id integer identity(1,1) primary key," & _
                                 "exm_name varchar(20) Not null," & _
                                 "exm_cmt varchar(20) default '', " & _
                                 "exm_starttime varchar(20) default ''," & _
                                 "exm_endtime varchar(20) default ''," & _
                                 "updatetime varchar(20) default ''," & _
                                 "exmtype integer default 0," & _
                                 "version varchar(20) not null )"
   End If
   loRs.Open "SELECT ScreenLocked FROM VERSION_T"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE VERSION_T ADD ScreenLocked integer default 0 not null "
   End If
   '2008/03/08��������exm_testtime
   loRs.Open "SELECT test_time FROM VERSION_T"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE VERSION_T ADD test_time integer default 60 not null "
   End If
   '2007/10/18:���RESULT���Ƿ���rst_keyָ���У�û������Ӹ���
   loRs.Open "select rst_key from result"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE result ADD rst_key nvarchar(20) not NULL default ''"
   End If
   '2007/12/13:���RESULT���Ƿ���rst_upload�У�û������Ӹ���
   loRs.Open "select rst_upload from result"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "ALTER TABLE result ADD rst_upload bit default 0"
   End If
   '�½�student0��(id,stu_no,stu_name,stu_sex,unit_name)
   loRs.Open "select * from student0"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "CREATE TABLE student0 (id integer identity(1,1) primary key," & _
                               "stu_no varchar(20) Not null," & _
                               "stu_name varchar(20) NOT NULL, " & _
                               "exam_starttime varchar(30) NOT NULL, " & _
                               "exam_endtime varchar(30) NOT NULL, " & _
                               "stu_sex varchar(10) ," & _
                               "unit_name varchar(10) default '')"
   End If
   '2008/03/08-----------------------------------------------
   '���ݱ�student0����test_id,test_type,test_grade��
   loRs.Open "select test_type from student0"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table student0 add test_type nvarchar(50) not null default ''"
      loConn.Execute "alter table student0 add test_grade nvarchar(50) not null default ''"
      loConn.Execute "alter table student0 add test_id integer not null default 0"
   End If
   
   loRs.Open "select birthday from student"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table student add birthday date"
      loConn.Execute "alter table student add police_no nvarchar(20) "
      loConn.Execute "alter table student add pos_level nvarchar(20) "
      loConn.Execute "alter table student alter column stu_unit_no nvarchar(16)"
   End If
   
   
   '���ݱ�versionQ����test_id��,cancled��
   loRs.Open "select test_id from versionQ"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table versionQ add test_id integer not null default 0"
      loConn.Execute "alter table versionQ add cancled integer not null default 0"
      loConn.Execute "alter table versionQ add updateqstname varchar(50) not null default ''"
      loConn.Execute "update versionQ set test_id=0,cancled=0,updateQstname=''"
   End If
   
   loRs.Open "select test_id from version_T"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table version_T add test_id integer not null default 0"
      loConn.Execute "alter table version_T add cancled integer not null default 0"
      loConn.Execute "update version_t set test_id=0,cancled=0"
   End If
   
   loRs.Open "select test_type from exam"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table exam add test_type nvarchar(50) not null default ''"
      loConn.Execute "alter table exam add test_grade nvarchar(50) not null default ''"
      loConn.Execute "alter table exam add test_id integer not null default 0"
      loConn.Execute "update exam set test_type=0,test_grade=0,test_id=0"
   End If
   
   loRs.Open "select test_id from knowledge"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table knowledge add test_id integer not null default 0"
      loConn.Execute "update knowledge set test_id=0"
   End If
   
   loRs.Open "select test_id from course"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table course add test_id integer not null default 0"
      loConn.Execute "update course set test_id=0"
   End If
   
   loRs.Open "select exm_starttime from stu_exm"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table stu_exm add exm_starttime datetime"
      loConn.Execute "alter table stu_exm add exm_endtime datetime"
   End If
   
   loRs.Open "select exm_pnt from result"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table result add exm_pnt float default 0"
   End If
   
   loRs.Open "select * from qtype where type_id=8"
   If loRs.EOF Then
      loConn.Execute "insert into qtype(type_id,type_name) values(8,'ѡ�������')"
   End If
   loRs.Close
   loConn.Execute "update qtype set type_name='����' where type_id=10"
   loConn.Execute "update qtype set type_name='ͨ�ñ��' where type_id=30"
   
   loRs.Open "select exm_no from webmailuser"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table webmailuser add exm_no varchar(20) not null default ''"
   End If
   '��������tpl_mode�����ֳ���ģʽ
   loRs.Open "select tpl_mode from template"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "alter table template add column tpl_mode integer  default 0"
      loConn.Execute "update template set tpl_mode=0"
   End If
   
   loRs.Open "select IsNew from exam"
   loRs.Close
   '�½�webmail��
   loRs.Open "select * from webmail"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "CREATE TABLE webmail (mail_id integer identity(1,1) primary key," & _
                     "mail_type integer Not null default 1," & _
                     "mail_from varchar(200) NOT NULL default '', " & _
                     "mail_to varchar(200) NOT NULL default '', " & _
                     "mail_alsoto varchar(200) NOT NULL default '', " & _
                     "mail_subject varchar(200) NOT NULL default '', " & _
                     "mail_content text NOT NULL default '', " & _
                     "mail_datetime varchar(20) NOT NULL default '', " & _
                     "mail_attachment varchar(255) NOT NULL default '', " & _
                     "mail_isnew bit NOT NULL , " & _
                     "stu_no varchar(20) NOT NULL default '', " & _
                     "qst_no varchar(20) NOT NULL default '', " & _
                     "exm_no varchar(20) NOT NULL default '')"
   End If
   '�½�webmail0��
   loRs.Open "select * from webmail0"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      loConn.Execute "CREATE TABLE webmail0 (mail_id integer identity(1,1) primary key," & _
                     "mail_type integer Not null default 1," & _
                     "mail_from varchar(200) NOT NULL default '', " & _
                     "mail_to varchar(200) NOT NULL default '', " & _
                     "mail_alsoto varchar(200) NOT NULL default '', " & _
                     "mail_subject varchar(200) NOT NULL default '', " & _
                     "mail_content text NOT NULL default '', " & _
                     "mail_datetime varchar(20) NOT NULL default '', " & _
                     "mail_attachment varchar(255) NOT NULL default '', " & _
                     "mail_isnew bit NOT NULL , " & _
                     "stu_no varchar(20) NOT NULL default '', " & _
                     "qst_no varchar(20) NOT NULL default '')"
   End If
   
   '   20190809���ɾ��exam���exm_no�Ĺ�ϵ������
   loRs.Open "SELECT * FROM exam"
   loRs.Close
   loConn.Execute "alter table question drop constraint examquestion1"
   loConn.Execute "Drop INDEX exm_no ON exam"
   
'20190830   ����������
   loRs.Open "select qlib_type from exam"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE exam ADD qlib_type integer"
      loConn.Execute lcSql
   End If
   
'20201230   ���exam���������
   loRs.Open "select paperType from exam"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "ALTER TABLE exam ADD paperType integer"
      loConn.Execute lcSql
   End If
   
'    20210225����޸� template ��qlib_no�ֶ�����Ϊmemo����ע���ͣ�
   loRs.Open "select qlibno from template"
   loRs.Close
   If Err.Number <> 0 Then
      Err.Clear
      lcSql = "alter table template alter column qlib_no memo"
      loConn.Execute lcSql
   End If
   
   Set loRs = Nothing
   loConn.Close
   Set loConn = Nothing
End Sub

