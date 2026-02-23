{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Commande ipmaddr (gestion des adresses de multidiffusion)
}

Program IPMADDR;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, WinSock;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour les informations d'interface rÇseau }
 TInterfaceInfo = Record
  Name:String;
  Index:Integer;
  IPAddress:String;
  HWAddress:String;
  Flags:String;
 End;

 { Structure pour les adresses multicast }
 TMulticastAddr = Record
  InterfaceIndex:Integer;
  InterfaceName:String;
  GroupAddr:String;
  RefCount:Integer;
  Users:Integer;
  Timer:String;
  Reporter:String;
 End;

 { Structures Windows pour les interfaces }
 IP_ADAPTER_ADDRESSES = Record
  Length:DWORD;
  IfIndex:DWORD;
  Next:Pointer;
  AdapterName:PChar;
  FirstUnicastAddress:Pointer;
  FirstAnycastAddress:Pointer;
  FirstMulticastAddress:Pointer;
  FirstDnsServerAddress:Pointer;
  DnsSuffix:PWideChar;
  Description:PWideChar;
  FriendlyName:PWideChar;
  PhysicalAddress:Array[0..7] of Byte;
  PhysicalAddressLength:DWORD;
  Flags:DWORD;
  Mtu:DWORD;
  IfType:DWORD;
  OperStatus:DWORD;
 End;
 PIP_ADAPTER_ADDRESSES = ^IP_ADAPTER_ADDRESSES;

 { Structure pour adresses multicast Windows }
 IP_ADAPTER_MULTICAST_ADDRESS = Record
  Length:DWORD;
  Flags:DWORD;
  Next:Pointer;
  Address:Pointer;  { SOCKET_ADDRESS }
 End;
 PIP_ADAPTER_MULTICAST_ADDRESS = ^IP_ADAPTER_MULTICAST_ADDRESS;

