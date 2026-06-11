unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ComCtrls, PrintersDlgs, RTTICtrls, Printers, ExtCtrls, unit2, uhistory,
  LCLType, LCLIntf, IniPropStorage, RxTextHolder, ATPanelSimple, ATPanelColor,
  Clipbrd, PopupNotifier, MaskEdit, ValEdit, Spin, TplSearchPanelUnit,
  TplColorPanelUnit, strUtils, RegExpr;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    MatchC: TCheckBox;
    WCheck: TCheckBox;
    FindDialog: TFindDialog;
    FontDialog: TFontDialog;
    Image1: TImage;
    ImageList: TImageList;
    IniPropStorage1: TIniPropStorage;
    LFont: TLabel;
    LogoBox: TPaintBox;
    MainMenu: TMainMenu;
    MenuItem3: TMenuItem;
    MFind: TMenuItem;
    MRetro: TMenuItem;
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
    Panel1: TPanel;
    SPanel: TplSearchPanel;
    pop: TPopupNotifier;
    Popt: TTimer;
    WelcomePanel: TPanel;
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
    LoadTimer: TTimer;
    AnimTimer: TTimer;
    procedure AnimTimerTimer(Sender: TObject);
    procedure LogoBoxPaint(Sender: TObject);
    procedure MDarkClick(Sender: TObject);
    procedure MFindClick(Sender: TObject);
    procedure MRetroClick(Sender: TObject);
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
    procedure PadKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SPanelDblClick(Sender: TObject);
    procedure SPanelSearch(Sender: TObject; incremental,
      backwards: boolean);
    procedure StatusBar1Click(Sender: TObject);
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
    procedure LoadTimerTimer(Sender: TObject);
    procedure Poptimer(Sender: TObject);
  private
         History: THistory;
         FrameStep: Integer;
         IconBitmap: TBitmap;
         CurrentScale: Double;
         CurrentAngle: Double;
         procedure RotateAndDraw(DestCanvas: TCanvas; CenterX, CenterY: Integer; SrcBitmap: TBitmap; Angle: Double; Scale: Double);
  public
         oi: integer;
         R, G, B: Byte;
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

procedure TForm1.RotateAndDraw(DestCanvas: TCanvas; CenterX, CenterY: Integer; SrcBitmap: TBitmap; Angle: Double; Scale: Double);
var
  CosA, SinA: Double;
  HalfW, HalfH: Integer;
  Points: array[0..3] of TPoint;
begin
  CosA := Cos(Angle) * Scale;
  SinA := Sin(Angle) * Scale;
  HalfW := SrcBitmap.Width div 2;
  HalfH := SrcBitmap.Height div 2;
  Points[0].X := CenterX + Round(-HalfW * CosA - -HalfH * SinA);
  Points[0].Y := CenterY + Round(-HalfW * SinA + -HalfH * CosA);
  Points[1].X := CenterX + Round(HalfW * CosA - -HalfH * SinA);
  Points[1].Y := CenterY + Round(HalfW * SinA + -HalfH * CosA);
  Points[2].X := CenterX + Round(HalfW * CosA - HalfH * SinA);
  Points[2].Y := CenterY + Round(HalfW * SinA + HalfH * CosA);
  Points[3].X := CenterX + Round(-HalfW * CosA - HalfH * SinA);
  Points[3].Y := CenterY + Round(-HalfW * SinA + HalfH * CosA);
  DestCanvas.AntialiasingMode := amOn;
  DestCanvas.StretchDraw(TRect.Create(Points[0].X, Points[0].Y, Points[2].X, Points[2].Y), SrcBitmap);
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
  vk: Word;
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
    vk := Ord('1') + i;
    NewItem.ShortCut := Shortcut(VK, [ssCtrl, ssShift]);
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
       if StatusBar1.Panels.Items[2].Text = 'Modified' then
         MSave.Enabled := true else MSave.Enabled := false;
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

procedure TForm1.PadKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Statusbar1.Panels[8].Text:= IntToStr(Pad.CaretPos.Y + 1)+':' +IntToStr(Pad.CaretPos.X + 1);
end;

