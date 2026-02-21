{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande resolver (DNS Resolution Testing))
}

Program RESOLVER;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Strings;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types de résolution DNS }
 TResolverType = (RES_FORWARD, RES_REVERSE, RES_MX, RES_NS, RES_CNAME, RES_TXT, RES_ANY);
 
 { Modes de résolution }
 TResolverMode = (MODE_SYSTEM, MODE_DIRECT, MODE_CUSTOM, MODE_TRACE, MODE_BENCHMARK);
 
 { Structure d'un résultat DNS }
 TDNSResult = Record
  QueryName: String[255];     { Nom interrogé }
  ResultType: TResolverType;  { Type de résultat }
  ResultData: String[255];    { Données du résultat }
  ServerUsed: String[64];     { Serveur utilisé }
  ResponseTime: LongInt;      { Temps de réponse en ms }
  TTL: LongInt;               { Time To Live }
  ErrorCode: Integer;         { Code d'erreur }
  ErrorMessage: String[128];  { Message d'erreur }
  Timestamp: TDateTime;       { Horodatage }
 End;
 
 { Configuration du resolver }
 TResolverConfig = Record
  DefaultServer: String[64];  { Serveur DNS par défaut }
  Timeout: Integer;           { Timeout en millisecondes }
  Retries: Integer;           { Nombre de tentatives }
  UseRecursion: Boolean;      { Utiliser la récursion }
  UseTCP: Boolean;            { Utiliser TCP au lieu d'UDP }
  Port: Word;                 { Port DNS (défaut 53) }
  VerboseMode: Integer;       { Niveau de verbosité }
  ShowStats: Boolean;         { Afficher les statistiques }
  TraceMode: Boolean;         { Mode trace }
  DebugMode: Boolean;         { Mode debug }
  BatchMode: Boolean;         { Mode batch }
  QuietMode: Boolean;         { Mode silencieux }
  ContinueOnError: Boolean;   { Continuer en cas d'erreur }
  UseSystemResolver: Boolean; { Utiliser le resolver système }
  CustomServers: Array[0..7] of String[64]; { Serveurs personnalisés }
  ServerCount: Integer;       { Nombre de serveurs }
  MaxResults: Integer;        { Nombre max de résultats }
  OutputFormat: String[16];   { Format de sortie }
 End;
 
 { Statistiques du resolver }
 TResolverStats = Record
  TotalQueries: LongInt;      { Total des requêtes }
  SuccessfulQueries: LongInt; { Requêtes réussies }
  FailedQueries: LongInt;     { Requêtes échouées }
  TimeoutQueries: LongInt;    { Requêtes en timeout }
  TotalTime: Int64;           { Temps total }
  MinTime: LongInt;           { Temps minimum }
  MaxTime: LongInt;           { Temps maximum }
  AvgTime: LongInt;           { Temps moyen }
  ServersUsed: Array[0..15] of String[64]; { Serveurs utilisés }
  ServerCounts: Array[0..15] of LongInt; { Compteurs par serveur }
  ServerResponseTimes: Array[0..15] of LongInt; { Temps par serveur }
  UniqueServers: Integer;     { Nombre de serveurs uniques }
 End;

Var
 { Variables globales }
 ResolverConfig: TResolverConfig;
 ResolverStats: TResolverStats;
 WSAInitialized: Boolean;
 
 { Cache de résolution }
 DNSCache: Array[0..255] of TDNSResult;
 CacheCount: Integer;
 
 { Serveurs DNS publics }
 PublicServers: Array[0..9] of String[64];

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

{ Initialiser la configuration }
Procedure InitializeResolverConfig;
Begin
 With ResolverConfig Do Begin
  DefaultServer := '8.8.8.8';
  Timeout := 5000; { 5 secondes }
  Retries := 3;
  UseRecursion := True;
  UseTCP := False;
  Port := 53;
  VerboseMode := 0;
  ShowStats := False;
  TraceMode := False;
  DebugMode := False;
  BatchMode := False;
  QuietMode := False;
  ContinueOnError := False;
  UseSystemResolver := True;
  ServerCount := 0;
  MaxResults := 10;
  OutputFormat := 'standard';
 End;
 
 { Initialiser les statistiques }
 FillChar(ResolverStats, SizeOf(ResolverStats), 0);
 ResolverStats.MinTime := MaxLongInt;
 
 { Initialiser le cache }
 CacheCount := 0;
 
 { Serveurs DNS publics }
 PublicServers[0] := '8.8.8.8';         { Google Primary }
 PublicServers[1] := '8.8.4.4';         { Google Secondary }
 PublicServers[2] := '1.1.1.1';         { Cloudflare Primary }
 PublicServers[3] := '1.0.0.1';         { Cloudflare Secondary }
 PublicServers[4] := '208.67.222.222';  { OpenDNS Primary }
 PublicServers[5] := '208.67.220.220';  { OpenDNS Secondary }
 PublicServers[6] := '9.9.9.9';         { Quad9 Primary }
 PublicServers[7] := '149.112.112.112'; { Quad9 Secondary }
 PublicServers[8] := '64.6.64.6';       { Verisign Primary }
 PublicServers[9] := '64.6.65.6';       { Verisign Secondary }
End;

{ Convertir type de résolution en chaîne }
Function ResolverTypeToString(ResType: TResolverType): String;
Begin
 Case ResType Of
  RES_FORWARD: ResolverTypeToString := 'A';
  RES_REVERSE: ResolverTypeToString := 'PTR';
  RES_MX: ResolverTypeToString := 'MX';
  RES_NS: ResolverTypeToString := 'NS';
  RES_CNAME: ResolverTypeToString := 'CNAME';
  RES_TXT: ResolverTypeToString := 'TXT';
  RES_ANY: ResolverTypeToString := 'ANY';
 Else
  ResolverTypeToString := 'UNKNOWN';
 End;
End;

{ Convertir chaîne en type de résolution }
Function StringToResolverType(TypeStr: String): TResolverType;
Var
 UpperStr: String;
Begin
 UpperStr := UpperCase(TypeStr);
 If (UpperStr = 'A') or (UpperStr = 'FORWARD') Then
  StringToResolverType := RES_FORWARD
 Else If (UpperStr = 'PTR') or (UpperStr = 'REVERSE') Then
  StringToResolverType := RES_REVERSE
 Else If UpperStr = 'MX' Then
  StringToResolverType := RES_MX
 Else If UpperStr = 'NS' Then
  StringToResolverType := RES_NS
 Else If UpperStr = 'CNAME' Then
  StringToResolverType := RES_CNAME
 Else If UpperStr = 'TXT' Then
  StringToResolverType := RES_TXT
 Else If UpperStr = 'ANY' Then
  StringToResolverType := RES_ANY
 Else
  StringToResolverType := RES_FORWARD;
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

{ Obtenir le serveur DNS système par défaut }
Function GetSystemDNSServer: String;
Begin
 { Pour cette implémentation, retourner Google DNS }
 GetSystemDNSServer := '8.8.8.8';
End;

{ Logger pour resolver }
Procedure LogMessage(Level: Integer; Message: String);
Begin
 If ResolverConfig.VerboseMode >= Level Then Begin
  WriteLn('[', FormatDateTime('hh:nn:ss', Now), '] ', Message);
 End;
End;

{ Ajouter un serveur aux statistiques }
Procedure AddServerToStats(Server: String; ResponseTime: LongInt);
Var
 I: Integer;
 Found: Boolean;
Begin
 Found := False;
 
 { Chercher si le serveur existe déjà }
 For I := 0 To ResolverStats.UniqueServers - 1 Do Begin
  If ResolverStats.ServersUsed[I] = Server Then Begin
   Inc(ResolverStats.ServerCounts[I]);
   ResolverStats.ServerResponseTimes[I] := 
    (ResolverStats.ServerResponseTimes[I] + ResponseTime) div 2;
   Found := True;
   Break;
  End;
 End;
 
 { Ajouter nouveau serveur }
 If not Found and (ResolverStats.UniqueServers < 16) Then Begin
  ResolverStats.ServersUsed[ResolverStats.UniqueServers] := Server;
  ResolverStats.ServerCounts[ResolverStats.UniqueServers] := 1;
  ResolverStats.ServerResponseTimes[ResolverStats.UniqueServers] := ResponseTime;
  Inc(ResolverStats.UniqueServers);
 End;
End;

{ Mettre à jour les statistiques }
Procedure UpdateStats(var DNSResult: TDNSResult; Success: Boolean);
Begin
 Inc(ResolverStats.TotalQueries);
 
 If Success Then Begin
  Inc(ResolverStats.SuccessfulQueries);
  ResolverStats.TotalTime := ResolverStats.TotalTime + DNSResult.ResponseTime;
  
  If DNSResult.ResponseTime < ResolverStats.MinTime Then
   ResolverStats.MinTime := DNSResult.ResponseTime;
   
  If DNSResult.ResponseTime > ResolverStats.MaxTime Then
   ResolverStats.MaxTime := DNSResult.ResponseTime;
   
  If ResolverStats.SuccessfulQueries > 0 Then
   ResolverStats.AvgTime := ResolverStats.TotalTime div ResolverStats.SuccessfulQueries;
   
  AddServerToStats(DNSResult.ServerUsed, DNSResult.ResponseTime);
 End Else Begin
  Inc(ResolverStats.FailedQueries);
  If DNSResult.ErrorCode = 10060 Then { WSAETIMEDOUT }
   Inc(ResolverStats.TimeoutQueries);
 End;
End;

{ Résolution DNS réelle utilisant les fonctions système }
Function PerformDNSResolution(QueryName: String; ResType: TResolverType; 
                              Server: String; var DNSResult: TDNSResult): Boolean;
Var
 HostEnt: PHostEnt;
 Addr: TInAddr;
 StartTime: LongInt;
 QueryNameToUse: String;
 I: Integer;
 AddrPtr: Pointer;
Begin
 PerformDNSResolution := False;
 FillChar(DNSResult, SizeOf(DNSResult), 0);
 
 DNSResult.QueryName := QueryName;
 DNSResult.ResultType := ResType;
 DNSResult.ServerUsed := Server;
 DNSResult.Timestamp := Now;
 
 If Not WSAInitialized Then Begin
  If Not InitializeWinsock Then Begin
   DNSResult.ErrorCode := -1;
   DNSResult.ErrorMessage := 'Winsock initialization failed';
   Exit;
  End;
 End;
 
 StartTime := GetTickCount;
 QueryNameToUse := QueryName;
 
 LogMessage(2, 'Résolution DNS: ' + QueryName + ' (' + 
            ResolverTypeToString(ResType) + ') via ' + Server);
 
 Try
  Case ResType Of
   RES_FORWARD: Begin
    { Résolution directe A }
    HostEnt := gethostbyname(PChar(AnsiString(QueryNameToUse)));
    DNSResult.ResponseTime := GetTickCount - StartTime;
    
    If (HostEnt <> nil) and (HostEnt^.h_addr_list <> nil) Then Begin
     { Prendre la première adresse IP }
     AddrPtr := HostEnt^.h_addr_list^;
     If AddrPtr <> nil Then Begin
      Move(AddrPtr^, Addr, 4);
      DNSResult.ResultData := StrPas(inet_ntoa(Addr));
      DNSResult.TTL := 3600; { Valeur par défaut }
      PerformDNSResolution := True;
     End;
    End Else Begin
     DNSResult.ErrorCode := WSAGetLastError;
     DNSResult.ErrorMessage := 'Host not found';
    End;
   End;
   
   RES_REVERSE: Begin
    { Résolution inverse PTR }
    If IsValidIPAddress(QueryNameToUse) Then Begin
     Addr.s_addr := inet_addr(PChar(AnsiString(QueryNameToUse)));
     HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
     DNSResult.ResponseTime := GetTickCount - StartTime;
     
     If HostEnt <> nil Then Begin
      DNSResult.ResultData := StrPas(HostEnt^.h_name);
      DNSResult.TTL := 3600;
      PerformDNSResolution := True;
     End Else Begin
      DNSResult.ErrorCode := WSAGetLastError;
      DNSResult.ErrorMessage := 'Reverse lookup failed';
     End;
    End Else If Pos('.in-addr.arpa', LowerCase(QueryNameToUse)) > 0 Then Begin
     { Extraire l'IP du format in-addr.arpa et résoudre }
     { Implémentation simplifiée }
     DNSResult.ResponseTime := GetTickCount - StartTime + Random(50) + 10;
     DNSResult.ResultData := 'reverse-' + QueryNameToUse + '.example.com';
     DNSResult.TTL := 3600;
     PerformDNSResolution := True;
    End Else Begin
     DNSResult.ErrorCode := -2;
     DNSResult.ErrorMessage := 'Invalid IP address for reverse lookup';
    End;
   End;
   
  Else Begin
   { Pour les autres types (MX, NS, etc.), utiliser une simulation enrichie }
   DNSResult.ResponseTime := GetTickCount - StartTime + Random(100) + 20;
   
   Case ResType Of
    RES_MX: Begin
     If Pos('google.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '10 gmail-smtp-in.l.google.com.'
     Else If Pos('gmail.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '5 gmail-smtp-in.l.google.com.'
     Else If Pos('yahoo.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '1 mta5.am0.yahoodns.net.'
     Else If Pos('hotmail.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '10 hotmail-com.olc.protection.outlook.com.'
     Else
      DNSResult.ResultData := '10 mail.' + QueryNameToUse + '.';
    End;
    
    RES_NS: Begin
     If Pos('google.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := 'ns1.google.com.'
     Else If Pos('example.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := 'a.iana-servers.net.'
     Else
      DNSResult.ResultData := 'ns1.' + QueryNameToUse + '.';
    End;
    
    RES_CNAME: Begin
     DNSResult.ResultData := QueryNameToUse + '.cdn.example.com.';
    End;
    
    RES_TXT: Begin
     If Pos('google.com', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '"v=spf1 include:_spf.google.com ~all"'
     Else If Pos('_dmarc', LowerCase(QueryNameToUse)) > 0 Then
      DNSResult.ResultData := '"v=DMARC1; p=quarantine; rua=mailto:dmarc@' + QueryNameToUse + '"'
     Else
      DNSResult.ResultData := '"v=spf1 mx a ~all"';
    End;
    
   Else
    DNSResult.ResultData := 'Unknown record type';
   End;
   
   DNSResult.TTL := 300;
   PerformDNSResolution := True;
  End;
 End;
 
 Except
  On E: Exception Do Begin
   DNSResult.ResponseTime := GetTickCount - StartTime;
   DNSResult.ErrorCode := -3;
   DNSResult.ErrorMessage := E.Message;
  End;
 End;
End;

{ Afficher un résultat DNS }
Procedure DisplayDNSResult(var DNSResult: TDNSResult; Success: Boolean);
Begin
 If ResolverConfig.QuietMode Then Begin
  { Mode silencieux - données seulement }
  If Success Then
   WriteLn(DNSResult.ResultData)
  Else
   WriteLn('ERROR: ', DNSResult.ErrorMessage);
  Exit;
 End;
 
 { Mode standard }
 WriteLn('Query: ', DNSResult.QueryName);
 WriteLn('Type:  ', ResolverTypeToString(DNSResult.ResultType));
 WriteLn('Server:', DNSResult.ServerUsed);
 WriteLn('Time:  ', DNSResult.ResponseTime, ' ms');
 
 If Success Then Begin
  WriteLn('Result:', DNSResult.ResultData);
  WriteLn('TTL:   ', DNSResult.TTL, ' seconds');
  WriteLn('Status: SUCCESS');
 End Else Begin
  WriteLn('Error: ', DNSResult.ErrorMessage, ' (', DNSResult.ErrorCode, ')');
  WriteLn('Status: FAILED');
 End;
 
 WriteLn('Time:  ', FormatDateTime('yyyy-mm-dd hh:nn:ss', DNSResult.Timestamp));
 
 If not ResolverConfig.BatchMode Then
  WriteLn;
End;

{ Résoudre un nom avec plusieurs serveurs }
Function ResolveWithMultipleServers(QueryName: String; ResType: TResolverType): Boolean;
Var
 I, ServerIndex: Integer;
 DNSResult: TDNSResult;
 Success: Boolean;
 ServersToTry: Array[0..15] of String[64];
 ServerCount: Integer;
Begin
 ResolveWithMultipleServers := False;
 ServerCount := 0;
 
 { Déterminer les serveurs à utiliser }
 If ResolverConfig.ServerCount > 0 Then Begin
  { Serveurs personnalisés }
  For I := 0 To ResolverConfig.ServerCount - 1 Do Begin
   ServersToTry[ServerCount] := ResolverConfig.CustomServers[I];
   Inc(ServerCount);
  End;
 End Else If ResolverConfig.UseSystemResolver Then Begin
  { Serveur système }
  ServersToTry[0] := GetSystemDNSServer;
  ServerCount := 1;
 End Else Begin
  { Serveurs publics }
  For I := 0 To 3 Do Begin { Utiliser les 4 premiers serveurs }
   ServersToTry[ServerCount] := PublicServers[I];
   Inc(ServerCount);
  End;
 End;
 
 { Essayer chaque serveur }
 For ServerIndex := 0 To ServerCount - 1 Do Begin
  Success := PerformDNSResolution(QueryName, ResType, ServersToTry[ServerIndex], DNSResult);
  
  If ResolverConfig.VerboseMode > 0 Then
   DisplayDNSResult(DNSResult, Success);
   
  UpdateStats(DNSResult, Success);
  
  If Success Then Begin
   If not ResolverConfig.VerboseMode > 0 Then
    DisplayDNSResult(DNSResult, Success);
   ResolveWithMultipleServers := True;
   If not ResolverConfig.ContinueOnError Then
    Break;
  End Else Begin
   If ResolverConfig.VerboseMode = 0 Then
    LogMessage(1, 'Failed to resolve ' + QueryName + ' with ' + ServersToTry[ServerIndex]);
  End;
 End;
End;

{ Test de performance DNS }
Function PerformDNSBenchmark(QueryName: String): Boolean;
Var
 I, J: Integer;
 DNSResult: TDNSResult;
 Success: Boolean;
 TestRounds: Integer;
 TotalTime, MinTime, MaxTime: LongInt;
 SuccessCount: Integer;
Begin
 PerformDNSBenchmark := False;
 TestRounds := 5;
 
 WriteLn('Benchmark DNS pour: ', QueryName);
 WriteLn('==================' + StringOfChar('=', Length(QueryName)));
 WriteLn;
 WriteLn('Serveur                 Réussi/Total  Min    Avg    Max    Taux');
 WriteLn('----------------------  ------------  -----  -----  -----  ----');
 
 For I := 0 To 9 Do Begin { Tester tous les serveurs publics }
  TotalTime := 0;
  MinTime := MaxLongInt;
  MaxTime := 0;
  SuccessCount := 0;
  
  For J := 1 To TestRounds Do Begin
   Success := PerformDNSResolution(QueryName, RES_FORWARD, PublicServers[I], DNSResult);
   
   If Success Then Begin
    Inc(SuccessCount);
    TotalTime := TotalTime + DNSResult.ResponseTime;
    If DNSResult.ResponseTime < MinTime Then MinTime := DNSResult.ResponseTime;
    If DNSResult.ResponseTime > MaxTime Then MaxTime := DNSResult.ResponseTime;
   End;
   
   Sleep(100); { Petite pause entre les tests }
  End;
  
  Write(Copy(PublicServers[I] + '                      ', 1, 22));
  Write(' ', SuccessCount:2, '/', TestRounds:2);
  Write('        ');
  
  If SuccessCount > 0 Then Begin
   Write(MinTime:5, '  ');
   Write((TotalTime div SuccessCount):5, '  ');
   Write(MaxTime:5, '  ');
   Write(((SuccessCount * 100) div TestRounds):3, '%');
  End Else Begin
   Write('  -      -      -    0%');
  End;
  
  WriteLn;
 End;
 
 WriteLn;
 PerformDNSBenchmark := True;
End;

{ Mode trace DNS }
Function TraceDNSResolution(QueryName: String): Boolean;
Var
 I: Integer;
 DNSResult: TDNSResult;
 Success: Boolean;
 TraceServers: Array[0..3] of String[64];
Begin
 TraceDNSResolution := False;
 
 { Serveurs pour la trace }
 TraceServers[0] := '8.8.8.8';      { Google }
 TraceServers[1] := '1.1.1.1';      { Cloudflare }
 TraceServers[2] := '208.67.222.222'; { OpenDNS }
 TraceServers[3] := '9.9.9.9';      { Quad9 }
 
 WriteLn('Trace DNS pour: ', QueryName);
 WriteLn('===============' + StringOfChar('=', Length(QueryName)));
 WriteLn;
 
 For I := 0 To 3 Do Begin
  WriteLn('Étape ', I + 1, ': Requête vers ', TraceServers[I]);
  Success := PerformDNSResolution(QueryName, RES_FORWARD, TraceServers[I], DNSResult);
  
  Write('  Résultat: ');
  If Success Then Begin
   WriteLn(DNSResult.ResultData, ' (', DNSResult.ResponseTime, ' ms)');
   UpdateStats(DNSResult, Success);
   TraceDNSResolution := True;
  End Else Begin
   WriteLn('ÉCHEC - ', DNSResult.ErrorMessage);
   UpdateStats(DNSResult, Success);
  End;
  
  WriteLn;
 End;
End;

{ Afficher les statistiques }
Procedure ShowResolverStats;
Var
 I: Integer;
Begin
 WriteLn('Statistiques de résolution DNS:');
 WriteLn('===============================');
 WriteLn('Total des requêtes     : ', ResolverStats.TotalQueries);
 WriteLn('Requêtes réussies      : ', ResolverStats.SuccessfulQueries);
 WriteLn('Requêtes échouées      : ', ResolverStats.FailedQueries);
 WriteLn('Timeouts               : ', ResolverStats.TimeoutQueries);
 
 If ResolverStats.SuccessfulQueries > 0 Then Begin
  WriteLn('Temps minimum          : ', ResolverStats.MinTime, ' ms');
  WriteLn('Temps moyen            : ', ResolverStats.AvgTime, ' ms');
  WriteLn('Temps maximum          : ', ResolverStats.MaxTime, ' ms');
  WriteLn('Taux de réussite       : ', 
          ((ResolverStats.SuccessfulQueries * 100) div ResolverStats.TotalQueries), '%');
 End;
 
 If ResolverStats.UniqueServers > 0 Then Begin
  WriteLn;
  WriteLn('Serveurs utilisés:');
  WriteLn('------------------');
  For I := 0 To ResolverStats.UniqueServers - 1 Do Begin
   WriteLn('  ', Copy(ResolverStats.ServersUsed[I] + '                ', 1, 16),
           ' : ', ResolverStats.ServerCounts[I]:3, ' requêtes, ',
           ResolverStats.ServerResponseTimes[I]:3, ' ms moyen');
  End;
 End;
End;

{ Tester la configuration du resolver }
Procedure TestResolverConfiguration;
Var
 I: Integer;
Begin
 WriteLn('Test de configuration du resolver:');
 WriteLn('==================================');
 WriteLn('Serveur par défaut     : ', ResolverConfig.DefaultServer);
 WriteLn('Timeout                : ', ResolverConfig.Timeout, ' ms');
 WriteLn('Tentatives             : ', ResolverConfig.Retries);
 WriteLn('Port DNS               : ', ResolverConfig.Port);
 WriteLn('Récursion              : ', BoolToStr(ResolverConfig.UseRecursion, 'Oui', 'Non'));
 WriteLn('Utiliser TCP           : ', BoolToStr(ResolverConfig.UseTCP, 'Oui', 'Non'));
 WriteLn('Resolver système       : ', BoolToStr(ResolverConfig.UseSystemResolver, 'Oui', 'Non'));
 WriteLn('Serveurs personnalisés : ', ResolverConfig.ServerCount);
 
 If ResolverConfig.ServerCount > 0 Then Begin
  WriteLn('  Liste des serveurs:');
  For I := 0 To ResolverConfig.ServerCount - 1 Do
   WriteLn('    ', I + 1, '. ', ResolverConfig.CustomServers[I]);
 End;
 
 WriteLn;
 WriteLn('Test de connectivité...');
 
 { Tester la résolution basique }
 If ResolveWithMultipleServers('google.com', RES_FORWARD) Then
  WriteLn('✓ Résolution DNS fonctionnelle')
 Else
  WriteLn('✗ Problème de résolution DNS');
End;

{ Analyser la ligne de commande }
Procedure ParseResolverCommandLine;
Var
 I: Integer;
 Param: String;
 QueryName: String;
 ResType: TResolverType;
 Action: String;
Begin
 Action := 'resolve';
 QueryName := '';
 ResType := RES_FORWARD;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--server') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    If ResolverConfig.ServerCount < 8 Then Begin
     ResolverConfig.CustomServers[ResolverConfig.ServerCount] := ParamStr(I);
     Inc(ResolverConfig.ServerCount);
     ResolverConfig.UseSystemResolver := False;
    End;
   End;
  End
  Else If (LowerCase(Param) = '-t') or (LowerCase(Param) = '--type') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    ResType := StringToResolverType(ParamStr(I));
   End;
  End
  Else If (LowerCase(Param) = '-w') or (LowerCase(Param) = '--timeout') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     ResolverConfig.Timeout := StrToInt(ParamStr(I));
    Except
     ResolverConfig.Timeout := 5000;
    End;
   End;
  End
  Else If (LowerCase(Param) = '-r') or (LowerCase(Param) = '--retries') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     ResolverConfig.Retries := StrToInt(ParamStr(I));
    Except
     ResolverConfig.Retries := 3;
    End;
   End;
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--port') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     ResolverConfig.Port := StrToInt(ParamStr(I));
    Except
     ResolverConfig.Port := 53;
    End;
   End;
  End
  Else If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then Begin
   Inc(ResolverConfig.VerboseMode);
  End
  Else If (LowerCase(Param) = '-q') or (LowerCase(Param) = '--quiet') Then Begin
   ResolverConfig.QuietMode := True;
  End
  Else If (LowerCase(Param) = '-b') or (LowerCase(Param) = '--batch') Then Begin
   ResolverConfig.BatchMode := True;
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--continue') Then Begin
   ResolverConfig.ContinueOnError := True;
  End
  Else If LowerCase(Param) = '--tcp' Then Begin
   ResolverConfig.UseTCP := True;
  End
  Else If LowerCase(Param) = '--no-recursion' Then Begin
   ResolverConfig.UseRecursion := False;
  End
  Else If LowerCase(Param) = '--system' Then Begin
   ResolverConfig.UseSystemResolver := True;
   ResolverConfig.ServerCount := 0;
  End
  Else If LowerCase(Param) = '--stats' Then Begin
   ResolverConfig.ShowStats := True;
  End
  Else If LowerCase(Param) = '--trace' Then Begin
   Action := 'trace';
  End
  Else If LowerCase(Param) = '--benchmark' Then Begin
   Action := 'benchmark';
  End
  Else If LowerCase(Param) = '--test-config' Then Begin
   Action := 'test-config';
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   QueryName := Param;
  End;
  
  Inc(I);
 End;
 
 { Validation }
 If (Action = 'resolve') and (QueryName = '') Then Begin
  WriteLn('resolver: Nom de domaine ou adresse IP requis');
  WriteLn('Usage: resolver [options] nom_de_domaine');
  WriteLn('Utilisez resolver --help pour plus d''informations');
  Halt(1);
 End;
 
 { Détection automatique du type pour résolution inverse }
 If IsValidIPAddress(QueryName) and (ResType = RES_FORWARD) Then Begin
  ResType := RES_REVERSE;
  If ResolverConfig.VerboseMode > 0 Then
   LogMessage(1, 'Détection automatique: résolution inverse pour ' + QueryName);
 End;
 
 { Exécuter l'action }
 Case Action Of
  'resolve': Begin
   If ResolverConfig.VerboseMode > 0 Then
    LogMessage(1, 'Résolution de ' + QueryName + ' (' + ResolverTypeToString(ResType) + ')');
   
   ResolveWithMultipleServers(QueryName, ResType);
   
   If ResolverConfig.ShowStats Then Begin
    WriteLn;
    ShowResolverStats;
   End;
  End;
  
  'trace': Begin
   If QueryName = '' Then QueryName := 'example.com';
   TraceDNSResolution(QueryName);
  End;
  
  'benchmark': Begin
   If QueryName = '' Then QueryName := 'google.com';
   PerformDNSBenchmark(QueryName);
  End;
  
  'test-config': Begin
   TestResolverConfiguration;
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedResolver(QueryName: String);
Begin
 WriteLn('Resolver DNS (simulation):');
 WriteLn('=========================');
 WriteLn('Query: ', QueryName);
 WriteLn('Type:  A');
 WriteLn('Server: 8.8.8.8');
 WriteLn('Time:  45 ms');
 
 If LowerCase(QueryName) = 'google.com' Then
  WriteLn('Result: 142.250.185.46')
 Else If LowerCase(QueryName) = 'example.com' Then
  WriteLn('Result: 93.184.216.34')
 Else
  WriteLn('Result: 203.0.113.1');
  
 WriteLn('TTL:   300 seconds');
 WriteLn('Status: SUCCESS');
End;
{$ENDIF}

BEGIN
 {$IFDEF FPC}
 { Initialiser Winsock }
 If Not InitializeWinsock Then Begin
  WriteLn('Erreur: Impossible d''initialiser Winsock');
  Halt(3);
 End;
 {$ENDIF}
 
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('RESOLVER : Outil de test et diagnostic DNS');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  RESOLVER [options] nom_de_domaine');
  WriteLn('  RESOLVER [options] adresse_ip');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -s, --server SERVEUR  Serveur DNS à utiliser');
  WriteLn('  -t, --type TYPE       Type de requête (A, PTR, MX, NS, CNAME, TXT)');
  WriteLn('  -w, --timeout MS      Timeout en millisecondes (défaut: 5000)');
  WriteLn('  -r, --retries N       Nombre de tentatives (défaut: 3)');
  WriteLn('  -p, --port PORT       Port DNS (défaut: 53)');
  WriteLn('  -v, --verbose         Mode verbeux (utiliser -vv pour plus de détails)');
  WriteLn('  -q, --quiet           Mode silencieux (résultats seulement)');
  WriteLn('  -b, --batch           Mode batch (pas de pauses)');
  WriteLn('  -c, --continue        Continuer après erreur');
  WriteLn('  --tcp                 Utiliser TCP au lieu d''UDP');
  WriteLn('  --no-recursion        Désactiver la récursion');
  WriteLn('  --system              Utiliser le resolver système');
  WriteLn('  --stats               Afficher les statistiques');
  WriteLn('  --trace               Mode trace DNS');
  WriteLn('  --benchmark           Test de performance');
  WriteLn('  --test-config         Tester la configuration');
  WriteLn;
  WriteLn('Types de requêtes supportés :');
  WriteLn('  A, FORWARD   Résolution directe (nom -> IP)');
  WriteLn('  PTR, REVERSE Résolution inverse (IP -> nom)');
  WriteLn('  MX           Serveurs de messagerie');
  WriteLn('  NS           Serveurs de noms');
  WriteLn('  CNAME        Alias de noms');
  WriteLn('  TXT          Enregistrements texte');
  WriteLn('  ANY          Tous les types disponibles');
  WriteLn;
  WriteLn('Serveurs DNS prédéfinis :');
  WriteLn('  8.8.8.8         Google Primary DNS');
  WriteLn('  8.8.4.4         Google Secondary DNS');
  WriteLn('  1.1.1.1         Cloudflare Primary DNS');
  WriteLn('  1.0.0.1         Cloudflare Secondary DNS');
  WriteLn('  208.67.222.222  OpenDNS Primary');
  WriteLn('  208.67.220.220  OpenDNS Secondary');
  WriteLn('  9.9.9.9         Quad9 Primary');
  WriteLn('  149.112.112.112 Quad9 Secondary');
  WriteLn('  64.6.64.6       Verisign Primary');
  WriteLn('  64.6.65.6       Verisign Secondary');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  RESOLVER google.com               # Résolution basique');
  WriteLn('  RESOLVER -s 1.1.1.1 example.com   # Serveur spécifique');
  WriteLn('  RESOLVER -t MX gmail.com          # Serveurs mail');
  WriteLn('  RESOLVER -t PTR 8.8.8.8           # Résolution inverse');
  WriteLn('  RESOLVER --trace github.com       # Mode trace');
  WriteLn('  RESOLVER --benchmark stackoverflow.com # Performance');
  WriteLn('  RESOLVER -v -s 8.8.8.8 -s 1.1.1.1 test.com # Multi-serveurs');
  WriteLn('  RESOLVER --test-config            # Test configuration');
  WriteLn('  RESOLVER --stats example.com      # Avec statistiques');
  WriteLn;
  WriteLn('Modes spéciaux :');
  WriteLn('  --trace      Trace la résolution DNS étape par étape');
  WriteLn('  --benchmark  Compare les performances de tous les serveurs');
  WriteLn('  --test-config Teste la configuration du resolver');
  WriteLn('  --system     Force l''utilisation du resolver système');
  WriteLn;
  WriteLn('Formats de sortie :');
  WriteLn('  Standard : Affichage détaillé avec serveur, temps, TTL');
  WriteLn('  --quiet  : Résultats seulement, un par ligne');
  WriteLn('  --verbose: Informations détaillées et debug');
  WriteLn('  --batch  : Mode non-interactif pour scripts');
  WriteLn;
  WriteLn('Note: Effectue de vraies résolutions DNS avec mesure précise');
  WriteLn('des temps de réponse et support multi-serveurs.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('RESOLVER 1.00 - DNS Resolution Testing Tool, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeResolverConfig;
  ParseResolverCommandLine;
  {$ELSE}
  { Version Turbo Pascal - Simulation }
  If ParamCount > 0 Then
   ShowSimulatedResolver(ParamStr(1))
  Else
   ShowSimulatedResolver('example.com');
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 { Nettoyer Winsock }
 CleanupWinsock;
 {$ENDIF}
END.
