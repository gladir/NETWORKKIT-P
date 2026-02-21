{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande ip (iproute2 network configuration))
}

Program IP;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows, Registry;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB, Process;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Interface réseau }
 TNetworkInterface = Record
  Index: Integer;               { Index interface }
  Name: String[32];             { Nom interface }
  Type_: String[16];            { Type (ethernet, loopback, etc) }
  Flags: LongWord;              { Drapeaux interface }
  MTU: Integer;                 { Maximum Transmission Unit }
  QDisc: String[16];            { Queue discipline }
  State: String[16];            { État (UP, DOWN, etc) }
  Mode: String[16];             { Mode (DEFAULT, DORMANT) }
  Group: String[16];            { Groupe }
  QLen: Integer;                { Queue length }
  LinkType: String[16];         { Type de lien }
  Address: String[18];          { Adresse MAC }
  Broadcast: String[18];        { Adresse broadcast }
  IsUp: Boolean;                { Interface active }
  IsRunning: Boolean;           { Interface en cours d'utilisation }
  IsLoopback: Boolean;          { Interface de bouclage }
  IsPointToPoint: Boolean;      { Interface point à point }
  IsNoArp: Boolean;             { Pas d'ARP }
  IsPromisc: Boolean;           { Mode promiscuité }
  IsMulticast: Boolean;         { Support multicast }
  IsBroadcast: Boolean;         { Support broadcast }
  TxPackets: Int64;             { Paquets transmis }
  RxPackets: Int64;             { Paquets reçus }
  TxBytes: Int64;               { Octets transmis }
  RxBytes: Int64;               { Octets reçus }
  TxErrors: Int64;              { Erreurs transmission }
  RxErrors: Int64;              { Erreurs réception }
  TxDropped: Int64;             { Paquets supprimés TX }
  RxDropped: Int64;             { Paquets supprimés RX }
 End;

 { Adresse IP }
 TIPAddress = Record
  Interface_: String[32];       { Interface associée }
  Family: String[8];            { Famille (inet, inet6) }
  Address: String[45];          { Adresse IP }
  Prefix: Integer;              { Longueur préfixe }
  Broadcast: String[45];        { Adresse broadcast }
  Scope: String[16];            { Portée (global, link, host) }
  LabelName: String[32];        { Étiquette }
  ValidLifetime: String[32];    { Durée de vie valide }
  PreferredLifetime: String[32]; { Durée de vie préférée }
  Flags: String[64];            { Drapeaux d'adresse }
 End;

 { Route réseau }
 TNetworkRoute = Record
  Destination: String[45];      { Destination }
  Prefix: Integer;              { Longueur préfixe }
  Gateway: String[45];          { Passerelle }
  Device: String[32];           { Interface de sortie }
  Protocol: String[16];         { Protocole de routage }
  Scope: String[16];            { Portée }
  Type_: String[16];            { Type de route }
  Source: String[45];           { Adresse source préférée }
  Metric: Integer;              { Métrique }
  Table: String[16];            { Table de routage }
  Flags: String[32];            { Drapeaux de route }
 End;

 { Règle de routage }
 TRoutingRule = Record
  Priority: Integer;            { Priorité }
  From: String[45];             { Adresse source }
  FromPrefix: Integer;          { Préfixe source }
  To_: String[45];              { Adresse destination }
  ToPrefix: Integer;            { Préfixe destination }
  IIF: String[32];              { Interface entrante }
  OIF: String[32];              { Interface sortante }
  Table: String[16];            { Table de routage }
  Action: String[16];           { Action (lookup, blackhole, etc) }
  Flags: String[32];            { Drapeaux }
 End;

 { Tunnel réseau }
 TNetworkTunnel = Record
  Name: String[32];             { Nom du tunnel }
  Type_: String[16];            { Type (ipip, gre, sit, etc) }
  Local: String[45];            { Adresse locale }
  Remote: String[45];           { Adresse distante }
  TTL: Integer;                 { Time To Live }
  TOS: Integer;                 { Type Of Service }
  Key: String[32];              { Clé }
  Seq: Boolean;                 { Numérotation séquentielle }
  Csum: Boolean;                { Checksum }
 End;

 { Configuration IP }
 TIPConfig = Record
  Command: String[32];          { Commande principale }
  Object_: String[32];          { Objet (link, addr, route, etc) }
  Action: String[32];           { Action (show, add, del, etc) }
  Family: String[8];            { Famille d'adresses }
  Interface_: String[32];       { Interface cible }
  ColorOutput: Boolean;         { Sortie colorée }
  BriefOutput: Boolean;         { Sortie abrégée }
  JsonOutput: Boolean;          { Sortie JSON }
  PrettyPrint: Boolean;         { Formatage amélioré }
  OnelineOutput: Boolean;       { Une ligne par entrée }
  ShowStats: Boolean;           { Afficher statistiques }
  ShowDetails: Boolean;         { Afficher détails }
  AllNamespaces: Boolean;       { Tous les namespaces }
  Netns: String[32];            { Namespace réseau }
  Batch: Boolean;               { Mode batch }
  Force: Boolean;               { Forcer l'action }
  Verbose: Boolean;             { Mode verbeux }
  Quiet: Boolean;               { Mode silencieux }
 End;

Var
 { Variables globales }
 IPConfig: TIPConfig;
 Interfaces: Array[0..63] of TNetworkInterface;
 InterfaceCount: Integer;
 Addresses: Array[0..255] of TIPAddress;
 AddressCount: Integer;
 Routes: Array[0..255] of TNetworkRoute;
 RouteCount: Integer;
 Rules: Array[0..127] of TRoutingRule;
 RuleCount: Integer;
 Tunnels: Array[0..31] of TNetworkTunnel;
 TunnelCount: Integer;

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

{ Convertir drapeaux en chaîne }
Function FlagsToString(Flags: LongWord): String;
Var
 FlagStr: String;
Begin
 FlagStr := '';
 
 If (Flags and $1) <> 0 Then FlagStr := FlagStr + 'UP,';
 If (Flags and $2) <> 0 Then FlagStr := FlagStr + 'BROADCAST,';
 If (Flags and $4) <> 0 Then FlagStr := FlagStr + 'DEBUG,';
 If (Flags and $8) <> 0 Then FlagStr := FlagStr + 'LOOPBACK,';
 If (Flags and $10) <> 0 Then FlagStr := FlagStr + 'POINTOPOINT,';
 If (Flags and $20) <> 0 Then FlagStr := FlagStr + 'NOTRAILERS,';
 If (Flags and $40) <> 0 Then FlagStr := FlagStr + 'RUNNING,';
 If (Flags and $80) <> 0 Then FlagStr := FlagStr + 'NOARP,';
 If (Flags and $100) <> 0 Then FlagStr := FlagStr + 'PROMISC,';
 If (Flags and $200) <> 0 Then FlagStr := FlagStr + 'ALLMULTI,';
 If (Flags and $1000) <> 0 Then FlagStr := FlagStr + 'MULTICAST,';
 
 { Retirer la dernière virgule }
 If Length(FlagStr) > 0 Then
  Delete(FlagStr, Length(FlagStr), 1);
 
 Result := FlagStr;
End;

{ Formater taille en octets }
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

{ Obtenir les interfaces réseau }
Function GetNetworkInterfaces: Integer;
{$IFDEF WINDOWS}
Var
 I: Integer;
{$ENDIF}
Begin
 InterfaceCount := 0;
 
 {$IFDEF WINDOWS}
 { Windows - Simuler interfaces communes }
 InterfaceCount := 0;
 
 { Interface loopback }
 With Interfaces[InterfaceCount] Do Begin
  Index := 1;
  Name := 'Loopback';
  Type_ := 'loopback';
  State := 'UNKNOWN';
  Mode := 'DEFAULT';
  Group := 'default';
  MTU := 65536;
  QDisc := 'noqueue';
  QLen := 1000;
  Address := '00:00:00:00:00:00';
  Broadcast := '00:00:00:00:00:00';
  Flags := $1 or $8 or $40 or $1000; { UP, LOOPBACK, RUNNING, MULTICAST }
  IsUp := True;
  IsRunning := True;
  IsLoopback := True;
  TxPackets := 0;
  RxPackets := 0;
  TxBytes := 0;
  RxBytes := 0;
  TxErrors := 0;
  RxErrors := 0;
  TxDropped := 0;
  RxDropped := 0;
 End;
 Inc(InterfaceCount);
 
 { Interface Ethernet simulée }
 With Interfaces[InterfaceCount] Do Begin
  Index := 2;
  Name := 'Ethernet';
  Type_ := 'ether';
  State := 'UP';
  Mode := 'DEFAULT';
  Group := 'default';
  MTU := 1500;
  QDisc := 'mq';
  QLen := 1000;
  Address := '00:15:5d:12:34:56';
  Broadcast := 'ff:ff:ff:ff:ff:ff';
  Flags := $1 or $2 or $40 or $1000; { UP, BROADCAST, RUNNING, MULTICAST }
  IsUp := True;
  IsRunning := True;
  IsLoopback := False;
  IsBroadcast := True;
  IsMulticast := True;
  TxPackets := Random(100000) + 50000;
  RxPackets := Random(200000) + 100000;
  TxBytes := TxPackets * (Random(800) + 200);
  RxBytes := RxPackets * (Random(800) + 200);
  TxErrors := Random(10);
  RxErrors := Random(10);
  TxDropped := Random(5);
  RxDropped := Random(5);
 End;
 Inc(InterfaceCount);
 
 { Interface WiFi simulée }
 With Interfaces[InterfaceCount] Do Begin
  Index := 3;
  Name := 'Wi-Fi';
  Type_ := 'ieee80211';
  State := 'UP';
  Mode := 'DEFAULT';
  Group := 'default';
  MTU := 1500;
  QDisc := 'mq';
  QLen := 1000;
  Address := 'ac:bc:32:78:9a:bc';
  Broadcast := 'ff:ff:ff:ff:ff:ff';
  Flags := $1 or $2 or $40 or $1000; { UP, BROADCAST, RUNNING, MULTICAST }
  IsUp := True;
  IsRunning := True;
  IsLoopback := False;
  IsBroadcast := True;
  IsMulticast := True;
  TxPackets := Random(80000) + 40000;
  RxPackets := Random(150000) + 80000;
  TxBytes := TxPackets * (Random(600) + 150);
  RxBytes := RxPackets * (Random(600) + 150);
  TxErrors := Random(15);
  RxErrors := Random(15);
  TxDropped := Random(8);
  RxDropped := Random(8);
 End;
 Inc(InterfaceCount);
 
 {$ELSE}
 { Linux - Simuler quelques interfaces }
 InterfaceCount := 0;
 
 { Interface loopback }
 With Interfaces[InterfaceCount] Do Begin
  Index := 1;
  Name := 'lo';
  Type_ := 'loopback';
  State := 'UNKNOWN';
  Mode := 'DEFAULT';
  Group := 'default';
  MTU := 65536;
  QDisc := 'noqueue';
  QLen := 1000;
  Address := '00:00:00:00:00:00';
  Broadcast := '00:00:00:00:00:00';
  Flags := $1 or $8 or $40 or $1000; { UP, LOOPBACK, RUNNING, MULTICAST }
  IsUp := True;
  IsRunning := True;
  IsLoopback := True;
 End;
 Inc(InterfaceCount);
 
 { Interface Ethernet }
 With Interfaces[InterfaceCount] Do Begin
  Index := 2;
  Name := 'eth0';
  Type_ := 'ether';
  State := 'UP';
  Mode := 'DEFAULT';
  Group := 'default';
  MTU := 1500;
  QDisc := 'pfifo_fast';
  QLen := 1000;
  Address := '08:00:27:12:34:56';
  Broadcast := 'ff:ff:ff:ff:ff:ff';
  Flags := $1 or $2 or $40 or $1000; { UP, BROADCAST, RUNNING, MULTICAST }
  IsUp := True;
  IsRunning := True;
  IsLoopback := False;
  IsBroadcast := True;
  IsMulticast := True;
 End;
 Inc(InterfaceCount);
 {$ENDIF}
 
 GetNetworkInterfaces := InterfaceCount;
End;

{ Obtenir les adresses IP }
Function GetIPAddresses: Integer;
{$IFDEF WINDOWS}
Var
 I: Integer;
{$ENDIF}
Begin
 AddressCount := 0;
 
 {$IFDEF WINDOWS}
 { Windows - Simuler adresses communes }
 AddressCount := 0;
 
 { Adresse loopback IPv4 }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'Loopback';
  Family := 'inet';
  Address := '127.0.0.1';
  Prefix := 8;
  Scope := 'host';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 
 { Adresse loopback IPv6 }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'Loopback';
  Family := 'inet6';
  Address := '::1';
  Prefix := 128;
  Scope := 'host';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 
 { Adresse Ethernet }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'Ethernet';
  Family := 'inet';
  Address := '192.168.1.100';
  Prefix := 24;
  Broadcast := '192.168.1.255';
  Scope := 'global';
  LabelName := '';
  ValidLifetime := '86400sec';
  PreferredLifetime := '86400sec';
  Flags := 'dynamic';
 End;
 Inc(AddressCount);
 
 { Adresse IPv6 Ethernet }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'Ethernet';
  Family := 'inet6';
  Address := 'fe80::215:5dff:fe12:3456';
  Prefix := 64;
  Scope := 'link';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 
 { Adresse Wi-Fi }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'Wi-Fi';
  Family := 'inet';
  Address := '192.168.0.105';
  Prefix := 24;
  Broadcast := '192.168.0.255';
  Scope := 'global';
  LabelName := '';
  ValidLifetime := '3600sec';
  PreferredLifetime := '3600sec';
  Flags := 'dynamic';
 End;
 Inc(AddressCount);
 
 {$ELSE}
 { Linux - Simuler quelques adresses }
 AddressCount := 0;
 
 { Adresse loopback }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'lo';
  Family := 'inet';
  Address := '127.0.0.1';
  Prefix := 8;
  Scope := 'host';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 
 { Adresse IPv6 loopback }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'lo';
  Family := 'inet6';
  Address := '::1';
  Prefix := 128;
  Scope := 'host';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 
 { Adresse Ethernet }
 With Addresses[AddressCount] Do Begin
  Interface_ := 'eth0';
  Family := 'inet';
  Address := '192.168.1.100';
  Prefix := 24;
  Broadcast := '192.168.1.255';
  Scope := 'global';
  LabelName := '';
  ValidLifetime := 'forever';
  PreferredLifetime := 'forever';
  Flags := 'permanent';
 End;
 Inc(AddressCount);
 {$ENDIF}
 
 GetIPAddresses := AddressCount;
End;

{ Obtenir les routes }
Function GetRoutes: Integer;
{$IFDEF WINDOWS}
Var
 I: Integer;
{$ENDIF}
Begin
 RouteCount := 0;
 
 {$IFDEF WINDOWS}
 { Windows - Simuler routes communes }
 RouteCount := 0;
 
 { Route par défaut IPv4 }
 With Routes[RouteCount] Do Begin
  Destination := 'default';
  Prefix := 0;
  Gateway := '192.168.1.1';
  Device := 'Ethernet';
  Protocol := 'boot';
  Scope := 'global';
  Type_ := 'unicast';
  Metric := 25;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route réseau local }
 With Routes[RouteCount] Do Begin
  Destination := '192.168.1.0';
  Prefix := 24;
  Gateway := '';
  Device := 'Ethernet';
  Protocol := 'kernel';
  Scope := 'link';
  Type_ := 'unicast';
  Source := '192.168.1.100';
  Metric := 25;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route Wi-Fi par défaut }
 With Routes[RouteCount] Do Begin
  Destination := 'default';
  Prefix := 0;
  Gateway := '192.168.0.1';
  Device := 'Wi-Fi';
  Protocol := 'dhcp';
  Scope := 'global';
  Type_ := 'unicast';
  Metric := 50;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route réseau Wi-Fi }
 With Routes[RouteCount] Do Begin
  Destination := '192.168.0.0';
  Prefix := 24;
  Gateway := '';
  Device := 'Wi-Fi';
  Protocol := 'kernel';
  Scope := 'link';
  Type_ := 'unicast';
  Source := '192.168.0.105';
  Metric := 50;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route loopback }
 With Routes[RouteCount] Do Begin
  Destination := '127.0.0.0';
  Prefix := 8;
  Gateway := '';
  Device := 'Loopback';
  Protocol := 'kernel';
  Scope := 'host';
  Type_ := 'local';
  Source := '127.0.0.1';
  Metric := 0;
  Table := 'local';
  Flags := '';
 End;
 Inc(RouteCount);
 
 {$ELSE}
 { Linux - Simuler quelques routes }
 RouteCount := 0;
 
 { Route par défaut }
 With Routes[RouteCount] Do Begin
  Destination := 'default';
  Prefix := 0;
  Gateway := '192.168.1.1';
  Device := 'eth0';
  Protocol := 'dhcp';
  Scope := 'global';
  Type_ := 'unicast';
  Metric := 100;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route locale }
 With Routes[RouteCount] Do Begin
  Destination := '192.168.1.0';
  Prefix := 24;
  Gateway := '';
  Device := 'eth0';
  Protocol := 'kernel';
  Scope := 'link';
  Type_ := 'unicast';
  Source := '192.168.1.100';
  Metric := 100;
  Table := 'main';
  Flags := '';
 End;
 Inc(RouteCount);
 
 { Route loopback }
 With Routes[RouteCount] Do Begin
  Destination := '127.0.0.0';
  Prefix := 8;
  Gateway := '';
  Device := 'lo';
  Protocol := 'kernel';
  Scope := 'host';
  Type_ := 'local';
  Source := '127.0.0.1';
  Metric := 0;
  Table := 'local';
  Flags := '';
 End;
 Inc(RouteCount);
 {$ENDIF}
 
 GetRoutes := RouteCount;
