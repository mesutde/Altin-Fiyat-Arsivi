unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AltinFiyatParser, Vcl.StdCtrls,
  System.Generics.Collections, System.IOUtils, ShellAPI,
  Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    dtpStartDate: TDateTimePicker;
    lbStartDate: TLabel;
    dtpEndDate: TDateTimePicker;
    lbEndDate: TLabel;
    Memo1: TMemo;
    LinkLabel1: TLinkLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);

  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Baslangic, Bitis: TDateTime;

implementation

{$R *.dfm}
{
  procedure TForm1.Button1Click(Sender: TObject);
  var
  Parser: TAltinFiyatParser;
  FiyatListesi: TList<TAltinFiyati>;
  Baslangic, Bitis: TDateTime;
  begin
  Baslangic := EncodeDate(2005, 1, 1);
  Bitis := EncodeDate(2025, 8, 6);
  // Bitis := EncodeDate(2005,1, 30);

  Parser := TAltinFiyatParser.Create;
  try
  FiyatListesi := Parser.IndirVeParse(Baslangic, Bitis);
  try
  if FiyatListesi.Count > 0 then
  begin
  ShowMessage(Format('%d g�n verisi y�klendi.', [FiyatListesi.Count]));

  if OpenDialog1.Execute then
  begin
  Parser.ExportToCSV(FiyatListesi, OpenDialog1.FileName);
  ShowMessage('Veriler CSV olarak kaydedildi.');
  end;
  end
  else
  ShowMessage('Hi� veri al�namad�.');
  finally
  FiyatListesi.Free;
  end;
  finally
  Parser.Free;
  end;
  end;
}

procedure TForm1.Button1Click(Sender: TObject);
var
  Parser: TAltinFiyatParser;
  FiyatListesi: TList<TAltinFiyati>;
  Baslangic, Bitis: TDateTime;
  ExePath, DataFolder, FileName, FinalFileName: string;
  BaseFileName, Extension: string;
  FileIndex: Integer;
  Y1, M1, D1, Y2, M2, D2: Word; // Tarih bile�enleri
begin
  // Baslangic := EncodeDate(2005, 1, 1);  //Y�l-Ay-G�n
  // Bitis := EncodeDate(2025, 8, 7);       //Y�l-Ay-G�n

  // Kullan�c�n�n se�ti�i tarihleri al
  Baslangic := dtpStartDate.Date;
  Bitis := dtpEndDate.Date;

  Parser := TAltinFiyatParser.Create;
  try
    FiyatListesi := Parser.IndirVeParse(Baslangic, Bitis);
    try
      if FiyatListesi.Count > 0 then
      begin
        ShowMessage(Format('%d g�n verisi y�klendi.', [FiyatListesi.Count]));

        // Tarihlerden y�l, ay, g�n ��kar
        DecodeDate(Baslangic, Y1, M1, D1);
        DecodeDate(Bitis, Y2, M2, D2);

        // .exe dosyas�n�n bulundu�u dizin
        ExePath := ExtractFilePath(ParamStr(0));
        DataFolder := IncludeTrailingPathDelimiter(ExePath) + 'Data';

        // Data klas�r�n� olu�tur (e�er yoksa)
        if not DirectoryExists(DataFolder) then
          ForceDirectories(DataFolder);

        // Dosya ad�: Alt�n_Verileri_2005_01_01-2025_08_06.csv
        BaseFileName := Format('Alt�n_Verileri_%d_%.2d_%.2d-%d_%.2d_%.2d',
          [Y1, M1, D1, Y2, M2, D2]);
        Extension := '.csv';
        FileName := BaseFileName + Extension;
        FinalFileName := IncludeTrailingPathDelimiter(DataFolder) + FileName;

        // Ayn� isimde dosya varsa _1, _2, ... ekleyerek ��zmek
        FileIndex := 1;
        while FileExists(FinalFileName) do
        begin
          FinalFileName := IncludeTrailingPathDelimiter(DataFolder) +
            BaseFileName + '_' + IntToStr(FileIndex) + Extension;
          Inc(FileIndex);
        end;

        // CSV olarak d��a aktar
        Parser.ExportToCSV(FiyatListesi, FinalFileName);
        ShowMessage(Format('Veriler �u dosyaya kaydedildi:%s%s',
          [sLineBreak, FinalFileName]));

        if MessageDlg
          (Format('Veriler �u dosyaya kaydedildi:%s%s%sA�mak ister misiniz?',
          [sLineBreak, FinalFileName, sLineBreak]), mtInformation,
          [mbYes, mbNo], 0) = mrYes then
        begin
          // Dosyay� Windows'ta se�ili �ekilde g�ster
          ShellExecute(0, 'open', 'explorer.exe',
            PChar('/select,"' + FinalFileName + '"'), nil, SW_SHOWNORMAL);
        end;

      end
      else
        ShowMessage('Hi� veri al�namad�.');
    finally
      FiyatListesi.Free;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  // Ba�lang�� tarihi: 1 Ocak 2005
  Baslangic := EncodeDate(2005, 1, 1);
  dtpStartDate.Date := Baslangic;

  // Biti� tarihi: Bug�n
  Bitis := Date;
  dtpEndDate.Date := Bitis;

  LinkLabel1.Caption :=
    '<a href="https://www.linkedin.com/in/mesutdemirci/">https://www.linkedin.com/in/mesutdemirci/</a>';
  LinkLabel1.Cursor := crHandPoint; // El imleci i�in
end;

procedure TForm1.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

end.
