unit Unit_directorio;
// Esta unidad se habilita cuando el cliente puide la cuenta, puede abrir este formnulario para cargar los datos de un cliente registrado
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, System.Rtti, FMX.Grid,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, strutils;

type
  TForm5 = class(TForm)
    LabelItems: TLabel;
    ButtonBack: TSpeedButton;
    ButtonExit: TSpeedButton;
    Imagecarga: TImage;
    LayoutError: TLayout;
    Label1: TLabel;
    LayoutContenido: TLayout;
    GridClientes: TStringGrid;
    identificacion: TStringColumn;
    nombre: TStringColumn;
    IdHTTP5: TIdHTTP;
    procedure ButtonBackClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CargarClientes();
    procedure ButtonExitClick(Sender: TObject);
  private
    Identificaciones, Nombres, Telefonos, Direcciones: TStrings;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;
  Rif, Buscar: String ;


implementation

{$R *.fmx}

uses
  unit_index, unit_cuenta;

procedure TForm5.ButtonBackClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TForm5.FormResize(Sender: TObject);
// Ajuste de interfaz en caso de cambio de tamaño de pantalla
begin
  LayoutError.Position.X := (Screen.Width DIV 2) - 100;
  LayoutError.Position.Y := (Screen.Height DIV 2) - 100;
  Imagecarga.Position.X := (Screen.Width DIV 2) - 25;
  Imagecarga.Position.Y := (Screen.Height DIV 2) - 25;
  ButtonExit.Position.X := Screen.Width  - 48;
end;

procedure TForm5.FormShow(Sender: TObject);
// inicia la pantalla para la carga de clientes
begin
  Imagecarga.Visible := true;
  LayoutContenido.Visible := false;
  layoutError.Visible := false;
  Form5.FormResize(Sender);
  CargarClientes();
end;

procedure TForm5.ButtonExitClick(Sender: TObject);
// Al cerrar esta ventana, cargará en la pantalla la principal los datos del cliente seleccionado
begin
  if GridClientes.Selected > -1 then
  begin
    Form2.EditIdentificacion.Text := Identificaciones[GridClientes.Selected];
    Form2.EditNombre.Text := Nombres[GridClientes.Selected];
    Form2.EditTelefono.Text := Telefonos[GridClientes.Selected];
    Form2.EditDireccion.Text := Direcciones[GridClientes.Selected];
    Self.Close;
  end;
end;

procedure TForm5.CargarClientes;
// Por esta funcion se hace la carga de los registrios de los clientes por medio de la búsqueda e coincidencia de algún campo con los parámetros introducidos por el usuario
var
  Response : String;
  v : boolean;
  List : TStrings;
  List2 : TStrings;
  List3 : TStrings;

begin
  Imagecarga.Visible := True;
  v := false;
  List := TStringList.Create;
  List2 := TStringList.Create;
  List3 := TStringList.Create;
  Identificaciones := TStringList.Create;
  Nombres := TStringList.Create;
  Telefonos := TStringList.Create;
  Direcciones := TStringList.Create;
  GridClientes.RowCount := 0;
  //Se inicializan las listas para los datos de los clientes registrados
  TThread.CreateAnonymousThread(procedure ()
  var
    i : smallint;
  begin
    try
      // Por medio de un hilo secundario se carga los registros desde el servidor
      Response := IdHTTP5.Get(servidor+'/datasnap/rest/TServerMethods1/Listarclientes/'+Usuario+'/'+Clave+'/'+Rif+'/'+Buscar);
      v := true;
    except
      LayoutError.Visible := True;
      FormResize(Self);
    end;
    if v  then
    begin
      ExtractStrings([':'], [], PChar(Response), List);
      if Form1.QuitarSimbolos(List[1]) <> '' then
      begin
        ExtractStrings(['|'], [], PChar(Form1.QuitarSimbolos(List[1])), List2);
        for i := 0 to List2.Count - 1 do
        begin
          try
            // Se registra la respuesta y se guardan en las listas y se agregan en la interfaz de usuario
            ExtractStrings(['!'], [], PChar(List2[i]), List3);
            GridClientes.RowCount := GridClientes.RowCount + 1;
            GridClientes.Cells[0 , i] := RightStr(List3[0] , length(List3[0]) - 1 );
            GridClientes.Cells[1 , i] := RightStr(List3[1] , length(List3[1]) - 1 );
            Identificaciones.Add(RightStr(List3[0] , length(List3[0]) - 1 ));
            Nombres.Add(RightStr(List3[1] , length(List3[1]) - 1 ));
            Telefonos.Add(RightStr(List3[2] , length(List3[2]) - 1 )) ;
            Direcciones.Add(RightStr(List3[3] , length(List3[3]) - 1 ));
          except
          end;
          List3.Clear;
        end;
      end;
      // Se oculta la animación de carga
      Imagecarga.Visible := False;
      Form5.LayoutContenido.Visible := True;
    end;
    Imagecarga.Visible := False;
  end).Start;
end;

end.
