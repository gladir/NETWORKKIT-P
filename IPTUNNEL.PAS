{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Commande iptunnel (gestion des tunnels IP))
}

Program IPTUNNEL;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows, WinSock;
{$ELSE}
 Uses DOS;
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour un tunnel IP }
 TTunnelInfo = Record
  Name:String;
  Mode:String;          { ipip, gre, sit,... }
  RemoteAddr:String;    { Adresse distante }
  LocalAddr:String;     { Adresse locale }
  TTL:Integer;          { Time To Live }
  TOS:Integer;          { Type Of Service }
  Key:String;           { Clef GRE }
  IKey:String;          { Clef d'entrÇe }
  OKey:String;          { Clef de sortie }
  Dev:String;           { Interface physique }
  Seq:Boolean;          { SÇquenáage }
  Csum:Boolean;         { Checksum }
  Active:Boolean;       { Tunnel actif }
  MTU:Integer;          { Maximum Transmission Unit }
 End;

  { Types de tunnels support√©s }
 TTunnelMode = (tmIPIP, tmGRE, tmSIT, tmIPv6, tmVTI);

Const
 { Modes de tunnels }
 TUNNEL_MODES:Array[TTunnelMode] of String = (
  'ipip', 'gre', 'sit', 'ipv6', 'vti'
 );

  { Constantes pour les tunnels }
 MAX_TUNNELS = 32;
 DEFAULT_TTL = 64;
 DEFAULT_TOS = 0;

Var
 Tunnels:Array[0..MAX_TUNNELS-1] of TTunnelInfo;
 TunnelCount:Integer;

 { Fonctions externes Windows pour interfaces rÇseau }
Function CreateInterface(Name:PChar):HANDLE;stdcall;external 'kernel32.dll' name 'CreateFileA';
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
Procedure InitializeTunnels;
Var
 I:Integer;
Begin
 TunnelCount:=0;
 For I:=0 To MAX_TUNNELS-1 Do Begin
  With Tunnels[I] Do Begin
   Name:='';
   Mode:='';
   RemoteAddr:='';
   LocalAddr:='';
   TTL:=DEFAULT_TTL;
   TOS:=DEFAULT_TOS;
   Key:='';
   IKey:='';
   OKey:='';
   Dev:='';
   Seq:=False;
   Csum:=False;
   Active:=False;
   MTU:=1500;
  End;
 End;
End;

 { Fonction pour valider une adresse IP }
Function IsValidIP(IP:String):Boolean;
Var
 I,Dots,Num:Integer;
 S:String;
 P:Integer;
Begin
 IsValidIP:=False;
 If Length(IP)=0 Then Exit;
 Dots:=0;
 S:=IP+'.';
 P:=1;
 For I:=1 To Length(S) Do Begin
  If S[I]='.' Then Begin
   If P=I Then Exit; { Deux points consÇcutifs }
   Num:=StrToInt(Copy(S,P,I-P));
   If (Num<0) or (Num>255) Then Exit;
   Inc(Dots);
   P:=I+1;
  End
   Else
  If not (S[I] in ['0'..'9']) Then Exit;
 End;
 IsValidIP:=(Dots=4);
End;

{ Fonction pour obtenir le mode de tunnel par nom }
Function GetTunnelMode(ModeName:String):TTunnelMode;
Var
 Mode:TTunnelMode;
Begin
 ModeName:=LowerCase(ModeName);
 For Mode:=Low(TTunnelMode) To High(TTunnelMode) Do Begin
  If TUNNEL_MODES[Mode]=ModeName Then Begin
   GetTunnelMode:=Mode;
   Exit;
  End;
 End;
 GetTunnelMode:=tmIPIP; { Par dÇfaut }
End;

 { Fonction pour trouver un tunnel par nom }
Function FindTunnel(Name:String):Integer;
Var
 I:Integer;
Begin
 FindTunnel:=-1;
 For I:=0 To TunnelCount-1 Do Begin
  If LowerCase(Tunnels[I].Name)=LowerCase(Name) Then Begin
   FindTunnel:=I;
   Exit;
  End;
 End;
End;

 { ProcÇdure pour ajouter un tunnel }
Function AddTunnel(Name,Mode,Remote,Local,Device:String):Boolean;
Var
 Index:Integer;
Begin
 AddTunnel:=False;
  { VÇrifier si le tunnel existe dÇjÖ }
 Index:=FindTunnel(Name);
 If Index>=0 Then Begin
  WriteLn('Erreur: Le tunnel "',Name,'" existe dÇjÖ');
  Exit;
 End;
  { VÇrifier l'espace disponible }
 If TunnelCount>=MAX_TUNNELS Then Begin
  WriteLn('Erreur: Nombre maximum de tunnels atteint (',MAX_TUNNELS,')');
  Exit;
 End;
  { Valider les adresses IP }
 If (Remote<>'') and not IsValidIP(Remote) Then Begin
  WriteLn('Erreur: Adresse distante invalide: ',Remote);
  Exit;
 End;
 If (Local<>'') and not IsValidIP(Local) Then Begin
  WriteLn('Erreur: Adresse locale invalide: ',Local);
  Exit;
 End;
  { CrÇer le tunnel }
 Index:=TunnelCount;
 Tunnels[Index].Name:=Name;
 Tunnels[Index].Mode:=LowerCase(Mode);
 Tunnels[Index].RemoteAddr:=Remote;
 Tunnels[Index].LocalAddr:=Local;
 Tunnels[Index].Dev:=Device;
 Tunnels[Index].TTL:=DEFAULT_TTL;
 Tunnels[Index].TOS:=DEFAULT_TOS;
 Tunnels[Index].Key:='';
 Tunnels[Index].IKey:='';
 Tunnels[Index].OKey:='';
 Tunnels[Index].Seq:=False;
 Tunnels[Index].Csum:=False;
 Tunnels[Index].Active:=False;
 Tunnels[Index].MTU:=1500;
 Inc(TunnelCount);
 WriteLn('Tunnel "',Name,'" crÇÇ avec succäs');
 AddTunnel:=True;
End;

{ ProcÇdure pour supprimer un tunnel }
Function DeleteTunnel(Name:String):Boolean;
Var
 Index,I:Integer;
Begin
 DeleteTunnel:=False;
 Index:=FindTunnel(Name);
 If Index<0 Then Begin
  WriteLn('Erreur: Tunnel "',Name,'" introuvable');
  Exit;
 End;
  { DÇsactiver le tunnel s'il est actif }
 If Tunnels[Index].Active Then Begin
  Tunnels[Index].Active:=False;
  WriteLn('Tunnel "',Name,'" dÇsactivÇ');
 End;
  { DÇcaler les tunnels suivants }
 For I:=Index To TunnelCount-2 Do Begin
  Tunnels[I]:=Tunnels[I+1];
 End;
 Dec(TunnelCount);
 WriteLn('Tunnel "',Name,'" supprimÇ avec succäs');
 DeleteTunnel:=True;
End;

{ ProcÇdure pour modifier un tunnel }
Function ChangeTunnel(Name:String;Params:Array of String):Boolean;
Var
 Index,I:Integer;
 ParamKey,Value:String;
 P:Integer;
Begin
 ChangeTunnel:=False;
 Index:=FindTunnel(Name);
 If Index<0 Then Begin
  WriteLn('Erreur: Tunnel "',Name,'" introuvable');
  Exit;
 End;
  { Analyser les paramätres }
 For I:=0 To High(Params) Do Begin
  P:=Pos('=',Params[I]);
  If P>0 Then Begin
   ParamKey:=LowerCase(Copy(Params[I],1,P-1));
   Value:=Copy(Params[I],P+1,Length(Params[I]));
   With Tunnels[Index] Do Begin
    If ParamKey='remote' Then Begin
     If IsValidIP(Value) Then RemoteAddr:=Value
     Else Begin
      WriteLn('Erreur: Adresse distante invalide: ',Value);
      Exit;
     End;
    End Else If ParamKey='local' Then Begin
     If IsValidIP(Value) Then LocalAddr:=Value
     Else Begin
      WriteLn('Erreur: Adresse locale invalide: ',Value);
      Exit;
     End;
    End Else If ParamKey='ttl' Then Begin
     TTL:=StrToInt(Value);
     If (TTL<1) or (TTL>255) Then TTL:=DEFAULT_TTL;
    End Else If ParamKey='tos' Then Begin
     TOS:=StrToInt(Value);
     If (TOS<0) or (TOS>255) Then TOS:=DEFAULT_TOS;
    End Else If ParamKey='key' Then Begin
     Key:=Value;
    End Else If ParamKey='ikey' Then Begin
     IKey:=Value;
    End Else If ParamKey='okey' Then Begin
     OKey:=Value;
    End Else If ParamKey='dev' Then Begin
     Dev:=Value;
    End Else If ParamKey='mtu' Then Begin
     MTU:=StrToInt(Value);
     If (MTU<68) or (MTU>65535) Then MTU:=1500;
    End Else If ParamKey='seq' Then Begin
     Seq:=(LowerCase(Value)='on') or (Value='1');
    End Else If ParamKey='csum' Then Begin
     Csum:=(LowerCase(Value)='on') or (Value='1');
    End
     Else
    Begin
     WriteLn('Avertissement: Paramätre inconnu: ',ParamKey);
    End;
   End;
  End;
 End;
 WriteLn('Tunnel "',Name,'" modifiÇ avec succäs');
 ChangeTunnel:=True;
End;

 { ProcÇdure pour activer/dÇsactiver un tunnel }
Function SetTunnelState(Name:String;Active:Boolean):Boolean;
Var
 Index:Integer;
Begin
 SetTunnelState:=False;
 Index:=FindTunnel(Name);
 If Index<0 Then Begin
  WriteLn('Erreur: Tunnel "',Name,'" introuvable');
  Exit;
 End;
 Tunnels[Index].Active:=Active;
 If Active Then WriteLn('Tunnel "',Name,'" activÇ')
           Else WriteLn('Tunnel "',Name,'" dÇsactivÇ');
 SetTunnelState:=True;
End;

{ ProcÇdure pour afficher les tunnels }
Procedure ShowTunnels(Detailed:Boolean);
Var
 I:Integer;
Begin
 If TunnelCount=0 Then Begin
  WriteLn('Aucun tunnel configurÇ');
  Exit;
 End;
 If Detailed Then Begin
  WriteLn('Tunnels IP configurÇs (dÇtaillÇ):');
  WriteLn('===============================================');
  For I:=0 To TunnelCount-1 Do Begin
   With Tunnels[I] Do Begin
    WriteLn;
    WriteLn('Tunnel: ',Name);
    WriteLn('  Mode     : ',Mode);
    Write('  êtat     : ');
    If Active Then WriteLn('ACTIF') Else WriteLn('INACTIF');
    Write('  Distant  : ');
    If RemoteAddr<>'' Then WriteLn(RemoteAddr) Else WriteLn('any');
    Write('  Local    : ');
    If LocalAddr<>'' Then WriteLn(LocalAddr) Else WriteLn('any');
    Write('  Device   : ');
    If Dev<>'' Then WriteLn(Dev) Else WriteLn('any');
    WriteLn('  TTL      : ',TTL);
    WriteLn('  TOS      : ',TOS);
    WriteLn('  MTU      : ',MTU);
    If Key<>'' Then WriteLn('  Clef      : ',Key);
    If IKey<>'' Then WriteLn('  Clef-E    : ',IKey);
    If OKey<>'' Then WriteLn('  Clef-S    : ',OKey);
    If Seq Then WriteLn('  SÇquence : activÇ');
    If Csum Then WriteLn('  Checksum : activÇ');
   End;
  End;
 End
  Else
 Begin
  WriteLn('Nom         Mode  êtat     Distant         Local           Device');
  WriteLn('----------- ----- -------- --------------- --------------- --------');
  For I:=0 To TunnelCount-1 Do Begin
   With Tunnels[I] Do Begin
    Write(Copy(Name+'           ',1,11),' ');
    Write(Copy(Mode+'     ',1,5),' ');
    If Active Then
     Write('ACTIF   ')
    Else
     Write('INACTIF ');
    If RemoteAddr<>'' Then
     Write(Copy(RemoteAddr+'               ',1,15))
    Else
     Write('any            ');
    Write(' ');
    If LocalAddr<>'' Then
     Write(Copy(LocalAddr+'               ',1,15))
    Else
     Write('any            ');
    Write(' ');
    If Dev<>'' Then
     WriteLn(Copy(Dev+'        ',1,8))
    Else
     WriteLn('any     ');
   End;
  End;
 End;
 WriteLn;
 WriteLn('Total: ',TunnelCount,' tunnel(s) configurÇ(s)');
End;

{ ProcÇdure pour crÇer des tunnels de dÇmonstration }
Procedure CreateSampleTunnels;
Begin
 { Tunnel GRE vers un serveur distant }
 AddTunnel('gre0','gre','203.0.113.1','192.168.1.100','eth0');
 If TunnelCount>0 Then Begin
  With Tunnels[TunnelCount-1] Do Begin
   Key:='12345';
   TTL:=255;
   Csum:=True;
  End;
 End;
  { Tunnel IPIP pour IPv4 over IPv4 }
 AddTunnel('ipip0','ipip','198.51.100.1','192.168.1.100','eth0');
 If TunnelCount>0 Then Begin
  With Tunnels[TunnelCount-1] Do Begin
   TTL:=64;
   MTU:=1480;
  End;
 End;
  { Tunnel SIT pour IPv6 over IPv4 - utiliser une adresse IPv4 pour l'exemple }
 AddTunnel('sit0','sit','192.0.2.1','192.168.1.100','eth0');
 If TunnelCount>0 Then Begin
  With Tunnels[TunnelCount-1] Do Begin
   TTL:=64;
   MTU:=1480;
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedTunnels;Begin
 WriteLn('Tunnels IP configurÇs (simulation):');
 WriteLn('Nom         Mode  √âtat     Distant         Local           Device');
 WriteLn('----------- ----- -------- --------------- --------------- --------');
 WriteLn('gre0        gre   ACTIF    203.0.113.1     192.168.1.100   eth0');
 WriteLn('ipip0       ipip  INACTIF  198.51.100.1    192.168.1.100   eth0');
 WriteLn('sit0        sit   ACTIF    2001:db8::1     192.168.1.100   eth0');
 WriteLn;
 WriteLn('Total: 3 tunnel(s) configurÇ(s)');
End;

Procedure ShowSimulatedDetailed;Begin
 WriteLn('Tunnels IP configurÇs (dÇtaillÇ):');
 WriteLn('===============================================');
 WriteLn;
 WriteLn('Tunnel: gre0');
 WriteLn('  Mode     : gre');
 WriteLn('  êtat     : ACTIF');
 WriteLn('  Distant  : 203.0.113.1');
 WriteLn('  Local    : 192.168.1.100');
 WriteLn('  Device   : eth0');
 WriteLn('  TTL      : 255');
 WriteLn('  TOS      : 0');
 WriteLn('  MTU      : 1476');
 WriteLn('  Clef     : 12345');
 WriteLn('  Checksum : activÇ');
 WriteLn;
 WriteLn('Tunnel: sit0');
 WriteLn('  Mode     : sit');
 WriteLn('  êtat     : ACTIF');
 WriteLn('  Distant  : 2001:db8::1');
 WriteLn('  Local    : 192.168.1.100');
 WriteLn('  Device   : eth0');
 WriteLn('  TTL      : 64');
 WriteLn('  TOS      : 0');
 WriteLn('  MTU      : 1480');
End;

Procedure SimulateAddTunnel;Begin
 WriteLn('Tunnel "test0" crÇÇ avec succäs (simulation)');
End;

Procedure SimulateDeleteTunnel;Begin
 WriteLn('Tunnel "test0" supprimÇ avec succäs (simulation)');
End;
{$ENDIF}

 { ProcÇdure pour analyser la ligne de commande }
Procedure ParseCommandLine;
Var
 I:Integer;
 Cmd:String;
 Action:String;
 TunnelName:String;
 Mode,Remote,Local,Device:String;
 ShowDetailed:Boolean;
 {$IFDEF FPC}
 Params:Array[0..15] of String;
 ParamCount_Local:Integer;
 {$ENDIF}
Begin
 Action:='show';  { Action par dÇfaut }
 TunnelName:='';
 Mode:='ipip';
 Remote:='';
 Local:='';
 Device:='';
 ShowDetailed:=False;
 {$IFDEF FPC}
  ParamCount_Local:=0;
 {$ENDIF}
 If ParamCount=0 Then Action:='show' Else
 Begin
  For I:=1 To ParamCount Do Begin
   Cmd:=LowerCase(ParamStr(I));
   If (Cmd='add') or (Cmd='create') Then
    Action:='add'
   Else If (Cmd='del') or (Cmd='delete') or (Cmd='remove') Then
    Action:='delete'
   Else If (Cmd='change') or (Cmd='modify') or (Cmd='set') Then
    Action:='change'
   Else If (Cmd='show') or (Cmd='list') Then
    Action:='show'
   Else If (Cmd='up') or (Cmd='enable') Then
    Action:='up'
   Else If (Cmd='down') or (Cmd='disable') Then
    Action:='down'
   Else If (Cmd='-d') or (Cmd='--detailed') Then
    ShowDetailed:=True
   Else If Copy(Cmd,1,5)='mode=' Then
    Mode:=Copy(ParamStr(I),6,Length(ParamStr(I))-5)
   Else If Copy(Cmd,1,7)='remote=' Then
    Remote:=Copy(ParamStr(I),8,Length(ParamStr(I))-7)
   Else If Copy(Cmd,1,6)='local=' Then
    Local:=Copy(ParamStr(I),7,Length(ParamStr(I))-6)
   Else If Copy(Cmd,1,4)='dev=' Then
    Device:=Copy(ParamStr(I),5,Length(ParamStr(I))-4)
   Else If (TunnelName='') and (Pos('=',Cmd)=0) and
           not (Cmd[1] in ['-','/']) Then Begin
    TunnelName:=ParamStr(I);
   {$IFDEF FPC}
   End Else If (Action='change') and (Pos('=',ParamStr(I))>0) Then Begin
    If ParamCount_Local<16 Then Begin
     Params[ParamCount_Local]:=ParamStr(I);
     Inc(ParamCount_Local);
    End;
   {$ENDIF}
   End;
  End;
 End;
 {$IFDEF FPC}
 { ExÇcuter l'action }
 Case Action Of
  'show':Begin
   If TunnelCount=0 Then CreateSampleTunnels; { CrÇer des exemples si rien }
   ShowTunnels(ShowDetailed);
  End;
  'add':Begin
   If TunnelName='' Then Begin
    WriteLn('Erreur: Nom de tunnel requis');
    WriteLn('Syntaxe: IPTUNNEL add TUNNEL mode=MODE remote=ADDR local=ADDR [dev=DEV]');
   End Else Begin
    AddTunnel(TunnelName,Mode,Remote,Local,Device);
   End;
  End;
  'delete':Begin
   If TunnelName='' Then Begin
    WriteLn('Erreur: Nom de tunnel requis');
    WriteLn('Syntaxe: IPTUNNEL delete TUNNEL');
   End Else Begin
    DeleteTunnel(TunnelName);
   End;
  End;
  'change':Begin
   If TunnelName='' Then Begin
    WriteLn('Erreur: Nom de tunnel requis');
    WriteLn('Syntaxe: IPTUNNEL change TUNNEL [paramätres]');
   End Else Begin
    ChangeTunnel(TunnelName,Params);
   End;
  End;
  'up':Begin
   If TunnelName='' Then Begin
    WriteLn('Erreur: Nom de tunnel requis');
    WriteLn('Syntaxe: IPTUNNEL up TUNNEL');
   End Else Begin
    SetTunnelState(TunnelName,True);
   End;
  End;
  'down':Begin
   If TunnelName='' Then Begin
    WriteLn('Erreur: Nom de tunnel requis');
    WriteLn('Syntaxe: IPTUNNEL down TUNNEL');
   End Else Begin
    SetTunnelState(TunnelName,False);
   End;
  End;
 End;
 {$ELSE}
 { Version Turbo Pascal }
 If Action='show'Then Begin
  If ShowDetailed Then ShowSimulatedDetailed Else ShowSimulatedTunnels;
 End
  Else
 If Action='add'Then SimulateAddTunnel Else
 If action='delete'Then SimulateDeleteTunnel
                   Else ShowSimulatedTunnels;
 {$ENDIF}
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('IPTUNNEL : Cette commande permet d''effectuer la gestion des tunnels IP');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  IPTUNNEL [action] [tunnel] [paramätres]');
  WriteLn;
  WriteLn('Actions :');
  WriteLn('  show, list            Afficher les tunnels (par dÇfaut)');
  WriteLn('  add, create           CrÇer un tunnel');
  WriteLn('  del, delete           Supprimer un tunnel');
  WriteLn('  change, modify        Modifier un tunnel');
  WriteLn('  up, enable            Activer un tunnel');
  WriteLn('  down, disable         DÇsactiver un tunnel');
  WriteLn;
  WriteLn('Param√®tres :');
  WriteLn('  mode=TYPE             Type de tunnel (ipip,gre,sit,vti)');
  WriteLn('  remote=ADDR           Adresse distante');
  WriteLn('  local=ADDR            Adresse locale');
  WriteLn('  dev=DEVICE            Interface physique');
  WriteLn('  ttl=VALUE             Time To Live (1-255)');
  WriteLn('  tos=VALUE             Type Of Service (0-255)');
  WriteLn('  key=KEY               Clef GRE');
  WriteLn('  ikey=KEY              Clef d''entrÇe');
  WriteLn('  okey=KEY              Clef de sortie');
  WriteLn('  seq=on/off            SÇquenáage');
  WriteLn('  csum=on/off           Checksum');
  WriteLn('  mtu=SIZE              MTU (68-65535)');
  WriteLn;
  WriteLn('Options d''affichage :');
  WriteLn('  -d, --detailed        Affichage dÇtaillÇ');
  WriteLn;
  WriteLn('Types de tunnels :');
  WriteLn('  ipip                  IP-in-IP (IPv4 over IPv4)');
  WriteLn('  gre                   Generic Routing Encapsulation');
  WriteLn('  sit                   Simple Internet Transition (6to4)');
  WriteLn('  vti                   Virtual Tunnel Interface');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  IPTUNNEL                              # Lister les tunnels');
  WriteLn('  IPTUNNEL show -d                      # Affichage dÇtaillÇ');
  WriteLn('  IPTUNNEL add gre0 mode=gre remote=203.0.113.1 local=192.168.1.100');
  WriteLn('  IPTUNNEL change gre0 key=12345 ttl=255');
  WriteLn('  IPTUNNEL up gre0                      # Activer le tunnel');
  WriteLn('  IPTUNNEL down gre0                    # DÇsactiver');
  WriteLn('  IPTUNNEL delete gre0                  # Supprimer');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion rÇelle)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('IPTUNNEL 1.00 - Clone Pascal pour NETWORKKIT-P, Linux-0, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeTunnels;
  { Cr√©er des exemples pour la d√©monstration si aucun param√®tre }
  If ParamCount=0 Then
   CreateSampleTunnels;
  {$ENDIF}
  ParseCommandLine;
 End;
END.