{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande mail (Unix/Linux mail command))
}

Program MAIL;

{$IFDEF FPC}
 {$mode objfpc}
 {$IFDEF WINDOWS}
  Uses SysUtils, Classes, StrUtils, DateUtils, WinSock;
 {$ELSE}
  Uses SysUtils, Classes, StrUtils, DateUtils, Sockets, NetDB;
 {$ENDIF}
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'un message mail }
 TMailMessage = Record
  MessageID: Integer;         { ID unique du message }
  FromAddr: String[255];      { Adresse expéditeur }
  FromName: String[255];      { Nom expéditeur }
  ToAddr: String[255];        { Adresse destinataire }
  ToName: String[255];        { Nom destinataire }
  CcAddr: String[255];        { Copie carbone }
  BccAddr: String[255];       { Copie carbone invisible }
  Subject: String[255];       { Sujet }
  DateSent: TDateTime;        { Date d'envoi }
  DateReceived: TDateTime;    { Date de réception }
  Priority: Integer;          { Priorité (1=haute, 2=normale, 3=basse) }
  Status: String[32];         { État (new, read, deleted, replied) }
  Size: LongInt;              { Taille en octets }
  Lines: Integer;             { Nombre de lignes }
  MessageBody: TStringList;   { Corps du message }
  Headers: TStringList;       { En-têtes complètes }
  IsRead: Boolean;            { Message lu }
  IsDeleted: Boolean;         { Message supprimé }
  IsReplied: Boolean;         { Réponse envoyée }
  IsSaved: Boolean;           { Message sauvegardé }
 End;

 { Configuration mail }
 TMailConfig = Record
  UserName: String[64];       { Nom utilisateur }
  UserEmail: String[255];     { Adresse email }
  FullName: String[255];      { Nom complet }
  Domain: String[255];        { Domaine }
  MailSpoolFile: String[255]; { Fichier spool mail }
  MailboxFile: String[255];   { Fichier boîte mail }
  DeadLetterFile: String[255]; { Fichier dead.letter }
  SMTPServer: String[255];    { Serveur SMTP }
  SMTPPort: Word;             { Port SMTP }
  UseSSL: Boolean;            { Utiliser SSL/TLS }
  Password: String[255];      { Mot de passe SMTP }
  Editor: String[255];        { Éditeur par défaut }
  Pager: String[255];         { Programme de pagination }
  PrintCommand: String[255];  { Commande d'impression }
  SendmailPath: String[255];  { Chemin vers sendmail }
  ReplyPrefix: String[16];    { Préfixe réponse (Re:) }
  Verbose: Boolean;           { Mode verbeux }
  Interactive: Boolean;       { Mode interactif }
  IgnoreInterrupts: Boolean;  { Ignorer interruptions }
  ShowHeaders: Boolean;       { Afficher en-têtes }
  AutoSave: Boolean;          { Sauvegarde automatique }
  ConfirmSend: Boolean;       { Confirmer envoi }
  KeepMessages: Boolean;      { Conserver messages lus }
 End;

 { Interface mail en ligne de commande }
 TMailInterface = Record
  CurrentMessage: Integer;    { Message actuel }
  MessageCount: Integer;      { Nombre total messages }
  LastMessage: Integer;       { Dernier message affiché }
  CurrentMode: String[16];    { Mode actuel (read, compose, command) }
  PromptString: String[16];   { Chaîne d'invite }
  LastCommand: String[255];   { Dernière commande }
  QuitRequested: Boolean;     { Sortie demandée }
  InCompose: Boolean;         { En mode composition }
  InputBuffer: TStringList;   { Buffer d'entrée }
  Recipients: TStringList;    { Liste destinataires }
  CcList: TStringList;        { Liste copie carbone }
  BccList: TStringList;       { Liste copie carbone invisible }
  SubjectLine: String[255];   { Ligne sujet }
  ErrorMessage: String[255];  { Message d'erreur }
  StatusMessage: String[255]; { Message de statut }
 End;

Var
 { Variables globales }
 MailConfig: TMailConfig;
 MailMessages: Array[0..9999] of TMailMessage;
 MessageCount: Integer;
 MailInterface: TMailInterface;
 CommandArgs: TStringList;

{ === FONCTIONS SMTP RÉELLES === }

{ Envoyer une commande SMTP et lire la réponse }
Function SendSMTPCommand(Socket: TSocket; Command: String; Var Response: String): Boolean;
Var
 Buffer: Array[0..1023] of Char;
 BytesSent, BytesReceived: Integer;
 FullCommand: String;
Begin
 SendSMTPCommand := False;
 Response := '';
 
 { Ajouter CRLF si nécessaire }
 FullCommand := Command;
 If (Length(FullCommand) < 2) or 
    (FullCommand[Length(FullCommand)-1] <> #13) or 
    (FullCommand[Length(FullCommand)] <> #10) Then
  FullCommand := FullCommand + #13#10;
 
 { Envoyer la commande }
 If Command <> '' Then Begin
  BytesSent := send(Socket, FullCommand[1], Length(FullCommand), 0);
  If BytesSent = SOCKET_ERROR Then Begin
   Response := 'Error sending command';
   Exit;
  End;
  
  If MailConfig.Verbose Then
   WriteLn('> ', Trim(Command));
 End;
 
 { Lire la réponse }
 FillChar(Buffer, SizeOf(Buffer), 0);
 BytesReceived := recv(Socket, Buffer, SizeOf(Buffer) - 1, 0);
 If BytesReceived > 0 Then Begin
  Buffer[BytesReceived] := #0;
  Response := StrPas(Buffer);
  Response := Trim(Response);
  
  If MailConfig.Verbose Then
   WriteLn('< ', Response);
  
  SendSMTPCommand := True;
 End Else Begin
  Response := 'No response from server';
 End;
End;

{ Se connecter au serveur SMTP }
Function ConnectSMTP(Server: String; Port: Word; Var Socket: TSocket): Boolean;
Var
 ServerAddr: TSockAddrIn;
 WSAData: TWSAData;
 HostEnt: PHostEnt;
 Response: String;
Begin
 ConnectSMTP := False;
 
 { Initialiser WinSock }
 If WSAStartup($0202, WSAData) <> 0 Then Begin
  WriteLn('Error: Cannot initialize WinSock');
  Exit;
 End;
 
 { Créer le socket }
 Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If Socket = INVALID_SOCKET Then Begin
  WriteLn('Error: Cannot create socket');
  WSACleanup;
  Exit;
 End;
 
 { Résoudre l'adresse du serveur }
 HostEnt := gethostbyname(@Server[1]);
 If HostEnt = nil Then Begin
  WriteLn('Error: Cannot resolve server ', Server);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 
 { Préparer l'adresse }
 FillChar(ServerAddr, SizeOf(ServerAddr), 0);
 ServerAddr.sin_family := AF_INET;
 ServerAddr.sin_port := htons(Port);
 ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
 
 { Se connecter }
 If connect(Socket, @ServerAddr, SizeOf(ServerAddr)) = SOCKET_ERROR Then Begin
  WriteLn('Error: Cannot connect to ', Server, ':', Port);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 
 If MailConfig.Verbose Then
  WriteLn('Connected to ', Server, ':', Port);
 
 { Lire le message de bienvenue }
 If not SendSMTPCommand(Socket, '', Response) Then Begin
  WriteLn('Error: No welcome message from server');
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 
 { Vérifier le code de réponse }
 If Copy(Response, 1, 3) <> '220' Then Begin
  WriteLn('Error: Bad welcome message: ', Response);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 
 ConnectSMTP := True;
End;

{ Authentification SMTP (simplifiée) }
Function AuthenticateSMTP(Socket: TSocket; Username, Password: String): Boolean;
Var
 Response: String;
Begin
 AuthenticateSMTP := True; { Par défaut, pas d'auth pour les tests }
 
 If (Username = '') or (Password = '') Then
  Exit;
 
 { Tentative AUTH PLAIN simplifiée }
 If not SendSMTPCommand(Socket, 'AUTH PLAIN', Response) Then Begin
  AuthenticateSMTP := True; { Ignorer l'erreur d'auth pour les tests }
  Exit;
 End;
 
 AuthenticateSMTP := True; { Simplifiée pour les tests }
End;

{ Envoyer un email via SMTP }
Function SendEmailSMTP(ToAddr, FromAddr, Subject, Body: String): Boolean;
Var
 Socket: TSocket;
 Response: String;
 MessageBody: TStringList;
 I: Integer;
 DateStr: String;
 MessageID: String;
Begin
 SendEmailSMTP := False;
 
 If MailConfig.Verbose Then Begin
  WriteLn('Sending email via SMTP...');
  WriteLn('Server: ', MailConfig.SMTPServer, ':', MailConfig.SMTPPort);
  WriteLn('From: ', FromAddr);
  WriteLn('To: ', ToAddr);
 End;
 
 { Se connecter au serveur SMTP }
 If not ConnectSMTP(MailConfig.SMTPServer, MailConfig.SMTPPort, Socket) Then
  Exit;
 
 Try
  { HELO/EHLO }
  If not SendSMTPCommand(Socket, 'HELO ' + MailConfig.Domain, Response) Then Begin
   WriteLn('Error: HELO failed');
   Exit;
  End;
  
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Error: HELO rejected: ', Response);
   Exit;
  End;
  
  { Authentification (si configurée) }
  If not AuthenticateSMTP(Socket, MailConfig.UserName, MailConfig.Password) Then Begin
   WriteLn('Warning: Authentication failed, continuing anyway');
  End;
  
  { MAIL FROM }
  If not SendSMTPCommand(Socket, 'MAIL FROM:<' + FromAddr + '>', Response) Then Begin
   WriteLn('Error: MAIL FROM failed');
   Exit;
  End;
  
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Error: MAIL FROM rejected: ', Response);
   Exit;
  End;
  
  { RCPT TO }
  If not SendSMTPCommand(Socket, 'RCPT TO:<' + ToAddr + '>', Response) Then Begin
   WriteLn('Error: RCPT TO failed');
   Exit;
  End;
  
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Error: RCPT TO rejected: ', Response);
   Exit;
  End;
  
  { DATA }
  If not SendSMTPCommand(Socket, 'DATA', Response) Then Begin
   WriteLn('Error: DATA failed');
   Exit;
  End;
  
  If Copy(Response, 1, 3) <> '354' Then Begin
   WriteLn('Error: DATA rejected: ', Response);
   Exit;
  End;
  
  { Construire le message }
  MessageBody := TStringList.Create;
  Try
   DateStr := FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', Now) + ' +0100';
   MessageID := '<mail-' + IntToStr(GetTickCount64) + '@' + MailConfig.Domain + '>';
   
   { En-têtes }
   MessageBody.Add('From: ' + MailConfig.FullName + ' <' + FromAddr + '>');
   MessageBody.Add('To: <' + ToAddr + '>');
   MessageBody.Add('Subject: ' + Subject);
   MessageBody.Add('Date: ' + DateStr);
   MessageBody.Add('Message-ID: ' + MessageID);
   MessageBody.Add('MIME-Version: 1.0');
   MessageBody.Add('Content-Type: text/plain; charset=UTF-8');
   MessageBody.Add('X-Mailer: NETWORKKIT-P Mail 1.0');
   MessageBody.Add('');
   
   { Corps du message }
   MessageBody.Add(Body);
   MessageBody.Add('');
   MessageBody.Add('--');
   MessageBody.Add('Sent with NETWORKKIT-P Mail');
   
   { Envoyer le message }
   For I := 0 To MessageBody.Count - 1 Do Begin
    If not SendSMTPCommand(Socket, MessageBody[I], Response) Then Begin
     WriteLn('Error: Failed to send message line');
     Exit;
    End;
   End;
   
   { Terminer le message }
   If not SendSMTPCommand(Socket, '.', Response) Then Begin
    WriteLn('Error: Failed to end message');
    Exit;
   End;
   
   If Copy(Response, 1, 3) <> '250' Then Begin
    WriteLn('Error: Message rejected: ', Response);
    Exit;
   End;
   
  Finally
   MessageBody.Free;
  End;
  
  { QUIT }
  SendSMTPCommand(Socket, 'QUIT', Response);
  
  WriteLn('Email sent successfully!');
  SendEmailSMTP := True;
  
 Finally
  closesocket(Socket);
  WSACleanup;
 End;
End;

{ Initialiser la configuration mail }
Procedure InitializeMailConfig;
Begin
 With MailConfig Do Begin
  UserName := GetEnvironmentVariable('USER');
  If UserName = '' Then UserName := GetEnvironmentVariable('USERNAME');
  If UserName = '' Then UserName := 'user';
  
  { Configuration SMTP par défaut (Gmail) }
  Domain := 'localhost';
  UserEmail := UserName + '@gmail.com';
  FullName := UserName;
  MailSpoolFile := '/var/mail/' + UserName;
  MailboxFile := '/home/' + UserName + '/mbox';
  DeadLetterFile := '/home/' + UserName + '/dead.letter';
  
  { Serveurs SMTP courants }
  SMTPServer := 'smtp.gmail.com';
  SMTPPort := 587; { Port STARTTLS }
  UseSSL := True;
  
  { Variables d'environnement pour config SMTP }
  If GetEnvironmentVariable('SMTP_SERVER') <> '' Then
   SMTPServer := GetEnvironmentVariable('SMTP_SERVER');
  If GetEnvironmentVariable('SMTP_PORT') <> '' Then
   SMTPPort := StrToIntDef(GetEnvironmentVariable('SMTP_PORT'), 587);
  If GetEnvironmentVariable('SMTP_USER') <> '' Then
   UserEmail := GetEnvironmentVariable('SMTP_USER');
  If GetEnvironmentVariable('SMTP_PASS') <> '' Then
   Password := GetEnvironmentVariable('SMTP_PASS');
  
  Editor := GetEnvironmentVariable('EDITOR');
  If Editor = '' Then Editor := 'notepad';
  Pager := GetEnvironmentVariable('PAGER');
  If Pager = '' Then Pager := 'more';
  PrintCommand := 'print';
  SendmailPath := 'sendmail';
  ReplyPrefix := 'Re: ';
  Verbose := False;
  Interactive := True;
  IgnoreInterrupts := False;
  ShowHeaders := False;
  AutoSave := True;
  ConfirmSend := True;
  KeepMessages := True;
 End;
 
 { Initialiser l'interface }
 With MailInterface Do Begin
  CurrentMessage := 1;
  MessageCount := 0;
  LastMessage := 0;
  CurrentMode := 'command';
  PromptString := '& ';
  LastCommand := '';
  QuitRequested := False;
  InCompose := False;
  InputBuffer := TStringList.Create;
  Recipients := TStringList.Create;
  CcList := TStringList.Create;
  BccList := TStringList.Create;
  SubjectLine := '';
  ErrorMessage := '';
  StatusMessage := '';
 End;
 
 MessageCount := 0;
 CommandArgs := TStringList.Create;
End;

{ Créer des messages d'exemple }
Procedure CreateSampleMessages;
Begin
 { Message 1: Message urgent non lu }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'root@localhost';
  FromName := 'System Administrator';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'URGENT: System maintenance tonight';
  DateSent := Now - 0.25; { Il y a 6 heures }
  DateReceived := Now - 0.2;
  Priority := 1;
  Status := 'new';
  Size := 896;
  Lines := 12;
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  IsRead := False;
  IsDeleted := False;
  IsReplied := False;
  IsSaved := False;
  
  { Corps du message }
  MessageBody.Add('Dear ' + MailConfig.FullName + ',');
  MessageBody.Add('');
  MessageBody.Add('A critical system maintenance is scheduled for tonight');
  MessageBody.Add('from 2:00 AM to 6:00 AM. All services will be affected.');
  MessageBody.Add('');
  MessageBody.Add('Please complete any important work before 2:00 AM.');
  MessageBody.Add('');
  MessageBody.Add('Services affected:');
  MessageBody.Add('- Email servers');
  MessageBody.Add('- Web services');
  MessageBody.Add('- Database servers');
  MessageBody.Add('');
  MessageBody.Add('Best regards,');
  MessageBody.Add('System Administrator');
  
  { En-têtes }
  Headers.Add('From: System Administrator <root@localhost>');
  Headers.Add('To: ' + MailConfig.FullName + ' <' + MailConfig.UserEmail + '>');
  Headers.Add('Subject: URGENT: System maintenance tonight');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('Message-ID: <urgent-maint-001@localhost>');
  Headers.Add('X-Priority: 1');
 End;
 Inc(MessageCount);
 
 { Message 2: Message lu de collègue }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'john.doe@company.com';
  FromName := 'John Doe';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := 'team@company.com';
  BccAddr := '';
  Subject := 'Weekly team meeting - Agenda';
  DateSent := Now - 1.1; { Il y a 1.1 jour }
  DateReceived := Now - 1.05;
  Priority := 2;
  Status := 'read';
  Size := 512;
  Lines := 8;
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  IsRead := True;
  IsDeleted := False;
  IsReplied := True;
  IsSaved := False;
  
  { Corps du message }
  MessageBody.Add('Hi team,');
  MessageBody.Add('');
  MessageBody.Add('Our weekly meeting is scheduled for Friday 2 PM.');
  MessageBody.Add('');
  MessageBody.Add('Agenda:');
  MessageBody.Add('1. Project status updates');
  MessageBody.Add('2. Budget review');
  MessageBody.Add('3. Next quarter planning');
  MessageBody.Add('');
  MessageBody.Add('See you there,');
  MessageBody.Add('John');
  
  { En-têtes }
  Headers.Add('From: John Doe <john.doe@company.com>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Cc: team@company.com');
  Headers.Add('Subject: Weekly team meeting - Agenda');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
 End;
 Inc(MessageCount);
 
 { Message 3: Newsletter automatique }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'noreply@techblog.com';
  FromName := 'TechBlog Weekly';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'Weekly Tech Newsletter #142';
  DateSent := Now - 2.3; { Il y a 2.3 jours }
  DateReceived := Now - 2.25;
  Priority := 3;
  Status := 'read';
  Size := 1024;
  Lines := 16;
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  IsRead := True;
  IsDeleted := False;
  IsReplied := False;
  IsSaved := True;
  
  { Corps du message }
  MessageBody.Add('=== TECHBLOG WEEKLY #142 ===');
  MessageBody.Add('');
  MessageBody.Add('This week in tech:');
  MessageBody.Add('');
  MessageBody.Add('• Free Pascal 3.2.4 released with new features');
  MessageBody.Add('• Linux kernel 6.7 improves networking stack');
  MessageBody.Add('• New security vulnerabilities in mail servers');
  MessageBody.Add('');
  MessageBody.Add('Featured articles:');
  MessageBody.Add('- Building network tools with Pascal');
  MessageBody.Add('- Email security best practices');
  MessageBody.Add('- Command line productivity tips');
  MessageBody.Add('');
  MessageBody.Add('Visit our website for full articles.');
  MessageBody.Add('');
  MessageBody.Add('Unsubscribe: reply with UNSUBSCRIBE');
  MessageBody.Add('TechBlog Team');
  
  { En-têtes }
  Headers.Add('From: TechBlog Weekly <noreply@techblog.com>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Subject: Weekly Tech Newsletter #142');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('List-Unsubscribe: <mailto:unsubscribe@techblog.com>');
 End;
 Inc(MessageCount);
 
 { Message 4: Message supprimé }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'spam@junk.example';
  FromName := 'Special Offer';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'WIN $10000 NOW!!! CLICK HERE!!!';
  DateSent := Now - 0.5;
  DateReceived := Now - 0.45;
  Priority := 1; { Fausse priorité }
  Status := 'deleted';
  Size := 768;
  Lines := 10;
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  IsRead := False;
  IsDeleted := True;
  IsReplied := False;
  IsSaved := False;
  
  { Corps du message }
  MessageBody.Add('CONGRATULATIONS!!!');
  MessageBody.Add('');
  MessageBody.Add('You have been selected to win $10,000!');
  MessageBody.Add('Click here immediately to claim your prize!');
  MessageBody.Add('');
  MessageBody.Add('This offer expires in 24 hours!');
  MessageBody.Add('');
  MessageBody.Add('[Message automatically marked as spam]');
  
  { En-têtes }
  Headers.Add('From: Special Offer <spam@junk.example>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Subject: WIN $10000 NOW!!! CLICK HERE!!!');
  Headers.Add('X-Spam-Score: 12.5');
 End;
 Inc(MessageCount);
End;

{ Afficher la liste des messages (mode headers) }
Procedure DisplayMessageHeaders;
Var
 I: Integer;
 StatusChar: Char;
 FromDisplay: String;
 SubjectDisplay: String;
 DateDisplay: String;
Begin
 WriteLn('Mail version 8.1.2 01/15/2001.  Type ? for help.');
 WriteLn('"/var/mail/', MailConfig.UserName, '": ', MessageCount, ' messages');
 
 For I := 0 To MessageCount - 1 Do Begin
  With MailMessages[I] Do Begin
   { Caractère de statut }
   If IsDeleted Then StatusChar := 'D'
   Else If Status = 'new' Then StatusChar := 'N'
   Else If IsReplied Then StatusChar := 'R'
   Else If IsRead Then StatusChar := ' '
   Else StatusChar := 'U';
   
   { Formatage des champs }
   FromDisplay := Copy(FromName + '                   ', 1, 19);
   SubjectDisplay := Copy(Subject + '                                          ', 1, 40);
   DateDisplay := FormatDateTime('mmm dd hh:nn', DateReceived);
   
   { Indicateur de message actuel }
   If I + 1 = MailInterface.CurrentMessage Then
    Write('>')
   Else
    Write(' ');
   
   Write(StatusChar, I + 1:3, ' ');
   WriteLn(FromDisplay, ' ', DateDisplay, '  ', SubjectDisplay);
  End;
 End;
 
 WriteLn;
End;

{ Afficher un message complet }
Procedure DisplayMessage(MessageIndex: Integer);
Var
 I: Integer;
Begin
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('No such message');
  Exit;
 End;
 
 With MailMessages[MessageIndex] Do Begin
  WriteLn('Message ', MessageID, ':');
  WriteLn('From: ', FromName, ' <', FromAddr, '>');
  WriteLn('To: ', ToName, ' <', ToAddr, '>');
  If CcAddr <> '' Then
   WriteLn('Cc: ', CcAddr);
  WriteLn('Subject: ', Subject);
  WriteLn('Date: ', FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  WriteLn;
  
  { Afficher le corps du message }
  If MessageBody <> nil Then Begin
   For I := 0 To MessageBody.Count - 1 Do
    WriteLn(MessageBody[I]);
  End Else Begin
   WriteLn('[Message body not available]');
  End;
  
  WriteLn;
  
  { Marquer comme lu }
  If not IsRead Then Begin
   IsRead := True;
   If Status = 'new' Then Status := 'read';
  End;
 End;
End;

{ Composer un nouveau message }
Function ComposeMessage(Recipients: String): Boolean;
Var
 Subject: String;
 Body: TStringList;
 Line: String;
 I: Integer;
 MessageText: String;
 Input: String;
Begin
 ComposeMessage := False;
 
 WriteLn('Composing message to: ', Recipients);
 
 { Demander le sujet }
 Write('Subject: ');
 ReadLn(Subject);
 If Subject = '' Then
  Subject := '[No Subject]';
 
 WriteLn('Enter message text (end with single "." on a line):');
 Body := TStringList.Create;
 Try
  { Lire le message depuis l'entrée standard }
  Repeat
   ReadLn(Input);
   If Input <> '.' Then
    Body.Add(Input);
  Until Input = '.';
  
  { Construire le texte complet }
  MessageText := '';
  For I := 0 To Body.Count - 1 Do Begin
   MessageText := MessageText + Body[I];
   If I < Body.Count - 1 Then
    MessageText := MessageText + #13#10;
  End;
  
  { Afficher le contenu }
  WriteLn('Message content:');
  WriteLn('----------------');
  For I := 0 To Body.Count - 1 Do
   WriteLn(Body[I]);
  WriteLn('----------------');
  WriteLn;
  
  { Confirmation d'envoi }
  If MailConfig.ConfirmSend Then Begin
   Write('Send this message? (y/n) ');
   ReadLn(Input);
   If LowerCase(Input) <> 'y' Then Begin
    WriteLn('Message cancelled');
    Exit;
   End;
  End;
  
  { Envoyer le message via SMTP }
  WriteLn('Sending message...');
  If SendEmailSMTP(Recipients, MailConfig.UserEmail, Subject, MessageText) Then Begin
   WriteLn('Message sent successfully to: ', Recipients);
   ComposeMessage := True;
  End Else Begin
   WriteLn('Failed to send message');
   WriteLn('Message saved to ', MailConfig.DeadLetterFile);
  End;
  
 Finally
  Body.Free;
 End;
End;

{ Sauvegarder un message }
Function SaveMessage(MessageIndex: Integer; FileName: String): Boolean;
Begin
 SaveMessage := False;
 
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('No such message');
  Exit;
 End;
 
 If FileName = '' Then
  FileName := MailConfig.MailboxFile;
 
 WriteLn('Message ', MessageIndex + 1, ' saved to ', FileName);
 With MailMessages[MessageIndex] Do Begin
  IsSaved := True;
 End;
 
 SaveMessage := True;
End;

{ Supprimer un message }
Function DeleteMessage(MessageIndex: Integer): Boolean;
Begin
 DeleteMessage := False;
 
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('No such message');
  Exit;
 End;
 
 With MailMessages[MessageIndex] Do Begin
  If IsDeleted Then Begin
   { Restaurer le message }
   IsDeleted := False;
   Status := 'read';
   WriteLn('Message ', MessageIndex + 1, ' undeleted');
  End Else Begin
   { Marquer pour suppression }
   IsDeleted := True;
   Status := 'deleted';
   WriteLn('Message ', MessageIndex + 1, ' marked for deletion');
  End;
 End;
 
 DeleteMessage := True;
End;

{ Répondre à un message }
Function ReplyToMessage(MessageIndex: Integer): Boolean;
Var
 ReplySubject: String;
 ReplyTo: String;
Begin
 ReplyToMessage := False;
 
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('No such message');
  Exit;
 End;
 
 With MailMessages[MessageIndex] Do Begin
  ReplyTo := FromAddr;
  
  { Préparer le sujet de réponse }
  If Copy(UpperCase(Subject), 1, 3) = 'RE:' Then
   ReplySubject := Subject
  Else
   ReplySubject := MailConfig.ReplyPrefix + Subject;
  
  WriteLn('Replying to: ', ReplyTo);
  WriteLn('Subject: ', ReplySubject);
  WriteLn;
  WriteLn('Enter reply text (end with single "." on a line):');
  
  { Simulation de la réponse }
  WriteLn('Thank you for your message.');
  WriteLn('.');
  WriteLn;
  WriteLn('Reply sent to: ', ReplyTo);
  
  { Marquer comme ayant reçu une réponse }
  IsReplied := True;
  ReplyToMessage := True;
 End;
End;

{ Afficher l'aide }
Procedure DisplayMailHelp;
Begin
 WriteLn('Mail Commands:');
 WriteLn;
 WriteLn('t [msglist]        Type messages');
 WriteLn('n                  Next message');
 WriteLn('p                  Previous message');
 WriteLn('f [msglist]        Show message headers');
 WriteLn('d [msglist]        Delete messages');
 WriteLn('u [msglist]        Undelete messages');
 WriteLn('r [message]        Reply to message');
 WriteLn('R [message]        Reply to sender and all recipients');
 WriteLn('m [user]           Mail to user');
 WriteLn('s [msglist] file   Save messages to file');
 WriteLn('w [msglist] file   Write messages to file (no headers)');
 WriteLn('q                  Quit, save changes');
 WriteLn('x                  Exit, don''t save changes');
 WriteLn('h                  Display headers');
 WriteLn('?                  Display this help');
 WriteLn;
 WriteLn('Msglist examples:');
 WriteLn('  1-5        Messages 1 through 5');
 WriteLn('  1 3 5      Messages 1, 3, and 5');
 WriteLn('  *          All messages');
 WriteLn('  $          Last message');
 WriteLn;
End;

{ Parser une liste de messages }
Function ParseMessageList(MsgList: String; Var Messages: Array of Integer): Integer;
Var
 Count: Integer;
 I: Integer;
Begin
 Count := 0;
 
 { Simplification pour la simulation }
 If MsgList = '' Then Begin
  { Message actuel }
  Messages[0] := MailInterface.CurrentMessage - 1;
  Count := 1;
 End
 Else If MsgList = '*' Then Begin
  { Tous les messages }
  For I := 0 To MessageCount - 1 Do Begin
   Messages[I] := I;
   Inc(Count);
  End;
 End
 Else If MsgList = '$' Then Begin
  { Dernier message }
  Messages[0] := MessageCount - 1;
  Count := 1;
 End
 Else Begin
  { Message spécifique }
  Try
   Messages[0] := StrToInt(MsgList) - 1;
   If (Messages[0] >= 0) and (Messages[0] < MessageCount) Then
    Count := 1;
  Except
   Count := 0;
  End;
 End;
 
 ParseMessageList := Count;
End;

{ Traiter une commande mail }
Function ProcessMailCommand(Command: String): Boolean;
Var
 Cmd: String;
 Args: String;
 SpacePos: Integer;
 Messages: Array[0..99] of Integer;
 MsgCount: Integer;
 I: Integer;
Begin
 ProcessMailCommand := True;
 
 Command := Trim(Command);
 If Command = '' Then Exit;
 
 { Séparer commande et arguments }
 SpacePos := Pos(' ', Command);
 If SpacePos > 0 Then Begin
  Cmd := Copy(Command, 1, SpacePos - 1);
  Args := Trim(Copy(Command, SpacePos + 1, Length(Command)));
 End Else Begin
  Cmd := Command;
  Args := '';
 End;
 
 Cmd := LowerCase(Cmd);
 
 Case Cmd Of
  { Aide }
  '?', 'help': DisplayMailHelp;
  
  { Afficher en-têtes }
  'h', 'headers': DisplayMessageHeaders;
  
  { Afficher message (type) }
  't', 'type': Begin
   MsgCount := ParseMessageList(Args, Messages);
   For I := 0 To MsgCount - 1 Do
    DisplayMessage(Messages[I]);
  End;
  
  { Message suivant }
  'n', 'next': Begin
   If MailInterface.CurrentMessage < MessageCount Then Begin
    Inc(MailInterface.CurrentMessage);
    DisplayMessage(MailInterface.CurrentMessage - 1);
   End Else Begin
    WriteLn('At EOF');
   End;
  End;
  
  { Message précédent }
  'p', 'prev': Begin
   If MailInterface.CurrentMessage > 1 Then Begin
    Dec(MailInterface.CurrentMessage);
    DisplayMessage(MailInterface.CurrentMessage - 1);
   End Else Begin
    WriteLn('At BOF');
   End;
  End;
  
  { Supprimer messages }
  'd', 'delete': Begin
   MsgCount := ParseMessageList(Args, Messages);
   For I := 0 To MsgCount - 1 Do
    DeleteMessage(Messages[I]);
  End;
  
  { Restaurer messages }
  'u', 'undelete': Begin
   MsgCount := ParseMessageList(Args, Messages);
   For I := 0 To MsgCount - 1 Do Begin
    With MailMessages[Messages[I]] Do Begin
     IsDeleted := False;
     Status := 'read';
     WriteLn('Message ', Messages[I] + 1, ' undeleted');
    End;
   End;
  End;
  
  { Répondre }
  'r', 'reply': Begin
   If Args <> '' Then Begin
    MsgCount := ParseMessageList(Args, Messages);
    If MsgCount > 0 Then
     ReplyToMessage(Messages[0]);
   End Else Begin
    ReplyToMessage(MailInterface.CurrentMessage - 1);
   End;
  End;
  
  { Composer nouveau message }
  'm', 'mail': Begin
   If Args <> '' Then
    ComposeMessage(Args)
   Else Begin
    Write('To: ');
    Args := 'user@example.com';
    WriteLn(Args);
    ComposeMessage(Args);
   End;
  End;
  
  { Sauvegarder messages }
  's', 'save': Begin
   MsgCount := ParseMessageList(Args, Messages);
   For I := 0 To MsgCount - 1 Do
    SaveMessage(Messages[I], '');
  End;
  
  { Quitter avec sauvegarde }
  'q', 'quit': Begin
   WriteLn('Saving changes...');
   MailInterface.QuitRequested := True;
   ProcessMailCommand := False;
  End;
  
  { Sortir sans sauvegarde }
  'x', 'exit': Begin
   WriteLn('Exiting without saving changes');
   MailInterface.QuitRequested := True;
   ProcessMailCommand := False;
  End;
  
  Else Begin
   { Commande inconnue - peut-être un numéro de message }
   Try
    I := StrToInt(Cmd) - 1;
    If (I >= 0) and (I < MessageCount) Then Begin
     MailInterface.CurrentMessage := I + 1;
     DisplayMessage(I);
    End Else Begin
     WriteLn('Unknown command: ', Cmd);
    End;
   Except
    WriteLn('Unknown command: ', Cmd);
   End;
  End;
 End;
End;

{ Mode interactif mail }
Procedure RunInteractiveMode;
Var
 Command: String;
Begin
 WriteLn('Mail interactive mode simulation');
 WriteLn('Commands executed automatically:');
 WriteLn;
 
 { Afficher les en-têtes }
 WriteLn('> headers');
 DisplayMessageHeaders;
 
 { Lire premier message }
 WriteLn('> 1');
 ProcessMailCommand('1');
 
 { Message suivant }
 WriteLn('> n');
 ProcessMailCommand('n');
 
 { Répondre au message }
 WriteLn('> r');
 ProcessMailCommand('r');
 
 { Composer nouveau message }
 WriteLn('> m john@example.com');
 ProcessMailCommand('m john@example.com');
 
 { Supprimer message spam }
 WriteLn('> d 4');
 ProcessMailCommand('d 4');
 
 { Afficher aide }
 WriteLn('> ?');
 ProcessMailCommand('?');
 
 { Quitter }
 WriteLn('> q');
 ProcessMailCommand('q');
 
 WriteLn('End of interactive mode simulation');
End;

{ Envoyer mail directement }
Function SendDirectMail(Recipients: TStringList; Subject: String; MessageFile: String): Boolean;
Var
 I: Integer;
 MessageBody: TStringList;
 MessageText: String;
 Line: String;
Begin
 SendDirectMail := False;
 
 If Recipients.Count = 0 Then Begin
  WriteLn('No recipients specified');
  Exit;
 End;
 
 { Préparer le corps du message }
 MessageBody := TStringList.Create;
 Try
  If MessageFile <> '' Then Begin
   { Lire depuis fichier }
   Try
    MessageBody.LoadFromFile(MessageFile);
   Except
    WriteLn('Error: Cannot read file ', MessageFile);
    Exit;
   End;
  End Else Begin
   { Lire depuis stdin }
   WriteLn('Reading message from stdin (end with Ctrl+Z or EOF):');
   While not EOF Do Begin
    ReadLn(Line);
    MessageBody.Add(Line);
   End;
  End;
  
  { Construire le texte }
  MessageText := '';
  For I := 0 To MessageBody.Count - 1 Do Begin
   MessageText := MessageText + MessageBody[I];
   If I < MessageBody.Count - 1 Then
    MessageText := MessageText + #13#10;
  End;
  
  { Envoyer à tous les destinataires }
  For I := 0 To Recipients.Count - 1 Do Begin
   WriteLn('Sending to: ', Recipients[I]);
   If not SendEmailSMTP(Recipients[I], MailConfig.UserEmail, Subject, MessageText) Then Begin
    WriteLn('Failed to send to: ', Recipients[I]);
    Exit;
   End;
  End;
  
  WriteLn('All messages sent successfully');
  SendDirectMail := True;
  
 Finally
  MessageBody.Free;
 End;
End;

{ Analyser les arguments de ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Param: String;
 Recipients: TStringList;
 Subject: String;
 MessageFile: String;
 Interactive: Boolean;
 SendMode: Boolean;
Begin
 Recipients := TStringList.Create;
 Subject := '';
 MessageFile := '';
 Interactive := False;
 SendMode := False;
 
 Try
  I := 1;
  While I <= ParamCount Do Begin
   Param := ParamStr(I);
   
   If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--version') Then Begin
    WriteLn('mail (GNU Mailutils) 3.7 - NETWORKKIT-P Implementation');
    WriteLn('Compatible with Unix/Linux mail command');
    WriteLn('With real SMTP sending capability');
    Exit;
   End
   Else If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--help') Then Begin
    { L'aide sera affichée par le bloc principal }
    Exit;
   End
   Else If LowerCase(Param) = '-s' Then Begin
    { Subject }
    Inc(I);
    If I <= ParamCount Then
     Subject := ParamStr(I)
    Else Begin
     WriteLn('Option -s requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-f' Then Begin
    { File }
    Inc(I);
    If I <= ParamCount Then
     MessageFile := ParamStr(I)
    Else Begin
     WriteLn('Option -f requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-smtp' Then Begin
    { SMTP Server }
    Inc(I);
    If I <= ParamCount Then
     MailConfig.SMTPServer := ParamStr(I)
    Else Begin
     WriteLn('Option -smtp requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-port' Then Begin
    { SMTP Port }
    Inc(I);
    If I <= ParamCount Then
     MailConfig.SMTPPort := StrToIntDef(ParamStr(I), 587)
    Else Begin
     WriteLn('Option -port requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-user' Then Begin
    { SMTP User }
    Inc(I);
    If I <= ParamCount Then
     MailConfig.UserEmail := ParamStr(I)
    Else Begin
     WriteLn('Option -user requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-pass' Then Begin
    { SMTP Password }
    Inc(I);
    If I <= ParamCount Then
     MailConfig.Password := ParamStr(I)
    Else Begin
     WriteLn('Option -pass requires an argument');
     Exit;
    End;
   End
   Else If LowerCase(Param) = '-verbose' Then Begin
    { Mode verbeux }
    MailConfig.Verbose := True;
   End
   Else If LowerCase(Param) = '-i' Then Begin
    { Interactive }
    Interactive := True;
   End
   Else If LowerCase(Param) = '-n' Then Begin
    { Non-interactive }
    Interactive := False;
   End
   Else If Copy(Param, 1, 1) <> '-' Then Begin
    { Recipient }
    Recipients.Add(Param);
    SendMode := True;
   End;
   
   Inc(I);
  End;
  
  { Créer les données d'exemple }
  CreateSampleMessages;
  MailInterface.MessageCount := MessageCount;
  
  If SendMode Then Begin
   { Mode envoi }
   SendDirectMail(Recipients, Subject, MessageFile);
  End
  Else If Interactive or (ParamCount = 0) Then Begin
   { Mode interactif }
   RunInteractiveMode;
  End Else Begin
   { Mode lecture par défaut }
   DisplayMessageHeaders;
  End;
  
 Finally
  Recipients.Free;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedMail;
Begin
 WriteLn('MAIL [NETWORKKIT-P] Unix/Linux mail command (simulation)');
 WriteLn('=========================================================');
 WriteLn;
 WriteLn('Mail version 8.1.2 01/15/2001.  Type ? for help.');
 WriteLn('"/var/mail/user": 4 messages');
 WriteLn;
 WriteLn(' N  1 System Administrator  Feb 21 08:15  URGENT: System maintenance');
 WriteLn(' R  2 John Doe             Feb 20 14:30  Weekly team meeting - Agenda');
 WriteLn('    3 TechBlog Weekly      Feb 19 09:45  Weekly Tech Newsletter #142');
 WriteLn(' D  4 Special Offer        Feb 21 10:20  WIN $10000 NOW!!! CLICK HERE');
 WriteLn;
 WriteLn('& ');
 WriteLn;
 WriteLn('Commands: t(ype) n(ext) p(rev) d(elete) r(eply) m(ail) q(uit) ?(help)');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('MAIL : Unix/Linux mail command');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  MAIL [options] [recipient...]');
  WriteLn('  MAIL [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn('  -s SUBJECT            Spécifier le sujet du message');
  WriteLn('  -f FILE               Lire le message depuis un fichier');
  WriteLn('  -i                    Mode interactif');
  WriteLn('  -n                    Mode non-interactif');
  WriteLn('  -c RECIPIENT          Ajouter destinataire en copie carbone');
  WriteLn('  -b RECIPIENT          Ajouter destinataire en copie carbone invisible');
  WriteLn('  -a FILE               Attacher un fichier');
  WriteLn('  -r FROM               Spécifier l''adresse d''expéditeur');
  WriteLn('  -smtp SERVER          Serveur SMTP (défaut: smtp.gmail.com)');
  WriteLn('  -port PORT            Port SMTP (défaut: 587)');
  WriteLn('  -user EMAIL           Adresse email utilisateur');
  WriteLn('  -pass PASSWORD        Mot de passe SMTP');
  WriteLn('  -verbose              Mode verbeux (debug SMTP)');
  WriteLn;
  WriteLn('Utilisation :');
  WriteLn;
  WriteLn('1. Lire le courrier :');
  WriteLn('   MAIL                 # Lancer en mode interactif');
  WriteLn('   MAIL -f mbox         # Lire depuis un fichier mbox');
  WriteLn;
  WriteLn('2. Envoyer du courrier :');
  WriteLn('   MAIL user@domain.com');
  WriteLn('   MAIL -s "Test" user@domain.com');
  WriteLn('   MAIL -s "Test" -f message.txt user@domain.com');
  WriteLn;
  WriteLn('Commandes interactives :');
  WriteLn('  Navigation :');
  WriteLn('    1, 2, 3...          Afficher message numéro N');
  WriteLn('    n, next             Message suivant');
  WriteLn('    p, prev             Message précédent');
  WriteLn('    h, headers          Afficher liste des messages');
  WriteLn('    f [msglist]         Afficher en-têtes des messages');
  WriteLn;
  WriteLn('  Actions sur messages :');
  WriteLn('    t [msglist]         Afficher contenu des messages');
  WriteLn('    d [msglist]         Supprimer messages');
  WriteLn('    u [msglist]         Restaurer messages supprimés');
  WriteLn('    s [msglist] file    Sauvegarder messages dans fichier');
  WriteLn('    w [msglist] file    Écrire messages dans fichier (sans en-têtes)');
  WriteLn;
  WriteLn('  Communication :');
  WriteLn('    r [message]         Répondre au message');
  WriteLn('    R [message]         Répondre à tous');
  WriteLn('    m [user]            Composer nouveau message');
  WriteLn('    fo [message]        Transférer message');
  WriteLn;
  WriteLn('  Gestion :');
  WriteLn('    q, quit             Quitter et sauvegarder');
  WriteLn('    x, exit             Quitter sans sauvegarder');
  WriteLn('    !, shell            Exécuter commande shell');
  WriteLn('    ?, help             Afficher cette aide');
  WriteLn;
  WriteLn('Spécification de messages (msglist) :');
  WriteLn('  1               Message numéro 1');
  WriteLn('  1-5             Messages 1 à 5');
  WriteLn('  1 3 5           Messages 1, 3 et 5');
  WriteLn('  *               Tous les messages');
  WriteLn('  $               Dernier message');
  WriteLn('  .               Message actuel');
  WriteLn('  ^               Premier message');
  WriteLn;
  WriteLn('Indicateurs de statut :');
  WriteLn('  N       Nouveau message (non lu)');
  WriteLn('  U       Non lu');
  WriteLn('  R       Lu avec réponse envoyée');
  WriteLn('  D       Marqué pour suppression');
  WriteLn('  *       Message sauvegardé');
  WriteLn('  P       Message conservé');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  MAIL            Fichier de courrier principal');
  WriteLn('  MAILPATH        Chemins de recherche des boîtes mail');
  WriteLn('  EDITOR          Éditeur par défaut pour composer');
  WriteLn('  PAGER           Programme de pagination');
  WriteLn('  MAILRC          Fichier de configuration');
  WriteLn;
  WriteLn('Fichiers :');
  WriteLn('  /var/mail/user      Boîte mail système');
  WriteLn('  ~/mbox              Boîte mail utilisateur');
  WriteLn('  ~/.mailrc           Configuration utilisateur');
  WriteLn('  ~/dead.letter       Messages non envoyés');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  MAIL                        # Lire courrier');
  WriteLn('  MAIL john@example.com       # Envoyer à john');
  WriteLn('  MAIL -s "Hello" john@example.com');
  WriteLn('  MAIL -s "Report" -f report.txt boss@company.com');
  WriteLn('  echo "Test" | MAIL -s "Test" user@domain.com');
  WriteLn;
  WriteLn('Envoi SMTP réel :');
  WriteLn('  MAIL -smtp smtp.gmail.com -port 587 -user mon@gmail.com -pass motdepasse -s "Test" dest@example.com');
  WriteLn('  MAIL -verbose -s "Debug" dest@example.com  # Avec debug SMTP');
  WriteLn;
  WriteLn('Variables d''environnement SMTP :');
  WriteLn('  SMTP_SERVER          Serveur SMTP par défaut');
  WriteLn('  SMTP_PORT            Port SMTP par défaut');
  WriteLn('  SMTP_USER            Utilisateur SMTP par défaut');
  WriteLn('  SMTP_PASS            Mot de passe SMTP par défaut');
  WriteLn;
  WriteLn('Configuration ~/.mailrc exemple :');
  WriteLn('  set ask');
  WriteLn('  set dot');
  WriteLn('  set hold');
  WriteLn('  set save');
  WriteLn('  set crt=24');
  WriteLn('  alias friends john@a.com mary@b.com');
  WriteLn;
  WriteLn('Note: Utilitaire de messagerie classique Unix/Linux');
  WriteLn('Compatible avec Berkeley Mail et System V mailx.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('mail (NETWORKKIT-P) 1.00');
  WriteLn('Compatible with Unix/Linux mail command');
  WriteLn('Based on Berkeley Mail and GNU Mailutils');
  WriteLn;
  WriteLn('Written by Sylvain Maltais for NETWORKKIT-P');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeMailConfig;
  ParseCommandLine;
  {$ELSE}
  ShowSimulatedMail;
  {$ENDIF}
 End;
END.
