{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande Route (table de routage))
}

Program ROUTE;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
  { Structure pour une entrÇe de table de routage }
 TRouteEntry = Record
  Destination:String;
  Gateway:String;
  Netmask:String;
  Flags:String;
  Metric:DWORD;
  RefCount:DWORD;
  UseCount:DWORD;
  InterfaceName:String;
  InterfaceIndex:DWORD;
 End;

  { Structure MIB_IPFORWARDROW pour l'API Windows }
 MIB_IPFORWARDROW = Packed Record
  dwForwardDest:DWORD;
  dwForwardMask:DWORD;
  dwForwardPolicy:DWORD;
  dwForwardNextHop:DWORD;
  dwForwardIfIndex:DWORD;
  dwForwardType:DWORD;
  dwForwardProto:DWORD;
  dwForwardAge:DWORD;
  dwForwardNextHopAS:DWORD;
  dwForwardMetric1:DWORD;
  dwForwardMetric2:DWORD;
  dwForwardMetric3:DWORD;
  dwForwardMetric4:DWORD;
  dwForwardMetric5:DWORD;
 End;

  { Structure MIB_IPFORWARDTABLE }
 MIB_IPFORWARDTABLE = Packed Record
  dwNumEntries:DWORD;
  table:Array[0..0] of MIB_IPFORWARDROW;
 End;
 PMIB_IPFORWARDTABLE = ^MIB_IPFORWARDTABLE;

Const
  { Constantes pour les types de route }
 MIB_IPROUTE_TYPE_OTHER = 1;
 MIB_IPROUTE_TYPE_INVALID = 2;
 MIB_IPROUTE_TYPE_DIRECT = 3;
 MIB_IPROUTE_TYPE_INDIRECT = 4;

  { Constantes pour les protocoles }
 MIB_IPPROTO_OTHER = 1;
 MIB_IPPROTO_LOCAL = 2;
 MIB_IPPROTO_NETMGMT = 3;
 MIB_IPPROTO_ICMP = 4;
 MIB_IPPROTO_EGP = 5;
 MIB_IPPROTO_GGP = 6;
 MIB_IPPROTO_HELLO = 7;
 MIB_IPPROTO_RIP = 8;
 MIB_IPPROTO_IS_IS = 9;
 MIB_IPPROTO_ES_IS = 10;
 MIB_IPPROTO_CISCO = 11;
 MIB_IPPROTO_BBN = 12;
 MIB_IPPROTO_OSPF = 13;
 MIB_IPPROTO_BGP = 14;

 NO_ERROR = 0;
 ERROR_INSUFFICIENT_BUFFER = 122;

Var
 RouteTable:Array[0..255] of TRouteEntry;
 RouteCount:Integer;

 { Fonction externe GetIpForwardTable }
Function GetIpForwardTable(pIpForwardTable:PMIB_IPFORWARDTABLE;
                           Var pdwSize:ULONG;bOrder:BOOL):DWORD;stdcall;external 'iphlpapi.dll';

 { Fonction externe CreateIpForwardEntry }
Function CreateIpForwardEntry(Var pRoute:MIB_IPFORWARDROW):DWORD;stdcall;external 'iphlpapi.dll';

 { Fonction externe DeleteIpForwardEntry }
Function DeleteIpForwardEntry(Var pRoute:MIB_IPFORWARDROW):DWORD;stdcall;external 'iphlpapi.dll';
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
 { Fonction pour convertir une adresse DWORD en chaåne IP }
Function DWORDToIP(IPAddr:DWORD):String;
Begin
 DWORDToIP:=IntToStr(IPAddr and $FF)+'.'+
           IntToStr((IPAddr shr 8) and $FF)+'.'+
           IntToStr((IPAddr shr 16) and $FF)+'.'+
           IntToStr((IPAddr shr 24) and $FF);
End;

 { Fonction pour convertir une chaåne IP en DWORD }
Function IPToDWORD(IPStr:String):DWORD;
Var
 Parts:Array[0..3] of Byte;
 I,Pos,Start:Integer;
 PartStr:String;
 PartIndex:Integer;
Begin
 IPToDWORD:=0;
 PartIndex:=0;
 Start:=1;
 For I:=1 To Length(IPStr)+1 Do Begin
  If (I>Length(IPStr)) or (IPStr[I]='.') Then Begin
   PartStr:=Copy(IPStr,Start,I-Start);
   If (PartIndex<4) and (PartStr<>'') Then Begin
    Parts[PartIndex]:=StrToInt(PartStr) and $FF;
    Inc(PartIndex);
   End;
   Start:=I+1;
  End;
 End;
 If PartIndex=4 Then IPToDWORD:=Parts[0] or (Parts[1] shl 8) or (Parts[2] shl 16) or (Parts[3] shl 24);
End;

 { Fonction pour obtenir le nom du protocole }
Function GetProtoName(Proto:DWORD):String;Begin
 Case Proto Of
  MIB_IPPROTO_OTHER:GetProtoName:='other';
  MIB_IPPROTO_LOCAL:GetProtoName:='local';
  MIB_IPPROTO_NETMGMT:GetProtoName:='netmgmt';
  MIB_IPPROTO_ICMP:GetProtoName:='icmp';
  MIB_IPPROTO_EGP:GetProtoName:='egp';
  MIB_IPPROTO_GGP:GetProtoName:='ggp';
  MIB_IPPROTO_HELLO:GetProtoName:='hello';
  MIB_IPPROTO_RIP:GetProtoName:='rip';
  MIB_IPPROTO_IS_IS:GetProtoName:='is-is';
  MIB_IPPROTO_ES_IS:GetProtoName:='es-is';
  MIB_IPPROTO_CISCO:GetProtoName:='cisco';
  MIB_IPPROTO_BBN:GetProtoName:='bbn';
  MIB_IPPROTO_OSPF:GetProtoName:='ospf';
  MIB_IPPROTO_BGP:GetProtoName:='bgp';
 Else
  GetProtoName:='unknown';
 End;
End;

 { Fonction pour gÇnÇrer les drapeaux de route }
Function GetRouteFlags(RouteType:DWORD;Dest,Mask:DWORD):String;
Var
 Flags:String;
Begin
 Flags:='U';  { Route active }
 If RouteType=MIB_IPROUTE_TYPE_INDIRECT Then Flags:=Flags+'G';  { Route via passerelle }
 If(Dest<>0)and(Mask=$FFFFFFFF)Then Flags:=Flags+'H';  { Route hìte }
 GetRouteFlags:=Flags;
End;

 { ProcÇdure pour obtenir la table de routage Windows }
Function GetRouteTable:Boolean;
Var
 pIpForwardTable:PMIB_IPFORWARDTABLE;
 dwSize:ULONG;
 dwRetVal:DWORD;
 I:Integer;
 pRow:^MIB_IPFORWARDROW;
Begin
 GetRouteTable:=False;
 RouteCount:=0;
 dwSize:=0;
  { Premiäre appel pour obtenir la taille }
 dwRetVal:=GetIpForwardTable(nil,dwSize,True);
 If dwRetVal<>ERROR_INSUFFICIENT_BUFFER Then Exit;
  { Allouer la mÇmoire }
 GetMem(pIpForwardTable,dwSize);
 Try
   { Obtenir la table de routage }
  dwRetVal:=GetIpForwardTable(pIpForwardTable,dwSize,True);
  If dwRetVal=NO_ERROR Then Begin
   RouteCount:=pIpForwardTable^.dwNumEntries;
   If RouteCount>256 Then RouteCount:=256;
   For I:=0 To RouteCount-1 Do Begin
    pRow:=@pIpForwardTable^.table[I];
    With RouteTable[I] Do Begin
     If pRow^.dwForwardDest=0 Then Destination:='default'
                              Else Destination:=DWORDToIP(pRow^.dwForwardDest);
     Gateway:=DWORDToIP(pRow^.dwForwardNextHop);
     Netmask:=DWORDToIP(pRow^.dwForwardMask);
     Flags:=GetRouteFlags(pRow^.dwForwardType,pRow^.dwForwardDest,pRow^.dwForwardMask);
     Metric:=pRow^.dwForwardMetric1;
     RefCount:=0;  { Non utilisÇ sous Windows }
     UseCount:=0;  { Non utilisÇ sous Windows }
     InterfaceIndex:=pRow^.dwForwardIfIndex;
     InterfaceName:='eth'+IntToStr(InterfaceIndex);
    End;
   End;
   GetRouteTable:=True;
  End;
 Finally
  FreeMem(pIpForwardTable);
 End;
End;

 { ProcÇdure pour afficher la table de routage }
Procedure ShowRouteTable;
Var
 I:Integer;
Begin
 WriteLn('Table de routage IP du noyau');
 WriteLn('Destination     Passerelle      Genmask         Indic Metric Ref    Use Iface');
 If GetRouteTable Then Begin
  For I:=0 To RouteCount-1 Do Begin
   With RouteTable[I] Do Begin
    Write(Destination);
    While Length(Destination)<16 Do Begin
     Write(' ');
     Destination:=Destination+' ';
    End;
    Write(Gateway);
    While Length(Gateway)<16 Do Begin
     Write(' ');
     Gateway:=Gateway+' ';
    End;
    Write(Netmask);
    While Length(Netmask)<16 Do Begin
     Write(' ');
     Netmask:=Netmask+' ';
    End;
    Write(Flags);
    While Length(Flags)<6 Do Begin
     Write(' ');
     Flags:=Flags+' ';
    End;
    Write(Metric:6);
    Write(RefCount:4);
    Write(UseCount:7);
    Write(' ',InterfaceName);
    WriteLn;
   End;
  End;
 End
  Else
 WriteLn('Erreur lors de la rÇcupÇration de la table de routage');
End;

{ ProcÇdure pour ajouter une route }
Procedure AddRoute(Dest,Gateway,Netmask:String;Metric:Integer);
Var
 Route:MIB_IPFORWARDROW;
 dwRetVal:DWORD;
Begin
 WriteLn('Ajout de la route : ',Dest,' via ',Gateway);
 FillChar(Route,SizeOf(Route),0);
 Route.dwForwardDest:=IPToDWORD(Dest);
 Route.dwForwardMask:=IPToDWORD(Netmask);
 Route.dwForwardNextHop:=IPToDWORD(Gateway);
 Route.dwForwardMetric1:=Metric;
 Route.dwForwardType:=MIB_IPROUTE_TYPE_INDIRECT;
 Route.dwForwardProto:=MIB_IPPROTO_NETMGMT;
 Route.dwForwardAge:=0;
 Route.dwForwardIfIndex:=1;  { Interface par dÇfaut }
 dwRetVal:=CreateIpForwardEntry(Route);
 If dwRetVal=NO_ERROR Then WriteLn('Route ajoutÇe avec succäs')
                      Else WriteLn('Erreur lors de l''ajout de la route : ',dwRetVal);
End;

{ ProcÇdure pour supprimer une route }
Procedure DelRoute(Dest,Gateway,Netmask:String);
Var
 Route:MIB_IPFORWARDROW;
 dwRetVal:DWORD;
Begin
 WriteLn('Suppression de la route : ',Dest,' via ',Gateway);
 FillChar(Route,SizeOf(Route),0);
 Route.dwForwardDest:=IPToDWORD(Dest);
 Route.dwForwardMask:=IPToDWORD(Netmask);
 Route.dwForwardNextHop:=IPToDWORD(Gateway);
 dwRetVal:=DeleteIpForwardEntry(Route);
 If dwRetVal=NO_ERROR Then WriteLn('Route supprimÇe avec succäs')
                      Else WriteLn('Erreur lors de la suppression de la route : ',dwRetVal);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedRoutes;Begin
 WriteLn('Table de routage IP du noyau (simulÇe)');
 WriteLn('Destination     Passerelle      Genmask         Indic Metric Ref    Use Iface');
 WriteLn('default         192.168.1.1     0.0.0.0         UG       0    0      0 eth0');
 WriteLn('192.168.1.0     0.0.0.0         255.255.255.0   U        0    0      0 eth0');
 WriteLn('127.0.0.0       0.0.0.0         255.0.0.0       U        0    0      0 lo');
End;

Procedure SimulateAddRoute(Dest,Gateway:String);Begin
 WriteLn('Simulation ajout route : ',Dest,' via ',Gateway);
 WriteLn('Route ajoutÇe (simulation)');
End;

Procedure SimulateDelRoute(Dest,Gateway:String);Begin
 WriteLn('Simulation suppression route : ',Dest,' via ',Gateway);
 WriteLn('Route supprimÇe (simulation)');
End;
{$ENDIF}

{ ProcÇdure pour analyser les paramätres }
Procedure ParseCommand;
Var
 Cmd:String;
 Dest,Gateway,Netmask:String;
 Metric:Integer;
Begin
 If ParamCount<1 Then Begin
  {$IFDEF FPC}
   ShowRouteTable;
  {$ELSE}
   ShowSimulatedRoutes;
  {$ENDIF}
  Exit;
 End;
 Cmd:=UpperCase(ParamStr(1));
 If (Cmd='ADD') or (Cmd='AJOUTER') Then Begin
  If ParamCount>=3 Then Begin
   Dest:=ParamStr(2);
   Gateway:=ParamStr(3);
   Netmask:='255.255.255.255';  { Masque par dÇfaut }
   Metric:=1;
   If ParamCount>=4 Then Netmask:=ParamStr(4);
   If ParamCount>=5 Then Metric:=StrToInt(ParamStr(5));
   {$IFDEF FPC}
    AddRoute(Dest,Gateway,Netmask,Metric);
   {$ELSE}
    SimulateAddRoute(Dest,Gateway);
   {$ENDIF}
  End
   Else
  WriteLn('Usage : ROUTE ADD destination passerelle [masque] [m√©trique]');
 End
  Else
 If(Cmd='DEL')or(Cmd='DELETE')or(Cmd='SUPPRIMER')Then Begin
  If ParamCount>=3 Then Begin
   Dest:=ParamStr(2);
   Gateway:=ParamStr(3);
   Netmask:='255.255.255.255';
   If ParamCount>=4 Then Netmask:=ParamStr(4);
   {$IFDEF FPC}
    DelRoute(Dest,Gateway,Netmask);
   {$ELSE}
    SimulateDelRoute(Dest,Gateway);
   {$ENDIF}
  End
   Else
  WriteLn('Usage : ROUTE DEL destination passerelle [masque]');
 End
  Else
 If (Cmd='-N') or (Cmd='--NUMERIC') Then Begin
  { Mode numÇrique - afficher seulement les IPs }
  {$IFDEF FPC}
   ShowRouteTable;
  {$ELSE}
   ShowSimulatedRoutes;
  {$ENDIF}
 End
  Else
 Begin
  WriteLn('Commande inconnue : ',Cmd);
  WriteLn('Commandes disponibles : ADD, DEL, -n');
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('ROUTE : Cette commande permet d''effectuer la manipulation de la table de routage IP.');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  ROUTE                              Afficher la table de routage');
  WriteLn('  ROUTE ADD dest passerelle [masque] Ajouter une route');
  WriteLn('  ROUTE DEL dest passerelle [masque] Supprimer une route');
  WriteLn('  ROUTE -n                           Mode numÇrique');
  WriteLn;
  WriteLn('Paramätres :');
  WriteLn('  dest        Adresse IP de destination (ou "default")');
  WriteLn('  passerelle  Adresse IP de la passerelle');
  WriteLn('  masque      Masque de sous-rÇseau (dÇfaut: 255.255.255.255)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  ROUTE                              # Afficher les routes');
  WriteLn('  ROUTE ADD default 192.168.1.1      # Route par dÇfaut');
  WriteLn('  ROUTE ADD 10.0.0.0 192.168.1.1 255.0.0.0  # Route rÇseau');
  WriteLn('  ROUTE DEL 10.0.0.0 192.168.1.1     # Supprimer route');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (table rÇelle)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('ROUTE 1.00 - Table de routage IP, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  WriteLn('Commande ROUTE - NETWORKKIT-P');
  WriteLn;
  ParseCommand;
 End;
END.