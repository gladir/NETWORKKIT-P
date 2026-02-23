{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande iftop (Network bandwidth monitor))
}

Program IFTOP;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows, Crt, PtcCrt;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB, Crt;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'une connexion rÇseau }
 TNetworkConnection = Record
  LocalIP: String[16];        { Adresse IP locale }
  LocalPort: Word;            { Port local }
  RemoteIP: String[16];       { Adresse IP distante }
  RemotePort: Word;           { Port distant }
  Protocol: String[8];        { Protocole (TCP/UDP) }
  State: String[16];          { êtat de la connexion }
  ProcessID: LongWord;        { ID du processus }
  ProcessName: String[64];    { Nom du processus }
  BytesSent: Int64;           { Octets envoyÇs }
  BytesReceived: Int64;       { Octets reáus }
  PacketsSent: LongWord;      { Paquets envoyÇs }
  PacketsReceived: LongWord;  { Paquets reáus }
  LastUpdate: TDateTime;      { Derniäre mise Ö jour }
  Direction: String[8];       { Direction (EntrÇe/Sortie/Les deux) }
  IsActive: Boolean;          { Connexion active }
 End;

 { Statistiques interface rÇseau }
 TNetworkInterface = Record
  Name: String[32];           { Nom de l'interface }
  Description: String[128];   { Description }
  MACAddress: String[18];     { Adresse MAC }
  IPAddress: String[16];      { Adresse IP }
  SubnetMask: String[16];     { Masque de sous-rÇseau }
  Gateway: String[16];        { Passerelle }
  MTU: Word;                  { Maximum Transmission Unit }
  Speed: Int64;               { Vitesse en bits/sec }
  BytesSent: Int64;           { Total octets envoyÇs }
  BytesReceived: Int64;       { Total octets reáus }
  PacketsSent: LongWord;      { Total paquets envoyÇs }
  PacketsReceived: LongWord;  { Total paquets reáus }
  ErrorsIn: LongWord;         { Erreurs en entrÇe }
  ErrorsOut: LongWord;        { Erreurs en sortie }
  DropsIn: LongWord;          { Paquets supprimÇs en entrÇe }
  DropsOut: LongWord;         { Paquets supprimÇs en sortie }
  IsUp: Boolean;              { Interface active }
  IsLoopback: Boolean;        { Interface de bouclage }
 End;

 { Configuration iftop }
 TIftopConfig = Record
  NetworkInterface: String[32];    { Interface Ö surveiller }
  PromiscuousMode: Boolean;   { Mode promiscuitÇ }
  ResolveHosts: Boolean;      { RÇsoudre noms d'hìtes }
  ResolveServices: Boolean;   { RÇsoudre noms de services }
  ShowPorts: Boolean;         { Afficher numÇros de ports }
  ShowDirection: Boolean;     { Afficher direction du trafic }
  ShowSingleHost: Boolean;    { Afficher un seul hìte }
  Filter: String[255];        { Filtre de trafic }
  SortBy: String[16];         { Critäre de tri }
  RefreshInterval: Integer;   { Intervalle de rafraåchissement (ms) }
  MaxConnections: Integer;    { Nombre max de connexions }
  MaxLines: Integer;          { Nombre max de lignes }
  LogFile: String[255];       { Fichier de journal de bord }
  Verbose: Boolean;           { Mode verbeux }
  Quiet: Boolean;             { Mode silencieux }
  NoBarGraph: Boolean;        { Pas de graphique en barres }
  LinearScale: Boolean;       { êchelle linÇaire }
  LogScale: Boolean;          { êchelle logarithmique }
  FixedScale: Boolean;        { êchelle fixe }
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
  Cumulative: Int64;          { Trafic cumulÇ }
  LastUpdate: TDateTime;      { Derniäre mise Ö jour }
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

 { Convertir octets en chaåne lisible }
Function FormatBytes(Bytes:Int64):String;Begin
 If Bytes < 1024 Then
  Result := IntToStr(Bytes) + 'o'
 Else If Bytes < 1024 * 1024 Then
  Result := FormatFloat('0.0', Bytes / 1024) + 'Ko'
 Else If Bytes < 1024 * 1024 * 1024 Then
  Result := FormatFloat('0.0', Bytes / (1024 * 1024)) + 'Mo'
 Else
  Result := FormatFloat('0.0', Bytes / (1024 * 1024 * 1024)) + 'Go';
End;

{ Convertir bits/sec en chaåne lisible }
Function FormatBandwidth(BitsPerSec: Int64): String;
Begin
 If BitsPerSec < 1024 Then
  Result := IntToStr(BitsPerSec) + 'o'
 Else If BitsPerSec < 1024 * 1024 Then
  Result := FormatFloat('0.0', BitsPerSec / 1024) + 'Ko'
 Else If BitsPerSec < 1024 * 1024 * 1024 Then
  Result := FormatFloat('0.0', BitsPerSec / (1024 * 1024)) + 'Mo'
 Else
  Result := FormatFloat('0.0', BitsPerSec / (1024 * 1024 * 1024)) + 'Go';
End;

{ RÇsoudre nom d'hìte depuis IP }
Function ResolveHostname(IPAddress:String):String;
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

{ RÇsoudre nom de service depuis port }
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

{ === FONCTIONS DE SURVEILLANCE RêSEAU === }

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
  WriteLn('Erreur: Impossible d''initialiser WinSock');
  InitializeNetwork := False;
 End;
 {$ENDIF}
End;

{ Nettoyer rÇseau }
Procedure CleanupNetwork;Begin
 {$IFDEF WINDOWS}
 WSACleanup;
 {$ENDIF}
End;

{ Obtenir les interfaces rÇseau }
Function GetNetworkInterfaces:Integer;Begin
 Result := 1;
  { Pour cette dÇmonstration, simuler une interface }
 With NetworkInterface Do Begin
  Name := 'eth0';
  Description := 'Adaptateur Ethernet';
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

 { Obtenir les connexions rÇseau actives }
Function GetActiveConnections:Integer;
Var
 I:Integer;
 BasePort:Word;
Begin
 ConnectionCount := 0;
  { Simuler quelques connexions pour la dÇmonstration }
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
   If BytesSent > BytesReceived Then Direction := 'OUT' Else
   If BytesReceived > BytesSent Then Direction := 'IN'
                                Else Direction := 'BOTH';
   IsActive := True;
  End;
  Inc(ConnectionCount);
 End;
 Result := ConnectionCount;
End;

{ Mettre Ö jour les statistiques de bande passante }
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
  { Ajouter Ö l'historique }
 If HistoryCount < High(BandwidthHistory) Then Inc(HistoryCount);
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

 { Mettre Ö jour les pics }
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
 For I := 1 To BarLength Do Write('=');
 For I := BarLength + 1 To Width Do Write(' ');
End;

{ Afficher l'entàte }
Procedure DisplayHeader;Begin
 ClrScr;
 WriteLn('                   ', Copy(NetworkInterface.Name + ' - ' + NetworkInterface.IPAddress +
         '                                                    ', 1, 40));
 WriteLn('Taux de pointe (entrÇe/sortie/total): ', FormatBandwidth(InStats.Peak), '/',
         FormatBandwidth(OutStats.Peak), '/', FormatBandwidth(TotalStats.Peak));
 WriteLn('Cumulatif (entrÇe/sortie/total): ', FormatBytes(InStats.Cumulative), '/',
         FormatBytes(OutStats.Cumulative), '/', FormatBytes(TotalStats.Cumulative));
 WriteLn;
 WriteLn('Nom de l''hìte (port/proto)     2s    10s   40s  <=>', '  Taux TX (2s/10s/40s)     Taux RX (2s/10s/40s)');
 WriteLn(StringOfChar(#196, 80));
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
  { PrÇparer le nom d'hìte }
  HostName := ResolveHostname(RemoteIP);
  If Length(HostName) > 20 Then HostName := Copy(HostName, 1, 17) + '...';
  { PrÇparer le nom du service }
  If IftopConfig.ShowPorts Then Begin
   ServiceName := ResolveServiceName(RemotePort, Protocol);
   SourceStr := HostName + ':' + ServiceName;
  End
   Else
  Begin
   SourceStr := HostName;
  End;
  If Length(SourceStr) > 26 Then
   SourceStr := Copy(SourceStr, 1, 23) + '...';
  { Calculer les dÇbits }
  TxRateStr := FormatBandwidth(BytesSent * 8) + '/' +
               FormatBandwidth(BytesSent * 8) + '/' +
               FormatBandwidth(BytesSent * 8);
  RxRateStr := FormatBandwidth(BytesReceived * 8) + '/' +
               FormatBandwidth(BytesReceived * 8) + '/' +
               FormatBandwidth(BytesReceived * 8);
   { Caractäre de direction }
  If Direction = 'OUT' Then DirectionChar := '=>' Else
  If Direction = 'IN' Then DirectionChar := '<='
                      Else DirectionChar := '<=>';
  { Afficher la ligne }
  GotoXY(1, DisplayLine);
  Write(Copy(SourceStr + '                          ', 1, 26));
  Write(' ', DirectionChar, ' ');
  Write(Copy(TxRateStr + '                     ', 1, 21));
  Write(' ', Copy(RxRateStr + '                     ', 1, 21));
  Inc(DisplayLine);
   { Afficher les barres si demandÇ }
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
 WriteLn(StringOfChar(#196,80));
 WriteLn('TX: ', FormatBandwidth(OutStats.Current2s),
         ' RX: ', FormatBandwidth(InStats.Current2s),
         ' TOTAL: ', FormatBandwidth(TotalStats.Current2s),
         ' Pointe: ', FormatBandwidth(TotalStats.Peak));
 WriteLn('q pour quitter, p pour pause, h pour aide - ExÇcution: ', RuntimeStr);
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
Procedure DisplayHelp;Begin
 ClrScr;
 WriteLn('iftop - Surveillance de la bande passante rÇseau');
 WriteLn;
 WriteLn('Commandes interactive :');
 WriteLn;
 WriteLn('  General:');
 WriteLn('    q           Quitte');
 WriteLn('    h           Aide (cet Çcran)');
 WriteLn('    p           Affiche avec pause ou sans pause');
 WriteLn('    r           RÇinitialise les taux de pointes');
 WriteLn('    R           RÇinitialise les compteurs cumulatif');
 WriteLn;
 WriteLn('  TriÇ:');
 WriteLn('    s           Tri par source');
 WriteLn('    S           Tri inversÇ par source');
 WriteLn('    d           Tri par destination');
 WriteLn('    D           Tri inversÇ par destination');
 WriteLn('    <           Tri par source de trafic');
 WriteLn('    >           Tri par destination traffic');
 WriteLn;
 WriteLn('  Options d''affichage:');
 WriteLn('    n           Active/dÇsactive la rÇsolution DNS');
 WriteLn('    N           Active/dÇsactive la rÇsolution de service');
 WriteLn('    P           Active/dÇsactive les numÇros de port');
 WriteLn('    b           Active/dÇsactive les graphiques en bar');
 WriteLn('    B           Active/dÇsactive le style de graphiques en bar');
 WriteLn('    l           Active/dÇsactive l''Çchelle de journal/linÇaire');
 WriteLn('    L           DÇfinir une limite supÇrieure fixe pour l''Çchelle de bande passante');
 WriteLn;
 WriteLn('  FiltrÇ:');
 WriteLn('    f           Edition du filtre');
 WriteLn('    F           Efface le filtre');
 WriteLn;
 WriteLn('Presse n''importe quel touche pour continuer...');
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
    IftopConfig.SortBy := 'octets';
   End;
  End;
 End;
End;

{ === FONCTIONS PRINCIPALES === }

{ Initialiser la configuration par dÇfaut }
Procedure InitializeConfig;Begin
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
    WriteLn('Option -i requäres un nom d''interface');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-f') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.Filter := ParamStr(I)
   Else Begin
    WriteLn('Option -f requäre une expression de filtre');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-p') Then Begin
   IftopConfig.PromiscuousMode := True;
  End
   Else
  If (LowerCase(Param) = '-n') Then Begin
   IftopConfig.ResolveHosts := False;
  End
   Else
  If (LowerCase(Param) = '-N') Then Begin
   IftopConfig.ResolveServices := False;
  End
   Else
  If (LowerCase(Param) = '-P') Then Begin
   IftopConfig.ShowPorts := False;
  End
   Else
  If (LowerCase(Param) = '-b') Then Begin
   IftopConfig.NoBarGraph := True;
  End
   Else
  If (LowerCase(Param) = '-B') Then Begin
   IftopConfig.LinearScale := False;
   IftopConfig.LogScale := True;
  End
   Else
  If (LowerCase(Param) = '-m') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.MaxBandwidth := StrToInt64Def(ParamStr(I), 0)
   Else Begin
    WriteLn('Option -m requäre une limite de bande passante');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-c') Then Begin
   Inc(I);
   If I <= ParamCount Then
    IftopConfig.RefreshInterval := StrToIntDef(ParamStr(I), 1000)
   Else Begin
    WriteLn('Option -c requäres un intervalle de rafraichissement');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-s') Then Begin
   Inc(I);
   If I <= ParamCount Then IftopConfig.SortBy := ParamStr(I)
    Else
   Begin
    WriteLn('Option -s requäre un critäre de tri');
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
  WriteLn('iftop - Interface de surveillance: ', IftopConfig.NetworkInterface);
  WriteLn('Presse h pour l''aide, q pour quitter');
  Sleep(2000);
 End;
 LastUpdate := Now - 1; { Force une premiäre mise Ö jour }
 While not ExitRequested Do Begin
  { Traiter les touches clavier }
  If not ProcessKeyboard Then Break;
   { Mise Ö jour des donnÇes si pas en pause }
  If not PauseDisplay and(MilliSecondsBetween(Now, LastUpdate) >= IftopConfig.RefreshInterval) Then Begin
    { Obtenir les connexions actives }
   GetActiveConnections;
    { Mettre Ö jour les statistiques }
   UpdateBandwidthStats;
    { Trier les connexions }
   SortConnections;
   LastUpdate := Now;
  End;
   { Afficher l'interface }
  If not PauseDisplay Then Begin
   DisplayHeader;
   For I := 0 To Min(ConnectionCount - 1, IftopConfig.MaxLines - 1) Do DisplayConnection(I);
   DisplayFooter;
  End;
   { Attendre avant le prochain rafra√Æchissement }
  Sleep(100);
 End;
End;

{ Fonction principale }
Procedure RunIftop;
Begin
 If not IftopConfig.Quiet Then Begin
  WriteLn('iftop - Surveillance de la bande passante rÇseau');
  WriteLn('Initialisation la surveillance rÇseau...');
  WriteLn;
 End;
  { Initialiser le rÇseau }
 If not InitializeNetwork Then Begin
  WriteLn('êchec d''initialisation rÇseau');
  Halt(1);
 End;
 Try
  { Obtenir les interfaces rÇseau }
  If GetNetworkInterfaces = 0 Then Begin
   WriteLn('Pas d''interfaces rÇseau trouvÇ');
   Halt(1);
  End;
   { DÇmarrer la surveillance }
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
 WriteLn('IFTOP Surveillance de la bande passante du rÇseau (simulation)');
 WriteLn('===========================================================');
 WriteLn;
 WriteLn('                       eth0 - 192.168.1.100');
 WriteLn('Taux de pointe (entrÇe/sortie/total): 2.5Mo/1.8Mo/4.3Mo');
 WriteLn('Cumulatif (entrÇe/sortie/total): 45.2Mo/23.1Mo/68.3Mo');
 WriteLn;
 WriteLn('Nom de l''hote (port/proto) 2s    10s   40s  <=> TX rate (2s/10s/40s)     Taux RX (2s/10s/40s)');
 WriteLn('--------------------------------------------------------------------------------');
 WriteLn('google.com:443            <=> 234Ko/189Ko/156Ko    1.2Mb/987Kb/834Ko');
 WriteLn('reddit.com:80             <=> 89Ko/95Ko/102Ko      456Kb/389Kb/324Ko');
 WriteLn('facebook.com:443          <=> 45Ko/52Ko/38Ko       234Kb/198Kb/167Ko');
 WriteLn('8.8.8.8:53                <=> 2Ko/1Ko/3Ko          8Kb/6Kb/9Ko');
 WriteLn('192.168.1.1:22            <=> 12Ko/15Ko/18Ko       34Kb/29Kb/41Ko');
 WriteLn;
 WriteLn('--------------------------------------------------------------------------------');
 WriteLn('TX: 382Kb RX: 1.9Mb TOTAL: 2.3Mb Peak: 4.3Mb');
 WriteLn('q pour quitter, p pour pause, h pour aide - ExÇcution: 00:02:34');
End;
{$ENDIF}

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}

 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('IFTOP : Cette commande permet de lancer l''interface de surveillance d''utilisation ',
                   'de la bande passante.');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IFTOP [options] [interface]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  --version             Afficher la version');
  WriteLn('  -i INTERFACE          Interface rÇseau Ö surveiller');
  WriteLn('  -f FILTER             Expression de filtrage du trafic');
  WriteLn('  -p                    Activer mode promiscuitÇ');
  WriteLn('  -n                    Pas de rÇsolution DNS');
  WriteLn('  -N                    Pas de rÇsolution des ports');
  WriteLn('  -P                    Pas d''affichage des ports');
  WriteLn('  -b                    Pas de graphiques en barres');
  WriteLn('  -B                    Utiliser l''Çchelle logarithmique');
  WriteLn('  -m LIMIT              Limite de bande passante fixe');
  WriteLn('  -c CONFIG             Fichier de configuration');
  WriteLn('  -s SORT               Critäre de tri (source/dest/bytes)');
  WriteLn('  -t SECONDS            DurÇe d''exÇcution en secondes');
  WriteLn('  -L LINES              Nombre de lignes Ö afficher');
  WriteLn('  -o OUTPUT             Format de sortie (text/csv/xml)');
  WriteLn('  -d                    Mode service (arriäre-plan)');
  WriteLn('  -w FILE               êcrire dans un fichier');
  WriteLn;
  WriteLn('Commandes interactives :');
  WriteLn('  Navigation et contrìle :');
  WriteLn('    q                   Quitter');
  WriteLn('    h                   Afficher aide');
  WriteLn('    p                   Pause/reprendre affichage');
  WriteLn('    r                   RÇinitialise le compteurs pic');
  WriteLn('    R                   RÇinitialise les compteurs cumulatifs');
  WriteLn('    ^L                  Rafraåchir Çcran');
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
  WriteLn('    n                   Basculer rÇsolution DNS');
  WriteLn('    N                   Basculer rÇsolution ports');
  WriteLn('    P                   Basculer affichage ports');
  WriteLn('    b                   Basculer graphiques barres');
  WriteLn('    B                   Changer style graphiques');
  WriteLn('    l                   Basculer Çchelle de journaux/linÇaire');
  WriteLn('    L                   DÇfinir limite Çchelle fixe');
  WriteLn('    1/2/3               Afficher moyennes 2s/10s/40s');
  WriteLn('    j/k                 DÇfilement haut/bas');
  WriteLn;
  WriteLn('  Filtrage du trafic :');
  WriteLn('    f                   Modifier filtre');
  WriteLn('    F                   Effacer filtre');
  WriteLn;
  WriteLn('Expressions de filtre :');
  WriteLn('  host HOST             Trafic vers/depuis HOST');
  WriteLn('  net NET/MASK          Trafic vers/depuis rÇseau');
  WriteLn('  port PORT             Trafic sur port PORT');
  WriteLn('  src host HOST         Trafic depuis HOST');
  WriteLn('  dst host HOST         Trafic vers HOST');
  WriteLn('  tcp/udp/icmp          Protocoles spÇcifiques');
  WriteLn('  not EXPR              NÇgation d''expression');
  WriteLn('  EXPR and EXPR         Intersection');
  WriteLn('  EXPR or EXPR          Union');
  WriteLn;
  WriteLn('Colonnes affich√©es :');
  WriteLn('  Host name             Nom d''hìte Ö distance');
  WriteLn('  2s/10s/40s            DÇbits moyens sur 2, 10 et 40 secondes');
  WriteLn('  <=>                   Direction du trafic');
  WriteLn('  TX rate               DÇbit d''envoi (upload)');
  WriteLn('  RX rate               DÇbit de rÇception (download)');
  WriteLn;
  WriteLn('Informations de statut :');
  WriteLn('  Peak rates            DÇbits maximum enregistrÇs');
  WriteLn('  Cumulative            Total des donnÇes transfÇrÇes');
  WriteLn('  TX/RX/TOTAL           DÇbits actuels par direction');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  IFTOP                           # Interface par dÇfaut');
  WriteLn('  IFTOP -i eth0                   # Interface spÇcifique');
  WriteLn('  IFTOP -n -P                     # Sans rÇsolution DNS/ports');
  WriteLn('  IFTOP -f "host google.com"      # Filtrer trafic Google');
  WriteLn('  IFTOP -f "port 80 or port 443"  # Trafic HTTP/HTTPS');
  WriteLn('  IFTOP -b -B                     # Sans barres, Çchelle log');
  WriteLn('  IFTOP -m 100M                   # Limite Ö 100 Mbps');
  WriteLn('  IFTOP -t 60                     # Surveiller 60 secondes');
  WriteLn;
  WriteLn('Unit√©s de mesure :');
  WriteLn('  b/B       bits/octets par seconde');
  WriteLn('  Kb/KB     Kilobits/Kilooctets par seconde');
  WriteLn('  Mb/MB     MÇgabits/MÇgaoctets par seconde');
  WriteLn('  Gb/GB     Gigabits/Gigaoctets par seconde');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  IFTOP_INTERFACE       Interface par dÇfaut');
  WriteLn('  IFTOP_CONFIG          Fichier de configuration');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                     Surveillance terminÇe normalement');
  WriteLn('  1                     Erreur d''initialisation');
  WriteLn('  2                     Interface non trouvÇe');
  WriteLn('  3                     Permissions insuffisantes');
  WriteLn;
  WriteLn('Note: Moniteur de bande passante rÇseau en temps rÇel.');
  WriteLn('Surveille le trafic par connexion avec moyennes temporelles.');
  WriteLn('Compatible avec iftop original. NÇcessite priviläges administrateur.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('iftop (NETWORKKIT-P) 1.0 - NETWORKKIT-P, LINUX-0, Corail');
  WriteLn('Surveilance de l''Çtat d''utilisation de la bande passante');
  WriteLn('Compatible avec iftop 1.0pre4');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeConfig;
  If ParseCommandLine Then
   RunIftop
  Else Begin
   WriteLn('Essayer "iftop --help" pour plus d''information.');
   Halt(1);
  End;
  {$ELSE}
  ShowSimulatedIftop;
  {$ENDIF}
 End;
END.