{   Component(s):
    tcyBaseGridPanel

    Description:
    A GridPanel with Canvas, OnPaint, OnMouseEnter, OnMouseLeave, Multi-bevels properties

    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $  ��� Accept any PAYPAL DONATION $$$  �
    $      to: mauricio_box@yahoo.com      �
    ����������������������������������������

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

unit cyBaseGridPanel;

{$I ..\Core\cyCompilerDefines.inc}

interface

uses Classes, Windows, Themes, Graphics, StdCtrls, ExtCtrls, Controls, Messages, Dialogs,
VCL.cyTypes, VCL.cyClasses, VCL.cyGraphics;

type
  TcyCellItem = class(TCellItem)
  end;


  TRunTimeDesignEvent = procedure (Sender: TObject; X, Y: Integer) of object;
  TProcOnOnDragDropFiles = procedure (Sender: TObject; var msg: TWMDropFiles) of object;


  tcyBaseGridPanel = class(TCustomGridPanel)
  private
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnPaint: TNotifyEvent;
    FBevels: TcyBevels;
    FShadow: TcyShadowText;
    FOnVisibleChanging: TNotifyEvent;
    FLayout: TTextLayout;
    FRunTimeDesign: TcyRunTimeDesign;
    FOnStartRunTimeDesign: TRunTimeDesignEvent;
    FOnDoRunTimeDesign: TRunTimeDesignEvent;
    FOnEndRunTimeDesign: TRunTimeDesignEvent;
    FWordWrap: Boolean;
    FCaptionOrientation: TCaptionOrientation;
    FOnDragDropFiles: TProcOnOnDragDropFiles;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMDropFiles(var msg: TWMDropFiles); message WM_DROPFILES;
    procedure BevelsChange(Sender: TObject);
    procedure SubPropertiesChanged(Sender: TObject);
    procedure SetBevels(const Value: TcyBevels);
    procedure SetShadow(const Value: TcyShadowText);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetRunTimeDesign(const Value: TcyRunTimeDesign);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetCaptionOrientation(const Value: TCaptionOrientation);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure Paint; override;
    procedure Loaded; override;
    procedure VisibleChanging; override;
    procedure DrawBackground(aRect: TRect); virtual;
    procedure DrawCaption(aRect: TRect); virtual;
    procedure MouseEnter(Sender: TObject); virtual;
    procedure MouseLeave(Sender: TObject); virtual;
    property Bevels: TcyBevels read FBevels write SetBevels;
    property CaptionOrientation: TCaptionOrientation read FCaptionOrientation write SetCaptionOrientation default coHorizontal;
    property Layout: TTextLayout read FLayout write SetLayout default tlCenter;
    property RunTimeDesign: TcyRunTimeDesign read FRunTimeDesign write SetRunTimeDesign;
    property Shadow: TcyShadowText read FShadow write SetShadow;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnVisibleChanging: TNotifyEvent read FOnVisibleChanging write FOnVisibleChanging;
    property OnStartRunTimeDesign: TRunTimeDesignEvent read FOnStartRunTimeDesign write FOnStartRunTimeDesign;
    property OnDoRunTimeDesign: TRunTimeDesignEvent read FOnDoRunTimeDesign write FOnDoRunTimeDesign;
    property OnEndRunTimeDesign: TRunTimeDesignEvent read FOnEndRunTimeDesign write FOnEndRunTimeDesign;
    property OnDragDropFiles: TProcOnOnDragDropFiles read FOnDragDropFiles write FOnDragDropFiles;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;

implementation

uses ComObj;

constructor tcyBaseGridPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelInner := bvNone;
  BevelOuter := bvNone;
  FLayout := tlCenter;
  FWordWrap := false;
  FBevels := TcyBevels.Create(self, TcyBevel);
  FBevels.OnChange := BevelsChange;
  FShadow := TcyShadowText.Create(self);
  FShadow.OnChange := SubPropertiesChanged;
  FRunTimeDesign := TcyRunTimeDesign.Create(Self);

  // Determine at design time if
  // the form is loading or if we have just added the component at design time :
  if csDesigning in ComponentState
  then
    if Owner <> nil
    then
      if not (csLoading in Owner.ComponentState)  // we have just added the component at design time
      then FBevels.Add;
end;

destructor tcyBaseGridPanel.Destroy;
begin
  FRunTimeDesign.Free;
  FShadow.Free;
  FBevels.Free;
  FBevels := Nil;

  inherited Destroy;
end;

procedure tcyBaseGridPanel.Loaded;
begin
  Inherited;
end;

procedure tcyBaseGridPanel.BevelsChange(Sender: TObject);
begin
  if FBevels.NeedOwnerRealign then
    Realign;

  Invalidate;
end;

procedure tcyBaseGridPanel.SubPropertiesChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure tcyBaseGridPanel.AdjustClientRect(var Rect: TRect);
var w: Integer;
begin
//  inherited AdjustClientRect(Rect);
  w := BorderWidth + Bevels.BevelsWidth;
  InflateRect(Rect, -w, -w);

  {$IFDEF DELPHI2009_OR_ABOVE}
  Inc(Rect.Left, Padding.Left);
  Inc(Rect.Top, Padding.Top);
  Dec(Rect.Right, Padding.Right);
  Dec(Rect.Bottom, Padding.Bottom);
  {$ENDIF}
end;

procedure tcyBaseGridPanel.Paint;
var
  Rect, TextRect: TRect;
  I, LinePos, Size: Integer;
begin
  // inherited;
  Rect := GetClientRect;
  DrawBackground(Rect);
  InflateRect(Rect, -BorderWidth, -BorderWidth);

  if (Caption <> '') {$IFDEF DELPHI2009_OR_ABOVE} and (ShowCaption) {$ENDIF}
  then begin
    TextRect := Rect;
    InflateRect(TextRect, -FBevels.BevelsWidth, -FBevels.BevelsWidth);
    DrawCaption(TextRect);
  end;

  FBevels.DrawBevels(Canvas, Rect, false);

  // Draw rows/columns :
  if csDesigning in ComponentState then
  begin
    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := clBlack;
    LinePos := Rect.Left;

    for I := 0 to ColumnCollection.Count - 2 do
    begin
      Size := TcyCellItem(ColumnCollection[I]).Size;
      Canvas.MoveTo(LinePos + Size, Rect.Top);
      Canvas.LineTo(LinePos + Size, Rect.Bottom);
      Inc(LinePos, Size);
    end;

    LinePos := Rect.Top;

    for I := 0 to RowCollection.Count - 2 do
    begin
      Size := TcyCellItem(RowCollection[I]).Size;
      Canvas.MoveTo(Rect.Left, LinePos + Size);
      Canvas.LineTo(Rect.Right, LinePos + Size);
      Inc(LinePos, Size);
    end;

    Canvas.Pen.Style := psSolid;
  end;

  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

procedure tcyBaseGridPanel.DrawBackground(aRect: TRect);
begin
  if not ThemeServices.ThemesEnabled or not ParentBackground
  then begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(aRect);
  end;
end;

procedure tcyBaseGridPanel.DrawCaption(aRect: TRect);
var
  Flags: Longint;
  TmpFont: TFont;
begin
  with Canvas do
  begin
    Brush.Style := bsClear;
    Font := Self.Font;
    Flags := DrawTextFormatFlags(0, Alignment, FLayout, WordWrap);
    Flags := DrawTextBiDiModeFlags(Flags);

    if FCaptionOrientation = coHorizontal
    then begin
      // Draw shadow caption :
      if Enabled and FShadow.Active
      then FShadow.DrawShadowText(Canvas, aRect, Caption, Alignment, FLayout, FCaptionOrientation, Flags);

      // Draw normal caption :
      cyDrawText(Handle, Caption, aRect, Flags);
    end
    else begin
      TmpFont := cyCreateFontIndirect(Font, FCaptionOrientation);
      try
        Font.Assign(TmpFont);

        // Draw shadow caption :
        if Enabled and FShadow.Active
        then FShadow.DrawShadowText(Canvas, aRect, Caption, Alignment, FLayout, FCaptionOrientation, Flags);

        // Draw normal caption :
        cyDrawVerticalText(Canvas, Caption, aRect, Flags, FCaptionOrientation, Alignment, FLayout);
      finally
        TmpFont.Free;
      end;
    end;
  end;
end;

procedure tcyBaseGridPanel.SetBevels(const Value: TcyBevels);
begin
  FBevels := Value;
end;

procedure tcyBaseGridPanel.SetCaptionOrientation(const Value: TCaptionOrientation);
begin
  if FCaptionOrientation = Value then Exit;

  FCaptionOrientation := Value;
  Invalidate;

  if (csDesigning in ComponentState) and (not (csLoading in ComponentState))
  then
    if (FCaptionOrientation <> coHorizontal) and CaptionOrientationWarning
    then begin
      CaptionOrientationWarning := false;
      ShowMessage(cCaptionOrientationWarning);
    end;
end;

procedure tcyBaseGridPanel.SetLayout(const Value: TTextLayout);
begin
  FLayout := Value;
  Invalidate;
end;

procedure tcyBaseGridPanel.SetRunTimeDesign(const Value: TcyRunTimeDesign);
begin
  FRunTimeDesign := Value;
end;

procedure tcyBaseGridPanel.SetShadow(const Value: TcyShadowText);
begin
  FShadow := Value;
end;

procedure tcyBaseGridPanel.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  Invalidate;
end;

procedure tcyBaseGridPanel.VisibleChanging;
begin
  inherited;
  if Assigned(FOnVisibleChanging)
  then FOnVisibleChanging(Self);
end;

procedure tcyBaseGridPanel.CMDropFiles(var msg: TWMDropFiles);
begin
  if Assigned(FOnDragDropFiles) then
    FOnDragDropFiles(Self, msg);
end;

procedure tcyBaseGridPanel.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  MouseEnter(Self);
end;

procedure tcyBaseGridPanel.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  MouseLeave(Self);
end;

procedure tcyBaseGridPanel.MouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure tcyBaseGridPanel.MouseLeave(Sender: TObject);
begin
  if Assigned(FonMouseLeave) then FOnMouseLeave(Self);
end;

procedure tcyBaseGridPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FRunTimeDesign.StartJob(X, Y);

  if FRunTimeDesign.Job <> rjNothing
  then
    if Assigned(FOnStartRunTimeDesign)
    then FOnStartRunTimeDesign(Self, X, Y);

  inherited;
end;

procedure tcyBaseGridPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FRunTimeDesign.Job <> rjNothing
  then
    if Assigned(FOnDoRunTimeDesign)
    then FOnDoRunTimeDesign(Self, X, Y);

  FRunTimeDesign.DoJob(X, Y);

  inherited;
end;

procedure tcyBaseGridPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FRunTimeDesign.Job <> rjNothing
  then
    if Assigned(FOnEndRunTimeDesign)
    then FOnEndRunTimeDesign(Self, X, Y);

  FRunTimeDesign.EndJob(X, Y);
  inherited;
end;

end.
