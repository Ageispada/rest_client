unit Unit_cuenta;
// Este es el módulo principal que se abre al seleccionar una mesa, aquí se puede cargar los platos, bebidas y datospara la realización de cuentas y facturación
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo ,System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, System.Rtti, FMX.Grid, FMX.Edit, FMX.EditBox , strutils,
  FMX.NumberBox;

type
  TForm2 = class(TForm)
    LayoutError: TLayout;
    Label1: TLabel;
    Imagecarga: TImage;
    LayoutContenido: TLayout;
    LabelMesa: TLabel;
    ScrollContenido: TScrollBox;
    ButtonBack: TSpeedButton;
    MemoCuenta: TMemo;
    IdHTTP2: TIdHTTP;
    GridComandas: TStringGrid;
    pedido: TStringColumn;
    precio: TStringColumn;
    cantidad: TStringColumn;
    subtotal: TStringColumn;
    GridNuevos: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    LayoutOpciones: TLayout;
    ButtonInsertar: TSpeedButton;
    ButtonEliminar: TSpeedButton;
    ButtonComentar: TSpeedButton;
    ButtonEnviar: TSpeedButton;
    ButtonEditar: TSpeedButton;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Editdireccion: TMemo;
    LabelSubtotal: TLabel;
    Label7: TLabel;
    LabelServicio: TLabel;
    LabelTotal: TLabel;
    Label9: TLabel;
    Buttonguardar: TButton;
    Buttoncerrar: TButton;
    Layout8: TLayout;
    IdHTTP22: TIdHTTP;
    ButtonBuscarCliente: TSpeedButton;
    LayoutClientes: TLayout;
    ScrollBox1: TScrollBox;
    GridClientes: TStringGrid;
    Identificacion: TStringColumn;
    Nombre: TStringColumn;
    Layout9: TLayout;
    EditTelefono: TMemo;
    EditNombre: TMemo;
    EditIdentificacion: TMemo;
    LayoutFondo: TLayout;
    procedure FormResize(Sender: TObject);
    procedure ButtonBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CargarCuenta();
    procedure ButtonInsertarClick(Sender: TObject);
    procedure ButtonEliminarClick(Sender: TObject);
    procedure ButtonEnviarClick(Sender: TObject);
    procedure ButtonguardarClick(Sender: TObject);
    procedure ButtoncerrarClick(Sender: TObject);
    procedure ButtonBuscarClienteClick(Sender: TObject);
    procedure ButtonComentarClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure ButtonEditarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Nmesa : String;
  Nuevos: TStrings;

implementation

{$R *.fmx}

uses
  unit_index , unit_grupos , unit_directorio , unit_observaciones , unit_cantidades;

procedure TForm2.ButtonguardarClick(Sender: TObject);
// Para guardar los datos modificados de la cuenta sin solicitar factura
var
  Response ,  Mensaje : String;
begin
  try
     Response := IdHTTP2.Get(servidor+'/datasnap/rest/TServerMethods1/Cargardatos/'+Usuario+'/'+Clave+'/'+Nmesa+'/'+EditIdentificacion.Text+'/'+Editnombre.Text+'/'+Edittelefono.Text+'/'+Editdireccion.Text);
     Mensaje := 'Datos cargados';
     CargarCuenta()
  except
     Mensaje := 'Error de conexión';
  end;
  showmessage(Mensaje);
end;

procedure TForm2.ButtonBackClick(Sender: TObject);
// cierra este formulario
begin
  Self.Close;
end;

procedure TForm2.ButtonBuscarClienteClick(Sender: TObject);
//Abre el buscador de clientes regitrados
begin
  Rif := EditIdentificacion.text;
  Buscar := EditNombre.text;
  Form5 := TForm5.Create(Self);
  Form5.Show;
end;

procedure TForm2.ButtoncerrarClick(Sender: TObject);
// Este módulo envúia la solicitud de cerrar la mesa al servidor
var
  Response ,  Mensaje : String;
begin
  try
     Response := IdHTTP2.Get(servidor+'/datasnap/rest/TServerMethods1/Cargarcuenta/'+Usuario+'/'+Clave+'/'+Nmesa);
     Mensaje := 'Cuenta enviada';
     CargarCuenta()
  except
     Mensaje := 'Error de conexión';
  end;
  showmessage(Mensaje);
