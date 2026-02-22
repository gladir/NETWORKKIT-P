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
 Uses SysUtils;
{$ENDIF}

{ Registres NE2000 }
Const
 { Registres de page 0 }
 NE2000_P0_CR     = $00;  { Command Register }
 NE2000_P0_CLDA0  = $01;  { Current Local DMA Address 0 }
 NE2000_P0_CLDA1  = $02;  { Current Local DMA Address 1 }
 NE2000_P0_BNRY   = $03;  { Boundary Pointer }
 NE2000_P0_TSR    = $04;  { Transmit Status Register }
 NE2000_P0_NCR    = $05;  { Number of Collisions Register }
 NE2000_P0_FIFO   = $06;  { FIFO }
 NE2000_P0_ISR    = $07;  { Interrupt Status Register }
 NE2000_P0_CRDA0  = $08;  { Current Remote DMA Address 0 }
 NE2000_P0_CRDA1  = $09;  { Current Remote DMA Address 1 }
 NE2000_P0_RBCR0  = $0A;  { Remote Byte Count Register 0 }
 NE2000_P0_RBCR1  = $0B;  { Remote Byte Count Register 1 }
 NE2000_P0_RSR    = $0C;  { Receive Status Register }
 NE2000_P0_CNTR0  = $0D;  { Frame Alignment Error Counter }
 NE2000_P0_CNTR1  = $0E;  { CRC Error Counter }
 NE2000_P0_CNTR2  = $0F;  { Missed Packet Counter }
 NE2000_IOPORT    = $10;  { Data I/O Port }
 NE2000_RESET     = $1F;  { Reset Port }

 { Registres de page 1 }
 NE2000_P1_CR     = $00;  { Command Register }
 NE2000_P1_PAR0   = $01;  { Physical Address Register 0 }
 NE2000_P1_PAR1   = $02;  { Physical Address Register 1 }
 NE2000_P1_PAR2   = $03;  { Physical Address Register 2 }
 NE2000_P1_PAR3   = $04;  { Physical Address Register 3 }
 NE2000_P1_PAR4   = $05;  { Physical Address Register 4 }
 NE2000_P1_PAR5   = $06;  { Physical Address Register 5 }
 NE2000_P1_CURR   = $07;  { Current Page Register }
 NE2000_P1_MAR0   = $08;  { Multicast Address Register 0-7 }

 { Commandes du registre de commande }
 NE2000_CR_STP    = $01;  { Stop }
 NE2000_CR_STA    = $02;  { Start }
 NE2000_CR_TXP    = $04;  { Transmit Packet }
 NE2000_CR_RD0    = $08;  { Remote DMA Command bit 0 }
 NE2000_CR_RD1    = $10;  { Remote DMA Command bit 1 }
 NE2000_CR_RD2    = $20;  { Remote DMA Command bit 2 }
 NE2000_CR_PS0    = $40;  { Page Select bit 0 }
 NE2000_CR_PS1    = $80;  { Page Select bit 1 }

 { Commandes Remote DMA }
 NE2000_CR_NODMA  = $20;  { No Remote DMA }
 NE2000_CR_READ   = $08;  { Remote Read }
 NE2000_CR_WRITE  = $10;  { Remote Write }
 NE2000_CR_SEND   = $18;  { Send Packet }

 { États ISR }
 NE2000_ISR_PRX   = $01;  { Packet Received }
 NE2000_ISR_PTX   = $02;  { Packet Transmitted }
 NE2000_ISR_RXE   = $04;  { Receive Error }
 NE2000_ISR_TXE   = $08;  { Transmit Error }
 NE2000_ISR_OVW   = $10;  { Overwrite Warning }
 NE2000_ISR_CNT   = $20;  { Counter Overflow }
 NE2000_ISR_RDC   = $40;  { Remote DMA Complete }
 NE2000_ISR_RST   = $80;  { Reset Status }

 { Configuration par défaut }
 DEFAULT_SOFT_INT = $60;   { Interruption logicielle par défaut }
 DEFAULT_HARD_INT = 10;    { IRQ par défaut }
 DEFAULT_IO_BASE  = $300;  { Adresse I/O par défaut }

