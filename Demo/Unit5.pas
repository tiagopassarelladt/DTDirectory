unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DTDirectory, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList;

type
  TForm5 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    DTDirectory1: TDTDirectory;
    Button1: TButton;
    ListView1: TListView;
    ImageList1: TImageList;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure RefreshView(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
        DTDirectory1.Directory := Edit1.Text;
        DTDirectory1.OnChange  := RefreshView;
        DTDirectory1.Active    := true;
        ListView1.Clear;
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
     DTDirectory1.Active := False;
end;

procedure TForm5.ListView1DblClick(Sender: TObject);
var
  lvi: TListItem;
  i: integer;
begin
  lvi := Listview1.Selected;
  //if nothing or simply a file is selected the exit ...
  if (lvi = nil) or (lvi.Data = nil) then exit;

  if lvi.Caption = '..' then
  begin
    //parent directory selected, so go up one level if possible ...
    i := length (DTDirectory1.Directory)-1;
    if i < 3 then exit; //root dir
    while DTDirectory1.Directory[i] <> '\' do dec(i);
    DTDirectory1.Directory := copy(DTDirectory1.Directory,1,i);
  end else
    //child directory selected, so go to that child directory ...
    DTDirectory1.Directory :=
      DTDirectory1.Directory + lvi.Caption;
  //refresh listview ...
  RefreshView(nil);

end;

procedure TForm5.RefreshView(Sender: TObject);
var
  sr: TSearchRec;
  searchResult: integer;
  lvi: TListitem;
  attr: string;
begin
  //whenever there's a change in the selected folder ... update the listview
  ListView1.items.clear;
  screen.Cursor := crHourglass;
  ListView1.Items.BeginUpdate;
  try
    //add the parent folder ...
    lvi := ListView1.Items.Add;
    lvi.Caption := '..';
    lvi.Data := pointer(-2); //Data simply used to sort folders before files
    lvi.ImageIndex := 2;
    //add any other files or folders ...
    searchResult := FindFirst(DTDirectory1.Directory+'*.*',faAnyFile,sr);
    while searchResult = 0 do
    begin
      if sr.Name[1] <> '.' then
      begin
        lvi := ListView1.Items.Add;
        if sr.Attr and FILE_ATTRIBUTE_DIRECTORY > 0 then lvi.Data := pointer(-1);
        lvi.Caption := sr.Name;
        if lvi.Data <> nil then //a directory
          lvi.SubItems.Add('') else
          lvi.SubItems.Add(format('%1.0n Kb',[sr.Size/1024]));
        if sr.Time = 0 then
          lvi.SubItems.Add('') else
          lvi.SubItems.Add(formatdatetime('dd/mm/yyyy' + '  ' + 'hh:mm:ss', FileDateToDateTime(sr.Time)));
        if lvi.Data <> nil then
          lvi.ImageIndex := 1 else
          lvi.ImageIndex := 0;
        if sr.Attr and FILE_ATTRIBUTE_READONLY > 0 then
          attr := 'R' else attr := '';
        if sr.Attr and FILE_ATTRIBUTE_ARCHIVE > 0 then
          attr := attr + 'A';
        if sr.Attr and FILE_ATTRIBUTE_SYSTEM > 0 then
          attr := attr + 'S';
        if sr.Attr and FILE_ATTRIBUTE_HIDDEN > 0 then
          attr := attr + 'H';
        lvi.SubItems.Add(attr);
      end;
      searchResult := FindNext(sr);
    end;
    findClose(sr);
  finally
    ListView1.Items.EndUpdate;
    screen.Cursor := crDefault;
  end;
  Caption := 'Explorando - ' + DTDirectory1.Directory;
end;

end.
