unit Unit_grupos;
// Los platos y bebidas se pueden agrupar porcategorías para na búsqueda manual o listar los items por un buscador
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FMX.ScrollBox, strutils, FMX.Memo,
  FMX.Edit;

type
  TForm3 = class(TForm)
    ButtonBack: TSpeedButton;
    LabelMesa: TLabel;
    IdHTTP3: TIdHTTP;
    Imagecarga: TImage;
    LayoutError: TLayout;
    Label1: TLabel;
    LayoutContenido: TLayout;
    ScrollContenido: TScrollBox;
    Layout1: TLayout;
    EditBuscar: TEdit;
    ButtonBuscar: TSpeedButton;
    EditBorrar: TSpeedButton;
    procedure ButtonBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CargarGrupos();
    procedure ButtonItem(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonBuscarClick(Sender: TObject);
    procedure EditBorrarClick(Sender: TObject);
  private
    Gr : TStrings;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  Cargado : boolean;


implementation

{$R *.fmx}

uses
  unit_cuenta , unit_index , unit_items;

procedure TForm3.ButtonBackClick(Sender: TObject);
//Paa cerrar esta ventana
begin
  Self.Close;
end;

procedure TForm3.ButtonBuscarClick(Sender: TObject);
// Al usar el buscador, abre el formulario de platos con los items filtrados por el texto ingresado
begin
  Grupo := 'Platos';
  Buscar := EditBuscar.Text;
  Codigo := '';
  Form4 := TForm4.Create(Self);
  Form4.Show;
end;

procedure TForm3.ButtonItem(Sender: TObject);
// De seleccionar un grupo abre el formulario de items filtrado por el grupo seleccionado, usando la variable codigo
begin
  Grupo := TSpeedButton(Sender).Text;
  Buscar := '';
  Codigo := Gr[TSpeedButton(Sender).Tag];
  Form4 := TForm4.Create(Self);
  Form4.Show;
end;

procedure TForm3.CargarGrupos;
// Este módulo consulta la información de las categorías
var
  Response : String;
  v : boolean;
  List : TStrings;
  List2 : TStrings;
  List3 : TStrings;
  Registro : TStrings;
  Item : TSpeedButton;
begin
  if Assigned(Gr) then
  begin
    Gr.Clear;
  end;
  Gr := TStringList.Create;
  ScrollContenido.Content.DeleteChildren;
  Imagecarga.Visible := True;
  v := false;
  List := TStringList.Create;
  List2 := TStringList.Create;
  List3 := TStringList.Create;
  TThread.CreateAnonymousThread(procedure ()
  var
    i : smallint;
  begin
    try
      Response := IdHTTP3.Get(servidor+'/datasnap/rest/TServerMethods1/Listargrupos/'+Usuario+'/'+Clave);
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
          ExtractStrings(['<'], [], PChar(List2[i]), List3);
          Item := tspeedbutton.Create(nil);
          with Item do
          begin
            align := TAlignLayout.Top;
            parent := Form3.ScrollContenido;
            text := RightStr(List3[1],(Length(List3[1]) - 1));
            tag := i;
            if Length(RightStr(List3[0],(Length(List3[0]) - 1))) > 2 then
            begin
              StyleLookup := 'listitembutton';
            end
            else
            begin
              StyleLookup := 'segmentedbuttonleft';
            end;
            if RightStr(List3[2],(Length(List3[2]) - 1)) = 'false' then
            begin
              Enabled := False;
            end;
            Gr.Add( RightStr(List3[0],(Length(List3[0]) - 1)));
            Item.OnClick:= ButtonItem;
          end;
          List3.Clear;
        end;
      end;
      Imagecarga.Visible := False;
      Form3.LayoutContenido.Visible := True;
    end;
    Imagecarga.Visible := False;
  end).Start;
end;

procedure TForm3.EditBorrarClick(Sender: TObject);
// Borra el contenido del bucador
begin
  EditBuscar.Text := '';
  EditBuscar.SetFocus;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Cargado := false;
end;

procedure TForm3.FormResize(Sender: TObject);
// modifica la interfaz al haber un cambio de tamaño de pantalla
begin
  LayoutError.Position.X := (Screen.Width DIV 2) - 100;
  LayoutError.Position.Y := (Screen.Height DIV 2) - 100;
  Imagecarga.Position.X := (Screen.Width DIV 2) - 25;
  Imagecarga.Position.Y := (Screen.Height DIV 2) - 25;
end;

procedure TForm3.FormShow(Sender: TObject);
// Si no se han cargado los grupos, presenta la animación de carga y hace la consulta
begin
  Form3.FormResize(Sender);
  if not Cargado then
  begin
    Imagecarga.Visible := true;
    LayoutContenido.Visible := false;
    layoutError.Visible := false;
    CargarGrupos();
  end;
end;

end.


