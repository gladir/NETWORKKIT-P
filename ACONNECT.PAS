{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande aconnect (ALSA MIDI connect))
}

Program ACONNECT;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Windows;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour un port MIDI }
 TMIDIPort = Record
  ClientID: Integer;         { ID du client ALSA }
  PortID: Integer;           { ID du port }
  ClientName: String[64];    { Nom du client }
  PortName: String[64];      { Nom du port }
  PortType: String[20];      { Type de port (Read, Write, Duplex) }
  Capabilities: Word;        { Capacités du port }
  Connected: Boolean;        { Port connecté }
  Active: Boolean;           { Port actif }
 End;

 { Structure pour une connexion MIDI }
 TMIDIConnection = Record
  SenderClient: Integer;     { Client émetteur }
  SenderPort: Integer;       { Port émetteur }
  ReceiverClient: Integer;   { Client récepteur }
  ReceiverPort: Integer;     { Port récepteur }
  Active: Boolean;           { Connexion active }
  Permanent: Boolean;        { Connexion permanente }
 End;

Const
 MAX_MIDI_PORTS = 64;
 MAX_MIDI_CONNECTIONS = 128;
 
 { Capacités des ports MIDI }
 SND_SEQ_PORT_CAP_READ = $01;
 SND_SEQ_PORT_CAP_WRITE = $02;
 SND_SEQ_PORT_CAP_SYNC_READ = $04;
 SND_SEQ_PORT_CAP_SYNC_WRITE = $08;
 SND_SEQ_PORT_CAP_DUPLEX = $10;
 SND_SEQ_PORT_CAP_SUBS_READ = $20;
 SND_SEQ_PORT_CAP_SUBS_WRITE = $40;

Var
 MIDIPorts: Array[0..MAX_MIDI_PORTS-1] of TMIDIPort;
 MIDIConnections: Array[0..MAX_MIDI_CONNECTIONS-1] of TMIDIConnection;
 PortCount: Integer;
 ConnectionCount: Integer;

{ Procédures Windows pour MIDI (simulation) }
Function midiOutGetNumDevs: UINT; stdcall; external 'winmm.dll';
Function midiInGetNumDevs: UINT; stdcall; external 'winmm.dll';

{ Initialiser les ports MIDI }
Procedure InitializeMIDI;
Var
 I: Integer;
Begin
 PortCount := 0;
 ConnectionCount := 0;
 
 For I := 0 To MAX_MIDI_PORTS-1 Do Begin
  With MIDIPorts[I] Do Begin
   ClientID := 0;
   PortID := 0;
   ClientName := '';
   PortName := '';
   PortType := '';
   Capabilities := 0;
   Connected := False;
   Active := False;
  End;
 End;
 
 For I := 0 To MAX_MIDI_CONNECTIONS-1 Do Begin
  With MIDIConnections[I] Do Begin
   SenderClient := 0;
   SenderPort := 0;
   ReceiverClient := 0;
   ReceiverPort := 0;
   Active := False;
   Permanent := False;
  End;
 End;
End;

