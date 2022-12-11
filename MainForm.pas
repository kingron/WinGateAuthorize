{******************************************************************************}
{                 WinGate 登录器                                    }
{                (C)Copyright 1998-2008 Kingron                                }
{                -----------------------------------                           }
{                                                                              }
{           原始文件名：MainForm.pas                                            }
{             单元作者：Kingron                                                 }
{             电子邮件：Kingron@163.com                                         }
{                 备注：WinGate代理登录客户端程序                              }
{                                                                              }
{******************************************************************************}
{* |<PRE>
================================================================================
* 软件名称：WGA － MainForm.pas 
* 单元名称：MainForm.pas
* 单元作者：Kingron <Kingron@163.com>  
* 备    注：- WinGate本身的Java登录需要Java虚拟机，使用不方便，性能低下
*           - 考虑使用一个客户端程序代替Java登录客户端，方便使用 
*           - 
* 开发平台：Windows XP + Delphi 2006
* 兼容测试：Windows 2K/XP/2003, Delphi 7/2006
* 本 地 化：该单元中的字符串均符合本地化处理方式
--------------------------------------------------------------------------------
* 更新记录：- 2007-11-9 - Kingron: 第一版
*           - 2008-4-12 - Kingron: 修正影响关机选项，修正无法每次正确登录情况
                                   对密码加密存储，增加About信息，部分界面更新
================================================================================
|</PRE>}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, IdTCPClient, ExtCtrls, ShellAPI, Menus, ComCtrls;

const
  WM_TrayIcon = WM_USER + $100;
  WM_RELOAD = WM_USER + $101;
  CSKey = $E0998209;

type
  TWinGateAuther = class
  private
    TCP : TIdTCPClient;
  public
    constructor Create;
    destructor Destroy; override;
    function Logon(const Username, Password, Host: string;
                   const Port: Integer): Boolean;
    procedure Logout;
    function Logined: Boolean;
  end;

  TFrmMain = class(TForm)
    btnLogon: TButton;
    btnLogout: TButton;
    edtUser: TEdit;
    lblUser: TLabel;
    edtPassword: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    edtHost: TEdit;
    bvl2: TBevel;
    tmr1: TTimer;
    pm1: TPopupMenu;
    ShowMainForm1: TMenuItem;
    LogonLogoff1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    grp1: TGroupBox;
    chkAuto: TCheckBox;
    lblAdvance: TButton;
    chkAutoStart: TCheckBox;
    hkKey: THotKey;
    lblKey: TLabel;
    chkMin: TCheckBox;
    btnKey: TButton;
    About1: TMenuItem;
    lblCmd: TLabel;
    edtCmd: TEdit;
    procedure btnLogonClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure ShowMainForm1Click(Sender: TObject);
    procedure LogonLogoff1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lblAdvanceClick(Sender: TObject);
    procedure btnKeyClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    WinGater: TWinGateAuther;
    IconData: TNotifyIconData;
    Key, Shift: Word;
    ShutDown: Boolean;
    procedure UpdateUI(AEnable: Boolean);
    procedure AddTrayIcon;
    procedure RegisterKey;
    procedure TrayIconMessage(var Msg: TMessage); message WM_TrayIcon;
    procedure WMReload(var Msg: TMessage); message WM_RELOAD;
    procedure WMHotkey(var msg:TWMHOTKEY); message wm_hotkey;
    procedure OnShutDown(var msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses lyhtools, psapi;

{$R *.dfm}
{$R winxp.res}

{ TWinGateAuther }

const
  CSRegKey = 'Software\Microsoft\Windows\CurrentVersion\Run';
  CSConfig = 'Config';


{-------------------------------------------------------------------------------
  过程名:    ShiftStateToWord
  作者:      Kingron
  日期:      2008.04.12
  参数:      Shift:TShiftState
  返回值:    Word
  说明:	     转换Delphi的按键设置为Windows的Word按键值
-------------------------------------------------------------------------------}
function ShiftStateToWord(Shift:TShiftState):Word;
begin
  Result := 0;
  if ssShift in Shift then  Result :=MOD_SHIFT;
  if ssCtrl in Shift then Result :=Result or MOD_CONTROL;
  if ssAlt in Shift then Result:=Result or MOD_ALT;
end;

function GetDosOutput(const CommandLine:string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of Char;
  BytesRead: Cardinal;
  Line: String;
begin
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  // create pipe for standard output redirection
  CreatePipe(StdOutPipeRead,  // read handle
             StdOutPipeWrite, // write handle
             @SA,             // security attributes
             0                // number of bytes reserved for pipe - 0 default
             );
  try
    // Make child process use StdOutPipeWrite as standard out,
    // and make sure it does not show on screen.
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdinput
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;

    // launch the command line compiler
    //WorkDir := ExtractFilePath(CommandLine);
    WasOK := CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil,
                           nil, SI, PI);

    // Now that the handle has been inherited, close write to be safe.
    // We don't want to read or write to it accidentally.
    CloseHandle(StdOutPipeWrite);
    // if process could be created then handle its output
    if not WasOK then
      raise Exception.Create('Could not execute command line!')
    else
      try
        // get all output until dos app finishes
        Line := '';
        repeat
          // read block of characters (might contain carriage returns and line feeds)
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);

          // has anything been read?
          if BytesRead > 0 then
          begin
            // finish buffer to PChar
            Buffer[BytesRead] := #0;
            // combine the buffer with the rest of the last run
            Line := Line + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        // wait for console app to finish (should be already at this point)
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        // Close all remaining handles
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
      result:=Line;
      CloseHandle(StdOutPipeRead);
  end;
