{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande inews (NNTP news posting))
}

Program INEWS;

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
 { Configuration inews }
 TInewsConfig = Record
  NNTPServer: String[255];      { Serveur NNTP }
  Port: Word;                   { Port NNTP (défaut: 119) }
  Username: String[64];         { Nom d'utilisateur }
  Password: String[255];        { Mot de passe }
  FromAddress: String[255];     { Adresse expéditeur }
  Organization: String[255];    { Organisation }
  ReplyTo: String[255];         { Adresse de réponse }
  Subject: String[255];         { Sujet de l'article }
  Newsgroups: String[255];      { Groupes de nouvelles }
  FollowupTo: String[255];      { Suivi vers groupes }
  References: String[255];          { Références d'articles }
  MessageID: String[255];       { ID de message }
  Distribution: String[64];     { Distribution géographique }
  Keywords: String[255];        { Mots-clés }
  Summary: String[255];         { Résumé }
  Expires: String[64];          { Date d'expiration }
  Supersedes: String[255];      { Article remplacé }
  Control: String[255];         { Message de contrôle }
  Approved: String[255];        { Approuvé par }
  Path: String[255];                { Chemin de distribution }
  XNewsreader: String[128];     { Client de nouvelles }
  InputFile: String[255];       { Fichier d'entrée }
  HeaderFile: String[255];      { Fichier d'en-têtes }
  Signature: String[255];       { Fichier signature }
  Encoding: String[32];         { Encodage (UTF-8, ISO-8859-1) }
  UseSSL: Boolean;              { Utiliser SSL/TLS }
  Debug: Boolean;               { Mode debug }
  Verbose: Boolean;             { Mode verbeux }
  DryRun: Boolean;              { Test sans envoi }
  ForcePost: Boolean;           { Forcer l'envoi }
  ModeratedPost: Boolean;       { Post vers groupe modéré }
  Timeout: Integer;             { Timeout connexion }
 End;

 { Session NNTP }
 TNNTPSession = Record
  Socket: TSocket;              { Socket de connexion }
  IsConnected: Boolean;         { Connexion établie }
  IsAuthenticated: Boolean;     { Authentifié }
  ServerCapabilities: String[255];  { Capacités du serveur }
  LastResponse: String[255];        { Dernière réponse }
  LastCode: Integer;            { Dernier code de réponse }
  PostingAllowed: Boolean;      { Post autorisé }
  AuthMethod: String[32];       { Méthode d'authentification }
  BytesSent: Int64;             { Octets envoyés }
  MessagesSent: Integer;        { Messages envoyés }
  LastError: String[255];       { Dernière erreur }
 End;

 { Article de nouvelles }
 TNewsArticle = Record
  Headers: TStringList;             { En-têtes de l'article }
  Body: TStringList;                { Corps de l'article }
  MessageID: String[255];       { ID généré }
  Size: Integer;                { Taille totale }
  Lines: Integer;               { Nombre de lignes }
  IsValid: Boolean;             { Article valide }
  HasSignature: Boolean;        { Contient une signature }
 End;

Var
 { Variables globales }
 InewsConfig: TInewsConfig;
 NNTPSession: TNNTPSession;
 NewsArticle: TNewsArticle;

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

{ Générer un Message-ID unique }
Function GenerateMessageID: String;
Var
 Hostname: String;
 Timestamp: String;
 Random: String;
Begin
 Hostname := GetEnvVar('COMPUTERNAME');
 If Hostname = '' Then Hostname := GetEnvVar('HOSTNAME');
 If Hostname = '' Then Hostname := 'localhost';
 
 Timestamp := IntToStr(Trunc((Now - EncodeDate(1970, 1, 1)) * 86400));
 Random := IntToStr(System.Random(99999));
 
 Result := '<' + Timestamp + '.' + Random + '@' + Hostname + '>';
End;

{ Formater date RFC 2822 }
Function FormatRFC2822Date(DateTime: TDateTime): String;
Const
 DayNames: Array[1..7] of String = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
 MonthNames: Array[1..12] of String = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
Var
 Year, Month, Day: Word;
 Hour, Min, Sec, MSec: Word;
 DayOfWeek: Integer;
Begin
 DecodeDate(DateTime, Year, Month, Day);
 DecodeTime(DateTime, Hour, Min, Sec, MSec);
 DayOfWeek := DayOfTheWeek(DateTime);
 
 Result := Format('%s, %d %s %d %02d:%02d:%02d +0000',
                  [DayNames[DayOfWeek], Day, MonthNames[Month], Year, Hour, Min, Sec]);
End;

{ Valider adresse email }
Function IsValidEmail(Email: String): Boolean;
Var
 AtPos: Integer;
Begin
 Result := False;
 Email := Trim(Email);
 
 If Length(Email) < 5 Then Exit; { Minimum: a@b.c }
 
 AtPos := Pos('@', Email);
 If (AtPos <= 1) or (AtPos >= Length(Email)) Then Exit;
 
 { Vérifications basiques }
 If (Pos(' ', Email) > 0) or (Pos('..', Email) > 0) Then Exit;
 If (Email[1] = '.') or (Email[Length(Email)] = '.') Then Exit;
 If (Email[1] = '@') or (Email[Length(Email)] = '@') Then Exit;
 
 { Vérifier domaine }
 If Pos('.', Copy(Email, AtPos + 1, Length(Email))) = 0 Then Exit;
 
 Result := True;
End;

{ Nettoyer nom de groupe }
Function CleanNewsgroup(Newsgroup: String): String;
Var
 I: Integer;
Begin
 Result := LowerCase(Trim(Newsgroup));
 
 { Remplacer caractères invalides }
 For I := 1 To Length(Result) Do Begin
  If not (Result[I] in ['a'..'z', '0'..'9', '.', '-']) Then
   Result[I] := '.';
 End;
 
 { Supprimer points multiples }
 While Pos('..', Result) > 0 Do
  Result := StringReplace(Result, '..', '.', [rfReplaceAll]);
 
 { Supprimer points en début/fin }
 While (Length(Result) > 0) and (Result[1] = '.') Do
  Delete(Result, 1, 1);
 While (Length(Result) > 0) and (Result[Length(Result)] = '.') Do
  Delete(Result, Length(Result), 1);
End;

{ === FONCTIONS NNTP RÉELLES === }

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

{ Se connecter au serveur NNTP }
Function ConnectToNNTPServer: Boolean;
Var
 ServerAddr: TSockAddrIn;
 {$IFDEF WINDOWS}
 HostEnt: PHostEnt;
 {$ENDIF}
Begin
 ConnectToNNTPServer := False;
 
 If InewsConfig.Verbose Then
  WriteLn('Connecting to NNTP server: ', InewsConfig.NNTPServer, ':', InewsConfig.Port);
 
 { Créer socket }
 NNTPSession.Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If NNTPSession.Socket = INVALID_SOCKET Then Begin
  NNTPSession.LastError := 'Cannot create socket';
  Exit;
 End;
 
 Try
  { Configurer timeout }
  setsockopt(NNTPSession.Socket, SOL_SOCKET, SO_RCVTIMEO, @InewsConfig.Timeout, SizeOf(InewsConfig.Timeout));
  setsockopt(NNTPSession.Socket, SOL_SOCKET, SO_SNDTIMEO, @InewsConfig.Timeout, SizeOf(InewsConfig.Timeout));
  
  { Résoudre adresse serveur }
  {$IFDEF WINDOWS}
  HostEnt := gethostbyname(@InewsConfig.NNTPServer[1]);
  If HostEnt = nil Then Begin
   ServerAddr.sin_addr.S_addr := inet_addr(@InewsConfig.NNTPServer[1]);
   If ServerAddr.sin_addr.S_addr = INADDR_NONE Then Begin
    NNTPSession.LastError := 'Cannot resolve server: ' + InewsConfig.NNTPServer;
    Exit;
   End;
  End Else Begin
   ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
  End;
  {$ENDIF}
  
  { Configurer adresse }
  ServerAddr.sin_family := AF_INET;
  ServerAddr.sin_port := htons(InewsConfig.Port);
  
  { Se connecter }
  If connect(NNTPSession.Socket, @ServerAddr, SizeOf(ServerAddr)) <> 0 Then Begin
   NNTPSession.LastError := 'Connection failed to ' + InewsConfig.NNTPServer;
   Exit;
  End;
  
  NNTPSession.IsConnected := True;
  
  If InewsConfig.Verbose Then
   WriteLn('Connected to NNTP server');
  
  ConnectToNNTPServer := True;
  
 Except
  NNTPSession.LastError := 'Connection error';
 End;
End;

{ Envoyer commande NNTP }
Function SendNNTPCommand(Command: String): Boolean;
Var
 CommandLine: String;
 BytesSent: Integer;
Begin
 SendNNTPCommand := False;
 
 If not NNTPSession.IsConnected Then Begin
  NNTPSession.LastError := 'Not connected to server';
  Exit;
 End;
 
 CommandLine := Command + #13#10;
 
 If InewsConfig.Debug Then
  WriteLn('> ', Command);
 
 BytesSent := send(NNTPSession.Socket, CommandLine[1], Length(CommandLine), 0);
 If BytesSent = Length(CommandLine) Then Begin
  Inc(NNTPSession.BytesSent, BytesSent);
  SendNNTPCommand := True;
 End Else Begin
  NNTPSession.LastError := 'Failed to send command';
 End;
End;

{ Recevoir réponse NNTP }
Function ReceiveNNTPResponse: Boolean;
Var
 Buffer: Array[0..1023] of Char;
 BytesReceived: Integer;
 Response: String;
 CodeStr: String;
Begin
 ReceiveNNTPResponse := False;
 NNTPSession.LastResponse := '';
 NNTPSession.LastCode := 0;
 
 If not NNTPSession.IsConnected Then Begin
  NNTPSession.LastError := 'Not connected to server';
  Exit;
 End;
 
 BytesReceived := recv(NNTPSession.Socket, Buffer, SizeOf(Buffer) - 1, 0);
 If BytesReceived <= 0 Then Begin
  NNTPSession.LastError := 'No response from server';
  Exit;
 End;
 
 Buffer[BytesReceived] := #0;
 Response := StrPas(Buffer);
 Response := Trim(StringReplace(Response, #13#10, '', [rfReplaceAll]));
 
 NNTPSession.LastResponse := Response;
 
 { Parser le code de réponse }
 If Length(Response) >= 3 Then Begin
  CodeStr := Copy(Response, 1, 3);
  NNTPSession.LastCode := StrToIntDef(CodeStr, 0);
 End;
 
 If InewsConfig.Debug Then
  WriteLn('< ', Response);
 
 ReceiveNNTPResponse := True;
End;

{ Lire bannière du serveur }
Function ReadServerBanner: Boolean;
Begin
 Result := ReceiveNNTPResponse;
 If Result Then Begin
  { Codes 200-299 = OK, 400-499 = temporaire, 500-599 = permanent }
  Case NNTPSession.LastCode Of
   200: Begin
    NNTPSession.PostingAllowed := True;
    If InewsConfig.Verbose Then
     WriteLn('Server ready, posting allowed');
   End;
   201: Begin
    NNTPSession.PostingAllowed := False;
    If InewsConfig.Verbose Then
     WriteLn('Server ready, posting NOT allowed');
   End;
   400..599: Begin
    NNTPSession.LastError := 'Server error: ' + NNTPSession.LastResponse;
    Result := False;
   End;
   Else Begin
    NNTPSession.LastError := 'Unexpected server response: ' + NNTPSession.LastResponse;
    Result := False;
   End;
  End;
 End;
End;

{ Authentifier avec le serveur }
Function AuthenticateNNTP: Boolean;
Begin
 AuthenticateNNTP := True;
 
 { Si pas de nom d'utilisateur, pas d'authentification }
 If InewsConfig.Username = '' Then Exit;
 
 If InewsConfig.Verbose Then
  WriteLn('Authenticating as: ', InewsConfig.Username);
 
 { Envoyer AUTHINFO USER }
 If not SendNNTPCommand('AUTHINFO USER ' + InewsConfig.Username) Then Begin
  AuthenticateNNTP := False;
  Exit;
 End;
 
 If not ReceiveNNTPResponse Then Begin
  AuthenticateNNTP := False;
  Exit;
 End;
 
 Case NNTPSession.LastCode Of
  281: Begin
   { Authentification réussie sans mot de passe }
   NNTPSession.IsAuthenticated := True;
   If InewsConfig.Verbose Then
    WriteLn('Authentication successful');
  End;
  
  381: Begin
   { Mot de passe requis }
   If InewsConfig.Password = '' Then Begin
    Write('Password: ');
    ReadLn(InewsConfig.Password);
   End;
   
   If not SendNNTPCommand('AUTHINFO PASS ' + InewsConfig.Password) Then Begin
    AuthenticateNNTP := False;
    Exit;
   End;
   
   If not ReceiveNNTPResponse Then Begin
    AuthenticateNNTP := False;
    Exit;
   End;
   
   If NNTPSession.LastCode = 281 Then Begin
    NNTPSession.IsAuthenticated := True;
    If InewsConfig.Verbose Then
     WriteLn('Authentication successful');
   End Else Begin
    NNTPSession.LastError := 'Authentication failed: ' + NNTPSession.LastResponse;
    AuthenticateNNTP := False;
   End;
  End;
  
  Else Begin
   NNTPSession.LastError := 'Authentication error: ' + NNTPSession.LastResponse;
   AuthenticateNNTP := False;
  End;
 End;
End;

{ === GESTION DES ARTICLES === }

{ Initialiser un nouvel article }
Procedure InitializeArticle;
Begin
 With NewsArticle Do Begin
  Headers := TStringList.Create;
  Body := TStringList.Create;
  MessageID := '';
  Size := 0;
  Lines := 0;
  IsValid := False;
  HasSignature := False;
 End;
End;

{ Nettoyer l'article }
Procedure CleanupArticle;
Begin
 With NewsArticle Do Begin
  If Headers <> nil Then Begin
   Headers.Free;
   Headers := nil;
  End;
  If Body <> nil Then Begin
   Body.Free;
   Body := nil;
  End;
 End;
End;

{ Ajouter un en-tête }
Procedure AddHeader(Name, Value: String);
Begin
 If (Name <> '') and (Value <> '') Then
  NewsArticle.Headers.Add(Name + ': ' + Value);
End;

{ Construire les en-têtes de l'article }
Procedure BuildArticleHeaders;
Begin
 { En-têtes obligatoires }
 If InewsConfig.Newsgroups <> '' Then
  AddHeader('Newsgroups', InewsConfig.Newsgroups);
 
 If InewsConfig.Subject <> '' Then
  AddHeader('Subject', InewsConfig.Subject);
 
 If InewsConfig.FromAddress <> '' Then
  AddHeader('From', InewsConfig.FromAddress);
 
 AddHeader('Date', FormatRFC2822Date(Now));
 
 { Générer Message-ID si pas fourni }
 If InewsConfig.MessageID = '' Then
  InewsConfig.MessageID := GenerateMessageID;
 AddHeader('Message-ID', InewsConfig.MessageID);
 NewsArticle.MessageID := InewsConfig.MessageID;
 
 { En-têtes optionnels }
 If InewsConfig.Organization <> '' Then
  AddHeader('Organization', InewsConfig.Organization);
 
 If InewsConfig.ReplyTo <> '' Then
  AddHeader('Reply-To', InewsConfig.ReplyTo);
 
 If InewsConfig.FollowupTo <> '' Then
  AddHeader('Followup-To', InewsConfig.FollowupTo);
 
 If InewsConfig.References <> '' Then
  AddHeader('References', InewsConfig.References);
 
 If InewsConfig.Distribution <> '' Then
  AddHeader('Distribution', InewsConfig.Distribution);
 
 If InewsConfig.Keywords <> '' Then
  AddHeader('Keywords', InewsConfig.Keywords);
 
 If InewsConfig.Summary <> '' Then
  AddHeader('Summary', InewsConfig.Summary);
 
 If InewsConfig.Expires <> '' Then
  AddHeader('Expires', InewsConfig.Expires);
 
 If InewsConfig.Supersedes <> '' Then
  AddHeader('Supersedes', InewsConfig.Supersedes);
 
 If InewsConfig.Control <> '' Then
  AddHeader('Control', InewsConfig.Control);
 
 If InewsConfig.Approved <> '' Then
  AddHeader('Approved', InewsConfig.Approved);
 
 If InewsConfig.Path <> '' Then
  AddHeader('Path', InewsConfig.Path);
 
 { En-tête client }
 If InewsConfig.XNewsreader = '' Then
  InewsConfig.XNewsreader := 'inews (NETWORKKIT-P) 1.0';
 AddHeader('X-Newsreader', InewsConfig.XNewsreader);
 
 { Encodage }
 If InewsConfig.Encoding = '' Then
  InewsConfig.Encoding := 'UTF-8';
 AddHeader('Content-Type', 'text/plain; charset=' + InewsConfig.Encoding);
 AddHeader('Content-Transfer-Encoding', '8bit');
End;

{ Lire le corps de l'article depuis un fichier }
Function ReadArticleBody(FileName: String): Boolean;
Var
 InputFile: TextFile;
 Line: String;
Begin
 ReadArticleBody := False;
 
 If not FileExists(FileName) Then Begin
  NNTPSession.LastError := 'Input file not found: ' + FileName;
  Exit;
 End;
 
 Try
  AssignFile(InputFile, FileName);
  Reset(InputFile);
  
  While not EOF(InputFile) Do Begin
   ReadLn(InputFile, Line);
   NewsArticle.Body.Add(Line);
   Inc(NewsArticle.Lines);
  End;
  
  CloseFile(InputFile);
  ReadArticleBody := True;
  
 Except
  On E: Exception Do Begin
   NNTPSession.LastError := 'Error reading file: ' + E.Message;
  End;
 End;
End;

{ Lire article depuis stdin }
Function ReadArticleFromStdin: Boolean;
Var
 Line: String;
Begin
 ReadArticleFromStdin := True;
 
 If InewsConfig.Verbose Then
  WriteLn('Reading article from stdin (end with single "." line)...');
 
 Try
  While not EOF Do Begin
   ReadLn(Line);
   If Line = '.' Then Break;
   NewsArticle.Body.Add(Line);
   Inc(NewsArticle.Lines);
  End;
 Except
  On E: Exception Do Begin
   NNTPSession.LastError := 'Error reading from stdin: ' + E.Message;
   ReadArticleFromStdin := False;
  End;
 End;
End;

{ Ajouter signature }
Procedure AddSignature;
Var
 SigFile: TextFile;
 Line: String;
 SigAdded: Boolean;
Begin
 If InewsConfig.Signature = '' Then Exit;
 
 If not FileExists(InewsConfig.Signature) Then Exit;
 
 SigAdded := False;
 
 Try
  AssignFile(SigFile, InewsConfig.Signature);
  Reset(SigFile);
  
  While not EOF(SigFile) Do Begin
   ReadLn(SigFile, Line);
   
   { Ajouter séparateur de signature }
   If not SigAdded Then Begin
    NewsArticle.Body.Add('-- ');
    Inc(NewsArticle.Lines);
    SigAdded := True;
    NewsArticle.HasSignature := True;
   End;
   
   NewsArticle.Body.Add(Line);
   Inc(NewsArticle.Lines);
  End;
  
  CloseFile(SigFile);
  
 Except
  { Ignorer les erreurs de signature }
 End;
End;

{ Valider l'article }
Function ValidateArticle: Boolean;
Var
 I: Integer;
 GroupList: TStringList;
 GroupName: String;
Begin
 ValidateArticle := False;
 
 { Vérifier en-têtes obligatoires }
 If InewsConfig.Newsgroups = '' Then Begin
  NNTPSession.LastError := 'Missing required header: Newsgroups';
  Exit;
 End;
 
 If InewsConfig.Subject = '' Then Begin
  NNTPSession.LastError := 'Missing required header: Subject';
  Exit;
 End;
 
 If InewsConfig.FromAddress = '' Then Begin
  NNTPSession.LastError := 'Missing required header: From';
  Exit;
 End;
 
 { Valider adresse From }
 If not IsValidEmail(InewsConfig.FromAddress) Then Begin
  NNTPSession.LastError := 'Invalid From address: ' + InewsConfig.FromAddress;
  Exit;
 End;
 
 { Valider groupes de nouvelles }
 GroupList := TStringList.Create;
 Try
  GroupList.Delimiter := ',';
  GroupList.DelimitedText := InewsConfig.Newsgroups;
  
  For I := 0 To GroupList.Count - 1 Do Begin
   GroupName := CleanNewsgroup(GroupList[I]);
   If GroupName = '' Then Begin
    NNTPSession.LastError := 'Invalid newsgroup name: ' + GroupList[I];
    Exit;
   End;
   GroupList[I] := GroupName;
  End;
  
  InewsConfig.Newsgroups := GroupList.DelimitedText;
  
 Finally
  GroupList.Free;
 End;
 
 { Vérifier que l'article a du contenu }
 If NewsArticle.Body.Count = 0 Then Begin
  NNTPSession.LastError := 'Article body is empty';
  Exit;
 End;
 
 { Calculer taille totale }
 NewsArticle.Size := 0;
 For I := 0 To NewsArticle.Headers.Count - 1 Do
  Inc(NewsArticle.Size, Length(NewsArticle.Headers[I]) + 2); { +2 pour CRLF }
 Inc(NewsArticle.Size, 2); { Ligne vide entre en-têtes et corps }
 For I := 0 To NewsArticle.Body.Count - 1 Do
  Inc(NewsArticle.Size, Length(NewsArticle.Body[I]) + 2); { +2 pour CRLF }
 
 NewsArticle.IsValid := True;
 ValidateArticle := True;
End;

{ === ENVOI D'ARTICLES === }

{ Envoyer l'article au serveur NNTP }
Function PostArticle: Boolean;
Var
 I: Integer;
Begin
 PostArticle := False;
 
 If InewsConfig.DryRun Then Begin
  WriteLn('Dry run mode - article would be posted:');
  WriteLn('Size: ', NewsArticle.Size, ' bytes, ', NewsArticle.Lines, ' lines');
  WriteLn('Message-ID: ', NewsArticle.MessageID);
  PostArticle := True;
  Exit;
 End;
 
 If not NNTPSession.PostingAllowed Then Begin
  NNTPSession.LastError := 'Posting not allowed by server';
  Exit;
 End;
 
 If InewsConfig.Verbose Then
  WriteLn('Posting article...');
 
 { Commencer l'envoi }
 If not SendNNTPCommand('POST') Then Exit;
 If not ReceiveNNTPResponse Then Exit;
 
 If NNTPSession.LastCode <> 340 Then Begin
  NNTPSession.LastError := 'Server rejected POST: ' + NNTPSession.LastResponse;
  Exit;
 End;
 
 { Envoyer en-têtes }
 For I := 0 To NewsArticle.Headers.Count - 1 Do Begin
  If not SendNNTPCommand(NewsArticle.Headers[I]) Then Exit;
 End;
 
 { Ligne vide entre en-têtes et corps }
 If not SendNNTPCommand('') Then Exit;
 
 { Envoyer corps }
 For I := 0 To NewsArticle.Body.Count - 1 Do Begin
  { Échapper les lignes commençant par un point }
  If (Length(NewsArticle.Body[I]) > 0) and (NewsArticle.Body[I][1] = '.') Then
   NewsArticle.Body[I] := '.' + NewsArticle.Body[I];
  
  If not SendNNTPCommand(NewsArticle.Body[I]) Then Exit;
 End;
 
 { Terminer l'envoi }
 If not SendNNTPCommand('.') Then Exit;
 If not ReceiveNNTPResponse Then Exit;
 
 Case NNTPSession.LastCode Of
  240: Begin
   Inc(NNTPSession.MessagesSent);
   If InewsConfig.Verbose Then
    WriteLn('Article posted successfully');
   If not InewsConfig.Verbose Then
    WriteLn('Message-ID: ', NewsArticle.MessageID);
   PostArticle := True;
  End;
  
  441: Begin
   NNTPSession.LastError := 'Posting failed - server error: ' + NNTPSession.LastResponse;
  End;
  
  Else Begin
   NNTPSession.LastError := 'Posting rejected: ' + NNTPSession.LastResponse;
  End;
 End;
End;

{ Fermer la session NNTP }
Procedure CloseNNTPSession;
Begin
 If NNTPSession.IsConnected Then Begin
  If InewsConfig.Verbose Then
   WriteLn('Closing NNTP connection...');
  
  SendNNTPCommand('QUIT');
  ReceiveNNTPResponse;
  
  closesocket(NNTPSession.Socket);
  NNTPSession.IsConnected := False;
  NNTPSession.IsAuthenticated := False;
 End;
End;

{ === FONCTIONS PRINCIPALES === }

{ Initialiser configuration par défaut }
Procedure InitializeConfig;
Begin
 With InewsConfig Do Begin
  NNTPServer := GetEnvVar('NNTPSERVER');
  If NNTPServer = '' Then NNTPServer := 'news';
  Port := 119;
  Username := GetEnvVar('NNTPUSER');
  Password := GetEnvVar('NNTPPASS');
  FromAddress := GetEnvVar('REPLYTO');
  If FromAddress = '' Then Begin
   FromAddress := GetEnvVar('USER');
   If FromAddress = '' Then FromAddress := GetEnvVar('USERNAME');
   If FromAddress <> '' Then
    FromAddress := FromAddress + '@' + GetEnvVar('HOSTNAME');
  End;
  Organization := GetEnvVar('ORGANIZATION');
  ReplyTo := '';
  Subject := '';
  Newsgroups := '';
  FollowupTo := '';
  References := '';
  MessageID := '';
  Distribution := '';
  Keywords := '';
  Summary := '';
  Expires := '';
  Supersedes := '';
  Control := '';
  Approved := '';
  Path := '';
  XNewsreader := '';
  InputFile := '';
  HeaderFile := '';
  Signature := GetEnvVar('HOME') + '/.signature';
  If not FileExists(Signature) Then
   Signature := GetEnvVar('USERPROFILE') + '\.signature';
  Encoding := 'UTF-8';
  UseSSL := False;
  Debug := False;
  Verbose := False;
  DryRun := False;
  ForcePost := False;
  ModeratedPost := False;
  Timeout := 30000; { 30 secondes }
 End;
 
 { Initialiser session }
 FillChar(NNTPSession, SizeOf(NNTPSession), 0);
 NNTPSession.PostingAllowed := False;
 NNTPSession.AuthMethod := 'AUTHINFO';
End;

{ Analyser les arguments de ligne de commande }
Function ParseCommandLine: Boolean;
Var
 I: Integer;
 Param: String;
Begin
 ParseCommandLine := True;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--host') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.NNTPServer := ParamStr(I)
   Else Begin
    WriteLn('Option -h requires server hostname');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--port') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Port := StrToIntDef(ParamStr(I), 119)
   Else Begin
    WriteLn('Option -p requires port number');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-u') or (LowerCase(Param) = '--user') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Username := ParamStr(I)
   Else Begin
    WriteLn('Option -u requires username');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--from') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.FromAddress := ParamStr(I)
   Else Begin
    WriteLn('Option -f requires from address');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--subject') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Subject := ParamStr(I)
   Else Begin
    WriteLn('Option -s requires subject');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-n') or (LowerCase(Param) = '--newsgroups') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Newsgroups := ParamStr(I)
   Else Begin
    WriteLn('Option -n requires newsgroups list');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-o') or (LowerCase(Param) = '--organization') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Organization := ParamStr(I)
   Else Begin
    WriteLn('Option -o requires organization');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-r') or (LowerCase(Param) = '--references') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.References := ParamStr(I)
   Else Begin
    WriteLn('Option -r requires references');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--distribution') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Distribution := ParamStr(I)
   Else Begin
    WriteLn('Option -d requires distribution');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-x') or (LowerCase(Param) = '--expires') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Expires := ParamStr(I)
   Else Begin
    WriteLn('Option -x requires expiration date');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-S') or (LowerCase(Param) = '--signature') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Signature := ParamStr(I)
   Else Begin
    WriteLn('Option -S requires signature file');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If LowerCase(Param) = '-v' Then Begin
   InewsConfig.Verbose := True;
  End
  Else If LowerCase(Param) = '-D' Then Begin
   InewsConfig.Debug := True;
   InewsConfig.Verbose := True;
  End
  Else If LowerCase(Param) = '-t' Then Begin
   InewsConfig.DryRun := True;
  End
  Else If LowerCase(Param) = '--ssl' Then Begin
   InewsConfig.UseSSL := True;
   If InewsConfig.Port = 119 Then InewsConfig.Port := 563;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Fichier d'entrée }
   InewsConfig.InputFile := Param;
  End;
  
  Inc(I);
 End;
End;

{ Fonction principale }
Procedure RunInews;
Begin
 If not InewsConfig.Verbose and not InewsConfig.DryRun Then
  WriteLn('inews (NETWORKKIT-P) - Posting news article...');
 
 { Initialiser réseau }
 If not InitializeNetwork Then Begin
  WriteLn('Failed to initialize network');
  Halt(1);
 End;
 
 { Initialiser article }
 InitializeArticle;
 
 Try
  { Construire en-têtes }
  BuildArticleHeaders;
  
  { Lire corps de l'article }
  If InewsConfig.InputFile <> '' Then Begin
   If not ReadArticleBody(InewsConfig.InputFile) Then Begin
    WriteLn('Error: ', NNTPSession.LastError);
    Halt(1);
   End;
  End Else Begin
   If not ReadArticleFromStdin Then Begin
    WriteLn('Error: ', NNTPSession.LastError);
    Halt(1);
   End;
  End;
  
  { Ajouter signature }
  AddSignature;
  
  { Valider article }
  If not ValidateArticle Then Begin
   WriteLn('Error: ', NNTPSession.LastError);
   Halt(1);
  End;
  
  { En mode dry run, ne pas se connecter }
  If InewsConfig.DryRun Then Begin
   If not PostArticle Then Begin
    WriteLn('Validation failed: ', NNTPSession.LastError);
    Halt(1);
   End;
  End Else Begin
   { Se connecter au serveur NNTP }
   If not ConnectToNNTPServer Then Begin
    WriteLn('Connection failed: ', NNTPSession.LastError);
    Halt(1);
   End;
   
   { Lire bannière }
   If not ReadServerBanner Then Begin
    WriteLn('Server error: ', NNTPSession.LastError);
    Halt(1);
   End;
   
   { S'authentifier si nécessaire }
   If not AuthenticateNNTP Then Begin
    WriteLn('Authentication failed: ', NNTPSession.LastError);
    Halt(1);
   End;
   
   { Envoyer l'article }
   If not PostArticle Then Begin
    WriteLn('Post failed: ', NNTPSession.LastError);
    Halt(1);
   End;
  End;
  
  If InewsConfig.Verbose Then Begin
   WriteLn('Article statistics:');
   WriteLn('  Size: ', NewsArticle.Size, ' bytes');
   WriteLn('  Lines: ', NewsArticle.Lines);
   WriteLn('  Has signature: ', BoolToStr(NewsArticle.HasSignature, True));
   WriteLn('  Newsgroups: ', InewsConfig.Newsgroups);
  End;
  
 Finally
  CloseNNTPSession;
  CleanupArticle;
  CleanupNetwork;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedInews;
Begin
 WriteLn('INEWS [NETWORKKIT-P] NNTP News Posting (simulation)');
 WriteLn('===================================================');
 WriteLn;
 WriteLn('inews (NETWORKKIT-P) - Posting news article...');
 WriteLn('Connecting to NNTP server: news.example.com:119');
 WriteLn('Server ready, posting allowed');
 WriteLn('Authenticating as: user@example.com');
 WriteLn('Authentication successful');
 WriteLn('Posting article...');
 WriteLn('Article posted successfully');
 WriteLn('Message-ID: <20260221123045.12345@hostname>');
 WriteLn;
 WriteLn('Article statistics:');
 WriteLn('  Size: 1247 bytes');
 WriteLn('  Lines: 23');
 WriteLn('  Has signature: True');
 WriteLn('  Newsgroups: comp.os.linux.misc,alt.test');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/help') or (ParamStr(1) = '/H') Then Begin
  WriteLn('INEWS : Post news articles to NNTP server');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  INEWS [options] [article_file]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  --help                Afficher cette aide');
  WriteLn('  --version             Afficher la version');
  WriteLn('  -h, --host SERVER     Serveur NNTP (défaut: $NNTPSERVER ou "news")');
  WriteLn('  -p, --port PORT       Port NNTP (défaut: 119)');
  WriteLn('  -u, --user USER       Nom d''utilisateur NNTP');
  WriteLn('  -f, --from ADDRESS    Adresse expéditeur (From:)');
  WriteLn('  -s, --subject SUBJECT Sujet de l''article');
  WriteLn('  -n, --newsgroups LIST Groupes de nouvelles (séparés par virgules)');
  WriteLn('  -o, --organization ORG Organisation');
  WriteLn('  -r, --references REFS Références d''articles');
  WriteLn('  -d, --distribution DIST Distribution géographique');
  WriteLn('  -x, --expires DATE    Date d''expiration');
  WriteLn('  -S, --signature FILE  Fichier signature');
  WriteLn('  -v                    Mode verbeux');
  WriteLn('  -D                    Mode debug');
  WriteLn('  -t                    Test (dry run) - ne pas envoyer');
  WriteLn('  --ssl                 Utiliser SSL/TLS (port 563)');
  WriteLn;
  WriteLn('En-têtes d''article :');
  WriteLn('  Obligatoires :');
  WriteLn('    From:               Adresse email de l''expéditeur');
  WriteLn('    Subject:            Sujet de l''article');
  WriteLn('    Newsgroups:         Groupes de destination');
  WriteLn('    Date:               Date de création (auto-générée)');
  WriteLn('    Message-ID:         Identifiant unique (auto-généré)');
  WriteLn;
  WriteLn('  Optionnels :');
  WriteLn('    Organization:       Nom de l''organisation');
  WriteLn('    Reply-To:           Adresse de réponse');
  WriteLn('    Followup-To:        Groupe pour les réponses');
  WriteLn('    References:         Articles référencés');
  WriteLn('    Distribution:       Zone géographique');
  WriteLn('    Keywords:           Mots-clés');
  WriteLn('    Summary:            Résumé de l''article');
  WriteLn('    Expires:            Date d''expiration');
  WriteLn('    Supersedes:         Article remplacé');
  WriteLn('    Control:            Message de contrôle');
  WriteLn('    Approved:           Approbation pour groupes modérés');
  WriteLn('    X-Newsreader:       Client de nouvelles');
  WriteLn;
  WriteLn('Format de l''article :');
  WriteLn('  Un article Usenet standard comprend :');
  WriteLn('  1. En-têtes (Header: Value)');
  WriteLn('  2. Ligne vide');
  WriteLn('  3. Corps du message');
  WriteLn('  4. Signature optionnelle (précédée de "-- ")');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  NNTPSERVER          Serveur NNTP par défaut');
  WriteLn('  NNTPUSER            Nom d''utilisateur NNTP');
  WriteLn('  NNTPPASS            Mot de passe NNTP');
  WriteLn('  REPLYTO             Adresse de réponse');
  WriteLn('  ORGANIZATION        Organisation');
  WriteLn('  USER/USERNAME       Nom d''utilisateur système');
  WriteLn('  HOSTNAME            Nom d''hôte pour Message-ID');
  WriteLn('  HOME/USERPROFILE    Répertoire pour .signature');
  WriteLn;
  WriteLn('Exemples d''utilisation :');
  WriteLn('  Poster depuis fichier :');
  WriteLn('    INEWS -s "Test message" -n "alt.test" article.txt');
  WriteLn;
  WriteLn('  Poster depuis stdin :');
  WriteLn('    echo "Hello world" | INEWS -s "Test" -n "alt.test"');
  WriteLn;
  WriteLn('  Post complet avec options :');
  WriteLn('    INEWS -h news.example.com -u user@domain.com');
  WriteLn('          -f "John Doe <john@example.com>"');
  WriteLn('          -s "Important announcement"');
  WriteLn('          -n "comp.announce,alt.test"');
  WriteLn('          -o "Example Corporation"');
  WriteLn('          -S ~/.signature');
  WriteLn('          announcement.txt');
  WriteLn;
  WriteLn('  Test avant envoi :');
  WriteLn('    INEWS -t -s "Test" -n "alt.test" article.txt');
  WriteLn;
  WriteLn('  Serveur SSL :');
  WriteLn('    INEWS --ssl -h secure.news.com article.txt');
  WriteLn;
  WriteLn('Groupes de nouvelles :');
  WriteLn('  • Séparer multiples groupes par virgules');
  WriteLn('  • Utiliser hiérarchie standard (comp.*, alt.*, etc.)');
  WriteLn('  • Éviter crosspost excessif');
  WriteLn('  • Respecter charte des groupes');
  WriteLn;
  WriteLn('Authentification :');
  WriteLn('  • AUTHINFO USER/PASS (standard NNTP)');
  WriteLn('  • Support authentification simple');
  WriteLn('  • Variables d''environnement pour credentials');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                   Article posté avec succès');
  WriteLn('  1                   Erreur de connexion/réseau');
  WriteLn('  2                   Erreur d''authentification');
  WriteLn('  3                   Article rejeté par serveur');
  WriteLn('  4                   Erreur de validation');
  WriteLn;
  WriteLn('Note: Client NNTP pour poster des articles sur serveurs de nouvelles.');
  WriteLn('Compatible avec inews standard. Supporte authentification et SSL.');
  WriteLn('Respecte format RFC 3977 (NNTP) et RFC 5536 (Netnews).');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('inews (NETWORKKIT-P) 1.0');
  WriteLn('NNTP news posting client');
  WriteLn('Compatible with traditional inews');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeConfig;
  If ParseCommandLine Then
   RunInews
  Else Begin
   WriteLn('Try "inews --help" for more information.');
   Halt(1);
  End;
  {$ELSE}
  ShowSimulatedInews;
  {$ENDIF}
 End;
END.