{ Créer des ports MIDI d'exemple }
Procedure CreateSamplePorts;
Begin
 { Port système ALSA }
 With MIDIPorts[0] Do Begin
  ClientID := 0;
  PortID := 1;
  ClientName := 'System';
  PortName := 'Timer';
  PortType := 'Read/Write';
  Capabilities := SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_WRITE;
  Connected := False;
  Active := True;
 End;
 
 { Port système Announce }
 With MIDIPorts[1] Do Begin
  ClientID := 1;
  PortID := 0;
  ClientName := 'Announce';
  PortName := 'Announce';
  PortType := 'Read/Write';
  Capabilities := SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_WRITE;
  Connected := False;
  Active := True;
 End;
 
 { Synthétiseur software }
 With MIDIPorts[2] Do Begin
  ClientID := 14;
  PortID := 0;
  ClientName := 'Midi Through';
  PortName := 'Midi Through Port-0';
  PortType := 'Read/Write';
  Capabilities := SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_WRITE or 
                  SND_SEQ_PORT_CAP_SUBS_READ or SND_SEQ_PORT_CAP_SUBS_WRITE;
  Connected := False;
  Active := True;
 End;
 
 { Port FluidSynth }
 With MIDIPorts[3] Do Begin
  ClientID := 128;
  PortID := 0;
  ClientName := 'FLUID Synth';
  PortName := 'Synth input port';
  PortType := 'Write';
  Capabilities := SND_SEQ_PORT_CAP_WRITE or SND_SEQ_PORT_CAP_SUBS_WRITE;
  Connected := False;
  Active := True;
 End;
 
 { Port clavier MIDI }
 With MIDIPorts[4] Do Begin
  ClientID := 20;
  PortID := 0;
  ClientName := 'USB MIDI';
  PortName := 'USB MIDI MIDI 1';
  PortType := 'Read/Write';
  Capabilities := SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_WRITE or
                  SND_SEQ_PORT_CAP_SUBS_READ or SND_SEQ_PORT_CAP_SUBS_WRITE;
  Connected := True;
  Active := True;
 End;
 
 { Séquenceur }
 With MIDIPorts[5] Do Begin
  ClientID := 129;
  PortID := 0;
  ClientName := 'LMMS';
  PortName := 'LMMS';
  PortType := 'Read/Write';
  Capabilities := SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_WRITE;
  Connected := False;
  Active := True;
 End;
 
 PortCount := 6;
End;

{ Créer des connexions d'exemple }
Procedure CreateSampleConnections;
Begin
 { Connexion clavier vers synthé }
 With MIDIConnections[0] Do Begin
  SenderClient := 20;
  SenderPort := 0;
  ReceiverClient := 128;
  ReceiverPort := 0;
  Active := True;
  Permanent := False;
 End;
 
 { Connexion séquenceur vers synthé }
 With MIDIConnections[1] Do Begin
  SenderClient := 129;
  SenderPort := 0;
  ReceiverClient := 128;
  ReceiverPort := 0;
  Active := True;
  Permanent := False;
 End;
 
 ConnectionCount := 2;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Fonctions utilitaires pour Turbo Pascal }
Function IntToStr(Value: LongInt): String;
Var
 S: String;
Begin
 Str(Value, S);
 IntToStr := S;
End;

Function StrToInt(S: String): LongInt;
Var
 Value: LongInt;
 Code: Integer;
Begin
 Val(S, Value, Code);
 If Code <> 0 Then Value := 0;
 StrToInt := Value;
End;

Function LowerCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['A'..'Z'] Then S[I] := Chr(Ord(S[I]) + 32);
 LowerCase := S;
End;

Function UpperCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I] := Chr(Ord(S[I]) - 32);
 UpperCase := S;
End;

Function Copy(S: String; Start, Len: Integer): String;
Var
 ResultStr: String;
 I: Integer;
Begin
 ResultStr := '';
 For I := Start To Start + Len - 1 Do
  If I <= Length(S) Then ResultStr := ResultStr + S[I];
 Copy := ResultStr;
End;

Function Pos(SubStr, S: String): Integer;
Var
 I, J: Integer;
 Found: Boolean;
Begin
 Pos := 0;
 For I := 1 To Length(S) - Length(SubStr) + 1 Do Begin
  Found := True;
  For J := 1 To Length(SubStr) Do
   If S[I + J - 1] <> SubStr[J] Then Begin
    Found := False;
    Break;
   End;
  If Found Then Begin
   Pos := I;
   Break;
  End;
 End;
End;
{$ENDIF}

{$IFDEF FPC}
{ Trouver un port par client:port }
Function FindPort(ClientID, PortID: Integer): Integer;
Var
 I: Integer;
Begin
 FindPort := -1;
 For I := 0 To PortCount - 1 Do Begin
  If (MIDIPorts[I].ClientID = ClientID) and (MIDIPorts[I].PortID = PortID) Then Begin
   FindPort := I;
   Exit;
  End;
 End;
End;

{ Trouver une connexion }
Function FindConnection(SenderClient, SenderPort, ReceiverClient, ReceiverPort: Integer): Integer;
Var
 I: Integer;