end;

procedure TForm2.ButtonComentarClick(Sender: TObject);
// Para insertar un comentario para un item
begin
  Form6 := TForm6.Create(Self);
  Form6.Show;
end;

procedure TForm2.ButtonEditarClick(Sender: TObject);
// Por este boton se abre el cuadro auxiliar para modificar la cantidad de algún item o eliminarlo
begin
  if (GridNuevos.RowCount > 0) and (Gridnuevos.Selected <> -1) and (Nuevos[Gridnuevos.Selected] <> '000001') and (Nuevos[Gridnuevos.Selected] <> '000002') then
  begin
    Form7 := TForm7.Create(Self);
    Form7.Show;
    Form7.Left := (Screen.Width DIV 2)  - 75;
    Form7.Top := (Screen.Height DIV 2);
  end;
end;

procedure TForm2.ButtonEliminarClick(Sender: TObject);
// De haber un error en algún item cargado, con este módulo se borra
var
  i , j : smallint;
begin
  j := Gridnuevos.Selected;
  if (GridNuevos.RowCount > 0) and (j <> -1)  then
  begin
    Nuevos.Delete(j);
    for i := 0 to GridNuevos.RowCount - 1 do
    begin
      if i < (GridNuevos.RowCount - 1) then
      begin
        if i >= j then
        begin
          GridNuevos.Cells[0 , i] := GridNuevos.Cells[0 , i + 1];
          GridNuevos.Cells[1 , i] := GridNuevos.Cells[1 , i + 1];
          GridNuevos.Cells[2 , i] := GridNuevos.Cells[2 , i + 1];
          GridNuevos.Cells[3 , i] := GridNuevos.Cells[3 , i + 1];
        end;
      end;
    end;
    GridNuevos.RowCount := GridNuevos.RowCount - 1;
  end;
end;

procedure TForm2.ButtonEnviarClick(Sender: TObject);
// Al insertar un conjutno de articulos y comentarios, se presiona el botón de enviar para guardar todas las acciones en el servidor y actualizar el estado de la mesa en el sistema local y demás tablas. Además desde aquí se envía la solicitu de impresión de comandas en cocina y bar
var
  Response, vcodigo, vcantidad , vdescripcion, Mensaje : string;
  v : boolean;
  i : smallint;
begin
  vcodigo := '';
  vcantidad := '';
  vdescripcion := '';
  v := false;
  for i := 0 to Nuevos.Count - 1 do
  begin
    v := true;
    vcodigo := vcodigo + '<' + Nuevos[i];
    vcantidad := vcantidad + '<' + GridNuevos.Cells[2 , i];
    vdescripcion := vdescripcion + '<' + GridNuevos.Cells[0 , i];
  end;
  if v then
  begin
    try
       Response := IdHTTP2.Get(servidor+'/datasnap/rest/TServerMethods1/Cargarcomandas/'+Usuario+'/'+Clave+'/'+Nmesa+'/'+vcodigo+'/'+vcantidad+'/'+vdescripcion);
       Mensaje := 'Pedido enviado';
       FormShow(Sender);
    except
       Mensaje := 'Error de conexión';
    end;
    if Mensaje = 'Pedido enviado' then
    begin
      while Nuevos.Count > 0 do
      begin
        GridNuevos.RowCount := GridNuevos.RowCount - 1;
        nuevos.Delete((Nuevos.Count - 1));
      end;
    end;
    Showmessage(Mensaje);
  end;
end;

procedure TForm2.ButtonInsertarClick(Sender: TObject);
//  Para agregar un nuevo item a la cuenta
begin
  Form3 := TForm3.Create(Self);
  Form3.Show;
end;

