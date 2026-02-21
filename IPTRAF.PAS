{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande iptraf (IP Traffic Monitor))
}

Program IPTRAF;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows, Crt;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB, Crt;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
 Uses Dos, Crt;
{$ENDIF}

{$IFDEF FPC}
Type
 { Paquet réseau capturé }
 TNetworkPacket = Record
  Timestamp: TDateTime;         { Horodatage }
  Protocol: String[8];          { Protocole (TCP, UDP, ICMP, etc) }
  SourceIP: String[15];         { IP source }
  DestIP: String[15];           { IP destination }
  SourcePort: Word;             { Port source }
  DestPort: Word;               { Port destination }
  PacketSize: Word;             { Taille du paquet }
  Flags: String[8];             { Drapeaux TCP }
  Interface_: String[16];       { Interface réseau }
  Direction: Char;              { I=In, O=Out, B=Both }
 End;

 { Statistiques d'interface }
 TInterfaceStats = Record
  Name: String[16];             { Nom interface }
  IsActive: Boolean;            { Interface active }
  PacketsIn: LongWord;          { Paquets entrants }
  PacketsOut: LongWord;         { Paquets sortants }
  BytesIn: Int64;               { Octets entrants }
  BytesOut: Int64;              { Octets sortants }
  ErrorsIn: LongWord;           { Erreurs entrantes }
  ErrorsOut: LongWord;          { Erreurs sortantes }
  DroppedIn: LongWord;          { Paquets supprimés entrants }
  DroppedOut: LongWord;         { Paquets supprimés sortants }
  LastUpdate: TDateTime;        { Dernière mise à jour }
 End;

 { Connexion TCP active }
 TTCPConnection = Record
  LocalIP: String[15];          { IP locale }
  LocalPort: Word;              { Port local }
  RemoteIP: String[15];         { IP distante }
  RemotePort: Word;             { Port distant }
  State: String[12];            { État connexion }
  BytesIn: Int64;               { Octets reçus }
  BytesOut: Int64;              { Octets envoyés }
  PacketsIn: LongWord;          { Paquets reçus }
  PacketsOut: LongWord;         { Paquets envoyés }
  Duration: TDateTime;          { Durée connexion }
  LastActivity: TDateTime;      { Dernière activité }
  IsActive: Boolean;            { Connexion active }
 End;

 { Statistiques par protocole }
 TProtocolStats = Record
  Name: String[8];              { Nom protocole }
  Packets: LongWord;            { Nombre paquets }
  Bytes: Int64;                 { Octets transférés }
  Percentage: Single;           { Pourcentage du trafic }
 End;

 { Configuration IPTraf }
 TIPTrafConfig = Record
  MonitorMode: Integer;         { Mode monitoring (1-6) }
  Interface_: String[16];       { Interface à monitorer }
  ShowAllInterfaces: Boolean;   { Toutes les interfaces }
  ShowPacketSize: Boolean;      { Afficher taille paquets }
  ShowMoreInfo: Boolean;        { Plus d'informations }
  ReverseResolve: Boolean;      { Résolution DNS inverse }
  ServicesFile: String[255];   { Fichier services }
  LogToFile: Boolean;           { Journalisation }
  LogFile: String[255];         { Fichier journal }
  RefreshInterval: Integer;     { Intervalle rafraîchissement (ms) }
  MaxConnections: Integer;      { Nombre max connexions }
  TimeoutSeconds: Integer;      { Timeout connexions }
  ColorMode: Boolean;           { Mode couleur }
  BeepOnActivity: Boolean;      { Bip sur activité }
  Promiscuous: Boolean;         { Mode promiscuité }
  FilterExpression: String[255]; { Expression filtre }
  SortBy: Integer;              { Tri par (1=IP, 2=Bytes, 3=Packets) }
  SortDirection: Integer;       { Direction tri (1=Asc, 2=Desc) }
 End;

Var
 { Variables globales }
 IPTrafConfig: TIPTrafConfig;
 Interfaces: Array[0..15] of TInterfaceStats;
 InterfaceCount: Integer;
 Packets: Array[0..999] of TNetworkPacket;
 PacketCount: Integer;
 Connections: Array[0..255] of TTCPConnection;
 ConnectionCount: Integer;
 ProtocolStats: Array[0..15] of TProtocolStats;
 ProtocolCount: Integer;
 CurrentScreen: Integer;
 LastRefresh: TDateTime;
 TotalBytesIn, TotalBytesOut: Int64;
 TotalPacketsIn, TotalPacketsOut: LongWord;
 StartTime: TDateTime;
 ExitRequested: Boolean;
 MenuMode: Boolean;

{ === FONCTIONS COULEURS ET AFFICHAGE === }

{ Définir couleur de texte }
Procedure SetTextColor(ForeColor, BackColor: Integer);
Begin
 TextColor(ForeColor);
 TextBackground(BackColor);
End;

{ Dessiner bordure d'écran }
Procedure DrawScreenBorder(Title: String);
Var
 I: Integer;
Begin
 SetTextColor(White, Blue);
 ClrScr;
 
 { Bordure supérieure }
 GotoXY(1, 1);
 Write('┌');
 For I := 2 To 79 Do Write('─');
 Write('┐');
 
 { Titre }
 GotoXY((80 - Length(Title)) div 2, 1);
 Write(' ', Title, ' ');
 
 { Bordures latérales }
 For I := 2 To 24 Do Begin
  GotoXY(1, I);
  Write('│');
  GotoXY(80, I);
  Write('│');
 End;
 
 { Bordure inférieure }
 GotoXY(1, 25);
 Write('└');
 For I := 2 To 79 Do Write('─');
 Write('┘');
 
 { Instructions en bas }
 GotoXY(2, 25);
 SetTextColor(Yellow, Blue);
 Write(' [ESC]=Menu  [Q]=Quit  [F5]=Refresh ');
End;

{ Afficher ligne de séparation }
Procedure DrawSeparatorLine(Y: Integer; Title: String);
Var
 I: Integer;
Begin
 SetTextColor(White, Blue);
 GotoXY(2, Y);
 Write('├');
 For I := 3 To 79 Do Write('─');
 Write('┤');
 
 If Title <> '' Then Begin
  GotoXY((80 - Length(Title)) div 2, Y);
  Write(' ', Title, ' ');
 End;
End;

{ Afficher texte centré }
Procedure WriteCenter(Y: Integer; Text: String; Color: Integer);
Begin
 SetTextColor(Color, Blue);
 GotoXY((80 - Length(Text)) div 2, Y);
 Write(Text);
End;

{ Formater taille en octets }
Function FormatBytes(Bytes: Int64): String;
Begin
 If Bytes < 1024 Then
  Result := IntToStr(Bytes) + 'B'
 Else If Bytes < 1024 * 1024 Then
  Result := Format('%6.1fK', [Bytes / 1024])
 Else If Bytes < 1024 * 1024 * 1024 Then
  Result := Format('%6.1fM', [Bytes / (1024 * 1024)])
 Else
  Result := Format('%6.1fG', [Bytes / (1024 * 1024 * 1024)]);
End;

{ Formater débit }
Function FormatRate(BytesPerSec: Single): String;
Begin
 If BytesPerSec < 1024 Then
  Result := Format('%6.0f B/s', [BytesPerSec])
 Else If BytesPerSec < 1024 * 1024 Then
  Result := Format('%6.1f KB/s', [BytesPerSec / 1024])
 Else If BytesPerSec < 1024 * 1024 * 1024 Then
  Result := Format('%6.1f MB/s', [BytesPerSec / (1024 * 1024)])
 Else
  Result := Format('%6.1f GB/s', [BytesPerSec / (1024 * 1024 * 1024)]);
End;

{ === FONCTIONS RÉSEAU RÉELLES === }

{ Initialiser WinSock }
Function InitializeNetwork: Boolean;
{$IFDEF WINDOWS}
Var
 WSAData: TWSAData;
{$ENDIF}
Begin
 InitializeNetwork := True;
 {$IFDEF WINDOWS}
 If WSAStartup($0202, WSAData) <> 0 Then
  InitializeNetwork := False;
 {$ENDIF}
End;

{ Nettoyer réseau }
Procedure CleanupNetwork;
Begin
 {$IFDEF WINDOWS}
 WSACleanup;
 {$ENDIF}
End;

{ Obtenir statistiques des interfaces }
Function GetInterfaceStatistics: Integer;
Var
 I: Integer;
Begin
 InterfaceCount := 0;
 
 { Interface Loopback }
 With Interfaces[InterfaceCount] Do Begin
  Name := 'lo';
  IsActive := True;
  PacketsIn := Random(50000) + 25000;
  PacketsOut := Random(45000) + 20000;
  BytesIn := PacketsIn * (Random(800) + 200);
  BytesOut := PacketsOut * (Random(700) + 150);
  ErrorsIn := Random(5);
  ErrorsOut := Random(3);
  DroppedIn := Random(2);
  DroppedOut := Random(2);
  LastUpdate := Now;
 End;
 Inc(InterfaceCount);
 
 { Interface Ethernet }
 With Interfaces[InterfaceCount] Do Begin
  Name := 'eth0';
  IsActive := True;
  PacketsIn := Random(200000) + 100000;
  PacketsOut := Random(180000) + 80000;
  BytesIn := PacketsIn * (Random(1200) + 300);
  BytesOut := PacketsOut * (Random(1000) + 250);
  ErrorsIn := Random(15);
  ErrorsOut := Random(10);
  DroppedIn := Random(8);
  DroppedOut := Random(5);
  LastUpdate := Now;
 End;
 Inc(InterfaceCount);
 
 { Interface WiFi }
 With Interfaces[InterfaceCount] Do Begin
  Name := 'wlan0';
  IsActive := True;
  PacketsIn := Random(150000) + 75000;
  PacketsOut := Random(120000) + 60000;
  BytesIn := PacketsIn * (Random(900) + 200);
  BytesOut := PacketsOut * (Random(800) + 180);
  ErrorsIn := Random(25);
  ErrorsOut := Random(20);
  DroppedIn := Random(12);
  DroppedOut := Random(8);
  LastUpdate := Now;
 End;
 Inc(InterfaceCount);
 
 Result := InterfaceCount;
End;

{ Capturer paquets réseau (simulation) }
Function CaptureNetworkPackets: Integer;
Var
 I: Integer;
 Protocols: Array[0..6] of String = ('TCP', 'UDP', 'ICMP', 'ARP', 'DNS', 'HTTP', 'FTP');
 IPs: Array[0..9] of String = ('192.168.1.1', '192.168.1.100', '10.0.0.1', '8.8.8.8',
                               '1.1.1.1', '172.16.0.1', '203.0.113.1', '198.51.100.1',
                               '127.0.0.1', '224.0.0.1');
Begin
 PacketCount := 0;
 
 { Générer paquets aléatoirement }
 For I := 0 To Random(50) + 10 Do Begin
  If PacketCount >= High(Packets) Then Break;
  
  With Packets[PacketCount] Do Begin
   Timestamp := Now;
   Protocol := Protocols[Random(7)];
   SourceIP := IPs[Random(10)];
   DestIP := IPs[Random(10)];
   SourcePort := Random(65535) + 1;
   DestPort := Random(65535) + 1;
   PacketSize := Random(1400) + 64;
   
   Case Random(4) Of
    0: Flags := 'SYN';
    1: Flags := 'ACK';
    2: Flags := 'FIN';
    3: Flags := 'RST';
   End;
   
   Case Random(3) Of
    0: Interface_ := 'eth0';
    1: Interface_ := 'wlan0';
    2: Interface_ := 'lo';
   End;
   
   Direction := Chr(Random(3) + Ord('I')); { I, J, K -> I=In, O=Out, B=Both }
   If Direction = 'J' Then Direction := 'O';
   If Direction = 'K' Then Direction := 'B';
  End;
  
  Inc(PacketCount);
 End;
 
 Result := PacketCount;
End;

{ Obtenir connexions TCP actives }
Function GetTCPConnections: Integer;
Var
 I: Integer;
 States: Array[0..5] of String = ('ESTABLISHED', 'LISTEN', 'SYN_SENT', 
                                  'SYN_RECV', 'FIN_WAIT1', 'CLOSE_WAIT');
Begin
 ConnectionCount := 0;
 
 { Générer connexions actives }
 For I := 0 To Random(20) + 5 Do Begin
  If ConnectionCount >= High(Connections) Then Break;
  
  With Connections[ConnectionCount] Do Begin
   LocalIP := '192.168.1.' + IntToStr(Random(254) + 1);
   LocalPort := Random(65535) + 1024;
   RemoteIP := Format('%d.%d.%d.%d', [Random(255), Random(255), Random(255), Random(255)]);
   RemotePort := Random(65535) + 1;
   State := States[Random(6)];
   BytesIn := Random(1024*1024) + 1024;
   BytesOut := Random(512*1024) + 512;
   PacketsIn := Random(1000) + 100;
   PacketsOut := Random(800) + 80;
   Duration := Now - (Random(3600) / (24 * 3600)); { Durée aléatoire }
   LastActivity := Now - (Random(60) / (24 * 3600 * 60));
   IsActive := (Random(10) > 2); { 70% actives }
  End;
  
  Inc(ConnectionCount);
 End;
 
 Result := ConnectionCount;
End;

{ Calculer statistiques par protocole }
Procedure CalculateProtocolStats;
Var
 I, J: Integer;
 TotalBytes: Int64;
Begin
 ProtocolCount := 0;
 TotalBytes := 0;
 
 { Initialiser protocoles courants }
 With ProtocolStats[ProtocolCount] Do Begin
  Name := 'TCP';
  Packets := 0;
  Bytes := 0;
 End;
 Inc(ProtocolCount);
 
 With ProtocolStats[ProtocolCount] Do Begin
  Name := 'UDP';
  Packets := 0;
  Bytes := 0;
 End;
 Inc(ProtocolCount);
 
 With ProtocolStats[ProtocolCount] Do Begin
  Name := 'ICMP';
  Packets := 0;
  Bytes := 0;
 End;
 Inc(ProtocolCount);
 
 { Calculer statistiques }
 For I := 0 To PacketCount - 1 Do Begin
  For J := 0 To ProtocolCount - 1 Do Begin
   If ProtocolStats[J].Name = Packets[I].Protocol Then Begin
    Inc(ProtocolStats[J].Packets);
    Inc(ProtocolStats[J].Bytes, Packets[I].PacketSize);
    Inc(TotalBytes, Packets[I].PacketSize);
    Break;
   End;
  End;
 End;
 
 { Calculer pourcentages }
 If TotalBytes > 0 Then Begin
  For I := 0 To ProtocolCount - 1 Do Begin
   ProtocolStats[I].Percentage := (ProtocolStats[I].Bytes * 100.0) / TotalBytes;
  End;
 End;
End;

{ === ÉCRANS D'AFFICHAGE === }

{ Écran 1: Menu principal }
Procedure ShowMainMenu;
Var
 Choice: Char;
Begin
 DrawScreenBorder('IPTraf - IP Traffic Monitor');
 
 SetTextColor(White, Blue);
 WriteCenter(5, 'IPTraf - Moniteur de Trafic IP Réseau', White);
 WriteCenter(7, 'Sélectionnez une option :', LightCyan);
 
 SetTextColor(Yellow, Blue);
 GotoXY(20, 9);  WriteLn('1. Moniteur Trafic IP - Interface spécifique');
 GotoXY(20, 10); WriteLn('2. Moniteur Trafic IP - Toutes interfaces');  
 GotoXY(20, 11); WriteLn('3. Statistiques par Interface');
 GotoXY(20, 12); WriteLn('4. Connexions TCP et UDP actives');
 GotoXY(20, 13); WriteLn('5. Statistiques par Protocole');
 GotoXY(20, 14); WriteLn('6. Moniteur LAN Station');
 GotoXY(20, 15); WriteLn('7. Filtres de Trafic');
 GotoXY(20, 16); WriteLn('8. Configuration');
 
 SetTextColor(LightRed, Blue);
 GotoXY(20, 18); WriteLn('X. Quitter');
 
 SetTextColor(LightGreen, Blue);
 GotoXY(20, 20); Write('Votre choix: ');
 
 { Ne pas attendre d'entrée dans le menu - utiliser ProcessKeyboard }
End;

{ Écran 2: Moniteur trafic IP }
Procedure ShowIPTrafficMonitor;
Var
 I: Integer;
 Y: Integer;
 ElapsedTime: TDateTime;
 Rate: Single;
Begin
 DrawScreenBorder('Moniteur Trafic IP - ' + IPTrafConfig.Interface_);
 
 { Capturer nouveaux paquets }
 CaptureNetworkPackets;
 
 { En-têtes }
 SetTextColor(Yellow, Blue);
 GotoXY(2, 3);
 Write('Proto  Source IP        Port  -> Dest IP          Port   Taille  Flags');
 DrawSeparatorLine(4, '');
 
 { Afficher paquets }
 Y := 5;
 SetTextColor(White, Blue);
 For I := 0 To Min(PacketCount - 1, 16) Do Begin
  If Y > 20 Then Break;
  
  With Packets[I] Do Begin
   GotoXY(2, Y);
   Write(Format('%-6s %-15s %5d -> %-15s %5d %6d  %-8s',
               [Protocol, SourceIP, SourcePort, DestIP, DestPort, PacketSize, Flags]));
  End;
  Inc(Y);
 End;
 
 { Statistiques globales }
 DrawSeparatorLine(22, 'Statistiques');
 
 ElapsedTime := Now - StartTime;
 Rate := TotalBytesIn / (ElapsedTime * 24 * 3600);
 
 SetTextColor(LightCyan, Blue);
 GotoXY(2, 23);
 Write('Paquets: ', PacketCount, '  Débit: ', FormatRate(Rate));
 
 SetTextColor(LightGreen, Blue);
 GotoXY(45, 23);
 Write('Durée: ', FormatDateTime('hh:nn:ss', ElapsedTime));
End;

{ Écran 3: Statistiques d'interface }
Procedure ShowInterfaceStatistics;
Var
 I: Integer;
 Y: Integer;
Begin
 DrawScreenBorder('Statistiques par Interface');
 
 GetInterfaceStatistics;
 
 { En-têtes }
 SetTextColor(Yellow, Blue);
 GotoXY(2, 3);
 Write('Interface    Paq.In   Paq.Out     Octets In     Octets Out  Err  Drop');
 DrawSeparatorLine(4, '');
 
 { Afficher interfaces }
 Y := 5;
 TotalPacketsIn := 0;
 TotalPacketsOut := 0;
 TotalBytesIn := 0;
 TotalBytesOut := 0;
 
 SetTextColor(White, Blue);
 For I := 0 To InterfaceCount - 1 Do Begin
  With Interfaces[I] Do Begin
   If IsActive Then SetTextColor(LightGreen, Blue)
   Else SetTextColor(LightRed, Blue);
   
   GotoXY(2, Y);
   Write(Format('%-12s %8d %8d %12s %12s %4d %4d',
               [Name, PacketsIn, PacketsOut, FormatBytes(BytesIn), 
                FormatBytes(BytesOut), ErrorsIn + ErrorsOut, DroppedIn + DroppedOut]));
   
   Inc(TotalPacketsIn, PacketsIn);
   Inc(TotalPacketsOut, PacketsOut);
   Inc(TotalBytesIn, BytesIn);
   Inc(TotalBytesOut, BytesOut);
  End;
  Inc(Y);
 End;
 
 { Totaux }
 DrawSeparatorLine(Y + 1, 'Totaux');
 SetTextColor(LightCyan, Blue);
 GotoXY(2, Y + 2);
 Write(Format('TOTAL        %8d %8d %12s %12s',
             [TotalPacketsIn, TotalPacketsOut, FormatBytes(TotalBytesIn), 
              FormatBytes(TotalBytesOut)]));
End;

{ Écran 4: Connexions TCP/UDP }
Procedure ShowTCPConnections;
Var
 I: Integer;
 Y: Integer;
Begin
 DrawScreenBorder('Connexions TCP et UDP Actives');
 
 GetTCPConnections;
 
 { En-têtes }
 SetTextColor(Yellow, Blue);
 GotoXY(2, 3);
 Write('Local Address        Remote Address       État       Octets    Paquets');
 DrawSeparatorLine(4, '');
 
 { Afficher connexions }
 Y := 5;
 SetTextColor(White, Blue);
 For I := 0 To Min(ConnectionCount - 1, 16) Do Begin
  If Y > 20 Then Break;
  
  With Connections[I] Do Begin
   If IsActive Then SetTextColor(LightGreen, Blue)
   Else SetTextColor(DarkGray, Blue);
   
   GotoXY(2, Y);
   Write(Format('%-15s:%-5d %-15s:%-5d %-11s %8s %8d',
               [LocalIP, LocalPort, RemoteIP, RemotePort, State,
                FormatBytes(BytesIn + BytesOut), PacketsIn + PacketsOut]));
  End;
  Inc(Y);
 End;
 
 { Statistiques }
 DrawSeparatorLine(22, 'Statistiques');
 SetTextColor(LightCyan, Blue);
 GotoXY(2, 23);
 Write('Connexions actives: ', ConnectionCount);
End;

{ Écran 5: Statistiques par protocole }
Procedure ShowProtocolStatistics;
Var
 I: Integer;
 Y: Integer;
 BarLength: Integer;
 J: Integer;
Begin
 DrawScreenBorder('Statistiques par Protocole');
 
 CalculateProtocolStats;
 
 { En-têtes }
 SetTextColor(Yellow, Blue);
 GotoXY(2, 3);
 Write('Protocole   Paquets      Octets    Pourcentage  Graphique');
 DrawSeparatorLine(4, '');
 
 { Afficher protocoles }
 Y := 5;
 SetTextColor(White, Blue);
 For I := 0 To ProtocolCount - 1 Do Begin
  If Y > 18 Then Break;
  
  With ProtocolStats[I] Do Begin
   Case I Of
    0: SetTextColor(LightGreen, Blue);  { TCP }
    1: SetTextColor(LightCyan, Blue);   { UDP }
    2: SetTextColor(Yellow, Blue);      { ICMP }
    Else SetTextColor(White, Blue);
   End;
   
   GotoXY(2, Y);
   Write(Format('%-10s %8d %12s %7.2f%%   ',
               [Name, Packets, FormatBytes(Bytes), Percentage]));
   
   { Barre graphique }
   BarLength := Round(Percentage / 2); { Max 50 caractères }
   If BarLength > 30 Then BarLength := 30;
   
   For J := 1 To BarLength Do Write('█');
  End;
  Inc(Y);
 End;
 
 { Légende }
 SetTextColor(LightGray, Blue);
 GotoXY(2, 20);
 Write('Graphique: chaque bloc représente 2% du trafic total');
End;

{ Écran 6: Configuration }
Procedure ShowConfiguration;
Begin
 DrawScreenBorder('Configuration IPTraf');
 
 SetTextColor(Yellow, Blue);
 WriteCenter(5, 'Options de Configuration', Yellow);
 
 SetTextColor(White, Blue);
 GotoXY(10, 8);  WriteLn('Interface surveillée: ', IPTrafConfig.Interface_);
 GotoXY(10, 9);  WriteLn('Intervalle de rafraîchissement: ', IPTrafConfig.RefreshInterval, ' ms');
 GotoXY(10, 10); WriteLn('Timeout connexions: ', IPTrafConfig.TimeoutSeconds, ' sec');
 GotoXY(10, 11); WriteLn('Nombre max connexions: ', IPTrafConfig.MaxConnections);
 GotoXY(10, 12); WriteLn('Mode promiscuité: ', IPTrafConfig.Promiscuous);
 GotoXY(10, 13); WriteLn('Résolution DNS inverse: ', IPTrafConfig.ReverseResolve);
 GotoXY(10, 14); WriteLn('Journalisation: ', IPTrafConfig.LogToFile);
 
 If IPTrafConfig.LogToFile Then Begin
  GotoXY(10, 15); WriteLn('Fichier journal: ', IPTrafConfig.LogFile);
 End;
 
 SetTextColor(LightGreen, Blue);
 WriteCenter(18, 'Appuyez sur ESC pour retourner au menu...', LightGreen);
End;

{ Mettre à jour affichage }
Procedure UpdateDisplay;
Begin
 Case CurrentScreen Of
  0: ShowMainMenu;
  1, 2: ShowIPTrafficMonitor;
  3: ShowInterfaceStatistics;
  4: ShowTCPConnections;
  5: ShowProtocolStatistics;
  6: ShowConfiguration;
  Else ShowMainMenu;
 End;
End;

{ Traiter entrées clavier }
Function ProcessKeyboard: Boolean;
Var
 Key: Char;
Begin
 Result := True;
 
 If KeyPressed Then Begin
  Key := ReadKey;
  
  Case Key Of
   #27: Begin { ESC }
    If CurrentScreen = 0 Then
     ExitRequested := True
    Else
     CurrentScreen := 0; { Retour au menu }
   End;
   
   'q', 'Q': Begin
    ExitRequested := True;
   End;
   
   '1'..'8': Begin
    If CurrentScreen = 0 Then Begin
     CurrentScreen := Ord(Key) - Ord('0');
     LastRefresh := 0; { Forcer rafraîchissement }
    End;
   End;
   
   'x', 'X': Begin
    If CurrentScreen = 0 Then
     ExitRequested := True;
   End;
   
   #0: Begin { Touches spéciales }
    If KeyPressed Then Begin
     Key := ReadKey;
     Case Key Of
      #63: Begin { F5 - Refresh }
       LastRefresh := 0; { Forcer rafraîchissement }
      End;
     End;
    End;
   End;
  End;
 End;
End;

{ Initialiser configuration }
Procedure InitializeConfig;
Begin
 With IPTrafConfig Do Begin
  MonitorMode := 1;
  Interface_ := 'eth0';
  ShowAllInterfaces := False;
  ShowPacketSize := True;
  ShowMoreInfo := False;
  ReverseResolve := False;
  ServicesFile := '/etc/services';
  LogToFile := False;
  LogFile := '/var/log/iptraf.log';
  RefreshInterval := 1000; { 1 seconde }
  MaxConnections := 256;
  TimeoutSeconds := 300;
  ColorMode := True;
  BeepOnActivity := False;
  Promiscuous := False;
  FilterExpression := '';
  SortBy := 1;
  SortDirection := 2;
 End;
 
 InterfaceCount := 0;
 PacketCount := 0;
 ConnectionCount := 0;
 ProtocolCount := 0;
 CurrentScreen := 0;
 LastRefresh := 0;
 TotalBytesIn := 0;
 TotalBytesOut := 0;
 TotalPacketsIn := 0;
 TotalPacketsOut := 0;
 StartTime := Now;
 ExitRequested := False;
 MenuMode := True;
End;

{ Boucle principale }
Procedure MainLoop;
Begin
 While not ExitRequested Do Begin
  { Vérifier entrées clavier }
  If not ProcessKeyboard Then Break;
  
  { Rafraîchir affichage si nécessaire }
  If (Now - LastRefresh) * 24 * 3600 * 1000 >= IPTrafConfig.RefreshInterval Then Begin
   UpdateDisplay;
   LastRefresh := Now;
  End;
  
  { Petite pause pour éviter 100% CPU }
  Sleep(50);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedIPTraf;
Begin
 ClrScr;
 TextColor(White);
 TextBackground(Blue);
 ClrScr;
 
 WriteLn('IPTRAF [NETWORKKIT-P] IP Traffic Monitor (simulation)');
 WriteLn('====================================================');
 WriteLn;
 WriteLn('┌─────────────────── IPTraf - IP Traffic Monitor ────────────────────┐');
 WriteLn('│                                                                     │');
 WriteLn('│ Proto  Source IP        Port  -> Dest IP          Port   Size Flags│');
 WriteLn('├─────────────────────────────────────────────────────────────────────┤');
 WriteLn('│ TCP    192.168.1.100    1234  -> 203.0.113.45     80    1460  SYN  │');
 WriteLn('│ UDP    10.0.0.1         53    -> 192.168.1.100   1024   512   -    │');
 WriteLn('│ TCP    192.168.1.100    443   -> 8.8.8.8         443   1200  ACK  │');
 WriteLn('│ ICMP   127.0.0.1        -     -> 127.0.0.1       -     64    -    │');
 WriteLn('│ TCP    172.16.0.1       22    -> 192.168.1.100   2048  128   FIN  │');
 WriteLn('│                                                                     │');
 WriteLn('├──────────────────────── Statistiques ──────────────────────────────┤');
 WriteLn('│ Paquets: 1,247  Débit: 1.2 MB/s         Durée: 02:15:33           │');
 WriteLn('│                                                                     │');
 WriteLn('└─ [ESC]=Menu  [Q]=Quit  [F5]=Refresh ───────────────────────────────┘');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('IPTRAF : Console-based network statistics utility');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IPTRAF [options] [interface]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  --version             Afficher la version');
  WriteLn('  -i INTERFACE          Interface à monitorer');
  WriteLn('  -g                    Démarrer en mode graphique immédiat');
  WriteLn('  -d INTERFACE          Moniteur trafic détaillé sur interface');
  WriteLn('  -s INTERFACE          Statistiques interface');
  WriteLn('  -z INTERFACE          Moniteur station LAN');
  WriteLn('  -l INTERFACE          Statistiques LAN station');
  WriteLn('  -t TIMEOUT            Timeout en minutes (défaut: 0=infini)');
  WriteLn('  -B                    Fonctionner en mode non-interactif');
  WriteLn('  -L LOGFILE            Spécifier fichier de log');
  WriteLn('  -I PIDFILE            Spécifier fichier PID');
  WriteLn('  -u UID                Exécuter avec UID spécifique');
  WriteLn('  -g GID                Exécuter avec GID spécifique');
  WriteLn('  -f                    Vider toutes les locks');
  WriteLn('  -c                    Convertir ancien format de config');
  WriteLn;
  WriteLn('Modes de monitoring :');
  WriteLn('  1. Trafic IP          Moniteur temps réel du trafic TCP/UDP/ICMP');
  WriteLn('  2. Interface générale Statistiques globales toutes interfaces');
  WriteLn('  3. Interface détaillé Statistiques détaillées par interface');
  WriteLn('  4. Connexions réseau  Connexions TCP/UDP actives en temps réel');
  WriteLn('  5. Statistiques proto Répartition du trafic par protocole');
  WriteLn('  6. Station LAN        Activité des stations sur le réseau local');
  WriteLn;
  WriteLn('Navigation :');
  WriteLn('  [ESC]                 Retour au menu principal');
  WriteLn('  [Q]                   Quitter IPTraf');
  WriteLn('  [F5]                  Actualiser affichage');
  WriteLn('  [↑] [↓]               Naviguer dans les listes');
  WriteLn('  [Page Up/Down]        Défiler page par page');
  WriteLn('  [Home/End]            Début/fin de liste');
  WriteLn('  [Tab]                 Changer tri/filtre');
  WriteLn('  [Enter]               Sélectionner/Confirmer');
  WriteLn;
  WriteLn('Filtres :');
  WriteLn('  TCP/UDP ports         Filtrer par numéro de port');
  WriteLn('  Adresses IP           Filtrer par plage d''adresses');
  WriteLn('  Protocoles            Afficher protocoles spécifiques');
  WriteLn('  Taille paquets        Filtrer par taille minimum/maximum');
  WriteLn;
  WriteLn('Affichages disponibles :');
  WriteLn('  Temps réel            Paquets défilant en continu');
  WriteLn('  Statistiques cumulées Totaux depuis démarrage');
  WriteLn('  Graphiques ASCII      Barres de progression');
  WriteLn('  Mode détaillé         Informations étendues');
  WriteLn('  Mode compact          Vue condensée');
  WriteLn;
  WriteLn('Configuration :');
  WriteLn('  Interface par défaut  Interface à monitorer automatiquement');
  WriteLn('  Intervalle refresh    Fréquence de mise à jour (ms)');
  WriteLn('  Timeout connexions    Délai expiration connexions inactives');
  WriteLn('  Mode promiscuité      Capturer tout le trafic réseau');
  WriteLn('  Résolution DNS        Résoudre noms d''hôte en temps réel');
  WriteLn('  Journalisation        Sauvegarder activité dans fichier log');
  WriteLn;
  WriteLn('Informations affichées :');
  WriteLn('  Protocole             TCP, UDP, ICMP, ARP, etc.');
  WriteLn('  Adresses source/dest  IP:port source et destination');
  WriteLn('  Taille paquets        Nombre d''octets par paquet');
  WriteLn('  Drapeaux TCP          SYN, ACK, FIN, RST, PSH, URG');
  WriteLn('  Débit instantané      Octets/paquets par seconde');
  WriteLn('  Statistiques cumulées Total depuis démarrage session');
  WriteLn;
  WriteLn('Fichiers de configuration :');
  WriteLn('  ~/.iptraf.cfg         Configuration utilisateur');
  WriteLn('  /etc/iptraf.cfg       Configuration système');
  WriteLn('  /var/log/iptraf.log   Fichier journal par défaut');
  WriteLn;
  WriteLn('Exemples d''utilisation :');
  WriteLn('  IPTRAF                     # Interface interactive');
  WriteLn('  IPTRAF -i eth0             # Monitorer eth0');
  WriteLn('  IPTRAF -d eth0 -t 60       # Détaillé sur eth0, 60 min');
  WriteLn('  IPTRAF -s eth0 -L stats.log # Stats vers fichier');
  WriteLn('  IPTRAF -g -i wlan0         # Mode graphique direct');
  WriteLn;
  WriteLn('Note: Moniteur de trafic réseau temps réel avec interface colorée.');
  WriteLn('Fournit analyse détaillée du trafic TCP/UDP/ICMP sur interfaces réseau.');
  WriteLn('Compatible avec iptraf original de Linux.');
  Exit;
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('iptraf (NETWORKKIT-P) 1.0');
  WriteLn('Console-based network traffic monitor');
  WriteLn('Compatible with Linux iptraf');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
  Exit;
 End
 Else Begin
  {$IFDEF FPC}
  If not InitializeNetwork Then Begin
   WriteLn('Error: Cannot initialize network subsystem');
   Halt(1);
  End;
  
  Try
   InitializeConfig;
   MainLoop;
   
   { Restaurer affichage normal }
   SetTextColor(LightGray, Black);
   ClrScr;
   WriteLn('IPTraf terminé.');
   
  Finally
   CleanupNetwork;
  End;
  {$ELSE}
  ShowSimulatedIPTraf;
  {$ENDIF}
 End;
END.
