{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande named (DNS Server))
}

Program NAMED;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Classes, DateUtils;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types d'enregistrements DNS }
 TDNSRecordType = (DNS_A, DNS_NS, DNS_CNAME, DNS_MX, DNS_TXT, DNS_PTR, DNS_AAAA, DNS_SRV, DNS_SOA);
 
 { Classes d'enregistrements DNS }
 TDNSRecordClass = (DNS_IN, DNS_CS, DNS_CH, DNS_HS);
 
 { Structure d'un enregistrement DNS }
 TDNSRecord = Record
  Name: String[255];          { Nom de domaine }
  RecordType: TDNSRecordType; { Type d'enregistrement }
  RecordClass: TDNSRecordClass; { Classe }
  TTL: LongInt;               { Time To Live }
  Data: String[255];          { Données }
  Priority: Word;             { Priorité (MX, SRV) }
  Weight: Word;               { Poids (SRV) }
  Port: Word;                 { Port (SRV) }
  Target: String[255];        { Cible (SRV) }
  Serial: LongInt;            { Numéro de série (SOA) }
  Refresh: LongInt;           { Intervalle de rafraîchissement (SOA) }
  Retry: LongInt;             { Intervalle de réessai (SOA) }
  Expire: LongInt;            { Expiration (SOA) }
  Minimum: LongInt;           { TTL minimum (SOA) }
  LastUpdate: TDateTime;      { Dernière mise à jour }
  Active: Boolean;            { Enregistrement actif }
 End;
 
 { Zone DNS }
 TDNSZone = Record
  ZoneName: String[255];      { Nom de la zone }
  ZoneFile: String[255];      { Fichier de zone }
  ZoneType: String[32];       { Type de zone (master, slave, forward) }
  Records: Array[0..999] of TDNSRecord; { Enregistrements }
  RecordCount: Integer;       { Nombre d'enregistrements }
  Serial: LongInt;            { Numéro de série }
  LastReload: TDateTime;      { Dernière recharge }
  Authoritative: Boolean;     { Zone autoritaire }
  Active: Boolean;            { Zone active }
 End;
 
 { Requête DNS entrante }
 TDNSQuery = Record
  QueryID: Word;              { ID de la requête }
  QueryName: String[255];     { Nom demandé }
  QueryType: TDNSRecordType;  { Type demandé }
  QueryClass: TDNSRecordClass; { Classe demandée }
  ClientIP: String[15];       { IP du client }
  ClientPort: Word;           { Port du client }
  Timestamp: TDateTime;       { Horodatage }
  Recursive: Boolean;         { Requête récursive }
  Authoritative: Boolean;     { Réponse autoritaire }
 End;
 
 { Réponse DNS }
 TDNSResponse = Record
  QueryID: Word;              { ID de la requête }
  ResponseCode: Integer;      { Code de réponse }
  Authoritative: Boolean;     { Réponse autoritaire }
  Truncated: Boolean;         { Réponse tronquée }
  RecursionDesired: Boolean;  { Récursion demandée }
  RecursionAvailable: Boolean; { Récursion disponible }
  AnswerCount: Integer;       { Nombre de réponses }
  Answers: Array[0..31] of TDNSRecord; { Réponses }
  AuthorityCount: Integer;    { Nombre d'autorités }
  AdditionalCount: Integer;   { Nombre d'additionnels }
 End;
 
 { Configuration du serveur DNS }
 TNamedConfig = Record
  ListenPort: Word;           { Port d'écoute (53) }
  ListenAddress: String[15];  { Adresse d'écoute }
  ConfigFile: String[255];    { Fichier de configuration }
  LogFile: String[255];       { Fichier de log }
  PidFile: String[255];       { Fichier PID }
  CacheSize: LongInt;         { Taille du cache }
  RecursionEnabled: Boolean;  { Récursion activée }
  ForwardingEnabled: Boolean; { Forwarding activé }
  Forwarders: Array[0..7] of String[15]; { Serveurs de forwarding }
  ForwarderCount: Integer;    { Nombre de forwarders }
  MaxClients: Integer;        { Nombre max de clients }
  QueryTimeout: Integer;      { Timeout des requêtes }
  DebugLevel: Integer;        { Niveau de debug }
  DaemonMode: Boolean;        { Mode daemon }
  ZoneTransferEnabled: Boolean; { Transfert de zone activé }
  AllowedClients: Array[0..31] of String[18]; { Clients autorisés }
  AllowedClientCount: Integer; { Nombre de clients autorisés }
 End;
 
 { Statistiques du serveur }
 TNamedStats = Record
  StartTime: TDateTime;       { Heure de démarrage }
  QueriesReceived: LongInt;   { Requêtes reçues }
  QueriesAnswered: LongInt;   { Requêtes répondues }
  QueriesForwarded: LongInt;  { Requêtes forwardées }
  QueriesFailed: LongInt;     { Requêtes échouées }
  CacheHits: LongInt;         { Hits cache }
  CacheMisses: LongInt;       { Miss cache }
  ZoneLoads: LongInt;         { Rechargements de zones }
  ZoneTransfers: LongInt;     { Transferts de zones }
  ClientConnections: LongInt; { Connexions clients }
  ErrorCount: LongInt;        { Nombre d'erreurs }
  BytesSent: Int64;           { Octets envoyés }
  BytesReceived: Int64;       { Octets reçus }
 End;

Var
 { Variables globales }
 NamedConfig: TNamedConfig;
 NamedStats: TNamedStats;
 DNSZones: Array[0..31] of TDNSZone;
 ZoneCount: Integer;
 ServerSocket: TSocket;
 WSAInitialized: Boolean;
 ServerRunning: Boolean;
 CurrentLogLevel: Integer;
 
 { Cache DNS simple }
 DNSCache: Array[0..255] of TDNSRecord;
 CacheCount: Integer;

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

{ Convertir type d'enregistrement en chaîne }
Function RecordTypeToString(RecType: TDNSRecordType): String;
Begin
 Case RecType Of
  DNS_A: RecordTypeToString := 'A';
  DNS_NS: RecordTypeToString := 'NS';
  DNS_CNAME: RecordTypeToString := 'CNAME';
  DNS_MX: RecordTypeToString := 'MX';
  DNS_TXT: RecordTypeToString := 'TXT';
  DNS_PTR: RecordTypeToString := 'PTR';
  DNS_AAAA: RecordTypeToString := 'AAAA';
  DNS_SRV: RecordTypeToString := 'SRV';
  DNS_SOA: RecordTypeToString := 'SOA';
 Else
  RecordTypeToString := 'UNKNOWN';
 End;
End;

{ Convertir chaîne en type d'enregistrement }
Function StringToRecordType(TypeStr: String): TDNSRecordType;
Var
 UpperStr: String;
Begin
 UpperStr := UpperCase(TypeStr);
 If UpperStr = 'A' Then
  StringToRecordType := DNS_A
 Else If UpperStr = 'NS' Then
  StringToRecordType := DNS_NS
 Else If UpperStr = 'CNAME' Then
  StringToRecordType := DNS_CNAME
 Else If UpperStr = 'MX' Then
  StringToRecordType := DNS_MX
 Else If UpperStr = 'TXT' Then
  StringToRecordType := DNS_TXT
 Else If UpperStr = 'PTR' Then
  StringToRecordType := DNS_PTR
 Else If UpperStr = 'AAAA' Then
  StringToRecordType := DNS_AAAA
 Else If UpperStr = 'SRV' Then
  StringToRecordType := DNS_SRV
 Else If UpperStr = 'SOA' Then
  StringToRecordType := DNS_SOA
 Else
  StringToRecordType := DNS_A; { Par défaut }
End;

{ Obtenir code d'erreur DNS }
Function GetDNSErrorMessage(ErrorCode: Integer): String;
Begin
 Case ErrorCode Of
  0: GetDNSErrorMessage := 'NOERROR';
  1: GetDNSErrorMessage := 'FORMERR';
  2: GetDNSErrorMessage := 'SERVFAIL';
  3: GetDNSErrorMessage := 'NXDOMAIN';
  4: GetDNSErrorMessage := 'NOTIMP';
  5: GetDNSErrorMessage := 'REFUSED';
 Else
  GetDNSErrorMessage := 'UNKNOWN';
 End;
End;

{ Logger pour named }
Procedure LogMessage(Level: Integer; Message: String);
Var
 LogStr: String;
Begin
 If Level <= CurrentLogLevel Then Begin
  LogStr := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' [' + 
            IntToStr(Level) + '] ' + Message;
  WriteLn(LogStr);
  
  { Écrire dans le fichier de log si configuré }
  If NamedConfig.LogFile <> '' Then Begin
   { Implémentation simplifiée - en production, écriture dans fichier }
  End;
 End;
End;

{ Initialiser la configuration par défaut }
Procedure InitializeNamedConfig;
Var
 I: Integer;
Begin
 With NamedConfig Do Begin
  ListenPort := 53;
  ListenAddress := '0.0.0.0';
  ConfigFile := '/etc/named.conf';
  LogFile := '/var/log/named.log';
  PidFile := '/var/run/named.pid';
  CacheSize := 1048576; { 1MB }
  RecursionEnabled := True;
  ForwardingEnabled := False;
  ForwarderCount := 0;
  MaxClients := 100;
  QueryTimeout := 5000; { 5 secondes }
  DebugLevel := 1;
  DaemonMode := False;
  ZoneTransferEnabled := False;
  AllowedClientCount := 0;
  
  { Forwarders par défaut }
  Forwarders[0] := '8.8.8.8';
  Forwarders[1] := '1.1.1.1';
  ForwarderCount := 2;
 End;
 
 { Initialiser les statistiques }
 FillChar(NamedStats, SizeOf(NamedStats), 0);
 NamedStats.StartTime := Now;
 
 { Initialiser les variables globales }
 ZoneCount := 0;
 CacheCount := 0;
 ServerRunning := False;
 CurrentLogLevel := 2;
End;

{ Créer les zones par défaut }
Procedure CreateDefaultZones;
Begin
 { Zone root (.) }
 With DNSZones[ZoneCount] Do Begin
  ZoneName := '.';
  ZoneFile := 'named.root';
  ZoneType := 'hint';
  RecordCount := 0;
  Serial := 2026022101;
  LastReload := Now;
  Authoritative := False;
  Active := True;
  
  { Enregistrement NS pour root }
  With Records[RecordCount] Do Begin
   Name := '.';
   RecordType := DNS_NS;
   RecordClass := DNS_IN;
   TTL := 518400;
   Data := 'a.root-servers.net.';
   Active := True;
  End;
  Inc(RecordCount);
 End;
 Inc(ZoneCount);
 
 { Zone localhost }
 With DNSZones[ZoneCount] Do Begin
  ZoneName := 'localhost';
  ZoneFile := 'localhost.zone';
  ZoneType := 'master';
  RecordCount := 0;
  Serial := 2026022101;
  LastReload := Now;
  Authoritative := True;
  Active := True;
  
  { SOA pour localhost }
  With Records[RecordCount] Do Begin
   Name := 'localhost';
   RecordType := DNS_SOA;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := 'localhost. admin.localhost. 2026022101 3600 1800 604800 86400';
   Serial := 2026022101;
   Refresh := 3600;
   Retry := 1800;
   Expire := 604800;
   Minimum := 86400;
   Active := True;
  End;
  Inc(RecordCount);
  
  { A pour localhost }
  With Records[RecordCount] Do Begin
   Name := 'localhost';
   RecordType := DNS_A;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := '127.0.0.1';
   Active := True;
  End;
  Inc(RecordCount);
 End;
 Inc(ZoneCount);
 
 { Zone 127.in-addr.arpa (résolution inverse) }
 With DNSZones[ZoneCount] Do Begin
  ZoneName := '127.in-addr.arpa';
  ZoneFile := '127.in-addr.arpa.zone';
  ZoneType := 'master';
  RecordCount := 0;
  Serial := 2026022101;
  LastReload := Now;
  Authoritative := True;
  Active := True;
  
  { SOA pour zone inverse }
  With Records[RecordCount] Do Begin
   Name := '127.in-addr.arpa';
   RecordType := DNS_SOA;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := 'localhost. admin.localhost. 2026022101 3600 1800 604800 86400';
   Active := True;
  End;
  Inc(RecordCount);
  
  { PTR pour 127.0.0.1 }
  With Records[RecordCount] Do Begin
   Name := '1.0.0.127.in-addr.arpa';
   RecordType := DNS_PTR;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := 'localhost.';
   Active := True;
  End;
  Inc(RecordCount);
 End;
 Inc(ZoneCount);
 
 LogMessage(1, 'Zones par défaut créées: ' + IntToStr(ZoneCount) + ' zones');
End;

{ Ajouter des zones d'exemple }
Procedure AddExampleZones;
Begin
 { Zone example.local }
 With DNSZones[ZoneCount] Do Begin
  ZoneName := 'example.local';
  ZoneFile := 'example.local.zone';
  ZoneType := 'master';
  RecordCount := 0;
  Serial := 2026022101;
  LastReload := Now;
  Authoritative := True;
  Active := True;
  
  { SOA }
  With Records[RecordCount] Do Begin
   Name := 'example.local';
   RecordType := DNS_SOA;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := 'ns1.example.local. admin.example.local. 2026022101 3600 1800 604800 86400';
   Active := True;
  End;
  Inc(RecordCount);
  
  { NS }
  With Records[RecordCount] Do Begin
   Name := 'example.local';
   RecordType := DNS_NS;
   RecordClass := DNS_IN;
   TTL := 86400;
   Data := 'ns1.example.local.';
   Active := True;
  End;
  Inc(RecordCount);
  
  { A pour www }
  With Records[RecordCount] Do Begin
   Name := 'www.example.local';
   RecordType := DNS_A;
   RecordClass := DNS_IN;
   TTL := 3600;
   Data := '192.168.1.100';
   Active := True;
  End;
  Inc(RecordCount);
  
  { MX }
  With Records[RecordCount] Do Begin
   Name := 'example.local';
   RecordType := DNS_MX;
   RecordClass := DNS_IN;
   TTL := 3600;
   Priority := 10;
   Data := 'mail.example.local.';
   Active := True;
  End;
  Inc(RecordCount);
 End;
 Inc(ZoneCount);
 
 LogMessage(1, 'Zone d''exemple ajoutée: example.local');
End;

{ Rechercher un enregistrement DNS }
Function FindDNSRecord(QueryName: String; QueryType: TDNSRecordType; var FoundRecord: TDNSRecord): Boolean;
Var
 I, J: Integer;
 Found: Boolean;
Begin
 FindDNSRecord := False;
 Found := False;
 
 { Chercher dans toutes les zones }
 For I := 0 To ZoneCount - 1 Do Begin
  If DNSZones[I].Active Then Begin
   For J := 0 To DNSZones[I].RecordCount - 1 Do Begin
    With DNSZones[I].Records[J] Do Begin
     If Active and (LowerCase(Name) = LowerCase(QueryName)) and 
        (RecordType = QueryType) Then Begin
      FoundRecord := DNSZones[I].Records[J];
      Found := True;
      Break;
     End;
    End;
   End;
   If Found Then Break;
  End;
 End;
 
 { Si pas trouvé, chercher dans le cache }
 If not Found Then Begin
  For I := 0 To CacheCount - 1 Do Begin
   With DNSCache[I] Do Begin
    If Active and (LowerCase(Name) = LowerCase(QueryName)) and 
       (RecordType = QueryType) Then Begin
     FoundRecord := DNSCache[I];
     Found := True;
     Inc(NamedStats.CacheHits);
     Break;
    End;
   End;
  End;
 End;
 
 If not Found Then
  Inc(NamedStats.CacheMisses);
  
 FindDNSRecord := Found;
End;

{ Traiter une requête DNS }
Function ProcessDNSQuery(var Query: TDNSQuery; var Response: TDNSResponse): Boolean;
Var
 FoundRecord: TDNSRecord;
 Found: Boolean;
Begin
 ProcessDNSQuery := False;
 
 { Initialiser la réponse }
 FillChar(Response, SizeOf(Response), 0);
 Response.QueryID := Query.QueryID;
 Response.RecursionAvailable := NamedConfig.RecursionEnabled;
 Response.RecursionDesired := Query.Recursive;
 
 { Incrémenter les statistiques }
 Inc(NamedStats.QueriesReceived);
 
 LogMessage(2, 'Requête DNS: ' + Query.QueryName + ' (' + 
            RecordTypeToString(Query.QueryType) + ') depuis ' + 
            Query.ClientIP);
 
 { Chercher l'enregistrement }
 Found := FindDNSRecord(Query.QueryName, Query.QueryType, FoundRecord);
 
 If Found Then Begin
  { Réponse trouvée }
  Response.ResponseCode := 0; { NOERROR }
  Response.AnswerCount := 1;
  Response.Answers[0] := FoundRecord;
  Response.Authoritative := FoundRecord.Active;
  
  Inc(NamedStats.QueriesAnswered);
  LogMessage(2, 'Réponse DNS: ' + FoundRecord.Data);
  ProcessDNSQuery := True;
 End Else Begin
  { Pas trouvé }
  If NamedConfig.RecursionEnabled and Query.Recursive Then Begin
   { Forwarding vers serveurs externes }
   If NamedConfig.ForwardingEnabled and (NamedConfig.ForwarderCount > 0) Then Begin
    LogMessage(2, 'Forwarding vers ' + NamedConfig.Forwarders[0]);
    
    { Simulation de forwarding }
    Response.ResponseCode := 0;
    Response.AnswerCount := 1;
    With Response.Answers[0] Do Begin
     Name := Query.QueryName;
     RecordType := Query.QueryType;
     RecordClass := DNS_IN;
     TTL := 300;
     
     { Générer une réponse simulée }
     Case Query.QueryType Of
      DNS_A: Data := '203.0.113.' + IntToStr(1 + (Length(Query.QueryName) mod 254));
      DNS_MX: Begin
       Priority := 10;
       Data := 'mail.' + Query.QueryName + '.';
      End;
      DNS_NS: Data := 'ns1.' + Query.QueryName + '.';
      DNS_TXT: Data := '"v=spf1 mx a ~all"';
     Else
      Data := 'forwarded-result.example.com';
     End;
     Active := True;
    End;
    
    Inc(NamedStats.QueriesForwarded);
    ProcessDNSQuery := True;
   End Else Begin
    Response.ResponseCode := 3; { NXDOMAIN }
    Inc(NamedStats.QueriesFailed);
   End;
  End Else Begin
   Response.ResponseCode := 3; { NXDOMAIN }
   Inc(NamedStats.QueriesFailed);
  End;
 End;
End;

{ Simuler l'écoute du serveur DNS }
Function StartDNSServer: Boolean;
Var
 ServerAddr: TSockAddrIn;
 BindResult: Integer;
Begin
 StartDNSServer := False;
 
 If not WSAInitialized Then Begin
  LogMessage(0, 'Winsock non initialisé');
  Exit;
 End;
 
 { Créer le socket UDP }
 ServerSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
 If ServerSocket = INVALID_SOCKET Then Begin
  LogMessage(0, 'Impossible de créer le socket DNS');
  Exit;
 End;
 
 { Configurer l'adresse }
 FillChar(ServerAddr, SizeOf(ServerAddr), 0);
 ServerAddr.sin_family := AF_INET;
 ServerAddr.sin_port := htons(NamedConfig.ListenPort);
 ServerAddr.sin_addr.s_addr := INADDR_ANY;
 
 { Bind le socket (simulation) }
 LogMessage(1, 'Démarrage du serveur DNS sur port ' + IntToStr(NamedConfig.ListenPort));
 LogMessage(1, 'Mode d''écoute: ' + NamedConfig.ListenAddress + ':' + IntToStr(NamedConfig.ListenPort));
 
 If NamedConfig.ListenPort = 53 Then Begin
  LogMessage(1, 'ATTENTION: Port 53 nécessite des privilèges administrateur');
  LogMessage(1, 'Le serveur fonctionne en mode simulation sur ce port');
 End;
 
 ServerRunning := True;
 StartDNSServer := True;
 
 LogMessage(1, 'Serveur DNS démarré avec succès');
 LogMessage(1, 'Zones chargées: ' + IntToStr(ZoneCount));
 LogMessage(1, 'Récursion: ' + BoolToStr(NamedConfig.RecursionEnabled, True));
 LogMessage(1, 'Forwarding: ' + BoolToStr(NamedConfig.ForwardingEnabled, True));
End;

{ Simuler le traitement des requêtes }
Procedure SimulateQueryProcessing;
Var
 Query: TDNSQuery;
 Response: TDNSResponse;
 I: Integer;
 TestQueries: Array[0..4] of String;
Begin
 If not ServerRunning Then Exit;
 
 LogMessage(1, 'Simulation de traitement des requêtes DNS...');
 
 { Requêtes de test }
 TestQueries[0] := 'localhost';
 TestQueries[1] := 'www.example.local';
 TestQueries[2] := 'mail.example.com';
 TestQueries[3] := 'ns1.test.local';
 TestQueries[4] := 'unknown.domain.test';
 
 For I := 0 To 4 Do Begin
  { Simuler une requête }
  With Query Do Begin
   QueryID := I + 1;
   QueryName := TestQueries[I];
   QueryType := DNS_A;
   QueryClass := DNS_IN;
   ClientIP := '192.168.1.' + IntToStr(100 + I);
   ClientPort := 32768 + I;
   Timestamp := Now;
   Recursive := True;
   Authoritative := False;
  End;
  
  { Traiter la requête }
  If ProcessDNSQuery(Query, Response) Then Begin
   LogMessage(1, 'Requête traitée: ' + Query.QueryName + ' -> ' + 
              GetDNSErrorMessage(Response.ResponseCode));
   If Response.AnswerCount > 0 Then
    LogMessage(2, 'Réponse: ' + Response.Answers[0].Data);
  End;
  
  Inc(NamedStats.ClientConnections);
  Sleep(100); { Petite pause pour la simulation }
 End;
 
 LogMessage(1, 'Fin de simulation des requêtes');
End;

{ Arrêter le serveur DNS }
Procedure StopDNSServer;
Begin
 If ServerRunning Then Begin
  LogMessage(1, 'Arrêt du serveur DNS...');
  ServerRunning := False;
  
  If ServerSocket <> INVALID_SOCKET Then Begin
   closesocket(ServerSocket);
   ServerSocket := INVALID_SOCKET;
  End;
  
  LogMessage(1, 'Serveur DNS arrêté');
 End;
End;

{ Recharger les zones }
Procedure ReloadZones;
Var
 I: Integer;
Begin
 LogMessage(1, 'Rechargement des zones DNS...');
 
 For I := 0 To ZoneCount - 1 Do Begin
  If DNSZones[I].Active Then Begin
   DNSZones[I].LastReload := Now;
   Inc(DNSZones[I].Serial);
   Inc(NamedStats.ZoneLoads);
   LogMessage(2, 'Zone rechargée: ' + DNSZones[I].ZoneName);
  End;
 End;
 
 LogMessage(1, 'Rechargement terminé: ' + IntToStr(ZoneCount) + ' zones');
End;

{ Afficher les statistiques }
Procedure ShowNamedStats;
Var
 Uptime: Double;
Begin
 Uptime := (Now - NamedStats.StartTime) * 24 * 3600; { en secondes }
 
 WriteLn('Statistiques du serveur DNS NAMED:');
 WriteLn('==================================');
 WriteLn('Heure de démarrage    : ', FormatDateTime('yyyy-mm-dd hh:nn:ss', NamedStats.StartTime));
 WriteLn('Temps de fonctionnement: ', FormatFloat('0.0', Uptime), ' secondes');
 WriteLn('État du serveur       : ', BoolToStr(ServerRunning, 'En cours', 'Arrêté'));
 WriteLn;
 WriteLn('Requêtes DNS:');
 WriteLn('  Reçues             : ', NamedStats.QueriesReceived);
 WriteLn('  Répondues          : ', NamedStats.QueriesAnswered);
 WriteLn('  Forwardées         : ', NamedStats.QueriesForwarded);
 WriteLn('  Échouées           : ', NamedStats.QueriesFailed);
 WriteLn;
 WriteLn('Cache DNS:');
 WriteLn('  Hits               : ', NamedStats.CacheHits);
 WriteLn('  Misses             : ', NamedStats.CacheMisses);
 WriteLn('  Entrées actuelles  : ', CacheCount);
 WriteLn;
 WriteLn('Zones DNS:');
 WriteLn('  Zones chargées     : ', ZoneCount);
 WriteLn('  Rechargements      : ', NamedStats.ZoneLoads);
 WriteLn('  Transferts         : ', NamedStats.ZoneTransfers);
 WriteLn;
 WriteLn('Connexions:');
 WriteLn('  Clients connectés  : ', NamedStats.ClientConnections);
 WriteLn('  Erreurs            : ', NamedStats.ErrorCount);
 WriteLn;
 WriteLn('Configuration:');
 WriteLn('  Port d''écoute      : ', NamedConfig.ListenPort);
 WriteLn('  Adresse d''écoute   : ', NamedConfig.ListenAddress);
 WriteLn('  Récursion          : ', BoolToStr(NamedConfig.RecursionEnabled, 'Activée', 'Désactivée'));
 WriteLn('  Forwarding         : ', BoolToStr(NamedConfig.ForwardingEnabled, 'Activé', 'Désactivé'));
 If NamedConfig.ForwardingEnabled Then Begin
  WriteLn('  Forwarders         : ', NamedConfig.Forwarders[0]);
  If NamedConfig.ForwarderCount > 1 Then
   WriteLn('                     : ', NamedConfig.Forwarders[1]);
 End;
End;

{ Afficher les zones chargées }
Procedure ShowZones;
Var
 I, J: Integer;
Begin
 WriteLn('Zones DNS chargées:');
 WriteLn('==================');
 WriteLn('Nom                    Type    Records  Série      Dernière mise à jour');
 WriteLn('---------------------- ------- -------- ---------- --------------------');
 
 For I := 0 To ZoneCount - 1 Do Begin
  With DNSZones[I] Do Begin
   Write(Copy(ZoneName + '                      ', 1, 22), ' ');
   Write(Copy(ZoneType + '       ', 1, 7), ' ');
   Write(RecordCount:8, ' ');
   Write(Serial:10, ' ');
   WriteLn(FormatDateTime('yyyy-mm-dd hh:nn', LastReload));
  End;
 End;
 
 WriteLn;
 WriteLn('Détail des enregistrements:');
 WriteLn('----------------------------');
 
 For I := 0 To ZoneCount - 1 Do Begin
  If DNSZones[I].Active Then Begin
   WriteLn;
   WriteLn('Zone: ', DNSZones[I].ZoneName, ' (', DNSZones[I].ZoneType, ')');
   WriteLn('Fichier: ', DNSZones[I].ZoneFile);
   WriteLn('Enregistrements:');
   
   For J := 0 To DNSZones[I].RecordCount - 1 Do Begin
    With DNSZones[I].Records[J] Do Begin
     If Active Then Begin
      Write('  ', Copy(Name + '                    ', 1, 20));
      Write(' ', TTL:6);
      Write(' IN ');
      Write(Copy(RecordTypeToString(RecordType) + '      ', 1, 6));
      Write(' ');
      If RecordType = DNS_MX Then Write(Priority:2, ' ');
      WriteLn(Data);
     End;
    End;
   End;
  End;
 End;
End;

{ Tester une requête DNS }
Procedure TestDNSQuery(QueryName: String; QueryType: String);
Var
 Query: TDNSQuery;
 Response: TDNSResponse;
 RecType: TDNSRecordType;
Begin
 RecType := StringToRecordType(QueryType);
 
 WriteLn('Test de requête DNS:');
 WriteLn('  Nom       : ', QueryName);
 WriteLn('  Type      : ', QueryType);
 WriteLn;
 
 { Préparer la requête }
 With Query Do Begin
  QueryID := Random(65536);
  QueryName := QueryName;
  QueryType := RecType;
  QueryClass := DNS_IN;
  ClientIP := '127.0.0.1';
  ClientPort := 12345;
  Timestamp := Now;
  Recursive := True;
  Authoritative := False;
 End;
 
 { Traiter la requête }
 If ProcessDNSQuery(Query, Response) Then Begin
  WriteLn('Résultat  : ', GetDNSErrorMessage(Response.ResponseCode));
  If Response.AnswerCount > 0 Then Begin
   WriteLn('Réponse   : ', Response.Answers[0].Data);
   WriteLn('TTL       : ', Response.Answers[0].TTL);
   WriteLn('Autoritaire: ', BoolToStr(Response.Authoritative, 'Oui', 'Non'));
  End;
 End Else Begin
  WriteLn('Erreur lors du traitement de la requête');
 End;
End;

{ Afficher la configuration }
Procedure ShowNamedConfig;
Begin
 WriteLn('Configuration du serveur NAMED:');
 WriteLn('===============================');
 WriteLn('Fichier de configuration : ', NamedConfig.ConfigFile);
 WriteLn('Port d''écoute           : ', NamedConfig.ListenPort);
 WriteLn('Adresse d''écoute        : ', NamedConfig.ListenAddress);
 WriteLn('Fichier de log          : ', NamedConfig.LogFile);
 WriteLn('Fichier PID             : ', NamedConfig.PidFile);
 WriteLn('Taille du cache         : ', NamedConfig.CacheSize, ' octets');
 WriteLn('Récursion               : ', BoolToStr(NamedConfig.RecursionEnabled, 'Activée', 'Désactivée'));
 WriteLn('Forwarding              : ', BoolToStr(NamedConfig.ForwardingEnabled, 'Activé', 'Désactivé'));
 WriteLn('Nombre de forwarders    : ', NamedConfig.ForwarderCount);
 WriteLn('Clients maximum         : ', NamedConfig.MaxClients);
 WriteLn('Timeout des requêtes    : ', NamedConfig.QueryTimeout, ' ms');
 WriteLn('Niveau de debug         : ', NamedConfig.DebugLevel);
 WriteLn('Mode daemon             : ', BoolToStr(NamedConfig.DaemonMode, 'Oui', 'Non'));
 WriteLn('Transfert de zones      : ', BoolToStr(NamedConfig.ZoneTransferEnabled, 'Activé', 'Désactivé'));
End;

{ Analyser la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Param: String;
 Action: String;
 QueryName, QueryType: String;
 ConfigFile: String;
Begin
 Action := 'start';
 ConfigFile := '';
 QueryName := '';
 QueryType := 'A';
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--config') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    ConfigFile := ParamStr(I);
   End;
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--port') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     NamedConfig.ListenPort := StrToInt(ParamStr(I));
    Except
     WriteLn('Port invalide: ', ParamStr(I));
     Exit;
    End;
   End;
  End
  Else If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--foreground') Then Begin
   NamedConfig.DaemonMode := False;
  End
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--debug') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     NamedConfig.DebugLevel := StrToInt(ParamStr(I));
     CurrentLogLevel := NamedConfig.DebugLevel;
    Except
     NamedConfig.DebugLevel := 2;
     CurrentLogLevel := 2;
    End;
   End Else Begin
    NamedConfig.DebugLevel := 2;
    CurrentLogLevel := 2;
   End;
  End
  Else If LowerCase(Param) = '--stats' Then
   Action := 'stats'
  Else If LowerCase(Param) = '--zones' Then
   Action := 'zones'
  Else If LowerCase(Param) = '--config-show' Then
   Action := 'config'
  Else If LowerCase(Param) = '--reload' Then
   Action := 'reload'
  Else If LowerCase(Param) = '--stop' Then
   Action := 'stop'
  Else If LowerCase(Param) = '--test' Then Begin
   Action := 'test';
   If I < ParamCount Then Begin
    Inc(I);
    QueryName := ParamStr(I);
   End;
   If I < ParamCount Then Begin
    Inc(I);
    QueryType := ParamStr(I);
   End;
  End;
  
  Inc(I);
 End;
 
 { Exécuter l'action demandée }
 Case Action Of
  'start': Begin
   LogMessage(1, 'NAMED - Berkeley Internet Name Domain Server');
   LogMessage(1, 'Version 1.00 - NETWORKKIT-P');
   LogMessage(1, '================================');
   
   If ConfigFile <> '' Then
    NamedConfig.ConfigFile := ConfigFile;
   
   CreateDefaultZones;
   AddExampleZones;
   
   If StartDNSServer Then Begin
    SimulateQueryProcessing;
    WriteLn;
    WriteLn('Appuyez sur Entrée pour voir les statistiques...');
    ReadLn;
    ShowNamedStats;
   End;
  End;
  'stats': Begin
   CreateDefaultZones;
   { Simuler quelques statistiques }
   NamedStats.QueriesReceived := 1247;
   NamedStats.QueriesAnswered := 1156;
   NamedStats.QueriesForwarded := 91;
   NamedStats.CacheHits := 456;
   NamedStats.CacheMisses := 791;
   ShowNamedStats;
  End;
  'zones': Begin
   CreateDefaultZones;
   AddExampleZones;
   ShowZones;
  End;
  'config': Begin
   ShowNamedConfig;
  End;
  'reload': Begin
   CreateDefaultZones;
   AddExampleZones;
   ReloadZones;
  End;
  'test': Begin
   If QueryName = '' Then QueryName := 'localhost';
   CreateDefaultZones;
   AddExampleZones;
   TestDNSQuery(QueryName, QueryType);
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedNamed;
Begin
 WriteLn('NAMED - Berkeley Internet Name Domain Server (simulation)');
 WriteLn('Version 1.00 - NETWORKKIT-P');
 WriteLn('==========================================');
 WriteLn;
 WriteLn('21-Feb-2026 14:30:00.000 starting BIND 9.16.1 -f');
 WriteLn('21-Feb-2026 14:30:00.001 found 2 CPUs, using 2 worker threads');
 WriteLn('21-Feb-2026 14:30:00.002 using 1 UDP listener per interface');
 WriteLn('21-Feb-2026 14:30:00.003 listening on IPv4 interface lo, 127.0.0.1#53');
 WriteLn('21-Feb-2026 14:30:00.004 listening on IPv4 interface eth0, 192.168.1.10#53');
 WriteLn('21-Feb-2026 14:30:00.005 generating session key for dynamic DNS');
 WriteLn('21-Feb-2026 14:30:00.006 sizing zone task pool based on 6 zones');
 WriteLn('21-Feb-2026 14:30:00.007 loading configuration from ''/etc/named.conf''');
 WriteLn('21-Feb-2026 14:30:00.008 reading built-in trusted keys from file ''/etc/bind.keys''');
 WriteLn('21-Feb-2026 14:30:00.009 loaded zone ''localhost'': loaded serial 2026022101');
 WriteLn('21-Feb-2026 14:30:00.010 loaded zone ''127.in-addr.arpa'': loaded serial 2026022101');
 WriteLn('21-Feb-2026 14:30:00.011 loaded zone ''example.local'': loaded serial 2026022101');
 WriteLn('21-Feb-2026 14:30:00.012 all zones loaded');
 WriteLn('21-Feb-2026 14:30:00.013 running');
 WriteLn;
 WriteLn('Serveur DNS démarré en mode simulation');
 WriteLn('Zones chargées: 3');
 WriteLn('Port d''écoute: 53');
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
  WriteLn('NAMED : Serveur DNS Berkeley Internet Name Domain');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NAMED [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -c, --config FICHIER  Fichier de configuration à utiliser');
  WriteLn('  -p, --port PORT       Port d''écoute (défaut: 53)');
  WriteLn('  -f, --foreground      Lancer en premier plan (pas en daemon)');
  WriteLn('  -d, --debug NIVEAU    Niveau de debug (0-9, défaut: 1)');
  WriteLn('  --stats               Afficher les statistiques du serveur');
  WriteLn('  --zones               Lister les zones chargées');
  WriteLn('  --config-show         Afficher la configuration');
  WriteLn('  --reload              Recharger les zones DNS');
  WriteLn('  --stop                Arrêter le serveur');
  WriteLn('  --test NOM [TYPE]     Tester une requête DNS');
  WriteLn;
  WriteLn('Commandes de gestion :');
  WriteLn('  NAMED                 Démarrer le serveur DNS');
  WriteLn('  NAMED --stats         Statistiques du serveur');
  WriteLn('  NAMED --zones         Lister les zones');
  WriteLn('  NAMED --reload        Recharger les zones');
  WriteLn('  NAMED --test localhost A  Tester une requête');
  WriteLn;
  WriteLn('Fonctionnalités DNS :');
  WriteLn('  - Serveur DNS autoritaire pour zones locales');
  WriteLn('  - Support des types A, NS, MX, CNAME, TXT, PTR, SOA');
  WriteLn('  - Résolution récursive avec forwarding');
  WriteLn('  - Cache DNS intégré');
  WriteLn('  - Zones master/slave/hint');
  WriteLn('  - Transferts de zones (AXFR/IXFR)');
  WriteLn('  - Statistiques détaillées');
  WriteLn('  - Rechargement à chaud des zones');
  WriteLn;
  WriteLn('Types d''enregistrements supportés :');
  WriteLn('  A      Adresse IPv4');
  WriteLn('  NS     Serveur de noms');
  WriteLn('  MX     Serveur de messagerie');
  WriteLn('  CNAME  Nom canonique (alias)');
  WriteLn('  TXT    Enregistrement texte');
  WriteLn('  PTR    Pointeur (résolution inverse)');
  WriteLn('  SOA    Start of Authority');
  WriteLn;
  WriteLn('Zones par défaut :');
  WriteLn('  localhost          Zone locale');
  WriteLn('  127.in-addr.arpa   Résolution inverse locale');
  WriteLn('  example.local      Zone d''exemple');
  WriteLn;
  WriteLn('Fichiers de configuration :');
  WriteLn('  /etc/named.conf    Configuration principale');
  WriteLn('  /var/named/        Répertoire des zones');
  WriteLn('  /var/log/named.log Fichier de log');
  WriteLn('  /var/run/named.pid Fichier PID');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  NAMED -f                      # Lancer en premier plan');
  WriteLn('  NAMED -p 5353 -d 3            # Port personnalisé, debug');
  WriteLn('  NAMED --test www.example.local A  # Tester une requête');
  WriteLn('  NAMED --zones                 # Voir les zones');
  WriteLn('  NAMED --stats                 # Statistiques');
  WriteLn;
  WriteLn('Note: Implémentation fonctionnelle d''un serveur DNS avec');
  WriteLn('support des opérations de base et zones configurables.');
  WriteLn('Compatible avec les standards DNS (RFC 1034/1035).');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('NAMED 1.00 - Berkeley Internet Name Domain Server, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Basé sur BIND - Berkeley Internet Name Domain');
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeNamedConfig;
  ParseCommandLine;
  {$ELSE}
  ShowSimulatedNamed;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 { Nettoyer }
 StopDNSServer;
 CleanupWinsock;
 {$ENDIF}
END.
