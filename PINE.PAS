{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Commande pine (Pine Is Not Elm))
}

Program PINE;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Classes, StrUtils, DateUtils;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
  { Structure d'un message Çlectronique Pine }
 TPineMessage = Record
  MessageID: Integer;         { ID unique du message }
  FromAddr: String[255];      { Adresse expÇditeur }
  FromName: String[255];      { Nom expÇditeur }
  ToAddr: String[255];        { Adresse destinataire }
  ToName: String[255];        { Nom destinataire }
  CcAddr: String[255];        { Copie carbone }
  BccAddr: String[255];       { Copie carbone invisible }
  ReplyTo: String[255];       { Adresse de rÇponse }
  Subject: String[255];       { Sujet }
  DateSent: TDateTime;        { Date d'envoi }
  DateReceived: TDateTime;    { Date de rÇception }
  Priority: Integer;          { PrioritÇ (1=haute, 2=normale, 3=basse) }
  Status: String[32];         { êtat (new, read, replied, forwarded, deleted) }
  Size: LongInt;              { Taille en octets }
  Lines: Integer;             { Nombre de lignes }
  ContentType: String[64];    { Type de contenu }
  Encoding: String[32];       { Encodage }
  MessageBody: TStringList;   { Corps du message }
  Headers: TStringList;       { Entàtes complätes }
  Attachments: Array[0..31] of String[255]; { Piäces jointes }
  AttachmentCount: Integer;   { Nombre de piäces jointes }
  IsRead: Boolean;            { Message lu }
  IsDeleted: Boolean;         { Message supprimÇ }
  IsReplied: Boolean;         { RÇponse envoyÇe }
  IsForwarded: Boolean;       { Message transfÇrÇ }
  IsFlagged: Boolean;         { Message marquÇ }
  IsImportant: Boolean;       { Message important }
  IsPersonal: Boolean;        { Message personnel }
  ThreadID: Integer;          { ID de processus lÇger }
  ThreadLevel: Integer;       { Niveau de processus lÇger }
 End;

 { Configuration Pine }
 TPineConfig = Record
  UserName: String[64];       { Nom utilisateur }
  UserEmail: String[255];     { Adresse de courriel }
  FullName: String[255];      { Nom complet }
  Domain: String[255];        { Domaine }
  MailDir: String[255];       { R√©pertoire mail }
  InboxFile: String[255];     { Fichier boåte de rÇception }
  SentFile: String[255];      { Fichier messages envoyÇs }
  DraftFile: String[255];     { Fichier brouillons }
  TrashFile: String[255];     { Fichier corbeille }
  PostponeFile: String[255];  { Fichier messages reportäs }
  SMTPServer: String[255];    { Serveur SMTP }
  SMTPPort: Word;             { Port SMTP }
  POP3Server: String[255];    { Serveur POP3 }
  POP3Port: Word;             { Port POP3 }
  IMAPServer: String[255];    { Serveur IMAP }
  IMAPPort: Word;             { Port IMAP }
  NNTPServer: String[255];    { Serveur NNTP (news) }
  NNTPPort: Word;             { Port NNTP }
  UseSSL: Boolean;            { Utiliser SSL/TLS }
  AuthMethod: String[32];     { MÇthode d'authentification }
  Password: String[255];      { Mot de passe }
  Editor: String[255];        { êditeur par dÇfaut }
  Speller: String[255];       { Correcteur orthographique }
  Pager: String[255];         { Programme de pagination }
  PrintCommand: String[255];  { Commande d'impression }
  Signature: String[255];     { Fichier signature }
  ReplyPrefix: String[16];    { PrÇfixe rÇponse (Re:) }
  ForwardPrefix: String[16];  { PrÇfixe transfert (Fwd:) }
  DateFormat: String[32];     { Format de date }
  SortBy: String[16];         { Tri (arrival, date, subject, thread, size, from) }
  SortOrder: String[16];      { Ordre (ascending, descending) }
  ThreadMode: Boolean;        { Mode thread }
  ShowNumbers: Boolean;       { Afficher numÇros de message }
  ShowSizes: Boolean;         { Afficher tailles }
  ShowStatus: Boolean;        { Afficher statut }
  AutoSave: Boolean;          { Sauvegarde automatique }
  AutoSaveInterval: Integer;  { Intervalle sauvegarde (min) }
  ShowHeaders: Boolean;       { Afficher entàtes }
  WrapLines: Integer;         { Retour Ö la ligne }
  PageSize: Integer;          { Taille de page }
  ConfirmDelete: Boolean;     { Confirmer suppression }
  ConfirmQuit: Boolean;       { Confirmer sortie }
  BeepOnNewMail: Boolean;     { Bip nouveau message }
  CheckInterval: Integer;     { Intervalle vÇrification (min) }
  UseColors: Boolean;         { Utiliser les couleurs }
  ColorTheme: String[16];     { Thäme de couleur }
  MenuBar: Boolean;           { Barre de menu }
  KeyBar: Boolean;            { Barre de touches }
  StatusLine: Boolean;        { Ligne de statut }
  EnableMouse: Boolean;       { Support souris }
 End;

 { Dossier Pine }
 TPineFolder = Record
  Name: String[64];           { Nom du dossier }
  DisplayName: String[64];    { Nom d'affichage }
  Path: String[255];          { Chemin du dossier }
  FolderType: String[16];     { Type (inbox, sent, drafts, trash, news) }
  MessageCount: Integer;      { Nombre de messages }
  NewMessages: Integer;       { Nouveaux messages }
  UnreadMessages: Integer;    { Messages non lus }
  Size: Int64;                { Taille totale }
  IsOpen: Boolean;            { Dossier ouvert }
  IsReadable: Boolean;        { Dossier lisible }
  IsWriteable: Boolean;       { Dossier modifiable }
 End;

 { Interface utilisateur Pine }
 TPineInterface = Record
  CurrentView: String[16];    { Vue actuelle (main, folder, message, compose) }
  CurrentFolder: Integer;     { Index dossier actuel }
  CurrentMessage: Integer;    { Message actuel }
  CurrentLine: Integer;       { Ligne actuelle }
  PageStart: Integer;         { DÇbut de page }
  PageEnd: Integer;           { Fin de page }
  ViewMode: String[16];       { Mode vue (full, headers, attachments) }
  SearchPattern: String[255]; { Motif de recherche }
  FilterActive: Boolean;      { Filtre actif }
  FilterPattern: String[255]; { Motif de filtre }
  MenuLevel: Integer;         { Niveau de menu }
  StatusMessage: String[255]; { Message de statut }
  LastCommand: String[32];    { Derniäre commande }
  HelpVisible: Boolean;       { Aide visible }
  CommandPrompt: String[255]; { Invite de commande }
  ErrorMessage: String[255];  { Message d'erreur }
  SelectionStart: Integer;    { DÇbut sÇlection }
  SelectionEnd: Integer;      { Fin sÇlection }
  EditMode: Boolean;          { Mode Çdition }
  ComposeMode: Boolean;       { Mode composition }
 End;

 { Statistiques Pine }
 TPineStats = Record
  TotalMessages: Integer;     { Total messages }
  NewMessages: Integer;       { Nouveaux messages }
  ReadMessages: Integer;      { Messages lus }
  UnreadMessages: Integer;    { Messages non lus }
  DeletedMessages: Integer;   { Messages supprimÇs }
  RepliedMessages: Integer;   { Messages avec rÇponse }
  ForwardedMessages: Integer; { Messages transfÇrÇs }
  FlaggedMessages: Integer;   { Messages marquÇs }
  ThreadedMessages: Integer;  { Messages en thread }
  TotalSize: Int64;           { Taille totale }
  TotalFolders: Integer;      { Total dossiers }
  ActiveFolders: Integer;     { Dossiers actifs }
  LastCheck: TDateTime;       { Derniäre vÇrification }
  SessionStart: TDateTime;    { DÇbut de session }
  MessagesRead: Integer;      { Messages lus cette session }
  MessagesSent: Integer;      { Messages envoyÇs cette session }
 End;

Var
 { Variables globales Pine }
 PineConfig: TPineConfig;
 PineMessages: Array[0..9999] of TPineMessage;
 PineFolders: Array[0..63] of TPineFolder;
 MessageCount: Integer;
 FolderCount: Integer;
 PineStats: TPineStats;
 PineInterface: TPineInterface;

 { êtats et commandes }
 QuitRequested: Boolean;
 DataChanged: Boolean;
 LastErrorMessage: String[255];

 { Initialiser la configuration Pine }
Procedure InitializePineConfig;Begin
 With PineConfig Do Begin
  UserName := 'user';
  UserEmail := 'user@localhost';
  FullName := 'Local User';
  Domain := 'localhost';
  MailDir := '~/mail/';
  InboxFile := '~/mail/INBOX';
  SentFile := '~/mail/sent-mail';
  DraftFile := '~/mail/drafts';
  TrashFile := '~/mail/trash';
  PostponeFile := '~/mail/postponed-msgs';
  SMTPServer := 'localhost';
  SMTPPort := 25;
  POP3Server := 'localhost';
  POP3Port := 110;
  IMAPServer := 'localhost';
  IMAPPort := 143;
  NNTPServer := 'news.localhost';
  NNTPPort := 119;
  UseSSL := False;
  AuthMethod := 'LOGIN';
  Password := '';
  Editor := 'pico';
  Speller := 'ispell';
  Pager := 'built-in';
  PrintCommand := 'lpr';
  Signature := '~/.signature';
  ReplyPrefix := 'Re: ';
  ForwardPrefix := 'Fwd: ';
  DateFormat := 'dd/mm/yyyy hh:nn';
  SortBy := 'arrival';
  SortOrder := 'descending';
  ThreadMode := True;
  ShowNumbers := True;
  ShowSizes := True;
  ShowStatus := True;
  AutoSave := True;
  AutoSaveInterval := 5;
  ShowHeaders := False;
  WrapLines := 80;
  PageSize := 22;
  ConfirmDelete := True;
  ConfirmQuit := True;
  BeepOnNewMail := True;
  CheckInterval := 3;
  UseColors := True;
  ColorTheme := 'default';
  MenuBar := True;
  KeyBar := True;
  StatusLine := True;
  EnableMouse := False;
 End;
  { Initialiser l'interface }
 With PineInterface Do Begin
  CurrentView := 'main';
  CurrentFolder := 0;
  CurrentMessage := 1;
  CurrentLine := 1;
  PageStart := 1;
  PageEnd := PineConfig.PageSize;
  ViewMode := 'full';
  SearchPattern := '';
  FilterActive := False;
  FilterPattern := '';
  MenuLevel := 0;
  StatusMessage := 'Pine ready for new mail';
  LastCommand := '';
  HelpVisible := False;
  CommandPrompt := '';
  ErrorMessage := '';
  SelectionStart := 0;
  SelectionEnd := 0;
  EditMode := False;
  ComposeMode := False;
 End;
  { Initialiser les variables globales }
 MessageCount := 0;
 FolderCount := 0;
 QuitRequested := False;
 DataChanged := False;
 LastErrorMessage := '';
End;

 { CrÇer les dossiers Pine par dÇfaut }
Procedure CreateDefaultFolders;Begin
  { INBOX }
 With PineFolders[FolderCount] Do Begin
  Name := 'INBOX';
  DisplayName := 'INBOX';
  Path := PineConfig.InboxFile;
  FolderType := 'inbox';
  MessageCount := 0;
  NewMessages := 0;
  UnreadMessages := 0;
  Size := 0;
  IsOpen := True;
  IsReadable := True;
  IsWriteable := True;
 End;
 Inc(FolderCount);
  { sent-mail }
 With PineFolders[FolderCount] Do Begin
  Name := 'sent-mail';
  DisplayName := 'sent-mail';
  Path := PineConfig.SentFile;
  FolderType := 'sent';
  MessageCount := 0;
  NewMessages := 0;
  UnreadMessages := 0;
  Size := 0;
  IsOpen := False;
  IsReadable := True;
  IsWriteable := True;
 End;
 Inc(FolderCount);
  { saved-messages }
 With PineFolders[FolderCount] Do Begin
  Name := 'saved-messages';
  DisplayName := 'saved-messages';
  Path := '~/mail/saved-messages';
  FolderType := 'saved';
  MessageCount := 0;
  NewMessages := 0;
  UnreadMessages := 0;
  Size := 0;
  IsOpen := False;
  IsReadable := True;
  IsWriteable := True;
 End;
 Inc(FolderCount);
  { drafts }
 With PineFolders[FolderCount] Do Begin
  Name := 'drafts';
  DisplayName := 'drafts';
  Path := PineConfig.DraftFile;
  FolderType := 'drafts';
  MessageCount := 0;
  NewMessages := 0;
  UnreadMessages := 0;
  Size := 0;
  IsOpen := False;
  IsReadable := True;
  IsWriteable := True;
 End;
 Inc(FolderCount);
  { Trash }
 With PineFolders[FolderCount] Do Begin
  Name := 'Trash';
  DisplayName := 'Trash';
  Path := PineConfig.TrashFile;
  FolderType := 'trash';
  MessageCount := 0;
  NewMessages := 0;
  UnreadMessages := 0;
  Size := 0;
  IsOpen := False;
  IsReadable := True;
  IsWriteable := True;
 End;
 Inc(FolderCount);
End;

 { CrÇer des messages d'exemple pour Pine }
Procedure CreatePineSampleMessages;Begin
  { Message 1: Courriel urgent du systäme }
 With PineMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'sysadmin@company.com';
  FromName := 'System Administrator';
  ToAddr := PineConfig.UserEmail;
  ToName := PineConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  ReplyTo := 'sysadmin@company.com';
  Subject := '[URGENT] Maintenance serveur programmÇe';
  DateSent := Now - 0.3; { Il y a 7 heures }
  DateReceived := Now - 0.25;
  Priority := 1; { Haute }
  Status := 'new';
  Size := 1280;
  Lines := 18;
  ContentType := 'text/plain';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 1;
  IsRead := False;
  IsDeleted := False;
  IsReplied := False;
  IsForwarded := False;
  IsFlagged := True;
  IsImportant := True;
  IsPersonal := False;
  ThreadID := 1;
  ThreadLevel := 0;
   { Corps du message }
  MessageBody.Add('Cher(e) utilisateur/trice,');
  MessageBody.Add('');
  MessageBody.Add('Une maintenance critique du serveur de messagerie');
  MessageBody.Add('est programmÇe pour cette fin de semaine :');
  MessageBody.Add('');
  MessageBody.Add('Date : Samedi 22 fÇvrier 2026');
  MessageBody.Add('Heure : 02:00 - 06:00 (GMT+1)');
  MessageBody.Add('');
  MessageBody.Add('Services impactÇs :');
  MessageBody.Add('- Serveur de messagerie (SMTP/IMAP/POP3)');
  MessageBody.Add('- Serveur web interne');
  MessageBody.Add('- Base de donnÇes utilisateurs');
  MessageBody.Add('');
  MessageBody.Add('Veuillez planifier vos activitÇs en consÇquence.');
  MessageBody.Add('Un courriel de confirmation sera envoyÇ Ö la fin de la maintenance.');
  MessageBody.Add('');
  MessageBody.Add('Cordialement,');
  MessageBody.Add('L''Ç©quipe technique');
   { Piäce jointe }
  Attachments[0] := 'maintenance-details.pdf';
   { En-tàtes }
  Headers.Add('Return-Path: <sysadmin@company.com>');
  Headers.Add('From: System Administrator <sysadmin@company.com>');
  Headers.Add('To: ' + PineConfig.FullName + ' <' + PineConfig.UserEmail + '>');
  Headers.Add('Subject: [URGENT] Maintenance serveur programm√©e');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('Message-ID: <urgent-maintenance-2026022101@company.com>');
  Headers.Add('X-Priority: 1 (Highest)');
  Headers.Add('X-Mailer: Pine 4.64');
 End;
 Inc(MessageCount);
  { Message 2: RÇponse Ö un processus lÇger }
 With PineMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'marie.martin@company.com';
  FromName := 'Marie Martin';
  ToAddr := PineConfig.UserEmail;
  ToName := PineConfig.FullName;
  CcAddr := 'team@company.com';
  BccAddr := '';
  ReplyTo := 'marie.martin@company.com';
  Subject := 'Re: Projet Q1 - Planning Çquipe';
  DateSent := Now - 1.2; { Il y a 1.2 jour }
  DateReceived := Now - 1.15;
  Priority := 2; { Normale }
  Status := 'read';
  Size := 768;
  Lines := 12;
  ContentType := 'text/plain';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 0;
  IsRead := True;
  IsDeleted := False;
  IsReplied := True;
  IsForwarded := False;
  IsFlagged := False;
  IsImportant := False;
  IsPersonal := True;
  ThreadID := 2;
  ThreadLevel := 1;
   { Corps du message }
  MessageBody.Add('Bonjour,');
  MessageBody.Add('');
  MessageBody.Add('> Peux-tu confirmer ta disponibilitÇ pour le projet Q1 ?');
  MessageBody.Add('');
  MessageBody.Add('Oui, je confirme ma disponibilitÇ Ö 100% pour ce projet.');
  MessageBody.Add('J''ai dÇjÖ bloquÇ les crÇneaux suivants dans mon agenda :');
  MessageBody.Add('');
  MessageBody.Add('- Lundi 24/02 : RÇunion de lancement (9h-11h)');
  MessageBody.Add('- Mercredi 26/02 : Point d''avancement (14h-15h30)');
  MessageBody.Add('- Vendredi 28/02 : Revue technique (10h-12h)');
  MessageBody.Add('');
  MessageBody.Add('A bientìt,');
  MessageBody.Add('Marie');
   { En-tàtes }
  Headers.Add('From: Marie Martin <marie.martin@company.com>');
  Headers.Add('To: ' + PineConfig.FullName + ' <' + PineConfig.UserEmail + '>');
  Headers.Add('Cc: team@company.com');
  Headers.Add('Subject: Re: Projet Q1 - Planning Çquipe');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('In-Reply-To: <project-q1-planning@company.com>');
  Headers.Add('References: <project-q1-planning@company.com>');
 End;
 Inc(MessageCount);
  { Message 3: Newsletter technique }
 With PineMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'newsletter@devtech.org';
  FromName := 'DevTech Weekly';
  ToAddr := PineConfig.UserEmail;
  ToName := PineConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  ReplyTo := 'no-reply@devtech.org';
  Subject := 'DevTech Weekly #47 - Free Pascal & Networking';
  DateSent := Now - 2.8; { Il y a 2.8 jours }
  DateReceived := Now - 2.75;
  Priority := 3; { Basse }
  Status := 'read';
  Size := 3072;
  Lines := 45;
  ContentType := 'text/html';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 0;
  IsRead := True;
  IsDeleted := False;
  IsReplied := False;
  IsForwarded := True;
  IsFlagged := False;
  IsImportant := False;
  IsPersonal := False;
  ThreadID := 3;
  ThreadLevel := 0;
   { Corps du message }
  MessageBody.Add('⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø');
  MessageBody.Add('≥                   DEVTECH WEEKLY #47                    ≥');
  MessageBody.Add('≥            Free Pascal & Networking Focus               ≥');
  MessageBody.Add('¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ');
  MessageBody.Add('');
  MessageBody.Add('Bonjour cher dÇveloppeur !');
  MessageBody.Add('');
  MessageBody.Add('Au programme cette semaine :');
  MessageBody.Add('');
  MessageBody.Add('˛ TENDANCES');
  MessageBody.Add('˙ Free Pascal 3.2.4 : nouvelles fonctionnalitÇs rÇseau');
  MessageBody.Add('˙ Lazarus IDE : amÇlioration debugger distant');
  MessageBody.Add('˙ Protocoles rÇseau : HTTP/2 et WebSocket');
  MessageBody.Add('');
  MessageBody.Add('˛ OUTILS & TECHNIQUES');
  MessageBody.Add('˙ Sockets TCP/UDP en Free Pascal');
  MessageBody.Add('˙ Clients courriel : Pine vs ELM comparaison');
  MessageBody.Add('˙ SÇcuritÇ rÇseau : SSL/TLS implÇmentation');
  MessageBody.Add('');
  MessageBody.Add('˛ RESSOURCES');
  MessageBody.Add('˙ GitHub: Awesome Free Pascal Networking');
  MessageBody.Add('˙ Documentation: RFC SMTP mise Ö jour');
  MessageBody.Add('˙ Tutoriel: DNS resolver from scratch');
  MessageBody.Add('');
  MessageBody.Add('˛ PROJET DE LA SEMAINE');
  MessageBody.Add('NetworkKit-P : Suite d''outils rÇseau en Pascal');
  MessageBody.Add('˙ https://github.com/gladir/networkkit-p');
  MessageBody.Add('');
  MessageBody.Add('Bonne programmation !');
  MessageBody.Add('L''Çquipe DevTech');
   { En-tàtes }
  Headers.Add('From: DevTech Weekly <newsletter@devtech.org>');
  Headers.Add('To: ' + PineConfig.UserEmail);
  Headers.Add('Subject: DevTech Weekly #47 - Free Pascal & Networking');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss +0100', DateSent));
  Headers.Add('List-ID: <devtech-weekly.devtech.org>');
  Headers.Add('List-Unsubscribe: <mailto:unsubscribe@devtech.org>');
 End;
 Inc(MessageCount);
  { Message 4: Brouillon }
 With PineMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := PineConfig.UserEmail;
  FromName := PineConfig.FullName;
  ToAddr := 'contact@freelance-client.com';
  ToName := 'Nouveau Client';
  CcAddr := '';
  BccAddr := '';
  ReplyTo := PineConfig.UserEmail;
  Subject := 'Proposition dÇveloppement application rÇseau';
  DateSent := 0; { Pas encore envoy√© }
  DateReceived := Now - 0.05;
  Priority := 2;
  Status := 'draft';
  Size := 512;
  Lines := 15;
  ContentType := 'text/plain';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 0;
  IsRead := True;
  IsDeleted := False;
  IsReplied := False;
  IsForwarded := False;
  IsFlagged := False;
  IsImportant := False;
  IsPersonal := True;
  ThreadID := 4;
  ThreadLevel := 0;
   { Corps du message }
  MessageBody.Add('Bonjour,');
  MessageBody.Add('');
  MessageBody.Add('Suite Ö notre Çchange tÇlÇphonique, je vous propose');
  MessageBody.Add('mes services pour le dÇveloppement de votre application');
  MessageBody.Add('de gestion rÇseau en Free Pascal.');
  MessageBody.Add('');
  MessageBody.Add('FonctionnalitÇs proposÇes :');
  MessageBody.Add('- Surveillance rÇseau temps rÇel');
  MessageBody.Add('- Outils de diagnostic (ping, traceroute, nslookup)');
  MessageBody.Add('- Interface utilisateur intuitive');
  MessageBody.Add('- Reporting automatique');
  MessageBody.Add('');
  MessageBody.Add('A complÇter : tarifs et planning]');
  MessageBody.Add('');
  MessageBody.Add('Cordialement,');
   { Entàtes }
  Headers.Add('From: ' + PineConfig.FullName + ' <' + PineConfig.UserEmail + '>');
  Headers.Add('To: Nouveau Client <contact@freelance-client.com>');
  Headers.Add('Subject: Proposition dÇveloppement application rÇseau');
  Headers.Add('Date: A dÇfinir lors de l''envoi]');
 End;
 Inc(MessageCount);
  { Message 5: Message supprimÇ }
 With PineMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'promo@spamsite.example';
  FromName := 'Offre Exceptionnelle';
  ToAddr := PineConfig.UserEmail;
  ToName := PineConfig.FullName;
  CcAddr := '';
  BccAddr := '';
  ReplyTo := 'noreply@spamsite.example';
  Subject := 'A GAGNEZ 5000 $ IMMêDIATEMENT ! Cliquez ici !!! ';
  DateSent := Now - 0.8;
  DateReceived := Now - 0.75;
  Priority := 1; { Fausse haute priorit√© }
  Status := 'deleted';
  Size := 2048;
  Lines := 30;
  ContentType := 'text/html';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 0;
  IsRead := False;
  IsDeleted := True;
  IsReplied := False;
  IsForwarded := False;
  IsFlagged := False;
  IsImportant := False;
  IsPersonal := False;
  ThreadID := 5;
  ThreadLevel := 0;

  { Corps du message }
  MessageBody.Add('FêLICITATIONS !!! VOUS AVEZ GAGNê !!!');
  MessageBody.Add('');
  MessageBody.Add('Cliquez sur le lien ci-dessous pour rÇcupÇrer vos 5000$');
  MessageBody.Add('ATTENTION : Offre limitÇe dans le temps !!!');
  MessageBody.Add('');
  MessageBody.Add('[Message identifiÇ comme SPAM et supprimÇ automatiquement]');

  { En-t√™tes }
  Headers.Add('From: Offre Exceptionnelle <promo@spamsite.example>');
  Headers.Add('To: ' + PineConfig.UserEmail);
  Headers.Add('Subject: A GAGNEZ 5000$ IMMêDIATEMENT ! Cliquez ici !!! ');
  Headers.Add('X-Spam-Score: 15.2');
  Headers.Add('X-Spam-Status: Yes, score=15.2 required=5.0');
 End;
 Inc(MessageCount);
End;

{ Calculer les statistiques Pine }
Procedure UpdatePineStats;
Var
 I: Integer;
Begin
 FillChar(PineStats, SizeOf(PineStats), 0);
 For I := 0 To MessageCount - 1 Do Begin
  With PineMessages[I] Do Begin
   Inc(PineStats.TotalMessages);
   PineStats.TotalSize := PineStats.TotalSize + Size;
   If Status = 'new' Then Inc(PineStats.NewMessages);
   If IsRead Then Inc(PineStats.ReadMessages) Else Inc(PineStats.UnreadMessages);
   If IsDeleted Then Inc(PineStats.DeletedMessages);
   If IsReplied Then Inc(PineStats.RepliedMessages);
   If IsForwarded Then Inc(PineStats.ForwardedMessages);
   If IsFlagged Then Inc(PineStats.FlaggedMessages);
   If ThreadID > 0 Then Inc(PineStats.ThreadedMessages);
  End;
 End;
 PineStats.TotalFolders := FolderCount;
 PineStats.ActiveFolders := FolderCount;
 PineStats.LastCheck := Now;
 PineStats.SessionStart := Now;
 PineStats.MessagesRead := 0;
 PineStats.MessagesSent := 0;
End;

{ Afficher l'Çcran principal Pine }
Procedure DisplayPineMainScreen;Begin
 WriteLn('PINE 4.64   MAIN MENU                   Folder: INBOX  ', MessageCount, ' Messages');
 WriteLn;
 WriteLn('           ?     HELP               -  Get help using Pine');
 WriteLn('           C     COMPOSE MESSAGE   -  Compose and send a message');
 WriteLn('           I     MESSAGE INDEX     -  View messages in current folder');
 WriteLn('           L     FOLDER LIST       -  Select a folder to view');
 WriteLn('           A     ADDRESS BOOK      -  Update address book');
 WriteLn('           S     SETUP             -  Configure Pine Options');
 WriteLn('           Q     QUIT              -  Quit Pine');
 WriteLn;
 WriteLn(' [Folder "INBOX" opened with ', MessageCount, ' messages]');
 If PineStats.NewMessages > 0 Then
  WriteLn(' [You have ', PineStats.NewMessages, ' new message(s)]');
 WriteLn;
 WriteLn('? Help     P PrevCmd     - PrevPage     Space NextPage     N NextCmd');
 WriteLn('O OTHER CMDS: [ListFldrs] [ExitSelect] [ComposeTo] [ListMode]');
End;

{ Afficher l'index des messages }
Procedure DisplayPineMessageIndex;
Var
 I: Integer;
 StatusChar: Char;
 ThreadIndent: String;
 FromDisplay: String;
 SubjectDisplay: String;
 DateDisplay: String;
 SizeDisplay: String;
Begin
 WriteLn('PINE 4.64   MESSAGE INDEX     Folder: INBOX             ', MessageCount, ' Messages');
 WriteLn;
 WriteLn('+ N  ', MessageCount:3, '  Feb 21  System Administrato (1,280)  [URGENT] Maintenance serveur prog');
 WriteLn('    ', MessageCount-1:3, '  Feb 20  Marie Martin       (  768)  Re: Projet Q1 - Planning Çquipe');
 WriteLn(' F  ', MessageCount-2:3, '  Feb 19  DevTech Weekly     (3,072)  DevTech Weekly #47 - Free Pascal');
 WriteLn(' D  ', MessageCount-3:3, '  Feb 21  [DRAFT]           (  512)  Proposition dÇveloppement appli');
 WriteLn(' D  ', MessageCount-4:3, '  Feb 21  Offre Exception.   (2,048) [SPAM] GAGNEZ 5000$ IMMêDIA');
 WriteLn;
  { Affichage dÇtaillÇ des messages }
 WriteLn('Message List (', PineInterface.PageStart, '-');
 If PineInterface.PageEnd < MessageCount Then
  Write(PineInterface.PageEnd)
 Else
  Write(MessageCount);
 WriteLn(' of ', MessageCount, ')');
 WriteLn(StringOfChar('-', 80));
 WriteLn('  # St  Date    From               Size   Subject');
 WriteLn(StringOfChar('-', 80));

 For I := PineInterface.PageStart - 1 To PineInterface.PageEnd - 1 Do Begin
  If I >= MessageCount Then Break;
  With PineMessages[I] Do Begin
   { Indicateur de statut }
   If IsDeleted Then StatusChar := 'D'
   Else If Status = 'new' Then StatusChar := 'N'
   Else If IsReplied Then StatusChar := 'R'
   Else If IsForwarded Then StatusChar := 'F'
   Else If Status = 'draft' Then StatusChar := 'B' { B pour brouillon }
   Else If IsRead Then StatusChar := ' '
   Else StatusChar := 'U';
   { Indentation pour les threads }
   ThreadIndent := StringOfChar(' ', ThreadLevel * 2);
   { Formatage des champs }
   FromDisplay := Copy(FromName + '               ', 1, 15);
   SubjectDisplay := Copy(Subject + '                                          ', 1, 40);
   DateDisplay := FormatDateTime('mm/dd', DateReceived);
   SizeDisplay := IntToStr(Size);
   { Indicateur de message courant }
   If I + 1 = PineInterface.CurrentMessage Then
    Write('>')
   Else
    Write(' ');
   { Affichage de la ligne }
   Write(I + 1:3, ' ', StatusChar, ' ');
   If IsFlagged Then Write('*') Else Write(' ');
   If IsImportant Then Write('!') Else Write(' ');
   WriteLn(DateDisplay, ' ', ThreadIndent, FromDisplay, ' (', SizeDisplay:5, ') ', SubjectDisplay);
  End;
 End;
 WriteLn(StringOfChar('-', 80));
 WriteLn('? Help     < FldrList     P PrevMsg     - PrevPage     Space NextPage');
 WriteLn('O OTHER CMDS: [ViewMsg] [Reply] [Forward] [Delete] [Undelete] [Flag]');
End;

{ Afficher un message }
Procedure DisplayPineMessage(MessageIndex: Integer);
Var
 I: Integer;
Begin
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message not found');
  Exit;
 End;
 With PineMessages[MessageIndex] Do Begin
  WriteLn('PINE 4.64   MESSAGE TEXT      Folder: INBOX  Message ', MessageID, ' of ', MessageCount);
  WriteLn(StringOfChar('-', 80));
  WriteLn('Date: ', FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  WriteLn('From: ', FromName, ' <', FromAddr, '>');
  WriteLn('To: ', ToName, ' <', ToAddr, '>');
  If CcAddr <> '' Then
   WriteLn('Cc: ', CcAddr);
  WriteLn('Subject: ', Subject);
  If AttachmentCount > 0 Then Begin
   WriteLn('Attachments: ');
   For I := 0 To AttachmentCount - 1 Do
    WriteLn('  [', I + 1, '] ', Attachments[I]);
  End;
  WriteLn(StringOfChar('-', 80));
  WriteLn;
  { Afficher le corps du message }
  If MessageBody <> nil Then Begin
   For I := 0 To MessageBody.Count - 1 Do
    WriteLn(MessageBody[I]);
  End Else Begin
   WriteLn('[Message body not available]');
  End;
  WriteLn;
  WriteLn(StringOfChar('-', 80));
  WriteLn('? Help     < MsgIndex     P PrevMsg     N NextMsg     - PrevPage');
  WriteLn('O OTHER CMDS: [Reply] [Forward] [Flag] [Delete] [Undelete] [Print]');
  { Marquer comme lu }
  If not IsRead Then Begin
   IsRead := True;
   If Status = 'new' Then Status := 'read';
   Inc(PineStats.MessagesRead);
   DataChanged := True;
  End;
 End;
End;

{ Afficher la liste des dossiers }
Procedure DisplayPineFolderList;
Var
 I: Integer;
Begin
 WriteLn('PINE 4.64   FOLDER LIST                                ', FolderCount, ' Folders');
 WriteLn;
 WriteLn('This collection of folders is for accessing your mail and news:');
 WriteLn;
 WriteLn('Folder-collection <Mail>');
 WriteLn(StringOfChar('-', 80));
 WriteLn('        Folder Name      (Message Count)');
 WriteLn(StringOfChar('-', 80));
 For I := 0 To FolderCount - 1 Do Begin
  With PineFolders[I] Do Begin
   If I = PineInterface.CurrentFolder Then
    Write(' -->  ')
   Else
    Write('      ');
   Write(DisplayName);
   If NewMessages > 0 Then
    Write(' (', MessageCount, ', ', NewMessages, ' new)')
   Else If MessageCount > 0 Then
    Write(' (', MessageCount, ')')
   Else
    Write(' (empty)');
   WriteLn;
  End;
 End;
 WriteLn(StringOfChar('-', 80));
 WriteLn('? Help     < MainMenu     P PrevFldr     N NextFldr     Space [Select]');
 WriteLn('O OTHER CMDS: [ViewFldr] [AddFldr] [DelFldr] [RenameFldr] [Export]');
End;

{ Composer un nouveau message }
Procedure DisplayPineCompose;Begin
 WriteLn('PINE 4.64   COMPOSE MESSAGE                             Folder: INBOX');
 WriteLn(StringOfChar('-', 80));
 WriteLn('To      : [Enter recipient address]');
 WriteLn('Cc      : ');
 WriteLn('Attchmnt: ');
 WriteLn('Subject : [Enter subject]');
 WriteLn('Message Text:');
 WriteLn(StringOfChar('-', 80));
 WriteLn;
 WriteLn('[Compose your message here]');
 WriteLn;
 WriteLn('[Use Ctrl+X to send, Ctrl+C to cancel]');
 WriteLn;
 WriteLn;
 WriteLn;
 WriteLn;
 WriteLn;
 WriteLn(StringOfChar('-', 80));
 WriteLn('-- ');
 WriteLn('[Your signature file will appear here]');
 WriteLn;
 WriteLn('^G Get Help  ^O WriteFile  ^R Read File  ^Y Prev Page  ^K Cut Text   ^C Cancel');
 WriteLn('^X Send      ^J Justify    ^W Where is   ^V Next Page  ^U UnCut Text ^T To Files');
End;

{ Afficher la configuration Pine }
Procedure DisplayPineSetup;
Begin
 WriteLn('PINE 4.64   SETUP CONFIGURATION                        (CONFIGURATION)');
 WriteLn(StringOfChar('-', 80));
 WriteLn;
 WriteLn('Choose one of the following to configure Pine:');
 WriteLn;
 WriteLn('   C     Config         - Change various Pine settings');
 WriteLn('   P     Printer        - Select a printer or adjust print settings');
 WriteLn('   N     Newpassword    - Change login password');
 WriteLn('   A     AddressBooks   - Select address books');
 WriteLn('   D     Directory      - Set up directory server for addresses');
 WriteLn('   K     Kolor          - Set colors for various parts of Pine');
 WriteLn('   R     Rules          - Set up rules for filing and filtering');
 WriteLn('   I     Index          - Choose message index format');
 WriteLn('   L     collectionLists - Set up collection lists');
 WriteLn('   S     S/MIME         - Configure S/MIME');
 WriteLn('   U     Update         - Update feature list from .pinerc');
 WriteLn('   X     eXceptions     - Configure feature exceptions');
 WriteLn;
 WriteLn('User: ', PineConfig.FullName, ' (', PineConfig.UserEmail, ')');
 WriteLn('Config File: ~/.pinerc');
 WriteLn;
 WriteLn('? Help     < Exit Setup     P PrevCmd     N NextCmd     Space [Select]');
End;

{ Afficher l'aide Pine }
Procedure DisplayPineHelp;Begin
 WriteLn('PINE 4.64   HELP TEXT                                          (MAIN)');
 WriteLn(StringOfChar('-', 80));
 WriteLn;
 WriteLn('Pine is a tool for reading, sending, and managing electronic messages.');
 WriteLn('Pine was developed by Computing & Communications at the University of');
 WriteLn('Washington.');
 WriteLn;
 WriteLn('MAIN MENU COMMANDS:');
 WriteLn;
 WriteLn('  ?  HELP           - Shows this help text');
 WriteLn('  C  COMPOSE        - Compose and send a message');
 WriteLn('  I  INDEX          - View messages in current folder');
 WriteLn('  L  LIST FOLDERS   - Select a folder OR news group to read');
 WriteLn('  A  ADDRESS BOOK   - Maintain address and distribution lists');
 WriteLn('  S  SETUP          - Configure or update Pine');
 WriteLn('  Q  QUIT           - Leave Pine');
 WriteLn;
 WriteLn('NAVIGATION COMMANDS:');
 WriteLn;
 WriteLn('  UP/DOWN Arrow     - Move highlight up/down one line');
 WriteLn('  P/N               - Move to Previous/Next item');
 WriteLn('  -/Space           - Page backward/forward');
 WriteLn('  <                 - Return to previous screen');
 WriteLn('  M                 - Return to main menu from anywhere');
 WriteLn;
 WriteLn('MESSAGE COMMANDS:');
 WriteLn('  Enter/Return      - View highlighted message');
 WriteLn('  R                 - Reply to current message');
 WriteLn('  F                 - Forward current message');
 WriteLn('  D                 - Mark current message for deletion');
 WriteLn('  U                 - Unmark current message');
 WriteLn;
 WriteLn('? Help     < Exit Help     P PrevPage     Space NextPage');
End;

{ Interface interactive Pine simulÇe }
Procedure RunPineInterface;Begin
 WriteLn('=== Pine Interactive Interface Simulation ===');
 WriteLn;
 WriteLn('Simulation of Pine 4.64 interface with automatic command execution:');
 WriteLn;
  { êcran principal }
 WriteLn('> Main Menu Screen');
 DisplayPineMainScreen;
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Index des messages }
 WriteLn('> Message Index (I)');
 DisplayPineMessageIndex;
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Lecture d'un message }
 WriteLn('> Reading Message 1 (Enter)');
 DisplayPineMessage(0);
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Liste des dossiers }
 WriteLn('> Folder List (L)');
 DisplayPineFolderList;
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Composition }
 WriteLn('> Compose Message (C)');
 DisplayPineCompose;
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Configuration }
 WriteLn('> Setup Configuration (S)');
 DisplayPineSetup;
 WriteLn;
 WriteLn('[Press any key to continue...]');
 WriteLn;
  { Aide }
 WriteLn('> Help System (?)');
 DisplayPineHelp;
 WriteLn;
 WriteLn('=== End of Pine Interface Simulation ===');
End;

 { Analyser les arguments de ligne de commande }
Procedure ParsePineCommandLine;
Var
 I: Integer;
 Param: String;
 Action: String;
Begin
 Action := 'interactive';
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--version') Then Begin
   Action := 'version';
  End
  Else If (LowerCase(Param) = '-h') or (LowerCase(Param) = '--help') Then Begin
   Action := 'help';
  End
  Else If (LowerCase(Param) = '-i') or (LowerCase(Param) = '--index') Then Begin
   Action := 'index';
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--config') Then Begin
   Action := 'config';
  End
  Else If (LowerCase(Param) = '-f') or (LowerCase(Param) = '--folders') Then Begin
   Action := 'folders';
  End
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--stats') Then Begin
   Action := 'stats';
  End
  Else If LowerCase(Param) = '-pine' Then Begin
   { Option Pine standard }
   Action := 'interactive';
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Param√®tre non reconnu }
  End;
  Inc(I);
 End;
  { CrÇer les donnÇes d'exemple }
 CreateDefaultFolders;
 CreatePineSampleMessages;
 UpdatePineStats;
 { Mettre Ö jour les statistiques des dossiers }
 With PineFolders[0] Do Begin { INBOX }
  MessageCount := PineStats.TotalMessages;
  NewMessages := PineStats.NewMessages;
  UnreadMessages := PineStats.UnreadMessages;
  Size := PineStats.TotalSize;
 End;
  { ExÇcuter l'action }
 Case Action Of
  'version': Begin
   WriteLn('Pine 4.64 - Program for Internet News & Email');
   WriteLn('NETWORKKIT-P Implementation');
   WriteLn('Compatible with University of Washington Pine');
   WriteLn;
   WriteLn('Built: Feb 21, 2026');
   WriteLn('Version: 4.64 (NETWORKKIT-P variant)');
  End;
  'index': DisplayPineMessageIndex;
  'config': DisplayPineSetup;
  'folders': DisplayPineFolderList;
  'stats': Begin
   WriteLn('Pine Mail Statistics:');
   WriteLn('Total Messages: ', PineStats.TotalMessages);
   WriteLn('New Messages: ', PineStats.NewMessages);
   WriteLn('Read Messages: ', PineStats.ReadMessages);
   WriteLn('Unread Messages: ', PineStats.UnreadMessages);
   WriteLn('Deleted Messages: ', PineStats.DeletedMessages);
   WriteLn('Total Size: ', PineStats.TotalSize, ' bytes');
   WriteLn('Total Folders: ', PineStats.TotalFolders);
  End;
  'interactive': RunPineInterface;
  'help': Begin
   { L'aide sera affich√©e par le bloc principal }
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedPine;
Begin
 WriteLn('PINE 4.64 [NETWORKKIT-P] Email Client (simulation)');
 WriteLn('====================================================');
 WriteLn;
 WriteLn('PINE 4.64   MAIN MENU         Folder: INBOX  5 Messages');
 WriteLn;
 WriteLn('     ?     HELP               -  Get help using Pine');
 WriteLn('     C     COMPOSE MESSAGE   -  Compose and send');
 WriteLn('     I     MESSAGE INDEX     -  View messages');
 WriteLn('     L     FOLDER LIST       -  Select a folder');
 WriteLn('     A     ADDRESS BOOK      -  Update address book');
 WriteLn('     S     SETUP             -  Configure Pine');
 WriteLn('     Q     QUIT              -  Quit Pine');
 WriteLn;
 WriteLn(' [Folder "INBOX" opened with 5 messages]');
 WriteLn(' [You have 1 new message]');
 WriteLn;
 WriteLn('? Help     P PrevCmd     N NextCmd     Space [Select]');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('PINE : Cette commande permet de lancer le programme de ',
          'nouvelles Internet et courriel.');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  PINE [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -h, --help            Afficher cette aide');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn('  -i, --index           Afficher l''index des messages');
  WriteLn('  -c, --config          Afficher la configuration');
  WriteLn('  -f, --folders         Afficher la liste des dossiers');
  WriteLn('  -s, --stats           Afficher les statistiques');
  WriteLn('  -pine                 Mode Pine standard (interactif)');
  WriteLn;
  WriteLn('Fonctionnalit√©s principales :');
  WriteLn('  - Interface utilisateur intuitive en mode texte');
  WriteLn('  - Lecture et gestion des courriels avec processus lÇgers');
  WriteLn('  - Composition avec Çditeur intÇgrÇ (Pico)');
  WriteLn('  - Carnet d''adresses intÇgrÇ');
  WriteLn('  - Support SMTP, POP3, IMAP et NNTP');
  WriteLn('  - Gestion avancÇe des dossiers');
  WriteLn('  - Filtres et rägles de classement');
  WriteLn('  - Support des piäces jointes');
  WriteLn('  - Correcteur orthographique');
  WriteLn('  - Personnalisation compläte');
  WriteLn;
  WriteLn('Commandes principales :');
  WriteLn('  Menu principal :');
  WriteLn('    ?     Aide');
  WriteLn('    C     Composer un message');
  WriteLn('    I     Index des messages');
  WriteLn('    L     Liste des dossiers');
  WriteLn('    A     Carnet d''adresses');
  WriteLn('    S     Configuration');
  WriteLn('    Q     Quitter');
  WriteLn;
  WriteLn('  Index des messages :');
  WriteLn('    Enter   Lire le message sÇlectionnÇ');
  WriteLn('    R       RÇpondre au message');
  WriteLn('    F       TransfÇrer le message');
  WriteLn('    D       Supprimer le message');
  WriteLn('    U       Restaurer le message');
  WriteLn('    N/P     Message suivant/prÇcÇdent');
  WriteLn('    Space   Page suivante');
  WriteLn('    -       Page prÇcÇdente');
  WriteLn;
  WriteLn('  Lecture de message :');
  WriteLn('    N/P     Message suivant/prÇcÇdent');
  WriteLn('    R       RÇpondre');
  WriteLn('    F       TransfÇrer');
  WriteLn('    D       Supprimer');
  WriteLn('    S       Sauvegarder dans dossier');
  WriteLn('    E       Exporter');
  WriteLn('    |       Pipe vers commande');
  WriteLn;
  WriteLn('  Composition :');
  WriteLn('    ^X      Envoyer le message');
  WriteLn('    ^C      Annuler');
  WriteLn('    ^R      Lire fichier');
  WriteLn('    ^O      êcrire fichier');
  WriteLn('    ^T      VÇrifier orthographe');
  WriteLn('    ^J      Justifier paragraphe');
  WriteLn;
  WriteLn('Gestion des processus lÇgers :');
  WriteLn('  Pine organise automatiquement les messages par processus lÇger');
  WriteLn('  (conversation). Les rÇponses sont indentÇes sous le');
  WriteLn('  message original pour faciliter le suivi.');
  WriteLn;
  WriteLn('Configuration :');
  WriteLn('  ~/.pinerc         Fichier de configuration principal');
  WriteLn('  ~/.pine-debug[1-4] Fichiers de debug');
  WriteLn('  ~/.signature      Signature automatique');
  WriteLn('  ~/.addressbook    Carnet d''adresses personnel');
  WriteLn('  ~/mail/           RÇpertoire des dossiers de courriel');
  WriteLn;
  WriteLn('Dossiers par dÇfaut :');
  WriteLn('  INBOX             Boåte de rÇception');
  WriteLn('  sent-mail         Messages envoyÇs');
  WriteLn('  saved-messages    Messages sauvegardÇs');
  WriteLn('  drafts            Brouillons');
  WriteLn('  Trash             Corbeille');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  PINE              # Mode interactif complet');
  WriteLn('  PINE -i           # Afficher index messages');
  WriteLn('  PINE -f           # Afficher dossiers');
  WriteLn('  PINE --config     # Voir configuration');
  WriteLn('  PINE --stats      # Statistiques mail');
  WriteLn;
  WriteLn('Note: Client de messagerie avancÇ compatible avec');
  WriteLn('Pine de l''University of Washington. Interface compläte');
  WriteLn('avec support threads, piäces jointes et configuration.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('Pine 4.64 - Program for Internet News & Email');
  WriteLn('NETWORKKIT-P Implementation');
  WriteLn;
  WriteLn('Compatible avec Pine standard Unix/Linux');
  WriteLn('êcrit par Sylvain Maltais pour NETWORKKIT-P');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializePineConfig;
  ParsePineCommandLine;
  {$ELSE}
  ShowSimulatedPine;
  {$ENDIF}
 End;
END.
