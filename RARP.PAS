{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande rarp (Reverse ARP))
}

Program RARP;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, WinSock;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour une entrée RARP }
 TRARPEntry = Record
  HWAddr: String[17];        { Adresse MAC (00:11:22:33:44:55) }
  IPAddr: String[15];        { Adresse IP correspondante }
  HWType: Word;              { Type de matériel (1=Ethernet) }
  Flags: Word;               { Drapeaux (permanent, publié, etc.) }
  InterfaceName: String[10]; { Nom de l'interface }
  Temp: Boolean;             { Entrée temporaire }
  Pub: Boolean;              { Entrée publiée }
  Complete: Boolean;         { Entrée complète }
 End;

Const
 MAX_RARP_ENTRIES = 256;
 HW_ETHER = 1;              { Type Ethernet }
 
 { Flags RARP }
 ATF_COM = $02;             { Entrée complète }
 ATF_PERM = $04;            { Entrée permanente }
 ATF_PUBL = $08;            { Entrée publiée }
 ATF_USETRAILERS = $10;     { Utilise des trailers }

Var
 RARPTable: Array[0..MAX_RARP_ENTRIES-1] of TRARPEntry;
 RARPCount: Integer;

{ Procédures Windows pour la gestion réseau }
Function GetAdaptersInfo(pAdapterInfo: Pointer; pOutBufLen: PDWORD): DWORD; stdcall; external 'iphlpapi.dll';
Function SendARP(DestIP, SrcIP: DWORD; pMacAddr: Pointer; PhyAddrLen: PDWORD): DWORD; stdcall; external 'iphlpapi.dll';

{ Initialiser la table RARP }
Procedure InitializeRARP;
Var
 I: Integer;
Begin
 RARPCount := 0;
 For I := 0 To MAX_RARP_ENTRIES-1 Do Begin
  With RARPTable[I] Do Begin
   HWAddr := '';
   IPAddr := '';
   HWType := HW_ETHER;
   Flags := 0;
   InterfaceName := '';
   Temp := False;
   Pub := False;
   Complete := False;
  End;
 End;
End;

{ Créer des entrées RARP d'exemple }
Procedure CreateSampleEntries;
Begin
 { Entrée 1: Serveur local }
 With RARPTable[0] Do Begin
  HWAddr := '00:1B:21:3A:4C:5D';
  IPAddr := '192.168.1.1';
  HWType := HW_ETHER;
  Flags := ATF_COM or ATF_PERM or ATF_PUBL;
  InterfaceName := 'eth0';
  Temp := False;
  Pub := True;
  Complete := True;
 End;
 
 { Entrée 2: Poste de travail }
 With RARPTable[1] Do Begin
  HWAddr := '00:50:56:C0:00:01';
  IPAddr := '192.168.1.100';
  HWType := HW_ETHER;
  Flags := ATF_COM;
  InterfaceName := 'eth0';
  Temp := True;
  Pub := False;
  Complete := True;
 End;
 
 { Entrée 3: Serveur DHCP }
 With RARPTable[2] Do Begin
  HWAddr := '00:0C:29:12:34:56';
  IPAddr := '192.168.1.254';
  HWType := HW_ETHER;
  Flags := ATF_COM or ATF_PERM or ATF_PUBL;
  InterfaceName := 'eth0';
  Temp := False;
  Pub := True;
  Complete := True;
 End;
 
 { Entrée 4: Entrée incomplète }
 With RARPTable[3] Do Begin
  HWAddr := '00:15:5D:01:02:03';
  IPAddr := '192.168.1.150';
  HWType := HW_ETHER;
  Flags := 0;
  InterfaceName := 'eth0';
  Temp := True;
  Pub := False;
  Complete := False;
 End;
 
 RARPCount := 4;
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

{ Valider une adresse MAC }
Function IsValidMAC(MAC: String): Boolean;
Var
 I, Colons: Integer;
Begin
 IsValidMAC := False;
 If Length(MAC) <> 17 Then Exit;
 
 Colons := 0;
 For I := 1 To Length(MAC) Do Begin
  If MAC[I] = ':' Then Begin
   Inc(Colons);
   If (I mod 3) <> 0 Then Exit;
  End Else If not (MAC[I] in ['0'..'9', 'A'..'F', 'a'..'f']) Then
   Exit;
 End;
 
 IsValidMAC := (Colons = 5);
End;

{ Normaliser une adresse MAC }
Function NormalizeMAC(MAC: String): String;
Var
 I: Integer;
 NormStr: String;
Begin
 NormStr := '';
 For I := 1 To Length(MAC) Do Begin
  If MAC[I] in ['a'..'f'] Then
   NormStr := NormStr + Chr(Ord(MAC[I]) - 32)
  Else
   NormStr := NormStr + MAC[I];
 End;
 NormalizeMAC := NormStr;
End;

{ Trouver une entrée RARP par adresse MAC }
Function FindRARPByMAC(HWAddr: String): Integer;
Var
 I: Integer;
Begin
 FindRARPByMAC := -1;
 HWAddr := NormalizeMAC(HWAddr);
 
 For I := 0 To RARPCount - 1 Do Begin
  If NormalizeMAC(RARPTable[I].HWAddr) = HWAddr Then Begin
   FindRARPByMAC := I;
   Exit;
  End;
 End;
End;

{ Trouver une entrée RARP par adresse IP }
Function FindRARPByIP(IPAddr: String): Integer;
Var
 I: Integer;
Begin
 FindRARPByIP := -1;
 
 For I := 0 To RARPCount - 1 Do Begin
  If RARPTable[I].IPAddr = IPAddr Then Begin
   FindRARPByIP := I;
   Exit;
  End;
 End;
End;

{ Ajouter une entrée RARP }
Function AddRARPEntry(HWAddr, IPAddr, IntfName: String; Temp, Pub: Boolean): Boolean;
Var
 Index: Integer;
Begin
 AddRARPEntry := False;
 
 { Vérifier les adresses }
 If not IsValidMAC(HWAddr) Then Begin
  WriteLn('Erreur: Adresse MAC invalide: ', HWAddr);
  Exit;
 End;
 
 If not IsValidIP(IPAddr) Then Begin
  WriteLn('Erreur: Adresse IP invalide: ', IPAddr);
  Exit;
 End;
 
 { Vérifier si l'entrée existe déjà }
 Index := FindRARPByMAC(HWAddr);
 If Index >= 0 Then Begin
  { Mettre à jour l'entrée existante }
  With RARPTable[Index] Do Begin
   RARPTable[Index].IPAddr := IPAddr;
   RARPTable[Index].InterfaceName := IntfName;
   RARPTable[Index].Temp := Temp;
   RARPTable[Index].Pub := Pub;
   RARPTable[Index].Complete := True;
   
   { Mettre à jour les flags }
   Flags := ATF_COM;
   If not Temp Then Flags := Flags or ATF_PERM;
   If Pub Then Flags := Flags or ATF_PUBL;
  End;
  WriteLn('Entrée RARP mise à jour pour ', HWAddr);
 End Else Begin
  { Ajouter nouvelle entrée }
  If RARPCount >= MAX_RARP_ENTRIES Then Begin
   WriteLn('Erreur: Table RARP pleine');
   Exit;
  End;
  
  Index := RARPCount;
  With RARPTable[Index] Do Begin
   HWAddr := NormalizeMAC(HWAddr);
   RARPTable[Index].IPAddr := IPAddr;
   HWType := HW_ETHER;
   InterfaceName := IntfName;
   RARPTable[Index].Temp := Temp;
   RARPTable[Index].Pub := Pub;
   Complete := True;
   
   { Définir les flags }
   Flags := ATF_COM;
   If not Temp Then Flags := Flags or ATF_PERM;
   If Pub Then Flags := Flags or ATF_PUBL;
  End;
  
  Inc(RARPCount);
  WriteLn('Entrée RARP ajoutée pour ', HWAddr);
 End;
 
 AddRARPEntry := True;
End;

{ Supprimer une entrée RARP }
Function DeleteRARPEntry(HWAddr: String): Boolean;
Var
 Index, I: Integer;
Begin
 DeleteRARPEntry := False;
 Index := FindRARPByMAC(HWAddr);
 
 If Index < 0 Then Begin
  WriteLn('Erreur: Entrée RARP introuvable pour ', HWAddr);
  Exit;
 End;
 
 { Décaler les entrées suivantes }
 For I := Index To RARPCount - 2 Do
  RARPTable[I] := RARPTable[I + 1];
  
 Dec(RARPCount);
 WriteLn('Entrée RARP supprimée pour ', HWAddr);
 DeleteRARPEntry := True;
End;

{ Résoudre une adresse MAC en IP (simulation) }
Function ResolveMAC(HWAddr: String; var IPAddr: String): Boolean;
Var
 Index: Integer;
Begin
 ResolveMAC := False;
 Index := FindRARPByMAC(HWAddr);
 
 If Index >= 0 Then Begin
  IPAddr := RARPTable[Index].IPAddr;
  ResolveMAC := True;
  WriteLn(HWAddr, ' résolu en ', IPAddr);
 End Else Begin
  WriteLn('Impossible de résoudre ', HWAddr);
 End;
End;

{ Afficher les flags sous forme de chaîne }
Function FlagsToString(Flags: Word): String;
Var
 FlagStr: String;
Begin
 FlagStr := '';
 If (Flags and ATF_COM) <> 0 Then FlagStr := FlagStr + 'C';
 If (Flags and ATF_PERM) <> 0 Then FlagStr := FlagStr + 'M';
 If (Flags and ATF_PUBL) <> 0 Then FlagStr := FlagStr + 'P';
 If (Flags and ATF_USETRAILERS) <> 0 Then FlagStr := FlagStr + 'T';
 If FlagStr = '' Then FlagStr := '-';
 FlagsToString := FlagStr;
End;

{ Afficher la table RARP }
Procedure ShowRARPTable(ShowHeaders: Boolean);
Var
 I: Integer;
Begin
 If RARPCount = 0 Then Begin
  WriteLn('Table RARP vide');
  Exit;
 End;
 
 If ShowHeaders Then Begin
  WriteLn('Table RARP (Reverse Address Resolution Protocol):');
  WriteLn('Adresse IP      Adresse MAC       Type HW Flags Interface');
  WriteLn('--------------- ----------------- ------- ----- ---------');
 End;
 
 For I := 0 To RARPCount - 1 Do Begin
  With RARPTable[I] Do Begin
   Write(Copy(IPAddr + '               ', 1, 15), ' ');
   Write(Copy(HWAddr + '                 ', 1, 17), ' ');
   
   Case HWType Of
    HW_ETHER: Write('ether   ');
    Else Write(HWType:3, '     ');
   End;
   
   Write(Copy(FlagsToString(Flags) + '     ', 1, 5), ' ');
   WriteLn(InterfaceName);
  End;
 End;
 
 If ShowHeaders Then Begin
  WriteLn;
  WriteLn('Légende des flags:');
  WriteLn('  C = Complète, M = Permanente, P = Publiée, T = Trailers');
  WriteLn('Entrées: ', RARPCount);
 End;
End;

{ Vider la table RARP }
Procedure FlushRARPTable;
Begin
 RARPCount := 0;
 WriteLn('Table RARP vidée');
End;

{ Afficher les statistiques RARP }
Procedure ShowRARPStats;
Var
 I, Complete, Permanent, Published, Incomplete: Integer;
Begin
 Complete := 0;
 Permanent := 0;
 Published := 0;
 Incomplete := 0;
 
 For I := 0 To RARPCount - 1 Do Begin
  With RARPTable[I] Do Begin
   If (Flags and ATF_COM) <> 0 Then Inc(Complete)
   Else Inc(Incomplete);
   If (Flags and ATF_PERM) <> 0 Then Inc(Permanent);
   If (Flags and ATF_PUBL) <> 0 Then Inc(Published);
  End;
 End;
 
 WriteLn('Statistiques RARP:');
 WriteLn('==================');
 WriteLn('Total entrées      : ', RARPCount);
 WriteLn('Entrées complètes  : ', Complete);
 WriteLn('Entrées permanentes: ', Permanent);
 WriteLn('Entrées publiées   : ', Published);
 WriteLn('Entrées incomplètes: ', Incomplete);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedRARP;
Begin
 WriteLn('Table RARP (Reverse Address Resolution Protocol):');
 WriteLn('Adresse IP      Adresse MAC       Type HW Flags Interface');
 WriteLn('--------------- ----------------- ------- ----- ---------');
 WriteLn('192.168.1.1     00:1B:21:3A:4C:5D ether   CMP   eth0');
 WriteLn('192.168.1.100   00:50:56:C0:00:01 ether   C     eth0');
 WriteLn('192.168.1.254   00:0C:29:12:34:56 ether   CMP   eth0');
 WriteLn('192.168.1.150   00:15:5D:01:02:03 ether   -     eth0');
 WriteLn;
 WriteLn('Légende des flags:');
 WriteLn('  C = Complète, M = Permanente, P = Publiée, T = Trailers');
 WriteLn('Entrées: 4');
End;

Procedure SimulateRARPAdd;
Begin
 WriteLn('Entrée RARP ajoutée pour 00:11:22:33:44:55 (simulation)');
End;

Procedure SimulateRARPDelete;
Begin
 WriteLn('Entrée RARP supprimée pour 00:11:22:33:44:55 (simulation)');
End;

Procedure ShowSimulatedStats;
Begin
 WriteLn('Statistiques RARP:');
 WriteLn('==================');
 WriteLn('Total entrées      : 4');
 WriteLn('Entrées complètes  : 3');
 WriteLn('Entrées permanentes: 2');
 WriteLn('Entrées publiées   : 2');
 WriteLn('Entrées incomplètes: 1');
End;
{$ENDIF}

{ Analyse de la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Action: String;
 HWAddr, IPAddr, InterfaceName: String;
 ShowNumeric: Boolean;
 Temp, Pub: Boolean;
 Param: String;
Begin
 Action := 'show';
 HWAddr := '';
 IPAddr := '';
 InterfaceName := 'eth0';
 ShowNumeric := False;
 Temp := False;
 Pub := False;
 
 { Analyser les paramètres }
 For I := 1 To ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-a') or (LowerCase(Param) = '--all') Then
   Action := 'show'
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--delete') Then
   Action := 'delete'
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--set') Then
   Action := 'add'
  Else If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--flush') Then
   Action := 'flush'
  Else If (LowerCase(Param) = '-n') or (LowerCase(Param) = '--numeric') Then
   ShowNumeric := True
  Else If (LowerCase(Param) = '-t') or (LowerCase(Param) = '--temp') Then
   Temp := True
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--pub') Then
   Pub := True
  Else If LowerCase(Param) = '--stats' Then
   Action := 'stats'
  Else If Copy(LowerCase(Param), 1, 4) = 'dev=' Then
   InterfaceName := Copy(Param, 5, Length(Param) - 4)
  {$IFDEF FPC}
  Else If IsValidMAC(Param) Then
   HWAddr := Param
  Else If IsValidIP(Param) Then
   IPAddr := Param;
  {$ELSE}
  Else If (Pos(':', Param) > 0) and (Length(Param) = 17) Then
   HWAddr := Param
  Else If (Pos('.', Param) > 0) Then
   IPAddr := Param;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 Case Action Of
  'show': Begin
   If RARPCount = 0 Then CreateSampleEntries;
   ShowRARPTable(True);
  End;
  'add': Begin
   If (HWAddr <> '') and (IPAddr <> '') Then
    AddRARPEntry(HWAddr, IPAddr, InterfaceName, Temp, Pub)
   Else
    WriteLn('Erreur: Adresse MAC et IP requises pour ajouter une entrée');
  End;
  'delete': Begin
   If HWAddr <> '' Then
    DeleteRARPEntry(HWAddr)
   Else
    WriteLn('Erreur: Adresse MAC requise pour supprimer une entrée');
  End;
  'flush': FlushRARPTable;
  'stats': Begin
   If RARPCount = 0 Then CreateSampleEntries;
   ShowRARPStats;
  End;
 Else Begin
  If RARPCount = 0 Then CreateSampleEntries;
  ShowRARPTable(True);
 End;
 End;
 {$ELSE}
 Case Action Of
  'show': ShowSimulatedRARP;
  'add': SimulateRARPAdd;
  'delete': SimulateRARPDelete;
  'flush': WriteLn('Table RARP vidée (simulation)');
  'stats': ShowSimulatedStats;
 Else
  ShowSimulatedRARP;
 End;
 {$ENDIF}
End;

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
   (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('RARP : Gestion du protocole Reverse Address Resolution Protocol');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  RARP [options] [adresse_mac] [adresse_ip]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -a, --all             Afficher toute la table RARP');
  WriteLn('  -d, --delete          Supprimer une entrée');
  WriteLn('  -s, --set             Ajouter/modifier une entrée');
  WriteLn('  -f, --flush           Vider la table RARP');
  WriteLn('  -n, --numeric         Affichage numérique');
  WriteLn('  -t, --temp            Entrée temporaire');
  WriteLn('  -p, --pub             Entrée publiée');
  WriteLn('  --stats               Afficher les statistiques');
  WriteLn('  dev=INTERFACE         Spécifier l''interface');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  adresse_mac           Adresse MAC (00:11:22:33:44:55)');
  WriteLn('  adresse_ip            Adresse IP correspondante');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  RARP                              # Afficher la table RARP');
  WriteLn('  RARP -a                           # Afficher toutes les entrées');
  WriteLn('  RARP --stats                      # Statistiques RARP');
  WriteLn('  RARP -s 00:11:22:33:44:55 192.168.1.10   # Ajouter entrée');
  WriteLn('  RARP -s 00:11:22:33:44:55 192.168.1.10 -p # Entrée publiée');
  WriteLn('  RARP -d 00:11:22:33:44:55         # Supprimer entrée');
  WriteLn('  RARP -f                           # Vider la table');
  WriteLn;
  WriteLn('Flags des entrées :');
  WriteLn('  C = Complète     M = Permanente');
  WriteLn('  P = Publiée      T = Trailers');
  WriteLn;
  WriteLn('Note: RARP permet de résoudre une adresse MAC en adresse IP.');
  WriteLn('Utilisé principalement pour l''amorçage réseau des stations');
  WriteLn('sans disque dur.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion réelle)');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('RARP 1.00 - Reverse Address Resolution Protocol, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeRARP;
  If ParamCount = 0 Then CreateSampleEntries;
  {$ENDIF}
  ParseCommandLine;
 End;
END.
