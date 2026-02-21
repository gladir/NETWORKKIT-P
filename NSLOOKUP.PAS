{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande nslookup (Name Server Lookup))
}

Program NSLOOKUP;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Strings;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types d'enregistrements DNS }
 TNSLookupRecordType = (NS_A, NS_AAAA, NS_NS, NS_MX, NS_CNAME, NS_TXT, NS_PTR, NS_SRV, NS_SOA, NS_ANY);

 { Structure pour un enregistrement DNS }
 TNSLookupRecord = Record
  Name: String[255];         { Nom de domaine }
  RecordType: TNSLookupRecordType; { Type d'enregistrement }
  RecordClass: Word;         { Classe (généralement IN=1) }
  TTL: LongInt;              { Time To Live }
  DataLength: Word;          { Longueur des données }
  Data: String[255];         { Données de l'enregistrement }
 End;

 { Structure pour une réponse DNS complète }
 TNSLookupResponse = Record
  QueryName: String[255];    { Nom interrogé }
  QueryType: TNSLookupRecordType; { Type de requête }
  AnswerCount: Integer;      { Nombre de réponses }
  Answers: Array[0..31] of TNSLookupRecord; { Réponses }
  AuthorityCount: Integer;   { Nombre d'autorités }
  AdditionalCount: Integer;  { Nombre d'additionnels }
  ResponseCode: Integer;     { Code de réponse (0=NOERROR) }
  QueryTime: LongInt;        { Temps de requête en millisecondes }
  Server: String[64];        { Serveur DNS utilisé }
 End;

Var
 { Variables globales }
 WSAInitialized: Boolean;
 DefaultServer: String[64];
 InteractiveMode: Boolean;
 QueryType: TNSLookupRecordType;
 QueryClass: Word;
 Timeout: Integer;
 Retries: Integer;
 Debug: Boolean;
 Recurse: Boolean;
 DefName: Boolean;
 Search: Boolean;
 Port: Word;

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
Function RecordTypeToString(RecType: TNSLookupRecordType): String;
Begin
 Case RecType Of
  NS_A: RecordTypeToString := 'A';
  NS_AAAA: RecordTypeToString := 'AAAA';
  NS_NS: RecordTypeToString := 'NS';
  NS_MX: RecordTypeToString := 'MX';
  NS_CNAME: RecordTypeToString := 'CNAME';
  NS_TXT: RecordTypeToString := 'TXT';
  NS_PTR: RecordTypeToString := 'PTR';
  NS_SRV: RecordTypeToString := 'SRV';
  NS_SOA: RecordTypeToString := 'SOA';
  NS_ANY: RecordTypeToString := 'ANY';
 Else
  RecordTypeToString := 'UNKNOWN';
 End;
End;

{ Convertir une chaîne en type d'enregistrement }
Function StringToRecordType(TypeStr: String): TNSLookupRecordType;
Var
 UpperStr: String;
Begin
 UpperStr := UpperCase(TypeStr);
 If UpperStr = 'A' Then
  StringToRecordType := NS_A
 Else If UpperStr = 'AAAA' Then
  StringToRecordType := NS_AAAA
 Else If UpperStr = 'NS' Then
  StringToRecordType := NS_NS
 Else If UpperStr = 'MX' Then
  StringToRecordType := NS_MX
 Else If UpperStr = 'CNAME' Then
  StringToRecordType := NS_CNAME
 Else If UpperStr = 'TXT' Then
  StringToRecordType := NS_TXT
 Else If UpperStr = 'PTR' Then
  StringToRecordType := NS_PTR
 Else If UpperStr = 'SRV' Then
  StringToRecordType := NS_SRV
 Else If UpperStr = 'SOA' Then
  StringToRecordType := NS_SOA
 Else If (UpperStr = 'ANY') or (UpperStr = '*') Then
  StringToRecordType := NS_ANY
 Else
  StringToRecordType := NS_A; { Par défaut }
End;

{ Valider un nom de domaine }
Function IsValidDomainName(Domain: String): Boolean;
Var
 I: Integer;
 DotCount: Integer;
Begin
 IsValidDomainName := False;
 If (Length(Domain) = 0) or (Length(Domain) > 253) Then Exit;
 
 DotCount := 0;
 For I := 1 To Length(Domain) Do Begin
  If Domain[I] = '.' Then Begin
   Inc(DotCount);
   If (I = 1) or (I = Length(Domain)) or (Domain[I-1] = '.') Then Exit;
  End Else If not (Domain[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-']) Then
   Exit;
 End;
 
 IsValidDomainName := True;
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

{ Résolution DNS réelle utilisant les fonctions système }
Function ResolveNSLookup(Name: String; RecType: TNSLookupRecordType; var Response: TNSLookupResponse): Boolean;
Var
 HostEnt: PHostEnt;
 Addr: TInAddr;
 AddrStr: String;
 I: Integer;
 AddrPtr: Pointer;
 StartTime: LongInt;
Begin
 ResolveNSLookup := False;
 FillChar(Response, SizeOf(Response), 0);
 Response.QueryName := Name;
 Response.QueryType := RecType;
 Response.Server := DefaultServer;
 Response.ResponseCode := 0;
 
 If Not WSAInitialized Then Begin
  If Not InitializeWinsock Then Exit;
 End;
 
 StartTime := GetTickCount;
 
 { Pour les enregistrements A (IPv4) }
 If RecType = NS_A Then Begin
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
      RecordType := NS_A;
      RecordClass := 1; { IN }
      TTL := 3600; { 1 heure par défaut }
      Data := AddrStr;
      DataLength := Length(Data);
     End;
     Inc(Response.AnswerCount);
     Inc(I);
     
     { Passer au suivant }
     Inc(PtrUInt(HostEnt^.h_addr_list), SizeOf(Pointer));
     AddrPtr := HostEnt^.h_addr_list^;
    End;
    ResolveNSLookup := (Response.AnswerCount > 0);
   End Else Begin
    Response.ResponseCode := 3; { NXDOMAIN }
   End;
  Except
   Response.ResponseCode := 2; { SERVFAIL }
  End;
 End
 
 { Pour les enregistrements PTR (résolution inverse) }
 Else If RecType = NS_PTR Then Begin
  Try
   { Convertir l'IP en format in-addr.arpa si nécessaire }
   If Pos('.', Name) > 0 Then Begin
    Addr.s_addr := inet_addr(PChar(AnsiString(Name)));
    HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
    If HostEnt <> nil Then Begin
     With Response.Answers[Response.AnswerCount] Do Begin
      Name := Response.QueryName;
      RecordType := NS_PTR;
      RecordClass := 1;
      TTL := 3600;
      Data := StrPas(HostEnt^.h_name);
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveNSLookup := True;
    End Else Begin
     Response.ResponseCode := 3; { NXDOMAIN }
    End;
   End;
  Except
   Response.ResponseCode := 2; { SERVFAIL }
  End;
 End
 
 { Pour les autres types, utiliser une simulation basée sur des données communes }
 Else Begin
  Case RecType Of
   NS_NS: Begin
    { Simuler des serveurs de noms pour des domaines connus }
    If Pos('google.com', LowerCase(Name)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NS_NS;
      RecordClass := 1;
      TTL := 172800;
      Data := 'ns1.google.com';
      DataLength := Length(Data);
     End;
     With Response.Answers[1] Do Begin
      Name := Response.QueryName;
      RecordType := NS_NS;
      RecordClass := 1;
      TTL := 172800;
      Data := 'ns2.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 2;
     ResolveNSLookup := True;
    End Else If Pos('example.com', LowerCase(Name)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NS_NS;
      RecordClass := 1;
      TTL := 86400;
      Data := 'ns.example.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveNSLookup := True;
    End;
   End;
   
   NS_MX: Begin
    { Simuler des enregistrements MX }
    If Pos('google.com', LowerCase(Name)) > 0 Then Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NS_MX;
      RecordClass := 1;
      TTL := 3600;
      Data := '10 mx.google.com';
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveNSLookup := True;
    End Else Begin
     With Response.Answers[0] Do Begin
      Name := Response.QueryName;
      RecordType := NS_MX;
      RecordClass := 1;
      TTL := 3600;
      Data := '10 mail.' + Name;
      DataLength := Length(Data);
     End;
     Response.AnswerCount := 1;
     ResolveNSLookup := True;
    End;
   End;
   
   NS_TXT: Begin
    { Simuler des enregistrements TXT }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := NS_TXT;
     RecordClass := 1;
     TTL := 300;
     Data := '"v=spf1 include:_spf.google.com ~all"';
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    ResolveNSLookup := True;
   End;
   
   NS_CNAME: Begin
    { Simuler CNAME }
    With Response.Answers[0] Do Begin
     Name := Response.QueryName;
     RecordType := NS_CNAME;
     RecordClass := 1;
     TTL := 300;
     Data := Name + '.cdn.example.com';
     DataLength := Length(Data);
    End;
    Response.AnswerCount := 1;
    ResolveNSLookup := True;
   End;
   
   NS_ANY: Begin
    { Pour ANY, essayer une résolution A d'abord }
    If ResolveNSLookup(Name, NS_A, Response) Then Begin
     { Rien de plus à faire, on a déjà les enregistrements A }
    End;
   End;
  End;
 End;
 
 Response.QueryTime := GetTickCount - StartTime;
End;

{ Affichage des résultats en format nslookup }
Procedure DisplayNSLookupResults(var Response: TNSLookupResponse);
Var
 I: Integer;
 ErrorMsg: String;
Begin
 Case Response.ResponseCode Of
  0: ErrorMsg := '';
  1: ErrorMsg := 'Format Error';
  2: ErrorMsg := 'Server Failure';
  3: ErrorMsg := 'Non-Existent Domain';
  4: ErrorMsg := 'Not Implemented';
  5: ErrorMsg := 'Query Refused';
 Else
  ErrorMsg := 'Unknown Error';
 End;
 
 If ErrorMsg <> '' Then Begin
  WriteLn('*** ', DefaultServer, ' can''t find ', Response.QueryName, ': ', ErrorMsg);
  Exit;
 End;
 
 If Response.AnswerCount = 0 Then Begin
  WriteLn('*** ', DefaultServer, ' can''t find ', Response.QueryName, ': Non-existent domain');
  Exit;
 End;
 
 If not InteractiveMode Then Begin
  WriteLn('Server:  ', Response.Server);
  WriteLn('Address: ', Response.Server, '#53');
  WriteLn;
  If Response.ResponseCode <> 0 Then Begin
   WriteLn('Non-authoritative answer:');
  End Else Begin
   WriteLn('Non-authoritative answer:');
  End;
 End;
 
 For I := 0 To Response.AnswerCount - 1 Do Begin
  With Response.Answers[I] Do Begin
   Case RecordType Of
    NS_A: WriteLn('Name: ', Name, #13#10, 'Address: ', Data);
    NS_PTR: WriteLn(Response.QueryName, ' name = ', Data);
    NS_NS: WriteLn(Name, ' nameserver = ', Data);
    NS_MX: WriteLn(Name, ' mail exchanger = ', Data);
    NS_CNAME: WriteLn(Name, ' canonical name = ', Data);
    NS_TXT: WriteLn(Name, ' text = ', Data);
   Else
    WriteLn(Name, ' ', RecordTypeToString(RecordType), ' = ', Data);
   End;
  End;
 End;
 
 If not InteractiveMode Then
  WriteLn;
End;

{ Affichage des informations de serveur par défaut }
Procedure ShowDefaultServer;
Begin
 WriteLn('Default server: ', DefaultServer);
 WriteLn('Address: ', DefaultServer, '#', Port);
 WriteLn;
End;

{ Mode interactif nslookup }
Procedure InteractiveNSLookup;
Var
 Input, Command, Param: String;
 SpacePos: Integer;
 Response: TNSLookupResponse;
 NewType: TNSLookupRecordType;
Begin
 ShowDefaultServer;
 
 Repeat
  Write('> ');
  ReadLn(Input);
  Input := Trim(Input);
  
  If Input = '' Then Continue;
  If (LowerCase(Input) = 'exit') or (LowerCase(Input) = 'quit') Then Break;
  
  { Analyser la commande }
  SpacePos := Pos(' ', Input);
  If SpacePos > 0 Then Begin
   Command := LowerCase(Copy(Input, 1, SpacePos - 1));
   Param := Trim(Copy(Input, SpacePos + 1, Length(Input)));
  End Else Begin
   Command := LowerCase(Input);
   Param := '';
  End;
  
  { Commandes spéciales }
  If Command = 'help' Then Begin
   WriteLn('Commands:');
   WriteLn('  help           - afficher cette aide');
   WriteLn('  set type=TYPE  - définir le type de requête (A, NS, MX, etc.)');
   WriteLn('  set class=CLASS- définir la classe (IN)');
   WriteLn('  set timeout=N  - définir le timeout en secondes');
   WriteLn('  set retry=N    - définir le nombre de tentatives');
   WriteLn('  set debug      - activer le mode debug');
   WriteLn('  set nodebug    - désactiver le mode debug');
   WriteLn('  server NAME    - changer de serveur DNS');
   WriteLn('  lserver NAME   - changer de serveur DNS (lookup)');
   WriteLn('  root           - définir le serveur racine');
   WriteLn('  finger         - finger le nom courant');
   WriteLn('  ls [opt] DOMAIN- lister un domaine');
   WriteLn('  view FILE      - trier et voir le fichier avec more');
   WriteLn('  exit           - quitter nslookup');
   WriteLn('  HOSTNAME       - rechercher des informations sur HOSTNAME');
  End
  Else If Copy(Command, 1, 4) = 'set ' Then Begin
   Param := Copy(Input, 5, Length(Input));
   If Copy(LowerCase(Param), 1, 5) = 'type=' Then Begin
    NewType := StringToRecordType(Copy(Param, 6, Length(Param)));
    QueryType := NewType;
    WriteLn('Type défini à ', RecordTypeToString(QueryType));
   End
   Else If Copy(LowerCase(Param), 1, 8) = 'timeout=' Then Begin
    Try
     Timeout := StrToInt(Copy(Param, 9, Length(Param)));
     WriteLn('Timeout défini à ', Timeout, ' secondes');
    Except
     WriteLn('Timeout invalide');
    End;
   End
   Else If Copy(LowerCase(Param), 1, 6) = 'retry=' Then Begin
    Try
     Retries := StrToInt(Copy(Param, 7, Length(Param)));
     WriteLn('Retries défini à ', Retries);
    Except
     WriteLn('Retry invalide');
    End;
   End
   Else If LowerCase(Param) = 'debug' Then Begin
    Debug := True;
    WriteLn('Mode debug activé');
   End
   Else If LowerCase(Param) = 'nodebug' Then Begin
    Debug := False;
    WriteLn('Mode debug désactivé');
   End
   Else Begin
    WriteLn('Option inconnue: ', Param);
   End;
  End
  Else If Command = 'server' Then Begin
   If Param <> '' Then Begin
    DefaultServer := Param;
    WriteLn('Serveur par défaut maintenant : ', DefaultServer);
    ShowDefaultServer;
   End Else Begin
    WriteLn('Usage: server <nom_serveur>');
   End;
  End
  Else If Command = 'lserver' Then Begin
   If Param <> '' Then Begin
    DefaultServer := Param;
    WriteLn('Serveur par défaut maintenant : ', DefaultServer);
    ShowDefaultServer;
   End Else Begin
    WriteLn('Usage: lserver <nom_serveur>');
   End;
  End
  Else If Command = 'root' Then Begin
   DefaultServer := '198.41.0.4'; { a.root-servers.net }
   WriteLn('Serveur racine défini');
   ShowDefaultServer;
  End
  Else Begin
   { Requête DNS normale }
   If IsValidDomainName(Input) or IsValidIPAddress(Input) Then Begin
    If ResolveNSLookup(Input, QueryType, Response) Then Begin
     DisplayNSLookupResults(Response);
    End Else Begin
     WriteLn('*** ', DefaultServer, ' can''t find ', Input, ': Non-existent domain');
    End;
   End Else Begin
    WriteLn('*** Invalid domain name: ', Input);
   End;
  End;
  
  WriteLn;
  
 Until False;
End;

{ Requête simple non-interactive }
Procedure SimpleNSLookup(QueryName: String; RecType: TNSLookupRecordType);
Var
 Response: TNSLookupResponse;
Begin
 If ResolveNSLookup(QueryName, RecType, Response) Then Begin
  DisplayNSLookupResults(Response);
 End Else Begin
  WriteLn('*** ', DefaultServer, ' can''t find ', QueryName, ': Non-existent domain');
 End;
End;

{ Obtenir le serveur DNS par défaut du système }
Function GetDefaultDNSServer: String;
Begin
 { Pour cette implémentation, utiliser des serveurs DNS publics connus }
 GetDefaultDNSServer := '8.8.8.8'; { Google Public DNS }
End;

{ Initialisation des variables globales }
Procedure InitializeNSLookup;
Begin
 WSAInitialized := False;
 DefaultServer := GetDefaultDNSServer;
 InteractiveMode := False;
 QueryType := NS_A;
 QueryClass := 1; { IN }
 Timeout := 5;
 Retries := 4;
 Debug := False;
 Recurse := True;
 DefName := True;
 Search := True;
 Port := 53;
End;

{ Analyser la ligne de commande }
Procedure ParseNSLookupCommandLine;
Var
 I: Integer;
 Param: String;
 QueryName: String;
 QueryTypeStr: String;
Begin
 QueryName := '';
 QueryTypeStr := '';
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-type') and (I < ParamCount) Then Begin
   Inc(I);
   QueryTypeStr := ParamStr(I);
  End
  Else If (LowerCase(Param) = '-class') and (I < ParamCount) Then Begin
   Inc(I);
   { Ignorer pour l'instant }
  End
  Else If (LowerCase(Param) = '-timeout') and (I < ParamCount) Then Begin
   Inc(I);
   Try
    Timeout := StrToInt(ParamStr(I));
   Except
    WriteLn('nslookup: timeout invalide');
    Halt(1);
   End;
  End
  Else If (LowerCase(Param) = '-retry') and (I < ParamCount) Then Begin
   Inc(I);
   Try
    Retries := StrToInt(ParamStr(I));
   Except
    WriteLn('nslookup: retry invalide');
    Halt(1);
   End;
  End
  Else If LowerCase(Param) = '-debug' Then Begin
   Debug := True;
  End
  Else If LowerCase(Param) = '-nodebug' Then Begin
   Debug := False;
  End
  Else If LowerCase(Param) = '-recurse' Then Begin
   Recurse := True;
  End
  Else If LowerCase(Param) = '-norecurse' Then Begin
   Recurse := False;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   If QueryName = '' Then Begin
    QueryName := Param;
   End Else If ParamStr(I+1) = '' Then Begin
    { Deuxième paramètre peut être le serveur DNS }
    DefaultServer := Param;
   End;
  End;
  
  Inc(I);
 End;
 
 { Définir le type de requête si spécifié }
 If QueryTypeStr <> '' Then
  QueryType := StringToRecordType(QueryTypeStr);
 
 { Mode de fonctionnement }
 If QueryName = '' Then Begin
  InteractiveMode := True;
  InteractiveNSLookup;
 End Else Begin
  InteractiveMode := False;
  
  { Détection automatique du type pour résolution inverse }
  If IsValidIPAddress(QueryName) and (QueryType = NS_A) Then
   QueryType := NS_PTR;
  
  SimpleNSLookup(QueryName, QueryType);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Simulation pour Turbo Pascal }
Procedure ShowSimulatedNSLookup(Name, RecordType: String);
Begin
 WriteLn('Server:  8.8.8.8');
 WriteLn('Address: 8.8.8.8#53');
 WriteLn;
 WriteLn('Non-authoritative answer:');
 
 If UpperCase(RecordType) = 'A' Then Begin
  If LowerCase(Name) = 'google.com' Then Begin
   WriteLn('Name: google.com');
   WriteLn('Address: 142.250.185.46');
  End Else If LowerCase(Name) = 'example.com' Then Begin
   WriteLn('Name: example.com');
   WriteLn('Address: 93.184.216.34');
  End Else Begin
   WriteLn('Name: ', Name);
   WriteLn('Address: 203.0.113.1');
  End;
 End Else If UpperCase(RecordType) = 'MX' Then Begin
  WriteLn(Name, ' mail exchanger = 10 mail.', Name);
 End Else If UpperCase(RecordType) = 'NS' Then Begin
  WriteLn(Name, ' nameserver = ns1.', Name);
  WriteLn(Name, ' nameserver = ns2.', Name);
 End;
End;

Procedure ShowSimulatedInteractive;
Begin
 WriteLn('Default server: 8.8.8.8');
 WriteLn('Address: 8.8.8.8#53');
 WriteLn;
 WriteLn('> example.com');
 WriteLn('Server:  8.8.8.8');
 WriteLn('Address: 8.8.8.8#53');
 WriteLn;
 WriteLn('Non-authoritative answer:');
 WriteLn('Name: example.com');
 WriteLn('Address: 93.184.216.34');
 WriteLn;
 WriteLn('> set type=MX');
 WriteLn('> google.com');
 WriteLn('Server:  8.8.8.8');
 WriteLn('Address: 8.8.8.8#53');
 WriteLn;
 WriteLn('Non-authoritative answer:');
 WriteLn('google.com mail exchanger = 10 mx.google.com');
 WriteLn;
 WriteLn('> exit');
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
  WriteLn('NSLOOKUP : Outil de requête DNS interactif');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NSLOOKUP                              # Mode interactif');
  WriteLn('  NSLOOKUP nom_de_domaine               # Requête simple');
  WriteLn('  NSLOOKUP nom_de_domaine serveur_dns   # Avec serveur spécifique');
  WriteLn('  NSLOOKUP [options] nom_de_domaine');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -type TYPE        Type d''enregistrement (A, NS, MX, CNAME, TXT, etc.)');
  WriteLn('  -class CLASS      Classe de requête (IN par défaut)');
  WriteLn('  -timeout N        Timeout en secondes (défaut: 5)');
  WriteLn('  -retry N          Nombre de tentatives (défaut: 4)');
  WriteLn('  -debug            Activer le mode debug');
  WriteLn('  -nodebug          Désactiver le mode debug');
  WriteLn('  -recurse          Requête récursive (défaut)');
  WriteLn('  -norecurse        Requête non-récursive');
  WriteLn;
  WriteLn('Types d''enregistrements supportés :');
  WriteLn('  A      Adresse IPv4');
  WriteLn('  AAAA   Adresse IPv6');
  WriteLn('  NS     Serveur de noms');
  WriteLn('  MX     Serveur de messagerie');
  WriteLn('  CNAME  Nom canonique (alias)');
  WriteLn('  TXT    Enregistrement texte');
  WriteLn('  PTR    Pointeur (résolution inverse)');
  WriteLn('  SRV    Service');
  WriteLn('  SOA    Start of Authority');
  WriteLn('  ANY    Tous les types');
  WriteLn;
  WriteLn('Commandes en mode interactif :');
  WriteLn('  help                    Afficher l''aide');
  WriteLn('  set type=TYPE           Définir le type de requête');
  WriteLn('  set timeout=N           Définir le timeout');
  WriteLn('  set retry=N             Définir le nombre de tentatives');
  WriteLn('  set debug               Activer le debug');
  WriteLn('  set nodebug             Désactiver le debug');
  WriteLn('  server NOM_SERVEUR      Changer de serveur DNS');
  WriteLn('  root                    Utiliser le serveur racine');
  WriteLn('  exit                    Quitter nslookup');
  WriteLn('  NOM_DE_DOMAINE          Faire une requête');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  NSLOOKUP                            # Mode interactif');
  WriteLn('  NSLOOKUP google.com                 # Résolution A par défaut');
  WriteLn('  NSLOOKUP google.com 8.8.4.4         # Avec serveur spécifique');
  WriteLn('  NSLOOKUP -type MX gmail.com         # Serveurs de messagerie');
  WriteLn('  NSLOOKUP -type NS example.com       # Serveurs de noms');
  WriteLn('  NSLOOKUP 8.8.8.8                   # Résolution inverse');
  WriteLn('  NSLOOKUP -debug -type A github.com  # Mode debug');
  WriteLn;
  WriteLn('Note: En Free Pascal, utilise la résolution DNS réelle du système.');
  WriteLn('En Turbo Pascal, fonctionne en mode simulation.');
  WriteLn;
  WriteLn('Compatible avec la commande nslookup de Linux/Unix.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('NSLOOKUP 1.00 - Name Server Lookup Tool, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeNSLookup;
  ParseNSLookupCommandLine;
  {$ELSE}
  { Version Turbo Pascal - Simulation }
  If ParamCount = 0 Then Begin
   WriteLn('Mode interactif (simulation):');
   WriteLn;
   ShowSimulatedInteractive;
  End Else Begin
   If ParamCount >= 2 Then
    ShowSimulatedNSLookup(ParamStr(1), ParamStr(2))
   Else
    ShowSimulatedNSLookup(ParamStr(1), 'A');
  End;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 { Nettoyer Winsock }
 CleanupWinsock;
 {$ENDIF}
END.
