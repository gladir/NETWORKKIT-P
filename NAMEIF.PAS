{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande nameif (renommage d'interfaces))
}

Program NAMEIF;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour les informations d'interface }
 TInterfaceMapping = Record
  NewName:String;
  MACAddress:String;
  OldName:String;
  Description:String;
  Found:Boolean;
 End;

 { Structure IP_ADAPTER_INFO }
 IP_ADDR_STRING = Record
  Next:Pointer;
  IpAddress:Array[0..15] of AnsiChar;
  IpMask:Array[0..15] of AnsiChar;
  Context:DWORD;
 End;
 PIP_ADDR_STRING = ^IP_ADDR_STRING;

 IP_ADAPTER_INFO = Record
  Next:Pointer;
  ComboIndex:DWORD;
  AdapterName:Array[0..259] of AnsiChar;
  Description:Array[0..131] of AnsiChar;
  AddressLength:UINT;
  Address:Array[0..7] of Byte;
  Index:DWORD;
  AdapterType:UINT;
  DhcpEnabled:UINT;
  CurrentIpAddress:PIP_ADDR_STRING;
  IpAddressList:IP_ADDR_STRING;
  GatewayList:IP_ADDR_STRING;
  DhcpServer:IP_ADDR_STRING;
  HaveWins:BOOL;
  PrimaryWinsServer:IP_ADDR_STRING;
  SecondaryWinsServer:IP_ADDR_STRING;
  LeaseObtained:Int64;
  LeaseExpires:Int64;
 End;
 PIP_ADAPTER_INFO = ^IP_ADAPTER_INFO;

Const
 { Constantes pour les types d'adaptateurs }
 MIB_IF_TYPE_ETHERNET_CSMACD = 6;
 MIB_IF_TYPE_IEEE80211 = 71;

 { Constantes d'erreur }
 NO_ERROR = 0;
 ERROR_BUFFER_OVERFLOW = 111;

Var
 MappingList:Array[0..31] of TInterfaceMapping;
 MappingCount:Integer;
 ConfigFile:String;
 SimulateMode:Boolean;

{ Fonctions externes }
Function GetAdaptersInfo(pAdapterInfo:PIP_ADAPTER_INFO;Var pOutBufLen:ULONG):DWORD;stdcall;external 'iphlpapi.dll';
{$ENDIF}

{$IFNDEF FPC}
{ Fonctions utilitaires pour Turbo Pascal }
Function IntToStr(Value:LongInt):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Function StrToInt(S:String):LongInt;
Var
 Value:LongInt;
 Code:Integer;
Begin
 Val(S,Value,Code);
 If Code<>0 Then Value:=0;
 StrToInt:=Value;
End;

Function UpperCase(S:String):String;
Var
 I:Integer;
Begin
 For I:=1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I]:=Chr(Ord(S[I])-32);
 UpperCase:=S;
End;

Function LowerCase(S:String):String;
Var
 I:Integer;
Begin
 For I:=1 To Length(S) Do
  If S[I] in ['A'..'Z'] Then S[I]:=Chr(Ord(S[I])+32);
 LowerCase:=S;
End;

Function Pos(SubStr,S:String):Integer;
Var
 I,J:Integer;
 Found:Boolean;
Begin
 Pos:=0;
 For I:=1 To Length(S)-Length(SubStr)+1 Do Begin
  Found:=True;
  For J:=1 To Length(SubStr) Do
   If S[I+J-1]<>SubStr[J] Then Begin
    Found:=False;
    Break;
   End;
  If Found Then Begin
   Pos:=I;
   Break;
  End;
 End;
End;

{ Fonction pour extraire le nom de fichier d'un chemin }
Function ExtractFileName(Path:String):String;
Var
 I:Integer;
Begin
 I:=Length(Path);
 While (I>0) and (Path[I]<>'\') Do Dec(I);
 ExtractFileName:=Copy(Path,I+1,Length(Path));
End;
{$ENDIF}

{$IFDEF FPC}
{ Fonction Trim pour enlever les espaces }
Function Trim(S:String):String;
Var
 I,Start,Finish:Integer;
Begin
 Start:=1;
 Finish:=Length(S);
 
 While (Start<=Finish) and (S[Start]=' ') Do Inc(Start);
 While (Finish>=Start) and (S[Finish]=' ') Do Dec(Finish);
 
 If Start<=Finish Then
  Trim:=Copy(S,Start,Finish-Start+1)
 Else
  Trim:='';
End;

{ Fonction pour formater une adresse MAC }
Function FormatMAC(MACBytes:Array of Byte;Len:Integer):String;
Var
 I:Integer;
 MACResult:String;
 HexChars:String;
Begin
 HexChars:='0123456789abcdef';
 MACResult:='';
 For I:=0 To Len-1 Do Begin
  If I>0 Then MACResult:=MACResult+':';
  MACResult:=MACResult+HexChars[(MACBytes[I] shr 4)+1];
  MACResult:=MACResult+HexChars[(MACBytes[I] and $F)+1];
 End;
 FormatMAC:=MACResult;
End;

{ Fonction pour normaliser une adresse MAC }
Function NormalizeMAC(MAC:String):String;
Var
 I:Integer;
 NormalResult:String;
Begin
 NormalResult:='';
 For I:=1 To Length(MAC) Do Begin
  If MAC[I] in ['0'..'9','a'..'f','A'..'F'] Then
   NormalResult:=NormalResult+LowerCase(MAC[I])
  Else If (MAC[I]=':') or (MAC[I]='-') Then
   NormalResult:=NormalResult+':';
 End;
 NormalizeMAC:=NormalResult;
End;

{ Fonction pour comparer deux adresses MAC }
Function CompareMACAddress(MAC1,MAC2:String):Boolean;
Begin
 CompareMACAddress:=NormalizeMAC(MAC1)=NormalizeMAC(MAC2);
End;

{ Procédure pour lire le fichier de configuration }
Function ReadConfigFile(FileName:String):Boolean;
Var
 F:Text;
 Line,NewName,MACAddr:String;
 SpacePos:Integer;
Begin
 ReadConfigFile:=False;
 MappingCount:=0;
 
 If Not FileExists(FileName) Then Exit;
 
 Assign(F,FileName);
 {$I-}
 Reset(F);
 {$I+}
 If IOResult<>0 Then Exit;
 
 Try
  While (Not EOF(F)) and (MappingCount<32) Do Begin
   ReadLn(F,Line);
   Line:=Trim(Line);
   
   { Ignorer les commentaires et lignes vides }
   If (Length(Line)=0) or (Line[1]='#') Then Continue;
   
   { Format: nom_interface adresse_mac }
   SpacePos:=Pos(' ',Line);
   If SpacePos=0 Then SpacePos:=Pos(#9,Line);  { Tabulation }
   
   If SpacePos>0 Then Begin
    NewName:=Trim(Copy(Line,1,SpacePos-1));
    MACAddr:=Trim(Copy(Line,SpacePos+1,Length(Line)));
    
    If (Length(NewName)>0) and (Length(MACAddr)>0) Then Begin
     With MappingList[MappingCount] Do Begin
      MappingList[MappingCount].NewName:=NewName;
      MappingList[MappingCount].MACAddress:=NormalizeMAC(MACAddr);
      MappingList[MappingCount].OldName:='';
      MappingList[MappingCount].Description:='';
      MappingList[MappingCount].Found:=False;
     End;
     Inc(MappingCount);
    End;
   End;
  End;
  ReadConfigFile:=True;
 Finally
  Close(F);
 End;
End;

{ Procédure pour obtenir les interfaces réseau }
Function GetNetworkInterfaces:Boolean;
Var
 pAdapterInfo,pAdapter:PIP_ADAPTER_INFO;
 OutBufLen:ULONG;
 RetVal:DWORD;
 I,J:Integer;
 CurrentMAC:String;
Begin
 GetNetworkInterfaces:=False;
 OutBufLen:=0;
 
 { Première appel pour obtenir la taille }
 RetVal:=GetAdaptersInfo(nil,OutBufLen);
 If RetVal<>ERROR_BUFFER_OVERFLOW Then Exit;
 
 { Allouer la mémoire }
 GetMem(pAdapterInfo,OutBufLen);
 Try
  { Obtenir les informations des adaptateurs }
  RetVal:=GetAdaptersInfo(pAdapterInfo,OutBufLen);
  If RetVal=NO_ERROR Then Begin
   pAdapter:=pAdapterInfo;
   While pAdapter<>nil Do Begin
    { Traiter seulement les interfaces Ethernet et WiFi }
    If (pAdapter^.AdapterType=MIB_IF_TYPE_ETHERNET_CSMACD) or 
       (pAdapter^.AdapterType=MIB_IF_TYPE_IEEE80211) Then Begin
     CurrentMAC:=FormatMAC(pAdapter^.Address,pAdapter^.AddressLength);
     
     { Chercher dans la liste des mappages }
     For I:=0 To MappingCount-1 Do Begin
      If CompareMACAddress(MappingList[I].MACAddress,CurrentMAC) Then Begin
       With MappingList[I] Do Begin
        OldName:='eth'+IntToStr(pAdapter^.Index);
        Description:=StrPas(pAdapter^.Description);
        Found:=True;
       End;
       Break;
      End;
     End;
    End;
    pAdapter:=PIP_ADAPTER_INFO(pAdapter^.Next);
   End;
   GetNetworkInterfaces:=True;
  End;
 Finally
  FreeMem(pAdapterInfo);
 End;
End;

{ Procédure pour afficher les mappages }
Procedure ShowMappings(ShowAll:Boolean);
Var
 I:Integer;
Begin
 WriteLn('Mappages d''interfaces réseau :');
 WriteLn;
 WriteLn('Interface  Adresse MAC       Ancienne    Description');
 WriteLn('---------- ----------------- ----------- -----------');
 
 For I:=0 To MappingCount-1 Do Begin
  With MappingList[I] Do Begin
   If ShowAll or Found Then Begin
    Write(NewName);
    While Length(NewName)<11 Do Begin
     Write(' ');
     NewName:=NewName+' ';
    End;
    
    Write(MACAddress);
    While Length(MACAddress)<18 Do Begin
     Write(' ');
     MACAddress:=MACAddress+' ';
    End;
    
    If Found Then Begin
     Write(OldName);
     While Length(OldName)<12 Do Begin
      Write(' ');
      OldName:=OldName+' ';
     End;
     WriteLn(Description);
    End Else
     WriteLn('???         Interface non trouvée');
   End;
  End;
 End;
End;

{ Procédure pour appliquer les renommages }
Function ApplyRenaming:Boolean;
Var
 I,Changes:Integer;
Begin
 ApplyRenaming:=False;
 Changes:=0;
 
 WriteLn('Application des renommages d''interfaces...');
 WriteLn;
 
 For I:=0 To MappingCount-1 Do Begin
  With MappingList[I] Do Begin
   If Found Then Begin
    If SimulateMode Then Begin
     WriteLn('SIMULATION: Renommer ',OldName,' -> ',NewName,' (',MACAddress,')');
    End Else Begin
     WriteLn('Renommer ',OldName,' -> ',NewName,' (',MACAddress,')');
     { Sous Windows, le renommage nécessite des droits administrateur }
     { et l'utilisation du registre ou de netsh }
     WriteLn('  Note: Le renommage réel nécessite des droits administrateur');
     WriteLn('        Utilisez netsh interface set interface name="',OldName,'" newname="',NewName,'"');
    End;
    Inc(Changes);
   End Else
    WriteLn('ERREUR: Interface avec MAC ',MACAddress,' non trouvée');
  End;
 End;
 
 WriteLn;
 If SimulateMode Then
  WriteLn(Changes,' interface(s) à renommer')
 Else
  WriteLn(Changes,' interface(s) traitée(s)');
 ApplyRenaming:=(Changes>0);
End;

{ Procédure pour créer un fichier de configuration d'exemple }
Procedure CreateSampleConfig;
Var
 F:Text;
 FileName:String;
Begin
 FileName:='nameif.conf';
 WriteLn('Création du fichier de configuration d''exemple : ',FileName);
 
 Assign(F,FileName);
 {$I-}
 Rewrite(F);
 {$I+}
 If IOResult<>0 Then Begin
  WriteLn('Erreur lors de la création du fichier');
  Exit;
 End;
 
 Try
  WriteLn(F,'# Configuration nameif - Mappage interface/MAC');
  WriteLn(F,'# Format: nom_interface adresse_mac');
  WriteLn(F,'# Exemple:');
  WriteLn(F,'#eth0 00:11:22:33:44:55');
  WriteLn(F,'#wifi0 aa:bb:cc:dd:ee:ff');
  WriteLn(F,'#lan0 12:34:56:78:9a:bc');
  WriteLn(F);
  WriteLn(F,'# Ajoutez vos mappages ci-dessous:');
  WriteLn(F,'# eth0 00:1a:2b:3c:4d:5e');
  
  WriteLn('Fichier créé avec succès');
 Finally
  Close(F);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedMappings;
Begin
 WriteLn('Mappages d''interfaces réseau (simulation) :');
 WriteLn;
 WriteLn('Interface  Adresse MAC       Ancienne    Description');
 WriteLn('---------- ----------------- ----------- -----------');
 WriteLn('eth0       00:1a:2b:3c:4d:5e eth17       Intel Ethernet Controller');
 WriteLn('wifi0      aa:bb:cc:dd:ee:ff eth18       IEEE 802.11 Wireless Adapter');
 WriteLn('lan0       12:34:56:78:9a:bc ???         Interface non trouvée');
End;

Procedure SimulateApplyRenaming;
Begin
 WriteLn('Application des renommages d''interfaces (simulation)...');
 WriteLn;
 WriteLn('SIMULATION: Renommer eth17 -> eth0 (00:1a:2b:3c:4d:5e)');
 WriteLn('SIMULATION: Renommer eth18 -> wifi0 (aa:bb:cc:dd:ee:ff)');
 WriteLn('ERREUR: Interface avec MAC 12:34:56:78:9a:bc non trouvée');
 WriteLn;
 WriteLn('2 interface(s) à renommer');
End;

Procedure SimulateCreateConfig;
Begin
 WriteLn('Création du fichier de configuration d''exemple : nameif.conf');
 WriteLn('Fichier créé avec succès (simulation)');
End;
{$ENDIF}

{ Procédure pour analyser les paramètres }
Procedure ParseCommand;
Var
 I:Integer;
 Cmd,InterfaceName,MACAddr:String;
 ShowAll,ApplyChanges:Boolean;
Begin
 ConfigFile:='nameif.conf';
 SimulateMode:=False;
 ShowAll:=False;
 ApplyChanges:=True;
 MappingCount:=0;
 
 { Analyser les paramètres de ligne de commande }
 I:=1;
 While I<=ParamCount Do Begin
  Cmd:=UpperCase(ParamStr(I));
  
  If (Cmd='-C') or (Cmd='--CONFIG') Then Begin
   If I<ParamCount Then Begin
    Inc(I);
    ConfigFile:=ParamStr(I);
   End Else Begin
    WriteLn('Erreur : nom de fichier manquant pour -c');
    Exit;
   End;
  End Else If (Cmd='-S') or (Cmd='--SYSCONFIG') Then Begin
   ConfigFile:='/etc/nameif.conf';
  End Else If (Cmd='-D') or (Cmd='--DRY-RUN') Then Begin
   SimulateMode:=True;
  End Else If (Cmd='-A') or (Cmd='--ALL') Then Begin
   ShowAll:=True;
   ApplyChanges:=False;
  End Else If (Cmd='--SAMPLE') Then Begin
   {$IFDEF FPC}
   CreateSampleConfig;
   {$ELSE}
   SimulateCreateConfig;
   {$ENDIF}
   Exit;
  End Else If (Cmd[1]<>'-') and (Cmd[1]<>'/') Then Begin
   { Format: interface MAC }
   If I<ParamCount Then Begin
    InterfaceName:=ParamStr(I);
    Inc(I);
    MACAddr:=ParamStr(I);
    
    { Ajouter à la liste des mappages }
    If MappingCount<32 Then Begin
     With MappingList[MappingCount] Do Begin
      NewName:=InterfaceName;
      MACAddress:=MACAddr;
      OldName:='';
      Description:='';
      Found:=False;
     End;
     Inc(MappingCount);
    End;
   End Else Begin
    WriteLn('Erreur : adresse MAC manquante pour l''interface ',ParamStr(I));
    Exit;
   End;
  End;
  
  Inc(I);
 End;
 
 { Si aucun mappage en ligne de commande, lire le fichier de config }
 If MappingCount=0 Then Begin
  {$IFDEF FPC}
  If Not ReadConfigFile(ConfigFile) Then Begin
   WriteLn('Erreur : impossible de lire le fichier de configuration : ',ConfigFile);
   WriteLn('Utilisez --sample pour créer un fichier d''exemple');
   Exit;
  End;
  {$ELSE}
  { Simulation pour Turbo Pascal }
  MappingCount:=3;
  With MappingList[0] Do Begin NewName:='eth0'; MACAddress:='00:1a:2b:3c:4d:5e'; Found:=False; End;
  With MappingList[1] Do Begin NewName:='wifi0'; MACAddress:='aa:bb:cc:dd:ee:ff'; Found:=False; End;
  With MappingList[2] Do Begin NewName:='lan0'; MACAddress:='12:34:56:78:9a:bc'; Found:=False; End;
  {$ENDIF}
 End;
 
 { Obtenir les informations des interfaces }
 {$IFDEF FPC}
 If Not GetNetworkInterfaces Then Begin
  WriteLn('Erreur lors de la récupération des interfaces réseau');
  Exit;
 End;
 {$ELSE}
 { Simulation pour Turbo Pascal }
 MappingList[0].Found:=True; MappingList[0].OldName:='eth17'; MappingList[0].Description:='Intel Ethernet Controller';
 MappingList[1].Found:=True; MappingList[1].OldName:='eth18'; MappingList[1].Description:='IEEE 802.11 Wireless Adapter';
 {$ENDIF}
 
 { Exécuter l'action appropriée }
 If ShowAll Then Begin
  {$IFDEF FPC}
  ShowMappings(True);
  {$ELSE}
  ShowSimulatedMappings;
  {$ENDIF}
 End Else If ApplyChanges Then Begin
  {$IFDEF FPC}
  ApplyRenaming;
  {$ELSE}
  SimulateApplyRenaming;
  {$ENDIF}
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('NAMEIF : Renommage des interfaces réseau basé sur l''adresse MAC');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NAMEIF [options] [interface MAC...]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -c, --config fichier   Fichier de configuration (défaut: nameif.conf)');
  WriteLn('  -s, --sysconfig        Utiliser /etc/nameif.conf');
  WriteLn('  -d, --dry-run          Mode simulation (ne pas appliquer)');
  WriteLn('  -a, --all              Afficher tous les mappages');
  WriteLn('      --sample           Créer un fichier de config exemple');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  interface   Nouveau nom d''interface');
  WriteLn('  MAC         Adresse MAC (format: xx:xx:xx:xx:xx:xx)');
  WriteLn;
  WriteLn('Fichier de configuration (nameif.conf) :');
  WriteLn('  # nom_interface adresse_mac');
  WriteLn('  eth0 00:11:22:33:44:55');
  WriteLn('  wifi0 aa:bb:cc:dd:ee:ff');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  NAMEIF                            # Appliquer nameif.conf');
  WriteLn('  NAMEIF eth0 00:11:22:33:44:55     # Renommer une interface');
  WriteLn('  NAMEIF -d                         # Mode simulation');
  WriteLn('  NAMEIF -a                         # Voir tous les mappages');
  WriteLn('  NAMEIF --sample                   # Créer fichier exemple');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (données réelles)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('NAMEIF 1.00 - Renommage d''interfaces réseau, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  ParseCommand;
 End;
END.
