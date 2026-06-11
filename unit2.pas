unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Buttons,
  StdCtrls, ExtCtrls, RTTICtrls, DividerBevel, RxVersInfo, RxMDI, rxctrls,
  RxAutoPanel, kbuttons, ECEditBtns, uEButton, ATButtons, LCLIntf, EditBtn,
  TplButtonUnit, TplButtonExUnit, TplLabelUnit, Math, DateUtils;

const
  MAX_STARS = 300;

type
  TStar = record
    X, Y: Double;      // Absolute position relative to the center
    Z: Double;         // Distance/Depth from the viewer (closer = lower Z)
    Speed: Double;     // Personalized star speed multiplier
  end;

  { TForm2 }

  TForm2 = class(TForm)
    AutoPanel1: TAutoPanel;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    DividerBevel1: TDividerBevel;
    DividerBevel3: TDividerBevel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    RxVersionInfo1: TRxVersionInfo;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel1Paint(Sender: TObject);
    procedure Panel2Paint(Sender: TObject);
    procedure plButtonEx1Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    Stars: array[0..MAX_STARS - 1] of TStar;
    SwirlAngle: Double;
    FOriginalTop: Integer;
    FOriginalLeft: Integer; // Tracks the starting X coordinate
    FStartTime: TDateTime; // Marks the absolute startup timestamp
    FAngle: Double;
    FCurrentScale: Double; // Tracks shadow scaling factor
    FShadowBaseWidth: Integer;
    FShadowBaseHeight: Integer;
    FShadowCenterY: Integer;
    procedure InitStar(Index: Integer);
  public

  end;

var
  Form2: TForm2;

implementation
 uses
  Unit1;
{$R *.lfm}

{ TForm2 }

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
begin
   OpenURL('https://github.com/krapclap/Memopad');
end;

function TheBlend(FGColor, BGColor: TColor; Alpha: Byte): TColor;
var
  fR, fG, fB, bR, bG, bB: Byte;
  cFG, cBG: Longint;
begin
  cFG := ColorToRGB(FGColor);
  cBG := ColorToRGB(BGColor);

  fR := cFG and $FF;  fG := (cFG shr 8) and $FF;  fB := (cFG shr 16) and $FF;
  bR := cBG and $FF;  bG := (cBG shr 8) and $FF;  bB := (cBG shr 16) and $FF;

  Result := RGBToColor(
    bR + ((fR - bR) * Alpha) div 255,
    bG + ((fG - bG) * Alpha) div 255,
    bB + ((fB - bB) * Alpha) div 255
  );
end;

procedure TForm2.InitStar(Index: Integer);
begin

  Stars[Index].X := Random(1000) - 500;
  Stars[Index].Y := Random(1000) - 500;
  Stars[Index].Z := Random(200) + 300;
  Stars[Index].Speed := 5.0 + Random;
end;

procedure TForm2.FormCreate(Sender: TObject);
  var
  i: Integer;
begin
  Randomize;
     SwirlAngle := 0.0;
  Panel1.DoubleBuffered := True;

  for i := 0 to MAX_STARS - 1 do
  begin
    InitStar(i);
    Stars[i].Z := Random(500) + 1;
  end;
  Self.DoubleBuffered := True;

  FOriginalTop := Image1.Top;
  FOriginalLeft := Image1.Left; // Save starting horizontal position
  FAngle := 0.0;
  FStartTime := Now;
  FCurrentScale := 1.0;
  Self.DoubleBuffered := True;
  Panel2.DoubleBuffered := True;
  FShadowBaseWidth := 28;
  FShadowBaseHeight := 5;

  Timer2.Interval := 16;
  Timer2.Enabled := True;
  FShadowCenterY := Image1.Top + Image1.Height + 20;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Label1.Top := Form2.Height;
  Label1.Left := Panel1.Width div 2 - Label1.Width div 2;
end;

procedure TForm2.Panel1Click(Sender: TObject);
begin

end;

procedure TForm2.Panel1Paint(Sender: TObject);
  var
  i: Integer;
  CenterX, CenterY: Integer;
  ScreenX, ScreenY: Integer;
  PrevX, PrevY: Integer;
  Size: Integer;
  RotX, RotY: Double;
  PrevRotX, PrevRotY: Double;
  CurrentAngle: Double;
