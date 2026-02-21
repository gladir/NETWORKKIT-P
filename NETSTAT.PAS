{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande netstat (statistiques réseau))
}

Program NETSTAT;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, WinSock;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour les connexions TCP }
 TTCPConnection = Record
  LocalAddr:String;
  LocalPort:DWORD;
  RemoteAddr:String;
  RemotePort:DWORD;
  State:String;
  ProcessID:DWORD;
  ProcessName:String;
 End;

 { Structure pour les connexions UDP }
 TUDPConnection = Record
  LocalAddr:String;
  LocalPort:DWORD;
  ProcessID:DWORD;
  ProcessName:String;
 End;

 { Structure MIB_TCPROW pour TCP }
 MIB_TCPROW = Record
  dwState:DWORD;
  dwLocalAddr:DWORD;
  dwLocalPort:DWORD;
  dwRemoteAddr:DWORD;
  dwRemotePort:DWORD;
 End;
 PMIB_TCPROW = ^MIB_TCPROW;

 { Structure MIB_TCPTABLE }
 MIB_TCPTABLE = Record
  dwNumEntries:DWORD;
  table:Array[0..0] of MIB_TCPROW;
 End;
 PMIB_TCPTABLE = ^MIB_TCPTABLE;

 { Structure MIB_UDPROW pour UDP }
 MIB_UDPROW = Record
  dwLocalAddr:DWORD;
  dwLocalPort:DWORD;
 End;
 PMIB_UDPROW = ^MIB_UDPROW;

 { Structure MIB_UDPTABLE }
 MIB_UDPTABLE = Record
  dwNumEntries:DWORD;
  table:Array[0..0] of MIB_UDPROW;
 End;
 PMIB_UDPTABLE = ^MIB_UDPTABLE;

 { Structure pour les statistiques TCP }
 MIB_TCPSTATS = Record
  dwRtoAlgorithm:DWORD;
  dwRtoMin:DWORD;
  dwRtoMax:DWORD;
  dwMaxConn:DWORD;
  dwActiveOpens:DWORD;
  dwPassiveOpens:DWORD;
  dwAttemptFails:DWORD;
  dwEstabResets:DWORD;
  dwCurrEstab:DWORD;
  dwInSegs:DWORD;
  dwOutSegs:DWORD;
  dwRetransSegs:DWORD;
  dwInErrs:DWORD;
  dwOutRsts:DWORD;
 End;
 PMIB_TCPSTATS = ^MIB_TCPSTATS;

 { Structure pour les statistiques UDP }
 MIB_UDPSTATS = Record
  dwInDatagrams:DWORD;
  dwNoPorts:DWORD;
  dwInErrors:DWORD;
  dwOutDatagrams:DWORD;
  dwNumAddrs:DWORD;
 End;
 PMIB_UDPSTATS = ^MIB_UDPSTATS;

