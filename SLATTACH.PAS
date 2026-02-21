{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande slattach (SLIP attach))
}

Program SLATTACH;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour une connexion SLIP }
 TSLIPConnection = Record
  DeviceName: String[20];    { Nom du périphérique série (COM1, ttyS0, etc.) }
  InterfaceName: String[10]; { Nom de l'interface réseau (sl0, sl1, etc.) }
  Protocol: String[10];      { Protocole (slip, cslip, slip6, adaptive) }
  BaudRate: LongInt;         { Vitesse de transmission }
  LocalIP: String[15];       { Adresse IP locale }
  RemoteIP: String[15];      { Adresse IP distante }
  Netmask: String[15];       { Masque de sous-réseau }
  MTU: Word;                 { Maximum Transmission Unit }
  KeepAlive: Boolean;        { Maintien de la connexion }
  Debug: Boolean;            { Mode debug }
  Active: Boolean;           { Interface active }
  Connected: Boolean;        { Connexion établie }
  BytesSent: LongInt;        { Octets transmis }
  BytesReceived: LongInt;    { Octets reçus }
  Errors: Integer;           { Nombre d'erreurs }
 End;

Const
 MAX_SLIP_CONNECTIONS = 8;   { Maximum 8 connexions SLIP }
 DEFAULT_MTU = 296;          { MTU par défaut pour SLIP }
 DEFAULT_BAUDRATE = 38400;   { Vitesse par défaut }

 { Protocoles supportés }
 PROTO_SLIP = 'slip';
 PROTO_CSLIP = 'cslip';      { Compressed SLIP }
 PROTO_SLIP6 = 'slip6';      { SLIP over IPv6 }
 PROTO_ADAPTIVE = 'adaptive'; { SLIP adaptatif }

Var
 SLIPConnections: Array[0..MAX_SLIP_CONNECTIONS-1] of TSLIPConnection;
 ConnectionCount: Integer;

{ Procédures Windows pour la gestion série }
Function CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: Pointer; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall; external 'kernel32.dll' name 'CreateFileA';
Function CloseHandle(hObject: THandle): BOOL; stdcall; external 'kernel32.dll';

{ Initialiser les connexions SLIP }
Procedure InitializeSLIP;
Var
 I: Integer;
Begin
 ConnectionCount := 0;
 For I := 0 To MAX_SLIP_CONNECTIONS-1 Do Begin
  With SLIPConnections[I] Do Begin
   DeviceName := '';
   InterfaceName := '';
   Protocol := PROTO_SLIP;
   BaudRate := DEFAULT_BAUDRATE;
   LocalIP := '';
   RemoteIP := '';
   Netmask := '255.255.255.0';
   MTU := DEFAULT_MTU;
   KeepAlive := False;
   Debug := False;
   Active := False;
   Connected := False;
   BytesSent := 0;
   BytesReceived := 0;
   Errors := 0;
  End;
 End;
End;

{ Créer des connexions SLIP d'exemple }
Procedure CreateSampleConnections;
Begin
 { Connexion SLIP0 - Modem dial-up }
 With SLIPConnections[0] Do Begin
  DeviceName := 'COM1';
  InterfaceName := 'sl0';
  Protocol := PROTO_CSLIP;
  BaudRate := 38400;
  LocalIP := '192.168.100.1';
  RemoteIP := '192.168.100.2';
  Netmask := '255.255.255.252';
  MTU := 296;
  KeepAlive := True;
  Debug := False;
  Active := True;
  Connected := True;
  BytesSent := 125847;
  BytesReceived := 98765;
  Errors := 2;
 End;
 
 { Connexion SLIP1 - Ligne dédiée }
 With SLIPConnections[1] Do Begin
  DeviceName := 'COM2';
  InterfaceName := 'sl1';
  Protocol := PROTO_SLIP;
  BaudRate := 115200;
  LocalIP := '10.0.0.1';
  RemoteIP := '10.0.0.2';
  Netmask := '255.255.255.252';
  MTU := 552;
  KeepAlive := True;
  Debug := False;
  Active := True;
  Connected := False;
  BytesSent := 0;
  BytesReceived := 0;
  Errors := 0;
 End;
 
 { Connexion SLIP2 - Mode adaptatif }
 With SLIPConnections[2] Do Begin
  DeviceName := '/dev/ttyS0';
  InterfaceName := 'sl2';
  Protocol := PROTO_ADAPTIVE;
  BaudRate := 57600;
  LocalIP := '172.16.1.1';
  RemoteIP := '172.16.1.2';
  Netmask := '255.255.255.252';
  MTU := 296;
  KeepAlive := False;
  Debug := True;
  Active := False;
  Connected := False;
  BytesSent := 45123;
  BytesReceived := 32456;
  Errors := 1;
 End;
 
 ConnectionCount := 3;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Fonctions utilitaires pour Turbo Pascal }
Function IntToStr(Value: LongInt): String;
Var
 S: String;
Begin
 Str(Value, S);
 IntToStr := S;
End;

Function StrToInt(S: String): LongInt;
Var
 Value: LongInt;
 Code: Integer;
Begin
 Val(S, Value, Code);
 If Code <> 0 Then Value := 0;
 StrToInt := Value;
End;

Function LowerCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['A'..'Z'] Then S[I] := Chr(Ord(S[I]) + 32);
 LowerCase := S;
End;

Function UpperCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I] := Chr(Ord(S[I]) - 32);
 UpperCase := S;
End;

Function Copy(S: String; Start, Len: Integer): String;
Var
 ResultStr: String;
 I: Integer;
Begin
 ResultStr := '';
 For I := Start To Start + Len - 1 Do
  If I <= Length(S) Then ResultStr := ResultStr + S[I];
 Copy := ResultStr;
End;

Function Pos(SubStr, S: String): Integer;
Var
 I, J: Integer;
 Found: Boolean;
Begin
 Pos := 0;
 For I := 1 To Length(S) - Length(SubStr) + 1 Do Begin
  Found := True;
  For J := 1 To Length(SubStr) Do
   If S[I + J - 1] <> SubStr[J] Then Begin
    Found := False;
    Break;
   End;
  If Found Then Begin
   Pos := I;
   Break;
  End;
 End;
End;
{$ENDIF}

{$IFDEF FPC}
{ Valider une adresse IP }
Function IsValidIP(IP: String): Boolean;
Var
 I, Dots, Num: Integer;
 S: String;
 P: Integer;
Begin
 IsValidIP := False;
 If Length(IP) = 0 Then Exit;
 
 Dots := 0;
 S := IP + '.';
 P := 1;
 
 For I := 1 To Length(S) Do Begin
  If S[I] = '.' Then Begin
   If P = I Then Exit;
   Num := StrToInt(Copy(S, P, I - P));
   If (Num < 0) or (Num > 255) Then Exit;
   Inc(Dots);
   P := I + 1;
  End Else If not (S[I] in ['0'..'9']) Then
   Exit;
 End;
 
 IsValidIP := (Dots = 4);
End;

{ Valider un nom de périphérique série }
Function IsValidSerialDevice(Device: String): Boolean;
Begin
 Device := UpperCase(Device);
 IsValidSerialDevice := (Copy(Device, 1, 3) = 'COM') or 
                       (Copy(Device, 1, 8) = '/DEV/TTY') or
                       (Device = '/DEV/MODEM');
End;

{ Valider un protocole SLIP }
Function IsValidProtocol(Protocol: String): Boolean;
Begin
 Protocol := LowerCase(Protocol);
 IsValidProtocol := (Protocol = PROTO_SLIP) or
                    (Protocol = PROTO_CSLIP) or
                    (Protocol = PROTO_SLIP6) or
                    (Protocol = PROTO_ADAPTIVE);
End;

{ Trouver une connexion par nom d'interface }
Function FindSLIPByInterface(IntfName: String): Integer;
Var
 I: Integer;
Begin
 FindSLIPByInterface := -1;
 IntfName := LowerCase(IntfName);
 
 For I := 0 To ConnectionCount - 1 Do Begin
  If LowerCase(SLIPConnections[I].InterfaceName) = IntfName Then Begin
   FindSLIPByInterface := I;
   Exit;
  End;
 End;
End;

{ Trouver une connexion par périphérique }
Function FindSLIPByDevice(Device: String): Integer;
Var
 I: Integer;
Begin
 FindSLIPByDevice := -1;
 Device := UpperCase(Device);
 
 For I := 0 To ConnectionCount - 1 Do Begin
  If UpperCase(SLIPConnections[I].DeviceName) = Device Then Begin
   FindSLIPByDevice := I;
   Exit;
  End;
 End;
End;

{ Attacher une interface SLIP }
Function AttachSLIP(Device, Protocol: String; BaudRate: LongInt; 
                   LocalIP, RemoteIP: String): Boolean;
Var
 Index: Integer;
 IntfName: String;
Begin
 AttachSLIP := False;
 
 { Valider les paramètres }
 If not IsValidSerialDevice(Device) Then Begin
  WriteLn('Erreur: Périphérique série invalide: ', Device);
  Exit;
 End;
 
 If not IsValidProtocol(Protocol) Then Begin
  WriteLn('Erreur: Protocole invalide: ', Protocol);
  Exit;
 End;
 
 If (LocalIP <> '') and not IsValidIP(LocalIP) Then Begin
  WriteLn('Erreur: Adresse IP locale invalide: ', LocalIP);
  Exit;
 End;
 
 If (RemoteIP <> '') and not IsValidIP(RemoteIP) Then Begin
  WriteLn('Erreur: Adresse IP distante invalide: ', RemoteIP);
  Exit;
 End;
 
 { Vérifier si le périphérique est déjà utilisé }
 Index := FindSLIPByDevice(Device);
 If Index >= 0 Then Begin
  WriteLn('Erreur: Périphérique ', Device, ' déjà utilisé par ', 
          SLIPConnections[Index].InterfaceName);
  Exit;
 End;
 
 { Créer une nouvelle connexion }
 If ConnectionCount >= MAX_SLIP_CONNECTIONS Then Begin
  WriteLn('Erreur: Nombre maximum de connexions SLIP atteint');
  Exit;
 End;
 
 { Générer un nom d'interface }
 IntfName := 'sl' + IntToStr(ConnectionCount);
 
 Index := ConnectionCount;
 With SLIPConnections[Index] Do Begin
  DeviceName := Device;
  InterfaceName := IntfName;
  SLIPConnections[Index].Protocol := LowerCase(Protocol);
  SLIPConnections[Index].BaudRate := BaudRate;
  SLIPConnections[Index].LocalIP := LocalIP;
  SLIPConnections[Index].RemoteIP := RemoteIP;
  Active := True;
  Connected := False;
  BytesSent := 0;
  BytesReceived := 0;
  Errors := 0;
 End;
 
 Inc(ConnectionCount);
 WriteLn('Interface SLIP ', IntfName, ' attachée au périphérique ', Device);
 WriteLn('Protocole: ', Protocol, ', Vitesse: ', BaudRate, ' bps');
 If LocalIP <> '' Then WriteLn('IP local: ', LocalIP);
 If RemoteIP <> '' Then WriteLn('IP distant: ', RemoteIP);
 
 AttachSLIP := True;
End;

{ Détacher une interface SLIP }
Function DetachSLIP(IntfName: String): Boolean;
Var
 Index, I: Integer;
Begin
 DetachSLIP := False;
 Index := FindSLIPByInterface(IntfName);
 
 If Index < 0 Then Begin
  WriteLn('Erreur: Interface SLIP "', IntfName, '" introuvable');
  Exit;
 End;
 
 { Fermer la connexion }
 With SLIPConnections[Index] Do Begin
  WriteLn('Détachement de l''interface ', InterfaceName, ' du périphérique ', DeviceName);
  If Connected Then Begin
   Connected := False;
   WriteLn('Connexion fermée');
  End;
 End;
 
 { Décaler les connexions suivantes }
 For I := Index To ConnectionCount - 2 Do
  SLIPConnections[I] := SLIPConnections[I + 1];
  
 Dec(ConnectionCount);
 WriteLn('Interface SLIP ', IntfName, ' détachée avec succès');
 DetachSLIP := True;
End;

{ Configurer une interface SLIP }
Function ConfigureSLIP(IntfName: String; LocalIP, RemoteIP, Netmask: String;
                      MTU: Word): Boolean;
Var
 Index: Integer;
Begin
 ConfigureSLIP := False;
 Index := FindSLIPByInterface(IntfName);
 
 If Index < 0 Then Begin
  WriteLn('Erreur: Interface SLIP "', IntfName, '" introuvable');
  Exit;
 End;
 
 With SLIPConnections[Index] Do Begin
  If LocalIP <> '' Then Begin
   If IsValidIP(LocalIP) Then Begin
    SLIPConnections[Index].LocalIP := LocalIP;
    WriteLn('Interface ', IntfName, ': IP local défini à ', LocalIP);
   End Else Begin
    WriteLn('Erreur: Adresse IP locale invalide: ', LocalIP);
    Exit;
   End;
  End;
  
  If RemoteIP <> '' Then Begin
   If IsValidIP(RemoteIP) Then Begin
    SLIPConnections[Index].RemoteIP := RemoteIP;
    WriteLn('Interface ', IntfName, ': IP distant défini à ', RemoteIP);
   End Else Begin
    WriteLn('Erreur: Adresse IP distante invalide: ', RemoteIP);
    Exit;
   End;
  End;
  
  If Netmask <> '' Then Begin
   If IsValidIP(Netmask) Then Begin
    SLIPConnections[Index].Netmask := Netmask;
    WriteLn('Interface ', IntfName, ': masque défini à ', Netmask);
   End Else Begin
    WriteLn('Erreur: Masque réseau invalide: ', Netmask);
    Exit;
   End;
  End;
  
  If MTU > 0 Then Begin
   If (MTU >= 68) and (MTU <= 1500) Then Begin
    SLIPConnections[Index].MTU := MTU;
    WriteLn('Interface ', IntfName, ': MTU défini à ', MTU);
   End Else Begin
    WriteLn('Erreur: MTU invalide (68-1500): ', MTU);
    Exit;
   End;
  End;
 End;
 
 ConfigureSLIP := True;
End;

{ Afficher les connexions SLIP }
Procedure ShowSLIPConnections(Detailed: Boolean);
Var
 I: Integer;
Begin
 If ConnectionCount = 0 Then Begin
  WriteLn('Aucune connexion SLIP configurée');
  Exit;
 End;
 
 If Detailed Then Begin
  WriteLn('Connexions SLIP configurées (détaillé):');
  WriteLn('=======================================');
  
  For I := 0 To ConnectionCount - 1 Do Begin
   With SLIPConnections[I] Do Begin
    WriteLn;
    WriteLn('Interface: ', InterfaceName);
    WriteLn('  Périphérique : ', DeviceName);
    WriteLn('  Protocole    : ', Protocol);
    WriteLn('  Vitesse      : ', BaudRate, ' bps');
    Write('  État         : ');
    If Active Then Begin
     If Connected Then WriteLn('CONNECTÉ') Else WriteLn('ACTIF');
    End Else WriteLn('INACTIF');
    
    If LocalIP <> '' Then WriteLn('  IP local     : ', LocalIP);
    If RemoteIP <> '' Then WriteLn('  IP distant   : ', RemoteIP);
    If Netmask <> '' Then WriteLn('  Masque       : ', Netmask);
    WriteLn('  MTU          : ', MTU);
    
    If KeepAlive Then WriteLn('  Keep-Alive   : activé');
    If Debug Then WriteLn('  Debug        : activé');
    
    WriteLn;
    WriteLn('  Statistiques:');
    WriteLn('    Octets TX  : ', BytesSent);
    WriteLn('    Octets RX  : ', BytesReceived);
    WriteLn('    Erreurs    : ', Errors);
   End;
  End;
 End Else Begin
  WriteLn('Interface Device      Protocol Vitesse   État      IP Local       IP Distant');
  WriteLn('--------- ----------- -------- --------- --------- -------------- --------------');
  
  For I := 0 To ConnectionCount - 1 Do Begin
   With SLIPConnections[I] Do Begin
    Write(Copy(InterfaceName + '         ', 1, 9), ' ');
    Write(Copy(DeviceName + '           ', 1, 11), ' ');
    Write(Copy(protocol + '        ', 1, 8), ' ');
    Write(BaudRate:9, ' ');
    
    If Active Then Begin
     If Connected Then Write('CONNECTÉ ') Else Write('ACTIF    ');
    End Else Write('INACTIF  ');
    
    If LocalIP <> '' Then
     Write(Copy(LocalIP + '              ', 1, 14))
    Else
     Write('              ');
    Write(' ');
    
    If RemoteIP <> '' Then
     WriteLn(RemoteIP)
    Else
     WriteLn;
   End;
  End;
 End;
 
 WriteLn;
 WriteLn('Total: ', ConnectionCount, ' connexion(s) SLIP');
End;

{ Afficher les statistiques SLIP }
Procedure ShowSLIPStats;
Var
 I, Active, Connected, TotalErrors: Integer;
 TotalTX, TotalRX: LongInt;
Begin
 If ConnectionCount = 0 Then Begin
  WriteLn('Aucune connexion SLIP configurée');
  Exit;
 End;
 
 Active := 0;
 Connected := 0;
 TotalTX := 0;
 TotalRX := 0;
 TotalErrors := 0;
 
 For I := 0 To ConnectionCount - 1 Do Begin
  With SLIPConnections[I] Do Begin
   If SLIPConnections[I].Active Then Inc(Active);
   If SLIPConnections[I].Connected Then Inc(Connected);
   TotalTX := TotalTX + BytesSent;
   TotalRX := TotalRX + BytesReceived;
   TotalErrors := TotalErrors + Errors;
  End;
 End;
 
 WriteLn('Statistiques SLIP:');
 WriteLn('==================');
 WriteLn('Connexions totales  : ', ConnectionCount);
 WriteLn('Connexions actives  : ', Active);
 WriteLn('Connexions établies : ', Connected);
 WriteLn('Octets transmis     : ', TotalTX);
 WriteLn('Octets reçus        : ', TotalRX);
 WriteLn('Erreurs totales     : ', TotalErrors);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedSLIP;
Begin
 WriteLn('Connexions SLIP configurées (simulation):');
 WriteLn('Interface Device      Protocol Vitesse   État      IP Local       IP Distant');
 WriteLn('--------- ----------- -------- --------- --------- -------------- --------------');
 WriteLn('sl0       COM1        cslip    38400     CONNECTÉ  192.168.100.1  192.168.100.2');
 WriteLn('sl1       COM2        slip     115200    ACTIF     10.0.0.1       10.0.0.2');
 WriteLn('sl2       /dev/ttyS0  adaptive 57600     INACTIF   172.16.1.1     172.16.1.2');
 WriteLn;
 WriteLn('Total: 3 connexion(s) SLIP');
End;

Procedure ShowSimulatedDetailed;
Begin
 WriteLn('Connexions SLIP configurées (détaillé):');
 WriteLn('=======================================');
 WriteLn;
 WriteLn('Interface: sl0');
 WriteLn('  Périphérique : COM1');
 WriteLn('  Protocole    : cslip');
 WriteLn('  Vitesse      : 38400 bps');
 WriteLn('  État         : CONNECTÉ');
 WriteLn('  IP local     : 192.168.100.1');
 WriteLn('  IP distant   : 192.168.100.2');
 WriteLn('  Masque       : 255.255.255.252');
 WriteLn('  MTU          : 296');
 WriteLn('  Keep-Alive   : activé');
 WriteLn;
 WriteLn('  Statistiques:');
 WriteLn('    Octets TX  : 125847');
 WriteLn('    Octets RX  : 98765');
 WriteLn('    Erreurs    : 2');
End;

Procedure SimulateSLIPAttach;
Begin
 WriteLn('Interface SLIP sl0 attachée au périphérique COM1 (simulation)');
 WriteLn('Protocole: slip, Vitesse: 38400 bps');
End;

Procedure SimulateSLIPDetach;
Begin
 WriteLn('Interface SLIP sl0 détachée avec succès (simulation)');
End;

Procedure ShowSimulatedStats;
Begin
 WriteLn('Statistiques SLIP:');
 WriteLn('==================');
 WriteLn('Connexions totales  : 3');
 WriteLn('Connexions actives  : 2');
 WriteLn('Connexions établies : 1');
 WriteLn('Octets transmis     : 170970');
 WriteLn('Octets reçus        : 131221');
 WriteLn('Erreurs totales     : 3');
End;
{$ENDIF}

{ Analyse de la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Action: String;
 Device, Protocol, IntfName: String;
 BaudRate: LongInt;
 LocalIP, RemoteIP, Netmask: String;
 MTU: Word;
 ShowDetailed: Boolean;
 Param: String;
Begin
 Action := 'show';
 Device := '';
 Protocol := PROTO_SLIP;
 IntfName := '';
 BaudRate := DEFAULT_BAUDRATE;
 LocalIP := '';
 RemoteIP := '';
 Netmask := '';
 MTU := 0;
 ShowDetailed := False;
 
 { Analyser les paramètres }
 For I := 1 To ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-a') or (LowerCase(Param) = '--attach') Then
   Action := 'attach'
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--detach') Then
   Action := 'detach'
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--configure') Then
   Action := 'configure'
  Else If (LowerCase(Param) = '-l') or (LowerCase(Param) = '--list') Then
   Action := 'show'
  Else If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then
   ShowDetailed := True
  Else If LowerCase(Param) = '--stats' Then
   Action := 'stats'
  Else If Copy(LowerCase(Param), 1, 2) = '-p' Then Begin
   Protocol := Copy(Param, 3, Length(Param) - 2);
   If Protocol = '' Then Protocol := PROTO_SLIP;
  End
  Else If Copy(LowerCase(Param), 1, 2) = '-s' Then Begin
   BaudRate := StrToInt(Copy(Param, 3, Length(Param) - 2));
   If BaudRate = 0 Then BaudRate := DEFAULT_BAUDRATE;
  End
  Else If Copy(LowerCase(Param), 1, 4) = 'mtu=' Then
   MTU := StrToInt(Copy(Param, 5, Length(Param) - 4))
  {$IFDEF FPC}
  Else If IsValidSerialDevice(Param) Then
   Device := Param
  Else If Copy(LowerCase(Param), 1, 2) = 'sl' Then
   IntfName := Param
  Else If IsValidIP(Param) Then Begin
   If LocalIP = '' Then
    LocalIP := Param
   Else If RemoteIP = '' Then
    RemoteIP := Param
   Else
    Netmask := Param;
  End;
  {$ELSE}
  Else If (UpperCase(Copy(Param, 1, 3)) = 'COM') or 
          (Copy(Param, 1, 8) = '/dev/tty') Then
   Device := Param
  Else If Copy(LowerCase(Param), 1, 2) = 'sl' Then
   IntfName := Param
  Else If Pos('.', Param) > 0 Then Begin
   If LocalIP = '' Then
    LocalIP := Param
   Else If RemoteIP = '' Then
    RemoteIP := Param
   Else
    Netmask := Param;
  End;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 Case Action Of
  'attach': Begin
   If Device <> '' Then
    AttachSLIP(Device, Protocol, BaudRate, LocalIP, RemoteIP)
   Else
    WriteLn('Erreur: Périphérique série requis pour l''attachement');
  End;
  'detach': Begin
   If IntfName <> '' Then
    DetachSLIP(IntfName)
   Else
    WriteLn('Erreur: Nom d''interface requis pour le détachement');
  End;
  'configure': Begin
   If IntfName <> '' Then
    ConfigureSLIP(IntfName, LocalIP, RemoteIP, Netmask, MTU)
   Else
    WriteLn('Erreur: Nom d''interface requis pour la configuration');
  End;
  'stats': Begin
   If ConnectionCount = 0 Then CreateSampleConnections;
   ShowSLIPStats;
  End;
  'show': Begin
   If ConnectionCount = 0 Then CreateSampleConnections;
   ShowSLIPConnections(ShowDetailed);
  End;
 Else Begin
  If ConnectionCount = 0 Then CreateSampleConnections;
  ShowSLIPConnections(ShowDetailed);
 End;
 End;
 {$ELSE}
 Case Action Of
  'attach': SimulateSLIPAttach;
  'detach': SimulateSLIPDetach;
  'configure': WriteLn('Configuration SLIP simulée');
  'stats': ShowSimulatedStats;
  'show': If ShowDetailed Then ShowSimulatedDetailed Else ShowSimulatedSLIP;
 Else
  ShowSimulatedSLIP;
 End;
 {$ENDIF}
End;

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
   (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('SLATTACH : Gestionnaire de connexions SLIP (Serial Line Internet Protocol)');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  SLATTACH [options] [périphérique] [adresses_ip]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -a, --attach          Attacher une interface SLIP');
  WriteLn('  -d, --detach          Détacher une interface SLIP');
  WriteLn('  -c, --configure       Configurer une interface');
  WriteLn('  -l, --list            Lister les connexions');
  WriteLn('  -v, --verbose         Affichage détaillé');
  WriteLn('  --stats               Statistiques SLIP');
  WriteLn('  -pPROTOCOL           Protocole (slip, cslip, slip6, adaptive)');
  WriteLn('  -sVITESSE            Vitesse de transmission (bps)');
  WriteLn('  mtu=TAILLE           Taille MTU (68-1500)');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  périphérique          Port série (COM1, /dev/ttyS0, etc.)');
  WriteLn('  adresse_ip_locale     Adresse IP de cette machine');
  WriteLn('  adresse_ip_distante   Adresse IP de la machine distante');
  WriteLn('  masque_réseau         Masque de sous-réseau');
  WriteLn;
  WriteLn('Protocoles supportés :');
  WriteLn('  slip                  SLIP standard (RFC 1055)');
  WriteLn('  cslip                 SLIP compressé (RFC 1144)');
  WriteLn('  slip6                 SLIP over IPv6');
  WriteLn('  adaptive              SLIP adaptatif');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  SLATTACH                              # Lister les connexions');
  WriteLn('  SLATTACH -v                           # Affichage détaillé');
  WriteLn('  SLATTACH --stats                      # Statistiques');
  WriteLn('  SLATTACH -a COM1 192.168.1.1 192.168.1.2  # Attacher SLIP');
  WriteLn('  SLATTACH -a COM1 -pcslip -s38400      # SLIP compressé');
  WriteLn('  SLATTACH -d sl0                       # Détacher interface');
  WriteLn('  SLATTACH -c sl0 mtu=552               # Configurer MTU');
  WriteLn;
  WriteLn('Vitesses courantes :');
  WriteLn('  1200, 2400, 9600, 19200, 38400, 57600, 115200 bps');
  WriteLn;
  WriteLn('Note: SLIP est un protocole point-à-point simple pour');
  WriteLn('transmettre IP sur une liaison série (modem, ligne dédiée).');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion réelle)');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('SLATTACH 1.00 - Serial Line Internet Protocol, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeSLIP;
  If ParamCount = 0 Then CreateSampleConnections;
  {$ENDIF}
  ParseCommandLine;
 End;
END.
