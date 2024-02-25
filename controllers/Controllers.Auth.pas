unit Controllers.Auth;

interface
  uses Horse,
     Horse.JWT,
     JOSE.Core.JWT,
     JOSE.Types.JSON,
     JOSE.Core.Builder,
     System.JSON,
     System.SysUtils;

  Const
   SECRET = 'PASS@801D07ET!@#$%�&*(';

 type
  TMyClaims = class(TJWTClaims)
  private
    function GetCodUsuario: integer;
    procedure SetCodUsuario(const Value: integer);
  public
    property COD_USUARIO: integer read GetCodUsuario write SetCodUsuario;
  end;

  function Criar_Token(cod_usuario: integer): string;
  function Get_Usuario_Request(Req: THorseRequest): integer;

implementation

{ TMyClaims }

//Cria o token JWT
function Criar_Token(cod_usuario: integer): string;
var
    jwt: TJWT;
    claims: TMyClaims;    //Informa��es contidas no token
 begin
     try
        jwt := TJWT.Create;
        claims := TMyClaims(jwt.Claims);

          try    //salvo o c�digo do usu�rio
               claims.COD_USUARIO := cod_usuario;

               //devolve o token gerado e criptografado
               //passo o SECRET,  o JWT  como parametro.
               Result := TJOSE.SHA256CompactToken(SECRET, jwt);
          except
               Result := '';
          end;

     finally
          FreeAndNil(jwt);
     end;
 end;

//Le o c�digo de usuario que est� contido dentro do token
function Get_usuario_Request (Req :THorseRequest ) : Integer;
var
 claims : TMyClaims;
 begin
   claims:= Req.Session<TMyClaims>; //pego o quequest, e pego a sess�o, digo que � do tip tmyclaims
   result := claims.COD_USUARIO;   //devolve o c�digo do usu�rio
 end;


function TMyClaims.GetCodUsuario: integer;
begin
    Result := FJSON.GetValue<integer>('id', 0);
end;

procedure TMyClaims.SetCodUsuario(const Value: integer);
begin
    TJSONUtils.SetJSONValueFrom<integer>('id', Value, FJSON);
end;

end.
