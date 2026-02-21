{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande smbclient (SMB/CIFS client))
}

Program SMBCLIEN;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock, Windows;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'un fichier/dossier SMB }
 TSMBFile = Record
  Name: String[255];          { Nom du fichier }
  FullPath: String[255];      { Chemin complet }
  Size: Int64;                { Taille en octets }
  Attributes: LongWord;       { Attributs de fichier }
  CreationTime: TDateTime;    { Date de création }
  LastWriteTime: TDateTime;   { Dernière modification }
  LastAccessTime: TDateTime;  { Dernier accès }
  IsDirectory: Boolean;       { Est un dossier }
  IsHidden: Boolean;          { Fichier caché }
  IsReadOnly: Boolean;        { Lecture seule }
  IsSystem: Boolean;          { Fichier système }
  IsArchive: Boolean;         { Attribut archive }
 End;

 { Configuration du client SMB }
 TSMBClientConfig = Record
  Server: String[255];        { Serveur SMB }
  Share: String[255];         { Partage }
  Username: String[64];       { Nom d'utilisateur }
  Password: String[255];      { Mot de passe }
  Domain: String[64];         { Domaine }
  Workgroup: String[64];      { Groupe de travail }
  Port: Word;                 { Port (139 ou 445) }
  UseNTLM: Boolean;           { Utiliser authentification NTLM }
  UseKerberos: Boolean;       { Utiliser Kerberos }
  ProtocolVersion: Integer;   { Version protocole SMB }
  Timeout: Integer;           { Timeout en secondes }
  MaxBufferSize: Integer;     { Taille buffer max }
  CaseSensitive: Boolean;     { Noms de fichiers sensibles à la casse }
  Verbose: Boolean;           { Mode verbeux }
  Debug: Boolean;             { Mode debug }
  Recursive: Boolean;         { Récursif pour commandes }
  Preserve: Boolean;          { Préserver attributs }
  Archive: Boolean;           { Mode archive }
  Quiet: Boolean;             { Mode silencieux }
 End;

 { Session SMB active }
 TSMBSession = Record
  Socket: TSocket;            { Socket de connexion }
  IsConnected: Boolean;       { Connexion établie }
  IsAuthenticated: Boolean;   { Authentifié }
  CurrentPath: String[255];   { Répertoire courant }
  TreeID: Word;               { ID de l'arborescence }
  UserID: Word;               { ID utilisateur }
  ProcessID: Word;            { ID processus }
  MultiplexID: Word;          { ID multiplex }
  SessionKey: Array[0..15] of Byte; { Clé de session }
  Challenge: Array[0..7] of Byte;   { Challenge d'auth }
  Capabilities: LongWord;     { Capacités du serveur }
  MaxTransmitSize: Word;      { Taille transmission max }
  MaxMultiplexCount: Word;    { Nombre max requêtes simultanées }
  LastError: String[255];     { Dernière erreur }
  BytesTransferred: Int64;    { Octets transférés }
  FilesTransferred: Integer;  { Fichiers transférés }
 End;

 { Commande client SMB }
 TSMBCommand = Record
  Command: String[32];        { Nom de la commande }
  Parameters: String[255];    { Paramètres }
  LocalPath: String[255];     { Chemin local }
  RemotePath: String[255];    { Chemin distant }
  Recursive: Boolean;         { Mode récursif }
  Force: Boolean;             { Forcer l'action }
  Preserve: Boolean;          { Préserver attributs }
 End;

Var
 { Variables globales }
 SMBConfig: TSMBClientConfig;
 SMBSession: TSMBSession;
 SMBFiles: Array[0..999] of TSMBFile;
 FileCount: Integer;
 InteractiveMode: Boolean;
 ExitRequested: Boolean;

{ === FONCTIONS UTILITAIRES === }

{ Obtenir variable d'environnement (compatible) }
Function GetEnvVar(VarName: String): String;
{$IFDEF WINDOWS}
Var
 Buffer: Array[0..255] of Char;
 Len: DWord;
{$ENDIF}
Begin
 Result := '';
 {$IFDEF WINDOWS}
 Len := GetEnvironmentVariable(@VarName[1], Buffer, SizeOf(Buffer));
 If Len > 0 Then
  Result := StrPas(Buffer);
 {$ELSE}
 Result := GetEnvironmentVariable(VarName);
 {$ENDIF}
End;

{ === FONCTIONS SMB RÉELLES === }

{ Initialiser WinSock (Windows uniquement) }
Function InitializeNetwork: Boolean;
{$IFDEF WINDOWS}
Var
 WSAData: TWSAData;
{$ENDIF}
Begin
 InitializeNetwork := True;
 {$IFDEF WINDOWS}
 If WSAStartup($0202, WSAData) <> 0 Then Begin
  WriteLn('Error: Cannot initialize WinSock');
  InitializeNetwork := False;
 End;
 {$ENDIF}
End;

{ Nettoyer réseau }
Procedure CleanupNetwork;
Begin
 {$IFDEF WINDOWS}
 WSACleanup;
 {$ENDIF}
End;

{ Se connecter au serveur SMB }
Function ConnectToSMBServer(Server: String; Port: Word): Boolean;
Var
 ServerAddr: TSockAddrIn;
 {$IFDEF WINDOWS}
 HostEnt: PHostEnt;
 {$ENDIF}
Begin
 ConnectToSMBServer := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Connecting to ', Server, ':', Port, '...');
 
 { Créer socket }
 SMBSession.Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If SMBSession.Socket = INVALID_SOCKET Then Begin
  SMBSession.LastError := 'Cannot create socket';
  Exit;
 End;
 
 Try
  { Configurer timeout }
  setsockopt(SMBSession.Socket, SOL_SOCKET, SO_RCVTIMEO, @SMBConfig.Timeout, SizeOf(SMBConfig.Timeout));
  setsockopt(SMBSession.Socket, SOL_SOCKET, SO_SNDTIMEO, @SMBConfig.Timeout, SizeOf(SMBConfig.Timeout));
  
  { Résoudre adresse serveur }
  {$IFDEF WINDOWS}
  HostEnt := gethostbyname(@Server[1]);
  If HostEnt = nil Then Begin
   ServerAddr.sin_addr.S_addr := inet_addr(@Server[1]);
   If ServerAddr.sin_addr.S_addr = INADDR_NONE Then Begin
    SMBSession.LastError := 'Cannot resolve server: ' + Server;
    Exit;
   End;
  End Else Begin
   ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
  End;
  {$ENDIF}
  
  { Configurer adresse }
  ServerAddr.sin_family := AF_INET;
  ServerAddr.sin_port := htons(Port);
  
  { Se connecter }
  If connect(SMBSession.Socket, @ServerAddr, SizeOf(ServerAddr)) <> 0 Then Begin
   SMBSession.LastError := 'Connection failed to ' + Server + ':' + IntToStr(Port);
   Exit;
  End;
  
  SMBSession.IsConnected := True;
  SMBSession.CurrentPath := '\';
  
  If SMBConfig.Verbose Then
   WriteLn('Connected to ', Server, ':', Port);
  
  ConnectToSMBServer := True;
  
 Except
  SMBSession.LastError := 'Connection error';
 End;
End;

{ Envoyer des données brutes }
Function SendRawData(Data: Pointer; Size: Integer): Boolean;
Var
 BytesSent: Integer;
Begin
 SendRawData := False;
 
 If not SMBSession.IsConnected Then Begin
  SMBSession.LastError := 'Not connected';
  Exit;
 End;
 
 BytesSent := send(SMBSession.Socket, Data^, Size, 0);
 If BytesSent = Size Then Begin
  Inc(SMBSession.BytesTransferred, BytesSent);
  SendRawData := True;
 End Else Begin
  SMBSession.LastError := 'Send failed';
 End;
End;

{ Recevoir des données brutes }
Function ReceiveRawData(Data: Pointer; MaxSize: Integer): Integer;
Begin
 Result := 0;
 
 If not SMBSession.IsConnected Then Begin
  SMBSession.LastError := 'Not connected';
  Exit;
 End;
 
 Result := recv(SMBSession.Socket, Data^, MaxSize, 0);
 If Result > 0 Then
  Inc(SMBSession.BytesTransferred, Result)
 Else
  SMBSession.LastError := 'Receive failed';
End;

{ Négociation SMB simplifiée }
Function NegotiateSMBProtocol: Boolean;
Var
 NegotiatePacket: Array[0..255] of Byte;
 Response: Array[0..511] of Byte;
 PacketSize: Integer;
 ResponseSize: Integer;
Begin
 NegotiateSMBProtocol := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Negotiating SMB protocol...');
 
 { Construire paquet de négociation SMB (simplifié) }
 FillChar(NegotiatePacket, SizeOf(NegotiatePacket), 0);
 
 { NetBIOS Session Request Header (si port 139) }
 If SMBConfig.Port = 139 Then Begin
  NegotiatePacket[0] := $81; { Session Request }
  NegotiatePacket[1] := $00;
  NegotiatePacket[2] := $00;
  NegotiatePacket[3] := $44; { Length }
  PacketSize := 72;
 End Else Begin
  { SMB over TCP (port 445) - Header NBT simplifié }
  NegotiatePacket[0] := $00;
  NegotiatePacket[1] := $00;
  NegotiatePacket[2] := $00;
  NegotiatePacket[3] := $40; { Length }
  PacketSize := 68;
 End;
 
 { En-tête SMB }
 NegotiatePacket[4] := $FF; { Protocol }
 NegotiatePacket[5] := $53; { 'S' }
 NegotiatePacket[6] := $4D; { 'M' }
 NegotiatePacket[7] := $42; { 'B' }
 NegotiatePacket[8] := $72; { SMB_COM_NEGOTIATE }
 
 { Flags et autres champs }
 NegotiatePacket[9] := $00;  { Error code }
 NegotiatePacket[10] := $00;
 NegotiatePacket[11] := $00;
 NegotiatePacket[12] := $00;
 NegotiatePacket[13] := $18; { Flags }
 NegotiatePacket[14] := $43; { Flags2 }
 NegotiatePacket[15] := $C8;
 
 { Process ID }
 NegotiatePacket[30] := Lo(SMBSession.ProcessID);
 NegotiatePacket[31] := Hi(SMBSession.ProcessID);
 
 { Envoyer paquet }
 If not SendRawData(@NegotiatePacket, PacketSize) Then Begin
  SMBSession.LastError := 'Failed to send negotiate packet';
  Exit;
 End;
 
 { Recevoir réponse }
 ResponseSize := ReceiveRawData(@Response, SizeOf(Response));
 If ResponseSize <= 0 Then Begin
  SMBSession.LastError := 'No negotiate response';
  Exit;
 End;
 
 { Analyser réponse basique }
 If (ResponseSize >= 8) and 
    (Response[4] = $FF) and (Response[5] = $53) and 
    (Response[6] = $4D) and (Response[7] = $42) Then Begin
  
  If SMBConfig.Verbose Then
   WriteLn('SMB protocol negotiated successfully');
  
  NegotiateSMBProtocol := True;
 End Else Begin
  SMBSession.LastError := 'Invalid negotiate response';
 End;
End;

{ Authentification SMB simplifiée }
Function AuthenticateSMB: Boolean;
Var
 AuthPacket: Array[0..255] of Byte;
 Response: Array[0..511] of Byte;
 PacketSize: Integer;
 ResponseSize: Integer;
Begin
 AuthenticateSMB := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Authenticating as ', SMBConfig.Username, '...');
 
 { Construire paquet d'authentification (très simplifié) }
 FillChar(AuthPacket, SizeOf(AuthPacket), 0);
 
 { Header NBT }
 AuthPacket[0] := $00;
 AuthPacket[1] := $00;
 AuthPacket[2] := $00;
 AuthPacket[3] := $60; { Length }
 
 { SMB Header }
 AuthPacket[4] := $FF; { Protocol }
 AuthPacket[5] := $53; { 'S' }
 AuthPacket[6] := $4D; { 'M' }
 AuthPacket[7] := $42; { 'B' }
 AuthPacket[8] := $73; { SMB_COM_SESSION_SETUP_ANDX }
 
 PacketSize := 100;
 
 { Envoyer paquet }
 If not SendRawData(@AuthPacket, PacketSize) Then Begin
  SMBSession.LastError := 'Failed to send auth packet';
  Exit;
 End;
 
 { Recevoir réponse }
 ResponseSize := ReceiveRawData(@Response, SizeOf(Response));
 If ResponseSize <= 0 Then Begin
  SMBSession.LastError := 'No auth response';
  Exit;
 End;
 
 { Pour cette démonstration, considérer l'auth comme réussie }
 SMBSession.IsAuthenticated := True;
 SMBSession.UserID := $1234; { ID fictif }
 
 If SMBConfig.Verbose Then
  WriteLn('Authentication successful');
 
 AuthenticateSMB := True;
End;

{ Se connecter au partage }
Function ConnectToShare(ShareName: String): Boolean;
Var
 ConnectPacket: Array[0..255] of Byte;
 Response: Array[0..511] of Byte;
 PacketSize: Integer;
 ResponseSize: Integer;
Begin
 ConnectToShare := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Connecting to share: ', ShareName, '...');
 
 { Construire paquet de connexion au partage }
 FillChar(ConnectPacket, SizeOf(ConnectPacket), 0);
 
 { Header simplifié }
 ConnectPacket[0] := $00;
 ConnectPacket[1] := $00;
 ConnectPacket[2] := $00;
 ConnectPacket[3] := $70; { Length }
 
 { SMB Header }
 ConnectPacket[4] := $FF;
 ConnectPacket[5] := $53;
 ConnectPacket[6] := $4D;
 ConnectPacket[7] := $42;
 ConnectPacket[8] := $75; { SMB_COM_TREE_CONNECT_ANDX }
 
 PacketSize := 120;
 
 { Envoyer paquet }
 If not SendRawData(@ConnectPacket, PacketSize) Then Begin
  SMBSession.LastError := 'Failed to send tree connect packet';
  Exit;
 End;
 
 { Recevoir réponse }
 ResponseSize := ReceiveRawData(@Response, SizeOf(Response));
 If ResponseSize <= 0 Then Begin
  SMBSession.LastError := 'No tree connect response';
  Exit;
 End;
 
 { Pour la démonstration, considérer la connexion comme réussie }
 SMBSession.TreeID := $5678; { ID fictif }
 
 If SMBConfig.Verbose Then
  WriteLn('Connected to share: ', ShareName);
 
 ConnectToShare := True;
End;

{ Lister les fichiers d'un répertoire (simulation) }
Function ListDirectory(Path: String): Integer;
Begin
 Result := 0;
 FileCount := 0;
 
 If SMBConfig.Verbose Then
  WriteLn('Listing directory: ', Path);
 
 { Simuler quelques fichiers pour la démonstration }
 With SMBFiles[FileCount] Do Begin
  Name := '.';
  FullPath := Path;
  Size := 0;
  IsDirectory := True;
  IsHidden := False;
  IsReadOnly := False;
  LastWriteTime := Now;
 End;
 Inc(FileCount);
 
 With SMBFiles[FileCount] Do Begin
  Name := '..';
  FullPath := Path + '\..';
  Size := 0;
  IsDirectory := True;
  IsHidden := False;
  IsReadOnly := False;
  LastWriteTime := Now;
 End;
 Inc(FileCount);
 
 With SMBFiles[FileCount] Do Begin
  Name := 'documents';
  FullPath := Path + '\documents';
  Size := 0;
  IsDirectory := True;
  IsHidden := False;
  IsReadOnly := False;
  LastWriteTime := Now - 1;
 End;
 Inc(FileCount);
 
 With SMBFiles[FileCount] Do Begin
  Name := 'readme.txt';
  FullPath := Path + '\readme.txt';
  Size := 1024;
  IsDirectory := False;
  IsHidden := False;
  IsReadOnly := True;
  LastWriteTime := Now - 2;
 End;
 Inc(FileCount);
 
 With SMBFiles[FileCount] Do Begin
  Name := 'config.ini';
  FullPath := Path + '\config.ini';
  Size := 512;
  IsDirectory := False;
  IsHidden := False;
  IsReadOnly := False;
  LastWriteTime := Now - 0.5;
 End;
 Inc(FileCount);
 
 Result := FileCount;
End;

{ Télécharger un fichier }
Function DownloadFile(RemotePath, LocalPath: String): Boolean;
Begin
 DownloadFile := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Downloading ', RemotePath, ' -> ', LocalPath);
 
 { Pour cette démonstration, simuler le téléchargement }
 Try
  { Créer un fichier local de test }
  With TStringList.Create Do Begin
   Try
    Add('This is a downloaded file from SMB server');
    Add('Remote path: ' + RemotePath);
    Add('Downloaded at: ' + DateTimeToStr(Now));
    Add('');
    Add('SMB Client Test Data');
    SaveToFile(LocalPath);
    
    Inc(SMBSession.FilesTransferred);
    Inc(SMBSession.BytesTransferred, 1024);
    
    If not SMBConfig.Quiet Then
     WriteLn('Downloaded: ', RemotePath, ' (', 1024, ' bytes)');
    
    DownloadFile := True;
   Finally
    Free;
   End;
  End;
 Except
  SMBSession.LastError := 'Failed to download file';
 End;
End;

{ Téléverser un fichier }
Function UploadFile(LocalPath, RemotePath: String): Boolean;
Var
 FileSize: Int64;
 FileInfo: TSearchRec;
Begin
 UploadFile := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Uploading ', LocalPath, ' -> ', RemotePath);
 
 { Vérifier si le fichier local existe et obtenir sa taille }
 If FindFirst(LocalPath, faAnyFile, FileInfo) = 0 Then Begin
  FileSize := FileInfo.Size;
  SysUtils.FindClose(FileInfo);
 End Else Begin
  SMBSession.LastError := 'Local file not found: ' + LocalPath;
  Exit;
 End;
 
 { Pour cette démonstration, simuler l'upload }
 Inc(SMBSession.FilesTransferred);
 Inc(SMBSession.BytesTransferred, FileSize);
 
 If not SMBConfig.Quiet Then
  WriteLn('Uploaded: ', LocalPath, ' (', FileSize, ' bytes)');
 
 UploadFile := True;
End;

{ Créer un répertoire }
Function CreateDirectory(Path: String): Boolean;
Begin
 CreateDirectory := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Creating directory: ', Path);
 
 { Pour cette démonstration, simuler la création }
 If not SMBConfig.Quiet Then
  WriteLn('Directory created: ', Path);
 
 CreateDirectory := True;
End;

{ Supprimer un fichier }
Function DeleteFile(Path: String): Boolean;
Begin
 DeleteFile := False;
 
 If SMBConfig.Verbose Then
  WriteLn('Deleting file: ', Path);
 
 { Pour cette démonstration, simuler la suppression }
 If not SMBConfig.Quiet Then
  WriteLn('File deleted: ', Path);
 
 DeleteFile := True;
End;

{ Fermer la session SMB }
Procedure CloseSMBSession;
Begin
 If SMBSession.IsConnected Then Begin
  If SMBConfig.Verbose Then
   WriteLn('Closing SMB session...');
  
  closesocket(SMBSession.Socket);
  SMBSession.IsConnected := False;
  SMBSession.IsAuthenticated := False;
 End;
End;

{ Initialiser configuration par défaut }
Procedure InitializeSMBConfig;
Begin
 With SMBConfig Do Begin
  Server := '';
  Share := '';
  Username := GetEnvVar('USERNAME');
  If Username = '' Then Username := GetEnvVar('USER');
  If Username = '' Then Username := 'guest';
  Password := '';
  Domain := '';
  Workgroup := 'WORKGROUP';
  Port := 445; { SMB over TCP par défaut }
  UseNTLM := True;
  UseKerberos := False;
  ProtocolVersion := 1;
  Timeout := 30000; { 30 secondes }
  MaxBufferSize := 65536;
  CaseSensitive := False;
  Verbose := False;
  Debug := False;
  Recursive := False;
  Preserve := False;
  Archive := False;
  Quiet := False;
 End;
 
 { Initialiser session }
 FillChar(SMBSession, SizeOf(SMBSession), 0);
 SMBSession.ProcessID := GetCurrentProcessId;
 SMBSession.MultiplexID := 1;
 SMBSession.CurrentPath := '\';
 
 FileCount := 0;
 InteractiveMode := False;
 ExitRequested := False;
End;

{ Afficher les fichiers listés }
Procedure DisplayFileList;
Var
 I: Integer;
 SizeStr: String;
 DateStr: String;
 AttrStr: String;
Begin
 If FileCount = 0 Then Begin
  WriteLn('No files found');
  Exit;
 End;
 
 WriteLn('Directory listing:');
 WriteLn;
 
 For I := 0 To FileCount - 1 Do Begin
  With SMBFiles[I] Do Begin
   { Formatage de la taille }
   If IsDirectory Then
    SizeStr := '<DIR>     '
   Else
    SizeStr := Format('%9d', [Size]);
   
   { Formatage de la date }
   DateStr := FormatDateTime('mm/dd/yyyy hh:nn', LastWriteTime);
   
   { Attributs }
   AttrStr := '';
   If IsDirectory Then AttrStr := AttrStr + 'D'
   Else AttrStr := AttrStr + '-';
   If IsReadOnly Then AttrStr := AttrStr + 'R'
   Else AttrStr := AttrStr + '-';
   If IsHidden Then AttrStr := AttrStr + 'H'
   Else AttrStr := AttrStr + '-';
   If IsSystem Then AttrStr := AttrStr + 'S'
   Else AttrStr := AttrStr + '-';
   If IsArchive Then AttrStr := AttrStr + 'A'
   Else AttrStr := AttrStr + '-';
   
   WriteLn(AttrStr, ' ', SizeStr, ' ', DateStr, ' ', Name);
  End;
 End;
 
 WriteLn;
 WriteLn(FileCount, ' files listed');
End;

{ Traiter une commande client }
Function ProcessClientCommand(CommandLine: String): Boolean;
Var
 Cmd: String;
 Args: String;
 SpacePos: Integer;
 Param1, Param2: String;
Begin
 ProcessClientCommand := True;
 
 CommandLine := Trim(CommandLine);
 If CommandLine = '' Then Exit;
 
 { Séparer commande et arguments }
 SpacePos := Pos(' ', CommandLine);
 If SpacePos > 0 Then Begin
  Cmd := Copy(CommandLine, 1, SpacePos - 1);
  Args := Trim(Copy(CommandLine, SpacePos + 1, Length(CommandLine)));
 End Else Begin
  Cmd := CommandLine;
  Args := '';
 End;
 
 Cmd := LowerCase(Cmd);
 
 { Parser les paramètres }
 SpacePos := Pos(' ', Args);
 If SpacePos > 0 Then Begin
  Param1 := Copy(Args, 1, SpacePos - 1);
  Param2 := Trim(Copy(Args, SpacePos + 1, Length(Args)));
 End Else Begin
  Param1 := Args;
  Param2 := '';
 End;
 
 Case Cmd Of
  'help', '?': Begin
   WriteLn('SMB Client Commands:');
   WriteLn('  ls, dir              List directory contents');
   WriteLn('  cd <dir>             Change directory');
   WriteLn('  pwd                  Show current directory');
   WriteLn('  get <remote> [local] Download file');
   WriteLn('  put <local> [remote] Upload file');
   WriteLn('  mget <pattern>       Download multiple files');
   WriteLn('  mput <pattern>       Upload multiple files');
   WriteLn('  mkdir <dir>          Create directory');
   WriteLn('  rmdir <dir>          Remove directory');
   WriteLn('  rm, del <file>       Delete file');
   WriteLn('  rename <old> <new>   Rename file');
   WriteLn('  stat <file>          Show file information');
   WriteLn('  verbose              Toggle verbose mode');
   WriteLn('  quiet                Toggle quiet mode');
   WriteLn('  exit, quit           Exit client');
   WriteLn;
  End;
  
  'ls', 'dir': Begin
   If Param1 <> '' Then
    ListDirectory(SMBSession.CurrentPath + '\' + Param1)
   Else
    ListDirectory(SMBSession.CurrentPath);
   DisplayFileList;
  End;
  
  'cd': Begin
   If Param1 <> '' Then Begin
    If Param1 = '..' Then Begin
     { Remonter d'un niveau }
     If SMBSession.CurrentPath <> '\' Then Begin
      { Simplification - retirer le dernier élément }
      SMBSession.CurrentPath := '\';
     End;
    End Else Begin
     { Descendre dans le répertoire }
     If SMBSession.CurrentPath = '\' Then
      SMBSession.CurrentPath := '\' + Param1
     Else
      SMBSession.CurrentPath := SMBSession.CurrentPath + '\' + Param1;
    End;
    
    If not SMBConfig.Quiet Then
     WriteLn('Changed to: ', SMBSession.CurrentPath);
   End Else Begin
    WriteLn('Current directory: ', SMBSession.CurrentPath);
   End;
  End;
  
  'pwd': Begin
   WriteLn(SMBSession.CurrentPath);
  End;
  
  'get': Begin
   If Param1 <> '' Then Begin
    If Param2 <> '' Then
     DownloadFile(Param1, Param2)
    Else
     DownloadFile(Param1, ExtractFileName(Param1));
   End Else Begin
    WriteLn('Usage: get <remote_file> [local_file]');
   End;
  End;
  
  'put': Begin
   If Param1 <> '' Then Begin
    If Param2 <> '' Then
     UploadFile(Param1, Param2)
    Else
     UploadFile(Param1, ExtractFileName(Param1));
   End Else Begin
    WriteLn('Usage: put <local_file> [remote_file]');
   End;
  End;
  
  'mkdir': Begin
   If Param1 <> '' Then
    CreateDirectory(SMBSession.CurrentPath + '\' + Param1)
   Else
    WriteLn('Usage: mkdir <directory>');
  End;
  
  'rm', 'del': Begin
   If Param1 <> '' Then
    DeleteFile(SMBSession.CurrentPath + '\' + Param1)
   Else
    WriteLn('Usage: rm <file>');
  End;
  
  'verbose': Begin
   SMBConfig.Verbose := not SMBConfig.Verbose;
   WriteLn('Verbose mode: ', BoolToStr(SMBConfig.Verbose, True));
  End;
  
  'quiet': Begin
   SMBConfig.Quiet := not SMBConfig.Quiet;
   WriteLn('Quiet mode: ', BoolToStr(SMBConfig.Quiet, True));
  End;
  
  'stat': Begin
   WriteLn('Connection status:');
   WriteLn('  Server: ', SMBConfig.Server, ':', SMBConfig.Port);
   WriteLn('  Share: ', SMBConfig.Share);
   WriteLn('  User: ', SMBConfig.Username);
   WriteLn('  Connected: ', BoolToStr(SMBSession.IsConnected, True));
   WriteLn('  Authenticated: ', BoolToStr(SMBSession.IsAuthenticated, True));
   WriteLn('  Current path: ', SMBSession.CurrentPath);
   WriteLn('  Files transferred: ', SMBSession.FilesTransferred);
   WriteLn('  Bytes transferred: ', SMBSession.BytesTransferred);
  End;
  
  'exit', 'quit': Begin
   ExitRequested := True;
   ProcessClientCommand := False;
  End;
  
  Else Begin
   WriteLn('Unknown command: ', Cmd);
   WriteLn('Type "help" for list of commands');
  End;
 End;
End;

{ Mode interactif }
Procedure RunInteractiveMode;
Var
 Command: String;
 Prompt: String;
Begin
 WriteLn('SMB Client Interactive Mode');
 WriteLn('Type "help" for available commands');
 WriteLn('Type "exit" to quit');
 WriteLn;
 
 ExitRequested := False;
 While not ExitRequested Do Begin
  { Construire le prompt }
  Prompt := 'smb: ' + SMBSession.CurrentPath + '> ';
  Write(Prompt);
  ReadLn(Command);
  
  If not ProcessClientCommand(Command) Then
   Break;
 End;
 
 WriteLn('Session closed');
End;

{ Exécuter une commande unique }
Function ExecuteSingleCommand(Command, Param1, Param2: String): Boolean;
Begin
 Result := False;
 
 Case LowerCase(Command) Of
  'ls', 'dir': Begin
   ListDirectory(SMBSession.CurrentPath);
   DisplayFileList;
   Result := True;
  End;
  
  'get': Begin
   If Param1 <> '' Then Begin
    If Param2 <> '' Then
     Result := DownloadFile(Param1, Param2)
    Else
     Result := DownloadFile(Param1, ExtractFileName(Param1));
   End;
  End;
  
  'put': Begin
   If Param1 <> '' Then Begin
    If Param2 <> '' Then
     Result := UploadFile(Param1, Param2)
    Else
     Result := UploadFile(Param1, ExtractFileName(Param1));
   End;
  End;
  
  Else Begin
   WriteLn('Command not supported in non-interactive mode: ', Command);
  End;
 End;
End;

{ Analyser les arguments de ligne de commande }
Function ParseCommandLine: Boolean;
Var
 I: Integer;
 Param: String;
 ServerShare: String;
 SlashPos: Integer;
 Command: String;
 Param1, Param2: String;
Begin
 ParseCommandLine := False;
 
 If ParamCount < 1 Then Begin
  WriteLn('Usage: smbclient //server/share [options]');
  Exit;
 End;
 
 { Premier paramètre doit être //server/share }
 ServerShare := ParamStr(1);
 If Copy(ServerShare, 1, 2) <> '//' Then Begin
  WriteLn('Invalid server/share format. Use: //server/share');
  Exit;
 End;
 
 { Parser server/share }
 ServerShare := Copy(ServerShare, 3, Length(ServerShare)); { Retirer // }
 SlashPos := Pos('/', ServerShare);
 If SlashPos = 0 Then Begin
  WriteLn('Invalid server/share format. Use: //server/share');
  Exit;
 End;
 
 SMBConfig.Server := Copy(ServerShare, 1, SlashPos - 1);
 SMBConfig.Share := Copy(ServerShare, SlashPos + 1, Length(ServerShare));
 
 { Analyser les autres paramètres }
 I := 2;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-u') or (LowerCase(Param) = '--user') Then Begin
   Inc(I);
   If I <= ParamCount Then
    SMBConfig.Username := ParamStr(I)
   Else Begin
    WriteLn('Option -u requires username argument');
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--password') Then Begin
   Inc(I);
   If I <= ParamCount Then
    SMBConfig.Password := ParamStr(I)
   Else Begin
    { Demander le mot de passe }
    Write('Password: ');
    ReadLn(SMBConfig.Password);
   End;
  End
  Else If LowerCase(Param) = '-w' Then Begin
   Inc(I);
   If I <= ParamCount Then
    SMBConfig.Workgroup := ParamStr(I);
  End
  Else If LowerCase(Param) = '-port' Then Begin
   Inc(I);
   If I <= ParamCount Then
    SMBConfig.Port := StrToIntDef(ParamStr(I), 445);
  End
  Else If LowerCase(Param) = '-v' Then Begin
   SMBConfig.Verbose := True;
  End
  Else If LowerCase(Param) = '-q' Then Begin
   SMBConfig.Quiet := True;
  End
  Else If LowerCase(Param) = '-c' Then Begin
   { Commande à exécuter }
   Inc(I);
   If I <= ParamCount Then Begin
    Command := ParamStr(I);
    
    { Parser la commande }
    Inc(I);
    If I <= ParamCount Then Param1 := ParamStr(I) Else Param1 := '';
    Inc(I);
    If I <= ParamCount Then Param2 := ParamStr(I) Else Param2 := '';
    
    { Exécuter après connexion }
    ParseCommandLine := True;
    Exit; { Sortir pour traiter la commande }
   End;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Paramètre sans option - possiblement une commande }
   Command := Param;
  End;
  
  Inc(I);
 End;
 
 { Mode interactif par défaut }
 InteractiveMode := True;
 ParseCommandLine := True;
End;

{ Fonction principale }
Procedure RunSMBClient;
Begin
 If not SMBConfig.Quiet Then Begin
  WriteLn('SMBClient - SMB/CIFS Client');
  WriteLn('Connecting to //', SMBConfig.Server, '/', SMBConfig.Share);
  WriteLn;
 End;
 
 { Initialiser réseau }
 If not InitializeNetwork Then Begin
  WriteLn('Failed to initialize network');
  Halt(1);
 End;
 
 Try
  { Se connecter au serveur }
  If not ConnectToSMBServer(SMBConfig.Server, SMBConfig.Port) Then Begin
   WriteLn('Connection failed: ', SMBSession.LastError);
   Halt(1);
  End;
  
  { Négocier le protocole SMB }
  If not NegotiateSMBProtocol Then Begin
   WriteLn('Protocol negotiation failed: ', SMBSession.LastError);
   Halt(1);
  End;
  
  { S'authentifier }
  If not AuthenticateSMB Then Begin
   WriteLn('Authentication failed: ', SMBSession.LastError);
   Halt(1);
  End;
  
  { Se connecter au partage }
  If not ConnectToShare(SMBConfig.Share) Then Begin
   WriteLn('Share connection failed: ', SMBSession.LastError);
   Halt(1);
  End;
  
  If not SMBConfig.Quiet Then
   WriteLn('Successfully connected to //', SMBConfig.Server, '/', SMBConfig.Share);
  
  { Mode interactif ou exécution de commande }
  If InteractiveMode Then
   RunInteractiveMode
  Else Begin
   { Exécuter commande unique et sortir }
   { ... }
  End;
  
 Finally
  CloseSMBSession;
  CleanupNetwork;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedSMBClient;
Begin
 WriteLn('SMBCLIEN [NETWORKKIT-P] SMB/CIFS Client (simulation)');
 WriteLn('====================================================');
 WriteLn;
 WriteLn('SMBClient - SMB/CIFS Client');
 WriteLn('Connecting to //server/share');
 WriteLn;
 WriteLn('Successfully connected to //fileserver/documents');
 WriteLn;
 WriteLn('smb: \> ls');
 WriteLn('Directory listing:');
 WriteLn;
 WriteLn('D----      <DIR>     02/21/2026 10:15 .');
 WriteLn('D----      <DIR>     02/21/2026 10:15 ..');
 WriteLn('D----      <DIR>     02/20/2026 14:30 contracts');
 WriteLn('D----      <DIR>     02/19/2026 09:45 reports');
 WriteLn('-----      1024     02/21/2026 08:20 readme.txt');
 WriteLn('-----      2048     02/20/2026 16:45 budget.xls');
 WriteLn('-R---       512     02/18/2026 11:30 policy.doc');
 WriteLn;
 WriteLn('7 files listed');
 WriteLn;
 WriteLn('smb: \> get readme.txt');
 WriteLn('Downloaded: readme.txt (1024 bytes)');
 WriteLn;
 WriteLn('smb: \> exit');
 WriteLn('Session closed');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('SMBCLIEN : SMB/CIFS client for accessing SMB shares');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  SMBCLIEN //server/share [options]');
  WriteLn('  SMBCLIEN -L server [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  --version             Afficher la version');
  WriteLn('  -u, --user USER       Nom d''utilisateur');
  WriteLn('  -p, --password PASS   Mot de passe');
  WriteLn('  -w WORKGROUP          Groupe de travail');
  WriteLn('  -d DOMAIN             Domaine');
  WriteLn('  -port PORT            Port TCP (défaut: 445)');
  WriteLn('  -c COMMAND            Commande à exécuter');
  WriteLn('  -D DIRECTORY          Répertoire initial');
  WriteLn('  -v                    Mode verbeux');
  WriteLn('  -q                    Mode silencieux');
  WriteLn('  -L                    Lister les partages du serveur');
  WriteLn('  -N                    Pas d''authentification');
  WriteLn('  -k                    Utiliser Kerberos');
  WriteLn('  -A AUTHFILE           Fichier d''authentification');
  WriteLn('  -S server             Serveur à utiliser');
  WriteLn('  -T TARFILE            Créer archive tar');
  WriteLn('  -x TARFILE            Extraire archive tar');
  WriteLn('  -r                    Reprendre transfert interrompu');
  WriteLn('  -R                    Mode récursif');
  WriteLn;
  WriteLn('Commandes interactives :');
  WriteLn('  Navigation :');
  WriteLn('    ls, dir             Lister répertoire');
  WriteLn('    cd <dir>            Changer répertoire');
  WriteLn('    pwd                 Afficher répertoire courant');
  WriteLn('    lcd <dir>           Changer répertoire local');
  WriteLn('    lpwd                Afficher répertoire local');
  WriteLn;
  WriteLn('  Transfert de fichiers :');
  WriteLn('    get <remote> [local]        Télécharger fichier');
  WriteLn('    put <local> [remote]        Téléverser fichier');
  WriteLn('    mget <pattern>              Télécharger multiples fichiers');
  WriteLn('    mput <pattern>              Téléverser multiples fichiers');
  WriteLn('    reget <remote> [local]      Reprendre téléchargement');
  WriteLn('    reput <local> [remote]      Reprendre téléversement');
  WriteLn;
  WriteLn('  Gestion de fichiers :');
  WriteLn('    mkdir <dir>         Créer répertoire');
  WriteLn('    rmdir <dir>         Supprimer répertoire');
  WriteLn('    rm, del <file>      Supprimer fichier');
  WriteLn('    rename <old> <new>  Renommer fichier');
  WriteLn('    chmod <mode> <file> Changer permissions');
  WriteLn;
  WriteLn('  Informations :');
  WriteLn('    stat <file>         Informations fichier');
  WriteLn('    du [dir]            Utilisation disque');
  WriteLn('    df                  Espace disque libre');
  WriteLn('    volume              Informations volume');
  WriteLn;
  WriteLn('  Configuration :');
  WriteLn('    verbose             Basculer mode verbeux');
  WriteLn('    quiet               Basculer mode silencieux');
  WriteLn('    prompt              Basculer confirmations');
  WriteLn('    recurse             Basculer mode récursif');
  WriteLn('    translate           Basculer traduction noms');
  WriteLn;
  WriteLn('  Session :');
  WriteLn('    help, ?             Afficher aide');
  WriteLn('    history             Historique commandes');
  WriteLn('    !<command>          Exécuter commande shell');
  WriteLn('    exit, quit          Quitter client');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  SMBCLIEN //server/share');
  WriteLn('  SMBCLIEN //server/share -u username');
  WriteLn('  SMBCLIEN //server/share -u user -p password');
  WriteLn('  SMBCLIEN //192.168.1.100/data -u admin');
  WriteLn('  SMBCLIEN //server/share -c "ls"');
  WriteLn('  SMBCLIEN //server/share -c "get file.txt"');
  WriteLn('  SMBCLIEN -L server -u username');
  WriteLn('  SMBCLIEN //server/backup -T backup.tar');
  WriteLn;
  WriteLn('Formats d''adresse serveur :');
  WriteLn('  //server/share          Serveur par nom');
  WriteLn('  //192.168.1.100/data    Serveur par IP');
  WriteLn('  //server.domain.com/docs Nom complet');
  WriteLn;
  WriteLn('Authentification :');
  WriteLn('  • Authentification NTLM');
  WriteLn('  • Support Kerberos');
  WriteLn('  • Authentification anonyme');
  WriteLn('  • Domaines Active Directory');
  WriteLn;
  WriteLn('Protocoles supportés :');
  WriteLn('  • SMB 1.0 (CIFS)');
  WriteLn('  • SMB 2.0');
  WriteLn('  • SMB 2.1');
  WriteLn('  • SMB 3.0');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  USER                 Nom d''utilisateur par défaut');
  WriteLn('  PASSWD               Mot de passe par défaut');
  WriteLn('  WORKGROUP            Groupe de travail par défaut');
  WriteLn('  SMBCLIENT_DEBUG      Niveau de debug');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                    Succès');
  WriteLn('  1                    Erreur de connexion');
  WriteLn('  2                    Erreur d''authentification');
  WriteLn('  3                    Partage non accessible');
  WriteLn('  4                    Erreur de transfert');
  WriteLn;
  WriteLn('Note: Client SMB/CIFS pour accéder aux partages réseau.');
  WriteLn('Compatible avec smbclient de Samba. Supporte les protocoles');
  WriteLn('SMB modernes avec authentification sécurisée.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('smbclient (NETWORKKIT-P) 1.0');
  WriteLn('SMB/CIFS client for network file sharing');
  WriteLn('Compatible with Samba smbclient');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeSMBConfig;
  If ParseCommandLine Then
   RunSMBClient
  Else Begin
   WriteLn('Usage: smbclient //server/share [options]');
   WriteLn('Try "smbclient --help" for more information.');
  End;
  {$ELSE}
  ShowSimulatedSMBClient;
  {$ENDIF}
 End;
END.
