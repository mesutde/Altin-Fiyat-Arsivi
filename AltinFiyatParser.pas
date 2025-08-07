unit AltinFiyatParser;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Generics.Collections,
  IdHTTP, IdGlobal, System.NetEncoding, System.StrUtils;

type
  TAltinFiyati = class
  private
    FGun, FAy, FYil: Integer;
    FKayitTarihi: TDateTime;

    FGramAlis, FGramSatis: string;
    FCeyrekAlis, FCeyrekSatis: string;
    FCumhuriyetAlis, FCumhuriyetSatis: string;
    FYarimAlis, FYarimSatis: string;
    FTamAlis, FTamSatis: string;
    FBilezik22Alis, FBilezik22Satis: string;
    F14AyarAlis, F14AyarSatis: string;
    F18AyarAlis, F18AyarSatis: string;
    FResatAlis, FResatSatis: string;
    FGremseAlis, FGremseSatis: string;
    FHamitAlis, FHamitSatis: string;
  public
    constructor Create(Gun, Ay, Yil: Integer);

    property KayitTarihi: TDateTime read FKayitTarihi;

    property GramAlis: string read FGramAlis write FGramAlis;
    property GramSatis: string read FGramSatis write FGramSatis;

    property CeyrekAlis: string read FCeyrekAlis write FCeyrekAlis;
    property CeyrekSatis: string read FCeyrekSatis write FCeyrekSatis;

    property CumhuriyetAlis: string read FCumhuriyetAlis write FCumhuriyetAlis;
    property CumhuriyetSatis: string read FCumhuriyetSatis write FCumhuriyetSatis;

    property YarimAlis: string read FYarimAlis write FYarimAlis;
    property YarimSatis: string read FYarimSatis write FYarimSatis;

    property TamAlis: string read FTamAlis write FTamAlis;
    property TamSatis: string read FTamSatis write FTamSatis;

    property Bilezik22Alis: string read FBilezik22Alis write FBilezik22Alis;
    property Bilezik22Satis: string read FBilezik22Satis write FBilezik22Satis;

    property Ayar14Alis: string read F14AyarAlis write F14AyarAlis;
    property Ayar14Satis: string read F14AyarSatis write F14AyarSatis;

    property Ayar18Alis: string read F18AyarAlis write F18AyarAlis;
    property Ayar18Satis: string read F18AyarSatis write F18AyarSatis;

    property ResatAlis: string read FResatAlis write FResatAlis;
    property ResatSatis: string read FResatSatis write FResatSatis;

    property GremseAlis: string read FGremseAlis write FGremseAlis;
    property GremseSatis: string read FGremseSatis write FGremseSatis;

    property HamitAlis: string read FHamitAlis write FHamitAlis;
    property HamitSatis: string read FHamitSatis write FHamitSatis;
  end;

