{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Informations NetBIOS)
}

Program NETBIOS;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 Uses DOS;
{$ENDIF}

Type
 { Structure NetBIOS Control Block (NCB) }
 NCB = Packed Record
  Command:Byte;                  { Commande NetBIOS }
  RetCode:Byte;                  { Code de retour }
  LSN:Byte;                      { Local Session Number }
  NameNum:Byte;                  { NumÇro du nom }
  Buffer:Pointer;                { Pointeur vers le tampon }
  Length:Word;                   { Longueur du tampon }
  CallName:Array[0..15]of Char;  { Nom appelÇ }
  LocalName:Array[0..15]of Char; { Nom local }
  RTO:Byte;                      { DÇpassement de dÇlai de la rÇception }
  STO:Byte;                      { DÇpassement de dÇlai de l'envoi }
  Lana_Num:Byte;                 { NumÇro de l'adaptateur }
  Cmd_Cplt:Byte;                 { Completion code }
  Reserve:Array[0..9]of Byte;    { RÇservÇ }
  Event:Pointer;                 { Descripteur d'ÇvÇnement }
 End;

 { Structure pour la liste des adaptateurs }
 LANA_ENUM = Packed Record
  Length:Byte;           { Nombre d'adaptateurs }
  LANA:Array[0..254]of Byte;  { Liste des num√©ros LANA }
 End;

 { Structure pour les statistiques d'adaptateur }
 ADAPTER_STATUS = Packed Record
  adapter_address:Array[0..5]of Byte;        { Adresse MAC }
  rev_major:Byte;                            { Version majeure }
  reserved0:Byte;                            { RÇservÇ }
  adapter_type:Byte;                         { Type d'adaptateur }
  rev_minor:Byte;                            { Version mineure }
  duration:Word;                             { DurÇe }
  frmr_recv:Word;                            { Trames FRMR re√ßues }
  frmr_xmit:Word;                            { Trames FRMR transmises }
  iframe_recv_err:Word;                      { Erreurs I-Frame re√ßues }
  xmit_aborts:Word;                          { Transmissions annul√©es }
  xmit_success:LongInt;                      { Transmissions r√©ussies }
  recv_success:LongInt;                      { R√©ceptions r√©ussies }
  iframe_xmit_err:Word;                      { Erreurs I-Frame transmises }
  recv_buff_unavail:Word;                    { Buffer de r√©ception indisponible }
  t1_timeouts:Word;                          { Timeouts T1 }
  ti_timeouts:Word;                          { Timeouts TI }
  reserved1:LongInt;                         { RÇservÇ }
  free_ncbs:Word;                            { NCBs libres }
  max_cfg_ncbs:Word;                         { NCBs maximum configurÇs }
  max_ncbs:Word;                             { NCBs maximum }
  xmit_buf_unavail:Word;                     { Tampon transmission indisponible }
  max_dgram_size:Word;                       { Taille maximum datagramme }
  pending_sess:Word;                         { Sessions en attente }
  max_cfg_sess:Word;                         { Sessions maximum configurÇes }
  max_sess:Word;                             { Sessions maximum }
  max_sess_pkt_size:Word;                    { Taille maximum paquet session }
  name_count:Word;                           { Nombre de noms }
 End;

 { Structure pour un nom NetBIOS }
 NAME_BUFFER = Packed Record
  name:Array[0..15]of Char;    { Nom NetBIOS }
  name_flags:Byte;             { Drapeaux du nom }
 End;

Var
 MyNCB:NCB;
 LanaEnum:LANA_ENUM;
 AdapterStatus:ADAPTER_STATUS;
 I:Integer;
 {$IFDEF FPC}
 NetBIOSHandle:THandle;
 BytesReturned:DWORD;
 {$ENDIF}

{ Fonction pour vÇrifier si NetBIOS est installÇ }
Function IsNetBIOSInstalled:Boolean;
{$IFNDEF FPC}
Var
 Int5CVector:Pointer;
{$ENDIF}
Begin
 {$IFDEF FPC}
  { Sous Free Pascal, vÇrifier la disponibilitÇ du service NetBIOS }
  NetBIOSHandle:=CreateFile('\\.\NETBIOS',GENERIC_READ or GENERIC_WRITE,
                           FILE_SHARE_READ or FILE_SHARE_WRITE,nil,
                           OPEN_EXISTING,0,0);
  IsNetBIOSInstalled:=(NetBIOSHandle<>INVALID_HANDLE_VALUE);
  If NetBIOSHandle<>INVALID_HANDLE_VALUE Then CloseHandle(NetBIOSHandle);
 {$ELSE}
  { Sous Turbo Pascal, vÇrifier l'interruption 5Ch }
  ASM
   PUSH ES
   MOV AX, 355Ch           { Obtenir le vecteur d'interruption 5Ch }
   INT 21h                 { Appel DOS }
   MOV WORD PTR Int5CVector, BX
   MOV WORD PTR Int5CVector+2, ES
   POP ES
  END;
  IsNetBIOSInstalled:=(Int5CVector<>Ptr($0000,$0000));
 {$ENDIF}
End;

{ Fonction NetBIOS - Turbo Pascal avec interruptions }
{$IFNDEF FPC}
 Function NetBIOSCall(Var NCB:NCB):Byte;Assembler;ASM
  PUSH ES
   MOV BX, WORD PTR NCB      { Adresse du NCB en BX:ES }
   MOV ES, WORD PTR NCB+2
   INT 5Ch                   { Interruption NetBIOS }
   MOV AL, ES:[BX+1]         { Code de retour dans RetCode }
  POP ES
 END;
{$ELSE}
  { Fonction NetBIOS - Free Pascal avec API Windows }
 Function NetBIOSCall(Var NCB:NCB):Byte;Begin
  If DeviceIoControl(CreateFile('\\.\NETBIOS',GENERIC_READ or GENERIC_WRITE,
                               FILE_SHARE_READ or FILE_SHARE_WRITE,nil,
                               OPEN_EXISTING,0,0),
                    0,@NCB,SizeOf(NCB),@NCB,SizeOf(NCB),BytesReturned,nil) Then
   NetBIOSCall:=NCB.RetCode
  Else
   NetBIOSCall:=$FF;
 End;
{$ENDIF}

{ ProcÇdure pour ÇnumÇrer les adaptateurs LANA }
Procedure EnumerateLANAs;
Begin
 FillChar(MyNCB,SizeOf(MyNCB),0);
 FillChar(LanaEnum,SizeOf(LanaEnum),0);

 MyNCB.Command:=$FE;         { NCBENUM - ênumÇrer les LANAs }
 MyNCB.Buffer:=@LanaEnum;
 MyNCB.Length:=SizeOf(LanaEnum);

 If NetBIOSCall(MyNCB)=0 Then Begin
  WriteLn('Adaptateurs NetBIOS trouvÇs : ',LanaEnum.Length);
  For I:=0 To LanaEnum.Length-1 Do
   WriteLn('  LANA ',I,' : ',LanaEnum.LANA[I]);
 End
  Else
 WriteLn('Erreur lors de l''ÇnumÇration des adaptateurs LANA');
End;

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

{ ProcÇdure pour obtenir les informations d'un adaptateur }
Procedure GetAdapterInfo(LanaNum:Byte);
Var
 NameBuffer:Array[0..1023]of Byte;
 NamePtr:^NAME_BUFFER;
 J:Integer;
 NameStr:String;
Begin
 FillChar(MyNCB,SizeOf(MyNCB),0);
 FillChar(AdapterStatus,SizeOf(AdapterStatus),0);
 FillChar(NameBuffer,SizeOf(NameBuffer),0);

 { PrÇparer le nom pour la requàte de statut }
 FillChar(MyNCB.CallName,16,' ');
 MyNCB.CallName[0]:='*';

 MyNCB.Command:=$33;         { NCBASTAT - Statut adaptateur }
 MyNCB.Buffer:=@AdapterStatus;
 MyNCB.Length:=SizeOf(AdapterStatus)+SizeOf(NameBuffer);
 MyNCB.Lana_Num:=LanaNum;

 If NetBIOSCall(MyNCB)=0 Then Begin
  WriteLn;
  WriteLn('=== Informations adaptateur LANA ',LanaNum,' ===');
  WriteLn('Adresse MAC : ',
          IntToHex(AdapterStatus.adapter_address[0],2),':',
          IntToHex(AdapterStatus.adapter_address[1],2),':',
          IntToHex(AdapterStatus.adapter_address[2],2),':',
          IntToHex(AdapterStatus.adapter_address[3],2),':',
          IntToHex(AdapterStatus.adapter_address[4],2),':',
          IntToHex(AdapterStatus.adapter_address[5],2));
  WriteLn('Version : ',AdapterStatus.rev_major,'.',AdapterStatus.rev_minor);
  WriteLn('Type d''adaptateur : ',AdapterStatus.adapter_type);
  WriteLn('Transmissions rÇussies : ',AdapterStatus.xmit_success);
  WriteLn('RÇceptions rÇussies : ',AdapterStatus.recv_success);
  WriteLn('NCBs libres : ',AdapterStatus.free_ncbs);
  WriteLn('NCBs maximum : ',AdapterStatus.max_ncbs);
  WriteLn('Sessions maximum : ',AdapterStatus.max_sess);
  WriteLn('Taille max. datagramme : ',AdapterStatus.max_dgram_size);
  WriteLn('Nombre de noms : ',AdapterStatus.name_count);

  { Afficher les noms NetBIOS enregistrÇs }
  If AdapterStatus.name_count>0 Then Begin
   WriteLn;
   WriteLn('Noms NetBIOS enregistrÇs :');
   NamePtr:=@NameBuffer[0];
   For J:=0 To AdapterStatus.name_count-1 Do Begin
    { Construire le nom en chaåne }
    NameStr:='';
    For I:=0 To 15 Do
     If NamePtr^.name[I]<>' ' Then NameStr:=NameStr+NamePtr^.name[I];
    If Length(NameStr)>0 Then
     WriteLn('  ',NameStr,' (Flags: $',IntToHex(NamePtr^.name_flags,2),')');
    Inc(NamePtr);
   End;
  End;
 End Else
  WriteLn('Erreur lors de la rÇcupÇration des informations de l''adaptateur LANA ',LanaNum);
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('NETBIOS : Affichage des informations NetBIOS');
  WriteLn;
  WriteLn('Syntaxe : NETBIOS');
  WriteLn;
  WriteLn('Cette commande affiche les informations sur les adaptateurs');
  WriteLn('NetBIOS installÇs, leurs adresses MAC, statistiques et noms');
  WriteLn('enregistrÇs.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (interruptions) et Free Pascal (API Windows)');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('NETBIOS 1.00 - Informations NetBIOS, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  WriteLn('Informations NetBIOS - NETWORKKIT-P');
  WriteLn;
  If Not IsNetBIOSInstalled Then Begin
   WriteLn('NetBIOS n''est pas installÇ sur ce systäme');
   Halt(1);
  End;
  WriteLn('NetBIOS dÇtectÇ - ênumÇration des adaptateurs...');
  WriteLn;
  EnumerateLANAs;
   { Obtenir les informations dÇtaillÇes pour chaque adaptateur }
  For I:=0 To LanaEnum.Length-1 Do GetAdapterInfo(LanaEnum.LANA[I]);
  WriteLn;
  WriteLn('Analyse terminÇe.');
 End;
END.
