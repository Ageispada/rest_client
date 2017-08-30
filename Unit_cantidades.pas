unit Unit_cantidades;
// Esta unidad auxiliar muestra un cuadro para cambiar la cantidad de algún pedido por medio de selectores
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TForm7 = class(TForm)
    ButtonCantidad: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure ButtonCantidadClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation

{$R *.fmx}

uses
  unit_cuenta;


procedure TForm7.ButtonCantidadClick(Sender: TObject);
// Para cerrar el selector
begin
  Self.Close;
end;

// Con estas funciones se aumentan o reducen la cantidad de items

procedure TForm7.SpeedButton1Click(Sender: TObject);
begin
  Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected] := floattostr(strtofloat(Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected]) + 1) ;
  Form2.GridNuevos.Cells[3 , Form2.GridNuevos.Selected] := floattostr(strtofloat(Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected]) * strtofloat(Form2.GridNuevos.Cells[1 , Form2.GridNuevos.Selected]));
end;

procedure TForm7.SpeedButton2Click(Sender: TObject);
begin
  if  strtoint(Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected]) > 1 then
  begin
    Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected] := floattostr(strtofloat(Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected]) - 1) ;
    Form2.GridNuevos.Cells[3 , Form2.GridNuevos.Selected] := floattostr(strtofloat(Form2.GridNuevos.Cells[2 , Form2.GridNuevos.Selected]) * strtofloat(Form2.GridNuevos.Cells[1 , Form2.GridNuevos.Selected]));
  end;
end;
end.