procedure TForm1.SPanelDblClick(Sender: TObject);
begin

end;

procedure TForm1.SPanelSearch(Sender: TObject; incremental, backwards: boolean);
var
  SearchText, MemoText: string;
  StartPos, FoundPos: Integer;
  IsMatch: Boolean;
  WordLen: Integer;
  Regex: TRegExpr;
begin
  // 1. Case-Sensitivity Setup
  if MatchC.Checked then
  begin
    SearchText := SPanel.SearchText;
    MemoText := Pad.Text;
  end
  else
  begin
    SearchText := LowerCase(SPanel.SearchText);
    MemoText := LowerCase(Pad.Text);
  end;

  WordLen := Length(SearchText);
  if WordLen = 0 then
  begin
    pop.Text := 'Search Canceled, Nothing to search!';
    Pop.ShowAtPos(Form1.Left + (Form1.Width div 2) - 170, Form1.Top);
    Popt.Enabled := True;
    Exit;
  end;

  FoundPos := 0;
  IsMatch := False;

  // 2. Determine initial search anchor position (1-based index)
  if not backwards then
  begin
    if Pad.SelLength > 0 then
      StartPos := Pad.SelStart + Pad.SelLength + 1
    else
      StartPos := Pad.SelStart + 1;
    if StartPos > Length(MemoText) then StartPos := 1; // Wrap baseline
  end
  else
  begin
    if Pad.SelStart > 0 then
      StartPos := Pad.SelStart
    else
      StartPos := Length(MemoText);
  end;

  // 3. STRATEGY A: WHOLE WORD SEARCH (RegEx ONLY)
  if WCheck.Checked then
  begin
  Regex := TRegExpr.Create;
  try
    // \Q starts literal escaping; \E ends it. This protects special characters safely.
    Regex.Expression := '\b' + SPanel.SearchText + '\b';
    Regex.ModifierI := not MatchC.Checked; // ModifierI = True means Case-Insensitive

    // Execute search on the string
    if Regex.Exec(MemoText) then
    begin
      if not backwards then
      begin
        // --- FORWARD SEARCH ---
        repeat
          if Regex.MatchPos[0] >= StartPos then
          begin
            FoundPos := Regex.MatchPos[0];
            IsMatch := True;
            Break;
          end;
        until not Regex.ExecNext;

        // Wrap Around: If nothing found past StartPos, reset and take absolute first match
        if not IsMatch then
        begin
          if Regex.Exec(MemoText) then
          begin
            FoundPos := Regex.MatchPos[0];
            IsMatch := True;
          end;
        end;
      end
      else
      begin
        // --- BACKWARD SEARCH ---
        // Track the latest match occurring strictly BEFORE our start position anchor
        repeat
          if Regex.MatchPos[0] <= StartPos then
            FoundPos := Regex.MatchPos[0];
        until not Regex.ExecNext;

        if FoundPos > 0 then
        begin
          IsMatch := True;
        end;

        // Wrap Around: If nothing found before StartPos, reset and find the absolute LAST match
        if not IsMatch then
        begin
          if Regex.Exec(MemoText) then
          begin
            FoundPos := Regex.MatchPos[0];
            while Regex.ExecNext do
            begin
              FoundPos := Regex.MatchPos[0];
            end;
            if FoundPos > 0 then IsMatch := True;
          end;
        end;
      end;
    end;

  finally
    Regex.Free;
  end;

  end

  // 4. STRATEGY B: STANDARD SEARCH (PosEx / RPosEx ONLY)
  else
  begin
    if not backwards then
    begin
      FoundPos := PosEx(SearchText, MemoText, StartPos);
      if FoundPos = 0 then // Wrap around to top
        FoundPos := PosEx(SearchText, MemoText, 1);
    end
    else
    begin
      FoundPos := RPosEx(SearchText, MemoText, StartPos);
      if FoundPos = 0 then // Wrap around to bottom
        FoundPos := RPosEx(SearchText, MemoText, Length(MemoText));
    end;

    if FoundPos > 0 then IsMatch := True;
  end;

  // 5. Apply Results
  if IsMatch and (FoundPos > 0) then
  begin
    Pad.SelStart := FoundPos - 1;
    Pad.SelLength := WordLen;
    Pad.SetFocus;
  end
  else
  begin
    pop.Text := 'Text match "' + SPanel.SearchText + '" could not be located.';
    Pop.ShowAtPos(Form1.Left + (Form1.Width div 2) - 170, Form1.Top);
    Popt.Enabled := True;
  end;
