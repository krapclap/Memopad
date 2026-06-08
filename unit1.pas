unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ComCtrls, PrintersDlgs, Printers, ExtCtrls, unit2, uhistory, LCLType, LCLIntf,
  IniPropStorage, Buttons, Clipbrd, RxTextHolder;

type

  { TForm1 }

  TForm1 = class(TForm)
    FontDialog: TFontDialog;
    ImageList: TImageList;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    MainMenu: TMainMenu;
    MenuItem3: TMenuItem;
    MRecent: TMenuItem;
    MLight: TMenuItem;
    MDark: TMenuItem;
    MFont: TMenuItem;
    MNew: TMenuItem;
    MQuit: TMenuItem;
    MWordWrap: TMenuItem;
    MAbout: TMenuItem;
    MZoom: TMenuItem;
    MZoomIn: TMenuItem;
    MZoomOut: TMenuItem;
    MReset: TMenuItem;
    MStatusBar: TMenuItem;
    MUndo: TMenuItem;
    MCut: TMenuItem;
    MCopy: TMenuItem;
    MPaste: TMenuItem;
    MRedo: TMenuItem;
    RecentFileList: TRxTextHolder;
    Separator1: TMenuItem;
    MPrint: TMenuItem;
    OpenDialog: TOpenDialog;
    Pad: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MOpen: TMenuItem;
    MSave: TMenuItem;
    MSaveAs: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    PrintDialog: TPrintDialog;
    SaveDialog: TSaveDialog;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure MainMenuDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      AState: TOwnerDrawState);
    procedure MDarkClick(Sender: TObject);
    procedure MRecentClick(Sender: TObject);
    procedure MFontClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MLightClick(Sender: TObject);
    procedure MNewClick(Sender: TObject);
    procedure MQuitClick(Sender: TObject);
    procedure MWordWrapClick(Sender: TObject);
    procedure MAboutClick(Sender: TObject);
    procedure MZoomInClick(Sender: TObject);
    procedure MZoomOutClick(Sender: TObject);
    procedure MResetClick(Sender: TObject);
    procedure MStatusBarClick(Sender: TObject);
    procedure MUndoClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MCutClick(Sender: TObject);
    procedure MCopyClick(Sender: TObject);
    procedure MPasteClick(Sender: TObject);
    procedure MRedoClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MOpenClick(Sender: TObject);
    procedure MSaveClick(Sender: TObject);
    procedure MSaveAsClick(Sender: TObject);
    procedure MPrintClick(Sender: TObject);
    procedure PadChange(Sender: TObject);
    procedure PadClick(Sender: TObject);
    procedure PadKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StatusBar1Click(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure StatusBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StatusBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusBar1Resize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
              History: THistory;
  public
        procedure AddRecentFile(const AFileName: String);
        procedure RecentFileClick(Sender: TObject);
        procedure RefreshRecentFilesMenu;
  end;

var
  Form1: TForm1;
  Fotn: String;
  MouseOnTheMove: Boolean = False;
  MO: integer;

implementation
{$R *.lfm}

{ TForm1 }
function IsKeyToggled(vKey: Integer): Boolean;
begin
  Result := ((GetKeyState(vKey) and 1) = 1);
end;

procedure TForm1.AddRecentFile(const AFileName: String);
var
  ExistingIndex: Integer;
begin

  ExistingIndex := RecentFileList.IndexByName(AFileName);
  if ExistingIndex >= 0 then
    RecentFileList.Items.Delete(RecentFileList.IndexByName(AFileName));
  RecentFileList.Items.Insert(0);
  RecentFileList.Items.Items[0].Caption := AFileName;
  while RecentFileList.Items.Count > 9 do
    RecentFileList.Items.Delete(RecentFileList.Items.Count - 1);
  RefreshRecentFilesMenu;
end;

procedure TForm1.RefreshRecentFilesMenu;
var
  I: Integer;
  NewItem: TMenuItem;
begin
  MRecent.Clear;
  if RecentFileList.Items.Count = 0 then
  begin
    MRecent.Enabled := False;
    Exit;
  end;
  MRecent.Enabled := True;
  for I := 0 to RecentFileList.Items.Count - 1 do
  begin
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := Format('&%d: %s', [I + 1, RecentFileList.Items.Items[I].Caption]);
    NewItem.Tag := I;
    NewItem.OnClick := @RecentFileClick;
    NewItem.ImageIndex := 0;
    MRecent.Add(NewItem);
  end;
end;

procedure TForm1.RecentFileClick(Sender: TObject);
var
  ClickedIndex: Integer;
  SelectedFile: String;
begin
  if Sender is TMenuItem then
  begin
    ClickedIndex := TMenuItem(Sender).Tag;
    SelectedFile := RecentFileList.Items.Items[ClickedIndex].Caption;
     if not FileExists(SelectedFile) then
    begin
      MessageDlg('File Not Found',
                 'The file "' + SelectedFile + '" no longer exists, Removing record.',
                 mtError, [mbOK], 0);
      RecentFileList.Items.Items[ClickedIndex].Destroy;
      RefreshRecentFilesMenu;
      Exit;
    end;
    Pad.Lines.LoadFromFile(SelectedFile);
    StatusBar1.Panels.Items[3].Text := SelectedFile;
    StatusBar1.Panels.Items[2].Text := 'Unmodified';
    AddRecentFile(SelectedFile);
  end;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
    If   StatusBar1.Panels.Items[3].Text = 'Unsaved File' then
    begin
    MSave.Enabled := false;
    end
    else
    begin
       if StatusBar1.Panels.Items[2].Text = 'Modified' then MSave.Enabled := true else MSave.Enabled := false;
     end

    end;

procedure TForm1.MCutClick(Sender: TObject);
begin
  Pad.CutToClipboard;
end;

procedure TForm1.MCopyClick(Sender: TObject);
begin
  Pad.CopyToClipboard;
end;

procedure TForm1.MPasteClick(Sender: TObject);
begin
 History.PasteText;
end;

procedure TForm1.MRedoClick(Sender: TObject);
begin
  History.redo;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  MUndo.Enabled := History.CanUndo;
  MRedo.Enabled := History.CanRedo;
end;

procedure TForm1.MOpenClick(Sender: TObject);
begin
  if OpenDialog.Execute then
                begin
                 Pad.Lines.LoadFromFile(OpenDialog.FileName);
                 StatusBar1.Panels.Items[3].Text := OpenDialog.Filename;
                 StatusBar1.Panels.Items[2].Text := 'Unmodified';
                 AddRecentFile(OpenDialog.FileName);
                 end;
end;

procedure TForm1.MSaveClick(Sender: TObject);
begin
  Pad.Lines.SaveToFile(StatusBar1.Panels.Items[3].Text);
  StatusBar1.Panels.Items[2].Text := 'Unmodified';
end;

procedure TForm1.MSaveAsClick(Sender: TObject);
begin
  if SaveDialog.Execute then
                begin
                 Pad.Lines.SaveToFile(SaveDialog.FileName);
                 StatusBar1.Panels.Items[2].Text := 'Unmodified';
                end;
end;

procedure TForm1.MPrintClick(Sender: TObject);
var
  i, lineCount, linesPerPage: Integer;
  scaleFactor: Double;
  lh: Integer;
begin
  if PrintDialog.Execute then
  begin
    Printers.printer.BeginDoc;
    try
      Printer.Canvas.Font.Assign(Pad.Font);
      scaleFactor := Printer.XDPI / Screen.PixelsPerInch;
      Printer.Canvas.Font.Size := trunc(strtoint(StatusBar1.Panels.Items[1].Text) * scaleFactor);


      lh := trunc(Printer.Canvas.TextHeight('Xg') * 1.2);
      linesPerPage := trunc(Printer.PaperSize.PaperRect.WorkRect.Bottom div lh) - 1;

      lineCount := 1;


      for i := 0 to Pad.Lines.Count - 1 do
      begin
        Printer.Canvas.TextOut(0, trunc(lh * lineCount), Pad.Lines[i]);
        Inc(lineCount);


        if (lineCount > linesPerPage) and (i < Pad.Lines.Count - 1) then
        begin
          Printer.NewPage;
          lineCount := 1;
        end;
      end;
    finally
      Printer.EndDoc;
    end;
  end;
end;

procedure TForm1.PadChange(Sender: TObject);
begin
      StatusBar1.Panels.Items[2].Text := 'Modified';
end;

procedure TForm1.PadClick(Sender: TObject);
begin
   Statusbar1.Panels[8].Text:= IntToStr(Pad.CaretPos.Y + 1)+':' +IntToStr(Pad.CaretPos.X + 1);
end;

procedure TForm1.PadKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Statusbar1.Panels[8].Text:= IntToStr(Pad.CaretPos.Y + 1)+':' +IntToStr(Pad.CaretPos.X + 1);
end;

procedure TForm1.StatusBar1Click(Sender: TObject);
begin

end;

procedure TForm1.StatusBar1DblClick(Sender: TObject);
begin

end;

procedure TForm1.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin

  StatusBar1.Canvas.Brush.Color := Form1.Color;
  StatusBar1.Canvas.FillRect(Rect);
  if Panel.Index = 0 then
      begin
           StatusBar1.Canvas.Font.Assign(Pad.font);
           StatusBar1.Canvas.Font.Color := (Form1.font.Color);
           if not StatusBar1.Panels.Items[0].Width = StatusBar1.Canvas.TextWidth(StatusBar1.Panels.Items[0].Text) +15 then StatusBar1.Panels.Items[0].Width := StatusBar1.Canvas.TextWidth(StatusBar1.Panels.Items[0].Text) +15;
      end
  else
      begin
           //StatusBar1.Canvas.Font.Assign(Form1.font);
           //StatusBar1.Canvas.Font.Name := (Fotn);
           StatusBar1.Canvas.Font.Color := (Form1.font.Color);
      end;
  StatusBar1.Canvas.Font.Size := 12;
  StatusBar1.Height := StatusBar1.Canvas.TextHeight(StatusBar1.Panels.Items[0].Text) +6;
  StatusBar1.Canvas.TextRect(Rect, Rect.Left +2, Rect.Top +2, Panel.Text);
end;

procedure TForm1.StatusBar1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if StatusBar1.GetPanelIndexAt(X, Y) = 1 then
   begin
        if Button = mbLeft then
        begin
        MouseOnTheMove := True;
        MO := Y;
        end;
        if Button = mbRight then MReset.OnClick(self);
   end;
end;

procedure TForm1.StatusBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If MouseOnTheMove = True then Pad.Font.Size := StrToInt(StatusBar1.Panels.Items[1].Text) + MO -Y;
end;

procedure TForm1.StatusBar1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
   MouseOnTheMove := False;
if button = mbLeft then
   begin
   if StatusBar1.GetPanelIndexAt(X, Y) = 0 then MFont.OnClick(self);
   if StatusBar1.GetPanelIndexAt(X, Y) = 2 then MSaveAs.OnClick(Self);
   if StatusBar1.GetPanelIndexAt(X, Y) = 3 then MOpen.OnClick(self);
   end;
if button = mbRight then
  begin
   if Statusbar1.Panels[3].Text <> 'Unsaved File' then Clipboard.AsText := Statusbar1.Panels[3].Text else MOpen.OnClick(self);
   end;
  end;



procedure TForm1.StatusBar1Resize(Sender: TObject);
begin
  StatusBar1.Panels.Items[3].Width := Form1.Width - StatusBar1.Panels.Items[0].width - StatusBar1.Panels.Items[1].width - StatusBar1.Panels.Items[2].width - StatusBar1.Panels.Items[4].width - StatusBar1.Panels.Items[5].width - StatusBar1.Panels.Items[6].width - StatusBar1.Panels.Items[7].width - StatusBar1.Panels.Items[8].width -20;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if IsKeyToggled(VK_CAPITAL) then
StatusBar1.Panels.Items[4].Text :='CAP'
  else if StatusBar1.Panels.Items[4].Text <> '' then StatusBar1.Panels.Items[4].Text := '';
  if IsKeyToggled(VK_NUMLOCK) then
    StatusBar1.Panels.Items[5].Text := 'NUM'
  else if StatusBar1.Panels.Items[5].Text <> '' then StatusBar1.Panels.Items[5].Text := '';
  if IsKeyToggled(VK_SCROLL) then
    StatusBar1.Panels.Items[6].Text := 'SCR'
  else if StatusBar1.Panels.Items[6].Text <> '' then StatusBar1.Panels.Items[6].Text := '';
  if IsKeyToggled(VK_INSERT) then
    StatusBar1.Panels.Items[7].Text := 'INS'
  else if StatusBar1.Panels.Items[7].Text <> '' then StatusBar1.Panels.Items[7].Text := '';


end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
   StatusBar1.Panels.Items[0].Width := StatusBar1.Canvas.TextWidth(StatusBar1.Panels[0].Text) +20;
   StatusBar1.Panels.Items[3].Width := Form1.Width - StatusBar1.Panels.Items[0].width - StatusBar1.Panels.Items[1].width - StatusBar1.Panels.Items[2].width - StatusBar1.Panels.Items[4].width - StatusBar1.Panels.Items[5].width - StatusBar1.Panels.Items[6].width - StatusBar1.Panels.Items[7].width - StatusBar1.Panels.Items[8].width -20;
   RefreshRecentFilesMenu;
   if StatusBar1.Panels.Items[3].Text <> 'Unsaved File' then AddRecentFile(StatusBar1.Panels.Items[3].Text);
   Timer2.Enabled := False;
end;

procedure TForm1.FormShow(Sender: TObject);
var
Result: string;
begin
  Result := '';
  if fsBold in Pad.Font.Style then Result := Result + ' Bold';
  if fsItalic in Pad.Font.Style then Result := Result + ' Italic';
  if fsUnderline in Pad.Font.Style then Result := Result + ' Underline';
  if fsStrikeOut in Pad.Font.Style then Result := Result + ' Strikethrough';
  if Result = '' then Result := ' Regular';
       StatusBar1.Panels.Items[0].Text:= Pad.Font.Name +Result;
       StatusBar1.Panels.Items[1].Text:= pad.Font.Size.ToString;
       StatusBar1.Panels.Items[0].Width := StatusBar1.Canvas.TextWidth(Pad.Font.Name +Result) +20;
end;

procedure TForm1.MLightClick(Sender: TObject);
begin
  If MDark.Checked = true then
  begin
    MLight.Checked := True;
    MDark.Checked := False;
    Pad.Color := clWhite;
        Pad.Font.Color := clBlack;
    Form1.Color := RGBToColor(192,192,192);
    form1.Font.Color := clBlack;
    end
    else
    begin
  MLight.Checked := True;

  end;

end;

procedure TForm1.MNewClick(Sender: TObject);
var
  Reply: integer;
begin
  if StatusBar1.Panels.Items[2].Text = 'Modified' then
  begin
       Reply:= MessageDlg('This file has been modified. Do you want to save the changes?', mtConfirmation,
       [mbYes, mbNo, mbCancel],0);

       if Reply = mrYes then
       begin
            if StatusBar1.Panels.Items[3].Text = 'Unsaved File' then
            begin
            if SaveDialog.Execute then
                begin
                 Pad.Lines.SaveToFile(SaveDialog.FileName);
                 Pad.Lines.Clear;
                 StatusBar1.Panels.Items[3].Text := 'Unsaved File';
                 StatusBar1.Panels.Items[2].Text := 'Unmodified';
                 SaveDialog.FileName:= '';
                 OpenDialog.FileName:= '';
                end;
            end
            else
            begin
             Pad.Lines.SaveToFile(StatusBar1.Panels.Items[2].Text);
             Pad.Lines.Clear;
             StatusBar1.Panels.Items[3].Text := 'Unsaved File';
             StatusBar1.Panels.Items[2].Text := 'Unmodified';
                              SaveDialog.FileName:= '';
                 OpenDialog.FileName:= '';
            end
       end
       else if Reply = mrNo then
           begin
           Pad.Lines.Clear;
           StatusBar1.Panels.Items[3].Text := 'Unsaved File';
           StatusBar1.Panels.Items[2].Text := 'Unmodified';
                            SaveDialog.FileName:= '';
                 OpenDialog.FileName:= '';
           end

   end
  else
    begin
                      Pad.Lines.Clear;
                 StatusBar1.Panels.Items[3].Text := 'Unsaved File';
                 StatusBar1.Panels.Items[2].Text := 'Unmodified';
                                  SaveDialog.FileName:= '';
                 OpenDialog.FileName:= '';
    end

end;

procedure TForm1.MQuitClick(Sender: TObject);
begin

     Close;

end;

procedure TForm1.MWordWrapClick(Sender: TObject);
begin
  MWordWrap.Checked :=  not MWordWrap.Checked;
  Pad.WordWrap:=MWordWrap.Checked;
end;

procedure TForm1.MAboutClick(Sender: TObject);
begin
  if Form2 = nil then
  Application.CreateForm(TForm2, Form2);
Form2.Show;
end;

procedure TForm1.MZoomInClick(Sender: TObject);
begin
   Pad.Font.Size := Pad.Font.Size * 2;
end;

procedure TForm1.MZoomOutClick(Sender: TObject);
begin
  if Pad.Font.Size > 4 then Pad.Font.Size := round(Pad.Font.Size / 2);
end;

procedure TForm1.MResetClick(Sender: TObject);
begin
  Pad.Font.Size := strtoint(StatusBar1.Panels.Items[1].Text);
end;

procedure TForm1.MStatusBarClick(Sender: TObject);
begin
   StatusBar1.Visible := not StatusBar1.Visible;
   MStatusBar.Checked := StatusBar1.Visible;
end;

procedure TForm1.MUndoClick(Sender: TObject);
begin
  History.Undo;
end;

procedure TForm1.MFontClick(Sender: TObject);
var
Result: string;
begin
       FontDialog.Font.Assign(Pad.Font);
       FontDialog.Font.Size := Pad.Font.Size;
       if FontDialog.Execute then
       begin
          Pad.Font.Assign(Fontdialog.Font);
          if fsBold in Pad.Font.Style then Result := Result + ' Bold';
          if fsItalic in Pad.Font.Style then Result := Result + ' Italic';
          if fsUnderline in Pad.Font.Style then Result := Result + ' Underline';
          if fsStrikeOut in Pad.Font.Style then Result := Result + ' Strikethrough';
          if Result = '' then Result := ' Regular';
          StatusBar1.Panels.Items[0].Text:= Pad.Font.Name +Result;
          StatusBar1.Panels.Items[1].Text:= pad.Font.Size.ToString;
          StatusBar1.Panels.Items[0].Width := StatusBar1.Canvas.TextWidth(Pad.Font.Name +Result) +20;
       end;
end;

procedure TForm1.MainMenuDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin
end;

procedure TForm1.MDarkClick(Sender: TObject);
begin
   If MLight.Checked = true then
  begin
    MDark.Checked := True;
    MLight.Checked := False;
    Pad.Color := RGBToColor(0,28,35);
    Pad.Font.Color := RGBToColor(192,192,192);
    Form1.Color := RGBToColor(0,25,30);
    form1.Font.Color := clWhite;
  end
   else
   begin
     MDark.Checked := True;
  end;
end;

procedure TForm1.MRecentClick(Sender: TObject);
begin

end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Reply: integer;
begin
   MReset.OnClick(self);
   if StatusBar1.Panels.Items[2].Text = 'Modified' then
  begin
       Reply:= MessageDlg('This file has been modified. Do you want to save the changes?', mtConfirmation,
       [mbYes, mbNo, mbCancel],0);

       if Reply = mrYes then
       begin
            if StatusBar1.Panels.Items[3].Text = 'Unsaved File' then
            begin
            if SaveDialog.Execute then
                begin
                 Pad.Lines.SaveToFile(SaveDialog.FileName);
                 CanClose := True;
                 //Close;
                end;
            end
            else
            begin
             Pad.Lines.SaveToFile(StatusBar1.Panels.Items[3].Text);
             CanClose := True;
             //Close;
            end
       end
       else if Reply = mrCancel then
           begin
             CanClose := False;
           end

   end
  else
    begin

    end

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IniPropStorage1.IniFileName := ExtractFilePath(Application.ExeName) + 'config.ini';
  if ParamCount > 0 then
  begin
     Pad.Lines.LoadFromFile(ParamStr(1));
     StatusBar1.Panels.Items[3].Text := ParamStr(1);
     StatusBar1.Panels.Items[2].Text := 'Unmodified';
     AddRecentFile(Paramstr(1));
  end;
  History := THistory.Create(Pad, ' ');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  History.Free;
end;

end.