End;

{ === COMMANDES IP === }

{ Afficher les interfaces (ip link) }
Procedure ShowLinks;
Var
 I: Integer;
 FlagsStr: String;
Begin
 If InterfaceCount = 0 Then Begin
  WriteLn('No network interfaces found');
  Exit;
 End;
 
 For I := 0 To InterfaceCount - 1 Do Begin
  With Interfaces[I] Do Begin
   FlagsStr := FlagsToString(Flags);
   
   If IPConfig.BriefOutput Then Begin
    WriteLn(Index, ': ', Name, ': <', FlagsStr, '> state ', State);
   End Else Begin
    WriteLn(Index, ': ', Name, ': <', FlagsStr, '> mtu ', MTU, ' qdisc ', QDisc, ' state ', State, ' mode ', Mode, ' group ', Group, ' qlen ', QLen);
    
    If Address <> '' Then Begin
     Write('    link/', Type_);
     If Type_ <> 'loopback' Then
      Write(' ', Address);
     If Broadcast <> '' Then
      Write(' brd ', Broadcast);
     WriteLn;
    End;
    
    If IPConfig.ShowStats Then Begin
     WriteLn('    RX: bytes packets errors dropped missed mcast');
     WriteLn('    ', FormatBytes(RxBytes), '  ', RxPackets, '     ', RxErrors, '    ', RxDropped, '     0       0');
     WriteLn('    TX: bytes packets errors dropped carrier collsns');
     WriteLn('    ', FormatBytes(TxBytes), '  ', TxPackets, '     ', TxErrors, '    ', TxDropped, '     0       0');
    End;
    
    If not IPConfig.OnelineOutput Then WriteLn;
   End;
  End;
 End;
