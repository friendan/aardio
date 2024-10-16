VERSION 5.00
Begin VB.UserControl UserControl1 
   ClientHeight    =   3600
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4800
   ScaleHeight     =   3600
   ScaleWidth      =   4800
   Begin VB.Image Image1 
      Height          =   3615
      Left            =   0
      Stretch         =   -1  'True
      Top             =   0
      Width           =   4815
   End
End
Attribute VB_Name = "UserControl1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

'����һ����ͨ����
Dim TestPropertyValue As Integer

'����һ���¼����� aardio �п�����Ӧ����¼���
'ע���������ByRef��ʾ��ַ���� aardio �оͿ����޸������������ֵ
Public Event OnImageClick(ByRef TestPropertyValue As Integer)

'VB6 ����� Image ͼ��ؼ��������¼�
Private Sub Image1_Click()
    '���� COM �ؼ����¼��� ���仰˵���ǵ��� aardio �еĺ��� ��
    RaiseEvent OnImageClick(TestPropertyValue)
End Sub

'���ڵ�����С�������������ע�� aardio �ؼ���������Ӧ���ŵ�
Private Sub UserControl_Resize()
    Image1.Width = UserControl.Width
    Image1.Height = UserControl.Height
End Sub

'��������� TestProperty �ĺ��������Ǵ�����������
Public Property Get TestProperty(Param As Integer) As Integer
    TestProperty = TestPropertyValue + Param
End Property

'����д���� TestProperty �ĺ��������������ԣ�����Ҫ������һ�£�
Public Property Let TestProperty(Param As Integer, ByVal v As Integer)
    TestPropertyValue = v - Param
End Property

'����д���� Picture �ĺ�����������һ�� IDispatch �ӿڵ� COM ����
Public Property Let Picture(ByVal pic As Variant)
    Image1.Picture = pic
End Property

'���� aardio ���Ե��õĿؼ�������aardio ������ VB ���ʾΪ IDispatch �ӿڵ� COM ����
Public Sub CallAnything(ByVal dispatchObject As Object)

    '��д����������
    dispatchObject("name") = "value"
    
    'ֱ�ӵ��� aardio ����������д aardio �������ԡ�
    dispatchObject.Log ("�������� VB �Ĳ�����  Ҳ���������� aardio �������ԣ�" + dispatchObject.Name)
    
    Dim v As Variant
    
    'aardio �����Զ�֧�� VB ö�ٽӿڣ� IEnumVARIANT �ӿ� ��
    For Each Key In dispatchObject
        v = dispatchObject(Key)
        
        If TypeName(v) = "String" Then
            MsgBox v
            
            Exit For
        End If
    Next Key
    
    
End Sub

'�������� aardio ���Ե��õĿؼ�����
Public Function Add(ByVal a As Integer, ByVal b As Integer)
   Add = a + b
End Function

'�����������
Public Function GetOutStr(ByRef str As String) As Integer
    str = "�����ַ���"
    
    GetOutStr = Len(str)
End Function