procedure TForm2.CargarCuenta();
// Este módulo carga la cuenta completa del cliente al servidor con los datos del mismo y envía la solicitud de impresión de factura
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
  GridComandas.RowCount := 0;
  //

  TThread.CreateAnonymousThread(procedure ()
  var
    i : smallint;
  begin
    try
      // Por medio de un hilo secundario se envía la alerta de que la mesa está siendo cerrada
      Response := IdHTTP2.Get(servidor+'/datasnap/rest/TServerMethods1/Listarcomandas/'+Usuario+'/'+Clave+'/'+Nmesa);
      v := true;
    except
      LayoutError.Visible := True;
      FormResize(Self);
    end;
    if v  then
    begin
      // Se actualiza el registro de los items pedidos por la mesa
      ExtractStrings([':'], [], PChar(Response), List);
      if Form1.QuitarSimbolos(List[1]) <> '' then
      begin
        ExtractStrings(['|'], [], PChar(Form1.QuitarSimbolos(List[1])), List2);
        for i := 0 to List2.Count - 1 do
        begin
          ExtractStrings(['<'], [], PChar(List2[i]), List3);
          GridComandas.RowCount := GridComandas.RowCount + 1;
          GridComandas.Cells[0 , i] := List3[0];
          GridComandas.Cells[1 , i] := List3[1];
          GridComandas.Cells[2 , i] := List3[2];
          GridComandas.Cells[3 , i] := List3[3];
          List3.Clear;
        end;
      end;
    end;

    List.Clear;
    List2.Clear;
    List3.Clear;
    // De haber sido llenados, se cargan los datos del cliente para la impresión de la factura
    try
      Response := IdHTTP2.Get(servidor+'/datasnap/rest/TServerMethods1/Listardatos/'+Usuario+'/'+Clave+'/'+Nmesa);
      v := true;
    except
      LayoutError.Visible := True;
      FormResize(Self);
    end;
    if v  then
    begin
      // En caso de no haber completado el formulario, se verifica en el servidor si el registro existe y lo completa en la interfaz
      ExtractStrings([':'], [], PChar(Response), List);
      if Form1.QuitarSimbolos(List[1]) <> '' then
      begin
        ExtractStrings(['|'], [], PChar(Form1.QuitarSimbolos(List[1])), List2);
        EditIdentificacion.Text := RightStr(List2[0],(Length(List2[0]) - 1));
        EditNombre.Text := RightStr(List2[1], (Length(List2[1]) - 1));
        EditTelefono.Text := RightStr(List2[2],(Length(List2[2]) - 1));
        EditDireccion.Text := RightStr(List2[3],(Length(List2[3]) - 1));
        LabelSubtotal.Text := RightStr(List2[4],(Length(List2[4]) - 1));
        LabelServicio.Text := RightStr(List2[5],(Length(List2[5]) - 1));
        LabelTotal.Text := RightStr(List2[6],(Length(List2[6]) - 1));
      end;
      Imagecarga.Visible := False;
      Form2.LayoutContenido.Visible := True;
    end;
    Form2.LayoutContenido.Visible := True;
    Imagecarga.Visible := False;
  end).Start;
end;

procedure TForm2.EditEnter(Sender: TObject);
// Ajuste que se hace para mejorar el uso del teclado de la tableta al cargar los datos para facturar
begin
  if screen.Width > screen.Height then
  begin
    layoutFondo.Height := 200;
  end
  else
  begin
    layoutFondo.Height := 270;
  end;
  ScrollContenido.ScrollBy(0,-2000);
end;

procedure TForm2.EditExit(Sender: TObject);
// Ajuste que se hace para mejorar el uso del teclado de la tableta al cargar los datos para facturar
begin
  layoutFondo.Height := 20;
end;

procedure TForm2.FormResize(Sender: TObject);
// Modifica la interfaz cuando hay un cambio de tamaño de pantalla
begin
  LayoutError.Position.X := (Screen.Width DIV 2) - 100;
  LayoutError.Position.Y := (Screen.Height DIV 2) - 100;
  Imagecarga.Position.X := (Screen.Width DIV 2) - 25;
  Imagecarga.Position.Y := (Screen.Height DIV 2) - 25;

end;

procedure TForm2.FormShow(Sender: TObject);
// Realiza la animación de carga e inicializa la lista temporal para las comandas que están siendo cargaas pero no han sigo confirmadas
begin
  GridNuevos.RowCount := 0;

  if Assigned(Nuevos) then
  begin
    Nuevos.Clear;
  end
  else
  begin
    Nuevos := TStringList.Create;
  end;

  Imagecarga.Visible := true;
  LayoutContenido.Visible := false;
  layoutError.Visible := false;
  Form2.FormResize(Sender);
  LabelMesa.Text := 'Mesa: '+Nmesa;
  CargarCuenta();
end;

end.
