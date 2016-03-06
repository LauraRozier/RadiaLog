{   Component(s):
    tcyImage

    Description:
    Herited from TImage, allow zoom and paint into real GraphiControl canvas ...

    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $  €€€ Accept any PAYPAL DONATION $$$  €
    $      to: mauricio_box@yahoo.com      €
    €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

    * ***** BEGIN LICENSE BLOCK *****
    *
    * Version: MPL 1.1
    *
    * The contents of this file are subject to the Mozilla Public License Version
    * 1.1 (the "License"); you may not use this file except in compliance with the
    * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
    *
    * Software distributed under the License is distributed on an "AS IS" basis,
    * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
    * the specific language governing rights and limitations under the License.
    *
    * The Initial Developer of the Original Code is Mauricio
    * (https://sourceforge.net/projects/tcycomponents/).
    *
    * Donations: see Donation section on Description.txt
    *
    * Alternatively, the contents of this file may be used under the terms of
    * either the GNU General Public License Version 2 or later (the "GPL"), or the
    * GNU Lesser General Public License Version 2.1 or later (the "LGPL"), in which
    * case the provisions of the GPL or the LGPL are applicable instead of those
    * above. If you wish to allow use of your version of this file only under the
    * terms of either the GPL or the LGPL, and not to allow others to use your
    * version of this file under the terms of the MPL, indicate your decision by
    * deleting the provisions above and replace them with the notice and other
    * provisions required by the LGPL or the GPL. If you do not delete the
    * provisions above, a recipient may use your version of this file under the
    * terms of any one of the MPL, the GPL or the LGPL.
    *
    * ***** END LICENSE BLOCK *****}

unit cyCustomImage;

{$I ..\Core\cyCompilerDefines.inc}

interface

uses VCL.cyClasses, VCL.cyTypes, VCL.cyGraphics, Windows, Graphics, ExtCtrls, classes, Messages, {$IFDEF DELPHI2009_OR_ABOVE} UXTheme, {$ENDIF} Controls, Math;

type
  TcyGraphicControl = class(TGraphicControl)
  end;

  TcyCustomImage = class(TImage)
  private
    FOnPaint: TNotifyEvent;
    FZoom: Double;
    FBeforePaint: TNotifyEvent;
    procedure SetZoom(const Value: Double);
    function GetCanvasControl: TCanvas;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;
    // procedure SetAutoSize(Value: Boolean); override;
    property CanvasControl: TCanvas read GetCanvasControl;
    property Zoom: Double read FZoom write SetZoom;
    property BeforePaint: TNotifyEvent read FBeforePaint write FBeforePaint;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyZoomFactor;
  published
  end;

  TcyImage = class(TcyCustomImage)
  private
  protected
  public
    // Herited from TcyCustomImage :
    property CanvasControl;
  published
    // Herited from TcyCustomImage :
    property Zoom;
    property BeforePaint;
    property OnPaint;
  end;




(* Abandonned for now ...
  TcyImageTool = (itNone, itZoom, itPickColor, itCrop, itText, itSelectRect, itFillColor, itFreeHand, itLine, itPolygon, itRectangle, itRoundRect, itEllipse, itErase);
  TcyImageToolMouseOngoingTask = (ijNone, ijCrop, ijText, ijSelectRect, ijFreeHand, ijLine, ijPolygon, ijRectangle, ijRoundRect, ijEllipse, ijErase);

  TcyImageAutoHandlingOption = (// ioNone,
                                     ioZoom,                    // Make image zoom with left / right click
                                     ioPickColor,               // Pick color under mouse cursor with left click
                                     ioCrop,
                                     ioText,
                                     ioSelectRect,
                                     ioFillColor,
                                     ioFreeHand,
                                     ioLine,
                                     ioPolygon,
                                     ioRectangle,
                                     ioRoundRect,
                                     ioEllipse,
                                     ioErase
                                     );

  TcyImageAutoHandlingOptions = Set of TcyImageAutoHandlingOption;

  TProcOnPickColor = procedure (Sender: TObject; const WithButton: TMouseButton; const Color: TColor) of object;

  TcyImageEditor = class(TCustomControl)
  private
    FTool: TcyImageTool;
    FAutoHandlingOptions: TcyImageAutoHandlingOptions;
    FTask: TcyImageToolMouseOngoingTask;
    FOnPickColor: TProcOnPickColor;
    FAutoPickColor: TColor;
    procedure SetTool(const Value: TcyImageTool);
    procedure SetAutoHandlingOptions(const Value: TcyImageAutoHandlingOptions);
    procedure SetTask(const Value: TcyImageToolMouseOngoingTask);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override; // Call OnMouseDown procedure ...
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override; // Call OnMouseUp procedure ...
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AutoPickColor: TColor read FAutoPickColor write FAutoPickColor;
    property Task: TcyImageToolMouseOngoingTask read FTask write SetTask;
    property Tool: TcyImageTool read FTool write SetTool;
    // Herited from TcyCustomImage :
    property CanvasControl;
  published
    property AutoHandlingOptions: TcyImageAutoHandlingOptions read FAutoHandlingOptions write SetAutoHandlingOptions default [
                                     ioZoom, ioPickColor, ioCrop, ioText, ioSelectRect, ioFillColor, ioFreeHand, ioLine,
                                     ioPolygon, ioRectangle, ioRoundRect, ioEllipse, ioErase];
    property OnPickColor: TProcOnPickColor read FOnPickColor write FOnPickColor;
    // Herited from TcyCustomImage :
    property Zoom;
    property BeforePaint;
    property OnPaint;
  end;     *)


implementation

constructor TcyCustomImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZoom := 1; // 100%
end;

destructor TcyCustomImage.Destroy;
begin
  inherited Destroy;
end;

// TImage.Canvas is in fact, TImage.Picture.Bitmap.Canvas
// What i want is paint into real TGraphic.Canvas!
function TcyCustomImage.GetCanvasControl: TCanvas;
begin
  Result := TcyGraphicControl(Self).Canvas;
end;

procedure TcyCustomImage.ApplyZoomFactor;
var
  aCanvas: TCanvas;
  _Zoom: Double;

    procedure SetCanvasZoomAndRotation(ACanvas: TCanvas; Zoom: Double; Angle: Double; CenterpointX, CenterpointY: Double);
    var
      form: tagXFORM;
      rAngle: Double;
    begin
      rAngle := DegToRad(Angle);
      SetGraphicsMode(ACanvas.Handle, GM_ADVANCED);
      SetMapMode(ACanvas.Handle, MM_ANISOTROPIC);
      form.eM11 := Zoom * Cos(rAngle);
      form.eM12 := Zoom * Sin(rAngle);
      form.eM21 := Zoom * (-Sin(rAngle));
      form.eM22 := Zoom * Cos(rAngle);
      form.eDx := CenterpointX;
      form.eDy := CenterpointY;
      SetWorldTransform(ACanvas.Handle, form);
    end;

(*  procedure SetCanvasZoomFactor(aCanvas: TCanvas; AZoomFactor: Integer);
    var
      i: Integer;
    begin
      if AZoomFactor = 100 then
        SetMapMode(aCanvas.Handle, MM_TEXT)
      else
      begin
        SetMapMode(aCanvas.Handle, MM_ISOTROPIC);
        SetWindowExtEx(aCanvas.Handle, AZoomFactor, AZoomFactor, nil);
        SetViewportExtEx(aCanvas.Handle, 100, 100, nil);
      end;
    end;       *)

begin
  aCanvas := TcyGraphicControl(Self).Canvas;

  if (FZoom = 1) or (Stretch) then
  begin
    // No need?!
    // SetCanvasZoomAndRotation(aCanvas, 1, 0, 0, 0); // SetMapMode(aCanvas.Handle, MM_TEXT)
  end
  else begin
    // _Zoom := Round(1/FZoom * 100);
    _Zoom := FZoom;
    SetCanvasZoomAndRotation(aCanvas, _Zoom, 0, 0, 0);
  end;
end;

function TcyCustomImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  if csLoading in ComponentState then
  begin
    Result := true;
    NewWidth := Width;
    NewHeight := Height;
    Exit;
  end;

  Result := True;
  if not (csDesigning in ComponentState) or (Picture.Width > 0) and (Picture.Height > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := Round(Picture.Width * FZoom);
    if Align in [alNone, alTop, alBottom] then
      NewHeight := Round(Picture.Height * FZoom);
  end;
end;

procedure TcyCustomImage.Paint;
{$IFDEF DELPHI2009_OR_ABOVE}
var
  aStyle: TBgStyle;
  aPosition: TBgPosition;

  procedure DoBufferedPaint(Canvas: TCanvas);
  var
    MemDC: HDC;
    Rect: TRect;
    PaintBuffer: HPAINTBUFFER;
  begin
    Rect := DestRect;
    PaintBuffer := BeginBufferedPaint(Canvas.Handle, Rect, BPBF_TOPDOWNDIB, nil, MemDC);
    try
      Canvas.Handle := MemDC;
      DrawGraphic(TcyGraphicControl(Self).Canvas, DestRect, Picture.Graphic, Transparent, aStyle, aPosition);
      BufferedPaintMakeOpaque(PaintBuffer, Rect);
    finally
      EndBufferedPaint(PaintBuffer, True);
    end;
  end;

begin
  ApplyZoomFactor;

  if Assigned(FBeforePaint) then FBeforePaint(Self);

  aStyle := bgNormal;

  if Center
  then aPosition := bgCentered
  else aPosition := bgTopLeft;

  if Stretch then
    if Proportional
    then aStyle := bgStretchProportional
    else aStyle := bgStretch;

  if csDesigning in ComponentState then
    with TcyGraphicControl(Self).Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;

  if (csGlassPaint in ControlState) and (Picture.Graphic <> nil) and
     not Picture.Graphic.SupportsPartialTransparency then
    DoBufferedPaint(TcyGraphicControl(Self).Canvas)
  else
    DrawGraphic(TcyGraphicControl(Self).Canvas, DestRect, Picture.Graphic, Transparent, aStyle, aPosition);

  if Assigned(FOnPaint) then FOnPaint(Self);
end;
{$ELSE}
begin
  ApplyZoomFactor;

  if Assigned(FBeforePaint) then FBeforePaint(Self);
  Inherited;
  if Assigned(FOnPaint) then FOnPaint(Self);
end;
{$ENDIF}

procedure TcyCustomImage.SetZoom(const Value: Double);
var
  NewWidth, NewHeight: Integer;
  RedrawRect: TRect;
begin
  if Value = 0 then Exit;
  if FZoom = Value then Exit;

  FZoom := Value;

  if Autosize then
  begin
    Invalidate;

    if (Picture.Width > 0) and (Picture.Height > 0) then
    begin
      if Align in [alNone, alLeft, alRight]
      then NewWidth := Round(Picture.Width * FZoom)
      else NewWidth := Width;

      if Align in [alNone, alTop, alBottom]
      then NewHeight := Round(Picture.Height * FZoom)
      else NewHeight := Height;

      if (NewWidth <> Width) or (NewHeight <> Height) then
        SetBounds(Left, Top, NewWidth, NewHeight);
    end;
  end
  else begin
    // Erase background :
    if Assigned(Self.Parent) then
    begin
      RedrawRect := classes.Rect(Left, Top, Left + Width, Top + Height);
      InvalidateRect(Self.Parent.Handle, @RedrawRect, true);
    end;
  end;
end;

(*
{ TcyImageEditor }
constructor TcyImageEditor.Create(AOwner: TComponent);
begin
  inherited;
  FAutoPickColor := clBlack;
  FTask := ijNone;
  FTool := itNone;
  FAutoHandlingOptions := [ioZoom, ioPickColor, ioCrop, ioText, ioSelectRect, ioFillColor, ioFreeHand, ioLine,
                           ioPolygon, ioRectangle, ioRoundRect, ioEllipse, ioErase];
end;

destructor TcyImageEditor.Destroy;
begin

  inherited;
end;

procedure TcyImageEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CursorPos: TPoint;
begin
  inherited;

  case FTool of
    itZoom:
    begin
      if ioZoom in FAutoHandlingOptions then
        case Button of
          mbLeft:
          begin
            if FZoom < 20 then
              Zoom := FZoom * 2
          end;

          mbRight:
          begin
            if FZoom > 0.25 then
              Zoom := FZoom / 2;
          end;
        end;
    end;

    itPickColor:
    begin
      if GetCursorPos(CursorPos) then
        if GetScreenPixelColor(CursorPos, FAutoPickColor) then
          if Assigned(FOnPickColor) then
            FOnPickColor(Self, Button, FAutoPickColor);
    end;

    itCrop:
    begin

    end;

    itText: ;
    itSelectRect: ;
    itFillColor: ;
    itFreeHand: ;
    itLine: ;
    itPolygon: ;
    itRectangle: ;
    itRoundRect: ;
    itEllipse: ;
    itErase: ;
  end;
end;

procedure TcyImageEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TcyImageEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TcyImageEditor.SetAutoHandlingOptions(const Value: TcyImageAutoHandlingOptions);
begin
  FAutoHandlingOptions := Value;
end;

procedure TcyImageEditor.SetTask(const Value: TcyImageToolMouseOngoingTask);
begin
  FTask := Value;
end;

procedure TcyImageEditor.SetTool(const Value: TcyImageTool);
begin
  FTool := Value;
end;  *)

end.