end;


{-------------------------------------------------------------------------------
  过程名:    CheckIPConnection
  作者:      Kingron
  日期:      2008.04.12
  参数:      IP, IPTable: string
  返回值:    Boolean
  说明:	     检查是否有其他程序使用代理服务器
-------------------------------------------------------------------------------}
function CheckIPConnection(IP, IPTable: string): Boolean;
var
  Buf: TStrings;
  i : Integer;
begin
  Result := True;
  Buf := TStringList.Create;
  try
    Buf.Text := IPTable;
    for i := 0 to Buf.Count - 1 do
    if Pos(IP + ':', Buf[i]) > 0 then
      if Pos('ESTABLISHED', Buf[i]) > 0 then Exit;    
    Result := False;
  finally
    Buf.Free;
  end;
end;

function MD5String(const Value: string): string;
{
  把Value进行计算MD5散列值
}
var
  MD5Context: TMD5Ctx;
  i : Integer;
  s : string;
begin
  MD5Init(MD5Context);
  MD5Update(MD5Context, PChar(Value), Length(Value));
  s := MD5Final(MD5Context);
  for i := 1 to Length(s) do
    Result := Result + Format('%x', [Byte(s[i])]);
  Result := LowerCase(Result);
end;

function GetByteFromInt(const AInt, AOffset: Integer): Char;
begin
  case AOffset of
    0: Result := Char(AInt and $FF);
    1: Result := Char(AInt and $FF00);
    2: Result := Char(AInt and $FF0000);
    3: Result := Char(AInt and $FF000000);
  else
    Result := #0;
  end;
end;

constructor TWinGateAuther.Create;
begin
  TCP := TIdTCPClient.Create(nil);
end;

destructor TWinGateAuther.Destroy;
begin
  Logout;
  TCP.Free;
  inherited;
end;

