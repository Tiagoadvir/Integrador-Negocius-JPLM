unit uConstante;

interface

uses
  RESTRequest4D,

  System.Classes,
  System.JSON,
  System.SysUtils;
const URL = 'http://localhost:9000';
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
    lResp := TRequest.New.BaseURL('http://localhost:9010/token')
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
