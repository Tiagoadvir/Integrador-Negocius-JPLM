unit uConstante;

interface

uses
  RESTRequest4D,

  System.Classes,
  System.JSON,
  System.SysUtils;
const URL_AUTORIZACAO = 'http://18.117.91.127:3001';
const URL_PEDIDO = 'http://localhost:9002';
const URL_CLIENTE = 'http://localhost:9004';
const URL_PRODUTOS = 'http://localhost:9005';
const URL_PRAZO = 'http://localhost:9006';
const URL_REPRESENTANTE = 'http://localhost:9003';
const URL_AWS = 'http://18.117.91.127:3001';
 //chaves para o aes
  Key  =  'Key1234567890-1234567890-1234567';
  IV   =  '1234567890123456';
var ClienteID : string;
var SecretID  : string;


type
TGetToken = class

class function SolicitaToken : string;
end;

implementation

{ TGetToken }

class function TGetToken.SolicitaToken : string;
var
 lResp : Iresponse;
begin
    lResp := TRequest.New.BaseURL(URL_AUTORIZACAO)
             .Resource('/token')
             .ContentType('application/json')
             .AddBody(TJSONObject.Create
               .AddPair('grant_type', 'client_credentials'))
             .BasicAuthentication(ClienteID, SecretID)
             .Post;

    if lResp.StatusCode <> 200 then
       raise Exception.Create(lresp.Content)
    else
    Result := lResp.JSONValue.GetValue<string>('access_token');

end;

end.
