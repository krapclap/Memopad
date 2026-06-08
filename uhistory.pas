unit uHistory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Forms, lazUTF8, ClipBrd;

type


  { TStep }

  TStep = class

  private

    FPrev      : TStep;
    FNext      : TStep;
    FSelStart  : SizeInt;
    FSelLength : SizeInt;
    FSelText   : String;
    FHalf      : Integer;

  public

    constructor Create(SelStart: SizeInt; SelLength: SizeInt; SelText: String;
      Half: Integer = 0; Prev: TStep=nil; Next: TStep=nil);
    destructor  Destroy(); override;

  end;


  { TSteps }

  TSteps = class

  private

    FHead     : TStep;
    FCurrent  : TStep;

    FSize     : SizeInt;
    FMaxSize  : SizeInt;

    FIndex    : Integer;

    FCount    : Integer;
    FMinCount : Integer;

    FDelimiters    : set of Char;
    FMaxWordLen    : Integer;
    FNewStep       : Boolean;

    procedure Add(SelStart: SizeInt; SelLength: SizeInt; SelText: string; Half: Boolean);
    procedure Limit;

  public

    constructor Create(MaxSize: SizeInt=0; MinCount: Integer=0);
    destructor  Destroy; override;

    procedure Prev;
    procedure Next;
    procedure Reset;

    property  Size  : SizeInt read FSize;
    property  Index : Integer read FIndex;
    property  Count : Integer read FCount;

  end;



  { THistory }

  THistory = class

  private

    FMemo               : TMemo;
    FSteps              : TSteps;

    FOldOnChange        : TNotifyEvent;
    FOldApplicationIdle : TIdleEvent;

    FPrevContent        : String;
    // FPrevSelStart       : SizeInt;
    FHalf               : Boolean;
    FInEdit             : Boolean;
    FixOnChangeBug      : Boolean;
    FAutoSelStart       : SizeInt;

    procedure MemoOnChange(Sender: TObject);
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);

    function  GetSize: SizeInt;
    function  GetIndex: Integer;
    function  GetCount: Integer;

  public

    constructor Create(Memo: TMemo; Delimiters: String = ''; MaxWordLen: Integer = 32;
      MaxSize: SizeInt = 0; MinCount: Integer = 0);
    destructor  Destroy; override;

    function CanRedo: Boolean;
    function CanUndo: Boolean;

    procedure Undo(AutoSelect: Boolean = False);
    procedure Redo(AutoSelect: Boolean = False);

    procedure Reset;

    procedure PasteText;

    property Size : SizeInt read GetSize;
    property Index: Integer read GetIndex;
    property Count: Integer read GetCount;

  end;


implementation

{ TStep }

constructor TStep.Create(SelStart: SizeInt; SelLength: SizeInt; SelText: String;
  Half: Integer = 0; Prev: TStep = nil; Next: TStep = nil);
begin
  Self.FSelStart  := SelStart;
  Self.FSelLength := SelLength;
  Self.FSelText   := SelText;

  Self.FHalf      := Half;

  Self.FPrev      := Prev;
  Self.FNext      := Next;
end;


destructor TStep.Destroy();
begin
  if Self.FPrev <> nil then
    Self.FPrev.FNext := nil;

  if Self.FNext <> nil then
    Self.FNext.Free;
end;



constructor TSteps.Create(MaxSize: SizeInt = 0; MinCount: Integer = 0);
begin
  FHead     := TStep.Create(0, 0, '');
  FCurrent  := FHead;

  FSize     := 0;
  FMaxSize  := MaxSize;

  FIndex    := 0;

  FCount    := 0;
  FMinCount := MinCount;

  FDelimiters := [];
  FMaxWordLen := 1;
  FNewStep    := True;
end;


destructor TSteps.Destroy;
begin
  FHead.Free;
  inherited Destroy;
end;


procedure TSteps.Prev;
begin
  if FCurrent <> FHead then
    FCurrent := FCurrent.FPrev;
  Dec(FIndex);
  FNewStep := True;
end;


procedure TSteps.Next;
begin
  if FCurrent.FNext <> nil then
    FCurrent := FCurrent.FNext;
  Inc(FIndex);
  FNewStep := True;
end;


procedure TSteps.Reset;
begin
  if FHead.FNext <> nil then begin
    FHead.FNext.Free;
    FHead.FNext := nil;

    FCurrent := FHead;

    FSize  := 0;
    FIndex := 0;
    FCount := 0;

    FNewStep := True;
  end;
end;