begin
  CenterX := Panel1.Width div 2;
  CenterY := Panel1.Height div 2;

  with Panel1.Canvas do
  begin
    Brush.Color := clBlack;
    FillRect(ClipRect);

    Pen.Color := clWhite;
    Brush.Color := clWhite;

    for i := 0 to MAX_STARS - 1 do
    begin

      CurrentAngle := SwirlAngle + (-100 / Stars[i].Z);
      RotX := Stars[i].X * Cos(CurrentAngle) - Stars[i].Y * Sin(CurrentAngle);
      RotY := Stars[i].X * Sin(CurrentAngle) + Stars[i].Y * Cos(CurrentAngle);
      ScreenX := Round((RotX / Stars[i].Z) * CenterX) + CenterX;
      ScreenY := Round((RotY / Stars[i].Z) * CenterY) + CenterY;

      if (ScreenX >= 0) and (ScreenX < Panel1.Width) and
         (ScreenY >= 0) and (ScreenY < Panel1.Height) then
      begin
        PrevRotX := Stars[i].X * Cos(CurrentAngle - 0.02) - Stars[i].Y * Sin(CurrentAngle - 0.02);
        PrevRotY := Stars[i].X * Sin(CurrentAngle - 0.02) + Stars[i].Y * Cos(CurrentAngle - 0.02);
        PrevX := Round((PrevRotX / (Stars[i].Z + Stars[i].Speed * 1.5)) * CenterX) + CenterX;
        PrevY := Round((PrevRotY / (Stars[i].Z + Stars[i].Speed * 1.5)) * CenterY) + CenterY;
        Size := Round(3 - (Stars[i].Z / 200));
        if Size < 1 then Size := 1;
        Pen.Width := Size;
        MoveTo(PrevX, PrevY);
        LineTo(ScreenX, ScreenY);
      end
      else
      begin
        InitStar(i);
      end;
    end;
  end;
end;

procedure TForm2.Panel2Paint(Sender: TObject);
  var
  x, y: Integer;
  cx, cy: Integer;
  w, h: Integer;
  StartX, EndX, StartY, EndY: Integer;
  CurrentDistance: Integer;
  DistanceRatio: Double;
begin
  // 1. Core Position Locking
  cx := Image1.Left + (Image1.Width div 2);
  cy := FShadowCenterY;

  // 2. FORCED SIZE CALCULATION:
  // Calculate exactly how far the image currently is from its resting point.
  CurrentDistance := Image1.Top - FOriginalTop;

  // Map the distance to a sizing percentage scale ratio.
  // When the object moves DOWN (CurrentDistance is positive), the scale grows.
  // When the object moves UP (CurrentDistance is negative), the scale shrinks.
  DistanceRatio := 1.0 + (CurrentDistance / 35.0);

  // Compute final real-time pixel size boundaries
  w := Round(FShadowBaseWidth * DistanceRatio);
  h := Round(FShadowBaseHeight * DistanceRatio);

  // Safety checks to prevent canvas exceptions
  if (w < 4) or (h < 4) then Exit;

  // 3. Grid Coordinates Allocation
  StartX := cx - (w div 2);
  EndX := cx + (w div 2);
  StartY := cy - (h div 2);
  EndY := cy + (h div 2);

  // 4. Alternating Checkerboard Render
  for y := StartY to EndY - 1 do
  begin
    for x := StartX to EndX - 1 do
    begin
      if (x + y) mod 2 = 0 then
      begin
        Panel2.Canvas.Pixels[x, y] := Form1.Pad.Font.Color;
      end;
    end;
  end;
end;

procedure TForm2.plButtonEx1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.StaticText1Click(Sender: TObject);
begin

end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Label1.Top := Label1.Top -1;
  if Label1.Top = 0 -Label1.Height then Label1.Top := Form2.Height;
  Panel2.Color:= Form1.Color;
  BitBtn1.Color:= Form1.Color;
  BitBtn2.Color:= Form1.Color;
  Label2.Font.Color := Form1.Pad.font.Color;
  BitBtn1.Font.Color := Form1.Pad.font.Color;
  BitBtn2.Font.Color := Form1.Pad.font.Color;
end;

procedure TForm2.Timer2Timer(Sender: TObject);
const
  FloatRange = 22;     // Vertical movement amplitude (pixels)
  SwayRange  = 35;      // Slight horizontal movement amplitude (pixels)
  FloatSpeed = 0.04;   // General speed of the animation
  SwaySpeed  = 1.0;    // Slower radians per second for side-to-side sway
  var
  ElapsedSeconds: Double;
  i: Integer;
  begin
 //
    SwirlAngle := SwirlAngle + 0.01;
      if SwirlAngle > (2 * Pi) then SwirlAngle := SwirlAngle - (2 * Pi);

      for i := 0 to MAX_STARS - 1 do
      begin
        Stars[i].Z := Stars[i].Z - Stars[i].Speed;

        if Stars[i].Z <= 0 then
        begin
          InitStar(i);
        end;
      end;

      Panel1.Invalidate;
 //
   ElapsedSeconds := MilliSecondsBetween(Now, FStartTime) / 1000.0;
   FAngle := FAngle + FloatSpeed;
  if FAngle > (2 * Pi) then
    FAngle := FAngle - (2 * Pi);
  Image1.Top := FOriginalTop + Round(Sin(FAngle) * FloatRange);
    Image1.Left := FOriginalLeft + Round(Sin(ElapsedSeconds * SwaySpeed) * SwayRange);
 //
 Panel2.Repaint;
  end;

end.

