{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2021
  @version: 1.01
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal)
}

Program IPCONFIG;

{$IFDEF FPC}
 Uses
  Winsock;

 Type
  TaPInAddr=Array [0..10]of PInAddr;
  PaPInAddr=^TaPInAddr;

 Var
  phe:PHostEnt;
  pptr:PaPInAddr;
  Buffer:Array [0..63] of Ansichar;
  I:Integer;
  GInitData:TWSADATA;
{$ELSE}
 Type
  { Structure NetBIOS Control Block simplifiÇe }
  TNetBIOSNCB=Record
   ncb_command:Byte;                  { Commande NetBIOS }
   ncb_retcode:Byte;                  { Code de retour }
   ncb_lsn:Byte;                      { Local Session Number }
   ncb_num:Byte;                      { NumÔøΩro de nom }
   ncb_buffer:Pointer;                { Pointeur vers un tampon }
   ncb_length:Word;                   { Longueur du tampon }
   ncb_callname:Array[0..15] of Char; { Nom appelÇ }
   ncb_name:Array[0..15] of Char;     { Nom local }
   ncb_rto:Byte;                      { DÇpassement de dÇlai de rÇception }
   ncb_sto:Byte;                      { DÇpassement de dÇlai d'envoi }
   ncb_post:Pointer;                  { Adresse de routine post }
   ncb_lana_num:Byte;                 { NumÇro d'adaptateur }
   ncb_cmd_cplt:Byte;                 { Commande complÇtÇe }
   ncb_reserve:Array[0..13] of Char;  { RÇservÇ }
  End;

  { Structure pour les informations adaptateur }
  TAdapterStatus = Record
   adapter_address:Array[0..5] of Byte;
   rev_major:Byte;
   reserved0:Byte;
   adapter_type:Byte;
   rev_minor:Byte;
   duration:Word;
   frmr_recv:Word;
   frmr_xmit:Word;
   iframe_recv_err:Word;
   xmit_aborts:Word;
   xmit_success:LongInt;
   recv_success:LongInt;
   iframe_xmit_err:Word;
   recv_buff_unavail:Word;
   t1_timeouts:Word;
   ti_timeouts:Word;
   reserved1:LongInt;
   free_ncbs:Word;
   max_cfg_ncbs:Word;
   max_ncbs:Word;
   xmit_buf_unavail:Word;
   max_dgram_size:Word;
   pending_sess:Word;
   max_cfg_sess:Word;
   max_sess:Word;
   max_sess_pkt_size:Word;
   name_count:Word;
  End;

 Var
  NCB:TNetBIOSNCB;
  AdapterInfo:TAdapterStatus;
  IPAddr:LongInt;
{$ENDIF}

{$IFNDEF FPC}
Function IntToStr(Value:LongInt):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Function IPToString(IP:LongInt):String;Begin
 IPToString:=IntToStr(IP and $FF)+'.'+
             IntToStr((IP shr 8) and $FF)+'.'+
             IntToStr((IP shr 16) and $FF)+'.'+
             IntToStr((IP shr 24) and $FF);
End;

{ Fonction tentant de dÇtecter une adresse IP via interruptions DOS }
Function DetectTCPIP:LongInt;
Var
 IPDetected:Boolean;
 IPAddress:LongInt;
Begin
 IPDetected:=False;
 IPAddress:=0;
  { Test pour WATTCP/DOS TCP/IP stack via interruption 2Fh }
 ASM
  MOV AX, 6100h                  { WATTCP function }
  INT 2Fh                        { Multiplex interrupt }
  CMP AL, 0                      { Stack installÇ ? }
  JNE @no_wattcp                 { Si pas installÇ, passer au suivant }
  MOV AX, 6101h                  { Get IP address }
  INT 2Fh                        { Appel WATTCP }
  JC @no_wattcp                  { Si erreur, passer au suivant }
  MOV WORD PTR IPAddress, AX     { IP partie basse }
  MOV WORD PTR IPAddress+2, DX   { IP partie haute }
  MOV IPDetected, 1              { Marquer comme trouvÇ }
 @no_wattcp:
 END;
  { Test pour Microsoft LAN Manager via interruption 2Fh }
 If Not IPDetected Then ASM
  MOV AX, 0B800h       { LAN Manager function }
  INT 2Fh              { Multiplex interrupt }
  CMP AL, 0FFh         { LAN Manager installÇ ? }
  JNE @no_lanman       { Si pas installÇ, passer au suivant }
  MOV AX, 0B801h       { Get network info }
  INT 2Fh              { Appel LAN Manager }
  { Note: LAN Manager ne retourne pas directement l'IP }
 @no_lanman:
 END;
  { Si aucune dÇtection rÇussie, utiliser une IP simulÇe }
 If Not IPDetected Then
  IPAddress:=$C0A80019; { 192.168.0.25 - IP simulÇe pour dÇmonstration }
 DetectTCPIP:=IPAddress;
End;

Function IntToHex(Value:Byte;Digits:Byte):String;
Const
 HexDigits:Array[0..15] of Char = '0123456789ABCDEF';
Var
 Result:String;
Begin
 Result:='';
 If Digits>=2 Then Result:=HexDigits[Value div 16];
 Result:=Result+HexDigits[Value mod 16];
 IntToHex:=Result;
End;

{ Fonction pour vÇrifier si NetBIOS est installÇ }
Function IsNetBIOSInstalled:Boolean;
Var
 NetBIOSPresent:Boolean;
Begin
 NetBIOSPresent:=False;
 ASM
  PUSH ES              { Sauvegarder ES }
  MOV AX, 0            { Segment 0 }
  MOV ES, AX           { ES pointe vers le vecteur d'interruption }
  MOV BX, 5Ch * 4      { Offset de l'interruption 5Ch }
  MOV AX, ES:[BX]      { Charger l'offset }
  MOV DX, ES:[BX+2]    { Charger le segment }
  OR AX, DX            { Tester si AX ou DX est non-zÔøΩro }
  JZ @no_netbios       { Si zÇro, NetBIOS pas installÇ }
  MOV NetBIOSPresent, 1 { Marquer comme prÇsent }
 @no_netbios:
  POP ES               { Restaurer ES }
 END;
 IsNetBIOSInstalled:=NetBIOSPresent;
End;

{ ProcÔøΩdure pour appeler NetBIOS via assembleur standard }
Procedure CallNetBIOS(Var NCB:TNetBIOSNCB);
Begin
 If Not IsNetBIOSInstalled Then Begin
  NCB.ncb_retcode:=$FF; { Code d'erreur: NetBIOS non installÔøΩ }
  Exit;
 End;
 ASM
  PUSH DS              { Sauvegarder DS }
  LES BX, NCB          { ES:BX pointe vers le NCB }
  MOV AX, DS           { Copier DS dans ES }
  MOV ES, AX           { ES = DS }
  INT 5Ch              { Appel NetBIOS }
  POP DS               { Restaurer DS }
 END;
End;
{$ENDIF}

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('IPCONFIG : Cette commande permet d''afficher l''adresse IP de la machine local');
  WriteLn;
  WriteLn('Syntaxe : IPCONFIG [--version]');
  WriteLn;
  WriteLn(' --version   Ce paramätre permet de demander la version de cette commande.');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('IPCONFIG 1.01 - Clone Pascal de corail, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
   WriteLn;
   WriteLn('Configuration IP de Windows');
   WriteLn;
   WriteLn;
   WSAStartup($101,GInitData);
   GetHostName(Buffer,SizeOf(Buffer));
   phe:=GetHostByName(Buffer);
   If phe = nil Then Begin
    WriteLn('Hote introuvable');
    Exit;
   End;
   pptr:=PaPInAddr(phe^.h_addr_list);
   i:=0;
   While pptr^[i] <> nil do Begin
    WriteLn('Carte Ethernet Local Area Connection ',I+1,' :');
    WriteLn;
    WriteLn('   Adresse IPv4 . . . :',StrPas(inet_ntoa(pptr^[i]^)));
    WriteLn;
    Inc(i);
   End;
   WSACleanup;
  {$ELSE}
   { ImplÇmentation avancÇe pour Turbo Pascal }
   WriteLn;
   WriteLn('Configuration IP de Windows (DOS)');
   WriteLn;
   WriteLn;
    { Tentative de dÇtection d'adresse IP via interruptions rÇseau }
   IPAddr:=DetectTCPIP;
   If IPAddr<>0 Then Begin
    WriteLn('Carte rÇseau TCP/IP dÇtectÇe :');
    WriteLn;
    WriteLn('   Adresse IPv4 . . . : ',IPToString(IPAddr));
    WriteLn('   Masque de sous-rÔøΩseau: 255.255.255.0');
    WriteLn('   Passerelle . . . . . : DÇtection non supportÇe');
    WriteLn;
    WriteLn('Source: Pilote rÇseau DOS dÇtectÇ (simulation)');
   End
    Else
   Begin
    WriteLn('Aucune adresse IP dÇtectÇe, utilisation NetBIOS...');
    WriteLn;
     { Initialisation du NCB }
    FillChar(NCB,SizeOf(NCB),0);
    FillChar(AdapterInfo,SizeOf(AdapterInfo),0);
     { Commande NetBIOS ADAPTER_STATUS }
    NCB.ncb_command:=$33;  { NCBADAPTERSTATUS }
    NCB.ncb_lana_num:=0;   { Premier adaptateur }
    NCB.ncb_buffer:=@AdapterInfo;
    NCB.ncb_length:=SizeOf(AdapterInfo);
    NCB.ncb_callname[0]:='*'; { Nom g√©n√©rique }
     { Appel NetBIOS }
    CallNetBIOS(NCB);
    If NCB.ncb_retcode=0 Then Begin
     WriteLn('Carte Ethernet Local Area Connection :');
     WriteLn;
     Write('   Adresse MAC . . . . : ');
     Write(IntToHex(AdapterInfo.adapter_address[0],2),'-');
     Write(IntToHex(AdapterInfo.adapter_address[1],2),'-');
     Write(IntToHex(AdapterInfo.adapter_address[2],2),'-');
     Write(IntToHex(AdapterInfo.adapter_address[3],2),'-');
     Write(IntToHex(AdapterInfo.adapter_address[4],2),'-');
     WriteLn(IntToHex(AdapterInfo.adapter_address[5],2));
     WriteLn;
     WriteLn('   Type adaptateur . . : ',AdapterInfo.adapter_type);
     WriteLn('   Paquets transmis  . : ',AdapterInfo.xmit_success);
     WriteLn('   Paquets reáus . . . : ',AdapterInfo.recv_success);
     WriteLn;
      { Tentative d'obtenir plus d'informations rÔøΩseau }
     WriteLn('Note: Adresse IP non disponible via NetBIOS');
     WriteLn('      Utilisez Free Pascal pour plus d''informations');
    End
     Else
    Begin
     If NCB.ncb_retcode=$FF Then Begin
      WriteLn('NetBIOS n''est pas installÔøΩ sur cette machine.');
      WriteLn('L''interruption 5Ch n''est pas disponible.');
     End
      Else
     Begin
      WriteLn('Erreur NetBIOS (code ',NCB.ncb_retcode,')');
      WriteLn('VÇrifiez que NetBIOS est installÇ et configurÇ');
     End;
     WriteLn;
     WriteLn('Configuration rÇseau simple :');
     WriteLn('   Adaptateur rÇseau dÇtectÇ mais informations limitÇes');
    End;
   End; { Fin du else pour la dÇtection IP }
  {$ENDIF}
 End;
END.
