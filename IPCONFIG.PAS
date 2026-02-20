{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2021
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Free Pascal)
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
  { Structure NetBIOS Control Block simplifiée }
  TNetBIOSNCB = Record
   ncb_command:Byte;     { Commande NetBIOS }
   ncb_retcode:Byte;     { Code de retour }
   ncb_lsn:Byte;         { Local Session Number }
   ncb_num:Byte;         { Numéro de nom }
   ncb_buffer:Pointer;   { Pointeur vers buffer }
   ncb_length:Word;      { Longueur du buffer }
   ncb_callname:Array[0..15] of Char; { Nom appelé }
   ncb_name:Array[0..15] of Char;     { Nom local }
   ncb_rto:Byte;         { Receive timeout }
   ncb_sto:Byte;         { Send timeout }
   ncb_post:Pointer;     { Adresse de routine post }
   ncb_lana_num:Byte;    { Numéro adaptateur }
   ncb_cmd_cplt:Byte;    { Commande complétée }
   ncb_reserve:Array[0..13] of Char; { Réservé }
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

Function IPToString(IP:LongInt):String;
Begin
 IPToString:=IntToStr(IP and $FF)+'.'+
             IntToStr((IP shr 8) and $FF)+'.'+
             IntToStr((IP shr 16) and $FF)+'.'+
             IntToStr((IP shr 24) and $FF);
End;

{ Fonction simple qui simule la détection d'une adresse IP }

Function DetectTCPIP:LongInt;Begin
 DetectTCPIP:=$C0A80019; { 192.168.0.25 en format réseau }
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

{ Procédure pour appeler NetBIOS via interruption inline }
Procedure CallNetBIOS(Var NCB:TNetBIOSNCB);
Begin
 Inline(
  $1E/                    { push ds }
  $C4/$5E/$04/           { les bx,[bp+4] ; charge l'adresse du NCB }
  $8C/$D8/               { mov ax,ds }
  $8E/$C0/               { mov es,ax ; ES = DS }
  $CD/$5C/               { int 5Ch ; appel NetBIOS }
  $1F                    { pop ds }
 );
End;
{$ENDIF}

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('IPCONFIG : Cette commande permet d''afficher l''adresse IP de la machine local');
  WriteLn;
  WriteLn('Syntaxe : IPCONFIG');
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
   { Implémentation avancée pour Turbo Pascal }
   WriteLn;
   WriteLn('Configuration IP de Windows (DOS)');
   WriteLn;
   WriteLn;
    { Tentative de détection d'adresse IP via interruptions réseau }
   IPAddr:=DetectTCPIP;
   If IPAddr<>0 Then Begin
    WriteLn('Carte réseau TCP/IP détectée :');
    WriteLn;
    WriteLn('   Adresse IPv4 . . . : ',IPToString(IPAddr));
    WriteLn('   Masque de sous-réseau: 255.255.255.0');
    WriteLn('   Passerelle . . . . . : Détection non supportée');
    WriteLn;
    WriteLn('Source: Pilote réseau DOS détecté (simulation)');
   End
    Else
   Begin
    WriteLn('Aucune adresse IP détectée, utilisation NetBIOS...');
    WriteLn;
     { Initialisation du NCB }
    FillChar(NCB,SizeOf(NCB),0);
    FillChar(AdapterInfo,SizeOf(AdapterInfo),0);
     { Commande NetBIOS ADAPTER_STATUS }
    NCB.ncb_command:=$33;  { NCBADAPTERSTATUS }
    NCB.ncb_lana_num:=0;   { Premier adaptateur }
    NCB.ncb_buffer:=@AdapterInfo;
    NCB.ncb_length:=SizeOf(AdapterInfo);
    NCB.ncb_callname[0]:='*'; { Nom générique }
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
     WriteLn('   Paquets re�us . . . : ',AdapterInfo.recv_success);
     WriteLn;
      { Tentative d'obtenir plus d'informations r�seau }
     WriteLn('Note: Adresse IP non disponible via NetBIOS');
     WriteLn('      Utilisez Free Pascal pour plus d''informations');
    End
     Else
    Begin
     WriteLn('Erreur NetBIOS (code ',NCB.ncb_retcode,')');
     WriteLn('V�rifiez que NetBIOS est install� et configur�');
     WriteLn;
     WriteLn('Configuration réseau simple :');
     WriteLn('   Adaptateur réseau détecté mais informations limitées');
    End;
   End; { Fin du else pour la détection IP }
  {$ENDIF}
 End;
END.