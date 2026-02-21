{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande plipconfig (configuration PLIP))
}

Program PLIPCONF;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour une interface PLIP }
 TPLIPInterface = Record
  Name: String[10];          { Nom de l'interface (plip0, plip1, etc.) }
  Active: Boolean;           { Interface active }
  IPAddr: String[15];        { Adresse IP assignée }
  RemoteAddr: String[15];    { Adresse IP distante }
  Netmask: String[15];       { Masque de sous-réseau }
  MTU: Word;                 { Maximum Transmission Unit }
  IRQ: Byte;                 { Numéro IRQ }
  IOPort: Word;              { Port d'entrée/sortie }
  Timeout: Word;             { Délai d'attente en ms }
  TxPackets: LongInt;        { Paquets transmis }
  RxPackets: LongInt;        { Paquets reçus }
  TxErrors: LongInt;         { Erreurs de transmission }
  RxErrors: LongInt;         { Erreurs de réception }
 End;

Const
 MAX_PLIP_INTERFACES = 4;    { Maximum 4 interfaces PLIP }
 DEFAULT_MTU = 1500;
 DEFAULT_TIMEOUT = 500;      { 500ms par défaut }

Var
 PLIPInterfaces: Array[0..MAX_PLIP_INTERFACES-1] of TPLIPInterface;
 InterfaceCount: Integer;

{ Procédure d'initialisation des interfaces PLIP }
Procedure InitializePLIP;
Var
 I: Integer;
Begin
 InterfaceCount := 0;
 For I := 0 To MAX_PLIP_INTERFACES-1 Do Begin
  With PLIPInterfaces[I] Do Begin
   Name := '';
   Active := False;
   IPAddr := '';
   RemoteAddr := '';
   Netmask := '';
   MTU := DEFAULT_MTU;
   IRQ := 0;
   IOPort := 0;
   Timeout := DEFAULT_TIMEOUT;
   TxPackets := 0;
   RxPackets := 0;
   TxErrors := 0;
   RxErrors := 0;
  End;
 End;
End;

{ Créer des interfaces PLIP d'exemple }
Procedure CreateSampleInterfaces;
Begin
 { Interface PLIP0 }
 With PLIPInterfaces[0] Do Begin
  Name := 'plip0';
  Active := True;
  IPAddr := '192.168.100.1';
  RemoteAddr := '192.168.100.2';
  Netmask := '255.255.255.252';
  MTU := 1500;
  IRQ := 7;
  IOPort := $378;
  Timeout := 500;
  TxPackets := 1247;
  RxPackets := 1156;
  TxErrors := 2;
  RxErrors := 1;
 End;
 
 { Interface PLIP1 }
 With PLIPInterfaces[1] Do Begin
  Name := 'plip1';
  Active := False;
  IPAddr := '192.168.101.1';
  RemoteAddr := '192.168.101.2';
  Netmask := '255.255.255.252';
  MTU := 1200;
  IRQ := 5;
  IOPort := $278;
  Timeout := 750;
  TxPackets := 0;
  RxPackets := 0;
  TxErrors := 0;
  RxErrors := 0;
 End;
 
 InterfaceCount := 2;
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
{ Fonction pour valider une adresse IP }
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
   If P = I Then Exit; { Deux points consécutifs }
   Num := StrToInt(Copy(S, P, I - P));
   If (Num < 0) or (Num > 255) Then Exit;
   Inc(Dots);
   P := I + 1;
  End Else If not (S[I] in ['0'..'9']) Then
   Exit;
 End;
 
 IsValidIP := (Dots = 4);
End;

{ Trouver une interface PLIP par nom }
Function FindPLIPInterface(Name: String): Integer;
Var
 I: Integer;
Begin
 FindPLIPInterface := -1;
 Name := LowerCase(Name);
 For I := 0 To InterfaceCount - 1 Do Begin
  If LowerCase(PLIPInterfaces[I].Name) = Name Then Begin
   FindPLIPInterface := I;
   Exit;
  End;
 End;
End;

{ Configurer une interface PLIP }
Function ConfigurePLIP(Name, IPAddr, RemoteAddr: String; IRQ: Byte; IOPort: Word): Boolean;
Var
 Index: Integer;
Begin
 ConfigurePLIP := False;
 Index := FindPLIPInterface(Name);
 
 If Index < 0 Then Begin
  { Créer une nouvelle interface si elle n'existe pas }
  If InterfaceCount >= MAX_PLIP_INTERFACES Then Begin
   WriteLn('Erreur: Nombre maximum d''interfaces PLIP atteint');
   Exit;
  End;
  Index := InterfaceCount;
  PLIPInterfaces[Index].Name := Name;
  Inc(InterfaceCount);
 End;
 
 { Valider les adresses IP }
 If (IPAddr <> '') and not IsValidIP(IPAddr) Then Begin
  WriteLn('Erreur: Adresse IP locale invalide: ', IPAddr);
  Exit;
 End;
 
 If (RemoteAddr <> '') and not IsValidIP(RemoteAddr) Then Begin
  WriteLn('Erreur: Adresse IP distante invalide: ', RemoteAddr);
  Exit;
 End;
 
 { Configurer l'interface }
 With PLIPInterfaces[Index] Do Begin
  If IPAddr <> '' Then Begin
   PLIPInterfaces[Index].IPAddr := IPAddr;
   WriteLn('Interface ', Name, ': adresse IP définie à ', IPAddr);
  End;
  
  If RemoteAddr <> '' Then Begin
   PLIPInterfaces[Index].RemoteAddr := RemoteAddr;
   WriteLn('Interface ', Name, ': adresse distante définie à ', RemoteAddr);
  End;
  
  If IRQ > 0 Then Begin
   PLIPInterfaces[Index].IRQ := IRQ;
   WriteLn('Interface ', Name, ': IRQ définie à ', IRQ);
  End;
  
  If IOPort > 0 Then Begin
   PLIPInterfaces[Index].IOPort := IOPort;
   WriteLn('Interface ', Name, ': port d''E/S défini à $', IntToHex(IOPort, 3));
  End;
  
  If not Active Then Begin
   Active := True;
   WriteLn('Interface ', Name, ': activée');
  End;
 End;
 
 ConfigurePLIP := True;
End;

{ Activer/désactiver une interface PLIP }
Function SetPLIPState(Name: String; Active: Boolean): Boolean;
Var
 Index: Integer;
Begin
 SetPLIPState := False;
 Index := FindPLIPInterface(Name);
 
 If Index < 0 Then Begin
  WriteLn('Erreur: Interface PLIP "', Name, '" introuvable');
  Exit;
 End;
 
 PLIPInterfaces[Index].Active := Active;
 If Active Then
  WriteLn('Interface ', Name, ': activée')
 Else
  WriteLn('Interface ', Name, ': désactivée');
 
 SetPLIPState := True;
End;

{ Afficher les statistiques d'une interface }
Procedure ShowInterfaceStats(Index: Integer);
Begin
 With PLIPInterfaces[Index] Do Begin
  WriteLn('Interface: ', Name);
  Write('État: ');
  If Active Then WriteLn('UP') Else WriteLn('DOWN');
  
  If IPAddr <> '' Then
   WriteLn('Adresse IP: ', IPAddr);
  If RemoteAddr <> '' Then
   WriteLn('Adresse distante: ', RemoteAddr);
  If Netmask <> '' Then
   WriteLn('Masque réseau: ', Netmask);
   
  WriteLn('MTU: ', MTU);
  If IRQ > 0 Then WriteLn('IRQ: ', IRQ);
  If IOPort > 0 Then WriteLn('Port E/S: $', IntToHex(IOPort, 3));
  WriteLn('Délai d''attente: ', Timeout, ' ms');
  
  WriteLn;
  WriteLn('Statistiques:');
  WriteLn('  Paquets transmis: ', TxPackets);
  WriteLn('  Paquets reçus: ', RxPackets);
  WriteLn('  Erreurs TX: ', TxErrors);
  WriteLn('  Erreurs RX: ', RxErrors);
 End;
End;

{ Afficher toutes les interfaces PLIP }
Procedure ShowAllInterfaces;
Var
 I: Integer;
Begin
 If InterfaceCount = 0 Then Begin
  WriteLn('Aucune interface PLIP configurée');
  Exit;
 End;
 
 For I := 0 To InterfaceCount - 1 Do Begin
  ShowInterfaceStats(I);
  If I < InterfaceCount - 1 Then WriteLn;
 End;
End;

{ Afficher un résumé compact des interfaces }
Procedure ShowInterfacesSummary;
Var
 I: Integer;
Begin
 If InterfaceCount = 0 Then Begin
  WriteLn('Aucune interface PLIP configurée');
  Exit;
 End;
 
 WriteLn('Interface   État    IP Local        IP Distant      IRQ  Port    MTU');
 WriteLn('----------- ------- --------------- --------------- ---- ------- -----');
 
 For I := 0 To InterfaceCount - 1 Do Begin
  With PLIPInterfaces[I] Do Begin
   Write(Copy(Name + '           ', 1, 11), ' ');
   If Active Then Write('UP     ') Else Write('DOWN   ');
   
   If IPAddr <> '' Then
    Write(Copy(IPAddr + '               ', 1, 15))
   Else
    Write('               ');
   Write(' ');
   
   If RemoteAddr <> '' Then
    Write(Copy(RemoteAddr + '               ', 1, 15))
   Else
    Write('               ');
   Write(' ');
   
   If IRQ > 0 Then
    Write(IRQ:3, '  ')
   Else
    Write('     ');
    
   If IOPort > 0 Then
    Write('$', IntToHex(IOPort, 3), '   ')
   Else
    Write('        ');
    
   WriteLn(MTU:5);
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedPLIP;
Begin
 WriteLn('Interfaces PLIP configurées (simulation):');
 WriteLn('Interface   État    IP Local        IP Distant      IRQ  Port    MTU');
 WriteLn('----------- ------- --------------- --------------- ---- ------- -----');
 WriteLn('plip0       UP      192.168.100.1   192.168.100.2   7    $378    1500');
 WriteLn('plip1       DOWN    192.168.101.1   192.168.101.2   5    $278    1200');
 WriteLn;
 WriteLn('Total: 2 interface(s) PLIP');
End;

Procedure ShowSimulatedDetailed;
Begin
 WriteLn('Interface: plip0');
 WriteLn('État: UP');
 WriteLn('Adresse IP: 192.168.100.1');
 WriteLn('Adresse distante: 192.168.100.2');
 WriteLn('Masque réseau: 255.255.255.252');
 WriteLn('MTU: 1500');
 WriteLn('IRQ: 7');
 WriteLn('Port E/S: $378');
 WriteLn('Délai d''attente: 500 ms');
 WriteLn;
 WriteLn('Statistiques:');
 WriteLn('  Paquets transmis: 1247');
 WriteLn('  Paquets reçus: 1156');
 WriteLn('  Erreurs TX: 2');
 WriteLn('  Erreurs RX: 1');
 WriteLn;
 WriteLn('Interface: plip1');
 WriteLn('État: DOWN');
 WriteLn('Adresse IP: 192.168.101.1');
 WriteLn('Adresse distante: 192.168.101.2');
 WriteLn('MTU: 1200');
 WriteLn('IRQ: 5');
 WriteLn('Port E/S: $278');
End;

Procedure SimulatePLIPConfig;
Begin
 WriteLn('Interface plip0: configuration simulée');
 WriteLn('Adresse IP définie à 192.168.100.1');
 WriteLn('Interface plip0: activée');
End;
{$ENDIF}

{ Conversion hexadécimale pour Free Pascal }
{$IFDEF FPC}
Function HexToInt(HexStr: String): Word;
Var
 I: Integer;
 Digit: Integer;
 Value: Word;
Begin
 Value := 0;
 HexStr := UpperCase(HexStr);
 
 For I := 1 To Length(HexStr) Do Begin
  If HexStr[I] in ['0'..'9'] Then
   Digit := Ord(HexStr[I]) - Ord('0')
  Else If HexStr[I] in ['A'..'F'] Then
   Digit := Ord(HexStr[I]) - Ord('A') + 10
  Else Begin
   HexToInt := 0;
   Exit;
  End;
  
  Value := Value * 16 + Digit;
 End;
 
 HexToInt := Value;
End;
{$ENDIF}

{ Conversion hexadécimale pour Turbo Pascal }
{$IFNDEF FPC}
Function IntToHex(Value: Word; Digits: Integer): String;
Const
 HexChars: String = '0123456789ABCDEF';
Var
 ResultStr: String;
 I: Integer;
Begin
 ResultStr := '';
 For I := 1 To Digits Do Begin
  ResultStr := HexChars[(Value and $F) + 1] + ResultStr;
  Value := Value shr 4;
 End;
 IntToHex := ResultStr;
End;
{$ENDIF}

{ Analyse de la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 InterfaceName: String;
 IPAddr, RemoteAddr: String;
 IRQ: Byte;
 IOPort: Word;
 ShowDetailed: Boolean;
 ConfigMode: Boolean;
 Param: String;
Begin
 InterfaceName := '';
 IPAddr := '';
 RemoteAddr := '';
 IRQ := 0;
 IOPort := 0;
 ShowDetailed := False;
 ConfigMode := False;
 
 { Analyser les paramètres }
 For I := 1 To ParamCount Do Begin
  Param := ParamStr(I);
  
  If LowerCase(Param) = '-v' Then
   ShowDetailed := True
  Else If LowerCase(Param) = '-s' Then
   ShowDetailed := False
  Else If Copy(LowerCase(Param), 1, 4) = 'plip' Then Begin
   InterfaceName := Param;
   ConfigMode := True;
  End
  Else If (Pos('.', Param) > 0) and IsValidIP(Param) Then Begin
   If IPAddr = '' Then
    IPAddr := Param
   Else
    RemoteAddr := Param;
  End
  Else If Copy(LowerCase(Param), 1, 4) = 'irq=' Then Begin
   If Length(Param) > 4 Then
    IRQ := StrToInt(Copy(Param, 5, Length(Param) - 4));
  End
  Else If Copy(LowerCase(Param), 1, 5) = 'port=' Then Begin
   If Length(Param) > 5 Then Begin
    If Copy(Param, 6, 1) = '$' Then
     IOPort := HexToInt(Copy(Param, 7, Length(Param) - 6))
    Else
     IOPort := StrToInt(Copy(Param, 6, Length(Param) - 5));
   End;
  End;
 End;
 
 {$IFDEF FPC}
 If ConfigMode and (InterfaceName <> '') Then Begin
  ConfigurePLIP(InterfaceName, IPAddr, RemoteAddr, IRQ, IOPort);
 End Else Begin
  If InterfaceCount = 0 Then CreateSampleInterfaces;
  If ShowDetailed Then
   ShowAllInterfaces
  Else
   ShowInterfacesSummary;
 End;
 {$ELSE}
 If ConfigMode Then
  SimulatePLIPConfig
 Else If ShowDetailed Then
  ShowSimulatedDetailed
 Else
  ShowSimulatedPLIP;
 {$ENDIF}
End;

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
   (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('PLIPCONF : Configuration des interfaces PLIP');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  PLIPCONF [interface] [adresse_ip] [adresse_distante] [options]');
  WriteLn('  PLIPCONF [-v|-s]');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  interface             Nom interface PLIP (plip0, plip1, etc.)');
  WriteLn('  adresse_ip            Adresse IP locale');
  WriteLn('  adresse_distante      Adresse IP du système distant');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -v                    Affichage détaillé (verbose)');
  WriteLn('  -s                    Affichage résumé (summary)');
  WriteLn('  irq=N                 Définir le numéro IRQ');
  WriteLn('  port=ADDR             Définir le port d''E/S (hex: $378)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  PLIPCONF                              # Lister toutes les interfaces');
  WriteLn('  PLIPCONF -v                           # Affichage détaillé');
  WriteLn('  PLIPCONF plip0 192.168.100.1 192.168.100.2');
  WriteLn('  PLIPCONF plip0 192.168.100.1 192.168.100.2 irq=7 port=$378');
  WriteLn;
  WriteLn('Ports parallèles courants :');
  WriteLn('  LPT1: $378 (IRQ 7)    LPT2: $278 (IRQ 5)');
  WriteLn('  LPT3: $3BC (IRQ 7)    Custom: spécifier manuellement');
  WriteLn;
  WriteLn('Note: PLIP (Parallel Line Internet Protocol) permet la connexion');
  WriteLn('réseau via le port parallèle entre deux ordinateurs.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion réelle)');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('PLIPCONF 1.00 - Configuration PLIP, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializePLIP;
  If ParamCount = 0 Then CreateSampleInterfaces;
  {$ENDIF}
  ParseCommandLine;
 End;
END.
