library libasyncmouse;

(*
ASyncMouse
==========

ASyncMouse is a plugin which moves the mouse on another thread so your script
can update the mouse destination while the mouse is actively moving.

The following methods are defined:

.. pascal::

  procedure TASyncMouse.Move(Destination: TPoint; Accuracy: Double = 1);
  procedure TASyncMouse.ChangeDestination(Destination: TPoint);
  procedure TASyncMouse.Stop;
  function TASyncMouse.IsMoving: Boolean;

**Example :**

.. pascal::
  {$I SRL/OSR.simba}
  {$I SRL/utils/asyncmouse.simba}

  function FindMyObject(out Position: TPoint): Boolean;
  begin
    // Your object finder ..
  end;

  var
    Position: TPoint;

  begin
    if FindMyObject(Position) then
    begin
      ASyncMouse.Move(Position);

      while ASyncMouse.IsMoving() do
      begin
        if FindMyObject(Position) then
          ASyncMouse.ChangeDestination(Position);

        Wait(50);
      end;
    end;
  end.

* *Accuracy* parameter in *ASyncMouse.Move* is maximum distance to the destination where the
  mouse movement is considered finished. By default it's *1* which means the mouse wont
  stop moving until the exact destination has been reached.

* ASyncMouse uses the current variables (Speed, Wind, Gravity) from SRL's *Mouse* variable.

* Mouse movement can be stopped at anytime with *ASyncMouse.Stop*

*)

{$mode objfpc}{$H+}

uses
  {$IFDEF LINUX}
  cmem, cthreads,
  {$ENDIF}
  classes, sysutils,
  libasyncmouse.asyncmouse;

{$i simbaplugin.inc}

type
  PPoint = ^TPoint;

procedure Lape_ASyncMouse_Create(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PASyncMouse(Result)^ := TASyncMouse.Create(Pointer(Params^[0]^), Pointer(Params^[1]^));
end;

procedure Lape_ASyncMouse_Free(const Params: PParamArray); cdecl;
begin
  PASyncMouse(Params^[0])^.Free();
end;

procedure Lape_ASyncMouse_Move(const Params: PParamArray); cdecl;
begin
  PASyncMouse(Params^[0])^.Move(PPoint(Params^[1])^, PDouble(Params^[2])^, PDouble(Params^[3])^, PDouble(Params^[4])^, PDouble(Params^[5])^, PDouble(Params^[6])^, PDouble(Params^[7])^, PDouble(Params^[8])^);
end;

procedure Lape_ASyncMouse_ChangeDestination(const Params: PParamArray); cdecl;
begin
  PASyncMouse(Params^[0])^.Destination := PPoint(Params^[1])^;
end;

procedure Lape_ASyncMouse_IsMoving(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PBoolean(Result)^ := PASyncMouse(Params^[0])^.Moving;
end;

procedure Lape_ASyncMouse_Stop(const Params: PParamArray); cdecl;
begin
  PASyncMouse(Params^[0])^.Moving := False;
end;

begin
  addGlobalType('type Pointer', 'TASyncMouse');

  addGlobalFunc('function TASyncMouse.__Create(constref MoveMouse, GetMousePosition): TASyncMouse; static; native;', @Lape_ASyncMouse_Create);
  addGlobalFunc('procedure TASyncMouse.__Free; native;', @Lape_ASyncMouse_Free);
  addGlobalFunc('procedure TASyncMouse.__Move(Destination: TPoint; Gravity, Wind, MinWait, WaxWait, MaxStep, TargetArea, Accuracy: Double); native;', @Lape_ASyncMouse_Move);
  addGlobalFunc('procedure TASyncMouse.ChangeDestination(Destination: TPoint); native;', @Lape_ASyncMouse_ChangeDestination);
  addGlobalFunc('procedure TASyncMouse.Stop; native;', @Lape_ASyncMouse_Stop);
  addGlobalFunc('function TASyncMouse.IsMoving: Boolean; native;', @Lape_ASyncMouse_IsMoving);

  addCode('procedure TASyncMouse.__MoveMouse(X, Y: Int32); static;'                                                                + LineEnding +
          'begin'                                                                                                                  + LineEnding +
          '  MoveMouse(X, Y);'                                                                                                     + LineEnding +
          'end;'                                                                                                                   + LineEnding +
          ''                                                                                                                       + LineEnding +
          'procedure TASyncMouse.__GetMousePosition(var X, Y: Int32); static;'                                                     + LineEnding +
          'begin'                                                                                                                  + LineEnding +
          '  GetMousePos(X, Y);'                                                                                                   + LineEnding +
          'end;'                                                                                                                   + LineEnding +
          ''                                                                                                                       + LineEnding +
          'procedure TASyncMouse.Move(Destination: TPoint; Accuracy: Double = 1);'                                                 + LineEnding +
          'var'                                                                                                                    + LineEnding +
          '  Speed: Double := (Random(Mouse.Speed) / 2.0 + Mouse.Speed) / 10.0;'                                                   + LineEnding +
          'begin'                                                                                                                  + LineEnding +
          '  Self.__Move(Destination, Mouse.Gravity, Mouse.Wind, 10.0 / Speed, 15.0 / Speed, 10.0 * Speed, 10.0 * Speed, Accuracy);' + LineEnding +
          'end;'                                                                                                                   + LineEnding +
          ''                                                                                                                       + LineEnding +
          'var'                                                                                                                    + LineEnding +
          '  ASyncMouse: TASyncMouse := TASyncMouse.__Create('                                                                       + LineEnding +
          '                               Natify(@TASyncMouse.__MoveMouse),'                                                       + LineEnding +
          '                               Natify(@TASyncMouse.__GetMousePosition)'                                                 + LineEnding +
          '                             );'                                                                                        + LineEnding +
          ''                                                                                                                       + LineEnding +
          'begin'                                                                                                                  + LineEnding +
          '  AddOnTerminateAlways(@ASyncMouse.__Free);'                                                                              + LineEnding +
          'end;'                                                                                                                   + LineEnding
         );
end.
