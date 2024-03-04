unit LogUnit;

interface

uses
  SysUtils;

procedure Log(const Mensagem, NomeArquivoLog: string);

implementation

procedure Log(const Mensagem, NomeArquivoLog: string);
var
  ArquivoLog: TextFile;
  CaminhoPasta, CaminhoArquivo: string;
begin
  // Obtém o caminho completo para o executável atual
  CaminhoPasta := ExtractFilePath(ParamStr(0));

  // Adiciona o nome da pasta de logs ao caminho
  CaminhoPasta := IncludeTrailingPathDelimiter(CaminhoPasta) + 'Logs';

  try
    // Verifica se a pasta de logs existe, se não, cria
    if not DirectoryExists(CaminhoPasta) then
      ForceDirectories(CaminhoPasta);

    // Adiciona o nome do arquivo de log ao caminho
    CaminhoArquivo := IncludeTrailingPathDelimiter(CaminhoPasta) + NomeArquivoLog + '.txt';

    // Abre o arquivo de log em modo de acrescentar, criando-o se não existir
    AssignFile(ArquivoLog, CaminhoArquivo);
    if not FileExists(CaminhoArquivo) then
      Rewrite(ArquivoLog)
    else
      Append(ArquivoLog);

    // Escreve a mensagem de log no arquivo
    Writeln(ArquivoLog, DateTimeToStr(Now) + ' - ' + Mensagem);
  finally
    // Fecha o arquivo de log
    CloseFile(ArquivoLog);
  end;
end;

end.

