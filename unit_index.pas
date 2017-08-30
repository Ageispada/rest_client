unit unit_index;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo, FMX.StdCtrls, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.ScrollBox, FMX.Controls.Presentation,
  IPPeerClient, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, IdHTTP,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient ,  JSON,
  IdAuthentication, FMX.Edit, FMX.Objects;

type
  TForm1 = class(TForm)
    IdHTTP1: TIdHTTP;
    LayoutError: TLayout;
    Label1: TLabel;
    LayoutLogin: TLayout;
    Label3: TLabel;
    Label4: TLabel;
    Editusuario: TEdit;
    Editclave: TEdit;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    Imagecarga: TImage;
    Labelerror: TLabel;
    LayoutContenido: TLayout;
    MemoRequest: TMemo;
    Label5: TLabel;
    ScrollContenido: TScrollBox;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    function QuitarSimbolos(c : String): String ;
    procedure ActualizarMesas(b : boolean);
    procedure DibujarMesas(Lista : String);
    procedure DibujarMesas2(Lista : String);
    procedure Servicio;
    procedure ButtonMesa(Sender: TObject);
    private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Left : Integer;
  Top : Integer;
  Usuario : String;
  Clave : String;
  Servidor : String;


implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

uses
  unit_cuenta;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Usuario := '';
  Clave := '';
  Servidor := 'http://192.168.0.102:8080';
end;

procedure TForm1.FormResize(Sender: TObject);
//Ajusta la posición de los elementos de la pantalla cuando hay un cambio de tamaño en el dispositivo
begin
  LayoutError.Position.X := (Screen.Width DIV 2) - 100;
  LayoutError.Position.Y := (Screen.Height DIV 2) - 100;
  LayoutLogin.Position.X := (Screen.Width DIV 2) - 200;
  LayoutLogin.Position.Y := 0;
  Imagecarga.Position.X := (Screen.Width DIV 2) - 25;
  Imagecarga.Position.Y := (Screen.Height DIV 2) - 25;
  if MemoRequest.Text <> '' then
  begin
    DibujarMesas(MemoRequest.Text);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  Response : String;
  v : boolean;
begin
  //Se presenta el ícono de carga al abrir el programa
  Imagecarga.Visible := True;
  v := false;
  TThread.CreateAnonymousThread(procedure ()
  begin
    Sleep(1000);
    //Habilita un hilo secundario para la conexión http
    TThread.Synchronize (TThread.CurrentThread,
    procedure ()
    begin
      //Si el usuario no se ha validado previamente
      if(Usuario = '') AND (Clave = '') then
      begin
        // Verifica que exita un servidor activo
        try
          Response := IdHTTP1.Get(servidor+'/datasnap/rest/DSAdmin/GetPlatformName');
          v := true;
        except
          //Muestra un error si no encuentra la conexión
          LayoutError.Visible := True;
          FormResize(Sender);
        end;
        if v then
        begin
          // Muestra el formulario de inicio para abrir el sistema en caso de encontrar el servidor
          LayoutLogin.Visible := True;
          Labelerror.Visible := False;
          FormResize(Sender);
        end;
        Imagecarga.Visible := False;
      end
      else
      begin
        //Sino dibuja el diagrama e las mesas con el ícono de carga
          Form1.ActualizarMesas(true);
      end;
    end);
  end).Start;
end;

function TForm1.QuitarSimbolos(c : String) : String ;
//Elimina caracteres especiales desde el servidor
var
  i : Smallint;
  s : String;
begin
  s := '';
  for i := 1 to length(c) do
  begin
    if (c[i] <> '"') AND (c[i] <> chr(39)) AND (c[i] <> '{') AND (c[i] <> '}') AND (c[i] <> '[') AND (c[i] <> ']') then
    begin
     s := s+c[i];
    end;
  end;
  result := s;
end;

procedure TForm1.ActualizarMesas(b : boolean);
// Este método actualiza de forma iterativa el estado de las mesas
var
  Response : String;
  v : boolean;
  List : TStrings;
