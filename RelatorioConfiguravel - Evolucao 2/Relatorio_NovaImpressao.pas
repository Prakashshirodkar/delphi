unit Relatorio_NovaImpressao;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, QuickRpt, QRPrntr, QRCtrls, DB, DBClient, QRPDFFilt,
  CJVQRBarCode, URelatorioSubDetalhamento, URelatorioDesenho, URelatorioDetalhamento,
  URelatorioUtil;

type

  TRelatorioNovaImpressao = class(TQuickRep)
    Cabecalho01: TQRBand;
    Cabecalho02: TQRBand;
    Cabecalho03: TQRBand;
    CabecalhoGeral: TQRBand;
    Detalhe01: TQRSubDetail;
    Detalhe02: TQRSubDetail;
    Detalhe03: TQRSubDetail;
    Principal: TQRBand;
    QRPDFFilter1: TQRPDFFilter;
    Rodape01: TQRBand;
    Rodape02: TQRBand;
    Rodape03: TQRBand;
    SeparadorPrincipal: TQRChildBand;
    RodapeGeral: TQRBand;
    cdRelatorio: TClientDataSet;
    cdDetalhe01: TClientDataSet;
    cdDetalhe02: TClientDataSet;
    cdDetalhe03: TClientDataSet;
    cdMontaItens: TClientDataSet;
    cdListaDetalhamentos: TClientDataSet;
    cdMontaRelatorio: TClientDataSet;
    procedure QRBandCabecalhoGeralBeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure MontarRelatorio();
    procedure MontarRelatorioDinamico();
    procedure Preview();
  end;

implementation

uses StrUtils;
{$R *.DFM}
{ TRelatorioNovaImpressao }

constructor TRelatorioNovaImpressao.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  for I := 0 to ComponentCount - 1 do
    if (TComponent(Components[I]).ClassType = TQRBand) or (TComponent(Components[I]).ClassType = TQRSubDetail) or (TComponent(Components[I]).ClassType = TQRChildBand) then
    begin
      TQRCustomBand(Components[I]).Visible := False;
      TQRCustomBand(Components[I]).Height := 0;
      TQRCustomBand(Components[I]).TransparentBand := False;
    end;
end;

procedure TRelatorioNovaImpressao.Preview;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if (Components[I].ClassType = TQRSubDetail) then
      TQRSubDetail(Components[I]).PrintIfEmpty := False;

  Self.PrevInitialZoom := qrZoom100;
  Self.PreviewInitialState := wsMaximized;
  Self.PrevShowThumbs := False;
  Self.PrevShowSearch := False;
  Self.PreviewModal;
end;

procedure TRelatorioNovaImpressao.QRBandCabecalhoGeralBeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
begin
  // PrintBand := (Self.PageNumber > 1);
end;

procedure TRelatorioNovaImpressao.MontarRelatorio();
var
  ItensPedido, Ordem, Bloqueio: TSubDetalhamento;
  Relatorio: TDetalhamento;
