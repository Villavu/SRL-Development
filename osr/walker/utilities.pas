type
  TRSWUtils = record
    MapFilters: set of (mfDots, mfSymbols);
  end;
  
  TWebGraph = record
    Nodes: TPointArray;
    Paths: T2DIntArray;
    Names: TStringArray;
    Blocking: TIntegerArray;
  end;
  
var
  MM_AREA: TBox := [570,12,714,156];//[570,9,714,159];
  MM_CROP: TBox := [0,0,MM_AREA.X2-MM_AREA.X1,MM_AREA.Y2-MM_AREA.Y1];
  MM_RAD: Int32 := 64;
  
  SLICE_WIDTH  = 768;
  SLICE_HEIGHT = 768;
  SLICE_FMT    = '[%d_%d].png';
  
  RSWUtils: TRSWUtils := [[mfDots, mfSymbols]];

  
  

function TRSWUtils.InPoly(p:TPoint; const Poly:TPointArray): Boolean; static;
var j,i,H: Int32;
begin
  H := High(poly);
  j := H;
  Result := False;
  for i:=0 to H do begin
    if ((poly[i].y < p.y) and (poly[j].y >= p.y) or (poly[j].y < p.y) and (poly[i].y >= p.y)) then
      if (poly[i].x+(p.y-poly[i].y) / (poly[j].y-poly[i].y) * (poly[j].x-poly[i].x) < p.x) then
        Result := not(Result);
    j := i;
  end;
end;

function TRSWUtils.DistToLine(Pt, sA, sB: TPoint): Double; static;
var
  dx,dy,d:Int32;
  f: Single;
  qt:TPoint;
begin
  dx := sB.x - sA.x;
  dy := sB.y - sA.y;
  d := dx*dx + dy*dy;
  if (d = 0) then Exit(Hypot(pt.x-sA.x, pt.y-sA.y));
  f := ((pt.x - sA.x) * (dx) + (pt.y - sA.y) * (dy)) / d;
  if (f < 0) then Exit(Hypot(pt.x-sA.x, pt.y-sA.y));
  if (f > 1) then Exit(Hypot(pt.x-sB.x, pt.y-sB.y));
  qt.x := Round(sA.x + f * dx);
  qt.y := Round(sA.y + f * dy);
  Result := Hypot(pt.x-qt.x, pt.y-qt.y);
end;

function TRSWUtils.LinesIntersect(p,q:array[0..1] of TPoint; out i:TPoint): Boolean; static;
var
  dx,dy,d: TPoint;
  dt,s,t: Double;
  function Det(a,b: TPoint): Int64; begin Result := a.x*b.y - a.y*b.x; end;
begin
  dx := [p[0].x - p[1].x, q[0].x - q[1].x];
  dy := [p[0].y - p[1].y, q[0].y - q[1].y];
  dt := det(dx, dy);
  if dt = 0 then Exit(False);
  d := [Det(p[0],p[1]), Det(q[0],q[1])];
  i.x := Round(Det(d, dx) / dt);
  i.y := Round(Det(d, dy) / dt);
  s := (dx.x * (q[0].y-p[0].y) + dy.x * (p[0].x-q[0].x)) / dt;
  t := (dx.y * (p[0].y-q[0].y) + dy.y * (q[0].x-p[0].x)) / (-dt);
  Result := (s > 0) and (s < 1) and (t > 0) and (t < 1);
end;

function TRSWUtils.PathLength(Path: TPointArray): Double; static;
var j,i,H: Int32;
begin
  for i:=0 to High(path)-1 do begin
    Result += Hypot(path[i].x-path[i+1].x, path[i].y-path[i+1].y);
  end;
end;

function TRSWUtils.BuildPath(TPA: TPointArray; minStep,maxStep:Int32): TPointArray; static; overload;
var
  i,j,l: Int32;
  tmp: TPointArray;
begin
  for i:=1 to High(TPA) do
  begin
    tmp := TPAFromLine(TPA[i-1].x,TPA[i-1].y, TPA[i].x,TPA[i].y);
    j := 0;
    while j < High(tmp) do
    begin
      Result += tmp[j];
      Inc(j, Random(minStep, maxStep));
    end;
  end;
  Result += TPA[High(TPA)];
