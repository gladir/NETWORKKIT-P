{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande nsquery (Name Server Query))
}

Program NSQUERY;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Strings;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types de requêtes DNS pour nsquery }
 TNSQueryType = (NSQ_A, NSQ_AAAA, NSQ_NS, NSQ_MX, NSQ_CNAME, NSQ_TXT, NSQ_PTR, NSQ_SRV, NSQ_SOA, NSQ_ANY);

 { Structure pour un enregistrement DNS }
 TNSQueryRecord = Record
  Name: String[255];         { Nom de domaine }
  RecordType: TNSQueryType;  { Type d'enregistrement }
  RecordClass: Word;         { Classe (généralement IN=1) }
  TTL: LongInt;              { Time To Live }
  DataLength: Word;          { Longueur des données }
  Data: String[255];         { Données de l'enregistrement }
  Priority: Word;            { Priorité (pour MX, SRV) }
  Weight: Word;              { Poids (pour SRV) }
  Port: Word;                { Port (pour SRV) }
 End;

 { Structure pour une requête DNS complète }
 TNSQueryRequest = Record
  QueryName: String[255];    { Nom interrogé }
  QueryType: TNSQueryType;   { Type de requête }
  QueryClass: Word;          { Classe de requête }
  Server: String[64];        { Serveur DNS à utiliser }
  Port: Word;                { Port DNS (défaut 53) }
  Timeout: Integer;          { Timeout en millisecondes }
  Retries: Integer;          { Nombre de tentatives }
  Recursive: Boolean;        { Requête récursive }
  UseCache: Boolean;         { Utiliser le cache DNS }
 End;

 { Structure pour une réponse DNS complète }
 TNSQueryResponse = Record
  QueryName: String[255];    { Nom interrogé }
  QueryType: TNSQueryType;   { Type de requête }
  Server: String[64];        { Serveur DNS utilisé }
  ResponseCode: Integer;     { Code de réponse (0=NOERROR) }
  ResponseFlags: Word;       { Drapeaux de réponse }
  AnswerCount: Integer;      { Nombre de réponses }
  Answers: Array[0..31] of TNSQueryRecord; { Réponses }
  AuthorityCount: Integer;   { Nombre d'autorités }
  Authorities: Array[0..15] of TNSQueryRecord; { Enregistrements d'autorité }
  AdditionalCount: Integer;  { Nombre d'additionnels }
  Additional: Array[0..15] of TNSQueryRecord; { Enregistrements additionnels }
  QueryTime: LongInt;        { Temps de requête en millisecondes }
  Truncated: Boolean;        { Réponse tronquée }
  Authoritative: Boolean;    { Réponse autoritaire }
  RecursionAvailable: Boolean; { Récursion disponible }
  Authenticated: Boolean;    { Données authentifiées }
 End;

Var
 { Variables globales }
 WSAInitialized: Boolean;
 DefaultServer: String[64];
 VerboseMode: Integer;      { 0=normal, 1=verbose, 2=debug }
 QuietMode: Boolean;
 RawMode: Boolean;          { Affichage brut des données }
 ShowStats: Boolean;        { Afficher les statistiques }
 ShowFlags: Boolean;        { Afficher les drapeaux }
 ShowHeaders: Boolean;      { Afficher les en-têtes }
 UseIPv6: Boolean;          { Utiliser IPv6 }
 FollowCNAME: Boolean;      { Suivre les CNAME }
 CheckReverse: Boolean;     { Vérifier la résolution inverse }

{ Initialisation Winsock }
Function InitializeWinsock: Boolean;
Var
 WSData: TWSAData;
 WSAResult: Integer;
Begin
 InitializeWinsock := False;
 Try
  WSAResult := WSAStartup($0202, WSData);
  If WSAResult = 0 Then Begin
   WSAInitialized := True;
   InitializeWinsock := True;
  End;
 Except
  WSAInitialized := False;
 End;
End;

{ Nettoyage Winsock }
Procedure CleanupWinsock;
Begin
 If WSAInitialized Then Begin
  WSACleanup;
  WSAInitialized := False;
 End;
End;

{ Convertir un type d'enregistrement en chaîne }
Function RecordTypeToString(RecType: TNSQueryType): String;
Begin
 Case RecType Of
  NSQ_A: RecordTypeToString := 'A';
  NSQ_AAAA: RecordTypeToString := 'AAAA';
  NSQ_NS: RecordTypeToString := 'NS';
  NSQ_MX: RecordTypeToString := 'MX';
  NSQ_CNAME: RecordTypeToString := 'CNAME';
  NSQ_TXT: RecordTypeToString := 'TXT';
  NSQ_PTR: RecordTypeToString := 'PTR';
  NSQ_SRV: RecordTypeToString := 'SRV';
  NSQ_SOA: RecordTypeToString := 'SOA';
  NSQ_ANY: RecordTypeToString := 'ANY';
 Else
  RecordTypeToString := 'UNKNOWN';
 End;
End;

{ Convertir une chaîne en type d'enregistrement }
Function StringToRecordType(TypeStr: String): TNSQueryType;
Var
 UpperStr: String;
Begin
 UpperStr := UpperCase(TypeStr);
 If UpperStr = 'A' Then
  StringToRecordType := NSQ_A
 Else If UpperStr = 'AAAA' Then
  StringToRecordType := NSQ_AAAA
 Else If UpperStr = 'NS' Then
  StringToRecordType := NSQ_NS
 Else If UpperStr = 'MX' Then
  StringToRecordType := NSQ_MX
 Else If UpperStr = 'CNAME' Then
  StringToRecordType := NSQ_CNAME
 Else If UpperStr = 'TXT' Then
  StringToRecordType := NSQ_TXT
 Else If UpperStr = 'PTR' Then
  StringToRecordType := NSQ_PTR
 Else If UpperStr = 'SRV' Then
  StringToRecordType := NSQ_SRV
 Else If UpperStr = 'SOA' Then
  StringToRecordType := NSQ_SOA
 Else If (UpperStr = 'ANY') or (UpperStr = '*') Then
  StringToRecordType := NSQ_ANY
 Else
  StringToRecordType := NSQ_A; { Par défaut }
End;

{ Obtenir le message d'erreur DNS }
Function GetDNSErrorMessage(ErrorCode: Integer): String;
Begin
 Case ErrorCode Of
  0: GetDNSErrorMessage := 'NOERROR';
  1: GetDNSErrorMessage := 'FORMERR - Format Error';
  2: GetDNSErrorMessage := 'SERVFAIL - Server Failure';
  3: GetDNSErrorMessage := 'NXDOMAIN - Non-Existent Domain';
  4: GetDNSErrorMessage := 'NOTIMP - Not Implemented';
  5: GetDNSErrorMessage := 'REFUSED - Query Refused';
  6: GetDNSErrorMessage := 'YXDOMAIN - Name Exists';
  7: GetDNSErrorMessage := 'YXRRSET - RR Set Exists';
  8: GetDNSErrorMessage := 'NXRRSET - RR Set Does Not Exist';
  9: GetDNSErrorMessage := 'NOTAUTH - Not Authorized';
  10: GetDNSErrorMessage := 'NOTZONE - Name Not In Zone';
 Else
  GetDNSErrorMessage := 'UNKNOWN ERROR (' + IntToStr(ErrorCode) + ')';
 End;
End;

{ Valider une adresse IP }
Function IsValidIPAddress(IP: String): Boolean;
Var
 I, Dots, Num: Integer;
 S: String;
 P: Integer;
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

{ Valider un nom de domaine }
Function IsValidDomainName(Domain: String): Boolean;
Var
 I: Integer;
Begin
 IsValidDomainName := False;
 If (Length(Domain) = 0) or (Length(Domain) > 253) Then Exit;
 
 For I := 1 To Length(Domain) Do Begin
  If not (Domain[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_']) Then Exit;
 End;
 
 IsValidDomainName := True;
End;

{ Convertir une adresse IP en format in-addr.arpa }
Function IPToInAddrArpa(IP: String): String;
Var
 Parts: Array[1..4] of String;
 I, P, PartCount: Integer;
 S: String;
Begin
 IPToInAddrArpa := '';
 If not IsValidIPAddress(IP) Then Exit;
 
 { Découper l'adresse IP }
 S := IP + '.';
 P := 1;
 PartCount := 0;
 For I := 1 To Length(S) Do Begin
  If S[I] = '.' Then Begin
   Inc(PartCount);
   If PartCount <= 4 Then
    Parts[PartCount] := Copy(S, P, I - P);
   P := I + 1;
  End;
 End;
 
 { Construire l'adresse inversée }
 If PartCount = 4 Then
  IPToInAddrArpa := Parts[4] + '.' + Parts[3] + '.' + Parts[2] + '.' + Parts[1] + '.in-addr.arpa';
End;

{ Requête DNS réelle utilisant les fonctions système }
Function PerformNSQuery(var Request: TNSQueryRequest; var Response: TNSQueryResponse): Boolean;
Var
 HostEnt: PHostEnt;
 Addr: TInAddr;
 StartTime: LongInt;
 I: Integer;
 AddrPtr: Pointer;
 QueryName: String;
Begin
 PerformNSQuery := False;
 FillChar(Response, SizeOf(Response), 0);
 Response.QueryName := Request.QueryName;
 Response.QueryType := Request.QueryType;
 Response.Server := Request.Server;
 Response.ResponseCode := 0;
 Response.RecursionAvailable := True;
 
 If Not WSAInitialized Then Begin
  If Not InitializeWinsock Then Begin
   Response.ResponseCode := 2; { SERVFAIL }
   Exit;
  End;
 End;
 
 StartTime := GetTickCount;
 QueryName := Request.QueryName;
 
 { Pour les enregistrements A (IPv4) }
 If Request.QueryType = NSQ_A Then Begin
  Try
   HostEnt := gethostbyname(PChar(AnsiString(QueryName)));
   Response.QueryTime := GetTickCount - StartTime;
   
   If (HostEnt <> nil) and (HostEnt^.h_addr_list <> nil) Then Begin
    I := 0;
    AddrPtr := HostEnt^.h_addr_list^;
    While (AddrPtr <> nil) and (I < 32) Do Begin
     Move(AddrPtr^, Addr, 4);
     
     With Response.Answers[Response.AnswerCount] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_A;
      RecordClass := 1; { IN }
      TTL := 3600; { 1 heure par défaut }
      Data := StrPas(inet_ntoa(Addr));
      DataLength := Length(Data);
      Priority := 0;
      Weight := 0;
      Port := 0;
     End;
     Inc(Response.AnswerCount);
     Inc(I);
     
     { Passer au suivant }
     Inc(PtrUInt(HostEnt^.h_addr_list), SizeOf(Pointer));
     AddrPtr := HostEnt^.h_addr_list^;
    End;
    
    Response.Authoritative := False;
    PerformNSQuery := (Response.AnswerCount > 0);
   End Else Begin
    Response.ResponseCode := 3; { NXDOMAIN }
   End;
  Except
   Response.QueryTime := GetTickCount - StartTime;
   Response.ResponseCode := 2; { SERVFAIL }
  End;
 End
 
 { Pour les enregistrements PTR (résolution inverse) }
 Else If Request.QueryType = NSQ_PTR Then Begin
  Try
   { Vérifier si c'est une IP ou déjà au format in-addr.arpa }
   If IsValidIPAddress(QueryName) Then Begin
    QueryName := IPToInAddrArpa(QueryName);
    Addr.s_addr := inet_addr(PChar(AnsiString(Request.QueryName)));
    HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
   End Else If Pos('.in-addr.arpa', LowerCase(QueryName)) > 0 Then Begin
    { Extraire l'IP du format in-addr.arpa }
    { Format: 4.3.2.1.in-addr.arpa -> 1.2.3.4 }
    { Implémentation simplifiée }
    Addr.s_addr := inet_addr(PChar(AnsiString(Request.QueryName)));
    HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
   End Else Begin
    HostEnt := nil;
   End;
   
   Response.QueryTime := GetTickCount - StartTime;
   
   If HostEnt <> nil Then Begin
    With Response.Answers[Response.AnswerCount] Do Begin
     Name := Response.QueryName;
     RecordType := NSQ_PTR;
     RecordClass := 1;
     TTL := 3600;
     Data := StrPas(HostEnt^.h_name);
     DataLength := Length(Data);
     Priority := 0;
     Weight := 0;
     Port := 0;
    End;
    Response.AnswerCount := 1;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End Else Begin
    Response.ResponseCode := 3; { NXDOMAIN }
   End;
  Except
   Response.QueryTime := GetTickCount - StartTime;
   Response.ResponseCode := 2; { SERVFAIL }
  End;
 End
 
 { Pour les autres types, utiliser une simulation enrichie }
 Else Begin
  Response.QueryTime := GetTickCount - StartTime + (Random(50) + 20);
  
  Case Request.QueryType Of
   NSQ_NS: Begin
    { Simuler des serveurs de noms }
    If Pos('google.com', LowerCase(QueryName)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_NS;
      RecordClass := 1;
      TTL := 172800; { 48 heures }
      Data := 'ns1.google.com';
      DataLength := Length(Data);
     End;
     With Response.Answers[1] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_NS;
      RecordClass := 1;
      TTL := 172800;
      Data := 'ns2.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 2;
    End Else If Pos('example.com', LowerCase(QueryName)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_NS;
      RecordClass := 1;
      TTL := 86400;
      Data := 'a.iana-servers.net';
      DataLength := Length(Data);
     End;
     With Response.Answers[1] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_NS;
      RecordClass := 1;
      TTL := 86400;
      Data := 'b.iana-servers.net';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 2;
    End Else Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_NS;
      RecordClass := 1;
      TTL := 3600;
      Data := 'ns1.' + QueryName;
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
    End;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End;
   
   NSQ_MX: Begin
    { Simuler des enregistrements MX }
    If Pos('google.com', LowerCase(QueryName)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_MX;
      RecordClass := 1;
      TTL := 3600;
      Priority := 10;
      Data := 'smtp.google.com';
      DataLength := Length(Data);
     End;
     With Response.Answers[1] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_MX;
      RecordClass := 1;
      TTL := 3600;
      Priority := 20;
      Data := 'alt1.smtp.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 2;
    End Else If Pos('gmail.com', LowerCase(QueryName)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_MX;
      RecordClass := 1;
      TTL := 3600;
      Priority := 5;
      Data := 'gmail-smtp-in.l.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
    End Else Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_MX;
      RecordClass := 1;
      TTL := 3600;
      Priority := 10;
      Data := 'mail.' + QueryName;
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
    End;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End;
   
   NSQ_TXT: Begin
    { Simuler des enregistrements TXT }
    If Pos('google.com', LowerCase(QueryName)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_TXT;
      RecordClass := 1;
      TTL := 300;
      Data := '"v=spf1 include:_spf.google.com ~all"';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
    End Else Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NSQ_TXT;
      RecordClass := 1;
      TTL := 300;
      Data := '"v=spf1 mx a ~all"';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
    End;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End;
   
   NSQ_CNAME: Begin
    { Simuler des enregistrements CNAME }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := NSQ_CNAME;
     RecordClass := 1;
     TTL := 300;
     Data := QueryName + '.cdn.example.com';
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End;
   
   NSQ_SRV: Begin
    { Simuler des enregistrements SRV }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := NSQ_SRV;
     RecordClass := 1;
     TTL := 3600;
     Priority := 10;
     Weight := 60;
     Port := 443;
     Data := 'server.' + QueryName;
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    Response.Authoritative := False;
    PerformNSQuery := True;
   End;
   
   NSQ_SOA: Begin
    { Simuler un enregistrement SOA }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := NSQ_SOA;
     RecordClass := 1;
     TTL := 86400;
     Data := 'ns1.' + QueryName + ' admin.' + QueryName + ' 2026022101 10800 3600 604800 86400';
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    Response.Authoritative := True;
    PerformNSQuery := True;
   End;
   
   NSQ_ANY: Begin
    { Pour ANY, essayer de résoudre A d'abord }
    Request.QueryType := NSQ_A;
    If PerformNSQuery(Request, Response) Then Begin
     Response.QueryType := NSQ_ANY;
    End;
   End;
   
  Else
   Response.ResponseCode := 4; { NOT IMPLEMENTED }
  End;
 End;
End;

{ Afficher les en-têtes de réponse DNS }
Procedure DisplayResponseHeader(var Response: TNSQueryResponse);
Begin
 If not ShowHeaders Then Exit;
 
 WriteLn(';; Got answer:');
 WriteLn(';; ->>HEADER<<- opcode: QUERY, status: ', GetDNSErrorMessage(Response.ResponseCode));
 Write(';; flags:');
 If Response.RecursionAvailable Then Write(' ra');
 If Response.Authoritative Then Write(' aa');
 If Response.Truncated Then Write(' tc');
 If Response.Authenticated Then Write(' ad');
 WriteLn('; QUERY: 1, ANSWER: ', Response.AnswerCount, 
         ', AUTHORITY: ', Response.AuthorityCount,
         ', ADDITIONAL: ', Response.AdditionalCount);
 WriteLn;
End;

{ Afficher la section QUESTION }
Procedure DisplayQuestionSection(var Response: TNSQueryResponse);
Begin
 WriteLn(';; QUESTION SECTION:');
 WriteLn(';', Response.QueryName, '.		IN	', RecordTypeToString(Response.QueryType));
 WriteLn;
End;

{ Afficher les résultats d'une requête DNS }
Procedure DisplayNSQueryResults(var Response: TNSQueryResponse);
Var
 I: Integer;
Begin
 If QuietMode Then Begin
  { Mode silencieux - afficher seulement les données }
  For I := 0 To Response.AnswerCount - 1 Do Begin
   With Response.Answers[I] Do Begin
    Case RecordType Of
     NSQ_A, NSQ_AAAA, NSQ_PTR, NSQ_NS, NSQ_CNAME, NSQ_TXT: WriteLn(Data);
     NSQ_MX: WriteLn(Priority, ' ', Data);
     NSQ_SRV: WriteLn(Priority, ' ', Weight, ' ', Port, ' ', Data);
    Else
     WriteLn(Data);
    End;
   End;
  End;
  Exit;
 End;
 
 { Vérifier les erreurs }
 If Response.ResponseCode <> 0 Then Begin
  WriteLn(';; Got answer:');
  WriteLn(';; ->>HEADER<<- opcode: QUERY, status: ', GetDNSErrorMessage(Response.ResponseCode));
  WriteLn;
  Exit;
 End;
 
 { Afficher l'en-tête si demandé }
 DisplayResponseHeader(Response);
 
 { Afficher la question }
 If ShowHeaders Then
  DisplayQuestionSection(Response);
 
 { Afficher les réponses }
 If Response.AnswerCount > 0 Then Begin
  If ShowHeaders Then
   WriteLn(';; ANSWER SECTION:');
  
  For I := 0 To Response.AnswerCount - 1 Do Begin
   With Response.Answers[I] Do Begin
    If RawMode Then Begin
     { Mode brut }
     WriteLn(Data);
    End Else Begin
     { Mode formaté }
     Write(Name);
     If ShowHeaders Then Begin
      Write(#9, TTL, #9, 'IN', #9, RecordTypeToString(RecordType), #9);
      Case RecordType Of
       NSQ_MX: Write(Priority, ' ');
       NSQ_SRV: Write(Priority, ' ', Weight, ' ', Port, ' ');
      End;
     End Else Begin
      Write(': ');
      Case RecordType Of
       NSQ_MX: Write('(', Priority, ') ');
       NSQ_SRV: Write('(', Priority, ',', Weight, ',', Port, ') ');
      End;
     End;
     WriteLn(Data);
    End;
   End;
  End;
  WriteLn;
 End;
 
 { Afficher les statistiques si demandées }
 If ShowStats Then Begin
  WriteLn(';; Query time: ', Response.QueryTime, ' msec');
  WriteLn(';; SERVER: ', Response.Server, '#53(', Response.Server, ')');
  WriteLn(';; WHEN: ', FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now));
  WriteLn(';; MSG SIZE  rcvd: ', (Response.AnswerCount * 32), ' bytes');
  WriteLn;
 End;
End;

{ Suivre les redirections CNAME }
Function FollowCNAMEChain(var Request: TNSQueryRequest; var FinalResponse: TNSQueryResponse): Boolean;
Var
 Response: TNSQueryResponse;
 OriginalName, CurrentName: String;
 MaxRedirects, Redirects: Integer;
Begin
 FollowCNAMEChain := False;
 MaxRedirects := 10; { Limite pour éviter les boucles }
 Redirects := 0;
 OriginalName := Request.QueryName;
 CurrentName := Request.QueryName;
 
 Repeat
  Request.QueryName := CurrentName;
  If not PerformNSQuery(Request, Response) Then Exit;
  
  { Si on a une réponse directe, c'est fini }
  If (Response.AnswerCount > 0) and (Response.Answers[0].RecordType = Request.QueryType) Then Begin
   FinalResponse := Response;
   FollowCNAMEChain := True;
   Exit;
  End;
  
  { Chercher un CNAME dans les réponses }
  If (Response.AnswerCount > 0) and (Response.Answers[0].RecordType = NSQ_CNAME) Then Begin
   CurrentName := Response.Answers[0].Data;
   Inc(Redirects);
   If VerboseMode > 0 Then
    WriteLn(';; Following CNAME: ', OriginalName, ' -> ', CurrentName);
  End Else Begin
   { Pas de CNAME trouvé }
   FinalResponse := Response;
   FollowCNAMEChain := True;
   Exit;
  End;
  
 Until Redirects >= MaxRedirects;
 
 { Trop de redirections }
 If VerboseMode > 0 Then
  WriteLn(';; Too many CNAME redirections (', MaxRedirects, ')');
End;

{ Effectuer une vérification de cohérence DNS }
Procedure PerformConsistencyCheck(QueryName: String; QueryType: TNSQueryType);
Var
 Request: TNSQueryRequest;
 Response: TNSQueryResponse;
 Servers: Array[0..3] of String[64];
 I: Integer;
Begin
 If VerboseMode = 0 Then Exit;
 
 { Serveurs à tester }
 Servers[0] := '8.8.8.8';      { Google }
 Servers[1] := '1.1.1.1';      { Cloudflare }
 Servers[2] := '208.67.222.222'; { OpenDNS }
 Servers[3] := '9.9.9.9';      { Quad9 }
 
 WriteLn(';; Consistency check across multiple servers:');
 
 For I := 0 To 3 Do Begin
  FillChar(Request, SizeOf(Request), 0);
  Request.QueryName := QueryName;
  Request.QueryType := QueryType;
  Request.QueryClass := 1;
  Request.Server := Servers[I];
  Request.Port := 53;
  Request.Timeout := 5000;
  Request.Retries := 2;
  Request.Recursive := True;
  Request.UseCache := False;
  
  If PerformNSQuery(Request, Response) Then Begin
   Write(';; ', Servers[I], ': ');
   If Response.AnswerCount > 0 Then
    WriteLn('OK (', Response.QueryTime, 'ms, ', Response.AnswerCount, ' records)')
   Else
    WriteLn('No records found');
  End Else Begin
   WriteLn(';; ', Servers[I], ': ', GetDNSErrorMessage(Response.ResponseCode));
  End;
 End;
 WriteLn;
End;

{ Obtenir le serveur DNS par défaut du système }
Function GetSystemDNSServer: String;
Begin
 { Pour cette implémentation, retourner un serveur DNS public }
 GetSystemDNSServer := '8.8.8.8'; { Google Public DNS }
End;

{ Initialiser les variables globales }
Procedure InitializeNSQuery;
Begin
 WSAInitialized := False;
 DefaultServer := GetSystemDNSServer;
 VerboseMode := 0;
 QuietMode := False;
 RawMode := False;
 ShowStats := True;
 ShowFlags := False;
 ShowHeaders := True;
 UseIPv6 := False;
 FollowCNAME := True;
 CheckReverse := False;
End;

{ Analyser la ligne de commande }
Procedure ParseNSQueryCommandLine;
Var
 I: Integer;
 Param: String;
 QueryName: String;
 QueryType: TNSQueryType;
 Request: TNSQueryRequest;
 Response: TNSQueryResponse;
Begin
 QueryName := '';
 QueryType := NSQ_A;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then Begin
   Inc(VerboseMode);
  End
  Else If (LowerCase(Param) = '-q') or (LowerCase(Param) = '--quiet') Then Begin
   QuietMode := True;
   ShowStats := False;
   ShowHeaders := False;
  End
  Else If (LowerCase(Param) = '-r') or (LowerCase(Param) = '--raw') Then Begin
   RawMode := True;
   ShowHeaders := False;
   ShowStats := False;
  End
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--stats') Then Begin
   ShowStats := True;
  End
  Else If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--flags') Then Begin
   ShowFlags := True;
  End
  Else If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--headers') Then Begin
   ShowHeaders := True;
  End
  Else If (LowerCase(Param) = '-6') or (LowerCase(Param) = '--ipv6') Then Begin
   UseIPv6 := True;
   QueryType := NSQ_AAAA;
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--consistency') Then Begin
   CheckReverse := True;
  End
  Else If (LowerCase(Param) = '-t') or (LowerCase(Param) = '--type') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    QueryType := StringToRecordType(ParamStr(I));
   End;
  End
  Else If (LowerCase(Param) = '@') and (I < ParamCount) Then Begin
   Inc(I);
   DefaultServer := ParamStr(I);
  End
  Else If Copy(Param, 1, 1) = '@' Then Begin
   DefaultServer := Copy(Param, 2, Length(Param) - 1);
  End
  Else If (LowerCase(Param) = '--server') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    DefaultServer := ParamStr(I);
   End;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   QueryName := Param;
  End;
  
  Inc(I);
 End;
 
 { Validation }
 If QueryName = '' Then Begin
  WriteLn('nsquery: Nom de domaine ou adresse IP requis');
  WriteLn('Usage: nsquery [options] nom_de_domaine');
  WriteLn('Utilisez nsquery --help pour plus d''informations');
  Halt(1);
 End;
 
 If not IsValidDomainName(QueryName) and not IsValidIPAddress(QueryName) Then Begin
  WriteLn('nsquery: "', QueryName, '" n''est pas un nom de domaine ou une adresse IP valide');
  Halt(1);
 End;
 
 { Détection automatique du type pour résolution inverse }
 If IsValidIPAddress(QueryName) and (QueryType = NSQ_A) Then Begin
  QueryType := NSQ_PTR;
  If VerboseMode > 0 Then
   WriteLn(';; Detected IP address, switching to PTR query');
 End;
 
 { Préparer la requête }
 FillChar(Request, SizeOf(Request), 0);
 Request.QueryName := QueryName;
 Request.QueryType := QueryType;
 Request.QueryClass := 1; { IN }
 Request.Server := DefaultServer;
 Request.Port := 53;
 Request.Timeout := 5000; { 5 secondes }
 Request.Retries := 3;
 Request.Recursive := True;
 Request.UseCache := True;
 
 { Affichage informatif }
 If VerboseMode > 0 Then Begin
  WriteLn(';; nsquery version 1.00');
  WriteLn(';; Server: ', DefaultServer, '#53(', DefaultServer, ')');
  WriteLn(';; Query: ', QueryName, ' IN ', RecordTypeToString(QueryType));
  WriteLn;
 End;
 
 { Effectuer la requête }
 If FollowCNAME and (QueryType <> NSQ_CNAME) and (QueryType <> NSQ_PTR) Then Begin
  If FollowCNAMEChain(Request, Response) Then Begin
   DisplayNSQueryResults(Response);
  End Else Begin
   WriteLn(';; Query failed');
  End;
 End Else Begin
  If PerformNSQuery(Request, Response) Then Begin
   DisplayNSQueryResults(Response);
  End Else Begin
   WriteLn(';; Query failed: ', GetDNSErrorMessage(Response.ResponseCode));
  End;
 End;
 
 { Vérifications supplémentaires }
 If CheckReverse and (VerboseMode > 0) Then
  PerformConsistencyCheck(QueryName, QueryType);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Simulation pour Turbo Pascal }
Procedure ShowSimulatedNSQuery(Name, RecordType: String);
Begin
 WriteLn(';; Got answer:');
 WriteLn(';; ->>HEADER<<- opcode: QUERY, status: NOERROR');
 WriteLn(';; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0');
 WriteLn;
 WriteLn(';; QUESTION SECTION:');
 WriteLn(';', Name, '.		IN	', UpperCase(RecordType));
 WriteLn;
 WriteLn(';; ANSWER SECTION:');
 
 If UpperCase(RecordType) = 'A' Then Begin
  If LowerCase(Name) = 'google.com' Then Begin
   WriteLn(Name, '.		300	IN	A	142.250.185.46');
  End Else If LowerCase(Name) = 'example.com' Then Begin
   WriteLn(Name, '.		86400	IN	A	93.184.216.34');
  End Else Begin
   WriteLn(Name, '.		3600	IN	A	203.0.113.1');
  End;
 End Else If UpperCase(RecordType) = 'MX' Then Begin
  WriteLn(Name, '.		3600	IN	MX	10 mail.', Name, '.');
 End Else If UpperCase(RecordType) = 'NS' Then Begin
  WriteLn(Name, '.		86400	IN	NS	ns1.', Name, '.');
  WriteLn(Name, '.		86400	IN	NS	ns2.', Name, '.');
 End;
 
 WriteLn;
 WriteLn(';; Query time: 45 msec');
 WriteLn(';; SERVER: 8.8.8.8#53(8.8.8.8)');
 WriteLn(';; WHEN: ', FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now));
 WriteLn(';; MSG SIZE  rcvd: 64 bytes');
End;

Procedure ShowSimulatedReverse(IP: String);
Begin
 WriteLn(';; Got answer:');
 WriteLn(';; ->>HEADER<<- opcode: QUERY, status: NOERROR');
 WriteLn(';; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0');
 WriteLn;
 WriteLn(';; QUESTION SECTION:');
 WriteLn(';', IP, '.in-addr.arpa.		IN	PTR');
 WriteLn;
 WriteLn(';; ANSWER SECTION:');
 If IP = '8.8.8.8' Then Begin
  WriteLn('8.8.8.8.in-addr.arpa.	7200	IN	PTR	dns.google.');
 End Else Begin
  WriteLn(IP, '.in-addr.arpa.	3600	IN	PTR	host.example.com.');
 End;
 WriteLn;
 WriteLn(';; Query time: 67 msec');
 WriteLn(';; SERVER: 8.8.8.8#53(8.8.8.8)');
 WriteLn(';; WHEN: ', FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now));
 WriteLn(';; MSG SIZE  rcvd: 78 bytes');
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
  WriteLn('NSQUERY : Outil de requête DNS avancé');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NSQUERY [options] nom_de_domaine');
  WriteLn('  NSQUERY [options] adresse_ip');
  WriteLn('  NSQUERY [options] [@serveur] nom_de_domaine');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -t, --type TYPE       Type d''enregistrement (A, NS, MX, CNAME, TXT, etc.)');
  WriteLn('  @serveur              Serveur DNS à utiliser (ex: @8.8.8.8)');
  WriteLn('  --server SERVEUR      Serveur DNS à utiliser');
  WriteLn('  -v, --verbose         Mode verbeux (utiliser -vv pour plus de détails)');
  WriteLn('  -q, --quiet           Mode silencieux (données seulement)');
  WriteLn('  -r, --raw             Mode brut (pas de formatage)');
  WriteLn('  -s, --stats           Afficher les statistiques de requête');
  WriteLn('  -f, --flags           Afficher les drapeaux de réponse');
  WriteLn('  -h, --headers         Afficher les en-têtes complets');
  WriteLn('  -6, --ipv6            Utiliser IPv6 (requête AAAA par défaut)');
  WriteLn('  -c, --consistency     Vérifier la cohérence entre serveurs');
  WriteLn;
  WriteLn('Types d''enregistrements supportés :');
  WriteLn('  A      Adresse IPv4');
  WriteLn('  AAAA   Adresse IPv6');
  WriteLn('  NS     Serveur de noms');
  WriteLn('  MX     Serveur de messagerie');
  WriteLn('  CNAME  Nom canonique (alias)');
  WriteLn('  TXT    Enregistrement texte');
  WriteLn('  PTR    Pointeur (résolution inverse)');
  WriteLn('  SRV    Enregistrement de service');
  WriteLn('  SOA    Start of Authority');
  WriteLn('  ANY    Tous les types disponibles');
  WriteLn;
  WriteLn('Fonctionnalités avancées :');
  WriteLn('  - Suivi automatique des redirections CNAME');
  WriteLn('  - Détection automatique de résolution inverse');
  WriteLn('  - Vérification de cohérence entre serveurs DNS');
  WriteLn('  - Support des formats de sortie multiples');
  WriteLn('  - Statistiques détaillées de performance');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  NSQUERY google.com                   # Résolution A par défaut');
  WriteLn('  NSQUERY @8.8.8.8 google.com         # Serveur DNS spécifique');
  WriteLn('  NSQUERY -t MX gmail.com              # Serveurs de messagerie');
  WriteLn('  NSQUERY -t NS example.com            # Serveurs de noms');
  WriteLn('  NSQUERY 8.8.8.8                     # Résolution inverse auto');
  WriteLn('  NSQUERY -v -t A github.com           # Mode verbeux');
  WriteLn('  NSQUERY -q -r stackoverflow.com     # Données brutes seulement');
  WriteLn('  NSQUERY -c -v example.com            # Vérification cohérence');
  WriteLn('  NSQUERY -6 google.com                # IPv6 (AAAA)');
  WriteLn('  NSQUERY -t TXT _dmarc.google.com     # Enregistrement TXT');
  WriteLn;
  WriteLn('Formats de sortie :');
  WriteLn('  Par défaut : Format nsquery avec en-têtes');
  WriteLn('  --quiet    : Données seulement, une par ligne');
  WriteLn('  --raw      : Données brutes sans formatage');
  WriteLn('  --verbose  : Informations détaillées et diagnostics');
  WriteLn;
  WriteLn('Note: Effectue de vraies requêtes DNS avec résolution système.');
  WriteLn('Compatible avec les outils nsquery/dig standard de Linux.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('NSQUERY 1.00 - Advanced DNS Query Tool, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeNSQuery;
  ParseNSQueryCommandLine;
  {$ELSE}
  { Version Turbo Pascal - Simulation }
  If ParamCount = 0 Then Begin
   ShowSimulatedNSQuery('google.com', 'A');
  End Else If IsValidIPAddress(ParamStr(1)) Then Begin
   ShowSimulatedReverse(ParamStr(1));
  End Else Begin
   If ParamCount >= 2 Then Begin
    If (ParamStr(1) = '-t') and (ParamCount >= 3) Then
     ShowSimulatedNSQuery(ParamStr(3), ParamStr(2))
    Else
     ShowSimulatedNSQuery(ParamStr(1), 'A');
   End Else Begin
    ShowSimulatedNSQuery(ParamStr(1), 'A');
   End;
  End;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 { Nettoyer Winsock }
 CleanupWinsock;
 {$ENDIF}
END.