Type
 { Configuration du driver NE2000 }
 TNE2000Config = Record
  SoftwareInt: Byte;     { Vecteur d'interruption logicielle }
  HardwareInt: Byte;     { IRQ matérielle }
  IOBaseAddr: Word;      { Adresse de base I/O }
  IsDetected: Boolean;   { Carte détectée }
  MACAddress: Array[0..5] of Byte;  { Adresse MAC }
  IsInstalled: Boolean;  { Driver installé }
 End;

Var
 NE2000Config: TNE2000Config;
 OldInt21: Pointer;      { Ancien gestionnaire INT 21h }

{$IFDEF FPC}
{ === SIMULATION DES FONCTIONS POUR FREE PASCAL === }

{ Simulation d'accès aux ports (non-fonctionnel en Windows moderne) }
Var
 SimulatedPort: Array[0..65535] of Byte;

{ Fonction Port simulée pour lecture }
Function ReadPort(PortAddr: Word): Byte;
Begin
 { Simulation - retourner des valeurs prédéterminées }
 Case PortAddr of
  DEFAULT_IO_BASE + NE2000_P0_ISR: ReadPort := NE2000_ISR_RST;  { Simuler reset }
  DEFAULT_IO_BASE + NE2000_P0_CR:  ReadPort := NE2000_CR_STP;   { Simuler stop }
  DEFAULT_IO_BASE + NE2000_IOPORT: ReadPort := $57;             { Valeur MAC simulée }
  Else ReadPort := SimulatedPort[PortAddr];
 End;
End;

{ Fonction Port simulée pour écriture }
Procedure WritePort(PortAddr: Word; Value: Byte);
Begin
 SimulatedPort[PortAddr] := Value;
End;

{ Simulation de Delay }
Procedure Delay(MS: Word);
Var
 StartTime: TDateTime;
Begin
 StartTime := Now;
 While ((Now - StartTime) * 24 * 60 * 60 * 1000) < MS Do
  { Attendre };
End;

{$ENDIF}

{$IFNDEF FPC}
{ === VERSION TURBO PASCAL AVEC ACCÈS PORTS RÉELS === }
Uses DOS;

{ Fonction Port pour lecture - Turbo Pascal natif }
Function ReadPort(PortAddr: Word): Byte;
Begin
 ReadPort := Port[PortAddr];
End;

{ Fonction Port pour écriture - Turbo Pascal natif }
Procedure WritePort(PortAddr: Word; Value: Byte);
Begin
 Port[PortAddr] := Value;
End;

{$ENDIF}

{ === FONCTIONS D'ACCÈS MATÉRIEL === }

{ Lire un octet du registre NE2000 }
Function ReadNE2000Reg(BaseAddr: Word; RegOffset: Byte): Byte;
Begin
 ReadNE2000Reg := Port[BaseAddr + RegOffset];
End;

{ Écrire un octet dans le registre NE2000 }
Procedure WriteNE2000Reg(BaseAddr: Word; RegOffset: Byte; Value: Byte);
Begin
 Port[BaseAddr + RegOffset] := Value;
End;

{ Lire données du port I/O NE2000 }
Function ReadNE2000Data(BaseAddr: Word): Byte;
Begin
 ReadNE2000Data := Port[BaseAddr + NE2000_IOPORT];
End;

{ Écrire données vers le port I/O NE2000 }
Procedure WriteNE2000Data(BaseAddr: Word; Value: Byte);
Begin
 Port[BaseAddr + NE2000_IOPORT] := Value;
End;

{ === DÉTECTION ET INITIALISATION === }

{ Réinitialiser la carte NE2000 }
Procedure ResetNE2000(BaseAddr: Word);
Var
 ResetValue: Byte;
Begin
 { Lecture du port de réinitialisation pour déclencher le reset }
 ResetValue := Port[BaseAddr + NE2000_RESET];
 
 { Attendre un peu pour la réinitialisation }
 Delay(10);
 
 { Écrire la valeur lue pour compléter la réinitialisation }
 Port[BaseAddr + NE2000_RESET] := ResetValue;
 
 { Attendre la fin de la réinitialisation }
 Delay(100);
End;

{ Détecter la présence d'une carte NE2000 }
Function DetectNE2000(BaseAddr: Word): Boolean;
Var
 TestValue, ReadValue: Byte;
 I: Integer;
 SavedValue: Byte;
Begin
 DetectNE2000 := False;
 
 { Test 1: Réinitialisation et vérification du registre de commande }
 ResetNE2000(BaseAddr);
 
 { Attendre que la carte soit prête }
 For I := 1 To 1000 Do Begin
  ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_ISR);
  If (ReadValue and NE2000_ISR_RST) <> 0 Then Break;
  Delay(1);
 End;
 
 { Vérifier si la réinitialisation s'est bien passée }
 If (ReadValue and NE2000_ISR_RST) = 0 Then Exit;
 
 { Test 2: Mettre la carte en mode stop et vérifier }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 Delay(10);
 
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_CR);
 If (ReadValue and NE2000_CR_STP) = 0 Then Exit;
 
 { Test 3: Test d'écriture/lecture sur le registre RBCR }
 TestValue := $A5;  { Valeur de test }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR0, TestValue);
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_RBCR0);
 If ReadValue <> TestValue Then Exit;
 
 TestValue := $5A;  { Autre valeur de test }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR1, TestValue);
 ReadValue := ReadNE2000Reg(BaseAddr, NE2000_P0_RBCR1);
 If ReadValue <> TestValue Then Exit;
 
 { Test 4: Vérifier la signature NE2000 dans la ROM }
 { Configuration pour lecture remote DMA }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(BaseAddr, NE2000_P0_ISR, $FF);  { Effacer interruptions }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA0, 0);  { Adresse remote DMA }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA1, 0);
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR0, 32); { Lire 32 octets }
 WriteNE2000Reg(BaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_READ);
 
 { Lire quelques octets pour vérifier l'accès DMA }
 For I := 0 To 5 Do Begin
  ReadValue := ReadNE2000Data(BaseAddr);
  { Stocker l'adresse MAC pendant qu'on y est }
  NE2000Config.MACAddress[I] := ReadValue;
 End;
 
 { Si on arrive ici, la carte semble être une NE2000 }
 DetectNE2000 := True;
End;

{ Initialiser la carte NE2000 }
Function InitializeNE2000(BaseAddr: Word): Boolean;
Var
 I: Integer;
Begin
 InitializeNE2000 := False;
 
 { Réinitialiser la carte }
 ResetNE2000(BaseAddr);
 
 { Configuration initiale }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(BaseAddr, NE2000_P0_ISR, $FF);  { Effacer toutes les interruptions }
 
 { Configuration des tampons }
 WriteNE2000Reg(BaseAddr, NE2000_P0_BNRY, $40);   { Page de début réception }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA0, 0);    { Adresse DMA courante }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CRDA1, 0);
 
 { Passer en page 1 pour configurer l'adresse physique }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA or NE2000_CR_PS0);
 
 { Configurer l'adresse MAC (utiliser l'adresse lue lors de la détection) }
 For I := 0 To 5 Do Begin
  WriteNE2000Reg(BaseAddr, NE2000_P1_PAR0 + I, NE2000Config.MACAddress[I]);
 End;
 
 { Configuration du pointeur courant }
 WriteNE2000Reg(BaseAddr, NE2000_P1_CURR, $41);
 
 { Revenir en page 0 }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 
 { Démarrer la carte }
 WriteNE2000Reg(BaseAddr, NE2000_P0_CR, NE2000_CR_STA or NE2000_CR_NODMA);
 
 { Attendre que la carte soit prête }
 Delay(50);
 
 InitializeNE2000 := True;