end;

function TRSWUtils.MinBoxInRotated(B: TBox; Angle: Double): TBox; static;
var
  sinA,cosA,ss,ls,wr,hr: Double;
  W,H: Int32;
begin
  W := B.x2-B.x1+1;
  H := B.y2-B.y1+1;
  ls := W;
  ss := H;
  if w < h then Swap(ls,ss);

  sinA := Abs(Sin(Angle));
  cosA := Abs(Cos(Angle));
  if (ss <= 2.0*sinA*cosA*ls) or (abs(sinA-cosA) < 0.00001) then
  begin
    wr := (0.5*ss)/sinA;
    hr := (0.5*ss)/cosA;
    if (w < h) then Swap(wr,hr);
  end else
  begin
    wr := (W*cosA - H*sinA) / (Sqr(cosA) - Sqr(sinA));
    hr := (H*cosA - W*sinA) / (Sqr(cosA) - Sqr(sinA));
  end;

  with B.Middle() do
  begin
    Result := [Trunc(X-wr/2), Trunc(Y-hr/2), Ceil(X+wr/2), Ceil(Y+hr/2)];
    Result.LimitTo(B);
  end;
end;

function TRSWUtils.ClearDotsHeuristc(BMP: TMufasaBitmap; DoFree:Boolean; PTS: TPointArray): TMufasaBitmap; static;
var
  search: TPointArray;
  i,w,h,color: Int32;
  p,q: TPoint;
  isYellow, isRed, isWhite, isBlack: Boolean;
begin
  w :=  bmp.getWidth;
  h :=  bmp.getHeight;
  Result := bmp.Copy();
  client.getMBitmaps.AddBMP(Result);

  search := TPAFromBox(Box(0,0,20,20));
  search.Sort([10,10]);

  for p in PTS do
  begin
    p.x -= MM_AREA.x1;
    p.y -= MM_AREA.y1;
    for i:=0 to High(search) do
    begin
      q := search[i] + p - Point(10,10);
      if not((q.x > 0) and (q.y > 0) and (q.x < w) and (q.y < h)) then
        continue;

      SetColorToleranceSpeed(2);
      SetToleranceSpeed2Modifiers(0.05,0.05);
      isWhite := SimilarColors($FFFFFF, BMP.GetPixel(q.x,q.y), 30);

      SetToleranceSpeed2Modifiers(0.05,1);
      isYellow := SimilarColors($00FFFF, BMP.GetPixel(q.x,q.y), 30);
      isRed    := SimilarColors($0000FF, BMP.GetPixel(q.x,q.y), 30);
      isBlack  := BMP.GetPixel(q.x,q.y) = 65536;

      if (not isWhite) and  (not isYellow) and (not isRed) and (not isBlack) then
      begin
        Result.DrawClippedBox(Box(p.x,p.y,p.x+4,p.y+4), True, BMP.GetPixel(q.x,q.y));
        break;
      end;
    end;
  end;

  if DoFree then
    BMP.Free();

  SetColorToleranceSpeed(1);
  SetToleranceSpeed2Modifiers(0.2,0.2);
end;

procedure TRSWUtils.ClearSymbols(bmp: TMufasaBitmap); static;
var
  circle7,circle8,tmp,blacks: TPointArray;
  colors: TIntegerArray;
  p,q: TPoint;
  c,w,h: Int32;
begin
  circle7 := TPAFromCircle(7,0, 7);
  circle8 := TPAFromCircle(7,0, 8);
  bmp.FindColors(blacks, 65536);
  w := bmp.getWidth;
  h := bmp.getHeight;

  for q in blacks do
  begin
    c := 0;
    for p in circle7 do
    begin
      p += q;
      if PointInTPA(p, blacks) then Inc(c);
    end;

    if c > Length(circle7)*0.8 then
    begin
      tmp := circle8.OffsetFunc(q).FilterBox(Box(0,0,w-1,h-1));
      colors := bmp.GetPixels(tmp);
      bmp.DrawClippedBox(Box(q.x,q.y-7,q.x+14,q.y+7), True, colors.Mode());
    end;
  end;
end;

procedure TRSWUtils.ClearCorners(bmp: TMufasaBitmap);
var
  i: Int32;
  TPA: TPointArray;
