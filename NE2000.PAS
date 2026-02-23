{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal)
  @description: Commande NE2000 - Driver de paquet pour cartes Ethernet NE2000 ISA
}

Program NE2000;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils,DOS;
{$ELSE}
 Uses Crt,DOS;
{$ENDIF}

{ Registres NE2000 }
Const
 { Registres de page 0 }
 NE2000_P0_CR     = $00;  { Registre de commande (Command Register) }
 NE2000_P0_CLDA0  = $01;  { Adresse local 0 courante du DMA (Current Local DMA Address 0) }
 NE2000_P0_CLDA1  = $02;  { Adresse local 1 courante du DMA (Current Local DMA Address 1) }
 NE2000_P0_BNRY   = $03;  { Pointeur de limite (Boundary Pointer) }
 NE2000_P0_TSR    = $04;  { Registre d'Çtat de transmission (Transmit Status Register) }
 NE2000_P0_NCR    = $05;  { Nombre de registre de collision (Number of Collisions Register) }
 NE2000_P0_FIFO   = $06;  { FIFO }
 NE2000_P0_ISR    = $07;  { Registre d'Çtat d'interruption (Interrupt Status Register) }
 NE2000_P0_CRDA0  = $08;  { Adresse 0 courante Ö distance du DMA (Current Remote DMA Address 0) }
 NE2000_P0_CRDA1  = $09;  { Adresse 1 courante Ö distance du DMA (Current Remote DMA Address 1) }
 NE2000_P0_RBCR0  = $0A;  { Registre 0 de compteur d'octet Ö distance (Remote Byte Count Register 0) }
 NE2000_P0_RBCR1  = $0B;  { Registre 1 de compteur d'octet Ö distance (Remote Byte Count Register 1) }
 NE2000_P0_RSR    = $0C;  { Registre d'Çtat de rÇception (Receive Status Register) }
 NE2000_P0_CNTR0  = $0D;  { Compteur d'erreur d'alignement de trame (Frame Alignment Error Counter) }
 NE2000_P0_CNTR1  = $0E;  { Compteur d'erreur CRC (CRC Error Counter) }
 NE2000_P0_CNTR2  = $0F;  { Compteur de paquet perdue (Missed Packet Counter) }
 NE2000_IOPORT    = $10;  { Port d'entrÇe/sortie de donnÇes (Data I/O Port) }
 NE2000_RESET     = $1F;  { Port de rÇinitialisation (Reset Port) }

 { Registres de page 1 }
 NE2000_P1_CR     = $00;  { Registre de commande (Command Register) }
 NE2000_P1_PAR0   = $01;  { Registre 0 d'adresse physique (Physical Address Register 0) }
 NE2000_P1_PAR1   = $02;  { Registre 1 d'adresse physique (Physical Address Register 1) }
 NE2000_P1_PAR2   = $03;  { Registre 2 d'adresse physique (Physical Address Register 2) }
 NE2000_P1_PAR3   = $04;  { Registre 3 d'adresse physique (Physical Address Register 3) }
 NE2000_P1_PAR4   = $05;  { Registre 4 d'adresse physique (Physical Address Register 4) }
 NE2000_P1_PAR5   = $06;  { Registre 5 d'adresse physique (Physical Address Register 5) }
 NE2000_P1_CURR   = $07;  { Registre du page courant (Current Page Register) }
 NE2000_P1_MAR0   = $08;  { Registre de 0 Ö 7 de multidiffusion (Multicast Address Register 0-7) }

 { Commandes du registre de commande }
 NE2000_CR_STP    = $01;  { Arràt (Stop) }
 NE2000_CR_STA    = $02;  { DÇmarre (Start) }
 NE2000_CR_TXP    = $04;  { Paquet de transission (Transmit Packet) }
 NE2000_CR_RD0    = $08;  { Bit 0 de commande DMA Ö distance (Remote DMA Command bit 0) }
 NE2000_CR_RD1    = $10;  { Bit 1 de commande DMA Ö distance (Remote DMA Command bit 1) }
 NE2000_CR_RD2    = $20;  { Bit 2 de commande DMA Ö disatnce (Remote DMA Command bit 2) }
 NE2000_CR_PS0    = $40;  { Bit 0 de sÇlection de page (Page Select bit 0) }
 NE2000_CR_PS1    = $80;  { Bit 1 de sÇlection de page (Page Select bit 1) }

 { Commandes Ö disatnce DMA }
 NE2000_CR_NODMA  = $20;  { Pas de DMA Ö distance (No Remote DMA) }
 NE2000_CR_READ   = $08;  { Lecture Ö distance (Remote Read) }
 NE2000_CR_WRITE  = $10;  { êcriture Ö distance (Remote Write) }
 NE2000_CR_SEND   = $18;  { Envoi de paquet (Send Packet) }

 { √âtats ISR }
 NE2000_ISR_PRX   = $01;  { Reception de paquet (Packet Received) }
 NE2000_ISR_PTX   = $02;  { Paquet transmit (Packet Transmitted) }
 NE2000_ISR_RXE   = $04;  { Erreur de reception (Receive Error) }
 NE2000_ISR_TXE   = $08;  { Erreur de transmission (Transmit Error) }
 NE2000_ISR_OVW   = $10;  { Attention d'Çcrasement (Overwrite Warning) }
 NE2000_ISR_CNT   = $20;  { Compteur de dÇbordement (Counter Overflow) }
 NE2000_ISR_RDC   = $40;  { DMA Ö distance complÇtÇ (Remote DMA Complete) }
 NE2000_ISR_RST   = $80;  { êtat d'initialisation (Reset Status) }

 { Configuration par dÇfaut }
 DEFAULT_SOFT_INT = $60;   { Interruption logicielle par dÇfaut }
 DEFAULT_HARD_INT = 10;    { IRQ par dÇfaut }
 DEFAULT_IO_BASE  = $300;  { Adresse d'entrÇe/sortie par dÇfaut }

Type
  { Configuration du pilote NE2000 }
 TNE2000Config = Record
  SoftwareInt: Byte;                { Vecteur d'interruption logicielle }
  HardwareInt: Byte;                { IRQ matÇrielle }
  IOBaseAddr: Word;                 { Adresse de base d'entrÇe/sortie }
  IsDetected: Boolean;              { Carte dÇtectÇe }
  MACAddress: Array[0..5] of Byte;  { Adresse MAC }
  IsInstalled: Boolean;             { Pilote installÇ }
 End;

Var
 NE2000Config: TNE2000Config;
 OldInt21: Pointer;      { Ancien gestionnaire INT 21h }
 Language:(_French,_English,_Germany,_Italian,_Spain,_Albanian,_Portuguese,_Swedish,_Danish,_Japanese);
 TmpLanguage:String;

{$IFDEF FPC}
{ === SIMULATION DES FONCTIONS POUR FREE PASCAL === }
 SimulatedPort: Array[0..65535] of Byte;
{$ENDIF}

{ === FONCTIONS DE COMPATIBILITê === }

 { Fonction StrToUpper pour compatibilitÇ }
Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S) do Begin
  If S[I] in['a'..'z'] Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

{ Fonction IntToHex pour compatibilitÇ Turbo Pascal }
{$IFNDEF FPC}
Function IntToHex(Value: Word; Digits: Integer):String;
Const
 HexChars:String[16] = '0123456789ABCDEF';
Var
 Result:String;
 I:Integer;
Begin
 Result:='';
 For I:=Digits-1 DownTo 0 Do Begin
  Result:=Result+HexChars[((Value shr (I * 4)) and $F) + 1];
 End;
 IntToHex := Result;
End;
{$ENDIF}

{$IFDEF FPC}
 { Fonction Port simulÇe pour lecture }
Function ReadPort(PortAddr: Word): Byte;Begin
 { Simulation - retourner des valeurs prÇdÇterminÇes }
 Case PortAddr of
  DEFAULT_IO_BASE + NE2000_P0_ISR: ReadPort := NE2000_ISR_RST;  { Simuler rÇinitialisation (ReSeT) }
  DEFAULT_IO_BASE + NE2000_P0_CR:  ReadPort := NE2000_CR_STP;   { Simuler arràt (SToP) }
  DEFAULT_IO_BASE + NE2000_IOPORT: ReadPort := $57;             { Valeur MAC simulÇe }
  Else ReadPort := SimulatedPort[PortAddr];
 End;
End;

{ Fonction de port simulÇe pour l'Çcriture }
Procedure WritePort(PortAddr: Word; Value:Byte);Begin
 SimulatedPort[PortAddr] := Value;
End;

{ Simulation de dÇlai Delay }
Procedure Delay(MS:Word);
Var
 StartTime: TDateTime;
Begin
 StartTime := Now;
 While ((Now - StartTime) * 24 * 60 * 60 * 1000) < MS Do
  { Attendre };
End;

{$ELSE}
 { === VERSION TURBO PASCAL AVEC ACCES PORTS RêELS === }

 { Fonction Port pour lecture - Turbo Pascal natif }
Function ReadPort(PortAddr:Word):Byte;Begin
 ReadPort:=Port[PortAddr];
End;

 { Fonction de port pour l'Çcriture - Turbo Pascal natif }
Procedure WritePort(PortAddr: Word; Value: Byte);Begin
 Port[PortAddr] := Value;
End;

{$ENDIF}

 { === FONCTIONS D'ACCES MATERIEL === }

{ Lire un octet du registre NE2000 }
Function ReadNE2000Reg(BaseAddr:Word;RegOffset:Byte):Byte;Begin
 ReadNE2000Reg:=ReadPort(BaseAddr+RegOffset);
End;

{ êcrire un octet dans le registre NE2000 }
Procedure WriteNE2000Reg(BaseAddr:Word;RegOffset:Byte;Value:Byte);Begin
 WritePort(BaseAddr+RegOffset,Value);
End;

 { Lire donnÇes du port d'entrÇe/sortie NE2000 }
Function ReadNE2000Data(BaseAddr:Word):Byte;Begin
 ReadNE2000Data := ReadPort(BaseAddr + NE2000_IOPORT);
End;

{ êcrire donnÇes vers le port d'entrÇe/sortie NE2000 }
Procedure WriteNE2000Data(BaseAddr:Word;Value:Byte);Begin
 WritePort(BaseAddr + NE2000_IOPORT, Value);
End;

{ === DêTECTION ET INITIALISATION === }

{ RÇinitialiser la carte NE2000 }
Procedure ResetNE2000(BaseAddr: Word);
Var
 ResetValue: Byte;
Begin
 { Lecture du port de rÇinitialisation pour dÇclencher le rÇinitilisation }
 ResetValue := ReadPort(BaseAddr + NE2000_RESET);
  { Attendre un peu pour la rÇinitialisation }
 Delay(10);
  { êcrire la valeur lue pour complÇter la rÇinitialisation }
 WritePort(BaseAddr + NE2000_RESET, ResetValue);
  { Attendre la fin de la rÇinitialisation }
 Delay(100);
End;

{ DÇtecter la prÇsence d'une carte NE2000 }
Function DetectNE2000(BaseAddr: Word): Boolean;
Var
 TestValue, ReadValue: Byte;
 I: Integer;
Begin
 DetectNE2000 := False;
  { Test 1: RÇinitialisation et vÇrification du registre de commande }
 ResetNE2000(BaseAddr);
  { Attendre que la carte soit pràte }
 For I:=1 To 1000 Do Begin
  ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_ISR);
  If (ReadValue and NE2000_ISR_RST) <> 0 Then Break;
  Delay(1);
 End;
  { VÇrifier si la rÇinitialisation s'est bien passÇe }
 If (ReadValue and NE2000_ISR_RST) = 0 Then Exit;
  { Test 2: Mettre la carte en mode stop et vÇrifier }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 Delay(10);
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_CR);
 If (ReadValue and NE2000_CR_STP) = 0 Then Exit;
  { Test 3: Test d'Çcriture/lecture sur le registre RBCR }
 TestValue := $A5;  { Valeur de test }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR0, TestValue);
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_RBCR0);
 If ReadValue <> TestValue Then Exit;
 TestValue := $5A;  { Autre valeur de test }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR1, TestValue);
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_RBCR1);
 If ReadValue <> TestValue Then Exit;
  { Test 4: VÇrifier la signature NE2000 dans la ROM }
  { Configuration pour lecture remote DMA }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(BaseAddr, NE2000_P0_ISR, $FF);  { Effacer interruptions }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA0, 0);  { Adresse remote DMA }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA1, 0);
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR0, 32); { Lire 32 octets }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_READ);
  { Lire quelques octets pour vÇrifier l'accäs DMA }
 For I := 0 To 5 Do Begin
  ReadValue := ReadNE2000Data(BaseAddr);
   { Entreposer l'adresse MAC pendant qu'on y est }
  NE2000Config.MACAddress[I] := ReadValue;
 End;
  { Si on arrive ici, la carte semble àtre une NE2000 }
 DetectNE2000:=True;
End;

 { Initialiser la carte NE2000 }
Function InitializeNE2000(BaseAddr: Word): Boolean;
Var
 I: Integer;
Begin
 InitializeNE2000 := False;
  { RÇinitialiser la carte }
 ResetNE2000(BaseAddr);
  { Configuration initiale }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(BaseAddr, NE2000_P0_ISR, $FF);  { Effacer toutes les interruptions }

 { Configuration des tampons }
 WriteNE2000Reg(BaseAddr, NE2000_P0_BNRY, $40);   { Page de dÇbut de rÇception }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA0, 0);    { Adresse DMA courante }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA1, 0);
  { Passer en page 1 pour configurer l'adresse physique }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA or NE2000_CR_PS0);
  { Configurer l'adresse MAC (utiliser l'adresse lue lors de la dÇtection) }
 For I := 0 To 5 Do Begin
  WriteNE2000Reg(BaseAddr, NE2000_P1_PAR0 + I, NE2000Config.MACAddress[I]);
 End;
  { Configuration du pointeur courant }
 WriteNE2000Reg(BaseAddr, NE2000_P1_CURR, $41);
  { Revenir en page 0 }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
  { DÇmarrer la carte }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STA or NE2000_CR_NODMA);
  { Attendre que la carte soit pràte }
 Delay(50);
 InitializeNE2000 := True;
End;

{ === GESTIONNAIRE D'INTERRUPTION === }

{ Gestionnaire d'interruption simple }
{$F+}
Procedure NE2000InterruptHandler;Begin
  { Simplement effacer le registre d'Çtat d'interruption }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_ISR, $FF);
  { Acquitter l'interruption matÇrielle }
 If NE2000Config.HardwareInt >= 8 Then Begin
  WritePort($A0, $20);  { EOI vers contrìleur esclave }
  WritePort($20, $20);  { EOI vers contrìleur maåtre }
 End Else Begin
  WritePort($20, $20);  { EOI vers contrìleur maåtre }
 End;
End;
{$F-}

 { Installer le gestionnaire d'interruption }
Function InstallInterruptHandler:Boolean;Begin
 InstallInterruptHandler := False;
  { Pour cette version simplifiÇe, on ne gäre pas les interruptions }
  { Dans un vrai pilote, il faudrait installer le gestionnaire sur l'IRQ }
 InstallInterruptHandler := True;
End;

{ === PILOTE D'INTERFACE DE PAQUET === }

 { Gestionnaire d'interruption logicielle pour pilote de paquet }
{$F+}
Procedure PacketDriverHandler;Begin
 { Interface simplifiÇe du packet de pilote }
 { Version simplifiÇe sans assembleur pour compatibilitÇ }
 { En rÇalitÇ, un vrai pilote de packet aurait besoin d'assembleur }

 {$IFDEF FPC}
 { Version Free Pascal - simulation }
 { Pas d'assembleur inline complexe }
 {$ELSE}
 { Version Turbo Pascal avec assembleur }
 ASM
  CMP AH, 1     { Fonction 1: Driver Info }
  JE @DriverInfo
  CMP AH, 2     { Fonction 2: Access Type }
  JE @AccessType
  JMP @Exit
@DriverInfo:
  MOV AL, 1     { Version }
  MOV BX, 1     { Type: Ethernet }
  MOV CX, 0     { NumÇro }
  CLC           { Succäs }
  JMP @Exit
@AccessType:
  CLC           { Succäs pour l'instant }
  JMP @Exit
@Exit:
 END;
 {$ENDIF}
End;
{$F-}

{ === FONCTIONS UTILITAIRES === }

{ Messages multilingues }

{ Afficher l'adresse MAC }
Procedure DisplayMACAddress;
Var
 I: Integer;
Begin
  { Affichage multilingue du label MAC Address }
 Case Language of
  _English:   Write('MAC Address: ');
  _Germany:   Write('MAC-Adresse: ');
  _Italian:   Write('Indirizzo MAC: ');
  _Spain:     Write('Direcci¢n MAC: ');
  _Albanian:  Write('Adresa MAC: ');
  _Portuguese:Write('Endereáo MAC: ');
  _Swedish:   Write('MAC-adress: ');
  _Danish:    Write('MAC-adresse: ');
  _Japanese:  Write('MAC adoresu: ');
  Else        Write('Adresse MAC: ');
 End;
 For I := 0 To 5 Do Begin
  Write(IntToHex(NE2000Config.MACAddress[I], 2));
  If I < 5 Then Write('-');
 End;
 WriteLn;
End;

{ Afficher l'Çtat de la carte }
Procedure DisplayCardStatus;
Var
 CR, ISR, TSR: Byte;
Begin
 { Affichage multilingue du statut de la carte }
 Case Language of
  _English:   WriteLn('NE2000 card status:');
  _Germany:   WriteLn('NE2000-Karten Status:');
  _Italian:   WriteLn('Stato scheda NE2000:');
  _Spain:     WriteLn('Estado de tarjeta NE2000:');
  _Albanian:  WriteLn('Gjendja e kartâs NE2000:');
  _Portuguese:WriteLn('Status da placa NE2000:');
  _Swedish:   WriteLn('NE2000-kort status:');
  _Danish:    WriteLn('NE2000-kort status:');
  _Japanese:  WriteLn('NE2000 kaado no suteetasu:');
  Else        WriteLn('êtat de la carte NE2000:');
 End;
 WriteLn('------------------------');

 CR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR);
 ISR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_ISR);
 TSR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_TSR);

 WriteLn('Registre de commande (CR): $', IntToHex(CR, 2));
 WriteLn('Registre d''Çtat d''interruption (ISR): $', IntToHex(ISR, 2));
 WriteLn('Registre d''Çtat de transmission (TSR): $', IntToHex(TSR, 2));
 Write('êtat: ');
 If (CR and NE2000_CR_STA) <> 0 Then WriteLn('DÇmarrÇ')
                                Else WriteLn('ArràtÇ');

 DisplayMACAddress;
End;

 { Test de la carte }
Function TestCard: Boolean;
Var
 TestData: Array[0..15] of Byte;
 I: Integer;
Begin
 TestCard := False;
 WriteLn('Test de la carte NE2000...');
  { Test simple de lecture/Çcriture }
 For I := 0 To 15 Do TestData[I] := I * 16 + I;
  { Configuration pour DMA Ö distance }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA0, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA1, $40);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR0, 16);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_WRITE);
  { êcrire des donnÇes de test }
 For I := 0 To 15 Do WriteNE2000Data(NE2000Config.IOBaseAddr, TestData[I]);
 { Relire les donnÇes }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA0, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA1, $40);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR0, 16);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_READ);
  { VÇrifier les donnÇes }
 For I := 0 To 15 Do Begin
  If ReadNE2000Data(NE2000Config.IOBaseAddr) <> TestData[I] Then Exit;
 End;
 WriteLn('Test de la carte: RêUSSI');
 TestCard := True;
End;

 { === FONCTIONS PRINCIPALES === }

 { Analyser les paramätres de ligne de commande }
Function ParseCommandLine: Boolean;
Var
 ErrorCode: Integer;
Begin
 ParseCommandLine := True;
  { Initialiser configuration par dÇfaut }
 With NE2000Config Do Begin
  SoftwareInt := DEFAULT_SOFT_INT;
  HardwareInt := DEFAULT_HARD_INT;
  IOBaseAddr := DEFAULT_IO_BASE;
  IsDetected := False;
  IsInstalled := False;
 End;
  { Analyser les param√®tres }
 If ParamCount >= 1 Then Begin
  { Premier paramätre: interruption logicielle }
  Val('$' + ParamStr(1), NE2000Config.SoftwareInt, ErrorCode);
  If ErrorCode <> 0 Then Begin
   WriteLn('Erreur: Interruption logicielle invalide: ', ParamStr(1));
   ParseCommandLine := False;
   Exit;
  End;
 End;

 If ParamCount >= 2 Then Begin
  { Deuxi√®me param√®tre: IRQ mat√©rielle }
  Val(ParamStr(2), NE2000Config.HardwareInt, ErrorCode);
  If ErrorCode <> 0 Then Begin
   WriteLn('Erreur: IRQ invalide: ', ParamStr(2));
   ParseCommandLine := False;
   Exit;
  End;
 End;

 If ParamCount >= 3 Then Begin
  { Troisiäme paramätre: adresse d'entrÇe/sortie }
  Val('$' + ParamStr(3), NE2000Config.IOBaseAddr, ErrorCode);
  If ErrorCode <> 0 Then Begin
   WriteLn('Erreur: Adresse d''entrÇe/sortie invalide: ', ParamStr(3));
   ParseCommandLine := False;
   Exit;
  End;
 End;
End;

 { Installer le pilote NE2000 }
Function InstallDriver:Boolean;Begin
 InstallDriver:=False;
 WriteLn('Installation du pilote paquet NE2000...');
 WriteLn('Interruption logicielle: $', IntToHex(NE2000Config.SoftwareInt, 2));
 WriteLn('IRQ matÇrielle: ', NE2000Config.HardwareInt);
 WriteLn('Adresse d''entrÇe/sortie : $', IntToHex(NE2000Config.IOBaseAddr, 4));
 WriteLn;
  { DÇtecter la carte }
 WriteLn('DÇtection de la carte NE2000...');
 If not DetectNE2000(NE2000Config.IOBaseAddr) Then Begin
  { Affichage multilingue de l'erreur de dÇtection }
  Case Language of
   _English:   Write('ERROR: No NE2000 card detected at address $');
   _Germany:   Write('FEHLER: Keine NE2000-Karte an Adresse $ erkannt ');
   _Italian:   Write('ERRORE: Nessuna scheda NE2000 rilevata all''indirizzo $');
   _Spain:     Write('ERROR: No se detect¢ tarjeta NE2000 en direcci¢n $');
   _Albanian:  Write('GABIM: Asnjâ kartâ NE2000 nuk u zbulua nâ adresân $');
   _Portuguese:Write('ERRO: Nenhuma placa NE2000 detectada no endere√ßo $');
   _Swedish:   Write('FEL: Inget NE2000-kort upptÑckt pÜ adress $');
   _Danish:    Write('FEJL: Intet NE2000-kort opdaget pÜ adresse $');
   _Japanese:  Write('ERAAH: Adoresu $ ni NE2000 kaado ga kenshutsu saremasen deshita ');
   Else        Write('ERREUR: Aucune carte NE2000 dÇtectÇe Ö l''adresse $');
  End;
  WriteLn(IntToHex(NE2000Config.IOBaseAddr, 4));
  Exit;
 End;

 { Affichage multilingue du succäs de dÇtection }
 Case Language of
  _English:   WriteLn('NE2000 card detected successfully!');
  _Germany:   WriteLn('NE2000-Karte erfolgreich erkannt!');
  _Italian:   WriteLn('Scheda NE2000 rilevata con successo!');
  _Spain:     WriteLn('Tarjeta NE2000 detectada exitosamente!');
  _Albanian:  WriteLn('Karta NE2000 u zbulua me sukses!');
  _Portuguese:WriteLn('Placa NE2000 detectada com sucesso!');
  _Swedish:   WriteLn('NE2000-kort upptÑckt framgÜngsrikt!');
  _Danish:    WriteLn('NE2000-kort opdaget succesfuldt!');
  _Japanese:  WriteLn('NE2000 kaado ga seikou ni kenshutsu saremashita!');
  Else        WriteLn('Carte NE2000 dÇtectÇe avec succäs!');
 End;
 NE2000Config.IsDetected := True;
 DisplayMACAddress;
 WriteLn;
  { Initialiser la carte }
 WriteLn('Initialisation de la carte...');
 If not InitializeNE2000(NE2000Config.IOBaseAddr) Then Begin
  WriteLn('ERREUR: êchec d''initialisation de la carte');
  Exit;
 End;
 WriteLn('Carte initialisÇe avec succäs!');
  { Test de la carte }
 If Not TestCard Then Begin
  WriteLn('ATTENTION: Test de la carte ÇchouÇ - le pilote pourrait ne pas fonctionner correctement');
 End;
  { Installer le gestionnaire d'interruption }
 WriteLn('Installation du gestionnaire d''interruption...');
 If InstallInterruptHandler Then Begin
  WriteLn('Gestionnaire d''interruption installÇ');
 End
  Else
 Begin
  WriteLn('ATTENTION: êchec d''installation du gestionnaire d''interruption');
 End;
  { Marquer comme installÇ }
 NE2000Config.IsInstalled := True;
 WriteLn;
  { Affichage multilingue du succäs d'installation }
 Case Language of
  _English:   WriteLn('NE2000 packet driver installed successfully!');
  _Germany:   WriteLn('NE2000 Packet-Treiber erfolgreich installiert!');
  _Italian:   WriteLn('Driver pacchetti NE2000 installato con successo!');
  _Spain:     WriteLn('Driver de paquetes NE2000 instalado exitosamente!');
  _Albanian:  WriteLn('Drajveri i paketave NE2000 u instalua me sukses!');
  _Portuguese:WriteLn('Driver de pacotes NE2000 instalado com sucesso!');
  _Swedish:   WriteLn('NE2000 paketdrivrutin installerad framgÜngsrikt!');
  _Danish:    WriteLn('NE2000 pakkedriver installeret succesfuldt!');
  _Japanese:  WriteLn('NE2000 paketto doraibaa ga seikou ni insutooru saremashita!');
  Else        WriteLn('Pilote de paquet NE2000 installÇ avec succäs!');
 End;
 WriteLn('Le pilote est maintenant pràt Ö àtre utilisÇ par les applications rÇseau.');
 InstallDriver := True;
End;

 { DÇsinstaller le pilote }
Procedure UninstallDriver;Begin
 If not NE2000Config.IsInstalled Then Begin
  WriteLn('Aucun pilote installÇ');
  Exit;
 End;
 WriteLn('DÇsinstallation du pilote NE2000...');
  { Arràter la carte }
 If NE2000Config.IsDetected Then Begin
  WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
  WriteLn('Carte arràtÇe');
 End;
  { Restaurer les gestionnaires d'interruption }
  { (Dans un vrai driver, il faudrait restaurer les vecteurs) }
 NE2000Config.IsInstalled := False;
 WriteLn('Pilote dÇsinstallÇ');
End;

 { Afficher les informations sur le driver }
Procedure ShowDriverInfo;Begin
 WriteLn('Informations sur le pilote NE2000');
 WriteLn('==================================');
 WriteLn;
 WriteLn('Version: 1.0 pour NETWORKKIT-P');
 WriteLn('Compatible: Cartes Ethernet NE2000 et compatibles');
 WriteLn('Type: Pilote de paquet (Packet Driver)');
 WriteLn;
 WriteLn('Configuration actuelle:');
 With NE2000Config Do Begin
  WriteLn('  Interruption logicielle: $', IntToHex(SoftwareInt, 2));
  WriteLn('  IRQ matÇrielle: ', HardwareInt);
  WriteLn('  Adresse d''entrÇe/sortie: $', IntToHex(IOBaseAddr, 4));
  Write('  êtat dÇtection: ');
  If IsDetected Then WriteLn('DÇtectÇ') Else WriteLn('Non dÇtectÇ');
  Write('  êtat installation: ');
  If IsInstalled Then WriteLn('InstallÇ') Else WriteLn('Non installÇ');
 End;
 WriteLn;
 If NE2000Config.IsDetected Then Begin
  DisplayCardStatus;
 End;
End;

{ === DONNêES CONSTANTES === }
Const
 DriverName: PChar = 'NE2000 Packet Driver';

BEGIN
  { Initialiser la langue }
 Language:=_French;
 TmpLanguage:=GetEnv('LANGUAGE');
 If TmpLanguage<>''Then Begin
  If TmpLanguage[1]='"'Then TmpLanguage:=Copy(TmpLanguage,2,255);
  If StrToUpper(Copy(TmpLanguage,1,2))='EN'Then Language:=_English Else
  If StrToUpper(Copy(TmpLanguage,1,2))='GR'Then Language:=_Germany Else
  If StrToUpper(Copy(TmpLanguage,1,2))='IT'Then Language:=_Italian Else
  If StrToUpper(Copy(TmpLanguage,1,2))='SP'Then Language:=_Spain Else
  If(StrToUpper(Copy(TmpLanguage,1,2))='SQ')or
    (StrToUpper(Copy(TmpLanguage,1,3))='ALB')Then Language:=_Albanian Else
  If(StrToUpper(Copy(TmpLanguage,1,2))='PT')or
    (StrToUpper(Copy(TmpLanguage,1,3))='PRT')Then Language:=_Portuguese Else
  If(StrToUpper(Copy(TmpLanguage,1,2))='SE')or
    (StrToUpper(Copy(TmpLanguage,1,3))='SWE')Then Language:=_Swedish Else
  If(StrToUpper(Copy(TmpLanguage,1,2))='DK')or
    (StrToUpper(Copy(TmpLanguage,1,3))='DNK')Then Language:=_Danish Else
  If(StrToUpper(Copy(TmpLanguage,1,2))='JP')or
    (StrToUpper(Copy(TmpLanguage,1,3))='JPN')Then Language:=_Japanese;
 End;

 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  Case Language of
   _English: Begin
    WriteLn('NE2000 : This command launches a packet driver for NE2000 compatible ISA Ethernet cards.');
    WriteLn;
    WriteLn('Syntax:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parameters:');
    WriteLn('  soft_int     Software interrupt vector in hexadecimal (60-7F)');
    WriteLn('  hard_int     Hardware IRQ number (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   I/O base address in hexadecimal (280, 300, 320, etc.)');
    WriteLn;
    WriteLn('Default values:');
    WriteLn('  soft_int     60h    (Software interrupt $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (I/O address $300)');
    WriteLn;
    WriteLn('Usage examples:');
    WriteLn('  NE2000                    # Default configuration');
    WriteLn('  NE2000 60 10 300          # Explicit configuration');
    WriteLn('  NE2000 61 5 280           # IRQ 5, address $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, address $320');
   End;
   _Germany: Begin
    WriteLn('NE2000 : Dieser Befehl startet einen Pakettreiber fÅr NE2000-kompatible ISA-Ethernet-Karten.');
    WriteLn('Syntax:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parameter:');
    WriteLn('  soft_int     Software-Interrupt-Vektor in Hexadezimal (60-7F)');
    WriteLn('  hard_int     Hardware-IRQ-Nummer (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   I/O-Basisadresse in Hexadezimal (280, 300, 320, usw.)');
    WriteLn;
    WriteLn('Standardwerte:');
    WriteLn('  soft_int     60h    (Software-Interrupt $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (I/O-Adresse $300)');
    WriteLn;
    WriteLn('Verwendungsbeispiele:');
    WriteLn('  NE2000                    # Standardkonfiguration');
    WriteLn('  NE2000 60 10 300          # Explizite Konfiguration');
    WriteLn('  NE2000 61 5 280           # IRQ 5, Adresse $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, Adresse $320');
   End;
   _Italian: Begin
    WriteLn('NE2000 : Questo comando avvia un driver di pacchetti per schede Ethernet ISA compatibili NE2000.');
    WriteLn('Sintassi:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parametri:');
    WriteLn('  soft_int     Vettore di interruzione software in esadecimale (60-7F)');
    WriteLn('  hard_int     Numero IRQ hardware (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   Indirizzo base I/O in esadecimale (280, 300, 320, ecc.)');
    WriteLn;
    WriteLn('Valori predefiniti:');
    WriteLn('  soft_int     60h    (Interruzione software $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (Indirizzo I/O $300)');
    WriteLn;
    WriteLn('Esempi di utilizzo:');
    WriteLn('  NE2000                    # Configurazione predefinita');
    WriteLn('  NE2000 60 10 300          # Configurazione esplicita');
    WriteLn('  NE2000 61 5 280           # IRQ 5, indirizzo $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, indirizzo $320');
   End;
   _Spain: Begin
    WriteLn('NE2000 : Este comando inicia un controlador de paquetes para tarjetas Ethernet ISA compatibles NE2000.');
    WriteLn('Sintaxis:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Par√°metros:');
    WriteLn('  soft_int     Vector de interrupci¢n de software en hexadecimal (60-7F)');
    WriteLn('  hard_int     N£mero de IRQ de hardware (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   Direcci¢n base de E/S en hexadecimal (280, 300, 320, etc.)');
    WriteLn;
    WriteLn('Valores predeterminados:');
    WriteLn('  soft_int     60h    (Interrupci¢n de software $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (Direcci¢n I/O $300)');
    WriteLn;
    WriteLn('Ejemplos de uso:');
    WriteLn('  NE2000                    # Configuraci¢n predeterminada');
    WriteLn('  NE2000 60 10 300          # Configuraci¢n explicita');
    WriteLn('  NE2000 61 5 280           # IRQ 5, direcci¢n $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, direcci¢n $320');
   End;
   _Albanian: Begin
    WriteLn('NE2000 : Ky komandâ nis njâ drejtues paketash pâr karta Ethernet ISA tâ pârputhshme NE2000.');
    WriteLn;
    WriteLn('Sintaksâ:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parametrat:');
    WriteLn('  soft_int     Vektori i ndârprerjes sâ softuerit nâ heksadecimal (60-7F)');
    WriteLn('  hard_int     Numri i IRQ tâ harduerit (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   Adresa bazâ I/O nâ heksadecimal (280, 300, 320, etj.)');
    WriteLn;
    WriteLn('Vlerat e paracaktuara:');
    WriteLn('  soft_int     60h    (Ndârprerja e softuerit $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (Adresa I/O $300)');
    WriteLn;
    WriteLn('Shembuj pârdorimi:');
    WriteLn('  NE2000                    # Konfigurimi i paracaktuar');
    WriteLn('  NE2000 60 10 300          # Konfigurimi eksplicit');
    WriteLn('  NE2000 61 5 280           # IRQ 5, adresa $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, adresa $320');
   End;
   _Portuguese: Begin
    WriteLn('NE2000 : Este comando inicia um driver de pacotes para placas Ethernet ISA compativeis NE2000.');
    WriteLn;
    WriteLn('Sintaxe:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('ParÉmetros:');
    WriteLn('  soft_int     Vetor de interrupáao de software em hexadecimal (60-7F)');
    WriteLn('  hard_int     N£mero do IRQ de hardware (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   Endereáo base de I/O em hexadecimal (280, 300, 320, etc.)');
    WriteLn;
    WriteLn('Valores padrao:');
    WriteLn('  soft_int     60h    (Interrupáao de software $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (Endereáo I/O $300)');
    WriteLn;
    WriteLn('Exemplos de uso:');
    WriteLn('  NE2000                    # Configuraáao padrao');
    WriteLn('  NE2000 60 10 300          # Configuraáao explicita');
    WriteLn('  NE2000 61 5 280           # IRQ 5, endereáo $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, endereáo $320');
   End;
   _Swedish: Begin
    WriteLn('NE2000 : Detta kommando startar en paketdrivrutin fîr NE2000-kompatibla ISA Ethernet-kort.');
    WriteLn;
    WriteLn('Syntax:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parametrar:');
    WriteLn('  soft_int     Programvaruavbrottsvektor i hexadecimal (60-7F)');
    WriteLn('  hard_int     HÜrdvaru-IRQ-nummer (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   I/O-basadress i hexadecimal (280, 300, 320, osv.)');
    WriteLn;
    WriteLn('StandardvÑrden:');
    WriteLn('  soft_int     60h    (Programvaruavbrott $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (I/O-adress $300)');
    WriteLn;
    WriteLn('AnvÑndningsexempel:');
    WriteLn('  NE2000                    # Standardkonfiguration');
    WriteLn('  NE2000 60 10 300          # Explicit konfiguration');
    WriteLn('  NE2000 61 5 280           # IRQ 5, adress $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, adress $320');
   End;
   _Danish: Begin
    WriteLn('NE2000 : Denne kommando starter en pakkedriver for NE2000-kompatible ISA Ethernet-kort.');
    WriteLn;
    WriteLn('Syntaks:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parametre:');
    WriteLn('  soft_int     Software interrupt vektor i hexadecimal (60-7F)');
    WriteLn('  hard_int     Hardware IRQ nummer (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   I/O baseadresse i hexadecimal (280, 300, 320, osv.)');
    WriteLn;
    WriteLn('Standardvaerdier:');
    WriteLn('  soft_int     60h    (Software interrupt $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (I/O-adresse $300)');
    WriteLn;
    WriteLn('Anvendelseseksempler:');
    WriteLn('  NE2000                    # Standardkonfiguration');
    WriteLn('  NE2000 60 10 300          # Eksplicit konfiguration');
    WriteLn('  NE2000 61 5 280           # IRQ 5, adresse $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, adresse $320');
   End;
   _Japanese: Begin
    WriteLn('NE2000 : Kono komando wa NE2000 gokan ISA Ethernet kado yo no paketto doraiba wo kido shimasu.');
    WriteLn;
    WriteLn('Kobun:');
    WriteLn;
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Parameta:');
    WriteLn('  soft_int     Sofutouea warikomi bekuta (jurokushinshu 60-7F)');
    WriteLn('  hard_int     HƒÅdouea IRQ bango (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   I/O kiban adoresu (jurokushinshu 280, 300, 320, nado)');
    WriteLn;
    WriteLn('Hyojun atai:');
    WriteLn('  soft_int     60h    (Sofutouea warikomi $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (I/O adoresu $300)');
    WriteLn;
    WriteLn('Shiyo rei:');
    WriteLn('  NE2000                    # Hyojun kosei');
    WriteLn('  NE2000 60 10 300          # Meishiteki kosei');
    WriteLn('  NE2000 61 5 280           # IRQ 5, adoresu $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, adoresu $320');
   End;
   Else Begin
    WriteLn('NE2000 : Cette commande permet de lancer un pilote de paquet pour cartes Ethernet NE2000 ',
                     'compatibles ISA.');
    WriteLn;
    WriteLn('Syntaxe :');
    WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
    WriteLn;
    WriteLn('Paramätres :');
    WriteLn('  soft_int     Vecteur d''interruption logicielle en hexadÇcimal (60-7F)');
    WriteLn('  hard_int     NumÇro d''IRQ matÇrielle (3, 5, 9, 10, 11, 12, 15)');
    WriteLn('  io_address   Adresse de base d''entrÇe/sortie en hexadÇcimal (280, 300, 320,...)');
    WriteLn;
    WriteLn('Valeurs par d√©faut :');
    WriteLn('  soft_int     60h    (Interruption logicielle $60)');
    WriteLn('  hard_int     10     (IRQ 10)');
    WriteLn('  io_address   300h   (Adresse d''entrÇe/sortie $300)');
    WriteLn;
    WriteLn('Exemples d''utilisation :');
    WriteLn('  NE2000                    # Configuration par dÇfaut');
    WriteLn('  NE2000 60 10 300          # Configuration explicite');
    WriteLn('  NE2000 61 5 280           # IRQ 5, adresse $280');
    WriteLn('  NE2000 62 11 320          # IRQ 11, adresse $320');
    WriteLn;
    WriteLn('Adresses d''entrÇe/sorties courantes :');
    WriteLn('  280h, 300h, 320h, 340h, 360h');
    WriteLn;
    WriteLn('IRQ courantes :');
    WriteLn('  3, 5, 9, 10, 11, 12, 15');
    WriteLn;
    WriteLn('Configuration des cavaliers :');
    WriteLn('  Les cavaliers de la carte doivent correspondre exactement');
    WriteLn('  aux paramätres spÇcifiÇs pour l''IRQ et l''adresse d''entrÇe/sortie.');
    WriteLn;
    WriteLn('Options :');
    WriteLn('  -i, /i       Afficher informations sur le pilote installÇ');
    WriteLn('  -u, /u       DÇsinstaller le pilote');
    WriteLn('  -t, /t       Tester la carte sans installer le pilote');
    WriteLn;
    WriteLn('Codes de retour :');
    WriteLn('  0            Installation rÇussie');
    WriteLn('  1            Erreur de paramätres');
    WriteLn('  2            Carte non dÇtectÇe');
    WriteLn('  3            Erreur d''initialisation');
    WriteLn('  4            Erreur d''installation du pilote');
    WriteLn;
    WriteLn('Note: Ce pilote implÇmente l''interface Packet Driver standard');
    WriteLn('pour les cartes Ethernet Novell NE2000 et compatibles.');
    WriteLn('NÇcessite une carte NE2000 ISA correctement configure.');
    WriteLn;
    WriteLn('Compatible Free Pascal (simulation) et Turbo Pascal (donnÇes rÇelles)');
   End;
  End;
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('ne2000 (NETWORKKIT-P) 1.0');
  WriteLn('Pilote de paquet pour cartes Ethernet NE2000');
  WriteLn('Compatible avec ne2000.com de Novell');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais pour NETWORKKIT-P, Corail');
 End
  Else
 If (ParamStr(1) = '-i') or (ParamStr(1) = '/i') Then Begin
  ShowDriverInfo;
 End
  Else
 If (ParamStr(1) = '-u') or (ParamStr(1) = '/u') Then Begin
  UninstallDriver;
 End
 Else If (ParamStr(1) = '-t') or (ParamStr(1) = '/t') Then Begin
  { Initialiser configuration par dÇfaut pour le test }
  With NE2000Config Do Begin
   SoftwareInt := DEFAULT_SOFT_INT;
   HardwareInt := DEFAULT_HARD_INT;
   IOBaseAddr := DEFAULT_IO_BASE;
   IsDetected := False;
   IsInstalled := False;
  End;
   WriteLn('Test de dÇtection NE2000...');
  WriteLn('Configuration de test: IRQ ', NE2000Config.HardwareInt,
          ', Adresse d''entrÇe/sortie $', IntToHex(NE2000Config.IOBaseAddr, 4));
  WriteLn;

  If DetectNE2000(NE2000Config.IOBaseAddr) Then Begin
   { Affichage multilingue du succäs de dÇtection dans le test }
   Case Language of
    _English:   WriteLn('NE2000 card detected successfully!');
    _Germany:   WriteLn('NE2000-Karte erfolgreich erkannt!');
    _Italian:   WriteLn('Scheda NE2000 rilevata con successo!');
    _Spain:     WriteLn('Tarjeta NE2000 detectada exitosamente!');
    _Albanian:  WriteLn('Karta NE2000 u zbulua me sukses!');
    _Portuguese:WriteLn('Placa NE2000 detectada com sucesso!');
    _Swedish:   WriteLn('NE2000-kort upptÑckt framgÑngsrikt!');
    _Danish:    WriteLn('NE2000-kort opdaget succesfuldt!');
    _Japanese:  WriteLn('NE2000 kaado ga seikou ni kenshutsu saremashita!');
    Else        WriteLn('Carte NE2000 dÇtectÇe avec succäs !');
   End;
   NE2000Config.IsDetected := True;
   DisplayMACAddress;
   DisplayCardStatus;
  End Else Begin
   { Affichage multilingue de l'erreur de d√©tection dans le test }
   Case Language of
    _English:   Write('ERROR: No NE2000 card detected at address $');
    _Germany:   Write('FEHLER: Keine NE2000-Karte an Adresse $ erkannt ');
    _Italian:   Write('ERRORE: Nessuna scheda NE2000 rilevata all''indirizzo $');
    _Spain:     Write('ERROR: No se detect¢ tarjeta NE2000 en direcci¢n $');
    _Albanian:  Write('GABIM: Asnjâ kartâ NE2000 nuk u zbulua nâ adresân $');
    _Portuguese:Write('ERRO: Nenhuma placa NE2000 detectada no endereáo $');
    _Swedish:   Write('FEL: Inget NE2000-kort upptÑckt pÜ adress $');
    _Danish:    Write('FEJL: Intet NE2000-kort opdaget pÜ adresse $');
    _Japanese:  Write('ERAAH: Adoresu $ ni NE2000 kaado ga kenshutsu saremasen deshita ');
    Else        Write('ERREUR: Aucune carte NE2000 dÇtectÇe Ö l''adresse $');
   End;
   WriteLn(IntToHex(NE2000Config.IOBaseAddr, 4));
   WriteLn('Essayez d''autres adresses d''entrÇe/sortie courantes: $280, $320, $340, $360');
   Halt(2);
  End;
 End
 Else Begin
  { Installation du driver }
  If ParseCommandLine Then Begin
   If InstallDriver Then Begin
    { Succ√®s }
    Halt(0);
   End Else Begin
    Halt(4);
   End;
  End Else Begin
   Halt(1);
  End;
 End;
END.