program WGA;

{$R 'Icon.res' 'Icon.rc'}

uses
  Forms,
  Windows,
  MainForm in 'MainForm.pas' {FrmMain};

{$R *.res}
var
  Mutex: THandle;
  Wnd: HWND;
begin
  Mutex := CreateMutex(nil, False, '_WGA_LYH_MUTEX_');
  if (GetLastError = ERROR_ALREADY_EXISTS) or (Mutex = 0) then
  begin
    Wnd := FindWindow('TFrmMain', 'WinGate Authenticate');
    SendMessage(Wnd, WM_RELOAD, 0, 0);
    Exit;
  end;
  
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
  CloseHandle(Mutex);
end.
