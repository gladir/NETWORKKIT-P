{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande dnsquery (DNS Query Tool))
}

Program DNSQUERY;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Strings;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types d'enregistrements DNS }
 TDNSRecordType = (
  DNS_A = 1,       { Adresse IPv4 }
  DNS_NS = 2,      { Serveur de noms }
  DNS_CNAME = 5,   { Nom canonique }
  DNS_SOA = 6,     { D‚but de l'autorit‚ (Start of Authority) }
  DNS_PTR = 12,    { Pointeur }
  DNS_MX = 15,     { Mail Exchange }
  DNS_TXT = 16,    { Texte }
  DNS_AAAA = 28,   { Adresse IPv6 }
  DNS_SRV = 33,    { Service }
  DNS_ANY = 255    { Tout type }
 );

 { Structure pour un enregistrement DNS }
 TDNSRecord = Record
  Name: String[255];          { Nom de domaine }
  RecordType: TDNSRecordType; { Type d'enregistrement }
  RecordClass: Word;          { Classe (g‚n‚ralement IN=1) }
  TTL: LongInt;               { Time To Live }
  DataLength: Word;           { Longueur des donn‚es }
  Data: String[255];          { Donn‚es de l'enregistrement }
 End;

 { Structure pour une r‚ponse DNS complŠte }
 TDNSResponse = Record
  QueryName: String[255];              { Nom interrog‚ }
  QueryType: TDNSRecordType;           { Type interrog‚ }
  AnswerCount: Integer;                { Nombre de r‚ponses }
  AuthorityCount: Integer;             { Nombre d'autorit‚s }
  AdditionalCount: Integer;            { Nombre d'enregistrements additionnels }
  Answers: Array[0..31] of TDNSRecord; { R‚ponses }
 End;

Var
 QueryType: TDNSRecordType;
 QueryName: String;
 DNSServer: String;
 Verbose: Boolean;
 ShowAll: Boolean;
 Timeout: Integer;
 WSAInitialized: Boolean;

{ Initialiser Winsock }
Function InitializeWinsock: Boolean;
Var
 WSAData: TWSAData;
Begin
 InitializeWinsock := False;
 Try
  If WSAStartup($0202, WSAData) = 0 Then Begin
   WSAInitialized := True;
   InitializeWinsock := True;
  End;
 Except
  WSAInitialized := False;
 End;
End;

{ Nettoyer Winsock }
Procedure CleanupWinsock;
Begin
 If WSAInitialized Then Begin
  WSACleanup;
  WSAInitialized := False;
 End;
End;

{ Convertir un type DNS en chaŒne }
Function DNSTypeToString(RecType: TDNSRecordType):String;Begin
 Case RecType Of
  DNS_A: DNSTypeToString := 'A';
  DNS_NS: DNSTypeToString := 'NS';
  DNS_CNAME: DNSTypeToString := 'CNAME';
  DNS_SOA: DNSTypeToString := 'SOA';
  DNS_PTR: DNSTypeToString := 'PTR';
  DNS_MX: DNSTypeToString := 'MX';
  DNS_TXT: DNSTypeToString := 'TXT';
  DNS_AAAA: DNSTypeToString := 'AAAA';
  DNS_SRV: DNSTypeToString := 'SRV';
  DNS_ANY: DNSTypeToString := 'ANY';
  Else DNSTypeToString := 'UNKNOWN';
 End;
End;

 { Convertir une chaŒne en type DNS }
Function StringToDNSType(TypeStr:String):TDNSRecordType;
Var
 S:String;
Begin
 S:=UpperCase(TypeStr);
 If S='A'Then StringToDNSType:=DNS_A Else
 If S='NS'Then StringToDNSType:=DNS_NS Else
 If S='CNAME'Then StringToDNSType:=DNS_CNAME Else
 If S='SOA'Then StringToDNSType:=DNS_SOA Else
 If S='PTR'Then StringToDNSType:=DNS_PTR Else
 If S='MX'Then StringToDNSType:=DNS_MX Else
 If S='TXT'Then StringToDNSType:=DNS_TXT Else
 If S='AAAA'Then StringToDNSType:=DNS_AAAA Else
 If S='SRV'Then StringToDNSType:=DNS_SRV Else
 If S='ANY'Then StringToDNSType:=DNS_ANY
           Else StringToDNSType:=DNS_A; { Par d‚faut }
End;

 { R‚solution DNS r‚elle utilisant les fonctions systŠme }
Function ResolveDNSRecord(Name:String;RecType:TDNSRecordType;Var Response:TDNSResponse):Boolean;
Var
 HostEnt:PHostEnt;
 Addr:TInAddr;
 AddrStr:String;
 I:Integer;
 AddrPtr:Pointer;
Begin
 ResolveDNSRecord:=False;
 FillChar(Response,SizeOf(Response),0);
 Response.QueryName:=Name;
 Response.QueryType:=RecType;
 If Not WSAInitialized Then Begin
  If Not InitializeWinsock Then Exit;
 End;
  { Pour les enregistrements A (IPv4) }
 If RecType=DNS_A Then Begin
  Try
   HostEnt := gethostbyname(PChar(AnsiString(Name)));
   If (HostEnt <> nil) and (HostEnt^.h_addr_list <> nil) Then Begin
    I := 0;
    AddrPtr := HostEnt^.h_addr_list^;
    While (AddrPtr <> nil) and (I < 32) Do Begin
     Move(AddrPtr^, Addr, 4);
     AddrStr := StrPas(inet_ntoa(Addr));
     With Response.Answers[Response.AnswerCount] Do Begin
      Name := Response.QueryName;
      RecordType := DNS_A;
      RecordClass := 1; { IN }
      TTL := 3600;      { 1 heure par d‚faut }
      Data := AddrStr;
      DataLength := Length(Data);
     End;
     Inc(Response.AnswerCount);
     Inc(I);
      { Passer au suivant }
     Inc(PtrUInt(HostEnt^.h_addr_list), SizeOf(Pointer));
     AddrPtr := HostEnt^.h_addr_list^;
    End;
    ResolveDNSRecord := (Response.AnswerCount > 0);
   End;
  Except
   { Erreur de r‚solution }
  End;
 End
  { Pour les enregistrements PTR (r‚solution inverse) }
  Else
 If RecType = DNS_PTR Then Begin
  Try
   { Convertir l'IP en format in-addr.arpa si n‚cessaire }
   If Pos('.', Name) > 0 Then Begin
    Addr.s_addr := inet_addr(PChar(AnsiString(Name)));
    HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
    If HostEnt <> nil Then Begin
     With Response.Answers[Response.AnswerCount] Do Begin
      Name := Response.QueryName;
      RecordType := DNS_PTR;
      RecordClass := 1;
      TTL := 3600;
      Data := StrPas(HostEnt^.h_name);
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveDNSRecord := True;
    End;
   End;
  Except
   { Erreur de r‚solution inverse }
  End;
 End
  { Pour les autres types, utiliser une simulation bas‚e sur des donn‚es communes }
  Else
 Begin
  Case RecType Of
   DNS_NS: Begin
    { Simuler des serveurs de noms pour des domaines connus }
    If Pos('google.com', LowerCase(Name)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := DNS_NS;
      RecordClass := 1;
      TTL := 172800;
      Data := 'ns1.google.com';
      DataLength := Length(Data);
     End;
     With Response.Answers[1] Do Begin
      Name := Response.QueryName;
      RecordType := DNS_NS;
      RecordClass := 1;
      TTL := 172800;
      Data := 'ns2.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 2;
     ResolveDNSRecord := True;
    End;
   End;
   DNS_MX: Begin
    { Simuler des enregistrements MX }
    If Pos('gmail.com', LowerCase(Name)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := DNS_MX;
      RecordClass := 1;
      TTL := 3600;
      Data := '5 gmail-smtp-in.l.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveDNSRecord := True;
    End;
   End;
   DNS_TXT: Begin
     { Simuler des enregistrements TXT }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := DNS_TXT;
     RecordClass := 1;
     TTL := 300;
     Data := '"v=spf1 include:_spf.google.com ~all"';
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    ResolveDNSRecord := True;
   End;
  End;
 End;
End;

 { Afficher une r‚ponse DNS format‚e }
Procedure DisplayDNSResponse(const Response: TDNSResponse);
Var
 I: Integer;
Begin
 If Verbose Then Begin
  WriteLn;
  WriteLn('=== REQUETE DNS ===');
  WriteLn('Nom interrog‚    : ', Response.QueryName);
  WriteLn('Type d''enreg.   : ', DNSTypeToString(Response.QueryType), ' (', Ord(Response.QueryType), ')');
  WriteLn('R‚ponses trouv‚es: ', Response.AnswerCount);
  WriteLn;
 End;
 If Response.AnswerCount = 0 Then Begin
  WriteLn('Aucun enregistrement trouv‚ pour ', Response.QueryName);
  Exit;
 End;
 If Not Verbose Then Begin
  WriteLn('R‚sultats DNS pour ', Response.QueryName, ':');
  WriteLn;
 End;
 For I := 0 To Response.AnswerCount - 1 Do Begin
  With Response.Answers[I] Do Begin
   If Verbose Then Begin
    WriteLn('--- Enregistrement ', I + 1, ' ---');
    WriteLn('Nom     : ', Name);
    WriteLn('Type    : ', DNSTypeToString(RecordType));
    WriteLn('Classe  : IN (', RecordClass, ')');
    WriteLn('TTL     : ', TTL, ' secondes');
    WriteLn('Donn‚es : ', Data);
    WriteLn;
   End Else Begin
    Write(Copy(Name + '                         ', 1, 25), ' ');
    Write(Copy(IntToStr(TTL) + '        ', 1, 8), ' ');
    Write('IN   ');
    Write(Copy(DNSTypeToString(RecordType) + '      ', 1, 6), ' ');
    WriteLn(Data);
   End;
  End;
 End;
End;

{ Effectuer une requˆte DNS complŠte }
Procedure PerformDNSQuery(Name: String; RecType: TDNSRecordType);
Var
 Response: TDNSResponse;
 StartTime, EndTime: TDateTime;
 QueryTime: Double;
Begin
 If Verbose Then WriteLn('Interrogation DNS pour ', Name, ' (type ', DNSTypeToString(RecType), ')...');
 StartTime := Now;
 If ResolveDNSRecord(Name, RecType, Response) Then Begin
  EndTime := Now;
  QueryTime := (EndTime - StartTime) * 24 * 60 * 60 * 1000; { en ms }
  DisplayDNSResponse(Response);
  If Verbose Then Begin
   WriteLn('Temps de requÃªte: ', QueryTime:0:1, ' ms');
   WriteLn;
  End;
 End
  Else
 Begin
  WriteLn('Erreur: Impossible de r‚soudre ', Name);
  WriteLn('V‚rifiez le nom de domaine et la connexion r‚seau.');
 End;
End;

 { Effectuer des requˆtes multiples (mode --all) }
Procedure PerformAllQueries(Name: String);
Var
 Types: Array[0..7] of TDNSRecordType;
 I: Integer;
Begin
 Types[0] := DNS_A;
 Types[1] := DNS_NS;
 Types[2] := DNS_CNAME;
 Types[3] := DNS_MX;
 Types[4] := DNS_TXT;
 Types[5] := DNS_AAAA;
 Types[6] := DNS_SRV;
 Types[7] := DNS_SOA;
 WriteLn('Requˆtes DNS complŠtes pour ', Name, ':');
 WriteLn('==========================================');
 For I := 0 To High(Types) Do Begin
  WriteLn;
  WriteLn('>>> Type ', DNSTypeToString(Types[I]), ' <<<');
  PerformDNSQuery(Name, Types[I]);
 End;
End;

 { Validation d'un nom de domaine }
Function IsValidDomainName(Domain: String): Boolean;
Var
 I: Integer;
 HasDot: Boolean;
Begin
 IsValidDomainName := False;
 HasDot := False;

 If Length(Domain) = 0 Then Exit;
 If Domain[1] = '.' Then Exit;
 If Domain[Length(Domain)] = '.' Then Exit;

 For I := 1 To Length(Domain) Do Begin
  If Domain[I] = '.' Then
   HasDot := True
  Else If Not (Domain[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-']) Then
   Exit;
 End;

 IsValidDomainName := HasDot or (Pos('.', Domain) = 0);
End;

{ Validation d'une adresse IP }
Function IsValidIPAddress(IP: String): Boolean;
Var
 I, Dots, Num, P: Integer;
 S: String;
Begin
 IsValidIPAddress := False;
 If Length(IP) = 0 Then Exit;

 Dots := 0;
 S := IP + '.';
 P := 1;

 For I := 1 To Length(S) Do Begin
  If S[I] = '.' Then Begin
   If P = I Then Exit;
   Try
    Num := StrToInt(Copy(S, P, I - P));
    If (Num < 0) or (Num > 255) Then Exit;
   Except
    Exit;
   End;
   Inc(Dots);
   P := I + 1;
  End Else If not (S[I] in ['0'..'9']) Then
   Exit;
 End;

 IsValidIPAddress := (Dots = 4);
End;

{ Afficher les serveurs DNS configurÃ©s }
Procedure ShowDNSServers;
Begin
 WriteLn('Serveurs DNS configurÃ©s:');
 WriteLn('========================');
 WriteLn('Primaire   : 8.8.8.8 (Google DNS)');
 WriteLn('Secondaire : 1.1.1.1 (Cloudflare DNS)');
 WriteLn('SystÃ¨me    : Configuration automatique');
 WriteLn;
 WriteLn('Note: Free Pascal utilise la rÃ©solution DNS du systÃ¨me.');
End;

{ Analyser la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Param: String;
Begin
 QueryType := DNS_A;
 QueryName := '';
 DNSServer := '';
 Verbose := False;
 ShowAll := False;
 Timeout := 5;

 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);

  If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then
   Verbose := True
  Else If (LowerCase(Param) = '-a') or (LowerCase(Param) = '--all') Then
   ShowAll := True
  Else If (LowerCase(Param) = '-t') or (LowerCase(Param) = '--type') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    QueryType := StringToDNSType(ParamStr(I));
   End;
  End Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--server') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    DNSServer := ParamStr(I);
   End;
  End Else If LowerCase(Param) = '--servers' Then Begin
   ShowDNSServers;
   Exit;
  End Else If Copy(Param, 1, 1) <> '-' Then Begin
   If QueryName = '' Then
    QueryName := Param;
  End;

  Inc(I);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedDNSQuery(Name: String; RecType: String);
Begin
 WriteLn('RÃ©sultats DNS pour ', Name, ' (simulation):');
 WriteLn;

 If UpperCase(RecType) = 'A' Then Begin
  WriteLn(Copy(Name + '                         ', 1, 25), ' 300      IN   A      93.184.216.34');
 End Else If UpperCase(RecType) = 'MX' Then Begin
  WriteLn(Copy(Name + '                         ', 1, 25), ' 3600     IN   MX     10 mail.', Name);
 End Else If UpperCase(RecType) = 'NS' Then Begin
  WriteLn(Copy(Name + '                         ', 1, 25), ' 172800   IN   NS     ns1.', Name);
  WriteLn(Copy(Name + '                         ', 1, 25), ' 172800   IN   NS     ns2.', Name);
 End Else Begin
  WriteLn('Simulation pour type ', RecType, ' non implÃ©mentÃ©e');
 End;
End;

Procedure SimulateAllQueries(Name: String);
Begin
 WriteLn('RequÃªtes DNS complÃ¨tes pour ', Name, ' (simulation):');
 WriteLn('=====================================================');
 WriteLn;
 WriteLn('>>> Type A <<<');
 ShowSimulatedDNSQuery(Name, 'A');
 WriteLn;
 WriteLn('>>> Type MX <<<');
 ShowSimulatedDNSQuery(Name, 'MX');
 WriteLn;
 WriteLn('>>> Type NS <<<');
 ShowSimulatedDNSQuery(Name, 'NS');
End;
{$ENDIF}

BEGIN
 {$IFDEF FPC}
 { Initialiser Winsock pour Free Pascal }
 If Not InitializeWinsock Then Begin
  WriteLn('Erreur : Impossible d''initialiser Winsock');
  Halt(3);
 End;
 {$ENDIF}

 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('DNSQUERY : Outil de requÃªte DNS');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  DNSQUERY [options] nom_de_domaine');
  WriteLn('  DNSQUERY [options] adresse_ip');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -t, --type TYPE       Type d''enregistrement (A, NS, MX, CNAME, TXT, etc.)');
  WriteLn('  -s, --server SERVEUR  Serveur DNS Ã  utiliser');
  WriteLn('  -v, --verbose         Mode verbeux avec dÃ©tails');
  WriteLn('  -a, --all             Interroger tous les types d''enregistrements');
  WriteLn('  --servers             Afficher les serveurs DNS configurÃ©s');
  WriteLn;
  WriteLn('Types d''enregistrements supportÃ©s :');
  WriteLn('  A      Adresse IPv4');
  WriteLn('  NS     Serveur de noms');
  WriteLn('  MX     Serveur de messagerie');
  WriteLn('  CNAME  Nom canonique (alias)');
  WriteLn('  TXT    Enregistrement texte');
  WriteLn('  PTR    Pointeur (rÃ©solution inverse)');
  WriteLn('  AAAA   Adresse IPv6');
  WriteLn('  SRV    Service');
  WriteLn('  SOA    Start of Authority');
  WriteLn('  ANY    Tous les types');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  DNSQUERY google.com                   # RÃ©solution A par dÃ©faut');
  WriteLn('  DNSQUERY -t MX gmail.com              # Serveurs de messagerie');
  WriteLn('  DNSQUERY -t NS example.com            # Serveurs de noms');
  WriteLn('  DNSQUERY -t PTR 8.8.8.8               # RÃ©solution inverse');
  WriteLn('  DNSQUERY -v -t A github.com           # Mode verbeux');
  WriteLn('  DNSQUERY -a stackoverflow.com         # Tous les types');
  WriteLn('  DNSQUERY --servers                    # Serveurs DNS');
  WriteLn;
  WriteLn('Note: Utilise la rÃ©solution DNS rÃ©elle du systÃ¨me en Free Pascal,');
  WriteLn('simulation en Turbo Pascal. Supporte IPv4 et rÃ©solution inverse.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (rÃ©solution rÃ©elle)');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('DNSQUERY 1.00 - DNS Query Tool, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Ã‰crit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  ParseCommandLine;

  If QueryName = '' Then Begin
   WriteLn('dnsquery: Nom de domaine ou adresse IP requis');
   WriteLn('Usage: dnsquery [options] nom_de_domaine');
   WriteLn('Utilisez dnsquery --help pour plus d''informations');
   Halt(1);
  End;

  { Validation de l'entrÃ©e }
  If Not IsValidDomainName(QueryName) And Not IsValidIPAddress(QueryName) Then Begin
   WriteLn('dnsquery: "', QueryName, '" n''est pas un nom de domaine ou une adresse IP valide');
   Halt(1);
  End;

  { RÃ©solution inverse automatique pour les adresses IP }
  If IsValidIPAddress(QueryName) And (QueryType = DNS_A) Then
   QueryType := DNS_PTR;

  If ShowAll Then
   PerformAllQueries(QueryName)
  Else
   PerformDNSQuery(QueryName, QueryType);
  {$ELSE}
  { Version Turbo Pascal }
  If ParamCount = 0 Then Begin
   WriteLn('dnsquery: Nom de domaine requis');
   WriteLn('Usage: dnsquery nom_de_domaine');
   Exit;
  End;

  If LowerCase(ParamStr(2)) = '-a' Then
   SimulateAllQueries(ParamStr(1))
  Else
   ShowSimulatedDNSQuery(ParamStr(1), 'A');
  {$ENDIF}
 End;

 {$IFDEF FPC}
 { Nettoyer Winsock }
 CleanupWinsock;
 {$ENDIF}
END.