end;

procedure TForm1.StatusBar1Click(Sender: TObject);
begin
end;

procedure TForm1.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  O:integer;
begin
  LFont.Caption:= StatusBar1.Panels.Items[Panel.Index].Text;

  if Panel.Index = 0 then
  begin
  LFont.Font.Assign(Pad.Font);
  O := LFont.Height;
  LFont.Font.Assign(Form1.Font);
  if O <= LFont.Height-0.1 then O := LFont.Height +4;
  StatusBar1.Height := O;
  end;

  if Panel.Index <= 1 then
    LFont.Font.Assign(Pad.Font)
  else LFont.Font.Assign(Form1.Font);

  StatusBar1.Canvas.Font.Assign(LFont.Font);
  StatusBar1.Canvas.Brush.Color := Form1.Color;
  StatusBar1.Canvas.FillRect(Rect);

  if Panel.Index <= 1 then
        StatusBar1.Canvas.TextRect(Rect, (Rect.Width-LFont.Width) div 2, (Rect.Height-LFont.Height) div 2, Panel.Text)
   else StatusBar1.Canvas.TextRect(Rect, (Rect.Width-LFont.Width) div 2, (Rect.Height-StatusBar1.Canvas.TextHeight(Panel.Text)) div 2, Panel.Text);
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
   if StatusBar1.GetPanelIndexAt(X, Y) = 3 then
   if Statusbar1.Panels[3].Text <> 'Unsaved File' then
   begin
  Clipboard.AsText := Statusbar1.Panels[3].Text;
  pop.Text:='File path copied to clipboard!';
  Pop.ShowAtPos(Form1.Left+(Form1.Width div 2)-170, Form1.Top);
  Popt.Enabled:=True;
     end
     else MOpen.OnClick(self);
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
  Pop.Color:=Form1.Color;
  Pop.TitleFont.Color:=Pad.Font.Color;
  Pop.TextFont.Color:=Pad.Font.Color;
end;

procedure TForm1.LoadTimerTimer(Sender: TObject);
begin
  LoadTimer.Enabled := False;
  WelcomePanel.Color:=Pad.Color;
  Label1.Font.Color := Pad.Font.Color;
  LFont.Font.Assign(Pad.Font);
  LFont.Caption:= StatusBar1.Panels.Items[0].Text;
  StatusBar1.Panels.Items[0].Width := LFont.Width +20;
  LFont.Caption:= StatusBar1.Panels.Items[1].Text;
  StatusBar1.Panels.Items[1].Width := LFont.Width +20;
  StatusBar1.Panels.Items[3].Width := Form1.Width - StatusBar1.Panels.Items[0].width - StatusBar1.Panels.Items[1].width - StatusBar1.Panels.Items[2].width - StatusBar1.Panels.Items[4].width - StatusBar1.Panels.Items[5].width - StatusBar1.Panels.Items[6].width - StatusBar1.Panels.Items[7].width - StatusBar1.Panels.Items[8].width -20;
  RefreshRecentFilesMenu;
  if StatusBar1.Panels.Items[3].Text <> 'Unsaved File' then AddRecentFile(StatusBar1.Panels.Items[3].Text);
  SPanel.Font.Color := clBlack;

    WelcomePanel.Left := Form1.Width div 2 -WelcomePanel.Width div 2;
  WelcomePanel.Top := Form1.Height div 2 -WelcomePanel.Height div 2;

  R:=0;
  G:=R;
  B:=R;
  if MDark.Checked then
  begin
  R:=35;
  G:=R;
  B:=R;
  end else
  if MLight.Checked then
  begin
   R:=255;
  G:=R;
  B:=R;
  end;
  WelcomePanel.BevelColor := RGBToColor(R,G,B);
  AnimTimer.Enabled := True;