type
  TAltinFiyatParser = class
  private
    FHTTP: TIdHTTP;
    FVeriListesi: TList<TAltinFiyati>;
    function ParseFiyat(const HTML: string; Gun, Ay, Yil: Integer): TAltinFiyati;
   function FindPriceInBlock(const HTMLContent, ATitle, AType: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    function IndirVeParse(BaslangicTarihi, BitisTarihi: TDateTime): TList<TAltinFiyati>;
    procedure ExportToCSV(FiyatListesi: TList<TAltinFiyati>; const FileName: string);
  end;

implementation

{ TAltinFiyati }

constructor TAltinFiyati.Create(Gun, Ay, Yil: Integer);
begin
  inherited Create;
  FGun := Gun;
  FAy := Ay;
  FYil := Yil;
  FKayitTarihi := EncodeDate(Yil, Ay, Gun);
end;

{ TAltinFiyatParser }

constructor TAltinFiyatParser.Create;
begin
  FHTTP := TIdHTTP.Create;
  FVeriListesi := TList<TAltinFiyati>.Create;

  FHTTP.Request.ContentType := 'text/html';
  FHTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  FHTTP.HandleRedirects := True;
end;

destructor TAltinFiyatParser.Destroy;
begin
  FHTTP.Free;
  if Assigned(FVeriListesi) then
  begin
    for var Item in FVeriListesi do
      Item.Free;
    FVeriListesi.Free;
  end;
  inherited;
end;

function TAltinFiyatParser.FindPriceInBlock(const HTMLContent, ATitle, AType: string): string;
var
  DivPattern, ValuePattern: string;
  DivStartPos, DivEndPos: Integer;
  DivContent: string;
  ValueStartPos, ValueEndPos: Integer;
begin
  Result := '';

  // 1. Belirli altın türünün div blokunu bul
  DivPattern := Format('<div class="kurlar bordernone" title="%s">', [ATitle]);
  DivStartPos := Pos(DivPattern, HTMLContent);
  if DivStartPos = 0 then
    Exit;

  // 2. Bu div'in kapanışını bul
  DivEndPos := PosEx('</div>', HTMLContent, DivStartPos);
  if DivEndPos = 0 then
    Exit;

  // 3. Div içeriğini al
  DivContent := Copy(HTMLContent, DivStartPos, DivEndPos - DivStartPos + 6);

  // 4. İlgili değeri bul (alis veya satis)
  ValuePattern := Format('<li class="midrow %s"', [AType]);
  ValueStartPos := Pos(ValuePattern, DivContent);
  if ValueStartPos = 0 then
    Exit;

  // 5. Değerin başlangıcını bul (">" karakterinden sonra)
  ValueStartPos := PosEx('>', DivContent, ValueStartPos);
  if ValueStartPos = 0 then
    Exit;
  ValueStartPos := ValueStartPos + 1;

  // 6. Değerin sonunu bul ("</li>" karakterinden önce)
  ValueEndPos := PosEx('</li>', DivContent, ValueStartPos);
  if ValueEndPos = 0 then
    Exit;

  // 7. Değeri temizle ve döndür
  Result := Trim(Copy(DivContent, ValueStartPos, ValueEndPos - ValueStartPos));
end;


function TAltinFiyatParser.ParseFiyat(const HTML: string; Gun, Ay, Yil: Integer): TAltinFiyati;
var
  Fiyat: TAltinFiyati;
begin
  Fiyat := TAltinFiyati.Create(Gun, Ay, Yil);
  try
    // Tüm altın türleri için string değerleri al
    Fiyat.FGramAlis := FindPriceInBlock(HTML, 'Gram Altın', 'alis');
    Fiyat.FGramSatis := FindPriceInBlock(HTML, 'Gram Altın', 'satis');

    Fiyat.FCeyrekAlis := FindPriceInBlock(HTML, 'Çeyrek Altın', 'alis');
    Fiyat.FCeyrekSatis := FindPriceInBlock(HTML, 'Çeyrek Altın', 'satis');

    Fiyat.FCumhuriyetAlis := FindPriceInBlock(HTML, 'Cumhuriyet Altını', 'alis');
    Fiyat.FCumhuriyetSatis := FindPriceInBlock(HTML, 'Cumhuriyet Altını', 'satis');

    Fiyat.FYarimAlis := FindPriceInBlock(HTML, 'Yarım Altın', 'alis');
    Fiyat.FYarimSatis := FindPriceInBlock(HTML, 'Yarım Altın', 'satis');

    Fiyat.FTamAlis := FindPriceInBlock(HTML, 'Tam Altın', 'alis');
    Fiyat.FTamSatis := FindPriceInBlock(HTML, 'Tam Altın', 'satis');

    Fiyat.FBilezik22Alis := FindPriceInBlock(HTML, '22 Ayar Bilezik', 'alis');
    Fiyat.FBilezik22Satis := FindPriceInBlock(HTML, '22 Ayar Bilezik', 'satis');

    Fiyat.F14AyarAlis := FindPriceInBlock(HTML, '14 Ayar Altın', 'alis');
    Fiyat.F14AyarSatis := FindPriceInBlock(HTML, '14 Ayar Altın', 'satis');

    Fiyat.F18AyarAlis := FindPriceInBlock(HTML, '18 Ayar Altın', 'alis');
    Fiyat.F18AyarSatis := FindPriceInBlock(HTML, '18 Ayar Altın', 'satis');

    Fiyat.FResatAlis := FindPriceInBlock(HTML, 'Reşat Altın', 'alis');
    Fiyat.FResatSatis := FindPriceInBlock(HTML, 'Reşat Altın', 'satis');

    Fiyat.FGremseAlis := FindPriceInBlock(HTML, 'Gremse Altın', 'alis');
    Fiyat.FGremseSatis := FindPriceInBlock(HTML, 'Gremse Altın', 'satis');

    Fiyat.FHamitAlis := FindPriceInBlock(HTML, 'Hamit Altın', 'alis');
    Fiyat.FHamitSatis := FindPriceInBlock(HTML, 'Hamit Altın', 'satis');

    Result := Fiyat;
  except
    on E: Exception do
    begin
      Fiyat.Free;
      raise;
    end;
  end;
end;

function TAltinFiyatParser.IndirVeParse(BaslangicTarihi, BitisTarihi: TDateTime): TList<TAltinFiyati>;
var
  Tarih: TDateTime;
  Gun, Ay, Yil: Word;
  URL: string;
  HTML: string;
  Fiyat: TAltinFiyati;
  ResponseStream: TMemoryStream;
  ResponseBytes: TBytes;
begin
  Result := TList<TAltinFiyati>.Create;
  Tarih := BaslangicTarihi;

  while Tarih <= BitisTarihi do
  begin
    DecodeDate(Tarih, Yil, Ay, Gun);
    URL := Format('https://altin.in/arsiv/%d/%.2d/%.2d', [Yil, Ay, Gun]);

    ResponseStream := TMemoryStream.Create;
    try
      try
        FHTTP.Get(URL, ResponseStream);
        ResponseStream.Position := 0;

        SetLength(ResponseBytes, ResponseStream.Size);
        ResponseStream.ReadBuffer(ResponseBytes[0], ResponseStream.Size);

        HTML := TEncoding.GetEncoding(28599).GetString(ResponseBytes);

        Fiyat := ParseFiyat(HTML, Gun, Ay, Yil);

        // ✅ String değerler boş değilse ekle
        if (Fiyat.GramAlis <> '') or
           (Fiyat.CeyrekAlis <> '') or
           (Fiyat.CumhuriyetAlis <> '') or
           (Fiyat.YarimAlis <> '') or
           (Fiyat.TamAlis <> '') or
           (Fiyat.ResatAlis <> '') or
           (Fiyat.GremseAlis <> '') or
           (Fiyat.HamitAlis <> '') or
           (Fiyat.Ayar14Alis <> '') or
           (Fiyat.Ayar18Alis <> '') or
           (Fiyat.Bilezik22Alis <> '') then
          Result.Add(Fiyat)
        else
          Fiyat.Free;

      except
        on E: Exception do
        begin
          // Hata loglanabilir
        end;
      end;
    finally
      ResponseStream.Free;
    end;

    Tarih := IncDay(Tarih);
    Sleep(500);
  end;
end;
procedure TAltinFiyatParser.ExportToCSV(FiyatListesi: TList<TAltinFiyati>; const FileName: string);
var
  SL: TStringList;
  F: TAltinFiyati;
begin
  SL := TStringList.Create;
  try
    SL.Add('Tarih,Gun,Ay,Yil,GramAlis,GramSatis,CeyrekAlis,CeyrekSatis,CumhuriyetAlis,CumhuriyetSatis,YarimAlis,YarimSatis,TamAlis,TamSatis,Bilezik22Alis,Bilezik22Satis,Ayar14Alis,Ayar14Satis,Ayar18Alis,Ayar18Satis,ResatAlis,ResatSatis,GremseAlis,GremseSatis,HamitAlis,HamitSatis');
    for F in FiyatListesi do
    begin
    SL.Add(Format('%d.%d.%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s',
  [F.FGun, F.FAy, F.FYil,
   F.FGun, F.FAy, F.FYil,
   F.GramAlis, F.GramSatis,
   F.CeyrekAlis, F.CeyrekSatis,
   F.CumhuriyetAlis, F.CumhuriyetSatis,
   F.YarimAlis, F.YarimSatis,
   F.TamAlis, F.TamSatis,
   F.Bilezik22Alis, F.Bilezik22Satis,
   F.Ayar14Alis, F.Ayar14Satis,
   F.Ayar18Alis, F.Ayar18Satis,
   F.ResatAlis, F.ResatSatis,
   F.GremseAlis, F.GremseSatis,
   F.HamitAlis, F.HamitSatis]));
    end;
    SL.SaveToFile(FileName, TEncoding.UTF8);
  finally
    SL.Free;
  end;
end;

end.
