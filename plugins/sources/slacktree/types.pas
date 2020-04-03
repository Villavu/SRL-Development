unit types;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
{$inline on}

interface

uses
  SysUtils, math;
  
type
  PPoint = ^TPoint;
  TPoint = packed record
    x,y: Int32;
  end;
  TPointArray   = array of TPoint;
  T2DPointArray = array of TPointArray;
  PPointArray = ^TPointArray;
  P2DPointArray = ^T2DPointArray;


  PBox = ^TBox;
  TBox = packed record
    x1,y1,x2,y2: Int32;
  private
    function GetWidth: Int32; inline;
    function GetHeight: Int32; inline;
  public
    property Width: Int32 read GetWidth;
    property Height: Int32 read GetHeight;
    function Center: TPoint; inline;
    procedure Expand(const SizeChange: Int32); inline;
    function Contains(pt:TPoint): Boolean; inline;
  end;
  TBoxArray   = array of TBox;
  T2DBoxArray = array of TBoxArray;
  PBoxArray   = ^TBoxArray;
  P2DBoxArray = ^T2DBoxArray;

  
  //--| 1D Array defs |------------------------------------------
  TBoolArray   = array of Boolean;
  TByteArray   = array of Byte;       TUInt8Array = array of Int8;
  TIntArray    = array of Int32;      TInt32Array = array of Int32;
  TInt64Array  = array of Int64;
  TFloatArray  = array of Single;
  TDoubleArray = array of Double;
  TExtArray    = array of Extended;
  
  TStringArray = array of String;
  TCharArray   = array of Char;
  
  
  //--| 2D Array defs |------------------------------------------
  T2DBoolArray   = array of TBoolArray;
  T2DByteArray   = array of TByteArray;
  T2DIntArray    = array of TIntArray;
  T2DInt64Array  = array of TInt64Array;
  T2DFloatArray  = array of TFloatArray;
  T2DDoubleArray = array of TDoubleArray;
  T2DExtArray    = array of TExtArray;


  //--| parameter passing |---------------------------------------
  PParamArray = ^TParamArray;
  TParamArray = array[Word] of Pointer;
  
  
  //--| Pointer defs |--------------------------------------------
  PFloat32 = ^Single;
  PFloat64 = ^Double;
  PFloat80 = ^Extended;
  PInt8  = ^Int8;
  PInt16 = ^Int16;
  PInt32 = ^Int32;
  PInt64 = ^Int64;
  PUInt8  = ^UInt8;
  PUInt16 = ^UInt16;
  PUInt32 = ^UInt32;
  PUInt64 = ^UInt64;
  PBoolean = ^Boolean;
  PByteBool = ^ByteBool;
  PWordBool = ^WordBool;
  PLongBool = ^LongBool;
  
  PIntArray = ^TIntArray;
  P2DIntArray = ^T2DIntArray;

  PByteArray = ^TByteArray;
  P2DByteArray = ^T2DByteArray;

  PBoolArray = ^TBoolArray;
  P2DBoolArray = ^T2DBoolArray;

  PExtArray = ^TExtArray;
  P2DExtArray = ^T2DExtArray;

  PDoubleArray = ^TDoubleArray;
  P2DDoubleArray = ^T2DDoubleArray;

  PFloatArray = ^TFloatArray;
  P2DFloatArray = ^T2DFloatArray;

  PStringArray = ^TStringArray;
  PCharArray   = ^TCharArray;


function ParamArray(arr:array of Pointer): TParamArray;

function Box(const x1,y1,x2,y2:Integer): TBox; inline;
function Point(const x,y:Integer): TPoint; inline;

operator = (left, right: TPoint): Boolean;
operator = (left, right: TBox): Boolean;

//-----------------------------------------------------------------------
implementation

function ParamArray(arr:Array of Pointer):TParamArray;
var i:Int32;
begin
  for i:=0 to High(arr) do Result[i] := arr[i];
end;

function TBox.GetWidth: Int32;
begin 
  Result := (X2-X1+1); 
end;

function TBox.GetHeight: Int32;
begin 
  Result := (Y2-Y1+1); 
end;

function TBox.Center: TPoint;
begin
  Result.X := Self.X1 + (GetWidth div 2);
  Result.Y := Self.Y1 + (GetHeight div 2);
end;

procedure TBox.Expand(const SizeChange: Int32);
begin
  Self.X1 := Self.X1 - SizeChange;
  Self.Y1 := Self.Y1 - SizeChange;
  Self.X2 := Self.X2 + SizeChange;
  Self.Y2 := Self.Y2 + SizeChange;
end;


function TBox.Contains(pt:TPoint): Boolean;
begin
  with self do
    Result := InRange(pt.x, x1, x2) and InRange(pt.y, y1, y2);
end;


function Box(const X1,Y1,X2,Y2:Int32): TBox;
begin
  Result.x1 := x1;
  Result.y1 := y1;
  Result.x2 := x2;
  Result.y2 := y2;
end;
    
  
function Point(const X, Y: Int32): TPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;  
 

operator = (Left, Right: TPoint): Boolean;
begin
  Result := (Left.x = Right.x) and (Left.y = Right.y);
end;

operator = (Left, Right: TBox): Boolean;
begin
  Result := (Left.x1 = Right.x1) and (Left.y1 = Right.y1) and
            (Left.x2 = Right.x2) and (Left.y2 = Right.y2);
end;


end.
