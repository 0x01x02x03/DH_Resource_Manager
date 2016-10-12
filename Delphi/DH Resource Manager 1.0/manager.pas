// DH Resource Manager 0.5
// (C) Doddy Hackman 2016

unit manager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Menus, Vcl.Styles.Utils.ComCtrls, Vcl.Styles.Utils.Menus,
  Vcl.Styles.Utils.SysStyleHook,
  Vcl.Styles.Utils.SysControls, Vcl.Styles.Utils.Forms,
  Vcl.Styles.Utils.StdCtrls, Vcl.Styles.Utils.ScreenTips, DH_Resources,
  ShellApi, Math, Vcl.ImgList, Vcl.Imaging.pngimage;

type
  TFormHome = class(TForm)
    imgLogo: TImage;
    status: TStatusBar;
    gbEnterFilename: TGroupBox;
    txtFilename: TEdit;
    btnLoad: TButton;
    btnScan: TButton;
    gbResources: TGroupBox;
    lvResources: TListView;
    ppOpciones: TPopupMenu;
    ItemAddResource: TMenuItem;
    ItemEditResource: TMenuItem;
    ItemDeleteResource: TMenuItem;
    ItemRefreshList: TMenuItem;
    ItemAddFile: TMenuItem;
    ItemAddDirectory: TMenuItem;
    ItemDeleteFile: TMenuItem;
    ItemDeleteDirectory: TMenuItem;
    ItemGenerateRC: TMenuItem;
    ItemSaveResource: TMenuItem;
    ilIconos: TImageList;
    ItemGenerate_RC_File: TMenuItem;
    ItemGenerate_RC_Directory: TMenuItem;
    procedure btnLoadClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ItemAddFileClick(Sender: TObject);
    procedure ItemEditResourceClick(Sender: TObject);
    procedure ItemDeleteFileClick(Sender: TObject);
    procedure ItemRefreshListClick(Sender: TObject);
    procedure ItemSaveResourceClick(Sender: TObject);
    procedure ItemAddDirectoryClick(Sender: TObject);
    procedure ItemDeleteDirectoryClick(Sender: TObject);
    procedure ItemGenerate_RC_DirectoryClick(Sender: TObject);
    procedure ItemGenerate_RC_FileClick(Sender: TObject);
  private
    { Private declarations }
    procedure DragDropFile(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
    archivos_encontrados: string;
    function open_dialog(title, filter: string; filter_index: integer): string;
    function save_dialog(title, filter, default_ext: string;
      filter_index: integer): string;
    function listar(): boolean;
    procedure buscar_archivos(directory: string);
    function listar_directorio_para_rc(directory: string; savefile_name: string;
      id: string): boolean;
    function listar_directorio_para_recursos(directory: string;
      id: string): boolean;
    function borrar_recursos_por_id(id: integer): boolean;

  end;

var
  FormHome: TFormHome;

implementation

{$R *.dfm}
// Functions

function message_box(title, message_text, type_message: string): string;
begin
  if not(title = '') and not(message_text = '') and not(type_message = '') then
  begin
    try
      begin
        if (type_message = 'Information') then
        begin
          MessageBox(FormHome.Handle, PChar(message_text), PChar(title),
            MB_ICONINFORMATION);
        end
        else if (type_message = 'Warning') then
        begin
          MessageBox(FormHome.Handle, PChar(message_text), PChar(title),
            MB_ICONWARNING);
        end
        else if (type_message = 'Question') then
        begin
          MessageBox(FormHome.Handle, PChar(message_text), PChar(title),
            MB_ICONQUESTION);
        end
        else if (type_message = 'Error') then
        begin
          MessageBox(FormHome.Handle, PChar(message_text), PChar(title),
            MB_ICONERROR);
        end
        else
        begin
          MessageBox(FormHome.Handle, PChar(message_text), PChar(title),
            MB_ICONINFORMATION);
        end;
        Result := '[+] MessageBox : OK';
      end;
    except
      begin
        Result := '[-] Error';
      end;
    end;
  end
  else
  begin
    Result := '[-] Error';
  end;
end;

function TFormHome.open_dialog(title, filter: string;
  filter_index: integer): string;
var
  odOpenFile: TOpenDialog;
  filename: string;
begin
  odOpenFile := TOpenDialog.Create(Self);
  odOpenFile.title := title;
  odOpenFile.InitialDir := GetCurrentDir;
  odOpenFile.Options := [ofFileMustExist];
  odOpenFile.filter := filter;
  odOpenFile.FilterIndex := filter_index;
  if odOpenFile.Execute then
  begin
    filename := odOpenFile.filename;
  end;
  odOpenFile.Free;
  Result := filename;
end;

function TFormHome.save_dialog(title, filter, default_ext: string;
  filter_index: integer): string;
var
  sdSaveFile: TSaveDialog;
  filename: string;
begin
  sdSaveFile := TSaveDialog.Create(Self);
  sdSaveFile.title := title;
  sdSaveFile.InitialDir := GetCurrentDir;
  sdSaveFile.filter := filter;
  sdSaveFile.DefaultExt := default_ext;
  sdSaveFile.FilterIndex := filter_index;
  if sdSaveFile.Execute then
  begin
    filename := sdSaveFile.filename;
  end;
  sdSaveFile.Free;
  Result := filename;
end;

// Function to DragDrop

// Based in : http://www.clubdelphi.com/foros/showthread.php?t=85665
// Thanks to ecfisa

var
  bypass_window: function(Msg: Cardinal; dwFlag: Word): BOOL; stdcall;

procedure TFormHome.DragDropFile(var Msg: TMessage);
var
  nombre_archivo, extension: string;
  limite, number: integer;
  path: array [0 .. MAX_COMPUTERNAME_LENGTH + MAX_PATH] of char;
begin
  limite := DragQueryFile(Msg.WParam, $FFFFFFFF, path, 255) - 1;
  if (Win32MajorVersion = 6) and (Win32MinorVersion > 0) then
    for number := 0 to limite do
    begin
      bypass_window(number, 1);
    end;
  for number := 0 to limite do
  begin
    DragQueryFile(Msg.WParam, number, path, 255);

    //

    if (FileExists(path)) then
    begin
      lvResources.Items.Clear;
      nombre_archivo := ExtractFilename(path);
      extension := ExtractFileExt(path);
      extension := StringReplace(extension, '.', '',
        [rfReplaceAll, rfIgnoreCase]);
      if (extension = 'exe') or (extension = 'dll') then
      begin
        txtFilename.Text := path;
        message_box('DH Resource Manager 0.5', 'File loaded', 'Information');
      end
      else
      begin
        message_box('DH Resource Manager 0.5', 'Format not valid', 'Warning');
      end;
    end;

    //

  end;
  DragFinish(Msg.WParam);
end;

procedure TFormHome.FormCreate(Sender: TObject);
begin

  if (Win32MajorVersion = 6) and (Win32MinorVersion > 0) then
  begin
    @bypass_window := GetProcAddress(LoadLibrary('user32.dll'),
      'ChangeWindowMessageFilter');
    bypass_window(WM_DROPFILES, 1);
    bypass_window(WM_COPYDATA, 1);
    bypass_window($0049, 1);
  end;
  DragAcceptFiles(Handle, True);

  UseLatestCommonDialogs := False;
end;

function regex(Text: String; deaca: String; hastaaca: String): String;
begin
  Delete(Text, 1, AnsiPos(deaca, Text) + Length(deaca) - 1);
  SetLength(Text, AnsiPos(hastaaca, Text) - 1);
  Result := Text;
end;

function savefile(archivo, texto: string): BOOL;
var
  open_file: TextFile;
begin
  try
    begin
      AssignFile(open_file, archivo);
      FileMode := fmOpenWrite;

      if FileExists(archivo) then
      begin
        Append(open_file);
      end
      else
      begin
        Rewrite(open_file);
      end;

      Write(open_file, texto);
      CloseFile(open_file);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function execute_command(command: string): string;
// Credits : Function ejecutar() based in : http://www.delphidabbler.com/tips/61
// Thanks to www.delphidabbler.com

var
  SecurityAttributes: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInformation: TProcessInformation;
  Handle1: THandle;
  Handle2: THandle;
  check: boolean;
  output: array [0 .. 255] of AnsiChar;
  check2: Cardinal;
  check3: boolean;
  code: string;

begin
  if not(command = '') then
  begin
    try
      begin
        code := '';

        with SecurityAttributes do
        begin
          nLength := SizeOf(SecurityAttributes);
          bInheritHandle := True;
          lpSecurityDescriptor := nil;
        end;

        CreatePipe(Handle1, Handle2, @SecurityAttributes, 0);

        with StartupInfo do
        begin
          FillChar(StartupInfo, SizeOf(StartupInfo), 0);
          cb := SizeOf(StartupInfo);
          dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
          wShowWindow := SW_HIDE;
          hStdInput := GetStdHandle(STD_INPUT_HANDLE);
          hStdOutput := Handle2;
          hStdError := Handle2;
        end;

        check3 := CreateProcess(nil, PChar('cmd.exe /C ' + command), nil, nil,
          True, 0, nil, PChar('c:/'), StartupInfo, ProcessInformation);

        CloseHandle(Handle2);

        if check3 then

          repeat

          begin
            check := ReadFile(Handle1, output, 255, check2, nil);
          end;

          if check2 > 0 then
          begin
            output[check2] := #0;
            code := code + output;
          end;

          until not(check) or (check2 = 0);

        Result := '[+] Console : OK' + sLineBreak + code;
      end;
    except
      begin
        Result := '[-] Console : ERROR';
      end;
    end;
  end
  else
  begin
    Result := '[-] Console : ERROR';
  end;
end;

function dh_generate_string(option: string; length_string: integer): string;
const
  letters1: array [1 .. 26] of string = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
    'x', 'y', 'z');