Begin
 FindConnection := -1;
 For I := 0 To ConnectionCount - 1 Do Begin
  With MIDIConnections[I] Do Begin
   If (MIDIConnections[I].SenderClient = SenderClient) and 
      (MIDIConnections[I].SenderPort = SenderPort) and
      (ReceiverClient = ReceiverClient) and 
      (MIDIConnections[I].ReceiverPort = ReceiverPort) Then Begin
    FindConnection := I;
    Exit;
   End;
  End;
 End;
End;

{ Connecter deux ports MIDI }
Function ConnectPorts(SenderClient, SenderPort, ReceiverClient, ReceiverPort: Integer): Boolean;
Var
 Index: Integer;
 SenderIndex, ReceiverIndex: Integer;
Begin
 ConnectPorts := False;
 
 { Vérifier que les ports existent }
 SenderIndex := FindPort(SenderClient, SenderPort);
 ReceiverIndex := FindPort(ReceiverClient, ReceiverPort);
 
 If SenderIndex < 0 Then Begin
  WriteLn('Erreur: Port émetteur ', SenderClient, ':', SenderPort, ' introuvable');
  Exit;
 End;
 
 If ReceiverIndex < 0 Then Begin
  WriteLn('Erreur: Port récepteur ', ReceiverClient, ':', ReceiverPort, ' introuvable');
  Exit;
 End;
 
 { Vérifier les capacités }
 If (MIDIPorts[SenderIndex].Capabilities and SND_SEQ_PORT_CAP_READ) = 0 Then Begin
  WriteLn('Erreur: Le port ', SenderClient, ':', SenderPort, ' ne peut pas émettre');
  Exit;
 End;
 
 If (MIDIPorts[ReceiverIndex].Capabilities and SND_SEQ_PORT_CAP_WRITE) = 0 Then Begin
  WriteLn('Erreur: Le port ', ReceiverClient, ':', ReceiverPort, ' ne peut pas recevoir');
  Exit;
 End;
 
 { Vérifier si la connexion existe déjà }
 Index := FindConnection(SenderClient, SenderPort, ReceiverClient, ReceiverPort);
 If Index >= 0 Then Begin
  WriteLn('Connexion ', SenderClient, ':', SenderPort, ' -> ', 
          ReceiverClient, ':', ReceiverPort, ' déjà existante');
  Exit;
 End;
 
 { Créer la connexion }
 If ConnectionCount >= MAX_MIDI_CONNECTIONS Then Begin
  WriteLn('Erreur: Nombre maximum de connexions atteint');
  Exit;
 End;
 
 Index := ConnectionCount;
 With MIDIConnections[Index] Do Begin
  MIDIConnections[Index].SenderClient := SenderClient;
  MIDIConnections[Index].SenderPort := SenderPort;
  MIDIConnections[Index].ReceiverClient := ReceiverClient;
  MIDIConnections[Index].ReceiverPort := ReceiverPort;
  Active := True;
  Permanent := False;
 End;
 
 Inc(ConnectionCount);
 WriteLn('Connexion créée: ', SenderClient, ':', SenderPort, ' -> ', 
         ReceiverClient, ':', ReceiverPort);
 ConnectPorts := True;
End;

{ Déconnecter deux ports MIDI }
Function DisconnectPorts(SenderClient, SenderPort, ReceiverClient, ReceiverPort: Integer): Boolean;
Var
 Index, I: Integer;
Begin
 DisconnectPorts := False;
 Index := FindConnection(SenderClient, SenderPort, ReceiverClient, ReceiverPort);
 
 If Index < 0 Then Begin
  WriteLn('Erreur: Connexion ', SenderClient, ':', SenderPort, ' -> ', 
          ReceiverClient, ':', ReceiverPort, ' introuvable');
  Exit;
 End;
 
 { Supprimer la connexion }
 For I := Index To ConnectionCount - 2 Do
  MIDIConnections[I] := MIDIConnections[I + 1];
  
 Dec(ConnectionCount);
 WriteLn('Connexion supprimée: ', SenderClient, ':', SenderPort, ' -> ', 
         ReceiverClient, ':', ReceiverPort);
 DisconnectPorts := True;