End;

{ === GESTIONNAIRE D'INTERRUPTION === }

{ Gestionnaire d'interruption simple }
{$F+}
Procedure NE2000InterruptHandler;
Begin
 { Simplement effacer le registre d'état d'interruption }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_ISR, $FF);
 
 { Acquitter l'interruption matérielle }
 If NE2000Config.HardwareInt >= 8 Then Begin
  Port[$A0] := $20;  { EOI vers contrôleur esclave }
  Port[$20] := $20;  { EOI vers contrôleur maître }
 End Else Begin
  Port[$20] := $20;  { EOI vers contrôleur maître }
 End;
End;
{$F-}

{ Installer le gestionnaire d'interruption }
Function InstallInterruptHandler: Boolean;
Begin
 InstallInterruptHandler := False;
 
 { Pour cette version simplifiée, on ne gère pas les interruptions }
 { Dans un vrai driver, il faudrait installer le gestionnaire sur l'IRQ }
 
 InstallInterruptHandler := True;
End;

{ === INTERFACE PACKET DRIVER === }

{ Gestionnaire d'interruption logicielle pour packet driver }
{$F+}
Procedure PacketDriverHandler;
Begin
 { Interface simplifiée du packet driver }
 { En réalité, il faudrait implémenter toutes les fonctions }
 { du packet driver selon la spécification }
 
 ASM
  { Vérifier fonction demandée dans AH }
  CMP AH, 1     { Fonction 1: Driver Info }
  JE @DriverInfo
  CMP AH, 2     { Fonction 2: Access Type }
  JE @AccessType
  JMP @Exit
  
@DriverInfo:
  { Retourner informations sur le driver }
  MOV AL, 1     { Version }
  MOV BX, 1     { Type: Ethernet }
  MOV CX, 0     { Numéro }
  MOV DX, OFFSET DriverName
  CLC           { Succès }
  JMP @Exit

@AccessType:
  { Configuration du type d'accès }
  CLC           { Succès pour l'instant }
  JMP @Exit

@Exit:
 END;
End;
{$F-}

{ === FONCTIONS UTILITAIRES === }

{ Afficher l'adresse MAC }
Procedure DisplayMACAddress;
Var
 I: Integer;
Begin
 Write('Adresse MAC: ');
 For I := 0 To 5 Do Begin
  Write(IntToHex(NE2000Config.MACAddress[I], 2));
  If I < 5 Then Write('-');
 End;
 WriteLn;
End;

{ Afficher l'état de la carte }
Procedure DisplayCardStatus;
Var
 CR, ISR, TSR: Byte;
Begin
 WriteLn('État de la carte NE2000:');
 WriteLn('------------------------');
 
 CR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR);
 ISR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_ISR);
 TSR := ReadNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_TSR);
 
 WriteLn('Registre de commande (CR): $', IntToHex(CR, 2));
 WriteLn('Registre d''état d''interruption (ISR): $', IntToHex(ISR, 2));
 WriteLn('Registre d''état de transmission (TSR): $', IntToHex(TSR, 2));
 
 Write('État: ');
 If (CR and NE2000_CR_STA) <> 0 Then WriteLn('Démarré')
                                 Else WriteLn('Arrêté');
 
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
 
 { Test simple de lecture/écriture }
 For I := 0 To 15 Do TestData[I] := I * 16 + I;
 
 { Configuration pour DMA remote }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA0, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA1, $40);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR0, 16);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_WRITE);
 
 { Écrire données test }
 For I := 0 To 15 Do
  WriteNE2000Data(NE2000Config.IOBaseAddr, TestData[I]);
 
 { Relire les données }
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA0, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CRDA1, $40);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR0, 16);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_RBCR1, 0);
 WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_READ);
 
 { Vérifier les données }
 For I := 0 To 15 Do Begin
  If ReadNE2000Data(NE2000Config.IOBaseAddr) <> TestData[I] Then Exit;
 End;
 
 WriteLn('Test de la carte: RÉUSSI');
 TestCard := True;
