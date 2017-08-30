program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  unit_index in 'unit_index.pas' {Form1},
  Unit_cuenta in 'Unit_cuenta.pas' {Form2},
  Unit_grupos in 'Unit_grupos.pas' {Form3},
  Unit_items in 'Unit_items.pas' {Form4},
  Unit_directorio in 'Unit_directorio.pas' {Form5},
  Unit_observaciones in 'Unit_observaciones.pas' {Form6},
  Unit_cantidades in 'Unit_cantidades.pas' {Form7};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