begin
  Relatorio := TDetalhamento.Create(Self, 'Relatorio');
  // Relatorio := TDetalhamento.Create(Self, 'Relatorio', CabecalhoGeral, Principal, RodapeGeral);
  Relatorio.DataSet := Self.DataSet;
  Relatorio.Cabecalho.AdicionarCampoLabel('Total Itens: ' + IntToStr(Self.DataSet.RecordCount), 1, 300, 0, 12);
  Relatorio.Cabecalho.AdicionarCampoLabel('texto fixo em toda pagina  ', 1, 100, 0, 12);
  Relatorio.Rodape.AdicionarCampoLabel('texto fixo em todo rodape ', 1, 100, 0, 12);
  Relatorio.Detalhe.AdicionarCampoLabel('texto corpo', 1, 300, 0, 12);
  Relatorio.Detalhe.AdicionarCampoLabel('texto corpo 2', 30, 300, 0, 12);
  Relatorio.Detalhe.AdicionarCampoDBLabel('numero', 1, 50, 50, 12);
  Relatorio.Detalhe.AdicionarCampoDBLabel('emissao', 1, 150, 0, 12);
  // AdicionarShape('retangulo', 1, 1, 0, 18, _BaseRelatorio);
  Relatorio.Detalhe.AdicionarShape(tsLinha, 50, 0, 0, 5);
  Relatorio.Detalhe.AdicionarIncrementoAlturaBand(10);

  // AdicionarShape('linha', 1, 0, 0, 18, 'SeparadorPrincipal');

  ItensPedido := TSubDetalhamento.Create(Self, 'ItensPedido');
  // ItensPedido := TSubDetalhamento.Create(Self, 'ItensPedido', Cabecalho01, Detalhe01, Rodape01);
  ItensPedido.Cores($005F9EF5, $009BC2F9, $00D1E3FC);
  ItensPedido.DataSet := Detalhe01.DataSet;
  ItensPedido.Cabecalho.AdicionarCampoLabel('numero-->', 1, 50, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoDBLabel('NUMERO', 1, 50, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoDBLabel('PRODUTO', 1, 200, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoLabel('texto fixo itens', 10, 300, 0, 10);
  ItensPedido.Rodape.AdicionarCampoLabel('numero<--', 1, 50, 0, 10);
  FreeAndNil(ItensPedido);

  Ordem := TSubDetalhamento.Create(Self, 'Ordem');
  // Ordem := TSubDetalhamento.Create(Self, 'Ordem', Cabecalho02, Detalhe02, Rodape02);
  Ordem.Cores($00D0EB76, $00E3F3AB, $00BEE340);
  Ordem.DataSet := Detalhe02.DataSet;
  Ordem.Cabecalho.AdicionarCampoLabel('ordem-->', 1, 50, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('NUMERO', 1, 1, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('ORDEM', 1, 50, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('VCTO', 1, 100, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('VALOR', 1, 250, 0, 10);
  Ordem.Detalhe.AdicionarCampoLabel('texto fixo ordem', 1, 400, 0, 10);
  Ordem.Rodape.AdicionarCampoLabel('ordem<--', 1, 50, 0, 10);
  FreeAndNil(Ordem);

  Bloqueio := TSubDetalhamento.Create(Self, 'Bloqueio');
  // Bloqueio := TSubDetalhamento.Create(Self, 'Bloqueio', Cabecalho03, Detalhe03, Rodape03);
  Bloqueio.Cores($00FFAC59, $00FFD8B0, $00FFC891);
  Bloqueio.DataSet := Detalhe03.DataSet;
  Bloqueio.Cabecalho.AdicionarCampoLabel('bloqueio-->', 1, 50, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('PEDIDO', 1, 1, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('MOTIVO', 1, 50, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('AUTORIZADO', 1, 100, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoLabel('texto fixo bloqueio', 1, 400, 0, 10);
  Bloqueio.Rodape.AdicionarCampoLabel('bloqueio<--', 1, 50, 0, 10);
  FreeAndNil(Bloqueio);

  FreeAndNil(Relatorio);
end;

procedure TRelatorioNovaImpressao.MontarRelatorioDinamico();
var
  ItensPedido, Ordem, Bloqueio: TSubDetalhamento;
  Relatorio: TDetalhamento;
  SQL: String;
begin
  Relatorio := TDetalhamento.Create(Self, 'Relatorio');
  Relatorio.DataSet := Self.DataSet;
  Relatorio.Cabecalho.AdicionarCampoLabel('Total Itens: ' + IntToStr(Self.DataSet.RecordCount), 1, 300, 0, 12);
  Relatorio.Cabecalho.AdicionarCampoLabel('texto fixo em toda pagina  ', 1, 100, 0, 12);
  Relatorio.Rodape.AdicionarCampoLabel('texto fixo em todo rodape ', 1, 100, 0, 12);
  Relatorio.Detalhe.AdicionarCampoLabel('texto corpo', 1, 300, 0, 12);
  Relatorio.Detalhe.AdicionarCampoLabel('texto corpo 2', 30, 300, 0, 12);
  Relatorio.Detalhe.AdicionarCampoDBLabel('numero', 1, 50, 50, 12);
  Relatorio.Detalhe.AdicionarCampoDBLabel('emissao', 1, 150, 0, 12);
  Relatorio.Detalhe.AdicionarShape(tsLinha, 50, 0, 0, 5);
  Relatorio.Detalhe.AdicionarIncrementoAlturaBand(10);

  ItensPedido := TSubDetalhamento.Create(Self, 'ItensPedido');
  ItensPedido.Cores($005F9EF5, $009BC2F9, $00D1E3FC);
  SQL := '';
  ItensPedido.DataSet := CriarDataSetDinamico(Self, SQL, [''], ['codigo'], Relatorio.DataSource);
  ItensPedido.Cabecalho.AdicionarCampoLabel('numero-->', 1, 50, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoDBLabel('NUMERO', 1, 50, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoDBLabel('PRODUTO', 1, 200, 0, 10);
  ItensPedido.Detalhe.AdicionarCampoLabel('texto fixo itens', 10, 300, 0, 10);
  ItensPedido.Rodape.AdicionarCampoLabel('numero<--', 1, 50, 0, 10);
  FreeAndNil(ItensPedido);

  Ordem := TSubDetalhamento.Create(Self, 'Ordem');
  Ordem.Cores($00D0EB76, $00E3F3AB, $00BEE340);
  Ordem.DataSet := Detalhe02.DataSet;
  Ordem.Cabecalho.AdicionarCampoLabel('ordem-->', 1, 50, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('NUMERO', 1, 1, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('ORDEM', 1, 50, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('VCTO', 1, 100, 0, 10);
  Ordem.Detalhe.AdicionarCampoDBLabel('VALOR', 1, 250, 0, 10);
  Ordem.Detalhe.AdicionarCampoLabel('texto fixo ordem', 1, 400, 0, 10);
  Ordem.Rodape.AdicionarCampoLabel('ordem<--', 1, 50, 0, 10);
  FreeAndNil(Ordem);

  Bloqueio := TSubDetalhamento.Create(Self, 'Bloqueio');
  Bloqueio.Cores($00FFAC59, $00FFD8B0, $00FFC891);
  Bloqueio.DataSet := Detalhe03.DataSet;
  Bloqueio.Cabecalho.AdicionarCampoLabel('bloqueio-->', 1, 50, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('PEDIDO', 1, 1, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('MOTIVO', 1, 50, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoDBLabel('AUTORIZADO', 1, 100, 0, 10);
  Bloqueio.Detalhe.AdicionarCampoLabel('texto fixo bloqueio', 1, 400, 0, 10);
  Bloqueio.Rodape.AdicionarCampoLabel('bloqueio<--', 1, 50, 0, 10);
  FreeAndNil(Bloqueio);

  FreeAndNil(Relatorio);
end;

end.
