{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande Ping ICMP)
}

Program PING;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, Winsock;
{$ELSE}
 Uses Crt,DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour l'en-tête ICMP }
 TICMPHeader = Packed Record
  IcmpType:Byte;      { Type ICMP (8 = Echo Request) }
  IcmpCode:Byte;      { Code ICMP (0 pour ping) }
  IcmpChecksum:Word;  { Somme de contrôle }
  IcmpId:Word;        { Identificateur }
  IcmpSequence:Word;  { Numéro de séquence }
 End;

 { Structure pour les statistiques de ping }
 TPingStats = Record
  PacketsSent:Integer;
  PacketsReceived:Integer;
  PacketsLost:Integer;
  MinTime:DWORD;
  MaxTime:DWORD;
  AvgTime:DWORD;
  TotalTime:DWORD;
 End;

Var
 WSAData:TWSADATA;
 Socket:Integer;
 PingStats:TPingStats;
 TargetHost:String;
 TargetIP:String;
 PingCount:Integer;
 PingSize:Integer;
 PingTimeout:Integer;
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
{$ENDIF}

{$IFDEF FPC}
{ Fonction pour calculer la somme de contrôle ICMP }
Function CalculateChecksum(Data:Pointer;Size:Integer):Word;
Var
 Sum:LongInt;
 WordPtr:^Word;
 I:Integer;