begin
  // Según se envíe por el parámetro b, se presenta el íucono de carga o no
  if b then
  begin
    Imagecarga.Visible := True;
  end;
  v := false;
  List := TStringList.Create;
  TThread.CreateAnonymousThread(procedure ()
  begin
    // Se solicita la información de las mesas al servidor
    try
      Response := IdHTTP1.Get(servidor+'/datasnap/rest/TServerMethods1/Listarmesas/'+Usuario+'/'+Clave);
      v := true;
    except
      LayoutError.Visible := True;
      FormResize(Self);
    end;
    if v  then
    begin
      ExtractStrings([':'], [], PChar(Response), List);
      MemoRequest.Text := QuitarSimbolos(List[1]);

      if MemoRequest.Text = '' then
      // De no haber respuesta, se presenta el error de desconexión
      begin
        Form1.LayoutContenido.Visible := False;
        Form1.LayoutLogin.Visible := True;
        Form1.Labelerror.Visible := True;
      end
      else
      begin
        TThread.Synchronize (TThread.CurrentThread,
        procedure ()
        begin
          // Si es una actualización, por medio de DibujarMesas2 se actualiza su estado
          Imagecarga.Visible := False;
          LayoutError.Visible := False;
          if b then
          begin
            Form1.DibujarMesas2(MemoRequest.Text);
          end;
        end);
      end;
    end;
    Imagecarga.Visible := False;
  end).Start;
end;


procedure TForm1.DibujarMesas2(Lista: String);
// Esta función actualiza las funciones y colores de las mesas, es importante para mantener informado al mesero del estado de todos los consumidores del negocio
var
  List : TStrings;
  Estado : TStrings;
  i , j : smallint;
begin
    List := TStringList.Create;
    ExtractStrings([' '], [], PChar(Lista), List);
    for i := 0 to List.Count - 1 do
    begin
      Estado := TStringList.Create;
      ExtractStrings(['\'], [], PChar(List[i]), Estado);

      for j := 0 to ComponentCount - 1 do
      begin
        if Components[j] is TSpeedButton then
        begin
          if TSpeedButton(Components[j]).Text = Estado[0] then
          begin
            if Estado[1] = '/x' then
            begin
               TSpeedButton(Components[j]).TintColor := TAlphaColorRec.White;
            end
            else
            begin
               TSpeedButton(Components[j]).TintColor := TAlphaColorRec.Gray;
            end;
          end;
        end;
      end;
      Estado.Free;
    end;
end;


procedure TForm1.DibujarMesas(Lista: String);
// Dibuja dinámicamente el plano de las mesas y le asigna sus funciones
var
  Mesa : TSpeedButton;
  List : TStrings;
  Estado : TStrings;
  i  : smallint;
  x : integer;
  y : integer;
begin
  ScrollContenido.Content.DeleteChildren;
  x := 5;
  y := 20;
  List := TStringList.Create;
  ExtractStrings([' '], [], PChar(Lista), List);
  for i := 0 to List.Count - 1 do
  begin
    Estado := TStringList.Create;
    ExtractStrings(['\'], [], PChar(List[i]), Estado);
    Mesa := tspeedbutton.Create(self);
    with Mesa do
    begin
      position.X := x;
      position.Y := y;
      parent := Form1.ScrollContenido;
      width := 100;
      text := Estado[0];
      StyleLookup := 'cornerbuttonstyle';

      if Estado[1] = '/x' then
      begin
        TintColor := TAlphaColorRec.White;
      end
      else
      begin
        TintColor := TAlphaColorRec.Gray;
      end;
      Mesa.OnClick:= ButtonMesa;
    end;
    Estado.Free;
    if (x + 240) > Screen.Width then
    begin
      x := 5;
      y := y + 80;
    end
    else
    begin
      x := x + 140;
    end;
  end;
  Servicio();
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
// Acciçon de login en el sistema
begin
  Usuario := Editusuario.Text;
  Clave := Editclave.Text;
  LayoutLogin.Visible := False;
  FormShow(Sender);
end;

procedure TForm1.Servicio();
// Iterativamente actuializa el estado de la mesa por medio de un hilo secundario
begin
  TThread.CreateAnonymousThread(procedure ()
  begin
    while true do
    begin
      Sleep(20000);
      TThread.Synchronize (TThread.CurrentThread,
      procedure ()
      begin
        Form1.ActualizarMesas(False);
      end);
    end;
  end).Start;
end;

procedure TForm1.ButtonMesa(Sender: TObject);
// Abre el formulario de cuenta al presionar sobre una mesa
begin
  Nmesa := TSpeedButton(Sender).Text;
  Form2 := TForm2.Create(Self);
  Form2.Show;
end;

end.
