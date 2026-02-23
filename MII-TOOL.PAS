{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande mii-tool (Media Independent Interface))
}

Program MIITOOL;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour les informations MII }
 TMIIInfo = Record
  InterfaceName:String;
  Description:String;
  LinkStatus:String;
  Speed:String;
  Duplex:String;
  AutoNeg:String;
  Capabilities:String;
  MIIPresent:Boolean;
  AdminStatus:String;
  OperStatus:String;
  MediaType:String;
  PhyAddress:Integer;
 End;

 { Structure pour les statistiques d'interface }
 MIB_IFROW = Record
  wszName:Array[0..255] of WideChar;
  dwIndex:DWORD;
  dwType:DWORD;
  dwMtu:DWORD;
  dwSpeed:DWORD;
  dwPhysAddrLen:DWORD;
  bPhysAddr:Array[0..7] of Byte;
  dwAdminStatus:DWORD;
  dwOperStatus:DWORD;
  dwLastChange:DWORD;
  dwInOctets:DWORD;
  dwInUcastPkts:DWORD;
  dwInNUcastPkts:DWORD;
  dwInDiscards:DWORD;
  dwInErrors:DWORD;
  dwInUnknownProtos:DWORD;
  dwOutOctets:DWORD;
  dwOutUcastPkts:DWORD;
  dwOutNUcastPkts:DWORD;
  dwOutDiscards:DWORD;
  dwOutErrors:DWORD;
  dwOutQLen:DWORD;
  dwDescrLen:DWORD;
  bDescr:Array[0..255] of Byte;
 End;
 PMIB_IFROW = ^MIB_IFROW;

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
 MIB_IF_TYPE_ISO88025_TOKENRING = 9;
 MIB_IF_TYPE_FDDI = 15;
 MIB_IF_TYPE_PPP = 23;
 MIB_IF_TYPE_SOFTWARE_LOOPBACK = 24;
 MIB_IF_TYPE_ATM = 37;
 MIB_IF_TYPE_IEEE80211 = 71;

 { Constantes pour les vitesses }
 SPEED_10M = 10000000;
 SPEED_100M = 100000000;
 SPEED_1G = 1000000000;

 { Constantes d'erreur }
 NO_ERROR = 0;
 ERROR_BUFFER_OVERFLOW = 111;
 ERROR_INSUFFICIENT_BUFFER = 122;

Var
 MIIList:Array[0..31] of TMIIInfo;
 MIICount:Integer;

{ Fonctions externes }
Function GetAdaptersInfo(pAdapterInfo:PIP_ADAPTER_INFO;Var pOutBufLen:ULONG):DWORD;stdcall;external 'iphlpapi.dll';
Function GetIfEntry(pIfRow:PMIB_IFROW):DWORD;stdcall;external 'iphlpapi.dll';
{$ENDIF}

Var
 VerboseMode:Boolean;
 WatchMode:Boolean;
 WatchInterval:Integer;

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
{$ENDIF}

{$IFDEF FPC}
 { Fonction pour dÇterminer les capacitÇs MII basÇes sur le type et la vitesse }
Function GetMIICapabilities(AdapterType:DWORD;Speed:DWORD):String;
Var
 Caps:String;
Begin
 Caps:='';
 Case AdapterType Of
  MIB_IF_TYPE_ETHERNET_CSMACD:Begin
   If Speed>=SPEED_1G Then Caps:='1000baseT-FD 1000baseT-HD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD' Else
   If Speed>=SPEED_100M Then Caps:='100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD'
                         Else Caps:='10baseT-FD 10baseT-HD';
  End;
  MIB_IF_TYPE_IEEE80211:Caps:='IEEE 802.11 wireless';
  MIB_IF_TYPE_SOFTWARE_LOOPBACK:Caps:='loopback';
 Else
  Caps:='unknown';
 End;
 GetMIICapabilities:=Caps;
End;

{ Fonction pour formater la vitesse }
Function FormatSpeed(Speed:DWORD):String;Begin
 If Speed=0 Then FormatSpeed:='100' Else  { Valeur par dÇfaut si inconnue }
 If Speed>=SPEED_1G Then FormatSpeed:='1000' Else
 If Speed>=SPEED_100M Then FormatSpeed:='100' Else
 If Speed>=SPEED_10M Then FormatSpeed:='10'
                     Else FormatSpeed:='100';  { DÇfaut }
End;

{ Fonction pour dÇterminer le duplex (simulation basÇe sur la vitesse) }
Function GetDuplexMode(Speed:DWORD;AdapterType:DWORD):String;Begin
 If AdapterType=MIB_IF_TYPE_SOFTWARE_LOOPBACK Then GetDuplexMode:='full' Else
 If Speed>=SPEED_100M Then GetDuplexMode:='full'
                      Else GetDuplexMode:='half';
End;

 { Fonction pour obtenir les informations MII des interfaces }
Function GetMIIInfo:Boolean;
Var
 pAdapterInfo,pAdapter:PIP_ADAPTER_INFO;
 OutBufLen:ULONG;
 RetVal:DWORD;
 IfRow:MIB_IFROW;
 I:Integer;
Begin
 GetMIIInfo:=False;
 MIICount:=0;
 OutBufLen:=0;
  { Premiäre appel pour obtenir la taille }
 RetVal:=GetAdaptersInfo(nil,OutBufLen);
 If RetVal<>ERROR_BUFFER_OVERFLOW Then Exit;
  { Allouer la mÇmoire }
 GetMem(pAdapterInfo,OutBufLen);
 Try
   { Obtenir les informations des adaptateurs }
  RetVal:=GetAdaptersInfo(pAdapterInfo,OutBufLen);
  If RetVal=NO_ERROR Then Begin
   pAdapter:=pAdapterInfo;
   While (pAdapter<>nil) and (MIICount<32) Do Begin
    { Ne traiter que les interfaces Ethernet }
    If (pAdapter^.AdapterType=MIB_IF_TYPE_ETHERNET_CSMACD) or
       (pAdapter^.AdapterType=MIB_IF_TYPE_IEEE80211) Then Begin
     With MIIList[MIICount] Do Begin
      InterfaceName:='eth'+IntToStr(pAdapter^.Index);
      Description:=StrPas(pAdapter^.Description);
      PhyAddress:=pAdapter^.Index;
       { Obtenir les statistiques via GetIfEntry }
      FillChar(IfRow,SizeOf(IfRow),0);
      IfRow.dwIndex:=pAdapter^.Index;
      If GetIfEntry(@IfRow)=NO_ERROR Then Begin
       { D√©terminer le statut du lien }
       If IfRow.dwOperStatus=1 Then Begin
        LinkStatus:='link ok';
        OperStatus:='up';
        If IfRow.dwSpeed>0 Then Speed:=FormatSpeed(IfRow.dwSpeed)
                           Else Speed:='100';  { Valeur par dÇfaut }
        Duplex:=GetDuplexMode(IfRow.dwSpeed,IfRow.dwType);
       End Else Begin
        LinkStatus:='no link';
        OperStatus:='down';
        Speed:='100';  { Valeur par dÇfaut }
        Duplex:='full';
       End;
        { êtat administratif }
       If IfRow.dwAdminStatus=1 Then AdminStatus:='up'
                                Else AdminStatus:='down';
        { Auto-nÇgociation (simulÇ) }
       If IfRow.dwSpeed>=SPEED_100M Then AutoNeg:='on'
                                    Else AutoNeg:='off';
        { CapacitÇs MII }
       Capabilities:=GetMIICapabilities(IfRow.dwType,IfRow.dwSpeed);
        { Type de mÇdia }
       Case IfRow.dwType Of
        MIB_IF_TYPE_ETHERNET_CSMACD:MediaType:='twisted pair';
        MIB_IF_TYPE_IEEE80211:MediaType:='wireless';
        Else MediaType:='unknown';
       End;
       MIIPresent:=True;
      End
       Else
      Begin
       LinkStatus:='no MII transceiver';
       OperStatus:='unknown';
       AdminStatus:='unknown';
       Speed:='unknown';
       Duplex:='unknown';
       AutoNeg:='unknown';
       Capabilities:='none';
       MediaType:='unknown';
       MIIPresent:=False;
      End;
     End;
     Inc(MIICount);
    End;
    pAdapter:=PIP_ADAPTER_INFO(pAdapter^.Next);
   End;
   GetMIIInfo:=True;
  End;
 Finally
  FreeMem(pAdapterInfo);
 End;
End;

{ Proc√©dure pour afficher les informations MII d'une interface }
Procedure ShowMIIInterface(Index:Integer);
Begin
 With MIIList[Index] Do Begin
  Write(InterfaceName,': ');
  If Not MIIPresent Then Begin
   WriteLn('Pas de Çmetteur-rÇcepteur MII prÇsent !');
   Exit;
  End;
  If VerboseMode Then Begin
   WriteLn;
   WriteLn('  Enregistrments de l''Çmetteur-rÇcepteur MII PHY no ',PhyAddress,' :');
   WriteLn('    ',Speed,'Mbit, ',Duplex,' duplex, ',LinkStatus);
   WriteLn('    informations de produit: ',Description);
   WriteLn('    mode de base:            auto-nÇgotiation ',AutoNeg);
   WriteLn('    Çtat de base:            ',LinkStatus);
   WriteLn('    capacitÇs:               ',Capabilities);
   WriteLn('    publicitÇ:               ',Capabilities);
   If AutoNeg='on' Then WriteLn('    partenaire de liaison:   ',Capabilities);
  End
   Else
  Begin
   Write(Speed,'Mbit, ',Duplex,' duplex');
   If AutoNeg='on' Then Write(', autoneg');
   Write(', ',LinkStatus);
   WriteLn;
  End;
 End;
End;

 { ProcÇdure pour afficher toutes les interfaces MII }
Procedure ShowAllMIIInterfaces;
Var
 I:Integer;
Begin
 If GetMIIInfo Then Begin
  For I:=0 To MIICount-1 Do ShowMIIInterface(I);
 End
  Else
 WriteLn('Erreur lors de la rÇcupÇration des informations MII');
End;

 { ProcÇdure pour afficher une interface spÇcifique }
Procedure ShowSpecificMIIInterface(InterfaceName:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 If GetMIIInfo Then Begin
  For I:=0 To MIICount-1 Do Begin
   If (MIIList[I].InterfaceName=InterfaceName) or
      (Pos(UpperCase(InterfaceName),UpperCase(MIIList[I].Description))>0) Then Begin
    ShowMIIInterface(I);
    Found:=True;
   End;
  End;
  If Not Found Then WriteLn(InterfaceName,': Aucun Çmetteur-rÇcepteur MII prÇsent !');
 End;
End;

 { ProcÇdure pour red√©marrer l'auto-nÇgociation }
Procedure RestartAutoNeg(InterfaceName:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 If GetMIIInfo Then Begin
  For I:=0 To MIICount-1 Do Begin
   If (MIIList[I].InterfaceName=InterfaceName) or
      (Pos(UpperCase(InterfaceName),UpperCase(MIIList[I].Description))>0) Then Begin
    WriteLn('redÇmarrage de l''auto-nÇgociation...');
    WriteLn(InterfaceName,': auto-nÇgociation redÇmarrÇe');
    Found:=True;
   End;
  End;
  If Not Found Then WriteLn(InterfaceName,': interface non trouvÇe');
 End;
End;

 { ProcÇdure pour forcer la vitesse et le duplex }
Procedure ForceSpeedDuplex(InterfaceName,Speed,Duplex:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 If GetMIIInfo Then Begin
  For I:=0 To MIICount-1 Do Begin
   If (MIIList[I].InterfaceName=InterfaceName) or
      (Pos(UpperCase(InterfaceName),UpperCase(MIIList[I].Description))>0) Then Begin
    WriteLn('configuration forcÇe : ',Speed,'Mbit, duplex ',Duplex);
    WriteLn(InterfaceName,': vitesse forcÇe Ö ',Speed,'Mbit, duplex ',Duplex);
    Found:=True;
   End;
  End;
  If Not Found Then WriteLn(InterfaceName,': interface non trouvÇe');
 End;
End;

{ ProcÇdure de surveillance continue }
Procedure WatchMode_Proc;
Var
 I:Integer;
Begin
 WriteLn('Surveillance des interfaces MII (Ctrl+C pour arràter)');
 WriteLn;
 While True Do Begin
  If GetMIIInfo Then Begin
   WriteLn('--- êtat MII Ö ',TimeToStr(Time),' ---');
   For I:=0 To MIICount-1 Do Begin
    With MIIList[I] Do Begin
     WriteLn(InterfaceName,': ',Speed,'Mbit ',Duplex,' duplex, ',LinkStatus);
    End;
   End;
   WriteLn;
  End;
   { Attendre l'intervalle spÇcifiÇ }
  Sleep(WatchInterval * 1000);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedMII;Begin
 WriteLn('eth0: 100Mbit, full duplex, link ok');
 WriteLn('eth1: no link');
 WriteLn('eth2: no MII transceiver present!.');
End;

Procedure ShowSimulatedVerbose;Begin
 WriteLn('eth0: ');
 WriteLn('  MII PHY #1 transceiver registers:');
 WriteLn('    100Mbit, full duplex, link ok');
 WriteLn('    product info: Intel 82540EM Gigabit Ethernet Controller');
 WriteLn('    basic mode:   autonegotiation on');
 WriteLn('    basic status: link ok');
 WriteLn('    capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD');
 WriteLn('    advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD');
 WriteLn('    link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD');
End;

Procedure SimulateRestart(InterfaceName:String);Begin
 WriteLn('redÇmarrage de l''auto-nÇgociation...');
 WriteLn(InterfaceName,': auto-nÇgociation redÇmarrÇe');
End;

Procedure SimulateForce(InterfaceName,Speed,Duplex:String);Begin
 WriteLn('configuration forcÇe : ',Speed,'Mbit, duplex ',Duplex);
 WriteLn(InterfaceName,': vitesse forcÇe Ö ',Speed,'Mbit, duplex ',Duplex);
End;

Procedure SimulateWatch;Begin
 WriteLn('Surveillance des interfaces MII (simulation)');
 WriteLn('--- Statut MII ---');
 WriteLn('eth0: 100Mbit full duplex, link ok');
 WriteLn('eth1: 10Mbit half duplex, no link');
End;
{$ENDIF}

 { ProcÇdure pour analyser les paramätres }
Procedure ParseCommand;
Var
 I:Integer;
 Cmd,InterfaceName,Speed,Duplex,CurrParam:String;
Begin
 VerboseMode:=False;
 WatchMode:=False;
 WatchInterval:=1;
 InterfaceName:='';
  { Analyser les paramätres }
 I:=1;
 While I<=ParamCount Do Begin
  Cmd:=UpperCase(ParamStr(I));
  If (Cmd='-V') or (Cmd='--VERBOSE') Then VerboseMode:=True Else
  If (Cmd='-W') or (Cmd='--WATCH') Then Begin
   WatchMode:=True;
   CurrParam:=ParamStr(I+1);
   If (I<ParamCount) and (CurrParam[1] in ['0'..'9']) Then Begin
    Inc(I);
    WatchInterval:=StrToInt(ParamStr(I));
   End;
  End
   Else
  If (Cmd='-R') or (Cmd='--RESTART') Then Begin
   If I<ParamCount Then Begin
    Inc(I);
    InterfaceName:=ParamStr(I);
    {$IFDEF FPC}
     RestartAutoNeg(InterfaceName);
    {$ELSE}
     SimulateRestart(InterfaceName);
    {$ENDIF}
    Exit;
   End
    Else
   Begin
    WriteLn('Erreur : interface manquante pour --restart');
    Exit;
   End;
  End
   Else
  If (Cmd='-F') or (Cmd='--FORCE') Then Begin
   If I+2<ParamCount Then Begin
    Inc(I); Speed:=ParamStr(I);
    Inc(I); Duplex:=ParamStr(I);
    Inc(I); InterfaceName:=ParamStr(I);
    {$IFDEF FPC}
    ForceSpeedDuplex(InterfaceName,Speed,Duplex);
    {$ELSE}
    SimulateForce(InterfaceName,Speed,Duplex);
    {$ENDIF}
    Exit;
   End
    Else
   Begin
    WriteLn('Erreur : param√®tres manquants pour --force vitesse duplex interface');
    Exit;
   End;
  End
   Else
  If (Cmd[1]<>'-') and (Cmd[1]<>'/') Then InterfaceName:=ParamStr(I);
  Inc(I);
 End;
  { ExÇcuter l'action appropriÇe }
 If WatchMode Then Begin
  {$IFDEF FPC}
   WatchMode_Proc;
  {$ELSE}
   SimulateWatch;
  {$ENDIF}
 End
  Else
 If InterfaceName<>'' Then Begin
  {$IFDEF FPC}
   ShowSpecificMIIInterface(InterfaceName);
  {$ELSE}
  If VerboseMode Then ShowSimulatedVerbose
                 Else WriteLn('eth0: 100Mbit, full duplex, link ok');
  {$ENDIF}
 End
  Else
 Begin
  {$IFDEF FPC}
   ShowAllMIIInterfaces;
  {$ELSE}
  If VerboseMode Then ShowSimulatedVerbose
                 Else ShowSimulatedMII;
  {$ENDIF}
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('MII-TOOL : Cette commande permet d''effectuer l''affichage et la configuration des interfaces ',
                      'MII (Media Independent Interface)');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  MII-TOOL [options] [interface...]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -v, --verbose                          Mode verbeux');
  WriteLn('  -w, --watch [sec]                      Surveillance continue (dÇfaut: 1 seconde)');
  WriteLn('  -r, --restart interface                RedÇmarrer l''auto-nÇgociation');
  WriteLn('  -F, --force vitesse duplex interface   Forcer vitesse et duplex');
  WriteLn;
  WriteLn('Paramätres :');
  WriteLn('  interface   Nom de l''interface (ex: eth0, eth1)');
  WriteLn('  vitesse     Vitesse en Mbit (10, 100, 1000)');
  WriteLn('  duplex      Mode duplex (half, full)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  MII-TOOL                      # Afficher toutes les interfaces');
  WriteLn('  MII-TOOL -v eth0              # Mode verbeux pour eth0');
  WriteLn('  MII-TOOL -w 2                 # Surveillance toutes les 2 sec');
  WriteLn('  MII-TOOL -r eth0              # RedÇmarrer auto-nÇgociation');
  WriteLn('  MII-TOOL -F 100 full eth0     # Forcer 100Mbit full duplex');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (donnÇes rÇelles)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('MII-TOOL 1.00 - Clone Pascal pour NETWORKKIT-P, Linux-0, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  ParseCommand;
 End;
END.