function TWinGateAuther.Logined: Boolean;
begin
  Result := TCP.Connected;
  if not Result then Exit;
  
  try
    TCP.ReadLn(#$A, 10);
    TCP.CheckForDisconnect(True);
    TCP.CheckForGracefulDisconnect(True);
    Result := True;
  except
    TCP.Disconnect;
    Result := False;
  end;
end;

function TWinGateAuther.Logon(const Username, Password, Host: string;
                              const Port: Integer): Boolean;
var
  Header: packed record
            PacketLength : Byte;
            MajorVersion: Byte;
            MinorVersion: Byte;
            ClientType: Byte;
            Command: Byte;
          end;
  rawChallenge: string;
  Buffer: string;
  Len : Integer;
begin
  FillChar(Header, SizeOf(Header), 0);

  if TCP.Connected then
    raise Exception.Create('Already logon');

  TCP.Host := Host;
  TCP.Port := Port;
  TCP.Connect;
  TCP.ReadBuffer(Header, SizeOf(Header));
  if (Header.MajorVersion <> 1) then
    raise Exception.Create('Error - Bad Version Number');
  if Header.Command <> 1 then
    raise Exception.Create('Error - Bad Protocol');

  rawChallenge := TCP.ReadString(Header.PacketLength - 5);
  if TCP.ReadChar <> #0 then
    raise Exception.Create('Error - Bad Terminator');

  Buffer := #1#3#3
               + GetByteFromInt(TCP.Socket.Binding.PeerPort, 0)
               + GetByteFromInt(TCP.Socket.Binding.PeerPort, 1)
               + GetByteFromInt(TCP.Socket.Binding.PeerPort, 2)
               + GetByteFromInt(TCP.Socket.Binding.PeerPort, 3)
               + #2 + Username + #0 + MD5String(rawChallenge + Password) + #0#0;
  TCP.WriteChar(Char(Length(Buffer)));
  TCP.Write(Buffer);
  Len := Byte(TCP.ReadChar);
  if Len < 4 then raise Exception.Create('Internal error');
  Buffer := TCP.ReadString(Len);
  if Buffer[4] <> #4 then  // 返回值不正确，登录失败
  begin
    TCP.Disconnect;
    raise Exception.Create('Log on failed');
  end;

  Result := True;
end;

procedure TWinGateAuther.Logout;
begin
  TCP.Disconnect;
end;

procedure TFrmMain.About1Click(Sender: TObject);
const
  CSAbout = 'Copyright 2008, Kingron.';
begin
  DlgInfo(CSAbout);
end;

procedure TFrmMain.AddTrayIcon;
begin
  ZeroMemory(@IconData, SizeOf(TNotifyIconData));
  IconData.cbSize := SizeOf(TNotifyIconData);
  IconData.Wnd := Handle;
  IconData.uID := 1;
  IconData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_INFO or NIF_TIP;
  IconData.uCallbackMessage := WM_TrayIcon;
  IconData.hIcon := Application.Icon.Handle;
  StrPCopy(IconData.szTip, Caption);
  StrPCopy(IconData.szInfoTitle, 'WinGate Authenticate');
  IconData.uTimeout := 10000;
  IconData.dwInfoFlags := NIIF_INFO;

  Shell_NotifyIcon(NIM_ADD, @IconData);
end;

procedure TFrmMain.btnKeyClick(Sender: TObject);
var
  Err : Cardinal;
begin
  UnregisterHotKey(Handle, 1);
  RegisterKey;
  Err := GetLastError;
  if Err <> 0 then DlgError(SysErrorMessage(Err));
end;

procedure TFrmMain.btnLogonClick(Sender: TObject);
var
  Host: string;
  Port: Integer;
begin
  Host := LeftPart(edtHost.Text, ':');
  Port := StrToInt(RightPart(edtHost.Text, ':'));
  btnLogon.Update;
  try
    WinGater.Logon(edtUser.Text, edtPassword.Text, Host, Port);
    UpdateUI(False);
    EmptyWorkingSet(GetCurrentProcess);
    IconData.dwInfoFlags := NIIF_INFO;
    IconData.hIcon := LoadIcon(HInstance, 'online');
    StrPCopy(IconData.szInfo, 'WinGate Login Success!');
    Shell_NotifyIcon(NIM_MODIFY, @IconData);
    Visible := False;
    if (Trim(edtCmd.Text) <> '') and WinGater.Logined then
      WinExec(PChar(edtCmd.Text), SW_SHOW);
  except
    on E: Exception do DlgError(e.Message);
  end;
  EmptyWorkingSet(GetCurrentProcess);
end;


procedure TFrmMain.btnLogoutClick(Sender: TObject);
var
  s, IP, Msg: string;
  niif : Word;
begin
  if not WinGater.Logined then Exit;

  WinGater.Logout;

  if ShutDown then Exit;
  
  IP := HostToIP(LeftPart(edtHost.Text, ':'));
  s := GetDosOutput('netstat -n');
  if CheckIPConnection(IP, s) then
  begin
    niif := NIIF_WARNING;
    Msg := 'Logout success.' + CrLf + 'Some connections still use proxy server!';
  end
  else
  begin
    niif := NIIF_INFO;
    Msg := 'WinGate Logout Success.';
  end;

  UpdateUI(True);
  IconData.hIcon := LoadIcon(HInstance, 'offline');
  IconData.dwInfoFlags := niif;
  StrPCopy(IconData.szInfo, Msg);
  Shell_NotifyIcon(NIM_MODIFY, @IconData);
  EmptyWorkingSet(GetCurrentProcess);
end;

procedure TFrmMain.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Visible := False;
  EmptyWorkingSet(GetCurrentProcess);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  s : string;
begin
  AddTrayIcon;
  WinGater := TWinGateAuther.Create;
  edtUser.Text := IniReadString(AppFileExt, CSConfig, 'User', '');
  s := IniReadString(AppFileExt, CSConfig, 'Password', '');
  s := HexToData(s);
  edtCmd.Text := IniReadString(AppFileExt, CSConfig, 'Cmd', '');
  edtPassword.Text := DecryptString(s, CSKey);
  edtHost.Text := IniReadString(AppFileExt, CSConfig, 'Proxy', 'proxy:808');
  chkAuto.Checked := IniReadBool(AppFileExt, CSConfig, 'Auto', False);
  s := RegReadString(HKEY_CURRENT_USER, CSRegKey, 'WGA');
  chkAutoStart.Checked := SameText(s, ParamStr(0));
  chkMin.Checked := IniReadBool(AppFileExt, CSConfig, 'Minimize', False);
  if chkMin.Checked then Application.ShowMainForm := False;
  hkKey.Hotkey := TextToShortCut(IniReadString(AppFileExt, CSConfig, 'Hotkey', 'Ctrl+F12'));
  RegisterKey;
  if chkAuto.Checked then btnLogon.Click;
  Height := 190;
  grp1.Visible := False;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var
  s: string;
begin
  UnregisterHotKey(Handle, 1);
  Shell_NotifyIcon(NIM_DELETE, @IconData);
  btnLogout.Click;
  IniWriteString(AppFileExt, CSConfig, 'User', edtUser.Text);
  s := EncryptString(edtPassword.Text, CSKey);
  s := DataToHex(PChar(s), Length(s));
  IniWriteString(AppFileExt, CSConfig, 'Password', s);
  IniWriteString(AppFileExt, CSConfig, 'Cmd', edtCmd.Text);
  IniWriteString(AppFileExt, CSConfig, 'Proxy', edtHost.Text);
  IniWriteInteger(AppFileExt, CSConfig, 'Auto', Ord(chkAuto.Checked));
  IniWriteInteger(AppFileExt, CSConfig, 'Minimize', Ord(chkMin.Checked));
  IniWriteString(AppFileExt, CSConfig, 'Hotkey', ShortCutToText(hkKey.Hotkey));
  if chkAutoStart.Checked then
    RegWriteString(HKEY_CURRENT_USER, CSRegKey, 'WGA', ParamStr(0))
  else
    RegValueDelete(HKEY_CURRENT_USER, CSRegKey, 'WGA');
  WinGater.Free;
end;

procedure TFrmMain.WMHotkey(var msg:TWMHOTKEY);
begin
  case msg.HotKey of
    1: LogonLogoff1.Click;
  end;
end;

procedure TFrmMain.lblAdvanceClick(Sender: TObject);
begin
  if lblAdvance.Tag = 0 then
  begin
    Height := 348;
    lblAdvance.Caption := '5';
    lblAdvance.Tag := 1;
    grp1.Visible := True;
  end
  else
  begin
    lblAdvance.Caption := '6';
    Height := 190;
    lblAdvance.Tag := 0;
    grp1.Visible := False;
  end;
end;

procedure TFrmMain.LogonLogoff1Click(Sender: TObject);
begin
  if btnLogon.Enabled then
    btnLogon.Click
  else
    btnLogout.Click;
end;

procedure TFrmMain.OnShutDown(var msg: TWMQueryEndSession);
begin
  msg.Result := 1;
  Application.Terminate;
  ShutDown := True;
end;

procedure TFrmMain.RegisterKey;
var
  t : TShiftState;
begin
  ShortCutToKey(hkKey.Hotkey, Key, T);
  Shift := ShiftStateToWord(T);
  RegisterHotKey(Handle, 1, Shift, Key);
end;

procedure TFrmMain.ShowMainForm1Click(Sender: TObject);
begin
  SetForegroundWindow(Handle);
  Visible := not Visible;
end;

procedure TFrmMain.tmr1Timer(Sender: TObject);
begin
  UpdateUI(not WinGater.Logined);
  if not WinGater.Logined then
  begin
    IconData.dwInfoFlags := NIIF_ERROR;
    StrPCopy(IconData.szInfo, 'Disconnect detected!');
    IconData.hIcon := Application.Icon.Handle;
    Shell_NotifyIcon(NIM_MODIFY, @IconData);
  end;
end;

procedure TFrmMain.TrayIconMessage(var Msg: TMessage);
begin
  case Msg.LParam of
    WM_RBUTTONUP:
      begin
        SetForegroundWindow(Handle);
        pm1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
      end;
    WM_LBUTTONUP: LogonLogoff1.Click;
    WM_MBUTTONUP: ShowMainForm1.Click;
  end;
end;

procedure TFrmMain.UpdateUI(AEnable: Boolean);
begin
  btnLogon.Enabled := AEnable;
  btnLogout.Enabled := not AEnable;
  tmr1.Enabled := not AEnable;
end;

procedure TFrmMain.WMReload(var Msg: TMessage);
begin
  IconData.dwInfoFlags := NIIF_WARNING;
  StrPCopy(IconData.szInfo, 'WGA already running!');
  StrPCopy(IconData.szInfoTitle, 'Warnning');
  Shell_NotifyIcon(NIM_MODIFY, @IconData);
end;

end.
