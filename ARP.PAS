{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande ARP (table ARP))
}

Program ARP;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour une entr�e ARP }
 TArpEntry = Record
  IPAddress:String;
  MACAddress:String;
  EntryType:String;
  InterfaceName:String;
  InterfaceIndex:DWORD;
 End;

 { Structure MIB_IPNETROW pour l'API Windows }
 MIB_IPNETROW = Packed Record
  dwIndex:DWORD;
  dwPhysAddrLen:DWORD;
  bPhysAddr:Array[0..7] of Byte;
  dwAddr:DWORD;
  dwType:DWORD;
 End;

 { Structure MIB_IPNETTABLE }
 MIB_IPNETTABLE = Packed Record
  dwNumEntries:DWORD;
  table:Array[0..0] of MIB_IPNETROW;
 End;
 PMIB_IPNETTABLE = ^MIB_IPNETTABLE;

Const
 { Types d'entr�es ARP }
 MIB_IPNET_TYPE_OTHER = 1;
 MIB_IPNET_TYPE_INVALID = 2;
 MIB_IPNET_TYPE_DYNAMIC = 3;
 MIB_IPNET_TYPE_STATIC = 4;

 NO_ERROR = 0;
 ERROR_INSUFFICIENT_BUFFER = 122;
 ERROR_NO_DATA = 232;

Var
 ArpTable:Array[0..255] of TArpEntry;
 ArpCount:Integer;

{ Fonction externe GetIpNetTable }
Function GetIpNetTable(pIpNetTable:PMIB_IPNETTABLE;Var pdwSize:ULONG;bOrder:BOOL):DWORD;stdcall;external 'iphlpapi.dll';

{ Fonction externe CreateIpNetEntry }
Function CreateIpNetEntry(Var pArpEntry:MIB_IPNETROW):DWORD;stdcall;external 'iphlpapi.dll';

{ Fonction externe DeleteIpNetEntry }
Function DeleteIpNetEntry(Var pArpEntry:MIB_IPNETROW):DWORD;stdcall;external 'iphlpapi.dll';

{ Fonction externe SetIpNetEntry }
Function SetIpNetEntry(Var pArpEntry:MIB_IPNETROW):DWORD;stdcall;external 'iphlpapi.dll';

{ Fonction externe FlushIpNetTable }
Function FlushIpNetTable(dwIfIndex:DWORD):DWORD;stdcall;external 'iphlpapi.dll';
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

Function Copy(S:String;Index,Count:Integer):String;
Var
 Result:String;
 I:Integer;
Begin
 Result:='';
 For I:=Index To Index+Count-1 Do
  If I<=Length(S) Then Result:=Result+S[I];
 Copy:=Result;
End;
{$ENDIF}

 { Fonction pour convertir un nombre en hexad�cimal }
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
 { Fonction pour convertir une adresse DWORD en cha�ne IP }
Function DWORDToIP(IPAddr:DWORD):String;
Begin
 DWORDToIP:=IntToStr(IPAddr and $FF)+'.'+
           IntToStr((IPAddr shr 8) and $FF)+'.'+
           IntToStr((IPAddr shr 16) and $FF)+'.'+
           IntToStr((IPAddr shr 24) and $FF);
End;

 { Fonction pour convertir une cha�ne IP en DWORD }
Function IPToDWORD(IPStr:String):DWORD;
Var
 Parts:Array[0..3] of Byte;
 I,PosPoint,Start:Integer;
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

 { Fonction pour convertir une cha�ne MAC en tableau d'octets }
Function MACToBytes(MACStr:String;Var MACBytes:Array of Byte):Boolean;
Var
 I,ByteIndex:Integer;
 HexStr:String;
 ByteValue:Integer;
 Code:Integer;
Begin
 MACToBytes:=False;
 ByteIndex:=0;
 HexStr:='';
 For I:=1 To Length(MACStr) Do Begin
  If MACStr[I] in ['0'..'9','A'..'F','a'..'f'] Then Begin
   HexStr:=HexStr+UpCase(MACStr[I]);
   If Length(HexStr)=2 Then Begin
    Val('$'+HexStr,ByteValue,Code);
    If (Code=0) and (ByteIndex<6) Then Begin
     MACBytes[ByteIndex]:=ByteValue;
     Inc(ByteIndex);
     HexStr:='';
    End;
   End;
  End Else If MACStr[I] in [':','-',' '] Then Begin
   { Séparateurs ignorés }
  End Else Begin
   Exit; { Caractère invalide }
  End;
 End;

 MACToBytes:=(ByteIndex=6);
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
  MACResult:=MACResult+IntToHex(MACBytes[I],2);
 End;
 FormatMAC:=MACResult;
End;

{ Fonction pour obtenir le type d'entr�e ARP }
Function GetArpType(EntryType:DWORD):String;
Begin
 Case EntryType Of
  MIB_IPNET_TYPE_OTHER:GetArpType:='autre';
  MIB_IPNET_TYPE_INVALID:GetArpType:='invalide';
  MIB_IPNET_TYPE_DYNAMIC:GetArpType:='dynamique';
  MIB_IPNET_TYPE_STATIC:GetArpType:='statique';
 Else
  GetArpType:='inconnu';
 End;
End;

{ Proc�dure pour obtenir la table ARP Windows }
Function GetArpTable:Boolean;
Var
 pIpNetTable:PMIB_IPNETTABLE;
 dwSize:ULONG;
 dwRetVal:DWORD;
 I:Integer;
 pRow:^MIB_IPNETROW;
Begin
 GetArpTable:=False;
 ArpCount:=0;
 dwSize:=0;

 { Première appel pour obtenir la taille }
 dwRetVal:=GetIpNetTable(nil,dwSize,True);
 If (dwRetVal<>ERROR_INSUFFICIENT_BUFFER) and (dwRetVal<>ERROR_NO_DATA) Then Exit;

 { Si pas de données, table vide }
 If dwRetVal=ERROR_NO_DATA Then Begin
  GetArpTable:=True;
  Exit;
 End;

 { Allouer la mémoire }
 GetMem(pIpNetTable,dwSize);
 Try
  { Obtenir la table ARP }
  dwRetVal:=GetIpNetTable(pIpNetTable,dwSize,True);
  If dwRetVal=NO_ERROR Then Begin
   ArpCount:=pIpNetTable^.dwNumEntries;
   If ArpCount>256 Then ArpCount:=256;

   For I:=0 To ArpCount-1 Do Begin
    pRow:=@pIpNetTable^.table[I];
    With ArpTable[I] Do Begin
     IPAddress:=DWORDToIP(pRow^.dwAddr);
     MACAddress:=FormatMAC(pRow^.bPhysAddr,pRow^.dwPhysAddrLen);
     EntryType:=GetArpType(pRow^.dwType);
     InterfaceIndex:=pRow^.dwIndex;
     InterfaceName:='eth'+IntToStr(InterfaceIndex);
    End;
   End;
   GetArpTable:=True;
  End;
 Finally
  FreeMem(pIpNetTable);
 End;
End;

{ Procédure pour afficher la table ARP }
Procedure ShowArpTable(ShowAll:Boolean);
Var
 I:Integer;
Begin
 WriteLn('Adresse          Type HW    Adresse HW        Indicateurs Masque     Interface');

 If GetArpTable Then Begin
  If ArpCount=0 Then
   WriteLn('Table ARP vide.')
  Else Begin
   For I:=0 To ArpCount-1 Do Begin
    With ArpTable[I] Do Begin
     { Filtrer les entrées invalides si demandé }
     If ShowAll or (EntryType<>'invalid') Then Begin
      Write(IPAddress);
      While Length(IPAddress)<17 Do Begin
       Write(' ');
       IPAddress:=IPAddress+' ';
      End;

      Write('ether ');
      Write(LowerCase(MACAddress));
      While Length(MACAddress)<18 Do Begin
       Write(' ');
       MACAddress:=MACAddress+' ';
      End;

      Write('C                         ');
      WriteLn(InterfaceName);
     End;
    End;
   End;
  End;
 End Else
  WriteLn('Erreur lors de la récupération de la table ARP');
End;

{ Procédure pour ajouter une entrée ARP statique }
Procedure AddArpEntry(IPAddr,MACAddr:String);
Var
 ArpEntry:MIB_IPNETROW;
 MACBytes:Array[0..5] of Byte;
 dwRetVal:DWORD;
Begin
 WriteLn('Ajout entrée ARP : ',IPAddr,' -> ',MACAddr);

 If Not MACToBytes(MACAddr,MACBytes) Then Begin
  WriteLn('Erreur : Adresse MAC invalide');
  Exit;
 End;

 FillChar(ArpEntry,SizeOf(ArpEntry),0);
 ArpEntry.dwAddr:=IPToDWORD(IPAddr);
 ArpEntry.dwPhysAddrLen:=6;
 Move(MACBytes,ArpEntry.bPhysAddr,6);
 ArpEntry.dwType:=MIB_IPNET_TYPE_STATIC;
 ArpEntry.dwIndex:=1;  { Interface par défaut }

 dwRetVal:=CreateIpNetEntry(ArpEntry);
 If dwRetVal=NO_ERROR Then
  WriteLn('Entrée ARP ajoutée avec succès')
 Else
  WriteLn('Erreur lors de l''ajout de l''entrée ARP : ',dwRetVal);
End;

{ Procédure pour supprimer une entrée ARP }
Procedure DelArpEntry(IPAddr:String);
Var
 ArpEntry:MIB_IPNETROW;
 dwRetVal:DWORD;
Begin
 WriteLn('Suppression entrée ARP : ',IPAddr);

 FillChar(ArpEntry,SizeOf(ArpEntry),0);
 ArpEntry.dwAddr:=IPToDWORD(IPAddr);
 ArpEntry.dwIndex:=1;  { Interface par défaut }

 dwRetVal:=DeleteIpNetEntry(ArpEntry);
 If dwRetVal=NO_ERROR Then
  WriteLn('Entrée ARP supprimée avec succès')
 Else
  WriteLn('Erreur lors de la suppression de l''entrée ARP : ',dwRetVal);
End;

{ Procédure pour vider la table ARP }
Procedure FlushArpTable;
Var
 dwRetVal:DWORD;
Begin
 WriteLn('Vidage de la table ARP...');

 dwRetVal:=FlushIpNetTable($FFFFFFFF);  { Toutes les interfaces }
 If dwRetVal=NO_ERROR Then
  WriteLn('Table ARP vidée avec succès')
 Else
  WriteLn('Erreur lors du vidage de la table ARP : ',dwRetVal);
End;

{ Procédure pour afficher une entrée ARP spécifique }
Procedure ShowSpecificArp(IPAddr:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;

 If GetArpTable Then Begin
  For I:=0 To ArpCount-1 Do Begin
   If ArpTable[I].IPAddress=IPAddr Then Begin
    If Not Found Then Begin
     WriteLn('Adresse          Type HW    Adresse HW        Indicateurs Masque     Interface');
     Found:=True;
    End;

    With ArpTable[I] Do Begin
     Write(IPAddress,'         ether ',LowerCase(MACAddress));
     WriteLn('   C                         ',InterfaceName);
    End;
   End;
  End;

  If Not Found Then
   WriteLn('Aucune entrée ARP trouvée pour ',IPAddr);
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedArp;
Begin
 WriteLn('Adresse          Type HW    Adresse HW        Indicateurs Masque     Interface');
 WriteLn('192.168.1.1      ether      00:1a:2b:3c:4d:5e   C                       eth0');
 WriteLn('192.168.1.100    ether      aa:bb:cc:dd:ee:ff   C                       eth0');
 WriteLn('192.168.1.254    ether      ff:ee:dd:cc:bb:aa   C                       eth0');
End;

Procedure SimulateAddArp(IPAddr,MACAddr:String);
Begin
 WriteLn('Simulation ajout ARP : ',IPAddr,' -> ',MACAddr);
 WriteLn('Entrée ARP ajoutée (simulation)');
End;

Procedure SimulateDelArp(IPAddr:String);
Begin
 WriteLn('Simulation suppression ARP : ',IPAddr);
 WriteLn('Entrée ARP supprimée (simulation)');
End;

Procedure SimulateFlushArp;
Begin
 WriteLn('Simulation vidage table ARP');
 WriteLn('Table ARP vidée (simulation)');
End;
{$ENDIF}

{ Procédure pour analyser les paramètres }
Procedure ParseCommand;
Var
 Cmd:String;
 IPAddr,MACAddr:String;
Begin
 If ParamCount<1 Then Begin
  {$IFDEF FPC}
  ShowArpTable(False);
  {$ELSE}
  ShowSimulatedArp;
  {$ENDIF}
  Exit;
 End;

 Cmd:=UpperCase(ParamStr(1));

 If (Cmd='-A') or (Cmd='--ALL') Then Begin
  { Afficher toutes les entrées }
  {$IFDEF FPC}
  ShowArpTable(True);
  {$ELSE}
  ShowSimulatedArp;
  {$ENDIF}
 End Else If (Cmd='-S') or (Cmd='--SET') Then Begin
  { Ajouter une entrée statique }
  If ParamCount>=3 Then Begin
   IPAddr:=ParamStr(2);
   MACAddr:=ParamStr(3);
   {$IFDEF FPC}
   AddArpEntry(IPAddr,MACAddr);
   {$ELSE}
   SimulateAddArp(IPAddr,MACAddr);
   {$ENDIF}
  End Else
   WriteLn('Usage : ARP -s adresse_ip adresse_mac');
 End Else If (Cmd='-D') or (Cmd='--DELETE') Then Begin
  { Supprimer une entrée }
  If ParamCount>=2 Then Begin
   IPAddr:=ParamStr(2);
   {$IFDEF FPC}
   DelArpEntry(IPAddr);
   {$ELSE}
   SimulateDelArp(IPAddr);
   {$ENDIF}
  End Else
   WriteLn('Usage : ARP -d adresse_ip');
 End Else If (Cmd='-F') or (Cmd='--FLUSH') Then Begin
  { Vider la table ARP }
  {$IFDEF FPC}
  FlushArpTable;
  {$ELSE}
  SimulateFlushArp;
  {$ENDIF}
 End Else If (Cmd='-N') or (Cmd='--NUMERIC') Then Begin
  { Mode numérique }
  {$IFDEF FPC}
  ShowArpTable(False);
  {$ELSE}
  ShowSimulatedArp;
  {$ENDIF}
 End Else If (Cmd[1]<>'-') and (Cmd[1]<>'/') Then Begin
  { Afficher une entrée spécifique }
  {$IFDEF FPC}
  ShowSpecificArp(ParamStr(1));
  {$ELSE}
  WriteLn('Recherche ARP pour ',ParamStr(1),' (simulation)');
  WriteLn('192.168.1.1      ether      00:1a:2b:3c:4d:5e   C                       eth0');
  {$ENDIF}
 End Else Begin
  WriteLn('Option inconnue : ',Cmd);
  WriteLn('Options disponibles : -a, -s, -d, -f, -n');
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('ARP : Cette commande permet d''effectuer la manipulation de la table ARP (Address Resolution Protocol)');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  ARP                    Afficher la table ARP');
  WriteLn('  ARP -a                 Afficher toutes les entrées');
  WriteLn('  ARP -s ip mac          Ajouter une entrée statique');
  WriteLn('  ARP -d ip              Supprimer une entrée');
  WriteLn('  ARP -f                 Vider la table ARP');
  WriteLn('  ARP -n                 Mode numérique');
  WriteLn('  ARP adresse_ip         Afficher une entrée spécifique');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  ip          Adresse IP');
  WriteLn('  mac         Adresse MAC (format: xx:xx:xx:xx:xx:xx)');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  ARP                              # Afficher la table');
  WriteLn('  ARP -s 192.168.1.100 aa:bb:cc:dd:ee:ff  # Ajouter entrée');
  WriteLn('  ARP -d 192.168.1.100             # Supprimer entrée');
  WriteLn('  ARP 192.168.1.1                  # Rechercher IP');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (table réelle)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('ARP 1.00 - Table ARP, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('�crit par Sylvain Maltais');
 End
  Else
 Begin
  WriteLn('Commande ARP - NETWORKKIT-P');
  WriteLn;
  ParseCommand;
 End;
END.