end;

procedure TForm1.Poptimer(Sender: TObject);
begin
Popt.Enabled := false;
Pop.Hide;
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
       LFont.Font.Assign(Pad.Font);
          LFont.Caption:= Pad.Font.Name +Result;
          StatusBar1.Panels.Items[0].Width := LFont.Width +20;

  FrameStep := 0;
  CurrentScale := 1.0;
  CurrentAngle := 0.0;

  WelcomePanel.Left := Form1.Width div 2 -32;
  WelcomePanel.Top := Form1.Height div 2 -32;

  if Label1.Font.Size <> 16 then Label1.Font.Size:=16;


end;

procedure TForm1.MLightClick(Sender: TObject);
begin
  MDark.Checked := True;
  MLight.Checked := False;
  MRetro.Checked := False;
    MLight.Checked := True;
    MDark.Checked := False;
    Pad.Color := clWhite;
        Pad.Font.Color := clBlack;
        SPanel.Font.Color := clBlack;
    Form1.Color := RGBToColor(192,192,192);
    form1.Font.Color := clBlack;
      WelcomePanel.Color:=Pad.Color;
  Label1.Font.Color := Pad.Font.Color;
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
          LFont.Font.Assign(Pad.Font);
          //LFont.Font.Size:= Form1.Font.Size;
          LFont.Caption:= Pad.Font.Name +Result;
          StatusBar1.Panels.Items[0].Width := LFont.Width +20;
          LFont.Caption:= StatusBar1.Panels.Items[1].Text;
          StatusBar1.Panels.Items[1].Width := LFont.Width +20;
       end;
end;

procedure TForm1.AnimTimerTimer(Sender: TObject);
var

s : string;
begin
  if MLight.Checked then
  begin
  R:=R-6;
  G:=G-6;
  B:=B-6;
  end
  else if MDark.Checked then
  begin
  R:=R+5;
  G:=G+5;
  B:=B+5;
  end
  else if MRetro.Checked then
  begin
  R:=R+6;
  G:=G+6;
  B:=B+6;
  end;

  WelcomePanel.BevelColor := RGBToColor(R,G,B);

  Inc(FrameStep);
  s := Label1.Caption;
    //if (Length(s) > 0) and (s[Length(s)] = ' ') then
      //SetLength(s, Length(s) - 1);
    if s[3]=' ' then Delete(s, 1, 3)else if s[2]=' ' then Delete(s, 1, 2) else if s[1]=' ' then Delete(s, 1, 1);
    Label1.Caption := s;


  if FrameStep <= 30 then
  begin
    CurrentScale := 0.50 + (FrameStep / 20) * 3.20;
    CurrentAngle := (FrameStep / 20) * (3 * 2 * Pi);
    If FrameStep > 21 then
    begin
         WelcomePanel.Width := WelcomePanel.Width +(29-Framestep);
         WelcomePanel.Height := WelcomePanel.Height +(29-Framestep);
         Label1.Font.Orientation:= Label1.Font.Orientation +(29-Framestep*2);
    end
    else
    begin
         WelcomePanel.Width := WelcomePanel.Width +oi div 3;
         WelcomePanel.Height := WelcomePanel.Height +oi div 3;
         Label1.Font.Orientation:= Label1.Font.Orientation +6;
    end;
    WelcomePanel.Left := Form1.Width div 2 -WelcomePanel.Width div 2;
    WelcomePanel.Top := Form1.Height div 2 -WelcomePanel.Height div 2;
    LogoBox.Left := Panel1.Width div 2 - LogoBox.Width div 2;
    Image1.Left := Panel1.Width div 2 - Image1.Width div 2;
    inc(oi);
  end
  else if FrameStep <= 40 then
  begin
    Image1.Visible:=true;
    Image1.BringToFront;
    LogoBox.Visible:=false;
    CurrentScale := 3.0 - ((FrameStep - 20) / 20) * 3.0;
    CurrentAngle := (3 * 2 * Pi) - (((FrameStep - 10) / 20) * (3 * 2 * Pi));
    WelcomePanel.Top := Form1.Height div 2 -WelcomePanel.Height div 2;
    oi := 1;
  end
  else
  begin
    if WelcomePanel.Width >20 then
    begin
      AnimTimer.Interval:= 7;
      WelcomePanel.Width := WelcomePanel.Width -oi;
      WelcomePanel.Height := WelcomePanel.Height -oi;
      if Label1.Font.Size >1 then Label1.Font.Size := Label1.Font.Size -1 else Label1.Visible := false;
      if Label1.Visible = False then Image1.Align:= alClient;
      if Label1.Font.Size >1 then Image1.ImageWidth := Image1.ImageWidth -oi;
      WelcomePanel.Top := WelcomePanel.Top +oi+ +10;
      WelcomePanel.Left := WelcomePanel.Left +(oi*3)*7;
      inc(oi);
    end
    else
    begin
    AnimTimer.Enabled := False;
    WelcomePanel.Visible := False;
    IconBitmap.Free;
    oi := 1;
    Exit;
    end;
  end;
  LogoBox.Invalidate;
    s := Label1.Caption;
    if (Length(s) > 0) and (s[Length(s)] = ' ') then
      SetLength(s, Length(s) - 1);
    Label1.Caption := s;
