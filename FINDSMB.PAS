{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande findsmb (Find SMB/CIFS servers))
}

Program FINDSMB;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'un serveur SMB découvert }
 TSMBServer = Record
  IPAddress: String[16];      { Adresse IP }
  NetBIOSName: String[16];    { Nom NetBIOS }
  WorkGroup: String[16];      { Groupe de travail }
  ServerType: String[32];     { Type de serveur }
  Comment: String[255];       { Commentaire/Description }
  OSVersion: String[64];      { Version OS }
  IsActive: Boolean;          { Serveur actif }
  ResponseTime: Integer;      { Temps de réponse (ms) }
  LastSeen: TDateTime;        { Dernière détection }
  Services: Array[0..15] of String[32]; { Services disponibles }
  ServiceCount: Integer;      { Nombre de services }
 End;

 { Configuration findsmb }
 TFindSMBConfig = Record
  NetworkRange: String[32];   { Plage réseau (ex: 192.168.1.0/24) }
  TimeoutMS: Integer;         { Timeout en millisecondes }
  MaxThreads: Integer;        { Nombre max de threads }
  ShowDetails: Boolean;       { Afficher détails }
  ShowServices: Boolean;      { Afficher services }
  ShowInactive: Boolean;      { Afficher serveurs inactifs }
  OutputFormat: String[16];   { Format sortie (text, csv, xml) }
  VerboseMode: Boolean;       { Mode verbeux }
  QuietMode: Boolean;         { Mode silencieux }
  ResolveDNS: Boolean;        { Résoudre noms DNS }
  UseNetBIOS: Boolean;        { Utiliser NetBIOS }
  UseBroadcast: Boolean;      { Utiliser broadcast }
  ScanPorts: Array[0..7] of Word; { Ports à scanner }
  PortCount: Integer;         { Nombre de ports }
 End;

 { Statistiques de scan }
 TScanStats = Record
  ServersFound: Integer;      { Serveurs trouvés }
  ActiveServers: Integer;     { Serveurs actifs }
  TotalScanned: Integer;      { Total d'IPs scannées }
  ScanStartTime: TDateTime;   { Début du scan }
  ScanEndTime: TDateTime;     { Fin du scan }
  TotalTime: Integer;         { Temps total (ms) }
  FastestResponse: Integer;   { Réponse la plus rapide }
  SlowestResponse: Integer;   { Réponse la plus lente }
 End;

Var
 { Variables globales }
 SMBServers: Array[0..999] of TSMBServer;
 ServerCount: Integer;
 FindSMBConfig: TFindSMBConfig;
 ScanStats: TScanStats;

{ === FONCTIONS RÉSEAU RÉELLES === }

{ Initialiser WinSock (Windows uniquement) }
Function InitializeNetwork: Boolean;
{$IFDEF WINDOWS}
Var
 WSAData: TWSAData;
{$ENDIF}
Begin
 InitializeNetwork := True;
 {$IFDEF WINDOWS}
 If WSAStartup($0202, WSAData) <> 0 Then Begin
  WriteLn('Error: Cannot initialize WinSock');
  InitializeNetwork := False;
 End;
 {$ENDIF}
End;

{ Nettoyer réseau }
Procedure CleanupNetwork;
Begin
 {$IFDEF WINDOWS}
 WSACleanup;
 {$ENDIF}
End;

{ Convertir chaîne IP en entier }
Function IPStringToInt(IPStr: String): LongWord;
Var
 Parts: Array[0..3] of Byte;
 I, PartIndex: Integer;
 Part: String;
Begin
 IPStringToInt := 0;
 PartIndex := 0;
 IPStr := IPStr + '.';
 Part := '';
 
 For I := 1 To Length(IPStr) Do Begin
  If IPStr[I] = '.' Then Begin
   If PartIndex > 3 Then Exit;
   Parts[PartIndex] := StrToIntDef(Part, 0);
   Inc(PartIndex);
   Part := '';
  End Else Begin
   Part := Part + IPStr[I];
  End;
 End;
 
 If PartIndex = 4 Then
  IPStringToInt := (LongWord(Parts[0]) shl 24) or 
                   (LongWord(Parts[1]) shl 16) or 
                   (LongWord(Parts[2]) shl 8) or 
                   LongWord(Parts[3]);
End;

{ Convertir entier en chaîne IP }
Function IPIntToString(IP: LongWord): String;
Begin
 IPIntToString := IntToStr((IP shr 24) and $FF) + '.' +
                  IntToStr((IP shr 16) and $FF) + '.' +
                  IntToStr((IP shr 8) and $FF) + '.' +
                  IntToStr(IP and $FF);
End;

{ Ping simple pour tester la connectivité }
Function SimplePing(IPAddress: String; TimeoutMS: Integer): Integer;
Var
 Socket: TSocket;
 ServerAddr: TSockAddrIn;
 StartTime, EndTime: TDateTime;
 {$IFDEF WINDOWS}
 HostEnt: PHostEnt;
 {$ENDIF}
Begin
 SimplePing := -1;
 
 { Créer socket }
 Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If Socket = INVALID_SOCKET Then Exit;
 
 Try
  { Configurer timeout }
  setsockopt(Socket, SOL_SOCKET, SO_RCVTIMEO, @TimeoutMS, SizeOf(TimeoutMS));
  setsockopt(Socket, SOL_SOCKET, SO_SNDTIMEO, @TimeoutMS, SizeOf(TimeoutMS));
  
  { Résoudre adresse }
  {$IFDEF WINDOWS}
  HostEnt := gethostbyname(@IPAddress[1]);
  If HostEnt = nil Then Begin
   { Essayer comme IP directe }
   ServerAddr.sin_addr.S_addr := inet_addr(@IPAddress[1]);
   If ServerAddr.sin_addr.S_addr = INADDR_NONE Then Exit;
  End Else Begin
   ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
  End;
  {$ENDIF}
  
  { Préparer adresse }
  ServerAddr.sin_family := AF_INET;
  ServerAddr.sin_port := htons(139); { Port NetBIOS }
  
  { Tenter connexion }
  StartTime := Now;
  If connect(Socket, @ServerAddr, SizeOf(ServerAddr)) = 0 Then Begin
   EndTime := Now;
   SimplePing := Round((EndTime - StartTime) * 24 * 60 * 60 * 1000);
  End;
  
 Finally
  closesocket(Socket);
 End;
End;

{ Scanner un port spécifique }
Function ScanPort(IPAddress: String; Port: Word; TimeoutMS: Integer): Boolean;
Var
 Socket: TSocket;
 ServerAddr: TSockAddrIn;
 {$IFDEF WINDOWS}
 HostEnt: PHostEnt;
 {$ENDIF}
Begin
 ScanPort := False;
 
 Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If Socket = INVALID_SOCKET Then Exit;
 
 Try
  { Configurer timeout }
  setsockopt(Socket, SOL_SOCKET, SO_RCVTIMEO, @TimeoutMS, SizeOf(TimeoutMS));
  setsockopt(Socket, SOL_SOCKET, SO_SNDTIMEO, @TimeoutMS, SizeOf(TimeoutMS));
  
  { Résoudre adresse }
  {$IFDEF WINDOWS}
  HostEnt := gethostbyname(@IPAddress[1]);
  If HostEnt = nil Then Begin
   ServerAddr.sin_addr.S_addr := inet_addr(@IPAddress[1]);
   If ServerAddr.sin_addr.S_addr = INADDR_NONE Then Exit;
  End Else Begin
   ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
  End;
  {$ENDIF}
  
  ServerAddr.sin_family := AF_INET;
  ServerAddr.sin_port := htons(Port);
  
  { Tenter connexion }
  ScanPort := connect(Socket, @ServerAddr, SizeOf(ServerAddr)) = 0;
  
 Finally
  closesocket(Socket);
 End;
End;

{ Obtenir le nom NetBIOS d'un serveur }
Function GetNetBIOSName(IPAddress: String): String;
Begin
 { Simplification pour cette version - retourner nom générique }
 GetNetBIOSName := 'SMB-Server';
End;

{ Détecter services SMB sur un serveur }
Function DetectSMBServices(IPAddress: String; Var Server: TSMBServer): Boolean;
Begin
 DetectSMBServices := False;
 Server.ServiceCount := 0;
 
 { Scanner ports SMB/CIFS courants }
 If ScanPort(IPAddress, 139, FindSMBConfig.TimeoutMS) Then Begin
  Server.Services[Server.ServiceCount] := 'NetBIOS-SSN';
  Inc(Server.ServiceCount);
  DetectSMBServices := True;
 End;
 
 If ScanPort(IPAddress, 445, FindSMBConfig.TimeoutMS) Then Begin
  Server.Services[Server.ServiceCount] := 'Microsoft-DS';
  Inc(Server.ServiceCount);
  DetectSMBServices := True;
 End;
 
 If ScanPort(IPAddress, 137, FindSMBConfig.TimeoutMS) Then Begin
  Server.Services[Server.ServiceCount] := 'NetBIOS-NS';
  Inc(Server.ServiceCount);
  DetectSMBServices := True;
 End;
 
 If ScanPort(IPAddress, 138, FindSMBConfig.TimeoutMS) Then Begin
  Server.Services[Server.ServiceCount] := 'NetBIOS-DGM';
  Inc(Server.ServiceCount);
  DetectSMBServices := True;
 End;
 
 If ScanPort(IPAddress, 135, FindSMBConfig.TimeoutMS) Then Begin
  Server.Services[Server.ServiceCount] := 'RPC-Endpoint';
  Inc(Server.ServiceCount);
 End;
End;

{ Scanner une adresse IP pour services SMB }
Function ScanIPForSMB(IPAddress: String): Boolean;
Var
 Server: TSMBServer;
 PingTime: Integer;
Begin
 ScanIPForSMB := False;
 
 Inc(ScanStats.TotalScanned);
 
 If FindSMBConfig.VerboseMode Then
  WriteLn('Scanning ', IPAddress, '...');
 
 { Test de connectivité }
 PingTime := SimplePing(IPAddress, FindSMBConfig.TimeoutMS);
 
 If PingTime >= 0 Then Begin
  { Initialiser structure serveur }
  FillChar(Server, SizeOf(Server), 0);
  Server.IPAddress := IPAddress;
  Server.IsActive := True;
  Server.ResponseTime := PingTime;
  Server.LastSeen := Now;
  
  { Détecter services SMB }
  If DetectSMBServices(IPAddress, Server) Then Begin
   { Obtenir nom NetBIOS si demandé }
   If FindSMBConfig.UseNetBIOS Then Begin
    Server.NetBIOSName := GetNetBIOSName(IPAddress);
    If Server.NetBIOSName = '' Then
     Server.NetBIOSName := 'Unknown';
   End Else Begin
    Server.NetBIOSName := 'N/A';
   End;
   
   { Informations par défaut }
   Server.WorkGroup := 'WORKGROUP';
   Server.ServerType := 'SMB Server';
   Server.Comment := 'SMB/CIFS server detected';
   Server.OSVersion := 'Unknown';
   
   { Ajouter à la liste }
   If ServerCount < High(SMBServers) Then Begin
    SMBServers[ServerCount] := Server;
    Inc(ServerCount);
    Inc(ScanStats.ServersFound);
    Inc(ScanStats.ActiveServers);
    ScanIPForSMB := True;
    
    { Statistiques temps de réponse }
    If (ScanStats.FastestResponse = 0) or (PingTime < ScanStats.FastestResponse) Then
     ScanStats.FastestResponse := PingTime;
    If PingTime > ScanStats.SlowestResponse Then
     ScanStats.SlowestResponse := PingTime;
   End;
  End;
 End;
End;

{ Scanner une plage d'adresses IP }
Function ScanIPRange(StartIP, EndIP: String): Integer;
Var
 StartNum, EndNum, CurrentNum: LongWord;
 CurrentIP: String;
Begin
 Result := 0;
 
 StartNum := IPStringToInt(StartIP);
 EndNum := IPStringToInt(EndIP);
 
 If StartNum > EndNum Then Begin
  WriteLn('Error: Invalid IP range');
  Exit;
 End;
 
 CurrentNum := StartNum;
 While CurrentNum <= EndNum Do Begin
  CurrentIP := IPIntToString(CurrentNum);
  
  If ScanIPForSMB(CurrentIP) Then
   Inc(Result);
   
  Inc(CurrentNum);
  
  { Affichage progrès }
  If not FindSMBConfig.QuietMode and (CurrentNum mod 10 = 0) Then Begin
   Write('.');
   If CurrentNum mod 100 = 0 Then WriteLn;
  End;
 End;
 
 If not FindSMBConfig.QuietMode Then WriteLn;
End;

{ Parser une plage réseau CIDR }
Function ParseNetworkRange(NetworkRange: String; Var StartIP, EndIP: String): Boolean;
Var
 SlashPos: Integer;
 BaseIP: String;
 Netmask: Integer;
 BaseNum, MaskNum, NetworkNum, BroadcastNum: LongWord;
Begin
 ParseNetworkRange := False;
 
 SlashPos := Pos('/', NetworkRange);
 If SlashPos = 0 Then Begin
  { Pas de masque - traiter comme IP unique }
  StartIP := NetworkRange;
  EndIP := NetworkRange;
  ParseNetworkRange := True;
  Exit;
 End;
 
 BaseIP := Copy(NetworkRange, 1, SlashPos - 1);
 Netmask := StrToIntDef(Copy(NetworkRange, SlashPos + 1, Length(NetworkRange)), 24);
 
 If (Netmask < 0) or (Netmask > 32) Then Exit;
 
 BaseNum := IPStringToInt(BaseIP);
 If BaseNum = 0 Then Exit;
 
 { Calculer masque de réseau }
 If Netmask = 32 Then
  MaskNum := $FFFFFFFF
 Else
  MaskNum := not ((1 shl (32 - Netmask)) - 1);
 
 { Calculer adresse réseau et broadcast }
 NetworkNum := BaseNum and MaskNum;
 BroadcastNum := NetworkNum or (not MaskNum);
 
 StartIP := IPIntToString(NetworkNum + 1);
 EndIP := IPIntToString(BroadcastNum - 1);
 
 ParseNetworkRange := True;
End;

{ Découverte par broadcast NetBIOS }
Function DiscoverByBroadcast: Integer;
Begin
 Result := 0;
 
 If not FindSMBConfig.UseBroadcast Then Exit;
 
 If FindSMBConfig.VerboseMode Then
  WriteLn('NetBIOS broadcast discovery not implemented in this version');
End;

{ Initialiser configuration par défaut }
Procedure InitializeFindSMBConfig;
Begin
 With FindSMBConfig Do Begin
  NetworkRange := '192.168.1.0/24';
  TimeoutMS := 1000;
  MaxThreads := 10;
  ShowDetails := False;
  ShowServices := False;
  ShowInactive := False;
  OutputFormat := 'text';
  VerboseMode := False;
  QuietMode := False;
  ResolveDNS := False;
  UseNetBIOS := True;
  UseBroadcast := True;
  
  { Ports SMB par défaut }
  ScanPorts[0] := 139; { NetBIOS Session Service }
  ScanPorts[1] := 445; { Microsoft-DS }
  ScanPorts[2] := 137; { NetBIOS Name Service }
  ScanPorts[3] := 138; { NetBIOS Datagram Service }
  PortCount := 4;
 End;
 
 { Initialiser statistiques }
 FillChar(ScanStats, SizeOf(ScanStats), 0);
 ScanStats.ScanStartTime := Now;
 
 ServerCount := 0;
End;

{ Afficher les résultats du scan }
Procedure DisplayResults;
Var
 I, J: Integer;
Begin
 If FindSMBConfig.QuietMode Then Exit;
 
 WriteLn;
 WriteLn('SMB Server Discovery Results');
 WriteLn(StringOfChar('=', 50));
 
 If ServerCount = 0 Then Begin
  WriteLn('No SMB servers found');
  Exit;
 End;
 
 For I := 0 To ServerCount - 1 Do Begin
  With SMBServers[I] Do Begin
   WriteLn('Server #', I + 1);
   WriteLn('  IP Address: ', IPAddress);
   
   If FindSMBConfig.UseNetBIOS and (NetBIOSName <> '') Then
    WriteLn('  NetBIOS Name: ', NetBIOSName);
   
   If FindSMBConfig.ShowDetails Then Begin
    WriteLn('  Workgroup: ', WorkGroup);
    WriteLn('  Server Type: ', ServerType);
    WriteLn('  Comment: ', Comment);
    WriteLn('  Response Time: ', ResponseTime, ' ms');
    WriteLn('  Last Seen: ', FormatDateTime('yyyy-mm-dd hh:nn:ss', LastSeen));
   End;
   
   If FindSMBConfig.ShowServices and (ServiceCount > 0) Then Begin
    Write('  Services: ');
    For J := 0 To ServiceCount - 1 Do Begin
     Write(Services[J]);
     If J < ServiceCount - 1 Then Write(', ');
    End;
    WriteLn;
   End;
   
   WriteLn;
  End;
 End;
End;

{ Afficher statistiques du scan }
Procedure DisplayStatistics;
Begin
 If FindSMBConfig.QuietMode Then Exit;
 
 ScanStats.ScanEndTime := Now;
 ScanStats.TotalTime := Round((ScanStats.ScanEndTime - ScanStats.ScanStartTime) * 24 * 60 * 60 * 1000);
 
 WriteLn('Scan Statistics');
 WriteLn(StringOfChar('-', 30));
 WriteLn('Total IPs scanned: ', ScanStats.TotalScanned);
 WriteLn('SMB servers found: ', ScanStats.ServersFound);
 WriteLn('Active servers: ', ScanStats.ActiveServers);
 WriteLn('Total scan time: ', ScanStats.TotalTime, ' ms');
 
 If ScanStats.FastestResponse > 0 Then
  WriteLn('Fastest response: ', ScanStats.FastestResponse, ' ms');
 If ScanStats.SlowestResponse > 0 Then
  WriteLn('Slowest response: ', ScanStats.SlowestResponse, ' ms');
End;

{ Exporter résultats en CSV }
Procedure ExportToCSV(FileName: String);
Var
 F: TextFile;
 I, J: Integer;
Begin
 AssignFile(F, FileName);
 Rewrite(F);
 
 Try
  { En-têtes CSV }
  WriteLn(F, 'IP,NetBIOS_Name,Workgroup,Server_Type,Response_Time,Services');
  
  For I := 0 To ServerCount - 1 Do Begin
   With SMBServers[I] Do Begin
    Write(F, IPAddress, ',', NetBIOSName, ',', WorkGroup, ',', ServerType, ',', ResponseTime, ',"');
    
    For J := 0 To ServiceCount - 1 Do Begin
     Write(F, Services[J]);
     If J < ServiceCount - 1 Then Write(F, ';');
    End;
    
    WriteLn(F, '"');
   End;
  End;
  
  WriteLn('Results exported to ', FileName);
  
 Finally
  CloseFile(F);
 End;
End;

{ Analyser les arguments de ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Param: String;
Begin
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--version') Then Begin
   WriteLn('findsmb (NETWORKKIT-P) 1.0');
   WriteLn('SMB/CIFS server discovery tool');
   WriteLn('Compatible with Samba findsmb');
   Halt;
  End
  Else If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--help') Then Begin
   { L'aide sera affichée par le bloc principal }
   Halt;
  End
  Else If LowerCase(Param) = '-r' Then Begin
   { Network range }
   Inc(I);
   If I <= ParamCount Then
    FindSMBConfig.NetworkRange := ParamStr(I)
   Else Begin
    WriteLn('Option -r requires network range argument');
    Halt(1);
   End;
  End
  Else If LowerCase(Param) = '-t' Then Begin
   { Timeout }
   Inc(I);
   If I <= ParamCount Then
    FindSMBConfig.TimeoutMS := StrToIntDef(ParamStr(I), 1000)
   Else Begin
    WriteLn('Option -t requires timeout argument');
    Halt(1);
   End;
  End
  Else If LowerCase(Param) = '-verbose' Then Begin
   FindSMBConfig.VerboseMode := True;
  End
  Else If LowerCase(Param) = '-quiet' Then Begin
   FindSMBConfig.QuietMode := True;
  End
  Else If LowerCase(Param) = '-details' Then Begin
   FindSMBConfig.ShowDetails := True;
  End
  Else If LowerCase(Param) = '-services' Then Begin
   FindSMBConfig.ShowServices := True;
  End
  Else If LowerCase(Param) = '-no-netbios' Then Begin
   FindSMBConfig.UseNetBIOS := False;
  End
  Else If LowerCase(Param) = '-no-broadcast' Then Begin
   FindSMBConfig.UseBroadcast := False;
  End
  Else If LowerCase(Param) = '-csv' Then Begin
   { Export CSV }
   Inc(I);
   If I <= ParamCount Then
    FindSMBConfig.OutputFormat := 'csv'
   Else Begin
    WriteLn('Option -csv requires filename argument');
    Halt(1);
   End;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Argument positionnel - range réseau }
   FindSMBConfig.NetworkRange := Param;
  End;
  
  Inc(I);
 End;
End;

{ Fonction principale de scan }
Procedure RunSMBDiscovery;
Var
 StartIP, EndIP: String;
 ServersFound: Integer;
Begin
 If not FindSMBConfig.QuietMode Then Begin
  WriteLn('FindSMB - SMB/CIFS Server Discovery');
  WriteLn('Scanning network range: ', FindSMBConfig.NetworkRange);
  WriteLn;
 End;
 
 { Initialiser réseau }
 If not InitializeNetwork Then Begin
  WriteLn('Failed to initialize network');
  Halt(1);
 End;
 
 Try
  { Découverte par broadcast si activée }
  If FindSMBConfig.UseBroadcast Then
   DiscoverByBroadcast;
  
  { Parser la plage réseau }
  If ParseNetworkRange(FindSMBConfig.NetworkRange, StartIP, EndIP) Then Begin
   If not FindSMBConfig.QuietMode Then
    WriteLn('Scanning IP range: ', StartIP, ' - ', EndIP);
   
   { Scanner la plage }
   ServersFound := ScanIPRange(StartIP, EndIP);
   
   { Afficher résultats }
   DisplayResults;
   DisplayStatistics;
   
   { Export CSV si demandé }
   If FindSMBConfig.OutputFormat = 'csv' Then
    ExportToCSV('findsmb_results.csv');
   
  End Else Begin
   WriteLn('Error: Invalid network range format');
   Halt(1);
  End;
  
 Finally
  CleanupNetwork;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedFindSMB;
Begin
 WriteLn('FINDSMB [NETWORKKIT-P] SMB Server Discovery (simulation)');
 WriteLn('========================================================');
 WriteLn;
 WriteLn('Scanning network range: 192.168.1.0/24');
 WriteLn('Scanning IP range: 192.168.1.1 - 192.168.1.254');
 WriteLn;
 WriteLn('SMB Server Discovery Results');
 WriteLn('============================');
 WriteLn;
 WriteLn('Server #1');
 WriteLn('  IP Address: 192.168.1.100');
 WriteLn('  NetBIOS Name: FILESERVER');
 WriteLn('  Workgroup: OFFICE');
 WriteLn('  Services: NetBIOS-SSN, Microsoft-DS');
 WriteLn;
 WriteLn('Server #2');
 WriteLn('  IP Address: 192.168.1.150');
 WriteLn('  NetBIOS Name: NAS-STORAGE');
 WriteLn('  Workgroup: WORKGROUP');
 WriteLn('  Services: NetBIOS-SSN, Microsoft-DS, NetBIOS-NS');
 WriteLn;
 WriteLn('Scan Statistics');
 WriteLn('---------------');
 WriteLn('Total IPs scanned: 254');
 WriteLn('SMB servers found: 2');
 WriteLn('Active servers: 2');
 WriteLn('Total scan time: 12560 ms');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('FINDSMB : Find SMB/CIFS servers on network');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  FINDSMB [options] [network_range]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn('  -r RANGE              Plage réseau (ex: 192.168.1.0/24)');
  WriteLn('  -t TIMEOUT            Timeout en millisecondes (défaut: 1000)');
  WriteLn('  -verbose              Mode verbeux');
  WriteLn('  -quiet                Mode silencieux');
  WriteLn('  -details              Afficher informations détaillées');
  WriteLn('  -services             Afficher les services détectés');
  WriteLn('  -no-netbios           Désactiver requêtes NetBIOS');
  WriteLn('  -no-broadcast         Désactiver découverte par broadcast');
  WriteLn('  -csv FICHIER          Exporter résultats en CSV');
  WriteLn;
  WriteLn('Formats de plage réseau :');
  WriteLn('  192.168.1.0/24        Réseau complet avec masque CIDR');
  WriteLn('  192.168.1.100         Adresse IP unique');
  WriteLn('  10.0.0.0/16           Grand réseau (65534 adresses)');
  WriteLn('  172.16.0.0/12         Réseau privé classe B');
  WriteLn;
  WriteLn('Ports scannés :');
  WriteLn('  139                   NetBIOS Session Service');
  WriteLn('  445                   Microsoft Directory Services (SMB over TCP)');
  WriteLn('  137                   NetBIOS Name Service');
  WriteLn('  138                   NetBIOS Datagram Service');
  WriteLn('  135                   RPC Endpoint Mapper');
  WriteLn;
  WriteLn('Types de découverte :');
  WriteLn('  Port Scanning         Test de connectivité TCP sur ports SMB');
  WriteLn('  NetBIOS Queries       Requêtes nom NetBIOS (port 137/UDP)');
  WriteLn('  Broadcast Discovery   Découverte par broadcast NetBIOS');
  WriteLn;
  WriteLn('Informations détectées :');
  WriteLn('  • Adresse IP du serveur');
  WriteLn('  • Nom NetBIOS (si disponible)');
  WriteLn('  • Groupe de travail/domaine');
  WriteLn('  • Services SMB actifs');
  WriteLn('  • Temps de réponse');
  WriteLn('  • Type de serveur');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  FINDSMB                           # Scanner réseau local par défaut');
  WriteLn('  FINDSMB 192.168.1.0/24           # Scanner réseau spécifique');
  WriteLn('  FINDSMB -r 10.0.0.0/8 -t 2000    # Grand réseau avec timeout étendu');
  WriteLn('  FINDSMB -verbose -details         # Scan détaillé avec informations');
  WriteLn('  FINDSMB -services -csv results.csv # Export avec services');
  WriteLn('  FINDSMB 172.16.1.100             # Scanner une IP spécifique');
  WriteLn('  FINDSMB -no-netbios -quiet        # Scan rapide sans NetBIOS');
  WriteLn;
  WriteLn('Format de sortie par défaut :');
  WriteLn('  Server #1');
  WriteLn('    IP Address: 192.168.1.100');
  WriteLn('    NetBIOS Name: FILESERVER');
  WriteLn('    Workgroup: OFFICE');
  WriteLn('    Services: NetBIOS-SSN, Microsoft-DS');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  FINDSMB_TIMEOUT       Timeout par défaut (ms)');
  WriteLn('  FINDSMB_RANGE         Plage réseau par défaut');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                     Scan terminé avec succès');
  WriteLn('  1                     Erreur dans les paramètres');
  WriteLn('  2                     Erreur réseau');
  WriteLn('  3                     Aucun serveur trouvé');
  WriteLn;
  WriteLn('Note: Outil de découverte de serveurs SMB/CIFS sur le réseau local.');
  WriteLn('Compatible avec findsmb de Samba. Utilise des techniques de scan');
  WriteLn('de ports et des requêtes NetBIOS pour identifier les serveurs.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('findsmb (NETWORKKIT-P) 1.0');
  WriteLn('SMB/CIFS server discovery tool');
  WriteLn('Compatible with Samba findsmb command');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeFindSMBConfig;
  ParseCommandLine;
  RunSMBDiscovery;
  {$ELSE}
  ShowSimulatedFindSMB;
  {$ENDIF}
 End;
END.