begin
 // TPA := TPAFromPolygon(Minimap.MaskPoly);
  TPA := TPA.Invert();
  FilterPointsBox(TPA, MM_AREA.X1,MM_AREA.Y1+1,MM_AREA.X2,MM_AREA.Y2);
  TPA.Offset(Point(-MM_AREA.X1,-MM_AREA.Y1));
  BMP.DrawTPA(TPA, 0);
  TPA.SortByY(True);
  for i:=0 to High(TPA) do
    bmp.SetPixel(TPA[i].x,TPA[i].y, bmp.GetPixel(TPA[i].x,TPA[i].y-1));
end;

function TRSWUtils.GetMinimap(Smooth, Sample: Boolean; ratio:Int32=1): TMufasaBitmap;
var
  B: TBox;
  theta: Double;
  TmpRes: TMufasaBitmap;
begin
  theta  := Minimap.GetCompassAngle(False);
  TmpRes := GetMufasaBitmap(BitmapFromClient(MM_AREA.x1, MM_AREA.y1, MM_AREA.x2, MM_AREA.y2));

 // if mfSymbols in Self.MapFilters then
 //   RSWUtils.ClearSymbols(TmpRes);

  RSWUtils.ClearCorners(TmpRes);



  Result.Init(client.getMBitmaps);
  TmpRes.RotateBitmapEx(theta, False, Smooth, Result);
  TmpRes.Free();

  B := RSWUtils.MinBoxInRotated(MM_CROP, theta);
  while B.Width  > 112 do begin B.x2 -= 1; B.x1 += 1; end;
  while B.Height > 100 do begin B.y2 -= 1; B.y1 += 1; end;
  Result.Crop(B.x1,B.y1,B.x2,B.y2);

  if Sample then
  begin
    TmpRes.Init(client.GetMBitmaps);
    Result.Downsample(ratio, TmpRes);
    Result.Free();
    Result := TmpRes;
  end;
end;


function TRSWUtils.AssembleSlices(Folder: string; Slices: TPointArray; out Base: TPoint): TMufasaBitmap; static;
var 
  p: TPoint;
  B: TBox;
  slice: TMufasaBitmap;
  xmax,ymax: Int32;
begin
  B := GetTPABounds(Slices);
  Base := Point(B.y1 * SLICE_HEIGHT, B.x1 * SLICE_WIDTH);
  
  Result.Init(client.GetMBitmaps);
  Result.SetSize(B.Height * SLICE_HEIGHT, B.Width * SLICE_WIDTH);
  for p in slices do
    if FileExists(Format(Folder + SLICE_FMT, [p.x,p.y])) then
    begin
      slice.Init(client.GetMBitmaps);
      slice.LoadFromFile(Folder + Format(SLICE_FMT, [p.x,p.y]));
      slice.DrawTransparent(
        p.y*SLICE_HEIGHT - B.y1*SLICE_HEIGHT,
        p.x*SLICE_WIDTH  - B.x1*SLICE_WIDTH,
        Result
      );
      slice.Free();
      xmax := Max(xmax,p.X);
      ymax := Max(xmax,p.Y);
    end else
    begin
      WriteLn('TRSWUtils.AssembleSlices: Warning slice: ',Format('%d,%d', [p.x,p.y]),' does not exist');
      Writeln(Format(Folder + SLICE_FMT, [p.x,p.y]));
    end;
  Result.SetSize((ymax-B.y1+1) * SLICE_HEIGHT, (xmax-B.x1+1) * SLICE_WIDTH);
end;

function TRSWUtils.SliceRange(Start, Stop: TPoint): TPointArray; static;
var x,y: Int32;
begin
  for y:=Start.y to Stop.y do
    for x:=Start.x to Stop.x do Result += Point(x,y);
end;

function TRSWUtils.PathToSlices(Path: TPointArray): TPointArray; static;
var 
  B: TBox;
  x,y,x1,y1,x2,y2: Int32;