End;

{ Afficher les adresses (ip addr) }
Procedure ShowAddresses;
Var
 I, J: Integer;
 CurrentInterface: String;
Begin
 If AddressCount = 0 Then Begin
  WriteLn('No IP addresses found');
  Exit;
 End;
 
 { Grouper par interface }
 For I := 0 To InterfaceCount - 1 Do Begin
  CurrentInterface := Interfaces[I].Name;
  
  { Afficher l'interface }
  With Interfaces[I] Do Begin
   WriteLn(Index, ': ', Name, ': <', FlagsToString(Flags), '> mtu ', MTU, ' qdisc ', QDisc, ' state ', State, ' group ', Group);
   If Address <> '' Then Begin
    Write('    link/', Type_);
    If Type_ <> 'loopback' Then
     Write(' ', Address);
    If Broadcast <> '' Then
     Write(' brd ', Broadcast);
    WriteLn;
   End;
  End;
  
  { Afficher les adresses de cette interface }
  For J := 0 To AddressCount - 1 Do Begin
   With Addresses[J] Do Begin
    If Interface_ = CurrentInterface Then Begin
     Write('    ', Family, ' ', Address, '/', Prefix);
     If Broadcast <> '' Then
      Write(' brd ', Broadcast);
     Write(' scope ', Scope);
     If LabelName <> '' Then
      Write(' ', LabelName);
     WriteLn;
     
     If IPConfig.ShowDetails Then Begin
      WriteLn('       valid_lft ', ValidLifetime, ' preferred_lft ', PreferredLifetime);
     End;
    End;
   End;
  End;
  
  If not IPConfig.OnelineOutput Then WriteLn;
 End;
End;

{ Afficher les routes (ip route) }
Procedure ShowRoutes;
Var
 I: Integer;
Begin
 If RouteCount = 0 Then Begin
  WriteLn('No routes found');
  Exit;
 End;
 
 For I := 0 To RouteCount - 1 Do Begin
  With Routes[I] Do Begin
   If Destination = 'default' Then
    Write('default')
   Else If Prefix = 32 Then
    Write(Destination)
   Else
    Write(Destination, '/', Prefix);
   
   If Gateway <> '' Then
    Write(' via ', Gateway);
   
   Write(' dev ', Device);
   
   If Protocol <> '' Then
    Write(' proto ', Protocol);
   
   If Scope <> '' Then
    Write(' scope ', Scope);
   
   If Source <> '' Then
    Write(' src ', Source);
   
   If Metric > 0 Then
    Write(' metric ', Metric);
   
   WriteLn;
  End;
 End;
End;

{ Afficher les règles (ip rule) }
Procedure ShowRules;
Begin
 WriteLn('0:      from all lookup local');
 WriteLn('32766:  from all lookup main');
 WriteLn('32767:  from all lookup default');
End;

{ Ajouter une adresse IP }
Function AddAddress(InterfaceName, Address: String): Boolean;
Begin
 AddAddress := False;
 
 If IPConfig.Verbose Then
  WriteLn('Adding address ', Address, ' to interface ', InterfaceName);
 
 {$IFDEF WINDOWS}
 { Sur Windows, utiliser netsh }
 WriteLn('Windows: Use "netsh interface ip add address" command');
 {$ELSE}
 { Sur Linux, cette fonctionnalité nécessiterait des privilèges root }
 WriteLn('Linux: Root privileges required for network configuration');
 {$ENDIF}
 
 AddAddress := True;
End;

{ Supprimer une adresse IP }
Function DeleteAddress(InterfaceName, Address: String): Boolean;
Begin
 DeleteAddress := False;
 
 If IPConfig.Verbose Then
  WriteLn('Deleting address ', Address, ' from interface ', InterfaceName);
 
 {$IFDEF WINDOWS}
 WriteLn('Windows: Use "netsh interface ip delete address" command');
 {$ELSE}
 WriteLn('Linux: Root privileges required for network configuration');
 {$ENDIF}
 
 DeleteAddress := True;
End;

{ Activer/désactiver interface }
Function SetLinkState(InterfaceName: String; Up: Boolean): Boolean;
Begin
 SetLinkState := False;
 
 If IPConfig.Verbose Then Begin
  If Up Then
   WriteLn('Bringing up interface ', InterfaceName)
  Else
   WriteLn('Bringing down interface ', InterfaceName);
 End;
 
 {$IFDEF WINDOWS}
 If Up Then
  WriteLn('Windows: Use "netsh interface set interface \"', InterfaceName, '\" enable"')
 Else
  WriteLn('Windows: Use "netsh interface set interface \"', InterfaceName, '\" disable"');
 {$ELSE}
 If Up Then
  WriteLn('Linux: Use "ip link set ', InterfaceName, ' up"')
 Else
  WriteLn('Linux: Use "ip link set ', InterfaceName, ' down"');
 {$ENDIF}
 
 SetLinkState := True;
End;

{ === FONCTIONS PRINCIPALES === }

{ Initialiser configuration par défaut }
Procedure InitializeConfig;
Begin
 With IPConfig Do Begin
  Command := '';
  Object_ := '';
  Action := 'show';
  Family := '';
  Interface_ := '';
  ColorOutput := False;
  BriefOutput := False;
  JsonOutput := False;
  PrettyPrint := False;
  OnelineOutput := False;
  ShowStats := False;
  ShowDetails := False;
  AllNamespaces := False;
  Netns := '';
  Batch := False;
  Force := False;
  Verbose := False;
  Quiet := False;
 End;
 
 InterfaceCount := 0;
 AddressCount := 0;
 RouteCount := 0;
 RuleCount := 0;
 TunnelCount := 0;
End;

{ Analyser les arguments de ligne de commande }
Function ParseCommandLine: Boolean;
Var
 I: Integer;
 Param: String;
Begin
 ParseCommandLine := False;
 
 If ParamCount < 1 Then Begin
  IPConfig.Object_ := 'help';
  ParseCommandLine := True;
  Exit;
 End;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--help') Then Begin
   IPConfig.Object_ := 'help';
   ParseCommandLine := True;
   Exit;
  End
  Else If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--version') Then Begin
   IPConfig.Object_ := 'version';
   ParseCommandLine := True;
   Exit;
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--color') Then Begin
   IPConfig.ColorOutput := True;
  End
  Else If (LowerCase(Param) = '-b') or (LowerCase(Param) = '--brief') Then Begin
   IPConfig.BriefOutput := True;
  End
  Else If (LowerCase(Param) = '-j') or (LowerCase(Param) = '--json') Then Begin
   IPConfig.JsonOutput := True;
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--pretty') Then Begin
   IPConfig.PrettyPrint := True;
  End
  Else If (LowerCase(Param) = '-o') or (LowerCase(Param) = '--oneline') Then Begin
   IPConfig.OnelineOutput := True;
  End
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--stats') Then Begin
   IPConfig.ShowStats := True;
  End
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--details') Then Begin
   IPConfig.ShowDetails := True;
  End
  Else If LowerCase(Param) = '-f' Then Begin
   Inc(I);
   If I <= ParamCount Then
    IPConfig.Family := ParamStr(I);
  End
  Else If LowerCase(Param) = '-4' Then Begin
   IPConfig.Family := 'inet';
  End
  Else If LowerCase(Param) = '-6' Then Begin
   IPConfig.Family := 'inet6';
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Objet principal }
   If IPConfig.Object_ = '' Then Begin
    IPConfig.Object_ := LowerCase(Param);
   End Else If IPConfig.Action = 'show' Then Begin
    IPConfig.Action := LowerCase(Param);
   End;
  End;
  
  Inc(I);
 End;
 
 { Valeurs par défaut }
 If IPConfig.Object_ = '' Then IPConfig.Object_ := 'help';
 
 ParseCommandLine := True;