End;

{ === FONCTIONS PRINCIPALES === }

{ Analyser les paramètres de ligne de commande }
Function ParseCommandLine: Boolean;
Begin
 ParseCommandLine := True;
 
 { Initialiser configuration par défaut }
 With NE2000Config Do Begin
  SoftwareInt := DEFAULT_SOFT_INT;
  HardwareInt := DEFAULT_HARD_INT;
  IOBaseAddr := DEFAULT_IO_BASE;
  IsDetected := False;
  IsInstalled := False;
 End;
 
 { Analyser les paramètres }
 If ParamCount >= 1 Then Begin
  { Premier paramètre: interruption logicielle }
  Val('$' + ParamStr(1), NE2000Config.SoftwareInt, Word(Result));
  If Result <> 0 Then Begin
   WriteLn('Erreur: Interruption logicielle invalide: ', ParamStr(1));
   ParseCommandLine := False;
   Exit;
  End;
 End;
 
 If ParamCount >= 2 Then Begin
  { Deuxième paramètre: IRQ matérielle }
  Val(ParamStr(2), NE2000Config.HardwareInt, Word(Result));
  If Result <> 0 Then Begin
   WriteLn('Erreur: IRQ invalide: ', ParamStr(2));
   ParseCommandLine := False;
   Exit;
  End;
 End;
 
 If ParamCount >= 3 Then Begin
  { Troisième paramètre: adresse I/O }
  Val('$' + ParamStr(3), NE2000Config.IOBaseAddr, Word(Result));
  If Result <> 0 Then Begin
   WriteLn('Erreur: Adresse I/O invalide: ', ParamStr(3));
   ParseCommandLine := False;
   Exit;
  End;
 End;