begin
  B := GetTPABounds(Path);
  
  x1 := B.x1 div SLICE_WIDTH;
  y1 := B.y1 div SLICE_HEIGHT;
  if (x1 > 0) and (B.x1 - x1*SLICE_WIDTH  < 100) then Dec(x1);
  if (y1 > 0) and (B.y1 - y1*SLICE_HEIGHT < 100) then Dec(y1);
  
  x2 := B.x2 div SLICE_WIDTH;
  y2 := B.y2 div SLICE_HEIGHT;
  if ((x2*SLICE_WIDTH+SLICE_WIDTH)   - B.x2 < 100) then Inc(x2);
  if ((y2*SLICE_HEIGHT+SLICE_HEIGHT) - B.y2 < 100) then Inc(y2);
  
  for y:=y1 to y2 do
    for x:=x1 to x2 do Result += Point(y,x);
end;


// -----------------------------------------------------------------------------
// TWebGraph - A web for any runescape map so you can walk everywhere on it.

function TWebGraph.Copy(): TWebGraph;
begin
  Result.Blocking := System.Copy(Self.Blocking);
  Result.Names    := System.Copy(Self.Names);
  Result.Nodes    := System.Copy(Self.Nodes);
  Result.Paths    := System.Copy(Self.Paths);
end;

procedure TWebGraph.BlockOutside(Area: TBox);
var
  i, c: Int32;
begin
  SetLength(Blocking, Length(Self.Nodes));

  for i := 0 to High(Self.Nodes) do
    if (not Area.Contains(Self.Nodes[i])) then
    begin
      Blocking[c] := i;
      Inc(c);
    end;

  SetLength(Blocking, c);
end;

function TWebGraph.FindNode(Name: String): Int32;
begin
  for Result:=0 to High(Self.Names) do
    if Pos(Name, Self.Names[Result]) <> 0 then
      Exit(Result);
  Result := -1;
end;

procedure TWebGraph.InvalidNode(Name: String);
var
  Arr: TStringArray;
  A, B: String;
  i, j: Int32;
