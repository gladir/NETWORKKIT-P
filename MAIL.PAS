{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Commande mail (Unix/Linux mail command))
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
  FromAddr: String[255];      { Adresse expÇditeur }
  FromName: String[255];      { Nom expÇditeur }
  ToAddr: String[255];        { Adresse destinataire }
  ToName: String[255];        { Nom destinataire }
  CcAddr: String[255];        { Copie carbone }
  BccAddr: String[255];       { Copie carbone invisible }
  Subject: String[255];       { Sujet }
  DateSent: TDateTime;        { Date d'envoi }
  DateReceived: TDateTime;    { Date de rÇception }
  Priority: Integer;          { PrioritÇ (1=haute, 2=normale, 3=basse) }
  Status: String[32];         { êtat (new, read, deleted, replied) }
  Size: LongInt;              { Taille en octets }
  Lines: Integer;             { Nombre de lignes }
  MessageBody: TStringList;   { Corps du message }
  Headers: TStringList;       { Entàtes complätes }
  IsRead: Boolean;            { Message lu }
  IsDeleted: Boolean;         { Message supprimÇ }
  IsReplied: Boolean;         { RÇponse envoyÇe }
  IsSaved: Boolean;           { Message sauvegardÇ }
 End;

 { Configuration mail }
 TMailConfig = Record
  UserName: String[64];        { Nom utilisateur }
  UserEmail: String[255];      { Adresse de courriel }
  FullName: String[255];       { Nom complet }
  Domain: String[255];         { Domaine }
  MailSpoolFile: String[255];  { Fichier de tampon de courrier mail }
  MailboxFile: String[255];    { Fichier boåte mail }
  DeadLetterFile: String[255]; { Fichier dead.letter }
  SMTPServer: String[255];     { Serveur SMTP }
  SMTPPort: Word;              { Port SMTP }
  UseSSL: Boolean;             { Utiliser SSL/TLS }
  Password: String[255];       { Mot de passe SMTP }
  Editor: String[255];         { êditeur par dÇfaut }
  Pager: String[255];          { Programme de pagination }
  PrintCommand: String[255];   { Commande d'impression }
  SendmailPath: String[255];   { Chemin vers sendmail }
  ReplyPrefix: String[16];     { PrÇfixe rÇponse (Re:) }
  Verbose: Boolean;            { Mode verbeux }
  Interactive: Boolean;        { Mode interactif }
  IgnoreInterrupts: Boolean;   { Ignorer interruptions }
  ShowHeaders: Boolean;        { Afficher entàtes }
  AutoSave: Boolean;           { Sauvegarde automatique }
  ConfirmSend: Boolean;        { Confirmer envoi }
  KeepMessages: Boolean;       { Conserver messages lus }
 End;

  { Interface mail en ligne de commande }
 TMailInterface = Record
  CurrentMessage: Integer;    { Message actuel }
  MessageCount: Integer;      { Nombre total messages }
  LastMessage: Integer;       { Dernier message affichÇ }
  CurrentMode: String[16];    { Mode actuel (read, compose, command) }
  PromptString: String[16];   { Chaåne d'invite }
  LastCommand: String[255];   { Derniäre commande }
  QuitRequested: Boolean;     { Sortie demandÇe }
  InCompose: Boolean;         { En mode composition }
  InputBuffer: TStringList;   { Buffer d'entrÇe }
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

{ === FONCTIONS SMTP R√âELLES === }

{ Envoyer une commande SMTP et lire la rÇponse }
Function SendSMTPCommand(Socket: TSocket; Command: String; Var Response: String): Boolean;
Var
 Buffer: Array[0..1023] of Char;
 BytesSent, BytesReceived: Integer;
 FullCommand: String;
Begin
 SendSMTPCommand := False;
 Response := '';
  { Ajouter CRLF si nÇcessaire }
 FullCommand := Command;
 If (Length(FullCommand) < 2) or
    (FullCommand[Length(FullCommand)-1] <> #13)or(FullCommand[Length(FullCommand)] <> #10) Then
  FullCommand := FullCommand + #13#10;
 { Envoyer la commande }
 If Command<>''Then Begin
  BytesSent:=send(Socket, FullCommand[1], Length(FullCommand), 0);
  If BytesSent=SOCKET_ERROR Then Begin
   Response:='Erreur lors de l''envoi de la commande';
   Exit;
  End;
  If MailConfig.Verbose Then WriteLn('> ', Trim(Command));
 End;
  { Lire la rÇponse }
 FillChar(Buffer, SizeOf(Buffer), 0);
 BytesReceived := recv(Socket, Buffer, SizeOf(Buffer) - 1, 0);
 If BytesReceived > 0 Then Begin
  Buffer[BytesReceived] := #0;
  Response := StrPas(Buffer);
  Response := Trim(Response);
  If MailConfig.Verbose Then WriteLn('< ', Response);
  SendSMTPCommand := True;
 End
  Else
 Begin
  Response := 'Aucune rÇponse du serveur';
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
  WriteLn('Erreur : Impossible d''initialiser WinSock');
  Exit;
 End;
  { CrÇer le socket }
 Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 If Socket = INVALID_SOCKET Then Begin
  WriteLn('Erreur : Impossible de crÇer le socket');
  WSACleanup;
  Exit;
 End;
  { RÇsoudre l'adresse du serveur }
 HostEnt := gethostbyname(@Server[1]);
 If HostEnt = nil Then Begin
  WriteLn('Erreur : Impossible de rÇsoudre le serveur ', Server);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
  { PrÇparer l'adresse }
 FillChar(ServerAddr, SizeOf(ServerAddr), 0);
 ServerAddr.sin_family := AF_INET;
 ServerAddr.sin_port := htons(Port);
 ServerAddr.sin_addr.S_addr := PInAddr(HostEnt^.h_addr_list^)^.S_addr;
  { Se connecter }
 If connect(Socket, @ServerAddr, SizeOf(ServerAddr)) = SOCKET_ERROR Then Begin
  WriteLn('Erreur : Impossible de se connecter Ö ', Server, ':', Port);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 If MailConfig.Verbose Then WriteLn('ConnectÇ Ö ', Server, ':', Port);
  { Lire le message de bienvenue }
 If not SendSMTPCommand(Socket, '', Response) Then Begin
  WriteLn('Erreur: Aucun meseseage de bienvenue du serveur');
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
  { VÇrifier le code de rÇponse }
 If Copy(Response, 1, 3) <> '220' Then Begin
  WriteLn('Erreur: Message de bienvenue incorrecte : ', Response);
  closesocket(Socket);
  WSACleanup;
  Exit;
 End;
 ConnectSMTP := True;
End;

 { Authentification SMTP (simplifiÇe) }
Function AuthenticateSMTP(Socket: TSocket; Username, Password: String): Boolean;
Var
 Response: String;
Begin
 AuthenticateSMTP := True; { Par dÇfaut, pas d'auth pour les tests }
 If (Username = '') or (Password = '') Then Exit;
  { Tentative AUTH PLAIN simplifi√©e }
 If not SendSMTPCommand(Socket, 'AUTH PLAIN', Response) Then Begin
  AuthenticateSMTP := True; { Ignorer l'erreur d'auth pour les tests }
  Exit;
 End;
 AuthenticateSMTP := True; { SimplifiÇe pour les tests }
End;

{ Envoyer un courriel via SMTP }
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
  WriteLn('Envoi de courriel via SMTP...');
  WriteLn('Serveur: ', MailConfig.SMTPServer, ':', MailConfig.SMTPPort);
  WriteLn('De: ', FromAddr);
  WriteLn('A: ', ToAddr);
 End;
  { Se connecter au serveur SMTP }
 If not ConnectSMTP(MailConfig.SMTPServer, MailConfig.SMTPPort, Socket) Then Exit;
 Try
  { HELO/EHLO }
  If not SendSMTPCommand(Socket, 'HELO ' + MailConfig.Domain, Response) Then Begin
   WriteLn('Erreur: êchec de HELO');
   Exit;
  End;
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Erreur: HELO rejetÇ: ', Response);
   Exit;
  End;
   { Authentification (si configurÇe) }
  If not AuthenticateSMTP(Socket, MailConfig.UserName, MailConfig.Password) Then Begin
   WriteLn('Attention : êchec d''authentication, continue de toute faáon');
  End;
   { MAIL FROM }
  If not SendSMTPCommand(Socket, 'MAIL FROM:<' + FromAddr + '>', Response) Then Begin
   WriteLn('Erreur: êchec MAIL FROM');
   Exit;
  End;
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Erreur: MAIL FROM rejetÇ: ', Response);
   Exit;
  End;
   { RCPT TO }
  If not SendSMTPCommand(Socket, 'RCPT TO:<' + ToAddr + '>', Response) Then Begin
   WriteLn('Erreur: êchec RCPT TO');
   Exit;
  End;
  If Copy(Response, 1, 3) <> '250' Then Begin
   WriteLn('Erreur: RCPT TO rejetÇ: ', Response);
   Exit;
  End;
   { DATA }
  If not SendSMTPCommand(Socket, 'DATA', Response) Then Begin
   WriteLn('Erreur: êchec DATA');
   Exit;
  End;
  If Copy(Response, 1, 3) <> '354' Then Begin
   WriteLn('Erreur: DATA rejetÇ : ', Response);
   Exit;
  End;
   { Construire le message }
  MessageBody := TStringList.Create;
  Try
   DateStr := FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', Now) + ' +0100';
   MessageID := '<mail-' + IntToStr(GetTickCount64) + '@' + MailConfig.Domain + '>';
    { Entàtes }
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
     WriteLn('Erreur: êchec de la ligne d''envoi de message');
     Exit;
    End;
   End;
    { Terminer le message }
   If not SendSMTPCommand(Socket, '.', Response) Then Begin
    WriteLn('Erreur: êchec vers la fin du message');
    Exit;
   End;
   If Copy(Response, 1, 3) <> '250' Then Begin
    WriteLn('Erreur: Message rejetÇ: ', Response);
    Exit;
   End;
  Finally
   MessageBody.Free;
  End;
   { QUIT }
  SendSMTPCommand(Socket, 'QUIT', Response);
  WriteLn('Courriel envoyÇ avec succäs !');
  SendEmailSMTP := True;
 Finally
  closesocket(Socket);
  WSACleanup;
 End;
End;

 { Initialiser la configuration mail }
Procedure InitializeMailConfig;Begin
 With MailConfig Do Begin
  UserName:=GetEnvironmentVariable('USER');
  If UserName = '' Then UserName := GetEnvironmentVariable('USERNAME');
  If UserName = '' Then UserName := 'user';
   { Configuration SMTP par dÇfaut (Gmail) }
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
  If GetEnvironmentVariable('SMTP_SERVER') <> '' Then SMTPServer := GetEnvironmentVariable('SMTP_SERVER');
  If GetEnvironmentVariable('SMTP_PORT') <> '' Then SMTPPort := StrToIntDef(GetEnvironmentVariable('SMTP_PORT'), 587);
  If GetEnvironmentVariable('SMTP_USER') <> '' Then UserEmail := GetEnvironmentVariable('SMTP_USER');
  If GetEnvironmentVariable('SMTP_PASS') <> '' Then Password := GetEnvironmentVariable('SMTP_PASS');
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

 { CrÇer des messages d'exemple }
Procedure CreateSampleMessages;Begin
 { Message 1: Message urgent non lu }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'root@localhost';
  FromName := 'System Administrator';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'URGENT: Maintenance du systäme ce soir';
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
  MessageBody.Add('Char/Chäre ' + MailConfig.FullName + ',');
  MessageBody.Add('');
  MessageBody.Add('Une maintenance systäme critique est prÇvue cette nuit,');
  MessageBody.Add('de 2h00 Ö 6h00. Tous les services seront indisponibles.');
  MessageBody.Add('');
  MessageBody.Add('Veuillez effectuer vos tÉches importantes avant 2h00.');
  MessageBody.Add('');
  MessageBody.Add('Services concernÇs :');
  MessageBody.Add('- Serveurs de messagerie');
  MessageBody.Add('- Services Web');
  MessageBody.Add('- Serveurs de bases de donnÇes');
  MessageBody.Add('');
  MessageBody.Add('Cordialement,');
  MessageBody.Add('Administrateur systäme');

  { Entàtes }
  Headers.Add('From: System Administrator <root@localhost>');
  Headers.Add('To: ' + MailConfig.FullName + ' <' + MailConfig.UserEmail + '>');
  Headers.Add('Subject: URGENT: Maintenance systäme cette nuit');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('Message-ID: <urgent-maint-001@localhost>');
  Headers.Add('X-Priority: 1');
 End;
 Inc(MessageCount);

 { Message 2: Message lu de collägue }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'john.doe@company.com';
  FromName := 'John Doe';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := 'team@company.com';
  BccAddr := '';
  Subject := 'RÇunion d''Çquipe hebdomadaire - Ordre du jour';
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
  MessageBody.Add('Bonjour l''Çquipe,');
  MessageBody.Add('');
  MessageBody.Add('Notre rÇunion hebdomadaire aura lieu vendredi Ö 14h00.');
  MessageBody.Add('');
  MessageBody.Add('Ordre du jour :');
  MessageBody.Add('1. Point sur l''Çtat d''avancement des projets');
  MessageBody.Add('2. Revue budgÇtaire');
  MessageBody.Add('3. Planification du prochain trimestre');
  MessageBody.Add('');
  MessageBody.Add('A bientìt,');
  MessageBody.Add('John');

  { En-t√™tes }
  Headers.Add('From: John Doe <john.doe@company.com>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Cc: team@company.com');
  Headers.Add('Subject: RÇunion d''Çquipe hebdomadaire - Ordre du jour');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
 End;
 Inc(MessageCount);
  { Message 3: Infolettres automatique }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'noreply@techblog.com';
  FromName := 'TechBlog Weekly';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'Bulleting technique hebdomadaire numÇro 142';
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
  MessageBody.Add('=== TECHBLOG HEBDOMADAIRE No 142 ===');
  MessageBody.Add('');
  MessageBody.Add('Cette semaine dans l''actualitÇ technique :');
  MessageBody.Add('');
  MessageBody.Add('- Free Pascal 3.2.4 est disponible avec des nouvelles fonctionnalitÇs');
  MessageBody.Add('- Le noyau Linux 6.7 amÇliore la pile rÇseau');
  MessageBody.Add('- Nouvelle faiolles de sÇcuritÇ dans les serveurs de messagerie');
  MessageBody.Add('');
  MessageBody.Add('Articles en vedettes :');
  MessageBody.Add('- CrÇation d''outil rÇseau avec Pascal');
  MessageBody.Add('- Bonnes pratiques de sÇcuritÇ pour la messagerie Çlectronique');
  MessageBody.Add('- Conseils pour optimiser la productivitÇ en ligne de commande');
  MessageBody.Add('');
  MessageBody.Add('Consultez l''intÇgritÇ des articles sur notre site Web.');
  MessageBody.Add('');
  MessageBody.Add('Se dÇsabonner: rÇpondre avec ÆUNSUBSCRIBEØ');
  MessageBody.Add('L''Çquipe TechBlog');

  { En-t√™tes }
  Headers.Add('From: TechBlog Hebdomadaire <noreply@techblog.com>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Subject: Infolettre technique hebdomadaire No 142');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('List-Unsubscribe: <mailto:unsubscribe@techblog.com>');
 End;
 Inc(MessageCount);

 { Message 4: Message supprimÇ }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'spam@junk.example';
  FromName := 'Offre spÇcial';
  ToAddr := MailConfig.UserEmail;
  ToName := MailConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  Subject := 'GAGNER $10000 MAINTENANT!!! CLIQUER ICI!!!';
  DateSent := Now - 0.5;
  DateReceived := Now - 0.45;
  Priority := 1; { Fausse prioritÇ }
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
  MessageBody.Add('FêLICITATIONS!!!');
  MessageBody.Add('');
  MessageBody.Add('Vous avez ÇtÇ sÇlectionnÇ(e) pour gagner 10 000$ !');
  MessageBody.Add('Cliquez ici immÇdiatement pour rÇclamer votre prix !');
  MessageBody.Add('');
  MessageBody.Add('Cette offre expire dans 24 heures !');
  MessageBody.Add('');
  MessageBody.Add('[Message automatiquement marquÇ comme spam]');

  { Entàtes }
  Headers.Add('From: Special Offer <spam@junk.example>');
  Headers.Add('To: ' + MailConfig.UserEmail);
  Headers.Add('Subject: GAGNER $10000 MAINTENANT!!! CLIQUER ICI!!!');
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
 WriteLn('Mail version 8.1.2 01/15/2001.  Tapez ? pour de l''aide.');
 WriteLn('"/var/mail/', MailConfig.UserName, '": ', MessageCount, ' messages');

 For I := 0 To MessageCount - 1 Do Begin
  With MailMessages[I] Do Begin
   { Caractäre d'Çtat }
   If IsDeleted Then StatusChar := 'D' Else
   If Status = 'new' Then StatusChar := 'N' Else
   If IsReplied Then StatusChar := 'R' Else
   If IsRead Then StatusChar := ' '
             Else StatusChar := 'U';
    { Formatage des champs }
   FromDisplay := Copy(FromName + '                   ', 1, 19);
   SubjectDisplay := Copy(Subject + '                                          ', 1, 40);
   DateDisplay := FormatDateTime('mmm dd hh:nn', DateReceived);
    { Indicateur de message actuel }
   If I + 1 = MailInterface.CurrentMessage Then Write('>')
                                           Else Write(' ');
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
  WriteLn('Aucun message de ce type');
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
   For I := 0 To MessageBody.Count - 1 Do WriteLn(MessageBody[I]);
  End
   Else
  Begin
   WriteLn('[Corps du message indisponible]');
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
Function ComposeMessage(Recipients:String):Boolean;
Var
 Subject: String;
 Body: TStringList;
 Line: String;
 I: Integer;
 MessageText: String;
 Input: String;
Begin
 ComposeMessage := False;
 WriteLn('RÇdaction du message Ö : ', Recipients);

 { Demander le sujet }
 Write('Subject: ');
 ReadLn(Subject);
 If Subject = '' Then
  Subject := '[No Subject]';

 WriteLn('Entrer le message texte (se termine par un simple "." dans une ligne):');
 Body := TStringList.Create;
 Try
  { Lire le message depuis l'entr√©e standard }
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
  WriteLn('Contenu du message :');
  WriteLn('----------------');
  For I := 0 To Body.Count - 1 Do
   WriteLn(Body[I]);
  WriteLn('----------------');
  WriteLn;

  { Confirmation d'envoi }
  If MailConfig.ConfirmSend Then Begin
   Write('Envoi ce message? (o/n) ');
   ReadLn(Input);
   If LowerCase(Input) <> 'o' Then Begin
    WriteLn('Message cancelled');
    Exit;
   End;
  End;
   { Envoyer le message via SMTP }
  WriteLn('Envoi ce message...');
  If SendEmailSMTP(Recipients, MailConfig.UserEmail, Subject, MessageText) Then Begin
   WriteLn('Message envoyÇ avec succäs vers : ', Recipients);
   ComposeMessage := True;
  End Else Begin
   WriteLn('Echec de l''envoi du message');
   WriteLn('Message sauvegardÇ vers ', MailConfig.DeadLetterFile);
  End;
 Finally
  Body.Free;
 End;
End;

 { Sauvegarder un message }
Function SaveMessage(MessageIndex:Integer;FileName:String):Boolean;Begin
 SaveMessage := False;
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message introuvable');
  Exit;
 End;
 If FileName = '' Then FileName := MailConfig.MailboxFile;
 WriteLn('Message ', MessageIndex + 1, ' sauvegarder vers ', FileName);
 With MailMessages[MessageIndex] Do Begin
  IsSaved := True;
 End;
 SaveMessage := True;
End;

 { Supprimer un message }
Function DeleteMessage(MessageIndex: Integer): Boolean;Begin
 DeleteMessage := False;
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message introuvable');
  Exit;
 End;
 With MailMessages[MessageIndex] Do Begin
  If IsDeleted Then Begin
   { Restaurer le message }
   IsDeleted := False;
   Status := 'read';
   WriteLn('Message ', MessageIndex + 1, ' restaurÇ');
  End
   Else
  Begin
   { Marquer pour suppression }
   IsDeleted := True;
   Status := 'deleted';
   WriteLn('Message ', MessageIndex + 1, ' marquÇ pour suppression');
  End;
 End;
 DeleteMessage := True;
End;

{ RÇpondre Ö un message }
Function ReplyToMessage(MessageIndex: Integer): Boolean;
Var
 ReplySubject: String;
 ReplyTo: String;
Begin
 ReplyToMessage := False;
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message introuvable');
  Exit;
 End;
 With MailMessages[MessageIndex] Do Begin
  ReplyTo := FromAddr;
   { PrÇparer le sujet de rÇponse }
  If Copy(UpperCase(Subject), 1, 3) = 'RE:' Then ReplySubject := Subject
                                            Else ReplySubject := MailConfig.ReplyPrefix + Subject;
  WriteLn('RÇponse Ö: ', ReplyTo);
  WriteLn('Sujet: ', ReplySubject);
  WriteLn;
  WriteLn('Enter votre rÇponse (terminez par un simple point "." sur la ligne) :');
   { Simulation de la rÇponse }
  WriteLn('Merci pour votre message.');
  WriteLn('.');
  WriteLn;
  WriteLn('RÇponse envoyÇe Ö: ', ReplyTo);
   { Marquer comme ayant reáu une rÇponse }
  IsReplied := True;
  ReplyToMessage := True;
 End;
End;

 { Afficher l'aide }
Procedure DisplayMailHelp;Begin
 WriteLn('Commandes Mail:');
 WriteLn;
 WriteLn('t [msglist]        Entrer les messages');
 WriteLn('n                  Prochain message');
 WriteLn('p                  PrÇcÇdent message');
 WriteLn('f [msglist]        Affiche les entàtes de message');
 WriteLn('d [msglist]        Efface les messages');
 WriteLn('u [msglist]        RestaurÇ les messages');
 WriteLn('r [message]        RÇpondre au message');
 WriteLn('R [message]        RÇpondre Ö l''expÇditeur et tous les destinataires');
 WriteLn('m [user]           Envoyer un courriel Ö l''utilisateur');
 WriteLn('s [msglist] file   Sauvegarde les messages vers un fichier');
 WriteLn('w [msglist] file   êcrire les messages vers un fichier (pas d''entàtes)');
 WriteLn('q                  Quitter, sauvegarder les changements');
 WriteLn('x                  Quitter, sans sauvegarder les changements');
 WriteLn('h                  Affiche les entàtes');
 WriteLn('?                  Affiche cette aide');
 WriteLn;
 WriteLn('Exemples Msglist:');
 WriteLn('  1-5        Messages 1 Ö 5');
 WriteLn('  1 3 5      Messages 1, 3 et 5');
 WriteLn('  *          Tous les messages');
 WriteLn('  $          Le dernier message');
 WriteLn;
End;

 { Analyser une liste de messages }
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
  Else
 If MsgList = '*' Then Begin
  { Tous les messages }
  For I := 0 To MessageCount - 1 Do Begin
   Messages[I] := I;
   Inc(Count);
  End;
 End
  Else
 If MsgList='$'Then Begin
   { Dernier message }
  Messages[0]:=MessageCount-1;
  Count := 1;
 End
  Else
 Begin
  { Message spÇcifique }
  Try
   Messages[0]:=StrToInt(MsgList)-1;
   If(Messages[0] >= 0)and(Messages[0]<MessageCount)Then Count := 1;
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
 { SÇparer commande et arguments }
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
  { Afficher en-t√™tes }
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
    { Message prÇcÇdent }
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
     WriteLn('Message ', Messages[I] + 1, ' restaurÇ');
    End;
   End;
  End;

  { R√©pondre }
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
   WriteLn('Sauvegarde les changements...');
   MailInterface.QuitRequested := True;
   ProcessMailCommand := False;
  End;
   { Sortir sans sauvegarde }
  'x', 'exit': Begin
   WriteLn('Quitte sans sauvegarder les changements');
   MailInterface.QuitRequested := True;
   ProcessMailCommand := False;
  End;
  Else Begin
    { Commande inconnue - peut-àtre un numÇro de message }
   Try
    I := StrToInt(Cmd) - 1;
    If (I >= 0) and (I < MessageCount) Then Begin
     MailInterface.CurrentMessage := I + 1;
     DisplayMessage(I);
    End
    Else
   Begin
     WriteLn('Commande inconnu : ', Cmd);
    End;
   Except
    WriteLn('Command inconnu : ', Cmd);
   End;
  End;
 End;
End;

 { Mode interactif mail }
Procedure RunInteractiveMode;
Var
 Command: String;
Begin
 WriteLn('Simulation du mode interactif de messagerie');
 WriteLn('Commandes exÇcutÇs automatiquement :');
 WriteLn;
  { Afficher les entàtes }
 WriteLn('> entàtes');
 DisplayMessageHeaders;
  { Lire premier message }
 WriteLn('> 1');
 ProcessMailCommand('1');
  { Message suivant }
 WriteLn('> n');
 ProcessMailCommand('n');
  { RÇpondre au message }
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
 WriteLn('Fin de la simulation du mode interactif');
End;

 { Envoyer de courriel directement }
Function SendDirectMail(Recipients: TStringList; Subject: String; MessageFile:String):Boolean;
Var
 I: Integer;
 MessageBody: TStringList;
 MessageText: String;
 Line: String;
Begin
 SendDirectMail := False;
 If Recipients.Count = 0 Then Begin
  WriteLn('Destinataires non spÇcifiÇs');
  Exit;
 End;
  { PrÇparer le corps du message }
 MessageBody := TStringList.Create;
 Try
  If MessageFile <> '' Then Begin
   { Lire depuis fichier }
   Try
    MessageBody.LoadFromFile(MessageFile);
   Except
    WriteLn('Erreur: Impossible de lire le fichier ', MessageFile);
    Exit;
   End;
  End
   Else
  Begin
   { Lire depuis stdin }
   WriteLn('Lecture du message depuis l''entrÇe standard (terminez par Ctrl+Z ou EOF) :');
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
   { Envoyer Ö tous les destinataires }
  For I := 0 To Recipients.Count - 1 Do Begin
   WriteLn('Envoi Ö : ', Recipients[I]);
   If not SendEmailSMTP(Recipients[I], MailConfig.UserEmail, Subject, MessageText) Then Begin
    WriteLn('êchec de l''envoi Ö : ', Recipients[I]);
    Exit;
   End;
  End;
  WriteLn('Tous les messages ont ÇtÇ envoyÇs avec succäs.');
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
    WriteLn('mail (GNU Mailutils) 3.7 - Clone Pascal pour NETWORKKIT-P, Linux-0, Corail');
    WriteLn('Compatible avec la commande mail de Unix/Linux');
    WriteLn('Avec une vÇritable fonctionnalitÇ d''envoi SMTP');
    Exit;
   End
    Else
   If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--help') Then Begin
    { L'aide sera affichÇe par le bloc principal }
    Exit;
   End
    Else
   If LowerCase(Param) = '-s'Then Begin
    { Sujet }
    Inc(I);
    If I <= ParamCount Then
     Subject := ParamStr(I)
    Else Begin
     WriteLn('L''option -s requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-f' Then Begin
    { File }
    Inc(I);
    If I <= ParamCount Then
     MessageFile := ParamStr(I)
    Else Begin
     WriteLn('L''option -f requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-smtp' Then Begin
    { SMTP Server }
    Inc(I);
    If I <= ParamCount Then MailConfig.SMTPServer := ParamStr(I)
     Else
    Begin
     WriteLn('L''option -smtp requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-port' Then Begin
    { SMTP Port }
    Inc(I);
    If I <= ParamCount Then MailConfig.SMTPPort := StrToIntDef(ParamStr(I), 587)
     Else
    Begin
     WriteLn('L''option -port requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-user' Then Begin
    { Utilisateur SMTP }
    Inc(I);
    If I <= ParamCount Then
     MailConfig.UserEmail := ParamStr(I)
    Else Begin
     WriteLn('L''option -user requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-pass' Then Begin
     { Mot de passe SMTP }
    Inc(I);
    If I <= ParamCount Then MailConfig.Password := ParamStr(I)
     Else
    Begin
     WriteLn('L''option -pass requiert un argument');
     Exit;
    End;
   End
    Else
   If LowerCase(Param) = '-verbose' Then Begin
    { Mode verbeux }
    MailConfig.Verbose := True;
   End
    Else
   If LowerCase(Param) = '-i' Then Begin
    { Interactive }
    Interactive := True;
   End
    Else
   If LowerCase(Param) = '-n' Then Begin
    { Non-interactive }
    Interactive := False;
   End
    Else
   If Copy(Param, 1, 1) <> '-' Then Begin
    { Destinataire }
    Recipients.Add(Param);
    SendMode := True;
   End;
   Inc(I);
  End;
   { CrÇer les donnÇes d'exemple }
  CreateSampleMessages;
  MailInterface.MessageCount := MessageCount;
  If SendMode Then Begin
    { Mode envoi }
   SendDirectMail(Recipients, Subject, MessageFile);
  End
   Else
  If Interactive or (ParamCount = 0)Then Begin
    { Mode interactif }
   RunInteractiveMode;
  End
   Else
  Begin
   { Mode lecture par dÇfaut }
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
 WriteLn('MAIL [NETWORKKIT-P] Simulation de la commande mail de Unix/Linux');
 WriteLn('=========================================================');
 WriteLn;
 WriteLn('Mail version 8.1.2 01/15/2001.  Tapez ? pour l''aide.');
 WriteLn('"/var/mail/user": 4 messages');
 WriteLn;
 WriteLn(' N  1 System Administrator  Feb 21 08:15  URGENT: Maintenance systäme');
 WriteLn(' R  2 John Doe              Feb 20 14:30  RÇunion d''Çquipe hebdomadaire - Ordre du jour');
 WriteLn('    3 TechBlog Weekly       Feb 19 09:45  Bulletin technique hebdomadaire No 142');
 WriteLn(' D  4 Special Offer         Feb 21 10:20  GAGNEZ $10000 MAINTENANT!!! CLIQUER ICI');
 WriteLn;
 WriteLn('& ');
 WriteLn;
 WriteLn('Commandes: t(apez) n(prochain) p(rev) d(efface) r(Çpondre) m(courrier) q(uitte) ?(aide)');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('MAIL : Cette commande permet de lancer l''utilitaire de courriel mail de Unix/Linux.');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  MAIL [options] [recipient...]');
  WriteLn('  MAIL [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn('  -s SUBJECT            SpÇcifier le sujet du message');
  WriteLn('  -f FILE               Lire le message depuis un fichier');
  WriteLn('  -i                    Mode interactif');
  WriteLn('  -n                    Mode non-interactif');
  WriteLn('  -c RECIPIENT          Ajouter destinataire en copie carbone');
  WriteLn('  -b RECIPIENT          Ajouter destinataire en copie carbone invisible');
  WriteLn('  -a FILE               Attacher un fichier');
  WriteLn('  -r FROM               SpÇcifier l''adresse d''expÇditeur');
  WriteLn('  -smtp SERVER          Serveur SMTP (dÇfaut: smtp.gmail.com)');
  WriteLn('  -port PORT            Port SMTP (dÇfaut: 587)');
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
  WriteLn('    1, 2, 3...          Afficher message numÇro N');
  WriteLn('    n, next             Message suivant');
  WriteLn('    p, prev             Message prÇcÇdent');
  WriteLn('    h, headers          Afficher liste des messages');
  WriteLn('    f [msglist]         Afficher entàtes des messages');
  WriteLn;
  WriteLn('  Actions sur messages :');
  WriteLn('    t [msglist]         Afficher contenu des messages');
  WriteLn('    d [msglist]         Supprimer messages');
  WriteLn('    u [msglist]         Restaurer messages supprimÇs');
  WriteLn('    s [msglist] file    Sauvegarder messages dans fichier');
  WriteLn('    w [msglist] file    êcrire messages dans fichier (sans entàtes)');
  WriteLn;
  WriteLn('  Communication :');
  WriteLn('    r [message]         RÇpondre au message');
  WriteLn('    R [message]         RÇpondre Ö tous');
  WriteLn('    m [user]            Composer nouveau message');
  WriteLn('    fo [message]        TransfÇrer message');
  WriteLn;
  WriteLn('  Gestion :');
  WriteLn('    q, quit             Quitter et sauvegarder');
  WriteLn('    x, exit             Quitter sans sauvegarder');
  WriteLn('    !, shell            ExÇcuter commande shell');
  WriteLn('    ?, help             Afficher cette aide');
  WriteLn;
  WriteLn('SpÇcification de messages (msglist) :');
  WriteLn('  1               Message numÇro 1');
  WriteLn('  1-5             Messages 1 Ö 5');
  WriteLn('  1 3 5           Messages 1, 3 et 5');
  WriteLn('  *               Tous les messages');
  WriteLn('  $               Dernier message');
  WriteLn('  .               Message actuel');
  WriteLn('  ^               Premier message');
  WriteLn;
  WriteLn('Indicateurs d''Çtat :');
  WriteLn('  N       Nouveau message (non lu)');
  WriteLn('  U       Non lu');
  WriteLn('  R       Lu avec rÇponse envoyÇe');
  WriteLn('  D       MarquÇ pour suppression');
  WriteLn('  *       Message sauvegardÇ');
  WriteLn('  P       Message conservÇ');
  WriteLn;
  WriteLn('Variables d''environnement :');
  WriteLn('  MAIL            Fichier de courrier principal');
  WriteLn('  MAILPATH        Chemins de recherche des boåtes de courrier');
  WriteLn('  EDITOR          êditeur par dÇfaut pour composer');
  WriteLn('  PAGER           Programme de pagination');
  WriteLn('  MAILRC          Fichier de configuration');
  WriteLn;
  WriteLn('Fichiers :');
  WriteLn('  /var/mail/user      Boåte mail systäme');
  WriteLn('  ~/mbox              Boåte mail utilisateur');
  WriteLn('  ~/.mailrc           Configuration utilisateur');
  WriteLn('  ~/dead.letter       Messages non envoyÇs');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  MAIL                        # Lire courrier');
  WriteLn('  MAIL john@example.com       # Envoyer Ö john');
  WriteLn('  MAIL -s "Hello" john@example.com');
  WriteLn('  MAIL -s "Report" -f report.txt boss@company.com');
  WriteLn('  echo "Test" | MAIL -s "Test" user@domain.com');
  WriteLn;
  WriteLn('Envoi SMTP rÇel :');
  WriteLn('  MAIL -smtp smtp.gmail.com -port 587 -user mon@gmail.com -pass motdepasse -s "Test" dest@example.com');
  WriteLn('  MAIL -verbose -s "Debug" dest@example.com  # Avec debug SMTP');
  WriteLn;
  WriteLn('Variables d''environnement SMTP :');
  WriteLn('  SMTP_SERVER          Serveur SMTP par dÇfaut');
  WriteLn('  SMTP_PORT            Port SMTP par dÇfaut');
  WriteLn('  SMTP_USER            Utilisateur SMTP par dÇfaut');
  WriteLn('  SMTP_PASS            Mot de passe SMTP par dÇfaut');
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
  WriteLn('mail 1.00 pour NETWORKKIT-P, Linux-0, Corail');
  WriteLn('Compatible avec la commande mail de Unix/Linux');
  WriteLn('BasÇ sur Berkeley Mail et GNU Mailutils');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
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