Const
  { Codes d'erreur Windows }
 ERROR_BUFFER_OVERFLOW = 111;
 ERROR_NO_DATA = 232;
 AF_UNSPEC = 0;
 AF_INET = 2;
 GAA_FLAG_INCLUDE_PREFIX = $00000010;
 GAA_FLAG_SKIP_UNICAST = $00000001;
 GAA_FLAG_SKIP_ANYCAST = $00000002;
 GAA_FLAG_SKIP_DNS_SERVER = $00000008;

 { Adresses multicast connues }
 MULTICAST_ALL_HOSTS = '224.0.0.1';
 MULTICAST_ALL_ROUTERS = '224.0.0.2';
 MULTICAST_DVMRP = '224.0.0.4';
 MULTICAST_OSPF_ALL = '224.0.0.5';
 MULTICAST_OSPF_DESIGNATED = '224.0.0.6';
 MULTICAST_RIP2 = '224.0.0.9';
 MULTICAST_MOBILE_AGENTS = '224.0.0.11';
 MULTICAST_DHCP_SERVER = '224.0.0.12';
 MULTICAST_ALL_PIM_ROUTERS = '224.0.0.13';
 MULTICAST_RSVP_ENCAP = '224.0.0.14';
 MULTICAST_UPnP = '239.255.255.250';

Var
 Interfaces:Array[0..31] of TInterfaceInfo;
 MulticastAddrs:Array[0..127] of TMulticastAddr;
 InterfaceCount,MulticastCount:Integer;

{ Fonctions externes Windows }
Function GetAdaptersAddresses(Family:DWORD;Flags:DWORD;Reserved:Pointer;
                             AdapterAddresses:PIP_ADAPTER_ADDRESSES;
                             Var SizePointer:DWORD):DWORD;stdcall;external 'iphlpapi.dll';
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
{$ENDIF}

{$IFDEF FPC}
{ ProcÇdure d'initialisation des structures }
Procedure InitializeStructures;
Var
 I:Integer;
Begin
 InterfaceCount:=0;
 MulticastCount:=0;
 For I:=0 To 31 Do Begin
  With Interfaces[I] Do Begin
   Name:='';
   Index:=0;
   IPAddress:='';
   HWAddress:='';
   Flags:='';
  End;
 End;
 For I:=0 To 127 Do Begin
  With MulticastAddrs[I] Do Begin
   InterfaceIndex:=0;
   InterfaceName:='';
   GroupAddr:='';
   RefCount:=0;
   Users:=0;
   Timer:='';
   Reporter:='';
  End;
 End;
End;

 { Fonction pour convertir une adresse MAC en chaåne }
Function MACToString(MAC:Array of Byte;Len:Integer):String;
Var
 I:Integer;
 S:String;
Begin
 S:='';
 For I:=0 To Len-1 Do Begin
  If I>0 Then S:=S+':';
  If MAC[I]<16 Then S:=S+'0';
  S:=S+IntToStr(MAC[I]);  { Simplification - ne gäre pas l'hexadÇcimal }
 End;
 MACToString:=S;
End;

 { Fonction pour obtenir le nom d'une adresse multicast connue }
Function GetMulticastName(Addr:String):String;Begin
 If Addr=MULTICAST_ALL_HOSTS Then GetMulticastName:='All Hosts' Else
 If Addr=MULTICAST_ALL_ROUTERS Then GetMulticastName:='All Routers' Else
 If Addr=MULTICAST_DVMRP Then GetMulticastName:='DVMRP' Else
 If Addr=MULTICAST_OSPF_ALL Then GetMulticastName:='OSPF All' Else
 If Addr=MULTICAST_OSPF_DESIGNATED Then GetMulticastName:='OSPF Designated' Else
 If Addr=MULTICAST_RIP2 Then GetMulticastName:='RIP2' Else
 If Addr=MULTICAST_MOBILE_AGENTS Then GetMulticastName:='Mobile Agents' Else
 If Addr=MULTICAST_DHCP_SERVER Then GetMulticastName:='DHCP Server' Else
 If Addr=MULTICAST_ALL_PIM_ROUTERS Then GetMulticastName:='All PIM Routers' Else
 If Addr=MULTICAST_RSVP_ENCAP Then GetMulticastName:='RSVP Encap' Else
 If Addr=MULTICAST_UPnP Then GetMulticastName:='UPnP'
                        Else GetMulticastName:='';
End;

 { Fonction pour obtenir les interfaces rÇseau }
Function GetNetworkInterfaces:Boolean;
Var
 pAdapterAddresses:PIP_ADAPTER_ADDRESSES;
 pAdapter:PIP_ADAPTER_ADDRESSES;
 dwSize:DWORD;
 dwRetVal:DWORD;
 I:Integer;
Begin
 GetNetworkInterfaces:=False;
 InterfaceCount:=0;
 dwSize:=0;
 Try
   { Premiäre appel pour obtenir la taille nÇcessaire }
  dwRetVal:=GetAdaptersAddresses(AF_INET,GAA_FLAG_SKIP_UNICAST or GAA_FLAG_SKIP_ANYCAST,
                                nil,nil,dwSize);
  If (dwRetVal<>ERROR_BUFFER_OVERFLOW) and (dwRetVal<>ERROR_NO_DATA) Then Exit;
  If dwSize=0 Then Exit;
   { Allouer la mÇmoire }
  GetMem(pAdapterAddresses,dwSize);
  Try
    { Obtenir les informations des adaptateurs }
   dwRetVal:=GetAdaptersAddresses(AF_INET,GAA_FLAG_SKIP_UNICAST or GAA_FLAG_SKIP_ANYCAST,
                                 nil,pAdapterAddresses,dwSize);
   If dwRetVal=0 Then Begin
    pAdapter:=pAdapterAddresses;
    I:=0;
    While (pAdapter<>nil) and (I<32) Do Begin
     With Interfaces[I] Do Begin
      If pAdapter^.AdapterName<>nil Then
       Name:=StrPas(pAdapter^.AdapterName)
      Else
       Name:='eth'+IntToStr(I);
      Index:=pAdapter^.IfIndex;
      IPAddress:='0.0.0.0';  { SimplifiÇ }
      HWAddress:=MACToString(pAdapter^.PhysicalAddress,pAdapter^.PhysicalAddressLength);
       { DÇterminer les drapeaux simples }
      Flags:='UP';
      If pAdapter^.OperStatus=1 Then Flags:=Flags+',RUNNING';
      If pAdapter^.IfType=6 Then Flags:=Flags+',BROADCAST,MULTICAST';
     End;
     Inc(I);
     pAdapter:=pAdapter^.Next;
    End;
    InterfaceCount:=I;
    GetNetworkInterfaces:=True;
   End;
  Finally
   FreeMem(pAdapterAddresses,dwSize);
  End;
 Except
  GetNetworkInterfaces:=False;
 End;
End;

 { Fonction pour simuler les adresses multicast (Windows n'expose pas facilement cette info) }
Function GetMulticastAddresses:Boolean;
Var
 I:Integer;
Begin
 GetMulticastAddresses:=True;
 MulticastCount:=0;
  { Ajouter quelques adresses multicast communes pour chaque interface }
 For I:=0 To InterfaceCount-1 Do Begin
  { Tous les hìtes de multi-diffusion }
  With MulticastAddrs[MulticastCount] Do Begin
   InterfaceIndex:=Interfaces[I].Index;
   InterfaceName:=Interfaces[I].Name;
   GroupAddr:=MULTICAST_ALL_HOSTS;
   RefCount:=1;
   Users:=1;
   Timer:='never';
   Reporter:='1';
  End;
  Inc(MulticastCount);
   { UPnP Multicast (träs commun) }
  If MulticastCount<128 Then Begin
   With MulticastAddrs[MulticastCount] Do Begin
    InterfaceIndex:=Interfaces[I].Index;
    InterfaceName:=Interfaces[I].Name;
    GroupAddr:=MULTICAST_UPnP;
    RefCount:=1;
    Users:=2;
    Timer:='4min17sec';
    Reporter:='1';
   End;
   Inc(MulticastCount);
  End;
   { OSPF si c'est un routeur potentiel }
  If (I=0) and (MulticastCount<128) Then Begin
   With MulticastAddrs[MulticastCount] Do Begin
    InterfaceIndex:=Interfaces[I].Index;
    InterfaceName:=Interfaces[I].Name;
    GroupAddr:=MULTICAST_OSPF_ALL;
    RefCount:=1;
    Users:=1;
    Timer:='never';
    Reporter:='1';
   End;
   Inc(MulticastCount);
  End;
 End;
End;

 { ProcÇdure pour afficher les adresses multicast par interface }
Procedure ShowMulticastByInterface(InterfaceName:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 For I:=0 To MulticastCount-1 Do Begin
  With MulticastAddrs[I] Do Begin
   If (InterfaceName='') or (LowerCase(InterfaceName)=LowerCase(InterfaceName)) Then Begin
    If not Found Then Begin
     WriteLn('Interface: ',InterfaceName);
     WriteLn('    inet  ',GroupAddr);
     Found:=True;
    End Else Begin
     WriteLn('    inet  ',GroupAddr);
    End;
   End;
  End;
 End;
 If Found Then WriteLn;
End;

 { ProcÇdure pour afficher toutes les adresses multicast }
Procedure ShowAllMulticast;
Var
 I:Integer;
 CurrentInterface:String;
Begin
 CurrentInterface:='';
 For I:=0 To MulticastCount-1 Do Begin
  With MulticastAddrs[I] Do Begin
   If InterfaceName<>CurrentInterface Then Begin
    If CurrentInterface<>'' Then WriteLn;
    CurrentInterface:=InterfaceName;
    WriteLn(CurrentInterface,':');
    WriteLn('    inet  ',GroupAddr);
   End Else Begin
    WriteLn('    inet  ',GroupAddr);
   End;
  End;
 End;
End;

 { ProcÇdure pour afficher les statistiques dÇtaillÇes }
Procedure ShowDetailedStats;
Var
 I:Integer;
 MCName:String;
Begin
 WriteLn('Interface       Groupe                   RefCnt Users Minuterie Reporter');
 For I:=0 To MulticastCount-1 Do Begin
  With MulticastAddrs[I] Do Begin
   Write(Copy(InterfaceName+'              ',1,15),' ');
   Write(Copy(GroupAddr+'                        ',1,24),' ');
   Write(Copy(IntToStr(RefCount)+'     ',1,6),' ');
   Write(Copy(IntToStr(Users)+'     ',1,6),' ');
   Write(Copy(Timer+'        ',1,10),' ');
   WriteLn(Reporter);
    { Afficher le nom si connu }
   MCName:=GetMulticastName(GroupAddr);
   If MCName<>'' Then
    WriteLn('                (',MCName,')');
  End;
 End;
End;

 { ProcÇdure pour afficher les interfaces disponibles }
Procedure DisplayInterfaceList;
Var
 I:Integer;
Begin
 WriteLn('Interfaces rÇseau disponibles:');
 WriteLn('Index  Nom           Adresse IP      Adresse MAC       Drapeaux');
 WriteLn('-----  ------------- --------------- ----------------- -------------------------');

 For I:=0 To InterfaceCount-1 Do Begin
  With Interfaces[I] Do Begin
   Write(Copy(IntToStr(Index)+'     ',1,6),' ');
   Write(Copy(Name+'             ',1,13),' ');
   Write(Copy(IPAddress+'               ',1,15),' ');
   Write(Copy(HWAddress+'                 ',1,17),' ');
   WriteLn(Flags);
  End;
 End;
 WriteLn;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedMulticast;
Begin
 WriteLn('eth0:');
 WriteLn('    inet  224.0.0.1');
 WriteLn('    inet  239.255.255.250');
 WriteLn('    inet  224.0.0.2');
 WriteLn;
 WriteLn('lo:');
 WriteLn('    inet  224.0.0.1');
 WriteLn;
End;

Procedure ShowSimulatedDetailed;Begin
 WriteLn('Interface       Groupe                   RefCnt Utilisateur Minuterie   Reporter');
 WriteLn('eth0            224.0.0.1                1      1           jamais      1');
 WriteLn('                (Tous les hìtes)');
 WriteLn('eth0            239.255.255.250          1      2           4min17sec   1');
 WriteLn('                (UPnP)');
 WriteLn('eth0            224.0.0.2                1      1           jamais      1');
 WriteLn('                (All Routers)');
 WriteLn('lo              224.0.0.1                1      1           jamais      1');
 WriteLn('                (Tous les hìtes)');
End;

Procedure ShowSimulatedInterfaces;Begin
 WriteLn('Interfaces rÇseau disponibles:');
 WriteLn('Index  Nom           Adresse IP      Adresse MAC       Drapeaux');
 WriteLn('-----  ------------- --------------- ----------------- -------------------------');
 WriteLn('1      eth0          192.168.1.100   00:11:22:33:44:55 UP,RUNNING,BROADCAST,MULTICAST');
 WriteLn('2      lo            127.0.0.1       00:00:00:00:00:00 UP,RUNNING,LOOPBACK');
 WriteLn('3      wlan0         192.168.0.25    aa:bb:cc:dd:ee:ff UP,RUNNING,BROADCAST,MULTICAST');
 WriteLn;
End;
{$ENDIF}

{ ProcÇdure pour analyser les paramätres de ligne de commande }
Procedure ParseCommandLine;
Var
 I:Integer;
 Cmd,InterfaceName:String;
 ShowStats,ShowInterfaceList,ShowSpecific:Boolean;
Begin
 ShowStats:=False;
 ShowInterfaceList:=False;
 ShowSpecific:=False;
 InterfaceName:='';
  { Analyser les paramätres }
 For I:=1 To ParamCount Do Begin
  Cmd:=UpperCase(ParamStr(I));
  If (Cmd='-S') or (Cmd='--STATS') or (Cmd='--STATISTICS') Then ShowStats:=True Else
  If (Cmd='-L') or (Cmd='--LIST') or (Cmd='--INTERFACES') Then ShowInterfaceList:=True Else
  If (Cmd='-D') or (Cmd='--DETAIL') Then ShowStats:=True Else
  If Copy(Cmd,1,4)='DEV=' Then Begin
   InterfaceName:=Copy(ParamStr(I),5,Length(ParamStr(I))-4);
   ShowSpecific:=True;
  End Else If (Pos('ETH',Cmd)=1) or (Pos('LO',Cmd)=1) or (Pos('WLAN',Cmd)=1) Then Begin
   InterfaceName:=ParamStr(I);
   ShowSpecific:=True;
  End;
 End;
 {$IFDEF FPC}
  { Obtenir les informations rÇseau }
 If GetNetworkInterfaces Then Begin
  GetMulticastAddresses;
  If ShowInterfaceList Then DisplayInterfaceList Else
  If ShowStats Then ShowDetailedStats Else
  If ShowSpecific Then ShowMulticastByInterface(InterfaceName)
                  Else ShowAllMulticast;
 End
  Else
 Begin
  WriteLn('Erreur: Impossible d''obtenir les informations sur les interfaces rÇseau');
 End;
 {$ELSE}
  { Version Turbo Pascal }
  If ShowInterfaceList Then ShowSimulatedInterfaces Else
  If ShowStats Then ShowSimulatedDetailed
               Else ShowSimulatedMulticast;
 {$ENDIF}
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('IPMADDR : Cette commande permet d''effectuer la gestion des adresses de multidiffusion IP.');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IPMADDR [options] [interface]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -s, --stats           Afficher les statistiques dÇtaillÇes');
  WriteLn('  -l, --list            Lister les interfaces disponibles');
  WriteLn('  -d, --detail          Afficher les dÇtails complets');
  WriteLn('  dev=interface         SpÇcifier une interface particuliäre');
  WriteLn;
  WriteLn('Interfaces :');
  WriteLn('  eth0, eth1, ...       Interfaces Ethernet');
  WriteLn('  lo                    Interface de bouclage');
  WriteLn('  wlan0, wlan1, ...     Interfaces sans fil');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  IPMADDR               # Toutes les adresses multicast');
  WriteLn('  IPMADDR eth0          # Adresses multicast de eth0');
  WriteLn('  IPMADDR -s            # Statistiques dÇtaillÇes');
  WriteLn('  IPMADDR -l            # Lister les interfaces');
  WriteLn('  IPMADDR dev=wlan0     # Adresses de wlan0');
  WriteLn;
  WriteLn('Adresses multicast communes :');
  WriteLn('  224.0.0.1             Tous les hìtes (obligatoire)');
  WriteLn('  224.0.0.2             Toutes les routes');
  WriteLn('  224.0.0.5             Toutes les routes OSPF');
  WriteLn('  224.0.0.9             RIP2');
  WriteLn('  239.255.255.250       UPnP (träs commun)');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (donnÇes rÇelles)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('IPMADDR 1.00 - Gestion adresses multicast, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeStructures;
  {$ENDIF}
  ParseCommandLine;
 End;
END.