procedure TSteps.Add(SelStart: SizeInt; SelLength: SizeInt; SelText: string; Half: Boolean);

  procedure DoAdd();
  begin
    if FCurrent.FNext <> nil then begin
      FCurrent.FNext.Free;
      FCount := FIndex;
    end;
    if Half and (FCurrent <> FHead) then
      FCurrent.FHalf := 1;
    FCurrent.FNext := TStep.Create(SelStart, SelLength, SelText, 0, FCurrent);
    FCurrent := FCurrent.FNext;

    if Half then
      FCurrent.FHalf := 2
    else
      FCurrent.FHalf := 0;

    Inc(FSize, Sizeof(TStep) + Length(SelText));
    Inc(FIndex);
    Inc(FCount);

    Limit;

    FNewStep := False;
  end;

begin
  if (FDelimiters = []) or (Length(SelText) > 1) or
  FNewStep or (FCurrent.FSelLength >= FMaxWordLen) or
  (FCurrent.FSelStart > 0) and (SelStart < 0) or
  (FCurrent.FSelStart < 0) and (SelStart > 0) or
  (SelText[1] in FDelimiters) then
    DoAdd

  else begin
    Inc(FCurrent.FSelLength);
    if FCurrent.FSelStart < 0 then begin
      Inc(FCurrent.FSelStart);
      FCurrent.FSelText := SelText + FCurrent.FSelText;
    end else begin
      FCurrent.FSelText := FCurrent.FSelText + SelText;
    end;
  end;

end;


procedure TSteps.Limit;
var
  First: TStep;
begin
  while (FMaxSize > 0) and (FSize > FMaxSize) and (FCount > FMinCount) do begin
    First := FHead.FNext;
    FSize := FSize - Sizeof(TStep) - Length(First.FSelText);
    FHead.FNext := First.FNext;

    First.FNext := nil;
    First.Free;

    Dec(FIndex);
    Dec(FCount);
  end;
end;

function UTF8PosToBytePos(const Text: PChar; const Size: SizeInt; UPos: SizeInt): SizeInt;
begin
  Result := 0;
  if UPos <= 0 then Exit;

  while (UPos > 1) and (Result < Size) do begin
    case Text[Result] of
      #192..#223: Inc(Result, 2);
      #224..#239: Inc(Result, 3);
      #240..#247: Inc(Result, 4);
      else Inc(Result);
    end;
    Dec(UPos);
  end;

  Inc(Result);
end;

function UTF8PosToBytePos(const Text: String; const UPos: SizeInt): SizeInt; inline;
begin
  Result := UTF8PosToBytePos(PChar(Text), Length(Text), UPos);
end;

constructor THistory.Create(Memo: TMemo; Delimiters: String = '';
  MaxWordLen: Integer = 32; MaxSize: SizeInt = 0; MinCount: Integer = 0);
var
  C: Char;
begin
  FMemo          := Memo;
  FSteps         := TSteps.Create(MaxSize, MinCount);

  with FSteps do begin
    for C in Delimiters do
      Include(FDelimiters, C);

    FMaxWordLen := MaxWordLen;
  end;

  FOldOnChange   := FMemo.OnChange;
  FMemo.OnChange := @MemoOnChange;

  FOldApplicationIdle := Application.OnIdle;
  Application.OnIdle  := @ApplicationIdle;

  FPrevContent   := FMemo.Text;
  // FPrevSelStart  := FMemo.SelStart;

  FHalf          := False;
  FInEdit        := True;
  FixOnChangeBug := False;

  FAutoSelStart  := 0;
end;


destructor THistory.Destroy;
begin
  FMemo.OnChange     := FOldOnChange;
  Application.OnIdle := FOldApplicationIdle;
  inherited Destroy;
end;


function THistory.GetSize: SizeInt;
begin
  Result := FSteps.FSize;
end;


function THistory.GetIndex: Integer;
begin
  Result := FSteps.FIndex;
end;


function THistory.GetCount: Integer;
begin
  Result := FSteps.FCount;
end;