Begin
 Sum:=0;
 WordPtr:=Data;

 { Additionner tous les mots de 16 bits }
 For I:=0 To (Size div 2)-1 Do Begin
  Inc(Sum,WordPtr^);
  Inc(WordPtr);
 End;

 { Ajouter l'octet restant si la taille est impaire }
 If (Size mod 2)=1 Then
  Inc(Sum,PByte(WordPtr)^ shl 8);

 { Replier les bits de report }
 While (Sum shr 16)<>0 Do
  Sum:=(Sum and $FFFF)+(Sum shr 16);

 { Complément à un }
 CalculateChecksum:=not Sum;
End;

{ Fonction pour résoudre une adresse IP }
Function ResolveHost(HostName:String):String;
Var
 HostEnt:PHostEnt;
 HostCStr:Array[0..255] of AnsiChar;
 InAddr:TInAddr;
Begin
 ResolveHost:='';

 { Convertir en chaîne C }
 Move(HostName[1],HostCStr[0],Length(HostName));
 HostCStr[Length(HostName)]:=#0;

 { Vérifier si c'est déjà une adresse IP }
 InAddr.s_addr:=inet_addr(HostCStr);
 If InAddr.s_addr<>INADDR_NONE Then Begin
  ResolveHost:=StrPas(inet_ntoa(InAddr));
  Exit;
 End;

 { Résoudre le nom d'hôte }
 HostEnt:=gethostbyname(HostCStr);
 If HostEnt<>nil Then Begin
  Move(HostEnt^.h_addr_list^^,InAddr,SizeOf(InAddr));
  ResolveHost:=StrPas(inet_ntoa(InAddr));
 End;
End;

{ Fonction pour envoyer un paquet ICMP ping }
Function SendPing(TargetAddr:String;Sequence:Word;DataSize:Integer):Boolean;
Var
 SockAddr:TSockAddrIn;
 ICMPPacket:Array[0..1023] of Byte;
 ICMPHeader:^TICMPHeader;
 DataPtr:PByte;
 PacketSize:Integer;
 I:Integer;
Begin
 SendPing:=False;

 { Préparer l'adresse de destination }
 FillChar(SockAddr,SizeOf(SockAddr),0);
 SockAddr.sin_family:=AF_INET;
 SockAddr.sin_addr.s_addr:=inet_addr(PAnsiChar(AnsiString(TargetAddr)));

 { Préparer le paquet ICMP }
 PacketSize:=SizeOf(TICMPHeader)+DataSize;
 FillChar(ICMPPacket,SizeOf(ICMPPacket),0);

 ICMPHeader:=@ICMPPacket[0];
 ICMPHeader^.IcmpType:=8;        { Echo Request }
 ICMPHeader^.IcmpCode:=0;
 ICMPHeader^.IcmpChecksum:=0;
 ICMPHeader^.IcmpId:=GetCurrentProcessId and $FFFF;
 ICMPHeader^.IcmpSequence:=htons(Sequence);

 { Remplir les données }
 DataPtr:=@ICMPPacket[SizeOf(TICMPHeader)];
 For I:=0 To DataSize-1 Do
  DataPtr^:=(I mod 256);
  Inc(DataPtr);

 { Calculer la somme de contrôle }
 ICMPHeader^.IcmpChecksum:=CalculateChecksum(@ICMPPacket,PacketSize);

 { Envoyer le paquet }
 If sendto(Socket,ICMPPacket,PacketSize,0,SockAddr,SizeOf(SockAddr))>0 Then
  SendPing:=True;
End;

{ Fonction pour recevoir une réponse ICMP }
Function ReceivePing(Var ResponseTime:DWORD):Boolean;
Var
 Buffer:Array[0..1023] of Byte;
 SockAddr:TSockAddrIn;
 AddrLen:Integer;
 BytesReceived:Integer;
 StartTime,EndTime:DWORD;
 TimeoutVal:Integer;
Begin
 ReceivePing:=False;
 ResponseTime:=0;

 { Définir le timeout }
 TimeoutVal:=PingTimeout;
 setsockopt(Socket,SOL_SOCKET,SO_RCVTIMEO,@TimeoutVal,SizeOf(TimeoutVal));

 StartTime:=GetTickCount;
 AddrLen:=SizeOf(SockAddr);
 BytesReceived:=recvfrom(Socket,Buffer,SizeOf(Buffer),0,SockAddr,AddrLen);
 EndTime:=GetTickCount;

 If BytesReceived>0 Then Begin
  ResponseTime:=EndTime-StartTime;
  ReceivePing:=True;
 End;
End;

{ Procédure principale de ping }
Procedure DoPing;
Var
 I:Integer;
 Success:Boolean;
 ResponseTime:DWORD;
 StartTime:DWORD;
Begin
 WriteLn('PING ',TargetHost,' (',TargetIP,') ',PingSize,' octets de données :');
 WriteLn;

 { Initialiser les statistiques }
 FillChar(PingStats,SizeOf(PingStats),0);
 PingStats.MinTime:=$FFFFFFFF;

 For I:=1 To PingCount Do Begin
  StartTime:=GetTickCount;

  If SendPing(TargetIP,I,PingSize) Then Begin
   Inc(PingStats.PacketsSent);

   Success:=ReceivePing(ResponseTime);
   If Success Then Begin
    Inc(PingStats.PacketsReceived);

    Write('Réponse de ',TargetIP,': octets=',PingSize);
    WriteLn(' temps=',ResponseTime,'ms TTL=64');

    { Mettre à jour les statistiques }
    Inc(PingStats.TotalTime,ResponseTime);
    If ResponseTime<PingStats.MinTime Then PingStats.MinTime:=ResponseTime;
    If ResponseTime>PingStats.MaxTime Then PingStats.MaxTime:=ResponseTime;
   End Else Begin
    WriteLn('Délai d''attente de la demande dépassé.');
   End;
  End Else Begin
   WriteLn('Erreur lors de l''envoi du paquet.');
  End;

  { Attendre avant le prochain ping (sauf le dernier) }
  If I<PingCount Then Sleep(1000);
 End;

 { Calculer les statistiques finales }
 PingStats.PacketsLost:=PingStats.PacketsSent-PingStats.PacketsReceived;
 If PingStats.PacketsReceived>0 Then
  PingStats.AvgTime:=PingStats.TotalTime div PingStats.PacketsReceived;

 { Afficher les statistiques }
 WriteLn;
 WriteLn('Statistiques de ping pour ',TargetIP,' :');
 WriteLn('    Paquets : envoyés = ',PingStats.PacketsSent,
         ', reçus = ',PingStats.PacketsReceived,
         ', perdus = ',PingStats.PacketsLost);
 If PingStats.PacketsSent>0 Then
  WriteLn('             (',((PingStats.PacketsLost*100) div PingStats.PacketsSent),'% de perte),');

 If PingStats.PacketsReceived>0 Then Begin
  WriteLn('Durée approximative des boucles en millisecondes :');
  WriteLn('    Minimum = ',PingStats.MinTime,'ms, Maximum = ',PingStats.MaxTime,'ms, Moyenne = ',PingStats.AvgTime,'ms');
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation ping }
Procedure DoSimulatedPing;
Var
 I:Integer;
 SimTime:Integer;
Begin
 WriteLn('PING ',ParamStr(1),' (simulation Turbo Pascal) :');
 WriteLn;

 For I:=1 To 4 Do Begin
  SimTime:=50+Random(100);  { Temps simulé entre 50-150ms }
  WriteLn('Réponse de ',ParamStr(1),': octets=32 temps=',SimTime,'ms TTL=64');
  If I<4 Then Begin
   { Attendre 1 seconde (simulation) }
   Delay(1000);
  End;
 End;

 WriteLn;
 WriteLn('Statistiques de ping pour ',ParamStr(1),' :');
 WriteLn('    Paquets : envoyés = 4, reçus = 4, perdus = 0');
 WriteLn('             (0% de perte),');
 WriteLn('Durée approximative des boucles en millisecondes :');
 WriteLn('    Minimum = 50ms, Maximum = 150ms, Moyenne = 100ms');
End;
{$ENDIF}

{ Procédure pour analyser les paramètres de ligne de commande }
Procedure ParseParameters;
Var
 I:Integer;
 Param:String;
Begin
 {$IFDEF FPC}
 PingCount:=4;      { Nombre de pings par défaut }
 PingSize:=32;      { Taille des données par défaut }
 PingTimeout:=4000; { Timeout par défaut (4 secondes) }
 TargetHost:='';

 I:=1;
 While I<=ParamCount Do Begin
  Param:=UpperCase(ParamStr(I));
  If Param='-N' Then Begin
   Inc(I);
   If I<=ParamCount Then PingCount:=StrToInt(ParamStr(I));
  End Else If Param='-L' Then Begin
   Inc(I);
   If I<=ParamCount Then PingSize:=StrToInt(ParamStr(I));
  End Else If Param='-W' Then Begin
   Inc(I);
   If I<=ParamCount Then PingTimeout:=StrToInt(ParamStr(I));
  End Else If (Param<>'') and (Param[1]<>'-') and (Param[1]<>'/') Then Begin
   If TargetHost='' Then TargetHost:=ParamStr(I);
  End;
  Inc(I);
 End;
 {$ENDIF}
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('PING : Commande de test de connectivité réseau');
  WriteLn;
  WriteLn('Syntaxe : PING [-n nombre] [-l taille] [-w timeout] destination');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  destination  Nom d''hôte ou adresse IP à ping');
  WriteLn('  -n nombre    Nombre de requêtes à envoyer (défaut: 4)');
  WriteLn('  -l taille    Taille des données en octets (défaut: 32)');
  WriteLn('  -w timeout   Délai d''attente en millisecondes (défaut: 4000)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  PING google.com');
  WriteLn('  PING 8.8.8.8');
  WriteLn('  PING -n 10 -l 64 192.168.1.1');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (ICMP réel)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('PING 1.00 - Commande Ping ICMP, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 If ParamCount>=1 Then Begin
  ParseParameters;

  {$IFDEF FPC}
  If TargetHost='' Then TargetHost:=ParamStr(1);

  WriteLn('Ping ICMP - NETWORKKIT-P');
  WriteLn;

  { Initialiser Winsock }
  If WSAStartup($0202,WSAData)<>0 Then Begin
   WriteLn('Erreur d''initialisation Winsock');
   Halt(1);
  End;

  { Résoudre l'adresse IP }
  WriteLn('Résolution de ',TargetHost,'...');
  TargetIP:=ResolveHost(TargetHost);
  If TargetIP='' Then Begin
   WriteLn('Impossible de résoudre ',TargetHost);
   WSACleanup;
   Halt(1);
  End;

  { Créer un socket RAW ICMP }
  Socket:=Winsock.socket(AF_INET,SOCK_RAW,IPPROTO_ICMP);
  If Socket=INVALID_SOCKET Then Begin
   WriteLn('Erreur : Impossible de créer un socket ICMP');
   WriteLn('(Nécessite des privilèges administrateur)');
   WSACleanup;
   Halt(1);
  End;

  Try
   DoPing;
  Finally
   closesocket(Socket);
   WSACleanup;
  End;
  {$ELSE}
  Randomize;
  DoSimulatedPing;
  {$ENDIF}
 End
  Else
 Begin
  WriteLn('Utilisation : PING destination');
  WriteLn('Tapez PING /? pour plus d''informations');
 End;
END.
