{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program LAN;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, Winsock;

Const
  { Constantes pour l'API Windows }
 MAX_ADAPTER_NAME_LENGTH = 256;
 MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
 MAX_ADAPTER_ADDRESS_LENGTH = 8;
 ERROR_BUFFER_OVERFLOW = 111;
 NO_ERROR = 0;

Type
 { Structures pour GetAdaptersInfo }
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
  AdapterName:Array[0..MAX_ADAPTER_NAME_LENGTH+3] of AnsiChar;
  Description:Array[0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of AnsiChar;
  AddressLength:UINT;
  Address:Array[0..MAX_ADAPTER_ADDRESS_LENGTH-1] of Byte;
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

 { Structure pour les informations d'adaptateur rÇseau }
 TAdapterInfo = Record
  AdapterName:String;
  Description:String;
  MACAddress:String;
  IPAddress:String;
  SubnetMask:String;
  Gateway:String;
  DHCPEnabled:Boolean;
  AdapterType:String;
 End;

 { Fonction externe GetAdaptersInfo }
 Function GetAdaptersInfo(pAdapterInfo:PIP_ADAPTER_INFO;Var pOutBufLen:ULONG):DWORD;stdcall;external 'iphlpapi.dll';

 { Fonction externe GetIfEntry }
 Function GetIfEntry(pIfRow:Pointer):DWORD;stdcall;external 'iphlpapi.dll';

Var
 WSAData:TWSADATA;
 AdapterList:Array[0..15] of TAdapterInfo;
 AdapterCount:Integer;
{$ELSE}
 Uses DOS;
{$ENDIF}

{ Variables globales }
Var
 I:Integer;

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
{$ENDIF}

 { Fonction pour convertir un nombre en hexadÇcimal }
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

{$IFNDEF FPC}
 { Fonction pour obtenir les informations rÇseau via interruptions DOS/BIOS }
Procedure GetLANInfoDOS;
Var
 Regs:Registers;
 NetwareActive:Boolean;
 IPXActive:Boolean;
 Int2FResult:Byte;
Begin
 WriteLn('=== DÇtection des protocoles rÇseau (DOS/BIOS) ===');
 WriteLn;
  { VÇrifier la prÇsence de Novell NetWare (INT 21h, AH=F0h) }
 NetwareActive:=False;
 Regs.AH:=$F0;
 Intr($21,Regs);
 If Regs.AL=$FF Then Begin
  WriteLn('[V] NetWare : DÇtectÇ');
  NetwareActive:=True;
 End
  Else
 WriteLn('[V] NetWare : Non dÇtectÇ');
  { VÇrifier IPX/SPX via interruption multiplexeur (INT 2Fh) }
 IPXActive:=False;
 Regs.AX:=$7A00;  { VÇrification d'installation IPX }
 Intr($2F,Regs);
 If Regs.AL=$FF Then Begin
  WriteLn('[V] IPX/SPX : DÇtectÇ');
  IPXActive:=True;
  WriteLn('    Version IPX : ',IntToHex(Regs.BH,2),'.',IntToHex(Regs.BL,2));
 End
  Else
 WriteLn('[V] IPX/SPX : Non dÇtectÇ');
  { VÇrifier Microsoft Network (MS-NET) }
 Regs.AX:=$B800;  { VÇrification d'installation MS-NET }
 Intr($2F,Regs);
 If Regs.AL<>0 Then WriteLn('[V] MS-NET : DÇtectÇ')
               Else WriteLn('[V] MS-NET : Non dÇtectÇ');
  { VÇrifier MSCDEX (CD-ROM extensions) }
 Regs.AX:=$1500;
 Intr($2F,Regs);
 If Regs.BX<>0 Then WriteLn('[V] MSCDEX : DÇtectÇ (',IntToStr(Regs.BX),' lecteurs)')
               Else WriteLn('[V] MSCDEX : Non dÇtectÇ');
  { VÇrifier le redirecteur rÇseau }
 Regs.AX:=$1100;
 Intr($2F,Regs);
 If Regs.AL=$FF Then WriteLn('[V] Redirecteur rÇseau : DÇtectÇ')
                Else WriteLn('[V] Redirecteur rÇseau : Non dÇtectÇ');
 WriteLn;
  { Informations sur les lecteurs rÇseau }
 WriteLn('=== Lecteurs rÇseau cartographiÇs ===');
 For I:=3 To 25 Do Begin  { C: Ö Z: }
  Regs.AX:=$440E;         { IOCTL: Demande la cartographie logique d'unitÇ de disque }
  Regs.BL:=I;             { NumÇro de lecteur (1=A, 2=B, 3=C, etc.) }
  Intr($21,Regs);
  If (Regs.Flags and 1)=0 Then Begin  { Pas d'erreur }
   If Regs.AL<>I Then
    WriteLn(Chr(I+Ord('A')-1),': -> Lecteur rÇseau (cartographiÇ sur ',Chr(Regs.AL+Ord('A')-1),')')
   Else Begin
    { VÇrifier si c'est un lecteur rÇseau via INT 21h AX=4409h }
    Regs.AX:=$4409;
    Regs.BL:=I;
    Intr($21,Regs);
    If (Regs.Flags and 1)=0 Then Begin
     If (Regs.DX and $1000)<>0 Then
      WriteLn(Chr(I+Ord('A')-1),': -> Lecteur rÇseau');
    End;
   End;
  End;
 End;
End;
{$ENDIF}

{$IFDEF FPC}
 { Fonction pour convertir un type d'adaptateur en texte }
Function AdapterTypeToString(AdapterType:UINT):String;
Begin
 Case AdapterType Of
  1:AdapterTypeToString:='Autre';
  6:AdapterTypeToString:='Ethernet';
  9:AdapterTypeToString:='Token Ring';
  15:AdapterTypeToString:='FDDI';
  20:AdapterTypeToString:='ATM';
  23:AdapterTypeToString:='PPP';
  24:AdapterTypeToString:='Bouclage (Loopback)';
  71:AdapterTypeToString:='IEEE 802.11 (Wi-Fi)';
  Else AdapterTypeToString:='Inconnu ('+IntToStr(AdapterType)+')';
 End;
End;

 { Fonction pour obtenir de vraies informations d'adaptateurs rÇseau }
Function GetRealAdapterInfo:Boolean;
Var
 pAdapterInfo,pAdapter:PIP_ADAPTER_INFO;
 OutBufLen:ULONG;
 RetVal:DWORD;
 I:Integer;
 MACStr:String;
Begin
 GetRealAdapterInfo:=False;
 AdapterCount:=0;
 OutBufLen:=0;
  { Premiäre appel pour obtenir la taille nÇcessaire }
 RetVal:=GetAdaptersInfo(nil,OutBufLen);
 If RetVal<>ERROR_BUFFER_OVERFLOW Then Exit;
  { Allouer la mÇmoire }
 GetMem(pAdapterInfo,OutBufLen);
 Try
   { Obtenir les informations des adaptateurs }
  RetVal:=GetAdaptersInfo(pAdapterInfo,OutBufLen);
  If RetVal=NO_ERROR Then Begin
   pAdapter:=pAdapterInfo;
   While (pAdapter<>nil) and (AdapterCount<16) Do Begin
    With AdapterList[AdapterCount] Do Begin
     AdapterName:=StrPas(pAdapter^.AdapterName);
     Description:=StrPas(pAdapter^.Description);
      { Formater l'adresse MAC }
     MACStr:='';
     For I:=0 To pAdapter^.AddressLength-1 Do Begin
      If I>0 Then MACStr:=MACStr+':';
      MACStr:=MACStr+IntToHex(pAdapter^.Address[I],2);
     End;
     MACAddress:=MACStr;
      { Adresse IP }
     IPAddress:=StrPas(pAdapter^.IpAddressList.IpAddress);
     SubnetMask:=StrPas(pAdapter^.IpAddressList.IpMask);
     Gateway:=StrPas(pAdapter^.GatewayList.IpAddress);
     DHCPEnabled:=(pAdapter^.DhcpEnabled<>0);
     AdapterType:=AdapterTypeToString(pAdapter^.AdapterType);
    End;
    Inc(AdapterCount);
    pAdapter:=PIP_ADAPTER_INFO(pAdapter^.Next);
   End;
   GetRealAdapterInfo:=True;
  End;
 Finally
  FreeMem(pAdapterInfo);
 End;
End;

 { ProcÇdure pour obtenir les informations rÇseau Windows }
Procedure GetLANInfoWindows;
Var
 HostName:Array[0..255] of AnsiChar;
 HostEnt:PHostEnt;
 IPAddr:String;
 InAddr:TInAddr;
 I:Integer;
Begin
 WriteLn('=== Informations rÇseau Windows ===');
 WriteLn;
  { Initialiser Winsock }
 If WSAStartup($0202,WSAData)<>0 Then Begin
  WriteLn('Erreur d''initialisation Winsock');
  Exit;
 End;
  { Obtenir le nom d'hìte }
 If gethostname(HostName,SizeOf(HostName))=0 Then Begin
  WriteLn('Nom d''hìte : ',StrPas(HostName));
   { RÇsoudre l'adresse IP principale }
  HostEnt:=gethostbyname(HostName);
  If HostEnt<>nil Then Begin
   Move(HostEnt^.h_addr_list^^,InAddr,SizeOf(InAddr));
   IPAddr:=inet_ntoa(InAddr);
   WriteLn('Adresse IP principale : ',IPAddr);
  End;
 End
  Else
 WriteLn('Impossible d''obtenir le nom d''hìte');
 WSACleanup;
End;

 { ProcÇdure pour afficher les vraies informations des adaptateurs }
Procedure ShowRealAdapters;
Var
 I:Integer;
Begin
 WriteLn;
 WriteLn('=== Adaptateurs rÇseau dÇtectÇs ===');
 If GetRealAdapterInfo Then Begin
  WriteLn('Nombre d''adaptateurs trouvÇs : ',AdapterCount);
  WriteLn;
  For I:=0 To AdapterCount-1 Do Begin
   With AdapterList[I] Do Begin
    WriteLn('Adaptateur ',I+1,' :');
    WriteLn('  Nom         : ',AdapterName);
    WriteLn('  Description : ',Description);
    WriteLn('  Type        : ',AdapterType);
    WriteLn('  Adresse MAC : ',MACAddress);
    WriteLn('  Adresse IP  : ',IPAddress);
    WriteLn('  Masque      : ',SubnetMask);
    WriteLn('  Passerelle  : ',Gateway);
    If(DHCPEnabled)Then WriteLn('  DHCP        : ActivÇ')
                   Else WriteLn('  DHCP        : DÇsactivÇ');
    WriteLn;
   End;
  End;
 End
  Else
 Begin
  WriteLn('Erreur lors de la rÇcupÇration des informations d''adaptateurs');
  WriteLn('Utilisation d''informations simulÇes...');
  WriteLn;
  WriteLn('Adaptateur Ethernet 1 :');
  WriteLn('  Description : Carte rÇseau Ethernet (simul√©)');
  WriteLn('  Adresse MAC : 00:1A:2B:3C:4D:5E');
  WriteLn('  Adresse IP  : 192.168.1.100');
  WriteLn('  Masque      : 255.255.255.0');
  WriteLn('  Passerelle  : 192.168.1.1');
  WriteLn('  DHCP        : ActivÇe');
 End;
End;

{ ProcÇdure pour afficher les statistiques rÇseau rÇelles }
Procedure ShowNetworkStats;
Type
 { Structure MIB_IFROW pour les statistiques d'interface }
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

Var
 IfRow:MIB_IFROW;
 RetVal:DWORD;
 TotalPacketsIn,TotalPacketsOut:DWORD;
 TotalErrorsIn,TotalErrorsOut:DWORD;
 I:Integer;
Begin
 WriteLn;
 WriteLn('=== Statistiques rÇseau ===');
  { Initialiser les totaux }
 TotalPacketsIn:=0;
 TotalPacketsOut:=0;
 TotalErrorsIn:=0;
 TotalErrorsOut:=0;
  { Parcourir les interfaces (gÇnÇralement de 1 Ö 10) }
 For I:=1 To 10 Do Begin
  FillChar(IfRow,SizeOf(IfRow),0);
  IfRow.dwIndex:=I;
  RetVal:=GetIfEntry(@IfRow);
  If RetVal=NO_ERROR Then Begin
   { Interface trouvÇe, additionner les statistiques }
   Inc(TotalPacketsIn,IfRow.dwInUcastPkts+IfRow.dwInNUcastPkts);
   Inc(TotalPacketsOut,IfRow.dwOutUcastPkts+IfRow.dwOutNUcastPkts);
   Inc(TotalErrorsIn,IfRow.dwInErrors+IfRow.dwInDiscards);
   Inc(TotalErrorsOut,IfRow.dwOutErrors+IfRow.dwOutDiscards);
    { Afficher les informations de la premiäre interface active }
   If (I=1) and (IfRow.dwOperStatus=1) Then Begin
    WriteLn('Interface principale (Index ',IfRow.dwIndex,'):');
    WriteLn('  Vitesse         : ',IfRow.dwSpeed div 1000000,' Mbps');
    WriteLn('  MTU             : ',IfRow.dwMtu,' octets');
    If IfRow.dwOperStatus=1 Then
     WriteLn('  Statut          : Actif')
    Else
     WriteLn('  Statut          : Inactif');
   End;
  End;
 End;

 { Afficher les totaux }
 WriteLn('Statistiques globales :');
 WriteLn('  Paquets reáus       : ',TotalPacketsIn);
 WriteLn('  Paquets transmis    : ',TotalPacketsOut);
 WriteLn('  Erreurs rÇception   : ',TotalErrorsIn);
 WriteLn('  Erreurs transmission: ',TotalErrorsOut);
End;
{$ENDIF}

{ ProcÇdure pour dÇtecter les protocoles rÇseau communs }
Procedure DetectNetworkProtocols;Begin
 WriteLn('=== Protocoles rÇseau supportÇs ===');
 {$IFDEF FPC}
 WriteLn('[V] TCP/IP   : SupportÇ (Winsock)');
 WriteLn('[V] UDP      : SupportÇ (Winsock)');
 WriteLn('[V] ICMP     : SupportÇ (Winsock)');
 WriteLn('[?] NetBEUI  : DÇtection requise');
 WriteLn('[?] IPX/SPX  : DÇtection requise');
 {$ELSE}
 WriteLn('[?] TCP/IP   : VÇrification via interruptions');
 WriteLn('[?] NetBEUI  : VÇrification via interruptions');
 WriteLn('[?] IPX/SPX  : VÇrification via interruptions');
 WriteLn('[?] NetBIOS  : VÇrification via INT 5Ch');
 {$ENDIF}
End;

 { ProcÇdure principale d'affichage des informations LAN }
Procedure ShowLANInfo;Begin
 WriteLn('Informations rÇseau LAN - NETWORKKIT-P');
 WriteLn('=======================================');
 WriteLn;
 {$IFDEF FPC}
  GetLANInfoWindows;
  ShowRealAdapters;
  ShowNetworkStats;
 {$ELSE}
  GetLANInfoDOS;
 {$ENDIF}
 WriteLn;
 DetectNetworkProtocols;
 WriteLn;
 WriteLn('Analyse terminÇe.');
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('LAN : Cette commande permet d''affichage des informations rÇseau local');
  WriteLn;
  WriteLn('Syntaxe : LAN');
  WriteLn;
  WriteLn('Cette commande affiche les informations sur le rÇseau local suivante :');
  WriteLn('˛ Adaptateurs rÇseau et leurs propriÇtÇs');
  WriteLn('˛ Adresses IP, masques et passerelles');
  WriteLn('˛ Protocoles rÇseau installÇs');
  WriteLn('˛ Statistiques de transmission/rÇception');
  WriteLn('˛ Lecteurs rÇseau cartographiÇs (DOS)');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (interruptions) et Free Pascal (API Windows)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('LAN 1.00 - Informations rÇseau LAN, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  Randomize;
  ShowLANInfo;
 End;
END.