procedure THistory.MemoOnChange(Sender: TObject);
var
  Content      : String;
  Len          : SizeInt;
  ByteSelStart : SizeInt;
  SelStart  : SizeInt;
  SelLength : SizeInt;
  SelText   : String;


  procedure HardCalc();
  var
    A, B, E: PChar;
  begin
    A := PChar(Content);
    B := PChar(FPrevContent);
    if Len < 0 then
      E := A + Length(Content)
    else
      E := A + Length(FPrevContent);
    while A < E do begin
      if A^ <> B^ then Break;
      Inc(A);
      Inc(B);
    end;

    while A > PChar(Content) do
      if A^ in [#0..#127, #192..#247] then
        Break
      else
        Dec(A);

    ByteSelStart := A - PChar(Content) + 1;
    SelStart     := UTF8LengthFast(PChar(Content), ByteSelStart);
    SelLength    := UTF8LengthFast(PChar(Content) + ByteSelStart, Len);
  end;


begin

  if FInEdit then begin

    Content      := FMemo.Text;
    Len          := Length(Content) - Length(FPrevContent);
    ByteSelStart := UTF8PosToBytePos(Content, FMemo.SelStart + 1);

    if Len > 0 then begin

      HardCalc();

      SelText  := Copy(Content, ByteSelStart, Len);

    end

    else if Len < 0 then begin
      Len := -Len;
      SelLength := UTF8LengthFast(PChar(FPrevContent) + ByteSelStart, Len);
      SelStart  := -(FMemo.SelStart + 1);
      SelText   := Copy(FPrevContent, ByteSelStart, Len);
    end

    else
      Exit;

    FSteps.Add(SelStart, SelLength, SelText, FHalf);

    FPrevContent := Content;
    FHalf := True;

  end;

  FixOnChangeBug := False;

  if Assigned(FOldOnChange) then
    FOldOnChange(Sender);
end;


procedure THistory.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin

  FHalf := False;

  if Assigned(FOldApplicationIdle) then
    FOldApplicationIdle(Sender, Done);
end;


function THistory.CanUndo: Boolean; inline;
begin
  Result := FSteps.FIndex > 0;
end;


function THistory.CanRedo: Boolean; inline;
begin
  Result := FSteps.FIndex < FSteps.Count;
end;


procedure THistory.Undo(AutoSelect: Boolean = False);
var
  Half      : Integer;
  SelStart  : SizeInt;
  SelLength : SizeInt;
begin
  if FSteps.FIndex <= 0 then
    Exit;

  FInEdit := False;
  FixOnChangeBug := True;

  with FSteps.FCurrent do begin

    Half      := FHalf;
    SelStart  := FSelStart;
    SelLength := FSelLength;

    if FSelStart > 0 then begin
      FMemo.SelStart  := FSelStart - 1;
      FMemo.SelLength := FSelLength;
      FMemo.SelText   := '';
    end

    else begin
      FAutoSelStart := -FSelStart;
      FMemo.SelStart  := FAutoSelStart - 1;
      FMemo.SelLength := 0;
      FMemo.SelText   := FSelText;
    end;

  end;

  FSteps.Prev;

  FPrevContent := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;


  if Half = 2 then
    Undo(AutoSelect);

  if AutoSelect then begin

    if (SelStart < 0) then begin
      FMemo.SelStart := FAutoSelStart - 1;
      FMemo.SelLength := SelLength;
    end

    else if (Half = 1) and (SelStart <= FAutoSelStart) then
      FAutoSelStart := FAutoSelStart - SelLength;

  end;

end;


procedure THistory.Redo(AutoSelect: Boolean);
var
  Half      : Integer;
  SelStart  : SizeInt;
  SelLength : SizeInt;
begin
  if FSteps.FIndex > FSteps.Count then
    Exit;

  FInEdit := False;

  FixOnChangeBug := True;

  FSteps.Next;

  with FSteps.FCurrent do begin

    Half      := FHalf;
    SelStart  := FSelStart;
    SelLength := FSelLength;

    if SelStart > 0 then begin
      FAutoSelStart   := FSelStart;
      FMemo.SelStart  := FSelStart - 1;
      FMemo.SelLength := 0;
      FMemo.SelText   := FSelText;
    end

    else begin
      FMemo.SelStart  := -FSelStart - 1;
      FMemo.SelLength := FSelLength;
      FMemo.SelText   := '';
    end;
  end;

  FPrevContent := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;

  if Half = 1 then
    Redo(AutoSelect);

  if AutoSelect then begin

    if (SelStart > 0) then begin
      FMemo.SelStart := FAutoSelStart - 1;
      FMemo.SelLength := SelLength;
    end

    else if (Half = 2) and (-SelStart <= FAutoSelStart) then
      FAutoSelStart := FAutoSelStart - SelLength;

  end;

end;


procedure THistory.PasteText;
var
  ClipBoardText: string;
begin
  ClipBoardText := ClipBoard.AsText;
  if ClipBoardText = '' then Exit;

  if FMemo.SelLength > 0 then begin
    FSteps.Add(-(FMemo.SelStart+1), FMemo.SelLength, FMemo.SelText, False);
    FSteps.Add(FMemo.SelStart + 1, UTF8LengthFast(ClipBoardText), ClipBoardText, True);
  end else
    FSteps.Add(FMemo.SelStart + 1, UTF8LengthFast(ClipBoardText), ClipBoardText, False);

  FInEdit := False;
  FixOnChangeBug := True;

  FMemo.SelText := ClipBoardText;
  FPrevContent  := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;
end;


procedure THistory.Reset; inline;
begin
  FSteps.Reset;
end;

end.