const
  letters2: array [1 .. 26] of string = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z');
const
  numbers: array [1 .. 10] of string = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9');

const
  cyrillic: array [1 .. 44] of string = ('А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ж', 'Ѕ',
    'З', 'И', 'І', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'Ѹ', 'Ф', 'Х',
    'Ѡ', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Ѣ', 'Ю', 'Ꙗ', 'Ѥ', 'Ѧ', 'Ѩ', 'Ѫ',
    'Ѭ', 'Ѯ', 'Ѱ', 'Ѳ', 'Ѵ', 'Ҁ');

const
  no_idea1: array [1 .. 13] of string = ('๏', '๐', '๑', '๒', '๓', '๔', '๕', '๖',
    '๗', '๘', '๙', '๚', '๛');

const
  no_idea2: array [1 .. 28] of string = ('ﷲ', 'ﺀ', 'ﺁ', 'ﺂ', 'ﺃ', 'ﺄ', 'ﺅ', 'ﺆ',
    'ﺇ', 'ﺈ', 'ﺉ', 'ﺊ', 'ﺋ', 'ﺌ', 'ﺍ', 'ﺎ', 'ﺏﺐ', 'ﺑ', 'ﺒ', 'ﺓ', 'ﺔ', 'ﺕ', 'ﺖ',
    'ﺗ', 'ﺘ', 'ﺙ', 'ﺚ', 'ﺛﺜ');