end;

procedure TForm1.LogoBoxPaint(Sender: TObject);
var
  MidX, MidY: Integer;
begin
  MidX := LogoBox.Width div 2;
  MidY := LogoBox.Height div 2;
  if (IconBitmap <> nil) and (not IconBitmap.Empty) then
  RotateAndDraw(LogoBox.Canvas, MidX, MidY, IconBitmap, CurrentAngle, CurrentScale);

end;

procedure TForm1.MDarkClick(Sender: TObject);
begin
    MDark.Checked := True;
    MLight.Checked := False;
    MRetro.Checked := False;
    Pad.Color := RGBToColor(35,35,35);
    Pad.Font.Color := RGBToColor(192,192,192);
    Form1.Color := RGBToColor(35,35,35);
    form1.Font.Color := clWhite;
    SPanel.Font.Color := clBlack;
      WelcomePanel.Color:=Pad.Color;
  Label1.Font.Color := Pad.Font.Color;
end;

procedure TForm1.MFindClick(Sender: TObject);
begin
If SPanel.Visible = False then
   begin
   SPanel.Visible := True;
   SPanel.SetFocus;
   end
   else if SPanel.SearchText <> '' then SPanel.OnSearch(self,False, False);
end;

procedure TForm1.MRetroClick(Sender: TObject);
begin
    MRetro.Checked := True;
    MLight.Checked := False;
    MDark.Checked := False;
    Pad.Color := RGBToColor(0,0,0);
    Pad.Font.Color := RGBToColor(0,192,0);
    Form1.Color := RGBToColor(0,0,0);
    form1.Font.Color := clLime;
    SPanel.Font.Color := clBlack;
      WelcomePanel.Color:=Pad.Color;
  Label1.Font.Color := Pad.Font.Color;
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
                end;
            end
            else
            begin
             Pad.Lines.SaveToFile(StatusBar1.Panels.Items[3].Text);
             CanClose := True;
            end
       end
       else if Reply = mrCancel then
       begin
            CanClose := False;
       end
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
  LogoBox.Parent.DoubleBuffered := True;
  IconBitmap := TBitmap.Create;
  IconBitmap.Transparent := True;
  ImageList.GetBitmap(0, IconBitmap);
  LogoBox.Canvas.Draw(0, 0, IconBitmap);
  Pad.Align:= alClient;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  History.Free;
end;

end.