Const
 { États TCP }
 MIB_TCP_STATE_CLOSED = 1;
 MIB_TCP_STATE_LISTEN = 2;
 MIB_TCP_STATE_SYN_SENT = 3;
 MIB_TCP_STATE_SYN_RCVD = 4;
 MIB_TCP_STATE_ESTAB = 5;
 MIB_TCP_STATE_FIN_WAIT1 = 6;
 MIB_TCP_STATE_FIN_WAIT2 = 7;
 MIB_TCP_STATE_CLOSE_WAIT = 8;
 MIB_TCP_STATE_CLOSING = 9;
 MIB_TCP_STATE_LAST_ACK = 10;
 MIB_TCP_STATE_TIME_WAIT = 11;
 MIB_TCP_STATE_DELETE_TCB = 12;

 { Constantes d'erreur }
 NO_ERROR = 0;
 ERROR_INSUFFICIENT_BUFFER = 122;

Var
 TCPConnections:Array[0..511] of TTCPConnection;
 UDPConnections:Array[0..511] of TUDPConnection;
 TCPCount,UDPCount:Integer;

{ Fonctions externes }
Function GetTcpTable(pTcpTable:PMIB_TCPTABLE;Var pdwSize:DWORD;bOrder:BOOL):DWORD;stdcall;external 'iphlpapi.dll';
Function GetUdpTable(pUdpTable:PMIB_UDPTABLE;Var pdwSize:DWORD;bOrder:BOOL):DWORD;stdcall;external 'iphlpapi.dll';
Function GetTcpStatistics(pStats:PMIB_TCPSTATS):DWORD;stdcall;external 'iphlpapi.dll';
Function GetUdpStatistics(pStats:PMIB_UDPSTATS):DWORD;stdcall;external 'iphlpapi.dll';

{ Procédure d'initialisation des structures }
Procedure InitializeStructures;
Var
 I:Integer;
Begin
 TCPCount:=0;
 UDPCount:=0;
 For I:=0 To 511 Do Begin
  With TCPConnections[I] Do Begin
   LocalAddr:='';
   LocalPort:=0;
   RemoteAddr:='';
   RemotePort:=0;
   State:='';
   ProcessID:=0;
   ProcessName:='';
  End;
  With UDPConnections[I] Do Begin
   LocalAddr:='';
   LocalPort:=0;
   ProcessID:=0;
   ProcessName:='';
  End;
 End;
End;
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
{ Fonction pour convertir une adresse DWORD en chaîne IP }
Function DWORDToIP(IPAddr:DWORD):String;
Begin
 DWORDToIP:=IntToStr(IPAddr and $FF)+'.'+
           IntToStr((IPAddr shr 8) and $FF)+'.'+
           IntToStr((IPAddr shr 16) and $FF)+'.'+
           IntToStr((IPAddr shr 24) and $FF);
End;

{ Fonction pour convertir un port network byte order }
Function NetworkToHostPort(NetPort:DWORD):DWORD;
Begin
 NetworkToHostPort:=((NetPort and $FF) shl 8) or ((NetPort shr 8) and $FF);
End;

{ Fonction pour obtenir l'état TCP en chaîne }
Function GetTCPState(State:DWORD):String;
Begin
 Case State Of
  MIB_TCP_STATE_CLOSED:GetTCPState:='CLOSED';
  MIB_TCP_STATE_LISTEN:GetTCPState:='LISTEN';
  MIB_TCP_STATE_SYN_SENT:GetTCPState:='SYN_SENT';
  MIB_TCP_STATE_SYN_RCVD:GetTCPState:='SYN_RCVD';
  MIB_TCP_STATE_ESTAB:GetTCPState:='ESTABLISHED';
  MIB_TCP_STATE_FIN_WAIT1:GetTCPState:='FIN_WAIT1';
  MIB_TCP_STATE_FIN_WAIT2:GetTCPState:='FIN_WAIT2';
  MIB_TCP_STATE_CLOSE_WAIT:GetTCPState:='CLOSE_WAIT';
  MIB_TCP_STATE_CLOSING:GetTCPState:='CLOSING';
  MIB_TCP_STATE_LAST_ACK:GetTCPState:='LAST_ACK';
  MIB_TCP_STATE_TIME_WAIT:GetTCPState:='TIME_WAIT';
  MIB_TCP_STATE_DELETE_TCB:GetTCPState:='DELETE_TCB';
 Else
  GetTCPState:='UNKNOWN';
 End;
End;

{ Fonction pour obtenir le nom du service par port }
Function GetServiceName(Port:DWORD;Protocol:String):String;
Begin
 Case Port Of
  21:GetServiceName:='ftp';
  22:GetServiceName:='ssh';
  23:GetServiceName:='telnet';
  25:GetServiceName:='smtp';
  53:GetServiceName:='domain';
  67:GetServiceName:='bootps';
  68:GetServiceName:='bootpc';
  80:GetServiceName:='http';
  110:GetServiceName:='pop3';
  135:GetServiceName:='epmap';
  139:GetServiceName:='netbios-ssn';
  143:GetServiceName:='imap';
  443:GetServiceName:='https';
  445:GetServiceName:='microsoft-ds';
  993:GetServiceName:='imaps';
  995:GetServiceName:='pop3s';
  1433:GetServiceName:='ms-sql-s';
  3389:GetServiceName:='ms-wbt-server';
  5432:GetServiceName:='postgresql';
 Else
  GetServiceName:=IntToStr(Port);
 End;
End;

{ Procédure pour obtenir les connexions TCP }
Function GetTCPConnections:Boolean;
Var
 pTcpTable:PMIB_TCPTABLE;
 dwSize:DWORD;
 dwRetVal:DWORD;
 I:Integer;
 pRow:PMIB_TCPROW;
Begin
 GetTCPConnections:=False;
 TCPCount:=0;
 dwSize:=0;
 
 Try
  { Première appel pour obtenir la taille }
  dwRetVal:=GetTcpTable(nil,dwSize,True);
  If dwRetVal<>ERROR_INSUFFICIENT_BUFFER Then Exit;
  
  { Vérifier la taille minimum }
  If dwSize<SizeOf(MIB_TCPTABLE) Then Exit;
  
  { Allouer la mémoire }
  GetMem(pTcpTable,dwSize);
  Try
   { Obtenir la table TCP }
   dwRetVal:=GetTcpTable(pTcpTable,dwSize,True);
   If dwRetVal=NO_ERROR Then Begin
    TCPCount:=pTcpTable^.dwNumEntries;
    If TCPCount>512 Then TCPCount:=512;
    
    For I:=0 To TCPCount-1 Do Begin
     Try
      pRow:=@pTcpTable^.table[I];
      With TCPConnections[I] Do Begin
       LocalAddr:=DWORDToIP(pRow^.dwLocalAddr);
       LocalPort:=NetworkToHostPort(pRow^.dwLocalPort);
       RemoteAddr:=DWORDToIP(pRow^.dwRemoteAddr);
       RemotePort:=NetworkToHostPort(pRow^.dwRemotePort);
       State:=GetTCPState(pRow^.dwState);
       ProcessID:=0;  { Non disponible dans cette version }
       ProcessName:='';
      End;
     Except
      { Ignorer l'erreur et continuer }
     End;
    End;
    GetTCPConnections:=True;
   End;
  Finally
   FreeMem(pTcpTable,dwSize);
  End;
 Except
  { Gérer les erreurs d'allocation mémoire }
  GetTCPConnections:=False;
 End;
End;

{ Procédure pour obtenir les connexions UDP }
Function GetUDPConnections:Boolean;
Var
 pUdpTable:PMIB_UDPTABLE;
 dwSize:DWORD;
 dwRetVal:DWORD;
 I:Integer;
 pRow:PMIB_UDPROW;
Begin
 GetUDPConnections:=False;
 UDPCount:=0;
 dwSize:=0;
 
 Try
  { Première appel pour obtenir la taille }
  dwRetVal:=GetUdpTable(nil,dwSize,True);
  If dwRetVal<>ERROR_INSUFFICIENT_BUFFER Then Exit;
  
  { Vérifier la taille minimum }
  If dwSize<SizeOf(MIB_UDPTABLE) Then Exit;
  
  { Allouer la mémoire }
  GetMem(pUdpTable,dwSize);
  Try
   { Obtenir la table UDP }
   dwRetVal:=GetUdpTable(pUdpTable,dwSize,True);
   If dwRetVal=NO_ERROR Then Begin
    UDPCount:=pUdpTable^.dwNumEntries;
    If UDPCount>512 Then UDPCount:=512;
    
    For I:=0 To UDPCount-1 Do Begin
     Try
      pRow:=@pUdpTable^.table[I];
      With UDPConnections[I] Do Begin
       LocalAddr:=DWORDToIP(pRow^.dwLocalAddr);
       LocalPort:=NetworkToHostPort(pRow^.dwLocalPort);
       ProcessID:=0;  { Non disponible dans cette version }
       ProcessName:='';
      End;
     Except
      { Ignorer l'erreur et continuer }
     End;
    End;
    GetUDPConnections:=True;
   End;
  Finally
   FreeMem(pUdpTable,dwSize);
  End;
 Except
  { Gérer les erreurs d'allocation mémoire }
  GetUDPConnections:=False;
 End;
End;

{ Procédure pour afficher les connexions TCP }
Procedure ShowTCPConnections(ShowListening,ShowEstablished,ShowAll:Boolean);
Var
 I:Integer;
 Show:Boolean;
Begin
 WriteLn('Connexions Internet actives (tcp)');
 WriteLn('Proto Recv-Q Send-Q Adresse locale        Adresse distante      État');
 
 If GetTCPConnections Then Begin
  For I:=0 To TCPCount-1 Do Begin
   With TCPConnections[I] Do Begin
    Show:=False;
    If ShowAll Then Show:=True
    Else If (ShowListening and (State='LISTEN')) Then Show:=True
    Else If (ShowEstablished and (State='ESTABLISHED')) Then Show:=True
    Else If (not ShowListening and not ShowEstablished) Then Show:=True;
    
    If Show Then Begin
     Write('tcp        0      0 ');
     Write(LocalAddr,':');
     If LocalPort<1024 Then
      Write(GetServiceName(LocalPort,'tcp'))
     Else
      Write(LocalPort);
     Write('                  ');
     
     If (RemoteAddr='0.0.0.0') and (RemotePort=0) Then
      Write('0.0.0.0:*                  ')
     Else Begin
      Write(RemoteAddr,':');
      If RemotePort<1024 Then
       Write(GetServiceName(RemotePort,'tcp'))
      Else
       Write(RemotePort);
      Write('            ');
     End;
     WriteLn(State);
    End;
   End;
  End;
 End Else
  WriteLn('Erreur lors de la récupération des connexions TCP');
End;

{ Procédure pour afficher les connexions UDP }
Procedure ShowUDPConnections;
Var
 I:Integer;
Begin
 WriteLn('Connexions Internet actives (udp)');
 WriteLn('Proto Recv-Q Send-Q Adresse locale        Adresse distante');
 
 If GetUDPConnections Then Begin
  For I:=0 To UDPCount-1 Do Begin
   With UDPConnections[I] Do Begin
    Write('udp        0      0 ');
    Write(LocalAddr,':');
    If LocalPort<1024 Then
     Write(GetServiceName(LocalPort,'udp'))
    Else
     Write(LocalPort);
    Write('                  ');
    WriteLn('0.0.0.0:*');
   End;
  End;
 End Else
  WriteLn('Erreur lors de la récupération des connexions UDP');
End;

{ Procédure pour afficher les ports en écoute }
Procedure ShowListeningPorts;
Var
 I:Integer;
Begin
 WriteLn('Ports en écoute :');
 WriteLn('Proto  Adresse locale        État');
 
 If GetTCPConnections Then Begin
  For I:=0 To TCPCount-1 Do Begin
   With TCPConnections[I] Do Begin
    If State='LISTEN' Then Begin
     Write('tcp    ');
     Write(LocalAddr,':');
     If LocalPort<1024 Then
      Write(GetServiceName(LocalPort,'tcp'))
     Else
      Write(LocalPort);
     Write('                  ');
     WriteLn('LISTEN');
    End;
   End;
  End;
 End;
 
 If GetUDPConnections Then Begin
  For I:=0 To UDPCount-1 Do Begin
   With UDPConnections[I] Do Begin
    Write('udp    ');
    Write(LocalAddr,':');
    If LocalPort<1024 Then
     Write(GetServiceName(LocalPort,'udp'))
    Else
     Write(LocalPort);
    Write('                  ');
    WriteLn('*:*');
   End;
  End;
 End;
End;

{ Procédure pour afficher les statistiques protocoles }
Procedure ShowProtocolStats;
Var
 pTCPStats:PMIB_TCPSTATS;
 pUDPStats:PMIB_UDPSTATS;
 dwRetVal:DWORD;
Begin
 WriteLn('Statistiques des protocoles :');
 WriteLn;
 
 Try
  { Allouer mémoire pour les statistiques TCP }
  GetMem(pTCPStats,SizeOf(MIB_TCPSTATS));
  Try
   FillChar(pTCPStats^,SizeOf(MIB_TCPSTATS),0);
   dwRetVal:=GetTcpStatistics(pTCPStats);
   If dwRetVal=NO_ERROR Then Begin
    WriteLn('TCP:');
    WriteLn('    ',pTCPStats^.dwActiveOpens,' connexions actives ouvertes');
    WriteLn('    ',pTCPStats^.dwPassiveOpens,' connexions passives ouvertes');
    WriteLn('    ',pTCPStats^.dwAttemptFails,' tentatives de connexion échouées');
    WriteLn('    ',pTCPStats^.dwEstabResets,' connexions établies réinitialisées');
    WriteLn('    ',pTCPStats^.dwCurrEstab,' connexions actuellement établies');
    WriteLn('    ',pTCPStats^.dwInSegs,' segments reçus');
    WriteLn('    ',pTCPStats^.dwOutSegs,' segments envoyés');
    WriteLn('    ',pTCPStats^.dwRetransSegs,' segments retransmis');
    WriteLn('    ',pTCPStats^.dwInErrs,' segments reçus en erreur');
    WriteLn('    ',pTCPStats^.dwOutRsts,' segments reset envoyés');
    WriteLn;
   End Else Begin
    WriteLn('Erreur lors de la récupération des statistiques TCP (Code: ',dwRetVal,')');
    WriteLn;
   End;
  Finally
   FreeMem(pTCPStats,SizeOf(MIB_TCPSTATS));
  End;
  
  { Allouer mémoire pour les statistiques UDP }
  GetMem(pUDPStats,SizeOf(MIB_UDPSTATS));
  Try
   FillChar(pUDPStats^,SizeOf(MIB_UDPSTATS),0);
   dwRetVal:=GetUdpStatistics(pUDPStats);
   If dwRetVal=NO_ERROR Then Begin
    WriteLn('UDP:');
    WriteLn('    ',pUDPStats^.dwInDatagrams,' datagrammes reçus');
    WriteLn('    ',pUDPStats^.dwOutDatagrams,' datagrammes envoyés');
    WriteLn('    ',pUDPStats^.dwNoPorts,' datagrammes vers ports fermés');
    WriteLn('    ',pUDPStats^.dwInErrors,' erreurs de réception');
    WriteLn('    ',pUDPStats^.dwNumAddrs,' adresses UDP en écoute');
    WriteLn;
   End Else Begin
    WriteLn('Erreur lors de la récupération des statistiques UDP (Code: ',dwRetVal,')');
    WriteLn;
   End;
  Finally
   FreeMem(pUDPStats,SizeOf(MIB_UDPSTATS));
  End;
  
 Except
  On E:Exception Do Begin
   WriteLn('Erreur lors de la récupération des statistiques réseau: ',E.Message);
   WriteLn;
  End;
 End;
End;

{ Procédure pour afficher un résumé numérique }
Procedure ShowNumericSummary;
Var
 I,TCPListen,TCPEstab,UDPTotal:Integer;
Begin
 TCPListen:=0;
 TCPEstab:=0;
 UDPTotal:=0;
 
 If GetTCPConnections Then Begin
  For I:=0 To TCPCount-1 Do Begin
   If TCPConnections[I].State='LISTEN' Then Inc(TCPListen);
   If TCPConnections[I].State='ESTABLISHED' Then Inc(TCPEstab);
  End;
 End;
 
 If GetUDPConnections Then UDPTotal:=UDPCount;
 
 WriteLn('Résumé des connexions :');
 WriteLn('  TCP en écoute     : ',TCPListen);
 WriteLn('  TCP établies      : ',TCPEstab);
 WriteLn('  TCP total         : ',TCPCount);
 WriteLn('  UDP total         : ',UDPTotal);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedTCP;
Begin
 WriteLn('Connexions Internet actives (tcp) - Simulation');
 WriteLn('Proto Recv-Q Send-Q Adresse locale        Adresse distante      État');
 WriteLn('tcp        0      0 0.0.0.0:http          0.0.0.0:*             LISTEN');
 WriteLn('tcp        0      0 0.0.0.0:https         0.0.0.0:*             LISTEN');
 WriteLn('tcp        0      0 192.168.1.100:1234    142.250.191.14:https  ESTABLISHED');
 WriteLn('tcp        0      0 192.168.1.100:5678    172.217.16.142:http   TIME_WAIT');
End;

Procedure ShowSimulatedUDP;
Begin
 WriteLn('Connexions Internet actives (udp) - Simulation');
 WriteLn('Proto Recv-Q Send-Q Adresse locale        Adresse distante');
 WriteLn('udp        0      0 0.0.0.0:domain        0.0.0.0:*');
 WriteLn('udp        0      0 127.0.0.1:1234        0.0.0.0:*');
 WriteLn('udp        0      0 192.168.1.100:5353    0.0.0.0:*');
End;

Procedure ShowSimulatedListening;
Begin
 WriteLn('Ports en écoute (simulation) :');
 WriteLn('Proto  Adresse locale        État');
 WriteLn('tcp    0.0.0.0:http          LISTEN');
 WriteLn('tcp    0.0.0.0:https         LISTEN');
 WriteLn('tcp    0.0.0.0:ssh           LISTEN');
 WriteLn('udp    0.0.0.0:domain        *:*');
 WriteLn('udp    127.0.0.1:1234        *:*');
End;

Procedure ShowSimulatedStats;
Begin
 WriteLn('Statistiques des protocoles (simulation) :');
 WriteLn;
 WriteLn('TCP:');
 WriteLn('    156 connexions actives ouvertes');
 WriteLn('    42 connexions passives ouvertes');
 WriteLn('    7 tentatives de connexion échouées');
 WriteLn('    3 connexions établies réinitialisées');
 WriteLn('    8 connexions actuellement établies');
 WriteLn('    12456 segments reçus');
 WriteLn('    8934 segments envoyés');
 WriteLn('    23 segments retransmis');
 WriteLn('    0 segments reçus en erreur');
 WriteLn('    12 segments reset envoyés');
 WriteLn;
 WriteLn('UDP:');
 WriteLn('    2341 datagrammes reçus');
 WriteLn('    1876 datagrammes envoyés');
 WriteLn('    15 datagrammes vers ports fermés');
 WriteLn('    0 erreurs de réception');
 WriteLn('    12 adresses UDP en écoute');
End;

Procedure ShowSimulatedSummary;
Begin
 WriteLn('Résumé des connexions (simulation) :');
 WriteLn('  TCP en écoute     : 3');
 WriteLn('  TCP établies      : 2');
 WriteLn('  TCP total         : 8');
 WriteLn('  UDP total         : 5');
End;
{$ENDIF}

{ Procédure pour analyser les paramètres }
Procedure ParseCommand;
Var
 I:Integer;
 Cmd:String;
 ShowTCP,ShowUDP,ShowListening,ShowEstablished,ShowAll:Boolean;
 ShowRouting,ShowInterface,ShowStats,ShowNumeric:Boolean;
Begin
 ShowTCP:=True;
 ShowUDP:=True;
 ShowListening:=False;
 ShowEstablished:=False;
 ShowAll:=False;
 ShowRouting:=False;
 ShowInterface:=False;
 ShowStats:=False;
 ShowNumeric:=False;
 
 { Analyser les paramètres }
 For I:=1 To ParamCount Do Begin
  Cmd:=UpperCase(ParamStr(I));
  
  If (Cmd='-T') or (Cmd='--TCP') Then Begin
   ShowTCP:=True; ShowUDP:=False;
  End Else If (Cmd='-U') or (Cmd='--UDP') Then Begin
   ShowTCP:=False; ShowUDP:=True;
  End Else If (Cmd='-L') or (Cmd='--LISTENING') Then Begin
   ShowListening:=True;
  End Else If (Cmd='-E') or (Cmd='--ESTABLISHED') Then Begin
   ShowEstablished:=True;
  End Else If (Cmd='-A') or (Cmd='--ALL') Then Begin
   ShowAll:=True;
  End Else If (Cmd='-R') or (Cmd='--ROUTE') Then Begin
   ShowRouting:=True;
  End Else If (Cmd='-I') or (Cmd='--INTERFACES') Then Begin
   ShowInterface:=True;
  End Else If (Cmd='-S') or (Cmd='--STATISTICS') Then Begin
   ShowStats:=True;
  End Else If (Cmd='-N') or (Cmd='--NUMERIC') Then Begin
   ShowNumeric:=True;
  End;
 End;
 
 { Affichage selon les options }
 If ShowStats Then Begin
  {$IFDEF FPC}
  ShowProtocolStats;
  {$ELSE}
  ShowSimulatedStats;
  {$ENDIF}
 End Else If ShowRouting Then Begin
  WriteLn('Table de routage IP (utilisez ROUTE pour plus de détails)');
  {$IFDEF FPC}
  { Réutiliser la fonction de ROUTE.PAS si disponible }
  WriteLn('Veuillez utiliser la commande ROUTE pour afficher la table de routage');
  {$ELSE}
  WriteLn('default         192.168.1.1     0.0.0.0         UG    0 0     0 eth0');
  WriteLn('192.168.1.0     0.0.0.0         255.255.255.0   U     0 0     0 eth0');
  {$ENDIF}
 End Else If ShowInterface Then Begin
  WriteLn('Statistiques des interfaces (utilisez IFCONFIG pour plus de détails)');
  {$IFDEF FPC}
  ShowNumericSummary;
  {$ELSE}
  ShowSimulatedSummary;
  {$ENDIF}
 End Else If ShowListening Then Begin
  {$IFDEF FPC}
  ShowListeningPorts;
  {$ELSE}
  ShowSimulatedListening;
  {$ENDIF}
 End Else Begin
  { Affichage standard des connexions }
  If ShowTCP Then Begin
   {$IFDEF FPC}
   ShowTCPConnections(ShowListening,ShowEstablished,ShowAll);
   {$ELSE}
   ShowSimulatedTCP;
   {$ENDIF}
   If ShowUDP Then WriteLn;
  End;
  
  If ShowUDP Then Begin
   {$IFDEF FPC}
   ShowUDPConnections;
   {$ELSE}
   ShowSimulatedUDP;
   {$ENDIF}
  End;
 End;
End;

BEGIN
 Try
  { Initialiser les structures }
  InitializeStructures;
  
  If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
    (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
   WriteLn('NETSTAT : Affichage des connexions réseau et statistiques');
   WriteLn;
   WriteLn('Syntaxe :');
   WriteLn('  NETSTAT [options]');
   WriteLn;
   WriteLn('Options :');
   WriteLn('  -t, --tcp              Afficher les connexions TCP seulement');
   WriteLn('  -u, --udp              Afficher les connexions UDP seulement');
   WriteLn('  -l, --listening        Afficher les ports en écoute seulement');
   WriteLn('  -e, --established      Afficher les connexions établies seulement');
   WriteLn('  -a, --all              Afficher toutes les connexions');
   WriteLn('  -r, --route            Afficher la table de routage');
   WriteLn('  -i, --interfaces       Afficher les statistiques d''interface');
   WriteLn('  -s, --statistics       Afficher les statistiques par protocole');
   WriteLn('  -n, --numeric          Affichage numérique (pas de résolution)');
   WriteLn;
   WriteLn('Exemples :');
   WriteLn('  NETSTAT                # Toutes les connexions TCP et UDP');
   WriteLn('  NETSTAT -t             # Connexions TCP seulement');
   WriteLn('  NETSTAT -l             # Ports en écoute');
   WriteLn('  NETSTAT -s             # Statistiques protocoles');
   WriteLn('  NETSTAT -r             # Table de routage');
   WriteLn('  NETSTAT -i             # Statistiques interfaces');
   WriteLn;
   WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (données réelles)');
  End
   Else
  If ParamStr(1)='--version'Then Begin
   WriteLn('NETSTAT 1.00 - Statistiques réseau, NETWORKKIT-P, corail');
   WriteLn('Licence MIT');
   WriteLn;
   WriteLn('Écrit par Sylvain Maltais');
  End
   Else
  Begin
   ParseCommand;
  End;
  
  { Sortie propre }
  Halt(0);
  
 Except
  On E:Exception Do Begin
   WriteLn('Erreur lors de l''exécution: ',E.Message);
   Halt(1);
  End;
 End;
END.