const
  no_idea3: array [1 .. 13] of string = ('٥٦', '٧', '٨', '٩', 'ﾎ', '么', 'ﾒ',
    '_', 'ｬ', '`', 'ｦ', '_', 'ｶ');

const
  no_idea4: array [1 .. 26] of string = ('₪', '₫', '€', '℅', 'l', '№', '™', 'Ω',
    'e', '⅛', '⅜', '⅝', '⅞', '∂', '∆', '∏', '∑', '-', '/', '·', 'v', '8', '∫',
    '˜', '≠', '=');

const
  no_idea5: array [1 .. 33] of string = ('∃', '∧', '∠', '∨', '∩', '⊂', '⊃', '∪',
    '⊥', '∀', 'Ξ', 'Γ', 'ɐ', 'ə', 'ɘ', 'ε', 'β', 'ɟ', 'ɥ', 'ɯ', 'ɔ', 'и', '๏',
    'ɹ', 'ʁ', 'я', 'ʌ', 'ʍ', 'λ', 'ч', '∞', 'Σ', 'Π');

const
  no_idea6: array [1 .. 32] of string = ('ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح',
    'خ', 'د', 'ذ', 'ر', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
    'ق', 'ک', 'گ', 'ل', 'م', 'ن', 'و', 'ه', 'ی');
var
  code: string;
  gen_now: string;
  i: integer;
  index: integer;
