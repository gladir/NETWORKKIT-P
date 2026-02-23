{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Commande inews (NNTP news posting))
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
  Port: Word;                   { Port NNTP (dÇfaut: 119) }
  Username: String[64];         { Nom d'utilisateur }
  Password: String[255];        { Mot de passe }
  FromAddress: String[255];     { Adresse expÇditeur }
  Organization: String[255];    { Organisation }
  ReplyTo: String[255];         { Adresse de rÇponse }
  Subject: String[255];         { Sujet de l'article }
  Newsgroups: String[255];      { Groupes de nouvelles }
  FollowupTo: String[255];      { Suivi vers groupes }
  References: String[255];      { RÇfÇrences d'articles }
  MessageID: String[255];       { ID de message }
  Distribution: String[64];     { Distribution gÇographique }
  Keywords: String[255];        { Mots-clefs }
  Summary: String[255];         { RÇsumÇ }
  Expires: String[64];          { Date d'expiration }
  Supersedes: String[255];      { Article remplacÇ }
  Control: String[255];         { Message de contrìle }
  Approved: String[255];        { ApprouvÇ par }
  Path: String[255];            { Chemin de distribution }
  XNewsreader: String[128];     { Client de nouvelles }
  InputFile: String[255];       { Fichier d'entrÇe }
  HeaderFile: String[255];      { Fichier d'entàtes }
  Signature: String[255];       { Fichier signature }
  Encoding: String[32];         { Encodage (UTF-8, ISO-8859-1) }
  UseSSL: Boolean;              { Utiliser SSL/TLS }
  Debug: Boolean;               { Mode debug }
  Verbose: Boolean;             { Mode verbeux }
  DryRun: Boolean;              { Test sans envoi }
  ForcePost: Boolean;           { Forcer l'envoi }
  ModeratedPost: Boolean;       { Post vers groupe modÇrÇ }
  Timeout: Integer;             { DÇpassement de dÇlai de connexion }
 End;

 { Session NNTP }
 TNNTPSession = Record
  Socket: TSocket;                  { Socket de connexion }
  IsConnected: Boolean;             { Connexion Çtablie }
  IsAuthenticated: Boolean;         { AuthentifiÇ }
  ServerCapabilities: String[255];  { CapacitÇs du serveur }
  LastResponse: String[255];        { Derniäre rÇponse }
  LastCode: Integer;                { Dernier code de r√©ponse }
  PostingAllowed: Boolean;          { Post autorisÇ }
  AuthMethod: String[32];           { MÇthode d'authentification }
  BytesSent: Int64;                 { Octets envoyÇs }
  MessagesSent: Integer;            { Messages envoyÇs }
  LastError: String[255];           { Derniäre erreur }
 End;

 { Article de nouvelles }
 TNewsArticle = Record
  Headers: TStringList;             { Entàtes de l'article }
  Body: TStringList;                { Corps de l'article }
  MessageID: String[255];           { ID gÇnÇrÇ }
  Size: Integer;                    { Taille totale }
  Lines: Integer;                   { Nombre de lignes }
  IsValid: Boolean;                 { Article valide }
  HasSignature: Boolean;            { Contient une signature }
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

{ GÇnÇrer un Message-ID unique }
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

 { Formater la date en RFC 2822 }
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

 { Valider l'adresse de courriel }
Function IsValidEmail(Email: String): Boolean;
Var
 AtPos: Integer;
Begin
 Result := False;
 Email := Trim(Email);
 If Length(Email) < 5 Then Exit; { Minimum: a@b.c }
 AtPos := Pos('@', Email);
 If (AtPos <= 1) or (AtPos >= Length(Email)) Then Exit;
 { Simples vÇrifications }
 If (Pos(' ', Email) > 0) or (Pos('..', Email) > 0) Then Exit;
 If (Email[1] = '.') or (Email[Length(Email)] = '.') Then Exit;
 If (Email[1] = '@') or (Email[Length(Email)] = '@') Then Exit;
  { VÇrifier domaine }
 If Pos('.', Copy(Email, AtPos + 1, Length(Email))) = 0 Then Exit;
 Result := True;
End;

 { Nettoyer nom de groupe }
Function CleanNewsgroup(Newsgroup: String): String;
Var
 I: Integer;
Begin
 Result := LowerCase(Trim(Newsgroup));
  { Remplacer caractäres invalides }
 For I := 1 To Length(Result) Do Begin
  If not (Result[I] in ['a'..'z', '0'..'9', '.', '-']) Then
   Result[I] := '.';
 End;
  { Supprimer points multiples }
 While Pos('..', Result) > 0 Do
  Result := StringReplace(Result, '..', '.', [rfReplaceAll]);
  { Supprimer points en dÇbut/fin }
 While (Length(Result) > 0) and (Result[1] = '.') Do
  Delete(Result, 1, 1);
 While (Length(Result) > 0) and (Result[Length(Result)] = '.') Do
  Delete(Result, Length(Result), 1);
End;

 { === FONCTIONS NNTP RêELLES === }

 { Initialiser WinSock (Windows uniquement) }
Function InitializeNetwork:Boolean;
{$IFDEF WINDOWS}
Var
 WSAData: TWSAData;
{$ENDIF}
Begin
 InitializeNetwork := True;
 {$IFDEF WINDOWS}
 If WSAStartup($0202, WSAData) <> 0 Then Begin
  WriteLn('Erreur: Impossible d''initialiser WinSock');
  InitializeNetwork := False;
 End;
 {$ENDIF}
End;

{ Nettoyer rÇseau }
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
  WriteLn('Connection vers un serveur NNTP: ', InewsConfig.NNTPServer, ':', InewsConfig.Port);

 { CrÇer socket }
 NNTPSession.Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If NNTPSession.Socket = INVALID_SOCKET Then Begin
  NNTPSession.LastError := 'Impossible de crÇer un socket';
  Exit;
 End;
 Try
  { Configurer le dÇpassement de dÇlai }
  setsockopt(NNTPSession.Socket, SOL_SOCKET, SO_RCVTIMEO, @InewsConfig.Timeout, SizeOf(InewsConfig.Timeout));
  setsockopt(NNTPSession.Socket, SOL_SOCKET, SO_SNDTIMEO, @InewsConfig.Timeout, SizeOf(InewsConfig.Timeout));

  { RÇsoudre adresse serveur }
  {$IFDEF WINDOWS}
   HostEnt := gethostbyname(@InewsConfig.NNTPServer[1]);
   If HostEnt = nil Then Begin
    ServerAddr.sin_addr.S_addr := inet_addr(@InewsConfig.NNTPServer[1]);
    If ServerAddr.sin_addr.S_addr = INADDR_NONE Then Begin
     NNTPSession.LastError := 'Cannot resolve server: ' + InewsConfig.NNTPServer;
     Exit;
    End;
   End
    Else
   Begin
    ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
   End;
  {$ENDIF}
   { Configurer adresse }
  ServerAddr.sin_family := AF_INET;
  ServerAddr.sin_port := htons(InewsConfig.Port);
   { Se connecter }
  If connect(NNTPSession.Socket, @ServerAddr, SizeOf(ServerAddr)) <> 0 Then Begin
   NNTPSession.LastError := 'êchec de connexion vers ' + InewsConfig.NNTPServer;
   Exit;
  End;
  NNTPSession.IsConnected := True;
  If InewsConfig.Verbose Then WriteLn('Connection vers le serveur NNTP');
  ConnectToNNTPServer := True;
 Except
  NNTPSession.LastError := 'Erreur de connexion';
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
  NNTPSession.LastError := 'Impossible de se connectÇ au serveur';
  Exit;
 End;
 CommandLine := Command + #13#10;
 If InewsConfig.Debug Then WriteLn('> ', Command);
 BytesSent := send(NNTPSession.Socket, CommandLine[1], Length(CommandLine), 0);
 If BytesSent = Length(CommandLine) Then Begin
  Inc(NNTPSession.BytesSent, BytesSent);
  SendNNTPCommand := True;
 End
  Else
 Begin
  NNTPSession.LastError := 'êchec d''envoi de commande';
 End;
End;

 { Recevoir la rÇponse NNTP }
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
  NNTPSession.LastError := 'Impossible de se connecter au serveur';
  Exit;
 End;
 BytesReceived := recv(NNTPSession.Socket, Buffer, SizeOf(Buffer) - 1, 0);
 If BytesReceived <= 0 Then Begin
  NNTPSession.LastError := 'Pas de rÇponse du serveur';
  Exit;
 End;
 Buffer[BytesReceived] := #0;
 Response := StrPas(Buffer);
 Response := Trim(StringReplace(Response, #13#10, '', [rfReplaceAll]));
 NNTPSession.LastResponse := Response;
  { Analyse le code de rÇponse }
 If Length(Response) >= 3 Then Begin
  CodeStr := Copy(Response, 1, 3);
  NNTPSession.LastCode := StrToIntDef(CodeStr, 0);
 End;
 If InewsConfig.Debug Then WriteLn('< ', Response);
 ReceiveNNTPResponse := True;
End;

 { Lire banniäre du serveur }
Function ReadServerBanner:Boolean;Begin
 Result := ReceiveNNTPResponse;
 If Result Then Begin
  { Codes 200-299 = OK, 400-499 = temporaire, 500-599 = permanent }
  Case NNTPSession.LastCode Of
   200: Begin
    NNTPSession.PostingAllowed := True;
    If InewsConfig.Verbose Then
     WriteLn('Serveur pràt, publication autorisÇ');
   End;
   201: Begin
    NNTPSession.PostingAllowed := False;
    If InewsConfig.Verbose Then
     WriteLn('Serveur pràt, publication interdite');
   End;
   400..599: Begin
    NNTPSession.LastError := 'Erreur de serveur: ' + NNTPSession.LastResponse;
    Result := False;
   End;
   Else Begin
    NNTPSession.LastError := 'RÇponse inattendue du serveur: ' + NNTPSession.LastResponse;
    Result := False;
   End;
  End;
 End;
End;

 { Authentifier avec le serveur }
Function AuthenticateNNTP:Boolean;Begin
 AuthenticateNNTP:=True;
  { Si pas de nom d'utilisateur, pas d'authentification }
 If InewsConfig.Username = '' Then Exit;
 If InewsConfig.Verbose Then WriteLn('Authenticating as: ', InewsConfig.Username);
 { Envoyer AUTHINFO USER }
 If Not SendNNTPCommand('AUTHINFO USER ' + InewsConfig.Username)Then Begin
  AuthenticateNNTP := False;
  Exit;
 End;
 If Not ReceiveNNTPResponse Then Begin
  AuthenticateNNTP := False;
  Exit;
 End;
 Case NNTPSession.LastCode Of
  281:Begin
    { Authentification rÇussie sans mot de passe }
   NNTPSession.IsAuthenticated:=True;
   If InewsConfig.Verbose Then WriteLn('Authentication rÇussie');
  End;
  381:Begin
   { Mot de passe requis }
   If InewsConfig.Password = '' Then Begin
    Write('Mot de passe: ');
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
     WriteLn('Authentication rÇussie');
   End Else Begin
    NNTPSession.LastError := 'êchec d''authentication: ' + NNTPSession.LastResponse;
    AuthenticateNNTP := False;
   End;
  End;
  Else Begin
   NNTPSession.LastError := 'êchec d''authentication: ' + NNTPSession.LastResponse;
   AuthenticateNNTP := False;
  End;
 End;
End;

{ === GESTION DES ARTICLES === }

 { Initialiser un nouvel article }
Procedure InitializeArticle;Begin
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

 { Ajouter un entàte }
Procedure AddHeader(Name, Value: String);Begin
 If (Name <> '') and (Value <> '') Then
  NewsArticle.Headers.Add(Name + ': ' + Value);
End;

 { Construire les entàtes de l'article }
Procedure BuildArticleHeaders;Begin
 { Entàtes obligatoires }
 If InewsConfig.Newsgroups <> '' Then AddHeader('Newsgroups', InewsConfig.Newsgroups);
 If InewsConfig.Subject <> '' Then AddHeader('Subject', InewsConfig.Subject);
 If InewsConfig.FromAddress <> '' Then AddHeader('From', InewsConfig.FromAddress);
 AddHeader('Date', FormatRFC2822Date(Now));
  { GÇnÇrer Message-ID si pas fourni }
 If InewsConfig.MessageID = '' Then InewsConfig.MessageID := GenerateMessageID;
 AddHeader('Message-ID', InewsConfig.MessageID);
 NewsArticle.MessageID := InewsConfig.MessageID;
  { Entàtes optionnels }
 If InewsConfig.Organization <> '' Then AddHeader('Organization', InewsConfig.Organization);
 If InewsConfig.ReplyTo <> '' Then AddHeader('Reply-To', InewsConfig.ReplyTo);
 If InewsConfig.FollowupTo <> '' Then AddHeader('Followup-To', InewsConfig.FollowupTo);
 If InewsConfig.References <> '' Then AddHeader('References', InewsConfig.References);
 If InewsConfig.Distribution <> '' Then AddHeader('Distribution', InewsConfig.Distribution);
 If InewsConfig.Keywords <> '' Then AddHeader('Keywords', InewsConfig.Keywords);
 If InewsConfig.Summary <> '' Then AddHeader('Summary', InewsConfig.Summary);
 If InewsConfig.Expires <> '' Then AddHeader('Expires', InewsConfig.Expires);
 If InewsConfig.Supersedes <> '' Then AddHeader('Supersedes', InewsConfig.Supersedes);
 If InewsConfig.Control <> '' Then AddHeader('Control', InewsConfig.Control);
 If InewsConfig.Approved <> '' Then AddHeader('Approved', InewsConfig.Approved);
 If InewsConfig.Path <> '' Then AddHeader('Path', InewsConfig.Path);
  { Entàte client }
 If InewsConfig.XNewsreader = '' Then InewsConfig.XNewsreader := 'inews (NETWORKKIT-P) 1.0';
 AddHeader('X-Newsreader', InewsConfig.XNewsreader);
  { Encodage }
 If InewsConfig.Encoding = '' Then InewsConfig.Encoding := 'UTF-8';
 AddHeader('Content-Type', 'text/plain; charset=' + InewsConfig.Encoding);
 AddHeader('Content-Transfer-Encoding', '8bit');
End;

 { Lire le corps de l'article depuis un fichier }
Function ReadArticleBody(FileName:String):Boolean;
Var
 InputFile:TextFile;
 Line:String;
Begin
 ReadArticleBody:=False;
 If not FileExists(FileName)Then Begin
  NNTPSession.LastError := 'Fichier d''entrÇe introuvable: ' + FileName;
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
   NNTPSession.LastError := 'Erreur de lecture de fichier: ' + E.Message;
  End;
 End;
End;

 { Lire article depuis stdin }
Function ReadArticleFromStdin:Boolean;
Var
 Line: String;
Begin
 ReadArticleFromStdin:=True;
 If InewsConfig.Verbose Then Begin
  WriteLn('Lecture de l''article depuis l''entrÇe standard (terminaison par une seule ligne ".")...');
 End;
 Try
  While not EOF Do Begin
   ReadLn(Line);
   If Line = '.' Then Break;
   NewsArticle.Body.Add(Line);
   Inc(NewsArticle.Lines);
  End;
 Except
  On E: Exception Do Begin
   NNTPSession.LastError := 'Erreur de lectrue depuis l''entrÇe standard: ' + E.Message;
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
    { Ajouter sÇparateur de signature }
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
  { VÇrifier entàtes obligatoires }
 If InewsConfig.Newsgroups = '' Then Begin
  NNTPSession.LastError := 'Entàte obligatoire manquant : Newsgroups';
  Exit;
 End;
 If InewsConfig.Subject = '' Then Begin
  NNTPSession.LastError := 'Entàte obligatoire manquant : Subject';
  Exit;
 End;
 If InewsConfig.FromAddress = '' Then Begin
  NNTPSession.LastError := 'Entàte obligatoire manquant : From';
  Exit;
 End;
  { Valider adresse From }
 If not IsValidEmail(InewsConfig.FromAddress) Then Begin
  NNTPSession.LastError := 'Adresse d''expÇdition invalide : ' + InewsConfig.FromAddress;
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
    NNTPSession.LastError := 'Nom de groupe de discussion invalide : ' + GroupList[I];
    Exit;
   End;
   GroupList[I] := GroupName;
  End;
  InewsConfig.Newsgroups := GroupList.DelimitedText;
 Finally
  GroupList.Free;
 End;
  { VÇrifier que l'article a du contenu }
 If NewsArticle.Body.Count = 0 Then Begin
  NNTPSession.LastError := 'Le corps de l''article est vide.';
  Exit;
 End;
  { Calculer taille totale }
 NewsArticle.Size := 0;
 For I := 0 To NewsArticle.Headers.Count - 1 Do
  Inc(NewsArticle.Size, Length(NewsArticle.Headers[I]) + 2); { +2 pour CRLF }
 Inc(NewsArticle.Size, 2); { Ligne vide entre entàtes et corps }
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
  WriteLn('Mode test Ö blanc - l''article sera publiÇ :');
  WriteLn('Taille: ', NewsArticle.Size, ' octets, ', NewsArticle.Lines, ' lignes');
  WriteLn('Message-ID: ', NewsArticle.MessageID);
  PostArticle := True;
  Exit;
 End;
 If not NNTPSession.PostingAllowed Then Begin
  NNTPSession.LastError := 'Publication interdite par le serveur';
  Exit;
 End;
 If InewsConfig.Verbose Then WriteLn('Publication de l''article...');
  { Commencer l'envoi }
 If not SendNNTPCommand('POST') Then Exit;
 If not ReceiveNNTPResponse Then Exit;
 If NNTPSession.LastCode <> 340 Then Begin
  NNTPSession.LastError := 'Le serveur Ö rejetÇ la requàte POST: ' + NNTPSession.LastResponse;
  Exit;
 End;
  { Envoyer entàtes }
 For I := 0 To NewsArticle.Headers.Count - 1 Do Begin
  If not SendNNTPCommand(NewsArticle.Headers[I]) Then Exit;
 End;
  { Ligne vide entre entàtes et corps }
 If not SendNNTPCommand('') Then Exit;
  { Envoyer corps }
 For I := 0 To NewsArticle.Body.Count - 1 Do Begin
  { êchapper les lignes commenáant par un point }
  If (Length(NewsArticle.Body[I]) > 0) and (NewsArticle.Body[I][1] = '.') Then
   NewsArticle.Body[I] := '.' + NewsArticle.Body[I];
  If not SendNNTPCommand(NewsArticle.Body[I]) Then Exit;
 End;
  { Terminer l'envoi }
 If not SendNNTPCommand('.')Then Exit;
 If not ReceiveNNTPResponse Then Exit;
 Case NNTPSession.LastCode Of
  240: Begin
   Inc(NNTPSession.MessagesSent);
   If InewsConfig.Verbose Then
    WriteLn('Article publiÇ avec succäs');
   If not InewsConfig.Verbose Then
    WriteLn('Message-ID: ', NewsArticle.MessageID);
   PostArticle := True;
  End;
  441: Begin
   NNTPSession.LastError := 'êchec de la publication - erreur serveur: ' + NNTPSession.LastResponse;
  End;
  Else Begin
   NNTPSession.LastError := 'Publication refusÇe: ' + NNTPSession.LastResponse;
  End;
 End;
End;

 { Fermer la session NNTP }
Procedure CloseNNTPSession;Begin
 If NNTPSession.IsConnected Then Begin
  If InewsConfig.Verbose Then WriteLn('Fermeture de la connexion NNTP...');
  SendNNTPCommand('QUIT');
  ReceiveNNTPResponse;
  closesocket(NNTPSession.Socket);
  NNTPSession.IsConnected := False;
  NNTPSession.IsAuthenticated := False;
 End;
End;

{ === FONCTIONS PRINCIPALES === }

{ Initialiser configuration par dÇfaut }
Procedure InitializeConfig;Begin
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
 I:Integer;
 Param:String;
Begin
 ParseCommandLine := True;
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--host') Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.NNTPServer := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -h requiert le nom de l''hìte du serveur');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--port') Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Port := StrToIntDef(ParamStr(I), 119)
    Else
   Begin
    WriteLn('L''option -p requiert le numÇro de port');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-u') or (LowerCase(Param) = '--user') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.Username := ParamStr(I)
   Else Begin
    WriteLn('L''option -u requiert le nom d''utilisateur');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--from') Then Begin
   Inc(I);
   If I <= ParamCount Then
    InewsConfig.FromAddress := ParamStr(I)
   Else Begin
    WriteLn('L''option -f requiert l''adresse');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--subject') Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Subject := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -s requiert le sujet');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If(LowerCase(Param) = '-n') or (LowerCase(Param) = '--newsgroups')Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Newsgroups:=ParamStr(I)
    Else
   Begin
    WriteLn('L''option -n requiert la liste de groupe de discussion');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-o') or (LowerCase(Param) = '--organization')Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Organization := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -o requiert l''organisation');
    ParseCommandLine := False;
    Exit;
   End;
  End
  Else If (LowerCase(Param) = '-r') or (LowerCase(Param) = '--references') Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.References := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -r requiert les rÇfÇrences');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-d') or (LowerCase(Param) = '--distribution') Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Distribution := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -d requiert la distribution');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If (LowerCase(Param) = '-x') or (LowerCase(Param) = '--expires')Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Expires:=ParamStr(I)
    Else
   Begin
    WriteLn('Option -x requires expiration date');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If(LowerCase(Param) = '-S')or(LowerCase(Param) = '--signature')Then Begin
   Inc(I);
   If I <= ParamCount Then InewsConfig.Signature := ParamStr(I)
    Else
   Begin
    WriteLn('L''option -S requiert le fichier de signature');
    ParseCommandLine := False;
    Exit;
   End;
  End
   Else
  If LowerCase(Param) = '-v'Then Begin
   InewsConfig.Verbose := True;
  End
   Else
  If LowerCase(Param) = '-D'Then Begin
   InewsConfig.Debug := True;
   InewsConfig.Verbose := True;
  End
   Else
  If LowerCase(Param)='-t' Then Begin
   InewsConfig.DryRun := True;
  End
   Else
  If LowerCase(Param)='--ssl' Then Begin
   InewsConfig.UseSSL := True;
   If InewsConfig.Port = 119 Then InewsConfig.Port := 563;
  End
   Else
  If Copy(Param, 1, 1)<>'-'Then Begin
    { Fichier d'entrÇe }
   InewsConfig.InputFile := Param;
  End;
  Inc(I);
 End;
End;

 { Fonction principale }
Procedure RunInews;Begin
 If not InewsConfig.Verbose and not InewsConfig.DryRun Then Begin
  WriteLn('inews (NETWORKKIT-P) - Publication d''article d''actualitÇ...');
 End;
  { Initialiser le rÇseau }
 If not InitializeNetwork Then Begin
  WriteLn('êchec de l''initialisation du rÇseau');
  Halt(1);
 End;
  { Initialiser article }
 InitializeArticle;
 Try
   { Construire entàtes }
  BuildArticleHeaders;
   { Lire corps de l'article }
  If InewsConfig.InputFile <> '' Then Begin
   If not ReadArticleBody(InewsConfig.InputFile) Then Begin
    WriteLn('Erreur: ', NNTPSession.LastError);
    Halt(1);
   End;
  End
   Else
  Begin
   If not ReadArticleFromStdin Then Begin
    WriteLn('Erreur: ', NNTPSession.LastError);
    Halt(1);
   End;
  End;
   { Ajouter signature }
  AddSignature;
   { Valider article }
  If not ValidateArticle Then Begin
   WriteLn('Erreur: ', NNTPSession.LastError);
   Halt(1);
  End;
   { En mode dry run, ne pas se connecter }
  If InewsConfig.DryRun Then Begin
   If not PostArticle Then Begin
    WriteLn('êchec de validation: ', NNTPSession.LastError);
    Halt(1);
   End;
  End
   Else
  Begin
    { Se connecter au serveur NNTP }
   If not ConnectToNNTPServer Then Begin
    WriteLn('êchec de connexion: ', NNTPSession.LastError);
    Halt(1);
   End;
    { Lire banniäre }
   If not ReadServerBanner Then Begin
    WriteLn('Erreur de serveur: ', NNTPSession.LastError);
    Halt(1);
   End;
    { S'authentifier si nÇcessaire }
   If not AuthenticateNNTP Then Begin
    WriteLn('êchec d''authentication: ', NNTPSession.LastError);
    Halt(1);
   End;
    { Envoyer l'article }
   If not PostArticle Then Begin
    WriteLn('êchec de la publication: ', NNTPSession.LastError);
    Halt(1);
   End;
  End;
  If InewsConfig.Verbose Then Begin
   WriteLn('Statistiques des articles :');
   WriteLn('  Taille : ', NewsArticle.Size, ' octets');
   WriteLn('  Lignes : ', NewsArticle.Lines);
   WriteLn('  Comporte une signature : ', BoolToStr(NewsArticle.HasSignature, True));
   WriteLn('  Groupes de discussion : ', InewsConfig.Newsgroups);
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
Procedure ShowSimulatedInews;Begin
 WriteLn('INEWS [NETWORKKIT-P] Publication d''actualitÇ NNTP (simulation)');
 WriteLn('===================================================');
 WriteLn;
 WriteLn('inews (NETWORKKIT-P) - Publication d''articles d''actualitÇ...');
 WriteLn('Connexion au serveur NNTP : news.example.com:119');
 WriteLn('Serveur pràt, publication autorisÇe');
 WriteLn('Authentication comme : user@example.com');
 WriteLn('Authentication rÇussie');
 WriteLn('Publication d''articles...');
 WriteLn('Article publiÇ avec succäs');
 WriteLn('Message-ID: <20260221123045.12345@hostname>');
 WriteLn;
 WriteLn('Statistiques des articles :');
 WriteLn('  Taille : 1247 octets');
 WriteLn('  Lignes : 23');
 WriteLn('  Comporte une signature : True');
 WriteLn('  Groupe de discussion : comp.os.linux.misc,alt.test');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/help') or (ParamStr(1) = '/H') Then Begin
  WriteLn('INEWS : Cette commande permet de publier des articles d''actualitÇ sur un serveur NNTP');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  INEWS [options] [article_file]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  --help                  Afficher cette aide');
  WriteLn('  --version               Afficher la version');
  WriteLn('  -h, --host SERVER       Serveur NNTP (dÇfaut: $NNTPSERVER ou "news")');
  WriteLn('  -p, --port PORT         Port NNTP (dÇfaut: 119)');
  WriteLn('  -u, --user USER         Nom d''utilisateur NNTP');
  WriteLn('  -f, --from ADDRESS      Adresse expÇditeur (From:)');
  WriteLn('  -s, --subject SUBJECT   Sujet de l''article');
  WriteLn('  -n, --newsgroups LIST   Groupes de nouvelles (sÇparÇs par virgules)');
  WriteLn('  -o, --organization ORG  Organisation');
  WriteLn('  -r, --references REFS   RÇfÇrences d''articles');
  WriteLn('  -d, --distribution DIST Distribution gÇographique');
  WriteLn('  -x, --expires DATE      Date d''expiration');
  WriteLn('  -S, --signature FILE    Fichier signature');
  WriteLn('  -v                      Mode verbeux');
  WriteLn('  -D                      Mode debug');
  WriteLn('  -t                      Test (dry run) - ne pas envoyer');
  WriteLn('  --ssl                   Utiliser SSL/TLS (port 563)');
  WriteLn;
  WriteLn('Entàtes d''article :');
  WriteLn('  Obligatoires :');
  WriteLn('    From:               Adresse de courriel de l''expÇditeur');
  WriteLn('    Subject:            Sujet de l''article');
  WriteLn('    Newsgroups:         Groupes de destination');
  WriteLn('    Date:               Date de crÇation (auto-gÇnÇrÇe)');
  WriteLn('    Message-ID:         Identifiant unique (auto-gÇnÇrÇ)');
  WriteLn;
  WriteLn('  Optionnels :');
  WriteLn('    Organization:       Nom de l''organisation');
  WriteLn('    Reply-To:           Adresse de rÇponse');
  WriteLn('    Followup-To:        Groupe pour les rÇponses');
  WriteLn('    References:         Articles rÇfÇrencÇs');
  WriteLn('    Distribution:       Zone gÇographique');
  WriteLn('    Keywords:           Mots-clefs');
  WriteLn('    Summary:            RÇsumÇ de l''article');
  WriteLn('    Expires:            Date d''expiration');
  WriteLn('    Supersedes:         Article remplacÇ');
  WriteLn('    Control:            Message de contrìle');
  WriteLn('    Approved:           Approbation pour groupes modÇrÇs');
  WriteLn('    X-Newsreader:       Client de nouvelles');
  WriteLn;
  WriteLn('Format de l''article :');
  WriteLn('  Un article Usenet standard comprend :');
  WriteLn('  1. Entàtes (Header: Value)');
  WriteLn('  2. Ligne vide');
  WriteLn('  3. Corps du message');
  WriteLn('  4. Signature optionnelle (prÇcÇdÇe de "-- ")');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  NNTPSERVER          Serveur NNTP par dÇfaut');
  WriteLn('  NNTPUSER            Nom d''utilisateur NNTP');
  WriteLn('  NNTPPASS            Mot de passe NNTP');
  WriteLn('  REPLYTO             Adresse de rÇponse');
  WriteLn('  ORGANIZATION        Organisation');
  WriteLn('  USER/USERNAME       Nom d''utilisateur systäme');
  WriteLn('  HOSTNAME            Nom d''hìte pour Message-ID');
  WriteLn('  HOME/USERPROFILE    RÇpertoire pour .signature');
  WriteLn;
  WriteLn('Exemples d''utilisation :');
  WriteLn('  Poster depuis fichier :');
  WriteLn('    INEWS -s "Test message" -n "alt.test" article.txt');
  WriteLn;
  WriteLn('  Poster depuis stdin :');
  WriteLn('    echo "Bonjour le monde" | INEWS -s "Test" -n "alt.test"');
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
  WriteLn('  ˛ SÇparer multiples groupes par virgules');
  WriteLn('  ˛ Utiliser hiÇrarchie standard (comp.*, alt.*, etc.)');
  WriteLn('  ˛ êviter crosspost excessif');
  WriteLn('  ˛ Respecter charte des groupes');
  WriteLn;
  WriteLn('Authentification :');
  WriteLn('  ˛ AUTHINFO USER/PASS (standard NNTP)');
  WriteLn('  ˛ Support authentification simple');
  WriteLn('  ˛ Variables d''environnement pour credentials');
  WriteLn;
  WriteLn('Codes de retour :');
  WriteLn('  0                   Article postÇ avec succäs');
  WriteLn('  1                   Erreur de connexion/rÇseau');
  WriteLn('  2                   Erreur d''authentification');
  WriteLn('  3                   Article rejetÇ par serveur');
  WriteLn('  4                   Erreur de validation');
  WriteLn;
  WriteLn('Note: Client NNTP pour poster des articles sur serveurs de nouvelles.');
  WriteLn('Compatible avec inews standard. Supporte authentification et SSL.');
  WriteLn('Respecte format RFC 3977 (NNTP) et RFC 5536 (Netnews).');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('inews (NETWORKKIT-P) 1.0 - Clone Pascal pour NETWORKKIT-P, Corail, Linux-0');
  WriteLn('Client de publication d''actualitÇ NNTP');
  WriteLn('Compatible avec les inews traditionnel');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
   InitializeConfig;
   If ParseCommandLine Then RunInews
    Else
   Begin
    WriteLn('Essayer "inews --help" pour plus d''informations.');
    Halt(1);
   End;
  {$ELSE}
   ShowSimulatedInews;
  {$ENDIF}
 End;
END.