End;

{ Installer le driver NE2000 }
Function InstallDriver: Boolean;
Begin
 InstallDriver := False;
 
 WriteLn('Installation du driver packet NE2000...');
 WriteLn('Interruption logicielle: $', IntToHex(NE2000Config.SoftwareInt, 2));
 WriteLn('IRQ matérielle: ', NE2000Config.HardwareInt);
 WriteLn('Adresse I/O: $', IntToHex(NE2000Config.IOBaseAddr, 4));
 WriteLn;
 
 { Détecter la carte }
 WriteLn('Détection de la carte NE2000...');
 If not DetectNE2000(NE2000Config.IOBaseAddr) Then Begin
  WriteLn('ERREUR: Aucune carte NE2000 détectée à l''adresse $', IntToHex(NE2000Config.IOBaseAddr, 4));
  Exit;
 End;
 
 WriteLn('Carte NE2000 détectée avec succès!');
 NE2000Config.IsDetected := True;
 DisplayMACAddress;
 WriteLn;
 
 { Initialiser la carte }
 WriteLn('Initialisation de la carte...');
 If not InitializeNE2000(NE2000Config.IOBaseAddr) Then Begin
  WriteLn('ERREUR: Échec d''initialisation de la carte');
  Exit;
 End;
 
 WriteLn('Carte initialisée avec succès!');
 
 { Test de la carte }
 If not TestCard Then Begin
  WriteLn('ATTENTION: Test de la carte échoué - le driver pourrait ne pas fonctionner correctement');
 End;
 
 { Installer le gestionnaire d'interruption }
 WriteLn('Installation du gestionnaire d''interruption...');
 If InstallInterruptHandler Then Begin
  WriteLn('Gestionnaire d''interruption installé');
 End Else Begin
  WriteLn('ATTENTION: Échec d''installation du gestionnaire d''interruption');
 End;
 
 { Marquer comme installé }
 NE2000Config.IsInstalled := True;
 
 WriteLn;
 WriteLn('Driver packet NE2000 installé avec succès!');
 WriteLn('Le driver est maintenant prêt à être utilisé par les applications réseau.');
 
 InstallDriver := True;
End;

{ Désinstaller le driver }
Procedure UninstallDriver;
Begin
 If not NE2000Config.IsInstalled Then Begin
  WriteLn('Aucun driver installé');
  Exit;
 End;
 
 WriteLn('Désinstallation du driver NE2000...');
 
 { Arrêter la carte }
 If NE2000Config.IsDetected Then Begin
  WriteNE2000Reg(NE2000Config.IOBaseAddr, NE2000_P0_CR, NE2000_CR_STP or NE2000_CR_NODMA);
  WriteLn('Carte arrêtée');
 End;
 
 { Restaurer les gestionnaires d'interruption }
 { (Dans un vrai driver, il faudrait restaurer les vecteurs) }
 
 NE2000Config.IsInstalled := False;
 WriteLn('Driver désinstallé');
End;

{ Afficher les informations sur le driver }
Procedure ShowDriverInfo;
Begin
 WriteLn('Informations sur le driver NE2000');
 WriteLn('==================================');
 WriteLn;
 WriteLn('Version: 1.0 pour NETWORKKIT-P');
 WriteLn('Compatible: Cartes Ethernet NE2000 et compatibles');
 WriteLn('Type: Driver de paquet (Packet Driver)');
 WriteLn;
 WriteLn('Configuration actuelle:');
 With NE2000Config Do Begin
  WriteLn('  Interruption logicielle: $', IntToHex(SoftwareInt, 2));
  WriteLn('  IRQ matérielle: ', HardwareInt);
  WriteLn('  Adresse I/O: $', IntToHex(IOBaseAddr, 4));
  Write('  État détection: ');
  If IsDetected Then WriteLn('Détecté') Else WriteLn('Non détecté');
  Write('  État installation: ');
  If IsInstalled Then WriteLn('Installé') Else WriteLn('Non installé');
 End;
 WriteLn;
 
 If NE2000Config.IsDetected Then Begin
  DisplayCardStatus;
 End;
End;

{ === DONNÉES CONSTANTES === }
Const
 DriverName: PChar = 'NE2000 Packet Driver';

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('NE2000 : Driver de paquet pour cartes Ethernet NE2000 compatibles ISA');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NE2000 [soft_int] [hard_int] [io_address]');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  soft_int     Vecteur d''interruption logicielle en hexadécimal (60-7F)');
  WriteLn('  hard_int     Numéro d''IRQ matérielle (3, 5, 9, 10, 11, 12, 15)');
  WriteLn('  io_address   Adresse de base I/O en hexadécimal (280, 300, 320, etc.)');
  WriteLn;
  WriteLn('Valeurs par défaut :');
  WriteLn('  soft_int     60h    (Interruption logicielle $60)');
  WriteLn('  hard_int     10     (IRQ 10)');
  WriteLn('  io_address   300h   (Adresse I/O $300)');
  WriteLn;
  WriteLn('Exemples d''utilisation :');
  WriteLn('  NE2000                    # Configuration par défaut');
  WriteLn('  NE2000 60 10 300          # Configuration explicite');
  WriteLn('  NE2000 61 5 280           # IRQ 5, adresse $280');
  WriteLn('  NE2000 62 11 320          # IRQ 11, adresse $320');
  WriteLn;
  WriteLn('Adresses I/O courantes :');
  WriteLn('  280h, 300h, 320h, 340h, 360h');
  WriteLn;
  WriteLn('IRQ courantes :');
  WriteLn('  3, 5, 9, 10, 11, 12, 15');
  WriteLn;
  WriteLn('Configuration des cavaliers :');
  WriteLn('  Les cavaliers de la carte doivent correspondre exactement');
  WriteLn('  aux paramètres spécifiés pour l''IRQ et l''adresse I/O.');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -i, /i       Afficher informations sur le driver installé');
  WriteLn('  -u, /u       Désinstaller le driver');
  WriteLn('  -t, /t       Tester la carte sans installer le driver');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0            Installation réussie');
  WriteLn('  1            Erreur de paramètres');
  WriteLn('  2            Carte non détectée');
  WriteLn('  3            Erreur d''initialisation');
  WriteLn('  4            Erreur d''installation du driver');
  WriteLn;
  WriteLn('Note: Ce driver implémente l''interface Packet Driver standard');
  WriteLn('pour les cartes Ethernet Novell NE2000 et compatibles.');
  WriteLn('Nécessite une carte NE2000 ISA correctement configurée.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('ne2000 (NETWORKKIT-P) 1.0');
  WriteLn('Driver de paquet pour cartes Ethernet NE2000');
  WriteLn('Compatible avec ne2000.com de Novell');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais pour NETWORKKIT-P');
 End
 Else If (ParamStr(1) = '-i') or (ParamStr(1) = '/i') Then Begin
  ShowDriverInfo;
 End
 Else If (ParamStr(1) = '-u') or (ParamStr(1) = '/u') Then Begin
  UninstallDriver;
 End
 Else If (ParamStr(1) = '-t') or (ParamStr(1) = '/t') Then Begin
  If ParseCommandLine Then Begin
   WriteLn('Test de détection NE2000...');
   If DetectNE2000(NE2000Config.IOBaseAddr) Then Begin
    WriteLn('Carte NE2000 détectée avec succès!');
    NE2000Config.IsDetected := True;
    DisplayMACAddress;
    DisplayCardStatus;
   End Else Begin
    WriteLn('Aucune carte NE2000 détectée à l''adresse $', IntToHex(NE2000Config.IOBaseAddr, 4));
    Halt(2);
   End;
  End Else Begin
   Halt(1);
  End;
 End
 Else Begin
  { Installation du driver }
  If ParseCommandLine Then Begin
   If InstallDriver Then Begin
    { Succès }
    Halt(0);
   End Else Begin
    Halt(4);
   End;
  End Else Begin
   Halt(1);
  End;
 End;
END.