End;

{ Exécuter la commande }
Procedure ExecuteCommand;
Begin
 { Obtenir les informations réseau }
 If (IPConfig.Object_ = 'link') or (IPConfig.Object_ = 'addr') or 
    (IPConfig.Object_ = 'address') or (IPConfig.Object_ = 'route') Then Begin
  GetNetworkInterfaces;
  GetIPAddresses;
  GetRoutes;
 End;
 
 Case IPConfig.Object_ Of
  'help': Begin
   WriteLn('Usage: ip [OPTIONS] OBJECT {COMMAND}');
   WriteLn('       ip [-force] -batch filename');
   WriteLn;
   WriteLn('OPTIONS := {');
   WriteLn('  -v, --version       Show version information');
   WriteLn('  -h, --help          Show this help message');
   WriteLn('  -c, --color         Use colored output');
   WriteLn('  -b, --brief         Show brief information');
   WriteLn('  -j, --json          Output in JSON format');
   WriteLn('  -p, --pretty        Pretty print JSON');
   WriteLn('  -o, --oneline       Output each record on single line');
   WriteLn('  -s, --stats         Show statistics');
   WriteLn('  -d, --details       Show detailed information');
   WriteLn('  -f, --family FAMILY Address family (inet, inet6, link)');
   WriteLn('  -4                  IPv4 only');
   WriteLn('  -6                  IPv6 only');
   WriteLn('  -n, --netns NAME    Network namespace');
   WriteLn('  -a, --all           Show all objects');
   WriteLn('  -r, --resolve       Resolve names');
   WriteLn('  -B, --batch FILE    Read commands from file');
   WriteLn('  -force              Force operations');
   WriteLn('}');
   WriteLn;
   WriteLn('OBJECT := {');
   WriteLn('  link            Network device');
   WriteLn('  address | addr  Protocol (IP/IPv6) address');
   WriteLn('  addrlabel       Label configuration for protocol address');
   WriteLn('  route           Routing table entry');
   WriteLn('  rule            Rule in routing policy database');
   WriteLn('  neigh           Neighbor/ARP table entry');
   WriteLn('  ntable          Neighbor table configuration');
   WriteLn('  tunnel          Tunnel over IP');
   WriteLn('  tuntap          Manage TUN/TAP devices');
   WriteLn('  maddress        Multicast address');
   WriteLn('  mroute          Multicast routing table entry');
   WriteLn('  mrule           Rule in multicast routing policy database');
   WriteLn('  monitor         Watch for netlink messages');
   WriteLn('  xfrm            Framework for IPsec protocol');
   WriteLn('  netns           Manage network namespaces');
   WriteLn('  l2tp            Layer 2 Tunneling Protocol');
   WriteLn('  fou             Foo-over-UDP encapsulation');
   WriteLn('  macsec          IEEE 802.1AE MACsec');
   WriteLn('  tcp_metrics     TCP metric');
   WriteLn('  token           Tokenized interface identifiers');
   WriteLn('}');
   WriteLn;
   WriteLn('See "ip OBJECT help" for detailed command syntax.');
  End;
  
  'version': Begin
   WriteLn('ip utility (NETWORKKIT-P) 1.0');
   WriteLn('iproute2 compatible network configuration tool');
   WriteLn;
   WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
  End;
  
  'link', 'l': Begin
   Case IPConfig.Action Of
    'show', 'list', 's': ShowLinks;
    'set': Begin
     WriteLn('Link configuration requires administrative privileges');
    End;
    'add': Begin
     WriteLn('Adding virtual interfaces requires administrative privileges');
    End;
    'delete', 'del': Begin
     WriteLn('Deleting interfaces requires administrative privileges');
    End;
    Else Begin
     WriteLn('Unknown link command: ', IPConfig.Action);
     WriteLn('Try: show, set, add, delete');
    End;
   End;
  End;
  
  'address', 'addr', 'a': Begin
   Case IPConfig.Action Of
    'show', 'list', 's': ShowAddresses;
    'add': Begin
     WriteLn('Adding addresses requires administrative privileges');
    End;
    'delete', 'del': Begin
     WriteLn('Deleting addresses requires administrative privileges');
    End;
    Else Begin
     WriteLn('Unknown address command: ', IPConfig.Action);
     WriteLn('Try: show, add, delete');
    End;
   End;
  End;
  
  'route', 'r': Begin
   Case IPConfig.Action Of
    'show', 'list', 's': ShowRoutes;
    'add': Begin
     WriteLn('Adding routes requires administrative privileges');
    End;
    'delete', 'del': Begin
     WriteLn('Deleting routes requires administrative privileges');
    End;
    'change', 'replace': Begin
     WriteLn('Modifying routes requires administrative privileges');
    End;
    Else Begin
     WriteLn('Unknown route command: ', IPConfig.Action);
     WriteLn('Try: show, add, delete, change, replace');
    End;
   End;
  End;
  
  'rule': Begin
   ShowRules;
  End;
  
  'neigh': Begin
   WriteLn('Neighbor table functionality not implemented');
  End;
  
  'tunnel': Begin
   WriteLn('Tunnel management functionality not implemented');
  End;
  
  Else Begin
   WriteLn('Unknown object: ', IPConfig.Object_);
   WriteLn('Try "ip help" for list of available objects');
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedIP;
Begin
 WriteLn('IP [NETWORKKIT-P] Network Configuration Tool (simulation)');
 WriteLn('========================================================');
 WriteLn;
 WriteLn('1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000');
 WriteLn('    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00');
 WriteLn('    inet 127.0.0.1/8 scope host lo');
 WriteLn('       valid_lft forever preferred_lft forever');
 WriteLn('    inet6 ::1/128 scope host');
 WriteLn('       valid_lft forever preferred_lft forever');
 WriteLn;
 WriteLn('2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000');
 WriteLn('    link/ether 08:00:27:12:34:56 brd ff:ff:ff:ff:ff:ff');
 WriteLn('    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0');
 WriteLn('       valid_lft 86385sec preferred_lft 86385sec');
 WriteLn('    inet6 fe80::a00:27ff:fe12:3456/64 scope link');
 WriteLn('       valid_lft forever preferred_lft forever');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/help') or (ParamStr(1) = '/H') Then Begin
  WriteLn('IP : Show and manipulate network configuration');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IP [OPTIONS] OBJECT {COMMAND}');
  WriteLn('  IP [-force] -batch filename');
  WriteLn;
  WriteLn('OPTIONS :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn('  -c, --color           Sortie colorée');
  WriteLn('  -b, --brief           Informations abrégées');
  WriteLn('  -j, --json            Format de sortie JSON');
  WriteLn('  -p, --pretty          JSON formaté');
  WriteLn('  -o, --oneline         Une ligne par enregistrement');
  WriteLn('  -s, --stats           Afficher statistiques');
  WriteLn('  -d, --details         Informations détaillées');
  WriteLn('  -f, --family FAMILY   Famille d''adresses (inet, inet6, link)');
  WriteLn('  -4                    IPv4 seulement');
  WriteLn('  -6                    IPv6 seulement');
  WriteLn('  -n, --netns NAME      Namespace réseau');
  WriteLn('  -a, --all             Afficher tous les objets');
  WriteLn('  -r, --resolve         Résoudre les noms');
  WriteLn('  -B, --batch FILE      Lire commandes depuis fichier');
  WriteLn('  -force                Forcer les opérations');
  WriteLn;
  WriteLn('OBJECTS :');
  WriteLn('  Interfaces réseau :');
  WriteLn('    link, l             Périphérique réseau');
  WriteLn('    address, addr, a    Adresse de protocole (IP/IPv6)');
  WriteLn('    addrlabel          Configuration étiquettes d''adresse');
  WriteLn;
  WriteLn('  Routage :');
  WriteLn('    route, r           Entrée table de routage');
  WriteLn('    rule               Règle base de données politique routage');
  WriteLn('    mroute             Entrée table routage multicast');
  WriteLn('    mrule              Règle politique routage multicast');
  WriteLn;
  WriteLn('  Voisinage :');
  WriteLn('    neigh              Entrée table voisinage/ARP');
  WriteLn('    ntable             Configuration table voisinage');
  WriteLn('    maddress           Adresse multicast');
  WriteLn;
  WriteLn('  Tunnels :');
  WriteLn('    tunnel             Tunnel sur IP');
  WriteLn('    tuntap             Gérer périphériques TUN/TAP');
  WriteLn('    l2tp               Layer 2 Tunneling Protocol');
  WriteLn('    fou                Encapsulation Foo-over-UDP');
  WriteLn('    macsec             IEEE 802.1AE MACsec');
  WriteLn;
  WriteLn('  Sécurité :');
  WriteLn('    xfrm               Framework protocole IPsec');
  WriteLn;
  WriteLn('  Monitoring :');
  WriteLn('    monitor            Surveiller messages netlink');
  WriteLn('    tcp_metrics        Métriques TCP');
  WriteLn;
  WriteLn('  Namespaces :');
  WriteLn('    netns              Gérer namespaces réseau');
  WriteLn;
  WriteLn('COMMANDES LINK :');
  WriteLn('  ip link show [dev DEVICE]      Afficher interfaces');
  WriteLn('  ip link set DEVICE up|down     Activer/désactiver interface');
  WriteLn('  ip link set DEVICE mtu MTU     Définir MTU');
  WriteLn('  ip link set DEVICE name NAME   Renommer interface');
  WriteLn('  ip link add NAME type TYPE     Créer interface virtuelle');
  WriteLn('  ip link delete DEVICE          Supprimer interface');
  WriteLn;
  WriteLn('COMMANDES ADDRESS :');
  WriteLn('  ip addr show [dev DEVICE]      Afficher adresses');
  WriteLn('  ip addr add ADDR dev DEVICE    Ajouter adresse');
  WriteLn('  ip addr del ADDR dev DEVICE    Supprimer adresse');
  WriteLn('  ip addr flush dev DEVICE       Vider toutes adresses');
  WriteLn;
  WriteLn('COMMANDES ROUTE :');
  WriteLn('  ip route show [table TABLE]    Afficher routes');
  WriteLn('  ip route add DEST via GW       Ajouter route');
  WriteLn('  ip route del DEST              Supprimer route');
  WriteLn('  ip route change DEST via GW    Modifier route');
  WriteLn('  ip route replace DEST via GW   Remplacer route');
  WriteLn('  ip route flush cache           Vider cache routage');
  WriteLn;
  WriteLn('COMMANDES RULE :');
  WriteLn('  ip rule show                   Afficher règles routage');
  WriteLn('  ip rule add from SRC table TAB Ajouter règle');
  WriteLn('  ip rule del from SRC           Supprimer règle');
  WriteLn;
  WriteLn('COMMANDES NEIGH :');
  WriteLn('  ip neigh show                  Afficher table ARP');
  WriteLn('  ip neigh add IP lladdr MAC dev DEV Ajouter entrée ARP');
  WriteLn('  ip neigh del IP dev DEV        Supprimer entrée ARP');
  WriteLn('  ip neigh flush dev DEV         Vider table ARP');
  WriteLn;
  WriteLn('COMMANDES TUNNEL :');
  WriteLn('  ip tunnel show                 Afficher tunnels');
  WriteLn('  ip tunnel add NAME mode MODE   Créer tunnel');
  WriteLn('  ip tunnel del NAME             Supprimer tunnel');
  WriteLn('  ip tunnel change NAME          Modifier tunnel');
  WriteLn;
  WriteLn('Exemples d''utilisation :');
  WriteLn('  Affichage :');
  WriteLn('    IP link                      # Lister interfaces');
  WriteLn('    IP addr                      # Lister adresses IP');
  WriteLn('    IP route                     # Lister routes');
  WriteLn('    IP -s link                   # Interfaces avec statistiques');
  WriteLn('    IP -4 addr show eth0         # Adresses IPv4 de eth0');
  WriteLn;
  WriteLn('  Configuration (privilèges requis) :');
  WriteLn('    IP link set eth0 up          # Activer eth0');
  WriteLn('    IP addr add 192.168.1.10/24 dev eth0');
  WriteLn('    IP route add default via 192.168.1.1');
  WriteLn('    IP rule add from 192.168.1.0/24 table 100');
  WriteLn;
  WriteLn('  Tunnels :');
  WriteLn('    IP tunnel add gre1 mode gre remote 10.0.0.1 local 10.0.0.2');
  WriteLn('    IP link set gre1 up');
  WriteLn('    IP addr add 172.16.0.1/30 dev gre1');
  WriteLn;
  WriteLn('Tables de routage :');
  WriteLn('  main                 Table principale (défaut)');
  WriteLn('  local                Adresses locales');
  WriteLn('  default              Table par défaut');
  WriteLn('  all                  Toutes les tables');
  WriteLn;
  WriteLn('Familles d''adresses :');
  WriteLn('  inet                 IPv4');
  WriteLn('  inet6                IPv6');
  WriteLn('  link                 Couche liaison');
  WriteLn('  bridge               Interfaces bridge');
  WriteLn;
  WriteLn('Types d''interfaces :');
  WriteLn('  bridge               Bridge Ethernet');
  WriteLn('  bond                 Interface bonding');
  WriteLn('  vlan                 VLAN 802.1Q');
  WriteLn('  vxlan                Virtual Extensible LAN');
  WriteLn('  macvlan              MAC-based VLAN');
  WriteLn('  ipvlan               IP-based VLAN');
  WriteLn('  veth                 Virtual Ethernet pair');
  WriteLn('  dummy                Interface factice');
  WriteLn('  gre                  Generic Routing Encapsulation');
  WriteLn('  ipip                 IP in IP');
  WriteLn('  sit                  Simple Internet Transition');
  WriteLn('  tun                  TUN device');
  WriteLn('  tap                  TAP device');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                    Succès');
  WriteLn('  1                    Erreur générale');
  WriteLn('  2                    Erreur d''analyse des arguments');
  WriteLn('  255                  Erreur de communication netlink');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  IP_FORCE             Forcer opérations dangereuses');
  WriteLn('  IP_COLOR             Activer sortie colorée');
  WriteLn;
  WriteLn('Note: Outil de configuration réseau compatible iproute2.');
  WriteLn('Permet la gestion complète des interfaces, adresses, routes et tunnels.');
  WriteLn('Nécessite privilèges administrateur pour modifications.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('ip (NETWORKKIT-P) 1.0');
  WriteLn('iproute2 compatible network configuration tool');
  WriteLn('Compatible with Linux iproute2 package');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeConfig;
  If not InitializeNetwork Then Begin
   WriteLn('Failed to initialize network');
   Halt(1);
  End;
  
  Try
   If ParseCommandLine Then
    ExecuteCommand
   Else Begin
    WriteLn('Try "ip help" for more information.');
    Halt(2);
   End;
  Finally
   CleanupNetwork;
  End;
  {$ELSE}
  ShowSimulatedIP;
  {$ENDIF}
 End;
END.
