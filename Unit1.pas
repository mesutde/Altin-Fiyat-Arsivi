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
  ShowMessage(Format('%d gün verisi yüklendi.', [FiyatListesi.Count]));

  if OpenDialog1.Execute then
  begin
  Parser.ExportToCSV(FiyatListesi, OpenDialog1.FileName);
  ShowMessage('Veriler CSV olarak kaydedildi.');
  end;
  end
  else
  ShowMessage('Hiç veri alýnamadý.');
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
  Y1, M1, D1, Y2, M2, D2: Word; // Tarih bileþenleri
begin
  // Baslangic := EncodeDate(2005, 1, 1);  //Yýl-Ay-Gün
  // Bitis := EncodeDate(2025, 8, 7);       //Yýl-Ay-Gün

  // Kullanýcýnýn seçtiði tarihleri al
  Baslangic := dtpStartDate.Date;
  Bitis := dtpEndDate.Date;

  Parser := TAltinFiyatParser.Create;
  try
    FiyatListesi := Parser.IndirVeParse(Baslangic, Bitis);
    try
      if FiyatListesi.Count > 0 then
      begin
        ShowMessage(Format('%d gün verisi yüklendi.', [FiyatListesi.Count]));

        // Tarihlerden yýl, ay, gün çýkar
        DecodeDate(Baslangic, Y1, M1, D1);
        DecodeDate(Bitis, Y2, M2, D2);

        // .exe dosyasýnýn bulunduðu dizin
        ExePath := ExtractFilePath(ParamStr(0));
        DataFolder := IncludeTrailingPathDelimiter(ExePath) + 'Data';

        // Data klasörünü oluþtur (eðer yoksa)
        if not DirectoryExists(DataFolder) then
          ForceDirectories(DataFolder);

        // Dosya adý: Altýn_Verileri_2005_01_01-2025_08_06.csv
        BaseFileName := Format('Altýn_Verileri_%d_%.2d_%.2d-%d_%.2d_%.2d',
          [Y1, M1, D1, Y2, M2, D2]);
        Extension := '.csv';
        FileName := BaseFileName + Extension;
        FinalFileName := IncludeTrailingPathDelimiter(DataFolder) + FileName;

        // Ayný isimde dosya varsa _1, _2, ... ekleyerek çözmek
        FileIndex := 1;
        while FileExists(FinalFileName) do
        begin
          FinalFileName := IncludeTrailingPathDelimiter(DataFolder) +
            BaseFileName + '_' + IntToStr(FileIndex) + Extension;
          Inc(FileIndex);
        end;

        // CSV olarak dýþa aktar
        Parser.ExportToCSV(FiyatListesi, FinalFileName);
        ShowMessage(Format('Veriler þu dosyaya kaydedildi:%s%s',
          [sLineBreak, FinalFileName]));

        if MessageDlg
          (Format('Veriler þu dosyaya kaydedildi:%s%s%sAçmak ister misiniz?',
          [sLineBreak, FinalFileName, sLineBreak]), mtInformation,
          [mbYes, mbNo], 0) = mrYes then
        begin
          // Dosyayý Windows'ta seçili þekilde göster
          ShellExecute(0, 'open', 'explorer.exe',
            PChar('/select,"' + FinalFileName + '"'), nil, SW_SHOWNORMAL);
        end;

      end
      else
        ShowMessage('Hiç veri alýnamadý.');
    finally
      FiyatListesi.Free;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  // Baþlangýç tarihi: 1 Ocak 2005
  Baslangic := EncodeDate(2005, 1, 1);
  dtpStartDate.Date := Baslangic;

  // Bitiþ tarihi: Bugün
  Bitis := Date;
  dtpEndDate.Date := Bitis;

  LinkLabel1.Caption :=
    '<a href="https://www.linkedin.com/in/mesutdemirci/">https://www.linkedin.com/in/mesutdemirci/</a>';
  LinkLabel1.Cursor := crHandPoint; // El imleci için
end;

procedure TForm1.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

end.