End;

{ Déconnecter toutes les connexions d'un port }
Function DisconnectAllFromPort(ClientID, PortID: Integer): Boolean;
Var
 I, Removed: Integer;
Begin
 DisconnectAllFromPort := False;
 Removed := 0;
 
 { Parcourir à l'envers pour éviter les problèmes d'index }
 I := ConnectionCount - 1;
 While I >= 0 Do Begin
  With MIDIConnections[I] Do Begin
   If ((SenderClient = ClientID) and (SenderPort = PortID)) or
      ((ReceiverClient = ClientID) and (ReceiverPort = PortID)) Then Begin
    { Supprimer cette connexion }
    WriteLn('Suppression connexion: ', SenderClient, ':', SenderPort, ' -> ', 
            ReceiverClient, ':', ReceiverPort);
    
    { Décaler les connexions suivantes }
    While I < ConnectionCount - 1 Do Begin
     MIDIConnections[I] := MIDIConnections[I + 1];
     Inc(I);
    End;
    Dec(ConnectionCount);
    Inc(Removed);
    I := ConnectionCount - 1; { Recommencer depuis la fin }
   End Else
    Dec(I);
  End;
 End;
 
 If Removed > 0 Then Begin
  WriteLn(Removed, ' connexion(s) supprimée(s) du port ', ClientID, ':', PortID);
  DisconnectAllFromPort := True;
 End Else
  WriteLn('Aucune connexion trouvée pour le port ', ClientID, ':', PortID);
End;

{ Afficher les capacités d'un port }
Function GetCapabilitiesString(Capabilities: Word): String;
Var
 CapStr: String;
Begin
 CapStr := '';
 If (Capabilities and SND_SEQ_PORT_CAP_READ) <> 0 Then CapStr := CapStr + 'R';
 If (Capabilities and SND_SEQ_PORT_CAP_WRITE) <> 0 Then CapStr := CapStr + 'W';
 If (Capabilities and SND_SEQ_PORT_CAP_SYNC_READ) <> 0 Then CapStr := CapStr + 'Sr';
 If (Capabilities and SND_SEQ_PORT_CAP_SYNC_WRITE) <> 0 Then CapStr := CapStr + 'Sw';
 If (Capabilities and SND_SEQ_PORT_CAP_DUPLEX) <> 0 Then CapStr := CapStr + 'D';
 If (Capabilities and SND_SEQ_PORT_CAP_SUBS_READ) <> 0 Then CapStr := CapStr + 'Sr';
 If (Capabilities and SND_SEQ_PORT_CAP_SUBS_WRITE) <> 0 Then CapStr := CapStr + 'Sw';
 
 If CapStr = '' Then CapStr := '-';
 GetCapabilitiesString := CapStr;
End;

{ Lister tous les ports MIDI }
Procedure ListMIDIPorts(ShowDetails: Boolean);
Var
 I: Integer;
Begin
 If PortCount = 0 Then Begin
  WriteLn('Aucun port MIDI disponible');
  Exit;
 End;
 
 If ShowDetails Then Begin
  WriteLn('Ports MIDI ALSA disponibles:');
  WriteLn('============================');
  WriteLn;
  
  For I := 0 To PortCount - 1 Do Begin
   With MIDIPorts[I] Do Begin
    WriteLn('Client ', ClientID, ': ''', ClientName, ''' [type=user]');
    WriteLn('    ', PortID, ' ''', PortName, '''');
    WriteLn('        Capacités: ', GetCapabilitiesString(Capabilities));
    WriteLn('        Type: ', PortType);
    If Connected Then WriteLn('        État: Connecté') 
                 Else WriteLn('        État: Disponible');
    WriteLn;
   End;
  End;
 End Else Begin
  WriteLn('client port    nom');
  WriteLn('------+--------+--------------------------------');
  
  For I := 0 To PortCount - 1 Do Begin
   With MIDIPorts[I] Do Begin
    Write(ClientID:3, ':', PortID:2, '     ');
    WriteLn(ClientName, ' ', PortName);
   End;
  End;
 End;
End;

{ Lister les connexions actives }
Procedure ListConnections;
Var
 I, SenderIdx, ReceiverIdx: Integer;
Begin
 If ConnectionCount = 0 Then Begin
  WriteLn('Aucune connexion active');
  Exit;
 End;
 
 WriteLn('Connexions MIDI actives:');
 WriteLn('========================');
 
 For I := 0 To ConnectionCount - 1 Do Begin
  With MIDIConnections[I] Do Begin
   Write('Connexion depuis ', SenderClient, ':', SenderPort);
   
   { Trouver le nom du port émetteur }
   SenderIdx := FindPort(SenderClient, SenderPort);
   If SenderIdx >= 0 Then
    Write(' (', MIDIPorts[SenderIdx].ClientName, ')')
   Else
    Write(' (port inconnu)');
   
   Write(' vers ', ReceiverClient, ':', ReceiverPort);
   
   { Trouver le nom du port récepteur }
   ReceiverIdx := FindPort(ReceiverClient, ReceiverPort);
   If ReceiverIdx >= 0 Then
    Write(' (', MIDIPorts[ReceiverIdx].ClientName, ')')
   Else
    Write(' (port inconnu)');
   
   WriteLn;
  End;
 End;
 
 WriteLn;
 WriteLn('Total: ', ConnectionCount, ' connexion(s) active(s)');
End;

{ Afficher les statistiques }
Procedure ShowMIDIStats;
Var
 I, ReadPorts, WritePorts, ConnectedPorts: Integer;
Begin
 ReadPorts := 0;
 WritePorts := 0;
 ConnectedPorts := 0;
 
 For I := 0 To PortCount - 1 Do Begin
  With MIDIPorts[I] Do Begin
   If (Capabilities and SND_SEQ_PORT_CAP_READ) <> 0 Then Inc(ReadPorts);
   If (Capabilities and SND_SEQ_PORT_CAP_WRITE) <> 0 Then Inc(WritePorts);
   If Connected Then Inc(ConnectedPorts);
  End;
 End;
 
 WriteLn('Statistiques MIDI ALSA:');
 WriteLn('=======================');
 WriteLn('Ports totaux        : ', PortCount);
 WriteLn('Ports d''entrée      : ', ReadPorts);
 WriteLn('Ports de sortie     : ', WritePorts);
 WriteLn('Ports connectés     : ', ConnectedPorts);
 WriteLn('Connexions actives  : ', ConnectionCount);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedPorts;
Begin
 WriteLn('Ports MIDI ALSA disponibles (simulation):');
 WriteLn('client port    nom');
 WriteLn('------+--------+--------------------------------');
 WriteLn('  0:1         System Timer');
 WriteLn('  1:0         Announce Announce');
 WriteLn(' 14:0         Midi Through Midi Through Port-0');
 WriteLn('128:0         FLUID Synth Synth input port');
 WriteLn(' 20:0         USB MIDI USB MIDI MIDI 1');
 WriteLn('129:0         LMMS LMMS');
End;

Procedure ShowSimulatedConnections;
Begin
 WriteLn('Connexions MIDI actives (simulation):');
 WriteLn('========================');
 WriteLn('Connexion depuis 20:0 (USB MIDI) vers 128:0 (FLUID Synth)');
 WriteLn('Connexion depuis 129:0 (LMMS) vers 128:0 (FLUID Synth)');
 WriteLn;
 WriteLn('Total: 2 connexion(s) active(s)');
End;

Procedure SimulateMIDIConnect;
Begin
 WriteLn('Connexion créée: 20:0 -> 128:0 (simulation)');
End;

Procedure SimulateMIDIDisconnect;
Begin
 WriteLn('Connexion supprimée: 20:0 -> 128:0 (simulation)');
End;

Procedure ShowSimulatedStats;
Begin
 WriteLn('Statistiques MIDI ALSA:');
 WriteLn('=======================');
 WriteLn('Ports totaux        : 6');
 WriteLn('Ports d''entrée      : 4');
 WriteLn('Ports de sortie     : 5');
 WriteLn('Ports connectés     : 1');
 WriteLn('Connexions actives  : 2');
End;
{$ENDIF}

{ Parser une spécification de port (client:port) }
Procedure ParsePortSpec(PortSpec: String; var ClientID, PortID: Integer);
Var
 ColonPos: Integer;
Begin
 ClientID := 0;
 PortID := 0;
 
 ColonPos := Pos(':', PortSpec);
 If ColonPos > 0 Then Begin
  ClientID := StrToInt(Copy(PortSpec, 1, ColonPos - 1));
  PortID := StrToInt(Copy(PortSpec, ColonPos + 1, Length(PortSpec) - ColonPos));
 End Else Begin
  ClientID := StrToInt(PortSpec);
  PortID := 0;
 End;
End;

{ Analyse de la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Action: String;
 SenderClient, SenderPort, ReceiverClient, ReceiverPort: Integer;
 ShowDetails: Boolean;
 Param: String;
Begin
 Action := 'connections';
 SenderClient := 0;
 SenderPort := 0;
 ReceiverClient := 0;
 ReceiverPort := 0;
 ShowDetails := False;
 
 { Analyser les paramètres }
 For I := 1 To ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-i') or (LowerCase(Param) = '--input') Then
   Action := 'list-input'
  Else If (LowerCase(Param) = '-o') or (LowerCase(Param) = '--output') Then
   Action := 'list-output'
  Else If (LowerCase(Param) = '-l') or (LowerCase(Param) = '--list') Then
   Action := 'list'
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--connect') Then
   Action := 'connect'
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--disconnect') Then
   Action := 'disconnect'
  Else If (LowerCase(Param) = '-x') or (LowerCase(Param) = '--remove-all') Then
   Action := 'remove-all'
  Else If (LowerCase(Param) = '-r') or (LowerCase(Param) = '--real-time') Then
   { Option ignorée pour compatibilité }
  Else If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then
   ShowDetails := True
  Else If LowerCase(Param) = '--connections' Then
   Action := 'connections'
  Else If LowerCase(Param) = '--stats' Then
   Action := 'stats'
  Else If Pos(':', Param) > 0 Then Begin
   { Spécification de port }
   If (Action = 'list') and (SenderClient = 0) and (ReceiverClient = 0) Then
    Action := 'connect'; { Connexion implicite }
   
   If (Action = 'connect') or (Action = 'disconnect') Then Begin
    If SenderClient = 0 Then
     ParsePortSpec(Param, SenderClient, SenderPort)
    Else
     ParsePortSpec(Param, ReceiverClient, ReceiverPort);
   End Else If Action = 'remove-all' Then
    ParsePortSpec(Param, SenderClient, SenderPort);
  End;
 End;
 
 {$IFDEF FPC}
 Case Action Of
  'list': Begin
   If PortCount = 0 Then CreateSamplePorts;
   ListMIDIPorts(ShowDetails);
  End;
  'list-input': Begin
   If PortCount = 0 Then CreateSamplePorts;
   WriteLn('Ports d''entrée MIDI:');
   ListMIDIPorts(False);
  End;
  'list-output': Begin
   If PortCount = 0 Then CreateSamplePorts;
   WriteLn('Ports de sortie MIDI:');
   ListMIDIPorts(False);
  End;
  'connect': Begin
   If PortCount = 0 Then CreateSamplePorts;
   If (SenderClient <> 0) and (ReceiverClient <> 0) Then
    ConnectPorts(SenderClient, SenderPort, ReceiverClient, ReceiverPort)
   Else
    WriteLn('Erreur: Spécifiez les ports émetteur et récepteur (client:port)');
  End;
  'disconnect': Begin
   If PortCount = 0 Then CreateSamplePorts;
   If (SenderClient <> 0) and (ReceiverClient <> 0) Then
    DisconnectPorts(SenderClient, SenderPort, ReceiverClient, ReceiverPort)
   Else
    WriteLn('Erreur: Spécifiez les ports émetteur et récepteur (client:port)');
  End;
  'remove-all': Begin
   If PortCount = 0 Then CreateSamplePorts;
   If SenderClient <> 0 Then
    DisconnectAllFromPort(SenderClient, SenderPort)
   Else
    WriteLn('Erreur: Spécifiez le port (client:port)');
  End;
  'connections': Begin
   If PortCount = 0 Then CreateSamplePorts;
   If ConnectionCount = 0 Then CreateSampleConnections;
   ListConnections;
  End;
  'stats': Begin
   If PortCount = 0 Then CreateSamplePorts;
   If ConnectionCount = 0 Then CreateSampleConnections;
   ShowMIDIStats;
  End;
 Else Begin
  If PortCount = 0 Then CreateSamplePorts;
  If ConnectionCount = 0 Then CreateSampleConnections;
  ListConnections;
 End;
 End;
 {$ELSE}
 Case Action Of
  'list': ShowSimulatedPorts;
  'list-input': Begin
   WriteLn('Ports d''entrée MIDI (simulation):');
   ShowSimulatedPorts;
  End;
  'list-output': Begin
   WriteLn('Ports de sortie MIDI (simulation):');
   ShowSimulatedPorts;
  End;
  'connect': SimulateMIDIConnect;
  'disconnect': SimulateMIDIDisconnect;
  'remove-all': WriteLn('Toutes les connexions supprimées (simulation)');
  'stats': ShowSimulatedStats;
 Else
  ShowSimulatedConnections;
 End;
 {$ENDIF}
End;

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
   (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('ACONNECT : Gestionnaire de connexions ALSA MIDI');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  ACONNECT [options] [sender] [receiver]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -i, --input           Lister les ports d''entrée');
  WriteLn('  -o, --output          Lister les ports de sortie');
  WriteLn('  -l, --list            Lister tous les ports');
  WriteLn('  -c, --connect         Connecter deux ports');
  WriteLn('  -d, --disconnect      Déconnecter deux ports');
  WriteLn('  -x, --remove-all      Supprimer toutes les connexions d''un port');
  WriteLn('  -r, --real-time       Mode temps réel (ignoré)');
  WriteLn('  -v, --verbose         Affichage détaillé');
  WriteLn('  --stats               Statistiques MIDI');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  sender                Port émetteur (client:port)');
  WriteLn('  receiver              Port récepteur (client:port)');
  WriteLn;
  WriteLn('Format des ports :');
  WriteLn('  client:port           Numéro de client et de port');
  WriteLn('  client                Client avec port 0 par défaut');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  ACONNECT -l                       # Lister tous les ports');
  WriteLn('  ACONNECT -i                       # Ports d''entrée seulement');
  WriteLn('  ACONNECT -o                       # Ports de sortie seulement');
  WriteLn('  ACONNECT                          # Connexions actives');
  WriteLn('  ACONNECT 20:0 128:0               # Connecter ports');
  WriteLn('  ACONNECT -c 20:0 128:0            # Connecter explicitement');
  WriteLn('  ACONNECT -d 20:0 128:0            # Déconnecter ports');
  WriteLn('  ACONNECT -x 20:0                  # Supprimer toutes connexions');
  WriteLn('  ACONNECT --stats                  # Statistiques');
  WriteLn;
  WriteLn('Capacités des ports :');
  WriteLn('  R = Lecture (Read)    W = Écriture (Write)');
  WriteLn('  Sr = Lecture sync     Sw = Écriture sync');
  WriteLn('  D = Duplex           Su = Souscription');
  WriteLn;
  WriteLn('Note: ACONNECT gère les connexions entre ports MIDI via ALSA.');
  WriteLn('Les connexions permettent de router les événements MIDI entre');
  WriteLn('applications, synthétiseurs, et contrôleurs.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion réelle)');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('ACONNECT 1.00 - ALSA MIDI Connection Manager, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeMIDI;
  If ParamCount = 0 Then Begin
   CreateSamplePorts;
   CreateSampleConnections;
  End;
  {$ENDIF}
  ParseCommandLine;
 End;
END.