begin

  gen_now := '';

  for i := 1 to length_string do
  begin
    if (option = '1') then
    begin
      gen_now := gen_now + letters1[RandomRange(1, Length(letters1) + 1)];
    end
    else if (option = '2') then
    begin
      gen_now := gen_now + letters2[RandomRange(1, Length(letters2) + 1)];
    end
    else if (option = '3') then
    begin
      gen_now := gen_now + numbers[RandomRange(1, Length(numbers) + 1)];
    end
    else if (option = '4') then
    begin
      gen_now := gen_now + cyrillic[RandomRange(1, Length(cyrillic) + 1)];
    end
    else if (option = '5') then
    begin
      gen_now := gen_now + no_idea1[RandomRange(1, Length(no_idea1) + 1)];
    end
    else if (option = '6') then
    begin
      gen_now := gen_now + no_idea2[RandomRange(1, Length(no_idea2) + 1)];
    end
    else if (option = '7') then
    begin
      gen_now := gen_now + no_idea3[RandomRange(1, Length(no_idea3) + 1)];
    end
    else if (option = '8') then
    begin
      gen_now := gen_now + no_idea4[RandomRange(1, Length(no_idea4) + 1)];
    end
    else if (option = '9') then
    begin
      gen_now := gen_now + no_idea5[RandomRange(1, Length(no_idea5) + 1)];
    end
    else if (option = '10') then
    begin
      gen_now := gen_now + no_idea6[RandomRange(1, Length(no_idea6) + 1)];
    end
    else
    begin
      gen_now := gen_now + letters1[RandomRange(1, Length(letters1) + 1)];
    end;
  end;
  code := gen_now;

  Result := code;
end;

//

function TFormHome.listar(): boolean;
var
  resources: T_DH_Resources;
  resources_list_string: string;
  resource_list: TStringList;
  i: integer;
  resource_line: string;
  name_resource: string;
  type_resource: string;
begin

  if (FileExists(txtFilename.Text)) then
  begin
    lvResources.Items.Clear;
    resources := T_DH_Resources.Create();
    resources_list_string := resources.list_all_resources(txtFilename.Text);

    resource_list := TStringList.Create;

    resource_list.Text := resources_list_string;

    for resource_line in resource_list do
    begin
      name_resource := regex(resource_line, '[name]', '[name]');
      type_resource := regex(resource_line, '[type]', '[type]');

      with lvResources.Items.Add do
      begin
        Caption := name_resource;
        SubItems.Add(type_resource);
      end;

    end;

    if (resource_list.Count > 0) then
    begin
      message_box('DH Resource Manager 0.5', 'Resources Loaded', 'Information');
    end
    else
    begin
      message_box('DH Resource Manager 0.5', 'Resources not found',
        'Information');
    end;

    resource_list.Free;
    resources.Free;

  end;
end;

procedure TFormHome.ItemRefreshListClick(Sender: TObject);
begin
  listar();
end;

procedure TFormHome.ItemAddFileClick(Sender: TObject);
var
  resource_file: string;
  resource_name: string;
  resource_manager: T_DH_Resources;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    resource_file := open_dialog('Select resource', '', 0);
    if (FileExists(resource_file)) then
    begin
      resource_name := InputBox('Write resource name', 'Name', '');
      if not(resource_name = '') then
      begin
        resource_manager := T_DH_Resources.Create();
        if (resource_manager.add_resource(txtFilename.Text, resource_file,
          resource_name)) then
        begin
          message_box('DH Resource Manager 0.5', 'Resource added',
            'Information');
        end
        else
        begin
          message_box('DH Resource Manager 0.5', 'Resources not found',
            'Error');
        end;
        resource_manager.Free;
        listar();
      end;
    end;
  end;
end;

procedure TFormHome.ItemEditResourceClick(Sender: TObject);
var
  old_resource_name: string;
  new_resource_file: string;
  resource_manager: T_DH_Resources;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    if lvResources.Selected <> nil then
    begin
      old_resource_name := lvResources.Selected.Caption;
      new_resource_file := open_dialog('Select new resource', '', 0);
      if (FileExists(new_resource_file)) then
      begin
        resource_manager := T_DH_Resources.Create();
        if (resource_manager.edit_resource(txtFilename.Text, new_resource_file,
          old_resource_name)) then
        begin
          message_box('DH Resource Manager 0.5', 'Resource edited',
            'Information');
        end
        else
        begin
          message_box('DH Resource Manager 0.5', 'Error', 'Error');
        end;
        resource_manager.Free;
        listar();
      end;
    end;
  end;
end;

procedure TFormHome.ItemDeleteFileClick(Sender: TObject);
var
  resource_name: string;
  resource_manager: T_DH_Resources;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    if lvResources.Selected <> nil then
    begin
      resource_name := lvResources.Selected.Caption;
      resource_manager := T_DH_Resources.Create();
      if (resource_manager.delete_resource(txtFilename.Text, resource_name))
      then
      begin
        message_box('DH Resource Manager 0.5', 'Resource deleted',
          'Information');
      end
      else
      begin
        message_box('DH Resource Manager 0.5', 'Error', 'Error');
      end;
      resource_manager.Free;
      listar();
    end;
  end;
