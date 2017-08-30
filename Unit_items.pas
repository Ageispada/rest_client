unit Unit_items;
// Unidad para seleccionar platos y bebidas disponibles del sistema
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, strutils, FMX.ScrollBox, FMX.Memo,
  FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TForm4 = class(TForm)
    ButtonBack: TSpeedButton;
    LabelItems: TLabel;
    IdHTTP4: TIdHTTP;
    Imagecarga: TImage;
    LayoutError: TLayout;
    Label1: TLabel;
    LayoutContenido: TLayout;
    ScrollContenido: TScrollBox;
    ButtonExit: TSpeedButton;
    procedure ButtonBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CargarItems();
    procedure ButtonItem(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure SpeedInsertarClick(Sender: TObject);
    procedure NumberBoxEnter(Sender: TObject);
    procedure NumberBoxExit(Sender: TObject);
    procedure NumberBoxChange(Sender: TObject);
    procedure NumberBoxKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  Grupo : String;
  Buscar : String;
  Codigo: String;

implementation

{$R *.fmx}

uses
  unit_cuenta , unit_index ,  unit_grupos;

procedure TForm4.ButtonBackClick(Sender: TObject);
// Cierra la ventana y regresa a las categorías
begin
  Self.Close;
end;

procedure TForm4.ButtonExitClick(Sender: TObject);
// Para cerrar la ventana de platos y la de categorías
begin
  Form3.Close;
  Self.Close;
end;

procedure TForm4.ButtonItem(Sender: TObject);
// Al seleccionar un item, se amplia para `más información y opciones
begin
  Self.Show;
end;

procedure TForm4.CargarItems;
// Este módulo crea dinámicamenteel selector
var
  Response : String;
  v : boolean;
  List : TStrings;
  List2 : TStrings;
  List3 : TStrings;
  Registro : TStrings;
  Item : TSpeedButton;
  Layout : Trectangle;
  Text : Tlabel;
  Precio : Tlabel;
  Total : Tlabel;
  Cantidad : TNumberBox;
  Insertar : TSpeedButton;
  Pvp : Tlabel;
  Cod : Tlabel;
begin
  ScrollContenido.Content.DeleteChildren;
  Imagecarga.Visible := True;
  v := false;
  // Listas auxiliares para descomposición de la respuesta
  List := TStringList.Create;
  List2 := TStringList.Create;
  List3 := TStringList.Create;
  TThread.CreateAnonymousThread(procedure ()
  var
    i : smallint;
  begin
    try
      // Se envía la petición al servidor de listar platos por grupo o texto de búsqueda
      Response := IdHTTP4.Get(servidor+'/datasnap/rest/TServerMethods1/Listaritems/'+Usuario+'/'+Clave+'/'+Codigo+'/'+Buscar);
      v := true;
    except
      LayoutError.Visible := True;
      FormResize(Self);
    end;
    if v  then
    begin
      Cargado := True;
      ExtractStrings([':'], [], PChar(Response), List);
      if Form1.QuitarSimbolos(List[1]) <> '' then
      begin
        ExtractStrings(['|'], [], PChar(Form1.QuitarSimbolos(List[1])), List2);
        for i := 0 to List2.Count - 1 do
        begin
          try
            ExtractStrings(['<'], [], PChar(List2[i]), List3);
            if (RightStr(List3[0],(Length(List3[0]) - 1)) <> '') and (RightStr(List3[1],(Length(List3[1]) - 1)) <> '') and (RightStr(List3[2],(Length(List3[2]) - 1)) <> '') then
            begin
              // e crean los bojetos de cada opción e la lista
              Layout := trectangle.Create(self);
              Text := tlabel.Create(self);
              Precio := tlabel.Create(self);
              Total := tlabel.Create(self);
              Pvp := tlabel.Create(self);
              Cod := tlabel.Create(self);
              Cantidad := tnumberbox.Create(self);
              Insertar := tspeedbutton.Create(self);
              // La lista de opciones se carga dentro de un scrolñ
              Layout.Parent := ScrollContenido;
              Layout.Align := TAlignLayout.Top;
              Layout.Height := 70;
              Layout.TabOrder := i + 1;
              // Se inserta la infrmación recibida de cada plato
              Pvp.Parent := Layout;
              Pvp.Text := RightStr(List3[2],(Length(List3[2]) - 1));
              Pvp.Name := 'Pvp'+inttostr(i);
              Pvp.Visible := False;

              Cod.Parent := Layout;
              Cod.Text := RightStr(List3[0],(Length(List3[0]) - 1));
              Cod.Name := 'Cod'+inttostr(i);
              Cod.Visible := False;

              Text.Parent := Layout;
              Text.Text := RightStr(List3[1],(Length(List3[1]) - 1));
              Text.Align := TAlignLayout.Top;
              Text.Margins.Left := 20;
              Text.Name := 'Text'+inttostr(i);

              Precio.Parent := Layout;
              Precio.Text := 'Bs: ' + RightStr(List3[2],(Length(List3[2]) - 1));
              Precio.Position.X := 20;
              Precio.Position.Y := 40;
              Precio.Name := 'Precio'+inttostr(i);

              Cantidad.Parent := Layout;
              Cantidad.Width := 40;
              Cantidad.Position.X := 130;
              Cantidad.Position.Y := 35;
              Cantidad.Text := '1';
              Cantidad.Name := 'Cantidad'+inttostr(i);
              Cantidad.OnClick := NumberBoxEnter;
              Cantidad.OnExit := NumberBoxExit;
              Cantidad.OnKeyUp := NumberBoxKeyDown;

              Total.Parent := Layout;
              Total.Text := 'Bs: ' + RightStr(List3[2],(Length(List3[2]) - 1));
              Total.Position.X := 180;
              Total.Position.Y := 40;
              Total.Name := 'Total'+inttostr(i);

              //Se agrega el comportamiento para el botón de agregar item
              Insertar.Parent := Layout;
              Insertar.StyleLookup := 'nexttoolbutton';
              Insertar.Align := TAlignLayout.Right;
              Insertar.Name := 'Insertar'+inttostr(i);
              Insertar.OnClick := SpeedInsertarClick;
            end;
          except
          end;
          List3.Clear;
        end;
      end;
      Imagecarga.Visible := False;
      Form4.LayoutContenido.Visible := True;
    end;
    Imagecarga.Visible := False;
  end).Start;
end;



procedure TForm4.FormResize(Sender: TObject);
// Modifica la interfaz al haber un cambio de tamaño de pantalla
begin
  LayoutError.Position.X := (Screen.Width DIV 2) - 100;
  LayoutError.Position.Y := (Screen.Height DIV 2) - 100;
  Imagecarga.Position.X := (Screen.Width DIV 2) - 25;
  Imagecarga.Position.Y := (Screen.Height DIV 2) - 25;
  ButtonExit.Position.X := Screen.Width  - 48;
end;

procedure TForm4.FormShow(Sender: TObject);
// Al hacer la carga presenta la animación y envía la consulta al servidor
begin
  LabelItems.Text := Grupo;
  Imagecarga.Visible := true;
  LayoutContenido.Visible := false;
  layoutError.Visible := false;
  Form4.FormResize(Sender);
  CargarItems();
end;

procedure TForm4.NumberBoxExit(Sender: TObject);
// En el selector de cantidad si se definión 0 o vacío, reinicia el valor mínimo que es 1
var
  i:String;
begin
  if (TNumberBox(Sender).Text = '0')  or (TNumberBox(Sender).Text = '')then
  begin
    TNumberBox(Sender).Text := '1';
    i := Copy(TSpeedButton(Sender).Name, 9, length(TSpeedButton(Sender).Name));
    (FindComponent('Cantidad'+i) as Tnumberbox).Text := '1';
    (FindComponent('Total'+i) as Tlabel).Text := 'Bs: '+(FindComponent('Pvp'+i) as Tlabel).Text;
  end;
end;

procedure TForm4.NumberBoxKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
  // Al cambiar la cantidad de items seleccionados, actualiza el subtotal mostrado
var
  i : String;
  pvp : Tlabel;
  total : Tlabel;
  cantidad : Tnumberbox;
begin
  NumberBoxChange(Sender);
  if cantidad.Text = '' then
  begin
    total.Text := 'Bs: 0';
  end
  else
  begin
    total.Text := 'Bs: '+floattostr(strtofloat(pvp.text) * strtofloat(cantidad.text));
  end;
end;

procedure TForm4.NumberBoxChange(Sender: TObject);
// Actualiza el subtotal mostrado y disponibilidad según modifique la cantidad seleccionada
var
  i : String;
  pvp : Tlabel;
  total : Tlabel;
  cantidad : Tnumberbox;
begin
  i := Copy(TSpeedButton(Sender).Name, 9, length(TSpeedButton(Sender).Name));
  total :=  FindComponent('Total'+i) as Tlabel;
  pvp :=  FindComponent('Pvp'+i) as Tlabel;
  cantidad :=  FindComponent('Cantidad'+i) as Tnumberbox;
  total.Text := floattostr(strtofloat(pvp.text) * strtofloat(cantidad.text));
end;

procedure TForm4.NumberBoxEnter(Sender: TObject);
// Al ingresar a cuadro de selección de cantidades lo inicializa en 0
var
  i : String;
begin
  TNumberBox(Sender).Text := '0';
  TNumberBox(Sender).SelStart := length(TNumberBox(Sender).text);
  i := Copy(TSpeedButton(Sender).Name, 9, length(TSpeedButton(Sender).Name));
  (FindComponent('Cantidad'+i) as Tnumberbox).Text := '0';
  (FindComponent('Total'+i) as Tlabel).Text := 'Bs: 0';
end;

procedure TForm4.SpeedInsertarClick(Sender: TObject);
// Al cargar el producto, es enviado al módulo de cuenta
var
  i : String;
  j : smallint;
  c : String;
begin
  i := Copy(TSpeedButton(Sender).Name, 9, length(TSpeedButton(Sender).Name));
  j := Nuevos.IndexOf((FindComponent('Cod'+i) as Tlabel).Text);
  c := (FindComponent('Cantidad'+i) as TnumberBox).Text;
  if (c <> '') and (strtoint(c) > 0) then
  begin
    if j = -1 then
    begin
      j := Form2.GridNuevos.RowCount;
      Form2.GridNuevos.RowCount := Form2.GridNuevos.RowCount + 1;
      Nuevos.Add((FindComponent('Cod'+i) as Tlabel).Text);
      Form2.GridNuevos.Cells[0 , j] := (FindComponent('Text'+i) as Tlabel).Text;
      Form2.GridNuevos.Cells[1 , j] := (FindComponent('Pvp'+i) as Tlabel).Text;
      Form2.GridNuevos.Cells[2 , j] := floattostr(strtofloat((FindComponent('Cantidad'+i) as tnumberbox).Text));
      Form2.GridNuevos.Cells[3 , j] := floattostr(strtofloat((FindComponent('Cantidad'+i) as tnumberbox).Text) * strtofloat((FindComponent('Pvp'+i) as Tlabel).Text));
    end
    else
    begin
      Form2.GridNuevos.Cells[2 , j] := floattostr(strtofloat((FindComponent('Cantidad'+i) as tnumberbox).Text) + strtofloat(Form2.GridNuevos.Cells[2 , j]));
      Form2.GridNuevos.Cells[3 , j] := floattostr((strtofloat((FindComponent('Cantidad'+i) as tnumberbox).Text) * strtofloat((FindComponent('Pvp'+i) as Tlabel).Text)) + strtofloat(Form2.GridNuevos.Cells[3 , j]));
    end;
    showmessage('Pedido cargado');
  end;
end;

end.
