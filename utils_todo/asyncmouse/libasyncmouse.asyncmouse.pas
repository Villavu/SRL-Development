unit libasyncmouse.asyncmouse;

{$mode objfpc}{$H+}

interface

uses
  classes, sysutils, syncobjs;

type
  TASyncMouse_MoveMouse = procedure(X, Y: Int32);
  TASyncMouse_GetMousePosition = procedure(var X, Y: Int32);

  PASyncMouse = ^TASyncMouse;
  TASyncMouse = class(TThread)
  protected
    FEvent: TSimpleEvent;
    FMoveMouse: TASyncMouse_MoveMouse;
    FGetMousePosition: TASyncMouse_GetMousePosition;
    FPosition: TPoint;
    FDestination: TPoint;
    FGravity: Double;
    FWind: Double;
    FMinWait: Double;
    FMaxWait: Double;
    FMaxStep: Double;
    FTargetArea: Double;
    FAccuracy: Double;
    FMoving: Boolean;

    procedure Execute; override;
  public
    procedure Move(Destination: TPoint; Gravity, Wind, MinWait, MaxWait, MaxStep, TargetArea, Accuracy: Double);

    property Destination: TPoint read FDestination write FDestination;
    property Moving: Boolean read FMoving write FMoving;

    constructor Create(MoveMouse, GetMousePosition: Pointer);
    destructor Destroy; override;
  end;

implementation

uses
  math;

procedure TASyncMouse.Execute;

  // https://github.com/BenLand100/SMART/blob/master/src/EventNazi.java#L201
  procedure WindMouse(var Moving: Boolean; var Position, Destination: TPoint; Gravity, Wind, MinWait, MaxWait, MaxStep, TargetArea, Accuracy: Double);
  var
    veloX, veloY, windX, windY, veloMag, randomDist, Dist, Step: Double;
    sqrt2, sqrt3, sqrt5: Double;
  begin
    sqrt2 := sqrt(2);
    sqrt3 := sqrt(3);
    sqrt5 := sqrt(5);

    windX := 0;
    windY := 0;
    veloX := 0;
    veloY := 0;

    Step := MaxStep;

    while Moving do
    begin
      Dist := Hypot(Position.X - Destination.X, Position.Y - Destination.Y);
      if (Dist <= Accuracy) then
        Break;

      wind := Min(Wind, Dist);

      if (Dist >= targetArea) then
      begin
        windX := windX / sqrt3 + (Random(Round(Wind) * 2 + 1) - Wind) / sqrt5;
        windY := windY / sqrt3 + (Random(Round(Wind) * 2 + 1) - Wind) / sqrt5;

        Step := MaxStep;
      end else
      begin
        windX := windX / sqrt2;
        windY := windY / sqrt2;

        if (Step < 3) then
          Step := Random(3) + 3.0
        else
          Step := Step / sqrt5;
      end;

      veloX := veloX + windX;
      veloY := veloY + windY;
      veloX := veloX + gravity * (Destination.X - Position.X) / Dist;
      veloY := veloY + gravity * (Destination.Y - Position.Y) / Dist;

      if (Hypot(veloX, veloY) > Step) then
      begin
        randomDist := step / 2.0 + Random(Round(step) div 2);

        veloMag := sqrt(veloX * veloX + veloY * veloY);
        veloX := (veloX / veloMag) * randomDist;
        veloY := (veloY / veloMag) * randomDist;
      end;

      Dist := Hypot(Position.X + veloX - Position.X,
                    Position.Y + veloY - Position.Y);

      Position.X := Round(Position.X + veloX);
      Position.Y := Round(Position.Y + veloY);

      FMoveMouse(Round(Position.X), Round(Position.Y));

      Sleep(Round((MaxWait - MinWait) * (Dist / Step) + MinWait));
    end;

    if Moving then
    begin
      if (Accuracy = 1) then
        FMoveMouse(Destination.X, Destination.Y);

      Moving := False;
    end;
  end;

begin
  while (not Terminated) do
  begin
    if FEvent.WaitFor(1000) = wrSignaled then
      WindMouse(FMoving, FPosition, FDestination, FGravity, FWind, FMinWait, FMaxWait, FMaxStep, FTargetArea, FAccuracy);

    FEvent.ResetEvent();
  end;
end;

procedure TASyncMouse.Move(Destination: TPoint; Gravity, Wind, MinWait, MaxWait, MaxStep, TargetArea, Accuracy: Double);
begin
  while FMoving do
    Sleep(1);

  FGetMousePosition(FPosition.X, FPosition.Y);
  FDestination := Destination;
  FGravity := Gravity;
  FWind := Wind;
  FMinWait := MinWait;
  FMaxWait := MaxWait;
  FMaxStep := MaxStep;
  FTargetArea := TargetArea;
  FAccuracy := Accuracy;
  FMoving := True;

  FEvent.SetEvent();
end;

constructor TASyncMouse.Create(MoveMouse, GetMousePosition: Pointer);
begin
  inherited Create(False);

  FMoveMouse := TASyncMouse_MoveMouse(MoveMouse);
  FGetMousePosition := TASyncMouse_GetMousePosition(GetMousePosition);
  FEvent := TSimpleEvent.Create();
end;

destructor TASyncMouse.Destroy;
begin
  Terminate();
  WaitFor();

  FEvent.Free();

  inherited Destroy();
end;

end.