end;

procedure TFormHome.buscar_archivos(directory: string);
var
  busqueda: TSearchRec;
begin
  if FindFirst(IncludeTrailingBackslash(directory) + '*.*',
    faAnyFile or faDirectory, busqueda) = 0 then
  begin
    try
      repeat
        if (busqueda.Attr and faDirectory) = 0 then
        begin
          archivos_encontrados := archivos_encontrados + directory + '/' +
            busqueda.Name + sLineBreak;
        end
        else if not(busqueda.Name = '.') and not(busqueda.Name = '..') then
        begin
          buscar_archivos(directory + '/' + busqueda.Name);
        end;
      until FindNext(busqueda) <> 0;
    finally
      FindClose(busqueda);
    end;
  end;
end;

function TFormHome.listar_directorio_para_rc(directory: string;
  savefile_name: string; id: string): boolean;
var
  listaArchivos: TStringList;
  archivo: string;
  id_directory: string;
  id_resource: string;
  id_ready: string;
  Name: string;
  name_resource: string;
  ruta: string;
begin

  try
    begin
      archivos_encontrados := '';
      buscar_archivos(directory);
      listaArchivos := TStringList.Create;
      listaArchivos.Text := archivos_encontrados;

      id_directory := '';

      if (id = '') then
      begin
        id_directory := dh_generate_string('3', 4);
      end
      else
      begin
        id_directory := id;
      end;

      for archivo in listaArchivos do
      begin
        id_resource := dh_generate_string('3', 4);
        ruta := archivo;
        name := archivo;
        name := StringReplace(name, '/', '\', [rfReplaceAll, rfIgnoreCase]);
        name := ExtractFilename(name);

        name := StringReplace(name, '.', '_', [rfReplaceAll, rfIgnoreCase]);
        name := StringReplace(name, ' ', '', [rfReplaceAll, rfIgnoreCase]);

        name_resource := id_directory + '_' + id_resource + '_' + name;
        savefile(savefile_name, name_resource + ' ' + 'RCDATA' + ' "' + ruta +
          '"' + sLineBreak);

      end;
      listaArchivos.Free;
      Result := True;
    end;
  except
    begin
      Result := False;
    end;
  end;
end;

function TFormHome.listar_directorio_para_recursos(directory: string;
  id: string): boolean;
var
  listaArchivos: TStringList;
  archivo: string;
  id_directory: string;
  id_resource: string;
  id_ready: string;
  Name: string;
  name_resource: string;
  ruta: string;
  resource_manager: T_DH_Resources;
begin

  try
    begin
      archivos_encontrados := '';
      buscar_archivos(directory);
      listaArchivos := TStringList.Create;
      listaArchivos.Text := archivos_encontrados;

      id_directory := '';

      if (id = '') then
      begin
        id_directory := dh_generate_string('3', 4);
      end
      else
      begin
        id_directory := id;
      end;

      resource_manager := T_DH_Resources.Create();

      for archivo in listaArchivos do
      begin
        id_resource := dh_generate_string('3', 4);
        ruta := archivo;
        name := archivo;
        name := StringReplace(name, '/', '\', [rfReplaceAll, rfIgnoreCase]);
        name := ExtractFilename(name);

        name := StringReplace(name, '.', '_', [rfReplaceAll, rfIgnoreCase]);

        name_resource := id_directory + '_' + id_resource + '_' + name;

        resource_manager.add_resource(txtFilename.Text, ruta, name_resource);

      end;

      resource_manager.Free;

      listaArchivos.Free;
      Result := True;
    end;
  except
    begin
      Result := False;
    end;
  end;
end;

function TFormHome.borrar_recursos_por_id(id: integer): boolean;
var
  cantidad: integer;
  i: integer;
  resource_name: string;
  resource_manager: T_DH_Resources;
begin
  try
    begin
      resource_manager := T_DH_Resources.Create();
      for i := 0 to lvResources.Items.Count - 1 do
      begin
        resource_name := lvResources.Items[i].Caption;
        if (Pos(IntToStr(id), resource_name) > 0) then
        begin
          resource_manager.delete_resource(txtFilename.Text, resource_name);
        end;
      end;
      resource_manager.Free;
      Result := True;
    end;
  except
    begin
      Result := False;
    end;
  end;
end;

procedure TFormHome.ItemAddDirectoryClick(Sender: TObject);
var
  directory: string;
  id: string;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    directory := InputBox('Write directory', 'Directory', '');
    if not(directory = '') and DirectoryExists(directory) then
    begin
      id := InputBox('Write ID', 'ID', '');
      if (listar_directorio_para_recursos(directory, id)) then
      begin
        message_box('DH Resource Manager 0.5', 'Resources added',
          'Information');
      end
      else
      begin
        message_box('DH Resource Manager 0.5', 'Error', 'Error');
      end;
      listar();
    end;
  end;
end;

procedure TFormHome.ItemDeleteDirectoryClick(Sender: TObject);
var
  directory: string;
  id: string;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    id := InputBox('Write ID', 'ID', '');
    if (borrar_recursos_por_id(StrToInt(id))) then
    begin
      message_box('DH Resource Manager 0.5', 'Resources deleted',
        'Information');
    end
    else
    begin
      message_box('DH Resource Manager 0.5', 'Error', 'Error');
    end;
    listar();
  end;
end;

procedure TFormHome.ItemGenerate_RC_DirectoryClick(Sender: TObject);
var
  directory: string;
  savefile: string;
  id: string;
begin
  directory := InputBox('Write directory', 'Directory', '');
  if not(directory = '') and DirectoryExists(directory) then
  begin
    savefile := save_dialog('Save resource', 'RC files (*.rc)', 'rc', 0);
    if not(savefile = '') then
    begin
      id := InputBox('Write ID', 'ID', '');
      if (listar_directorio_para_rc(directory, savefile, id)) then
      begin
        execute_command('BRCC32.exe "' + savefile + '"');
        message_box('DH Resource Manager 0.5', 'Files RC and RES generated',
          'Information');
      end
      else
      begin
        message_box('DH Resource Manager 0.5', 'Error', 'Error');
      end;
    end;
  end;
end;

procedure TFormHome.ItemSaveResourceClick(Sender: TObject);
var
  resource_name: string;
  savefile: string;
  resource_manager: T_DH_Resources;
begin
  if (FileExists(txtFilename.Text)) then
  begin
    if lvResources.Selected <> nil then
    begin
      savefile := save_dialog('Save resource', '', '', 0);
      if not(savefile = '') then
      begin
        resource_name := lvResources.Selected.Caption;
        resource_manager := T_DH_Resources.Create();
        if (resource_manager.save_resource(txtFilename.Text, resource_name,
          savefile)) then
        begin
          message_box('DH Resource Manager 0.5', 'Resource saved',
            'Information');
        end
        else
        begin
          message_box('DH Resource Manager 0.5', 'Error', 'Error');
        end;
        resource_manager.Free;
        listar();
      end;
    end;
  end;
end;

procedure TFormHome.ItemGenerate_RC_FileClick(Sender: TObject);
var
  resource_file: string;
  resource_name: string;
  savefile_name: string;
  resource_manager: T_DH_Resources;
begin
  resource_file := open_dialog('Load resource', '', 0);
  if (FileExists(resource_file)) then
  begin
    resource_name := InputBox('Write resource name', 'Name', '');
    if not(resource_name = '') then
    begin
      resource_name := StringReplace(resource_name, '.', '_',
        [rfReplaceAll, rfIgnoreCase]);
      resource_name := StringReplace(resource_name, ' ', '',
        [rfReplaceAll, rfIgnoreCase]);
      savefile_name := save_dialog('Save RC', 'RC files (*.rc)', 'rc', 0);
      if not(savefile_name = '') then
      begin
        savefile(savefile_name, resource_name + ' ' + 'RCDATA' + ' "' +
          resource_file + '"' + sLineBreak);
        execute_command('BRCC32.exe "' + savefile_name + '"');
        message_box('DH Resource Manager 0.5', 'Files RC and RES generated',
          'Information');
      end;
    end;
  end;
end;

procedure TFormHome.btnLoadClick(Sender: TObject);
begin
  lvResources.Items.Clear;
  txtFilename.Text := open_dialog('Select File',
    'EXE files (*.exe)|*.EXE|DLL Files (*.dll)|*.DLL', 0);
  if (FileExists(txtFilename.Text)) then
  begin
    message_box('DH Resource Manager 0.5', 'File loaded', 'Information');
  end;
end;

procedure TFormHome.btnScanClick(Sender: TObject);
begin
  listar();
end;

end.

// The End ?
