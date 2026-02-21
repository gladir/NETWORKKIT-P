{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande iftop (Network bandwidth monitor))
}

Program IFTOP;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows, Crt;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB, Crt;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'une connexion réseau }
 TNetworkConnection = Record
  LocalIP: String[16];        { Adresse IP locale }
  LocalPort: Word;            { Port local }
  RemoteIP: String[16];       { Adresse IP distante }
  RemotePort: Word;           { Port distant }
  Protocol: String[8];        { Protocole (TCP/UDP) }
  State: String[16];          { État de la connexion }
  ProcessID: LongWord;        { ID du processus }
  ProcessName: String[64];    { Nom du processus }
  BytesSent: Int64;           { Octets envoyés }
  BytesReceived: Int64;       { Octets reçus }
  PacketsSent: LongWord;      { Paquets envoyés }
  PacketsReceived: LongWord;  { Paquets reçus }
  LastUpdate: TDateTime;      { Dernière mise à jour }
  Direction: String[8];       { Direction (In/Out/Both) }
  IsActive: Boolean;          { Connexion active }
 End;

 { Statistiques interface réseau }
 TNetworkInterface = Record
  Name: String[32];           { Nom de l'interface }
  Description: String[128];   { Description }
  MACAddress: String[18];     { Adresse MAC }
  IPAddress: String[16];      { Adresse IP }
  SubnetMask: String[16];     { Masque de sous-réseau }
  Gateway: String[16];        { Passerelle }
  MTU: Word;                  { Maximum Transmission Unit }
  Speed: Int64;               { Vitesse en bits/sec }
  BytesSent: Int64;           { Total octets envoyés }
  BytesReceived: Int64;       { Total octets reçus }
  PacketsSent: LongWord;      { Total paquets envoyés }
  PacketsReceived: LongWord;  { Total paquets reçus }
  ErrorsIn: LongWord;         { Erreurs en entrée }
  ErrorsOut: LongWord;        { Erreurs en sortie }
  DropsIn: LongWord;          { Paquets supprimés en entrée }
  DropsOut: LongWord;         { Paquets supprimés en sortie }
  IsUp: Boolean;              { Interface active }
  IsLoopback: Boolean;        { Interface de bouclage }
 End;

 { Configuration iftop }
 TIftopConfig = Record
  NetworkInterface: String[32];    { Interface à surveiller }
  PromiscuousMode: Boolean;   { Mode promiscuité }
  ResolveHosts: Boolean;      { Résoudre noms d'hôtes }
  ResolveServices: Boolean;   { Résoudre noms de services }
  ShowPorts: Boolean;         { Afficher numéros de ports }
  ShowDirection: Boolean;     { Afficher direction du trafic }
  ShowSingleHost: Boolean;    { Afficher un seul hôte }
  Filter: String[255];        { Filtre de trafic }
  SortBy: String[16];         { Critère de tri }
  RefreshInterval: Integer;   { Intervalle de rafraîchissement (ms) }
  MaxConnections: Integer;    { Nombre max de connexions }
  MaxLines: Integer;          { Nombre max de lignes }
  LogFile: String[255];       { Fichier de log }
  Verbose: Boolean;           { Mode verbeux }
  Quiet: Boolean;             { Mode silencieux }
  NoBarGraph: Boolean;        { Pas de graphique en barres }
  LinearScale: Boolean;       { Échelle linéaire }
  LogScale: Boolean;          { Échelle logarithmique }
  FixedScale: Boolean;        { Échelle fixe }
  MaxBandwidth: Int64;        { Bande passante maximale }
 End;

 { Historique de bande passante }
 TBandwidthHistory = Record
  Timestamp: TDateTime;       { Horodatage }
  BytesIn: Int64;             { Octets entrants }
  BytesOut: Int64;            { Octets sortants }
  PacketsIn: LongWord;        { Paquets entrants }
  PacketsOut: LongWord;       { Paquets sortants }
  ConnectionCount: Integer;   { Nombre de connexions }
 End;

 { Statistiques de bande passante }
 TBandwidthStats = Record
  Current2s: Int64;           { Moyenne 2 secondes }
  Current10s: Int64;          { Moyenne 10 secondes }
  Current40s: Int64;          { Moyenne 40 secondes }
  Peak: Int64;                { Pic de trafic }
  Cumulative: Int64;          { Trafic cumulé }
  LastUpdate: TDateTime;      { Dernière mise à jour }
 End;

Var
 { Variables globales }
 IftopConfig: TIftopConfig;
 NetworkInterface: TNetworkInterface;
 Connections: Array[0..999] of TNetworkConnection;
 ConnectionCount: Integer;
 BandwidthHistory: Array[0..199] of TBandwidthHistory;
 HistoryCount: Integer;
 HistoryIndex: Integer;
 InStats, OutStats, TotalStats: TBandwidthStats;
 StartTime: TDateTime;
 DisplayLine: Integer;
 ExitRequested: Boolean;
 PauseDisplay: Boolean;

{ === FONCTIONS UTILITAIRES === }

{ Obtenir variable d'environnement (compatible) }
Function GetEnvVar(VarName: String): String;
{$IFDEF WINDOWS}
Var
 Buffer: Array[0..255] of Char;
 Len: DWord;
{$ENDIF}
Begin
 Result := '';
 {$IFDEF WINDOWS}
 Len := GetEnvironmentVariable(@VarName[1], Buffer, SizeOf(Buffer));
 If Len > 0 Then
  Result := StrPas(Buffer);
 {$ELSE}
 Result := GetEnvironmentVariable(VarName);
 {$ENDIF}
End;

{ Convertir octets en chaîne lisible }
Function FormatBytes(Bytes: Int64): String;
Begin
 If Bytes < 1024 Then
  Result := IntToStr(Bytes) + 'B'
 Else If Bytes < 1024 * 1024 Then
  Result := FormatFloat('0.0', Bytes / 1024) + 'KB'
 Else If Bytes < 1024 * 1024 * 1024 Then
  Result := FormatFloat('0.0', Bytes / (1024 * 1024)) + 'MB'
 Else
  Result := FormatFloat('0.0', Bytes / (1024 * 1024 * 1024)) + 'GB';
End;

{ Convertir bits/sec en chaîne lisible }
Function FormatBandwidth(BitsPerSec: Int64): String;
Begin
 If BitsPerSec < 1024 Then
  Result := IntToStr(BitsPerSec) + 'b'
 Else If BitsPerSec < 1024 * 1024 Then
  Result := FormatFloat('0.0', BitsPerSec / 1024) + 'Kb'
 Else If BitsPerSec < 1024 * 1024 * 1024 Then
  Result := FormatFloat('0.0', BitsPerSec / (1024 * 1024)) + 'Mb'
 Else
  Result := FormatFloat('0.0', BitsPerSec / (1024 * 1024 * 1024)) + 'Gb';
End;

{ Résoudre nom d'hôte depuis IP }
Function ResolveHostname(IPAddress: String): String;
{$IFDEF WINDOWS}
Var
 Addr: LongWord;
 HostEnt: PHostEnt;
{$ENDIF}
Begin
 Result := IPAddress;
 
 If not IftopConfig.ResolveHosts Then Exit;
 
 {$IFDEF WINDOWS}
 Addr := inet_addr(@IPAddress[1]);
 If Addr <> INADDR_NONE Then Begin
  HostEnt := gethostbyaddr(@Addr, SizeOf(Addr), AF_INET);
  If HostEnt <> nil Then
   Result := StrPas(HostEnt^.h_name);
 End;
 {$ENDIF}
End;

{ Résoudre nom de service depuis port }
Function ResolveServiceName(Port: Word; Protocol: String): String;
{$IFDEF WINDOWS}
Var
 ServEnt: PServEnt;
{$ENDIF}
Begin
 Result := IntToStr(Port);
 
 If not IftopConfig.ResolveServices Then Exit;
 
 {$IFDEF WINDOWS}
 ServEnt := getservbyport(htons(Port), @Protocol[1]);
 If ServEnt <> nil Then
  Result := StrPas(ServEnt^.s_name);
 {$ENDIF}
End;

{ === FONCTIONS DE SURVEILLANCE RÉSEAU === }

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

{ Obtenir les interfaces réseau }
Function GetNetworkInterfaces: Integer;
Begin
 Result := 1;
 
 { Pour cette démonstration, simuler une interface }
 With NetworkInterface Do Begin
  Name := 'eth0';
  Description := 'Ethernet Adapter';
  MACAddress := '00:1B:44:11:3A:B7';
  IPAddress := '192.168.1.100';
  SubnetMask := '255.255.255.0';
  Gateway := '192.168.1.1';
  MTU := 1500;
  Speed := 100000000; { 100 Mbps }
  BytesSent := 0;
  BytesReceived := 0;
  PacketsSent := 0;
  PacketsReceived := 0;
  ErrorsIn := 0;
  ErrorsOut := 0;
  DropsIn := 0;
  DropsOut := 0;
  IsUp := True;
  IsLoopback := False;
 End;
End;

{ Obtenir les connexions réseau actives }
Function GetActiveConnections: Integer;
Var
 I: Integer;
 BasePort: Word;
Begin
 ConnectionCount := 0;
 
 { Simuler quelques connexions pour la démonstration }
 BasePort := 49152;
 
 For I := 0 To 4 Do Begin
  With Connections[ConnectionCount] Do Begin
   LocalIP := NetworkInterface.IPAddress;
   LocalPort := BasePort + I;
   
   Case I Of
    0: Begin
     RemoteIP := '74.125.224.72'; { Google }
     RemotePort := 443;
     Protocol := 'TCP';
     State := 'ESTABLISHED';
     ProcessName := 'chrome.exe';
     BytesSent := Random(100000) + 50000;
     BytesReceived := Random(200000) + 100000;
    End;
    
    1: Begin
     RemoteIP := '151.101.193.140'; { Reddit }
     RemotePort := 80;
     Protocol := 'TCP';
     State := 'ESTABLISHED';
     ProcessName := 'firefox.exe';
     BytesSent := Random(50000) + 20000;
     BytesReceived := Random(150000) + 80000;
    End;
    
    2: Begin
     RemoteIP := '157.240.12.35'; { Facebook }
     RemotePort := 443;
     Protocol := 'TCP';
     State := 'ESTABLISHED';
     ProcessName := 'chrome.exe';
     BytesSent := Random(30000) + 10000;
     BytesReceived := Random(80000) + 40000;
    End;
    
    3: Begin
     RemoteIP := '8.8.8.8'; { Google DNS }
     RemotePort := 53;
     Protocol := 'UDP';
     State := 'OPEN';
     ProcessName := 'system';
     BytesSent := Random(1000) + 500;
     BytesReceived := Random(2000) + 1000;
    End;
    
    4: Begin
     RemoteIP := '192.168.1.1'; { Gateway local }
     RemotePort := 22;
     Protocol := 'TCP';
     State := 'ESTABLISHED';
     ProcessName := 'ssh.exe';
     BytesSent := Random(10000) + 5000;
     BytesReceived := Random(15000) + 8000;
    End;
   End;
   
   ProcessID := 1000 + I;
   PacketsSent := BytesSent div 1024;
   PacketsReceived := BytesReceived div 1024;
   LastUpdate := Now;
   
   If BytesSent > BytesReceived Then
    Direction := 'OUT'
   Else If BytesReceived > BytesSent Then
    Direction := 'IN'
   Else
    Direction := 'BOTH';
   
   IsActive := True;
  End;
  
  Inc(ConnectionCount);
 End;
 
 Result := ConnectionCount;
End;

{ Mettre à jour les statistiques de bande passante }
Procedure UpdateBandwidthStats;
Var
 I: Integer;
 TotalIn, TotalOut: Int64;
 CurrentTime: TDateTime;
Begin
 CurrentTime := Now;
 TotalIn := 0;
 TotalOut := 0;
 
 { Calculer le trafic total }
 For I := 0 To ConnectionCount - 1 Do Begin
  With Connections[I] Do Begin
   If IsActive Then Begin
    TotalIn := TotalIn + BytesReceived;
    TotalOut := TotalOut + BytesSent;
   End;
  End;
 End;
 
 { Ajouter à l'historique }
 If HistoryCount < High(BandwidthHistory) Then
  Inc(HistoryCount);
 
 HistoryIndex := (HistoryIndex + 1) mod Length(BandwidthHistory);
 
 With BandwidthHistory[HistoryIndex] Do Begin
  Timestamp := CurrentTime;
  BytesIn := TotalIn;
  BytesOut := TotalOut;
  PacketsIn := 0;
  PacketsOut := 0;
  ConnectionCount := ConnectionCount;
 End;
 
 { Calculer les moyennes }
 InStats.Current2s := TotalIn * 8; { Convertir en bits }
 InStats.Current10s := TotalIn * 8;
 InStats.Current40s := TotalIn * 8;
 InStats.Cumulative := TotalIn;
 InStats.LastUpdate := CurrentTime;
 
 OutStats.Current2s := TotalOut * 8;
 OutStats.Current10s := TotalOut * 8;
 OutStats.Current40s := TotalOut * 8;
 OutStats.Cumulative := TotalOut;
 OutStats.LastUpdate := CurrentTime;
 
 TotalStats.Current2s := (TotalIn + TotalOut) * 8;
 TotalStats.Current10s := (TotalIn + TotalOut) * 8;
 TotalStats.Current40s := (TotalIn + TotalOut) * 8;
 TotalStats.Cumulative := TotalIn + TotalOut;
 TotalStats.LastUpdate := CurrentTime;
 
 { Mettre à jour les pics }
 If InStats.Current2s > InStats.Peak Then
  InStats.Peak := InStats.Current2s;
 If OutStats.Current2s > OutStats.Peak Then
  OutStats.Peak := OutStats.Current2s;
 If TotalStats.Current2s > TotalStats.Peak Then
  TotalStats.Peak := TotalStats.Current2s;
End;

{ === AFFICHAGE === }

{ Dessiner une barre de progression }
Procedure DrawBar(Value, MaxValue: Int64; Width: Integer);
Var
 I, BarLength: Integer;
 Ratio: Double;
Begin
 If MaxValue = 0 Then Begin
  For I := 1 To Width Do
   Write(' ');
  Exit;
 End;
 
 Ratio := Value / MaxValue;
 If Ratio > 1.0 Then Ratio := 1.0;
 
 BarLength := Round(Ratio * Width);
 
 For I := 1 To BarLength Do
  Write('=');
 For I := BarLength + 1 To Width Do
  Write(' ');
End;

{ Afficher l'en-tête }
Procedure DisplayHeader;
Begin
 ClrScr;
 
 WriteLn('                   ', Copy(NetworkInterface.Name + ' - ' + NetworkInterface.IPAddress + 
         '                                                    ', 1, 40));
 WriteLn('Peak rates (in/out/total): ', FormatBandwidth(InStats.Peak), '/', 
         FormatBandwidth(OutStats.Peak), '/', FormatBandwidth(TotalStats.Peak));
 WriteLn('Cumulative (in/out/total): ', FormatBytes(InStats.Cumulative), '/', 
         FormatBytes(OutStats.Cumulative), '/', FormatBytes(TotalStats.Cumulative));
 WriteLn;
 WriteLn('Host name (port/proto)     2s    10s   40s  <=>', '  TX rate (2s/10s/40s)     RX rate (2s/10s/40s)');
 WriteLn(StringOfChar('-', 80));
 
 DisplayLine := 7;
End;

{ Afficher une connexion }
Procedure DisplayConnection(Index: Integer);
Var
 HostName: String;
 ServiceName: String;
 SourceStr: String;
 TxRateStr: String;
 RxRateStr: String;
 DirectionChar: String;
Begin
 If (Index < 0) or (Index >= ConnectionCount) Then Exit;
 
 With Connections[Index] Do Begin
  { Préparer le nom d'hôte }
  HostName := ResolveHostname(RemoteIP);
  If Length(HostName) > 20 Then
   HostName := Copy(HostName, 1, 17) + '...';
  
  { Préparer le nom du service }
  If IftopConfig.ShowPorts Then Begin
   ServiceName := ResolveServiceName(RemotePort, Protocol);
   SourceStr := HostName + ':' + ServiceName;
  End Else Begin
   SourceStr := HostName;
  End;
  
  If Length(SourceStr) > 26 Then
   SourceStr := Copy(SourceStr, 1, 23) + '...';
  
  { Calculer les débits }
  TxRateStr := FormatBandwidth(BytesSent * 8) + '/' +
               FormatBandwidth(BytesSent * 8) + '/' +
               FormatBandwidth(BytesSent * 8);
  
  RxRateStr := FormatBandwidth(BytesReceived * 8) + '/' +
               FormatBandwidth(BytesReceived * 8) + '/' +
               FormatBandwidth(BytesReceived * 8);
  
  { Caractère de direction }
  If Direction = 'OUT' Then DirectionChar := '=>'
  Else If Direction = 'IN' Then DirectionChar := '<='
  Else DirectionChar := '<=>';
  
  { Afficher la ligne }
  GotoXY(1, DisplayLine);
  Write(Copy(SourceStr + '                          ', 1, 26));
  Write(' ', DirectionChar, ' ');
  Write(Copy(TxRateStr + '                     ', 1, 21));
  Write(' ', Copy(RxRateStr + '                     ', 1, 21));
  
  Inc(DisplayLine);
  
  { Afficher les barres si demandé }
  If not IftopConfig.NoBarGraph and (DisplayLine < 24) Then Begin
   GotoXY(27, DisplayLine - 1);
   DrawBar(BytesSent, TotalStats.Peak div 8, 10);
   GotoXY(40, DisplayLine - 1);
   DrawBar(BytesReceived, TotalStats.Peak div 8, 10);
  End;
 End;
End;

{ Afficher le pied de page }
Procedure DisplayFooter;
Var
 Runtime: TDateTime;
 RuntimeStr: String;
Begin
 Runtime := Now - StartTime;
 RuntimeStr := FormatDateTime('hh:nn:ss', Runtime);
 
 GotoXY(1, 23);
 WriteLn(StringOfChar('-', 80));
 WriteLn('TX: ', FormatBandwidth(OutStats.Current2s), 
         ' RX: ', FormatBandwidth(InStats.Current2s),
         ' TOTAL: ', FormatBandwidth(TotalStats.Current2s),
         ' Peak: ', FormatBandwidth(TotalStats.Peak));
 WriteLn('q to quit, p to pause, h for help - Running: ', RuntimeStr);
End;

{ Trier les connexions }
Procedure SortConnections;
Var
 I, J: Integer;
 Temp: TNetworkConnection;
Begin
 For I := 0 To ConnectionCount - 2 Do Begin
  For J := I + 1 To ConnectionCount - 1 Do Begin
   If IftopConfig.SortBy = 'bytes' Then Begin
    If (Connections[I].BytesSent + Connections[I].BytesReceived) <
       (Connections[J].BytesSent + Connections[J].BytesReceived) Then Begin
     Temp := Connections[I];
     Connections[I] := Connections[J];
     Connections[J] := Temp;
    End;
   End
   Else If IftopConfig.SortBy = 'source' Then Begin
    If Connections[I].RemoteIP > Connections[J].RemoteIP Then Begin
     Temp := Connections[I];
     Connections[I] := Connections[J];
     Connections[J] := Temp;
    End;
   End;
  End;
 End;
End;

{ Afficher l'aide }
Procedure DisplayHelp;
Begin
 ClrScr;
 WriteLn('iftop - Network bandwidth monitor');
 WriteLn;
 WriteLn('Interactive commands:');
 WriteLn;
 WriteLn('  General:');
 WriteLn('    q           Quit');
 WriteLn('    h           Help (this screen)');
 WriteLn('    p           Pause/unpause display');
 WriteLn('    r           Reset peak rates');
 WriteLn('    R           Reset cumulative counters');
 WriteLn;
 WriteLn('  Sorting:');
 WriteLn('    s           Sort by source');
 WriteLn('    S           Sort by source (reverse)');
 WriteLn('    d           Sort by destination');
 WriteLn('    D           Sort by destination (reverse)');
 WriteLn('    <           Sort by source traffic');
 WriteLn('    >           Sort by destination traffic');
 WriteLn;
 WriteLn('  Display options:');
 WriteLn('    n           Toggle DNS resolution');
 WriteLn('    N           Toggle service resolution');
 WriteLn('    P           Toggle port numbers');
 WriteLn('    b           Toggle bar graphs');
 WriteLn('    B           Toggle bar graph style');
 WriteLn('    l           Toggle log/linear scales');
 WriteLn('    L           Set fixed upper limit for bandwidth scale');
 WriteLn;
 WriteLn('  Filtering:');
 WriteLn('    f           Edit filter');
 WriteLn('    F           Clear filter');
 WriteLn;
 WriteLn('Press any key to continue...');
 ReadKey;
End;

{ Traiter les touches clavier }
Function ProcessKeyboard: Boolean;
Var
 Key: Char;
Begin
 Result := True;
 
 If KeyPressed Then Begin
  Key := ReadKey;
  
  Case UpCase(Key) Of
   'Q': Begin
    ExitRequested := True;
    Result := False;
   End;
   
   'H': DisplayHelp;
   
   'P': Begin
    PauseDisplay := not PauseDisplay;
   End;
   
   'R': Begin
    { Reset peak rates }
    InStats.Peak := 0;
    OutStats.Peak := 0;
    TotalStats.Peak := 0;
   End;
   
   'N': Begin
    IftopConfig.ResolveHosts := not IftopConfig.ResolveHosts;
   End;
   
   'S': Begin
    IftopConfig.SortBy := 'source';
   End;
   
   'B': Begin
    IftopConfig.NoBarGraph := not IftopConfig.NoBarGraph;
   End;
   
   '<': Begin
    IftopConfig.SortBy := 'bytes';
   End;
  End;
 End;
End;

{ === FONCTIONS PRINCIPALES === }

{ Initialiser la configuration par défaut }
Procedure InitializeConfig;
Begin
 With IftopConfig Do Begin
  NetworkInterface := 'eth0';
  PromiscuousMode := False;
  ResolveHosts := True;
  ResolveServices := True;
  ShowPorts := True;
  ShowDirection := True;
  ShowSingleHost := False;
  Filter := '';
  SortBy := 'bytes';
  RefreshInterval := 1000; { 1 seconde }
  MaxConnections := 100;
  MaxLines := 15;
  LogFile := '';
  Verbose := False;
  Quiet := False;
  NoBarGraph := False;
  LinearScale := True;
  LogScale := False;
  FixedScale := False;
  MaxBandwidth := 0;
 End;
 
 ConnectionCount := 0;
 HistoryCount := 0;
 HistoryIndex := 0;
 DisplayLine := 1;
 ExitRequested := False;
 PauseDisplay := False;
 
 { Initialiser les statistiques }
 FillChar(InStats, SizeOf(InStats), 0);
 FillChar(OutStats, SizeOf(OutStats), 0);
 FillChar(TotalStats, SizeOf(TotalStats), 0);
 
 StartTime := Now;
End;

{ Analyser les arguments de ligne de commande }
Function ParseCommandLine: Boolean;
Var
 I: Integer;
 Param: String;
Begin
 ParseCommandLine := True;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-i') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.NetworkInterface := ParamStr(I)
   Else Begin
    WriteLn('Option -i requires interface name');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-f') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.Filter := ParamStr(I)
   Else Begin
    WriteLn('Option -f requires filter expression');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-p') Then Begin
   IftopConfig.PromiscuousMode := True;
  End
  Else If (LowerCase(Param) = '-n') Then Begin
   IftopConfig.ResolveHosts := False;
  End
  Else If (LowerCase(Param) = '-N') Then Begin
   IftopConfig.ResolveServices := False;
  End
  Else If (LowerCase(Param) = '-P') Then Begin
   IftopConfig.ShowPorts := False;
  End
  Else If (LowerCase(Param) = '-b') Then Begin
   IftopConfig.NoBarGraph := True;
  End
  Else If (LowerCase(Param) = '-B') Then Begin
   IftopConfig.LinearScale := False;
   IftopConfig.LogScale := True;
  End
  Else If (LowerCase(Param) = '-m') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.MaxBandwidth := StrToInt64Def(ParamStr(I), 0)
   Else Begin
    WriteLn('Option -m requires bandwidth limit');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-c') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.RefreshInterval := StrToIntDef(ParamStr(I), 1000)
   Else Begin
    WriteLn('Option -c requires refresh interval');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-s') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.SortBy := ParamStr(I)
   Else Begin
    WriteLn('Option -s requires sort criteria');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Interface sans option }
   IftopConfig.NetworkInterface := Param;
  End;
  
  Inc(I);
 End;
End;

{ Boucle principale de surveillance }
Procedure RunMonitoring;
Var
 LastUpdate: TDateTime;
 I: Integer;
Begin
 If not IftopConfig.Quiet Then Begin
  WriteLn('iftop - Monitoring interface: ', IftopConfig.NetworkInterface);
  WriteLn('Press h for help, q to quit');
  Sleep(2000);
 End;
 
 LastUpdate := Now - 1; { Force une première mise à jour }
 
 While not ExitRequested Do Begin
  { Traiter les touches clavier }
  If not ProcessKeyboard Then
   Break;
  
  { Mise à jour des données si pas en pause }
  If not PauseDisplay and 
     (MilliSecondsBetween(Now, LastUpdate) >= IftopConfig.RefreshInterval) Then Begin
   
   { Obtenir les connexions actives }
   GetActiveConnections;
   
   { Mettre à jour les statistiques }
   UpdateBandwidthStats;
   
   { Trier les connexions }
   SortConnections;
   
   LastUpdate := Now;
  End;
  
  { Afficher l'interface }
  If not PauseDisplay Then Begin
   DisplayHeader;
   
   For I := 0 To Min(ConnectionCount - 1, IftopConfig.MaxLines - 1) Do
    DisplayConnection(I);
   
   DisplayFooter;
  End;
  
  { Attendre avant le prochain rafraîchissement }
  Sleep(100);
 End;
End;

{ Fonction principale }
Procedure RunIftop;
Begin
 If not IftopConfig.Quiet Then Begin
  WriteLn('iftop - Network Bandwidth Monitor');
  WriteLn('Initializing network monitoring...');
  WriteLn;
 End;
 
 { Initialiser réseau }
 If not InitializeNetwork Then Begin
  WriteLn('Failed to initialize network');
  Halt(1);
 End;
 
 Try
  { Obtenir les interfaces réseau }
  If GetNetworkInterfaces = 0 Then Begin
   WriteLn('No network interfaces found');
   Halt(1);
  End;
  
  { Démarrer la surveillance }
  RunMonitoring;
  
 Finally
  CleanupNetwork;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedIftop;
Begin
 WriteLn('IFTOP [NETWORKKIT-P] Network Bandwidth Monitor (simulation)');
 WriteLn('===========================================================');
 WriteLn;
 WriteLn('                       eth0 - 192.168.1.100');
 WriteLn('Peak rates (in/out/total): 2.5Mb/1.8Mb/4.3Mb');
 WriteLn('Cumulative (in/out/total): 45.2MB/23.1MB/68.3MB');
 WriteLn;
 WriteLn('Host name (port/proto)     2s    10s   40s  <=> TX rate (2s/10s/40s)     RX rate (2s/10s/40s)');
 WriteLn(StringOfChar('-', 80));
 WriteLn('google.com:443            <=> 234Kb/189Kb/156Kb    1.2Mb/987Kb/834Kb');
 WriteLn('reddit.com:80             <=> 89Kb/95Kb/102Kb      456Kb/389Kb/324Kb');
 WriteLn('facebook.com:443          <=> 45Kb/52Kb/38Kb       234Kb/198Kb/167Kb');
 WriteLn('8.8.8.8:53                <=> 2Kb/1Kb/3Kb          8Kb/6Kb/9Kb');
 WriteLn('192.168.1.1:22            <=> 12Kb/15Kb/18Kb       34Kb/29Kb/41Kb');
 WriteLn;
 WriteLn(StringOfChar('-', 80));
 WriteLn('TX: 382Kb RX: 1.9Mb TOTAL: 2.3Mb Peak: 4.3Mb');
 WriteLn('q to quit, p to pause, h for help - Running: 00:02:34');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('IFTOP : Interface bandwidth usage monitor');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IFTOP [options] [interface]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  --version             Afficher la version');
  WriteLn('  -i INTERFACE          Interface réseau à surveiller');
  WriteLn('  -f FILTER             Expression de filtrage du trafic');
  WriteLn('  -p                    Activer mode promiscuité');
  WriteLn('  -n                    Pas de résolution DNS');
  WriteLn('  -N                    Pas de résolution des ports');
  WriteLn('  -P                    Pas d''affichage des ports');
  WriteLn('  -b                    Pas de graphiques en barres');
  WriteLn('  -B                    Utiliser échelle logarithmique');
  WriteLn('  -m LIMIT              Limite de bande passante fixe');
  WriteLn('  -c CONFIG             Fichier de configuration');
  WriteLn('  -s SORT               Critère de tri (source/dest/bytes)');
  WriteLn('  -t SECONDS            Durée d''exécution en secondes');
  WriteLn('  -L LINES              Nombre de lignes à afficher');
  WriteLn('  -o OUTPUT             Format de sortie (text/csv/xml)');
  WriteLn('  -d                    Mode démon (arrière-plan)');
  WriteLn('  -w FILE               Écrire dans un fichier');
  WriteLn;
  WriteLn('Commandes interactives :');
  WriteLn('  Navigation et contrôle :');
  WriteLn('    q                   Quitter');
  WriteLn('    h                   Afficher aide');
  WriteLn('    p                   Pause/reprendre affichage');
  WriteLn('    r                   Reset compteurs pic');
  WriteLn('    R                   Reset compteurs cumulatifs');
  WriteLn('    ^L                  Rafraîchir écran');
  WriteLn;
  WriteLn('  Tri des connexions :');
  WriteLn('    s                   Trier par source');
  WriteLn('    S                   Trier par source (inverse)');
  WriteLn('    d                   Trier par destination');
  WriteLn('    D                   Trier par destination (inverse)');
  WriteLn('    <                   Trier par trafic source');
  WriteLn('    >                   Trier par trafic destination');
  WriteLn('    o                   Basculer tri 2s/10s/40s');
  WriteLn;
  WriteLn('  Options d''affichage :');
  WriteLn('    n                   Basculer résolution DNS');
  WriteLn('    N                   Basculer résolution ports');
  WriteLn('    P                   Basculer affichage ports');
  WriteLn('    b                   Basculer graphiques barres');
  WriteLn('    B                   Changer style graphiques');
  WriteLn('    l                   Basculer échelle log/linéaire');
  WriteLn('    L                   Définir limite échelle fixe');
  WriteLn('    1/2/3               Afficher moyennes 2s/10s/40s');
  WriteLn('    j/k                 Défilement haut/bas');
  WriteLn;
  WriteLn('  Filtrage du trafic :');
  WriteLn('    f                   Modifier filtre');
  WriteLn('    F                   Effacer filtre');
  WriteLn;
  WriteLn('Expressions de filtre :');
  WriteLn('  host HOST             Trafic vers/depuis HOST');
  WriteLn('  net NET/MASK          Trafic vers/depuis réseau');
  WriteLn('  port PORT             Trafic sur port PORT');
  WriteLn('  src host HOST         Trafic depuis HOST');
  WriteLn('  dst host HOST         Trafic vers HOST');
  WriteLn('  tcp/udp/icmp          Protocoles spécifiques');
  WriteLn('  not EXPR              Négation d''expression');
  WriteLn('  EXPR and EXPR         Intersection');
  WriteLn('  EXPR or EXPR          Union');
  WriteLn;
  WriteLn('Colonnes affichées :');
  WriteLn('  Host name             Nom d''hôte distant');
  WriteLn('  2s/10s/40s            Débits moyens sur 2, 10 et 40 secondes');
  WriteLn('  <=>                   Direction du trafic');
  WriteLn('  TX rate               Débit d''envoi (upload)');
  WriteLn('  RX rate               Débit de réception (download)');
  WriteLn;
  WriteLn('Informations de statut :');
  WriteLn('  Peak rates            Débits maximum enregistrés');
  WriteLn('  Cumulative            Total des données transférées');
  WriteLn('  TX/RX/TOTAL           Débits actuels par direction');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  IFTOP                           # Interface par défaut');
  WriteLn('  IFTOP -i eth0                   # Interface spécifique');
  WriteLn('  IFTOP -n -P                     # Sans résolution DNS/ports');
  WriteLn('  IFTOP -f "host google.com"      # Filtrer trafic Google');
  WriteLn('  IFTOP -f "port 80 or port 443"  # Trafic HTTP/HTTPS');
  WriteLn('  IFTOP -b -B                     # Sans barres, échelle log');
  WriteLn('  IFTOP -m 100M                   # Limite à 100 Mbps');
  WriteLn('  IFTOP -t 60                     # Surveiller 60 secondes');
  WriteLn;
  WriteLn('Unités de mesure :');
  WriteLn('  b/B       bits/bytes par seconde');
  WriteLn('  Kb/KB     Kilobits/Kilobytes par seconde');
  WriteLn('  Mb/MB     Mégabits/Mégabytes par seconde');
  WriteLn('  Gb/GB     Gigabits/Gigabytes par seconde');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  IFTOP_INTERFACE       Interface par défaut');
  WriteLn('  IFTOP_CONFIG          Fichier de configuration');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                     Surveillance terminée normalement');
  WriteLn('  1                     Erreur d''initialisation');
  WriteLn('  2                     Interface non trouvée');
  WriteLn('  3                     Permissions insuffisantes');
  WriteLn;
  WriteLn('Note: Moniteur de bande passante réseau en temps réel.');
  WriteLn('Surveille le trafic par connexion avec moyennes temporelles.');
  WriteLn('Compatible avec iftop original. Nécessite privilèges administrateur.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('iftop (NETWORKKIT-P) 1.0');
  WriteLn('Network bandwidth usage monitor');
  WriteLn('Compatible with iftop 1.0pre4');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeConfig;
  If ParseCommandLine Then
   RunIftop
  Else Begin
   WriteLn('Try "iftop --help" for more information.');
   Halt(1);
  End;
  {$ELSE}
  ShowSimulatedIftop;
  {$ENDIF}
 End;
END.