begin
  Arr := Self.Names;

  for i := 0 to High(Arr) do
    for j := 0 to High(Arr) do
      if Arr[i] < Arr[j] then
      begin
        A := Arr[i];
        B := Arr[j];

        Arr[i] := B;
        Arr[j] := A;
      end;

  for i := 0 to High(Names) do
    WriteLn(Names[i]);

  WriteLn(#10);
  WriteLn('Node "' + Name + '" not found. Available nodes are above.');
  WriteLn(#10);

  TerminateScript();
end;

function TWebGraph.FindPath(Start, Goal: Int32; Rnd:Double=0): TIntegerArray; constref;
type
  TNode = record
    Indices: TIntegerArray;
    Score: Double;
  end;
var
  queue: array of TNode;
  visited: TBoolArray;
  cIdx, pathIdx, i: Int32;
  current, node: TNode;
  altPaths: array of TIntegerArray;
  p,q: TPoint;
  hyp: Double;

  function GetNextShortest(): TNode;
  var i,node: Int32;
  begin
    Result := queue[0];
    for i:=0 to High(queue) do
      if queue[i].Score < Result.Score then
      begin
        node   := i;
        Result := queue[i];
      end;
    Delete(queue, node, 1);
  end;
begin
  queue   := [[[start],0]];
  SetLength(visited, Length(Self.Nodes));
  
  // block certain paths by marking them as visited
  for i:=0 to High(Blocking) do Visited[Blocking[i]] := True;

  // ...
  while Length(queue) <> 0 do
  begin
    current := GetNextShortest();
    cIdx := current.Indices[High(current.Indices)];
    if Visited[cIdx] then Continue; //skip overwrapping paths..
    Visited[cIdx] := True;

    if (cIdx = Goal) then
      Exit(current.Indices);

    p := Self.Nodes[cIdx];
    for pathIdx in Self.Paths[cIdx] do
    begin
      if not Visited[pathIdx] then
      begin
        q := Self.Nodes[pathIdx];
        node.Indices := current.Indices + pathIdx;

        hyp := Hypot(p.x-q.x, p.y-q.y);
        node.Score   := current.Score + hyp + (hyp*Random()*Rnd-Rnd/2);
        queue += node;
      end;
    end;
  end;
end;

function TWebGraph.FindNearestNode(P: TPoint): Int32; constref;
var 
  i,j: Int32;
  d,best,dn1,dn2: Double;
begin
  best := $FFFFFF;
  for i:=0 to High(Self.Paths) do
    for j in Self.Paths[i] do
    begin
      d := RSWUtils.DistToLine(P, Self.Nodes[i], Self.Nodes[j]);
      if d < best then
      begin
        best := d;
        dn1 := Hypot(Self.Nodes[i].x-P.x, Self.Nodes[i].y-P.y);
        dn2 := Hypot(Self.Nodes[j].x-P.x, Self.Nodes[j].y-P.y);
        if dn1 < dn2 then 
          Result := i
        else  
          Result := j;
      end;
    end;
end;

function TWebGraph.NodesToPoints(NodeList: TIntegerArray): TPointArray; constref;
var node: Int32;
begin
  for node in NodeList do
    Result += Self.Nodes[node];
end;

function TWebGraph.PathBetween(p,q: TPoint; Rnd:Double=0): TPointArray; constref;
var
  i,n1,n2: Int32;
  nodes: TIntegerArray;
begin
  n1 := Self.FindNearestNode(p);
  n2 := Self.FindNearestNode(q);
  nodes := Self.FindPath(n1,n2,Rnd);
  if (Length(nodes) = 0) then
    RaiseException('Points `'+ToStr(p)+'` and `'+ToStr(q)+'` does not connect');

  // if distance between nodes > ??? then Unreliable result

  Result += p;
  Result += NodesToPoints(nodes);
  Result += q;
end;

function TWebGraph.InvalidConnection(p,q: TPoint): Boolean;
var
  i,n: Int32;
  l1,l2: array[0..1] of TPoint;
  _: TPoint;
begin
  l1 := [p,q];
  for i:=0 to High(self.Paths) do
  begin
    l2[0] := self.Nodes[i];
    for n in self.Paths[i] do
    begin
      l2[1] := self.Nodes[n];
      if (l1[0] = l2[0]) and (l1[1] = l2[1]) then
        Continue;
      if RSWUtils.LinesIntersect(l1,l2,_) then
        Exit(True);
    end;
  end;
end;

function TWebGraph.AddNode(p: TPoint; FromNode: Int32): Boolean;
var
  c: Int32;
begin
  if (FromNode <> -1) and (InvalidConnection(p, Self.Nodes[FromNode])) then
    Exit(False);

  c := Length(Self.Nodes);
  SetLength(Self.Nodes, c+1);
  SetLength(Self.Paths, c+1);
  Self.Nodes[c] := p;

  if FromNode <> -1 then
  begin
    Self.Paths[FromNode] += c;
    Self.Paths[c] += FromNode;
  end;

  Result := True;
end;

function TWebGraph.ConnectNodes(a,b: Int32): Boolean;
var
  i,n: Int32;
  p: TPoint;
  l1,l2: array[0..1] of TPoint;
begin
  if InIntArray(Self.Paths[a], b) then
  begin
    Self.Paths[a].Remove(b);
    Self.Paths[b].Remove(a);
  end else
  begin
    if (Self.InvalidConnection(Self.Nodes[a], Self.Nodes[b])) then
      Exit(False);

    Self.Paths[a] += b;
    Self.Paths[b] += a;
  end;

  Result := True;
end;

function TWebGraph.DeleteNode(node: Int32): Int32;
var
  i,j,n,curr: Int32;
  marked: TIntegerArray;
begin
  marked += node;
  repeat
    curr := marked.Pop();

    for n in Self.Paths[curr] do
    begin
      Self.Paths[n].Remove(curr, True);
      if Length(Self.Paths[n]) = 0 then
        marked += n;
    end;

    // offset remainding nodes
    for i:=0 to High(Self.Paths) do
      for j:=0 to High(Self.Paths[i]) do
        if Self.Paths[i][j] > curr then
          Dec(Self.Paths[i][j]);

    for i:=0 to High(marked) do
      if marked[i] > curr then Dec(marked[i]);

    // remove the node itself
    Delete(Self.Paths, curr, 1);
    Delete(Self.Nodes, curr, 1);
    Result += 1;
  until Length(marked) = 0;
end;


{$I world.graph}
var 
  RSW_Graph: TWebGraph := WorldGraph.Copy();




