unit Unit_observaciones;
 // Por medio de esta unidad se pueden enviar solicitudes especiales a bar o cocina por medio de impresora tickeras
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ScrollBox, FMX.Memo;

type
  TForm6 = class(TForm)
    ButtonBack: TSpeedButton;
    ButtonExit: TSpeedButton;
    LabelItems: TLabel;
    EditObservacion: TMemo;
    LayoutFondo: TLayout;
    Layout2: TLayout;
    RadioCocina: TRadioButton;
    RadioBar: TRadioButton;
    Layout3: TLayout;
    procedure ButtonBackClick(Sender: TObject);
    procedure Resize(Sender: TObject);
    procedure LabelItemsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

uses
  unit_cuenta;

procedure TForm6.ButtonBackClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TForm6.FormShow(Sender: TObject);
begin
  EditObservacion.Text := '';
  EditObservacion.SetFocus;
end;

procedure TForm6.LabelItemsClick(Sender: TObject);
// Al confiurmar el comentario, se agrega a la lista de comandas por enviar según se seleccione bar o cocina
begin
  if RadioCocina.IsChecked or RadioBar.IsChecked then
  begin
    if RadioCocina.IsChecked then
    begin
      Nuevos.Add('000001');
    end;
    if RadioBar.IsChecked then
    begin
      Nuevos.Add('000002');
    end;
    Form2.GridNuevos.RowCount := Form2.GridNuevos.RowCount+ 1;
    Form2.GridNuevos.Cells[0 , (Form2.GridNuevos.RowCount - 1)] := EditObservacion.Text;
    Form2.GridNuevos.Cells[1 , (Form2.GridNuevos.RowCount - 1)] := '0';
    Form2.GridNuevos.Cells[2 , (Form2.GridNuevos.RowCount - 1)] := '1';
    Form2.GridNuevos.Cells[3 , (Form2.GridNuevos.RowCount - 1)] := '0';
    Self.Close
  end;
end;

procedure TForm6.Resize(Sender: TObject);
// Modifica la interfaz al haber un cambio de tamaño de la pantalla
begin
  ButtonExit.Position.X := Screen.Width  - 48;
  if screen.Width > screen.Height then
  begin
    layoutFondo.Height := 200;
  end
  else
  begin
    layoutFondo.Height := 270;
  end;
end;

end.
