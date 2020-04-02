library slacktree;
{==============================================================================]
  Copyright (c) 2016, Jarl `slacky` Holta
  Project: SlackTree
  License: GNU Lesser GPL (http://www.gnu.org/licenses/lgpl.html)
[==============================================================================}

{$mode objfpc}{$H+}
{$inline on}

uses
  SysUtils,
  tree, types;

{$I simbaplugin.inc}

procedure TSlackTree_Init(const Params: PParamArray); cdecl;
begin
  PSlackTree(Params^[0])^.Init(PPointArray(Params^[1])^);
end;

procedure TSlackTree_Free(const Params: PParamArray); cdecl;
begin
  PSlackTree(Params^[0])^.Free();
end;

procedure TSlackTree_IndexOf(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PInt32(Result)^ := PSlackTree(Params^[0])^.IndexOf(PPoint(Params^[1])^);
end;

procedure TSlackTree_Find(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointer(Result)^ := PSlackTree(Params^[0])^.Find(PPoint(Params^[1])^);
end;

procedure TSlackTree_HideNode(const Params: PParamArray); cdecl;
begin
  PSlackTree(Params^[0])^.HideNode(PInt32(Params^[1])^);
end;

procedure TSlackTree_HideNode2(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PBoolean(Result)^ := PSlackTree(Params^[0])^.HideNode(PPoint(Params^[1])^);
end;

procedure TSlackTree_RawNearest(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointer(Result)^ := PSlackTree(Params^[0])^.RawNearest(PPoint(Params^[1])^, PBoolean(Params^[2])^);
end;

procedure TSlackTree_Nearest(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPoint(Result)^ := PSlackTree(Params^[0])^.Nearest(PPoint(Params^[1])^, PBoolean(Params^[2])^);
end;

procedure TSlackTree_RawKNearest(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  TNodeRefArray(Result^) := PSlackTree(Params^[0])^.RawKNearest(PPoint(Params^[1])^, PInt32(Params^[2])^, PBoolean(Params^[3])^);
end;

procedure TSlackTree_KNearest(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointArray(Result)^ := PSlackTree(Params^[0])^.KNearest(PPoint(Params^[1])^, PInt32(Params^[2])^, PBoolean(Params^[3])^);
end;

procedure TSlackTree_RawRangeQuery(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  TNodeRefArray(Result^) := PSlackTree(Params^[0])^.RawRangeQuery(PBox(Params^[1])^);
end;

procedure TSlackTree_RangeQuery(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointArray(Result)^ := PSlackTree(Params^[0])^.RangeQuery(PBox(Params^[1])^, PBoolean(Params^[2])^);
end;

procedure TSlackTree_RangeQueryEx(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointArray(Result)^ := PSlackTree(Params^[0])^.RangeQueryEx(PPoint(Params^[1])^, PDouble(Params^[2])^, PDouble(Params^[3])^, PBoolean(Params^[4])^);
end;

procedure TSlackTree_RangeQueryEx2(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PPointArray(Result)^ := PSlackTree(Params^[0])^.RangeQueryEx(PPoint(Params^[1])^, PDouble(Params^[2])^, PDouble(Params^[3])^, PDouble(Params^[4])^, PDouble(Params^[5])^, PBoolean(Params^[6])^);
end;

procedure TSlackTree_RefArray(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  TNodeRefArray(Result^) := PSlackTree(Params^[0])^.RefArray;
end;

begin
  addGlobalType('packed record split: TPoint; l,r: Int32; hidden: Boolean; end;', 'TSlackNode');
  addGlobalType('^TSlackNode', 'PSlackNode');
  addGlobalType('array of TSlackNode;', 'TSlackArray');
  addGlobalType('array of PSlackNode;', 'TSlackRefArray');
  addGlobalType('packed record Data: TSlackArray; Size: Int32; end;', 'TSlackTree');

  addGlobalFunc('procedure TSlackTree.Init(TPA:TPointArray); native;', @TSlackTree_Init);
  addGlobalFunc('procedure TSlackTree.Free(); native;', @TSlackTree_Free);
  addGlobalFunc('function TSlackTree.IndexOf(pt:TPoint): Int32; native;', @TSlackTree_IndexOf);
  addGlobalFunc('function TSlackTree.Find(pt:TPoint): PSlackNode; native;', @TSlackTree_Find);
  addGlobalFunc('procedure TSlackTree.Hide(idx:Int32); native;', @TSlackTree_HideNode);
  addGlobalFunc('function TSlackTree.Hide(pt:TPoint): LongBool; overload; native;', @TSlackTree_HideNode2);
  addGlobalFunc('function TSlackTree.Nearest_N(pt:TPoint; notEqual:LongBool=False): PSlackNode; native;', @TSlackTree_RawNearest);
  addGlobalFunc('function TSlackTree.Nearest(pt:TPoint; notEqual:LongBool=False): TPoint; native;', @TSlackTree_Nearest);
  addGlobalFunc('function TSlackTree.RawKNearest(pt:TPoint; k:Int32; notEqual:LongBool=False): TSlackRefArray; native;', @TSlackTree_RawKNearest);
  addGlobalFunc('function TSlackTree.KNearest(pt:TPoint; k:Int32; notEqual:LongBool=False): TPointArray; native;', @TSlackTree_KNearest);
  addGlobalFunc('function TSlackTree.RawRangeQuery(B:TBox): TSlackRefArray; native;', @TSlackTree_RawRangeQuery);
  addGlobalFunc('function TSlackTree.RangeQuery(B:TBox; hide:LongBool=False): TPointArray; native;', @TSlackTree_RangeQuery);
  addGlobalFunc('function TSlackTree.RangeQueryEx(query:TPoint; xRad,yRad:Double; hide:LongBool=False): TPointArray; overload; native;', @TSlackTree_RangeQueryEx);
  addGlobalFunc('function TSlackTree.RangeQueryEx(query:TPoint; xmin,ymin,xmax,ymax:double; hide:LongBool=False): TPointArray; overload; native;', @TSlackTree_RangeQueryEx2);
  addGlobalFunc('function TSlackTree.RefArray: TSlackRefArray; native;', @TSlackTree_RefArray);
end.
