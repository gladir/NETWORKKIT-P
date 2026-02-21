{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande ifconfig (configuration interface))
}

Program IFCONFIG;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour les informations d'interface }
 TInterfaceInfo = Record
  Name:String;
  DisplayName:String;
  Description:String;
  IPAddress:String;
  NetMask:String;
  Broadcast:String;
  Gateway:String;
  MACAddress:String;
  MTU:DWORD;
  Speed:DWORD;
  Status:String;
  InterfaceType:String;
  DHCPEnabled:Boolean;
  PacketsReceived:DWORD;
  PacketsTransmitted:DWORD;
  BytesReceived:DWORD;
  BytesTransmitted:DWORD;
  ErrorsReceived:DWORD;
  ErrorsTransmitted:DWORD;
 End;

 { Structure IP_ADAPTER_INFO étendue }
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

 { Structure MIB_IFROW pour les statistiques }
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

Const
 { Constantes pour les types d'adaptateurs }
 MIB_IF_TYPE_OTHER = 1;
 MIB_IF_TYPE_ETHERNET_CSMACD = 6;
 MIB_IF_TYPE_ISO88025_TOKENRING = 9;
 MIB_IF_TYPE_FDDI = 15;
 MIB_IF_TYPE_PPP = 23;
 MIB_IF_TYPE_SOFTWARE_LOOPBACK = 24;
 MIB_IF_TYPE_ATM = 37;
 MIB_IF_TYPE_IEEE80211 = 71;

 { Constantes d'erreur }
 NO_ERROR = 0;
 ERROR_BUFFER_OVERFLOW = 111;
 ERROR_INSUFFICIENT_BUFFER = 122;

Var
 InterfaceList:Array[0..31] of TInterfaceInfo;
 InterfaceCount:Integer;

{ Fonctions externes }
Function GetAdaptersInfo(pAdapterInfo:PIP_ADAPTER_INFO;Var pOutBufLen:ULONG):DWORD;stdcall;external 'iphlpapi.dll';
Function GetIfEntry(pIfRow:PMIB_IFROW):DWORD;stdcall;external 'iphlpapi.dll';
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

{ Fonction pour convertir un nombre en hexadécimal }
Function IntToHex(Value:Integer;Digits:Integer):String;
Const
 HexChars:String='0123456789ABCDEF';
Var
 HexResult:String;
 I:Integer;
Begin
 HexResult:='';
 For I:=1 To Digits Do Begin
  HexResult:=HexChars[(Value and 15)+1]+HexResult;
  Value:=Value shr 4;
 End;
 IntToHex:=HexResult;
End;

{$IFDEF FPC}
{ Fonction pour convertir un type d'interface en nom }
Function GetInterfaceTypeName(InterfaceType:DWORD):String;
Begin
 Case InterfaceType Of
  MIB_IF_TYPE_OTHER:GetInterfaceTypeName:='Other';
  MIB_IF_TYPE_ETHERNET_CSMACD:GetInterfaceTypeName:='Ethernet';
  MIB_IF_TYPE_ISO88025_TOKENRING:GetInterfaceTypeName:='Token Ring';
  MIB_IF_TYPE_FDDI:GetInterfaceTypeName:='FDDI';
  MIB_IF_TYPE_PPP:GetInterfaceTypeName:='PPP';
  MIB_IF_TYPE_SOFTWARE_LOOPBACK:GetInterfaceTypeName:='Loopback';
  MIB_IF_TYPE_ATM:GetInterfaceTypeName:='ATM';
  MIB_IF_TYPE_IEEE80211:GetInterfaceTypeName:='IEEE 802.11';
 Else
  GetInterfaceTypeName:='Unknown ('+IntToStr(InterfaceType)+')';
 End;
End;

{ Fonction pour formater une adresse MAC }
Function FormatMAC(MACBytes:Array of Byte;Len:Integer):String;
Var
 I:Integer;
 MACResult:String;
Begin
 MACResult:='';
 For I:=0 To Len-1 Do Begin
  If I>0 Then MACResult:=MACResult+':';
  MACResult:=MACResult+LowerCase(IntToHex(MACBytes[I],2));
 End;
 FormatMAC:=MACResult;
End;

{ Fonction pour calculer l'adresse de broadcast }
Function CalculateBroadcast(IPAddr,NetMask:String):String;
Var
 IP,Mask:Array[0..3] of Byte;
 Broadcast:Array[0..3] of Byte;
 I,DotPos,Start:Integer;
 PartStr:String;
 PartIndex:Integer;
Begin
 { Parser l'adresse IP }
 PartIndex:=0;
 Start:=1;
 For I:=1 To Length(IPAddr)+1 Do Begin
  If (I>Length(IPAddr)) or (IPAddr[I]='.') Then Begin
   PartStr:=Copy(IPAddr,Start,I-Start);
   If (PartIndex<4) and (PartStr<>'') Then Begin
    Val(PartStr,IP[PartIndex]);
    Inc(PartIndex);
   End;
   Start:=I+1;
  End;
 End;
 
 { Parser le masque }
 PartIndex:=0;
 Start:=1;
 For I:=1 To Length(NetMask)+1 Do Begin
  If (I>Length(NetMask)) or (NetMask[I]='.') Then Begin
   PartStr:=Copy(NetMask,Start,I-Start);
   If (PartIndex<4) and (PartStr<>'') Then Begin
    Val(PartStr,Mask[PartIndex]);
    Inc(PartIndex);
   End;
   Start:=I+1;
  End;
 End;
 
 { Calculer broadcast }
 For I:=0 To 3 Do
  Broadcast[I]:=IP[I] or (not Mask[I]);
 
 CalculateBroadcast:=IntToStr(Broadcast[0])+'.'+IntToStr(Broadcast[1])+'.'+
                    IntToStr(Broadcast[2])+'.'+IntToStr(Broadcast[3]);
End;

{ Fonction pour formater les octets en unités lisibles }
Function FormatBytes(Bytes:DWORD):String;
Begin
 If Bytes<1024 Then
  FormatBytes:=IntToStr(Bytes)+' B'
 Else If Bytes<1048576 Then
  FormatBytes:=IntToStr(Bytes div 1024)+' KB'
 Else If Bytes<1073741824 Then
  FormatBytes:=IntToStr(Bytes div 1048576)+' MB'
 Else
  FormatBytes:=IntToStr(Bytes div 1073741824)+' GB';
End;

{ Procédure pour obtenir les informations des interfaces }
Function GetInterfaceInfo:Boolean;
Var
 pAdapterInfo,pAdapter:PIP_ADAPTER_INFO;
 OutBufLen:ULONG;
 RetVal:DWORD;
 IfRow:MIB_IFROW;
 I:Integer;
Begin
 GetInterfaceInfo:=False;
 InterfaceCount:=0;
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
   While (pAdapter<>nil) and (InterfaceCount<32) Do Begin
    With InterfaceList[InterfaceCount] Do Begin
     Name:='eth'+IntToStr(pAdapter^.Index);
     DisplayName:=StrPas(pAdapter^.AdapterName);
     Description:=StrPas(pAdapter^.Description);
     IPAddress:=StrPas(pAdapter^.IpAddressList.IpAddress);
     NetMask:=StrPas(pAdapter^.IpAddressList.IpMask);
     Gateway:=StrPas(pAdapter^.GatewayList.IpAddress);
     MACAddress:=FormatMAC(pAdapter^.Address,pAdapter^.AddressLength);
     DHCPEnabled:=(pAdapter^.DhcpEnabled<>0);
     
     { Calculer broadcast }
     If (IPAddress<>'0.0.0.0') and (NetMask<>'0.0.0.0') Then
      Broadcast:=CalculateBroadcast(IPAddress,NetMask)
     Else
      Broadcast:='0.0.0.0';
     
     { Obtenir les statistiques via GetIfEntry }
     FillChar(IfRow,SizeOf(IfRow),0);
     IfRow.dwIndex:=pAdapter^.Index;
     If GetIfEntry(@IfRow)=NO_ERROR Then Begin
      MTU:=IfRow.dwMtu;
      Speed:=IfRow.dwSpeed;
      InterfaceType:=GetInterfaceTypeName(IfRow.dwType);
      PacketsReceived:=IfRow.dwInUcastPkts+IfRow.dwInNUcastPkts;
      PacketsTransmitted:=IfRow.dwOutUcastPkts+IfRow.dwOutNUcastPkts;
      BytesReceived:=IfRow.dwInOctets;
      BytesTransmitted:=IfRow.dwOutOctets;
      ErrorsReceived:=IfRow.dwInErrors;
      ErrorsTransmitted:=IfRow.dwOutErrors;
      
      If IfRow.dwOperStatus=1 Then
       Status:='UP'
      Else
       Status:='DOWN';
     End Else Begin
      MTU:=1500;
      Speed:=0;
      InterfaceType:='Unknown';
      Status:='UNKNOWN';
     End;
    End;
    Inc(InterfaceCount);
    pAdapter:=PIP_ADAPTER_INFO(pAdapter^.Next);
   End;
   GetInterfaceInfo:=True;
  End;
 Finally
  FreeMem(pAdapterInfo);
 End;
End;

{ Procédure pour afficher une interface (style Linux) }
Procedure ShowInterface(Index:Integer;ShowAll:Boolean);
Var
 FlagsStr:String;
Begin
 With InterfaceList[Index] Do Begin
  { Ne pas afficher les interfaces DOWN sauf si demandé }
  If (Not ShowAll) and (Status='DOWN') and (IPAddress='0.0.0.0') Then Exit;
  
  { Nom de l'interface et drapeaux }
  Write(Name);
  FlagsStr:='';
  If Status='UP' Then FlagsStr:=FlagsStr+'UP ';
  If IPAddress<>'0.0.0.0' Then FlagsStr:=FlagsStr+'RUNNING ';
  If Broadcast<>'0.0.0.0' Then FlagsStr:=FlagsStr+'BROADCAST ';
  If DHCPEnabled Then FlagsStr:=FlagsStr+'DHCP ';
  FlagsStr:=FlagsStr+'MULTICAST';
  
  WriteLn(': flags=<',FlagsStr,'> mtu ',MTU);
  
  { Type d'interface }
  WriteLn('        ',InterfaceType);
  
  { Configuration IP }
  If IPAddress<>'0.0.0.0' Then Begin
   Write('        inet ',IPAddress);
   If NetMask<>'0.0.0.0' Then Write('  netmask ',NetMask);
   If Broadcast<>'0.0.0.0' Then Write('  broadcast ',Broadcast);
   WriteLn;
  End;
  
  { Adresse MAC }
  If (MACAddress<>'') and (MACAddress<>'00:00:00:00:00:00') Then
   WriteLn('        ether ',MACAddress);
  
  { Statistiques }
  WriteLn('        RX packets ',PacketsReceived,'  bytes ',BytesReceived,
          ' (',FormatBytes(BytesReceived),')');
  WriteLn('        RX errors ',ErrorsReceived,'  dropped 0  overruns 0  frame 0');
  WriteLn('        TX packets ',PacketsTransmitted,'  bytes ',BytesTransmitted,
          ' (',FormatBytes(BytesTransmitted),')');
  WriteLn('        TX errors ',ErrorsTransmitted,'  dropped 0  overruns 0  carrier 0');
  WriteLn('        collisions 0');
  
  WriteLn;
 End;
End;

{ Procédure pour afficher toutes les interfaces }
Procedure ShowAllInterfaces(ShowAll:Boolean);
Var
 I:Integer;
Begin
 If GetInterfaceInfo Then Begin
  For I:=0 To InterfaceCount-1 Do
   ShowInterface(I,ShowAll);
 End Else
  WriteLn('Erreur lors de la récupération des informations d''interface');
End;

{ Procédure pour afficher une interface spécifique }
Procedure ShowSpecificInterface(InterfaceName:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 If GetInterfaceInfo Then Begin
  For I:=0 To InterfaceCount-1 Do Begin
   If (InterfaceList[I].Name=InterfaceName) or 
      (Pos(UpperCase(InterfaceName),UpperCase(InterfaceList[I].Description))>0) Then Begin
    ShowInterface(I,True);
    Found:=True;
   End;
  End;
  If Not Found Then
   WriteLn(InterfaceName,': erreur lors de la récupération des drapeaux de l''interface: Périphérique non trouvé');
 End;
End;

{ Procédure pour afficher un résumé des interfaces }
Procedure ShowBriefInterfaces;
Var
 I:Integer;
Begin
 WriteLn('Nom    Etat   Adresse IP       Masque réseau    Adresse MAC');
 WriteLn('------ ------ ---------------- ---------------- -----------------');
 
 If GetInterfaceInfo Then Begin
  For I:=0 To InterfaceCount-1 Do Begin
   With InterfaceList[I] Do Begin
    Write(Name);
    While Length(Name)<7 Do Begin
     Write(' ');
     Name:=Name+' ';
    End;
    
    Write(Status);
    While Length(Status)<7 Do Begin
     Write(' ');
     Status:=Status+' ';
    End;
    
    Write(IPAddress);
    While Length(IPAddress)<17 Do Begin
     Write(' ');
     IPAddress:=IPAddress+' ';
    End;
    
    Write(NetMask);
    While Length(NetMask)<17 Do Begin
     Write(' ');
     NetMask:=NetMask+' ';
    End;
    
    WriteLn(MACAddress);
   End;
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedInterfaces;
Begin
 WriteLn('eth0: flags=<UP,RUNNING,BROADCAST,DHCP,MULTICAST> mtu 1500');
 WriteLn('        Ethernet');
 WriteLn('        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255');
 WriteLn('        ether 00:1a:2b:3c:4d:5e');
 WriteLn('        RX packets 1234  bytes 567890 (554 KB)');
 WriteLn('        RX errors 0  dropped 0  overruns 0  frame 0');
 WriteLn('        TX packets 987  bytes 123456 (120 KB)');
 WriteLn('        TX errors 0  dropped 0  overruns 0  carrier 0');
 WriteLn('        collisions 0');
 WriteLn;
 
 WriteLn('lo: flags=<UP,RUNNING,LOOPBACK> mtu 65536');
 WriteLn('        Loopback');
 WriteLn('        inet 127.0.0.1  netmask 255.0.0.0');
 WriteLn('        RX packets 8  bytes 640 (640 B)');
 WriteLn('        RX errors 0  dropped 0  overruns 0  frame 0');
 WriteLn('        TX packets 8  bytes 640 (640 B)');
 WriteLn('        TX errors 0  dropped 0  overruns 0  carrier 0');
 WriteLn('        collisions 0');
End;

Procedure ShowSimulatedBrief;
Begin
 WriteLn('Nom    Etat   Adresse IP       Masque réseau    Adresse MAC');
 WriteLn('------ ------ ---------------- ---------------- -----------------');
 WriteLn('eth0   UP     192.168.1.100    255.255.255.0    00:1a:2b:3c:4d:5e');
 WriteLn('lo     UP     127.0.0.1        255.0.0.0        00:00:00:00:00:00');
End;
{$ENDIF}

{ Procédure pour analyser les paramètres }
Procedure ParseCommand;
Var
 Cmd:String;
Begin
 If ParamCount<1 Then Begin
  {$IFDEF FPC}
  ShowAllInterfaces(False);
  {$ELSE}
  ShowSimulatedInterfaces;
  {$ENDIF}
  Exit;
 End;
 
 Cmd:=UpperCase(ParamStr(1));
 
 If (Cmd='-A') or (Cmd='--ALL') Then Begin
  {$IFDEF FPC}
  ShowAllInterfaces(True);
  {$ELSE}
  ShowSimulatedInterfaces;
  {$ENDIF}
 End Else If (Cmd='-S') or (Cmd='--SHORT') Then Begin
  {$IFDEF FPC}
  ShowBriefInterfaces;
  {$ELSE}
  ShowSimulatedBrief;
  {$ENDIF}
 End Else If (Cmd[1]<>'-') and (Cmd[1]<>'/') Then Begin
  { Interface spécifique }
  {$IFDEF FPC}
  ShowSpecificInterface(ParamStr(1));
  {$ELSE}
  WriteLn('eth0: flags=<UP,RUNNING,BROADCAST,DHCP,MULTICAST> mtu 1500');
  WriteLn('        Ethernet');
  WriteLn('        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255');
  WriteLn('        ether 00:1a:2b:3c:4d:5e');
  WriteLn('        RX packets 1234  bytes 567890 (554 KB)');
  WriteLn('        RX errors 0  dropped 0  overruns 0  frame 0');
  WriteLn('        TX packets 987  bytes 123456 (120 KB)');
  WriteLn('        TX errors 0  dropped 0  overruns 0  carrier 0');
  WriteLn('        collisions 0');
  {$ENDIF}
 End Else Begin
  WriteLn('Option inconnue : ',Cmd);
  WriteLn('Options disponibles : -a, -s, interface');
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('IFCONFIG : Configuration et affichage des interfaces réseau');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IFCONFIG                    Afficher les interfaces actives');
  WriteLn('  IFCONFIG -a                 Afficher toutes les interfaces');
  WriteLn('  IFCONFIG -s                 Affichage résumé');
  WriteLn('  IFCONFIG interface          Afficher une interface spécifique');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  interface   Nom de l''interface (ex: eth0, eth1)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  IFCONFIG                    # Afficher interfaces actives');
  WriteLn('  IFCONFIG -a                 # Toutes les interfaces');
  WriteLn('  IFCONFIG -s                 # Résumé tabulaire');
  WriteLn('  IFCONFIG eth0               # Interface spécifique');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (données réelles)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('IFCONFIG 1.00 - Configuration interface réseau, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  ParseCommand;
 End;
END.
