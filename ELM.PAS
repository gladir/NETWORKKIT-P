{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description:  Commande elm (Electronic Mail))
}

Program ELM;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, Classes, StrUtils, DateUtils;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure d'un message �lectronique }
 TMailMessage = Record
  MessageID: Integer;                       { ID unique du message }
  FromAddr: String[255];                    { Adresse exp�diteur }
  FromName: String[255];                    { Nom exp�diteur }
  ToAddr: String[255];                      { Adresse destinataire }
  ToName: String[255];                      { Nom destinataire }
  Subject: String[255];                     { Sujet }
  DateSent: TDateTime;                      { Date d'envoi }
  DateReceived: TDateTime;                  { Date de r�ception }
  Priority: Integer;                        { Priorit� (1=haute, 2=normale, 3=basse) }
  Status: String[32];                       { �tat (new, read, replied, forwarded, deleted) }
  Size: LongInt;                            { Taille en octets }
  Lines: Integer;                           { Nombre de lignes }
  ContentType: String[64];                  { Type de contenu }
  Encoding: String[32];                     { Encodage }
  MessageBody: TStringList;                 { Corps du message }
  Headers: TStringList;                     { Ent�tes compl�tes }
  Attachments: Array[0..15] of String[255]; { Pi�ces jointes }
  AttachmentCount: Integer;                 { Nombre de pi�ces jointes }
  IsRead: Boolean;                          { Message lu }
  IsDeleted: Boolean;                       { Message supprim� }
  IsReplied: Boolean;                       { R�ponse envoy�e }
  IsForwarded: Boolean;                     { Message transf�r� }
  IsFlagged: Boolean;                       { Message marqu� }
 End;

 { Configuration de ELM }
 TElmConfig = Record
  UserName: String[64];       { Nom utilisateur }
  UserEmail: String[255];     { Adresse email }
  FullName: String[255];      { Nom complet }
  MailDir: String[255];       { Répertoire mail }
  InboxFile: String[255];     { Fichier boîte de réception }
  SentFile: String[255];      { Fichier messages envoyés }
  DraftFile: String[255];     { Fichier brouillons }
  TrashFile: String[255];     { Fichier corbeille }
  SMTPServer: String[255];    { Serveur SMTP }
  SMTPPort: Word;             { Port SMTP }
  POP3Server: String[255];    { Serveur POP3 }
  POP3Port: Word;             { Port POP3 }
  IMAPServer: String[255];    { Serveur IMAP }
  IMAPPort: Word;             { Port IMAP }
  UseSSL: Boolean;            { Utiliser SSL/TLS }
  AuthMethod: String[32];     { Méthode d'authentification }
  Password: String[255];      { Mot de passe }
  Editor: String[255];        { Éditeur par défaut }
  Pager: String[255];         { Programme de pagination }
  PrintCommand: String[255];  { Commande d'impression }
  Signature: String[255];     { Fichier signature }
  ReplyPrefix: String[16];    { Préfixe réponse (Re:) }
  ForwardPrefix: String[16];  { Préfixe transfert (Fw:) }
  DateFormat: String[32];     { Format de date }
  SortBy: String[16];         { Tri (date, sender, subject, size) }
  SortOrder: String[16];      { Ordre (asc, desc) }
  AutoSave: Boolean;          { Sauvegarde automatique }
  AutoSaveInterval: Integer;  { Intervalle sauvegarde (min) }
  ShowHeaders: Boolean;       { Afficher en-têtes }
  WrapLines: Integer;         { Retour à la ligne }
  PageSize: Integer;          { Taille de page }
  ConfirmDelete: Boolean;     { Confirmer suppression }
  ConfirmQuit: Boolean;       { Confirmer sortie }
  BeepOnNewMail: Boolean;     { Bip nouveau message }
  CheckInterval: Integer;     { Intervalle vérification (min) }
 End;

 { Statistiques de la boîte mail }
 TMailStats = Record
  TotalMessages: Integer;     { Total messages }
  NewMessages: Integer;       { Nouveaux messages }
  ReadMessages: Integer;      { Messages lus }
  UnreadMessages: Integer;    { Messages non lus }
  DeletedMessages: Integer;   { Messages supprimés }
  RepliedMessages: Integer;   { Messages avec réponse }
  ForwardedMessages: Integer; { Messages transférés }
  FlaggedMessages: Integer;   { Messages marqués }
  TotalSize: Int64;           { Taille totale }
  OldestMessage: TDateTime;   { Message le plus ancien }
  NewestMessage: TDateTime;   { Message le plus récent }
  LastCheck: TDateTime;       { Dernière vérification }
 End;

 { Interface utilisateur ELM }
 TElmInterface = Record
  CurrentFolder: String[32];  { Dossier actuel }
  CurrentMessage: Integer;    { Message actuel }
  PageStart: Integer;         { Début de page }
  PageEnd: Integer;           { Fin de page }
  ListMode: String[16];       { Mode liste (summary, detailed) }
  ViewMode: String[16];       { Mode vue (normal, headers, raw) }
  SearchPattern: String[255]; { Motif de recherche }
  FilterActive: Boolean;      { Filtre actif }
  FilterPattern: String[255]; { Motif de filtre }
  MenuLevel: Integer;         { Niveau de menu }
  StatusMessage: String[255]; { Message de statut }
  LastCommand: String[32];    { Dernière commande }
  HelpVisible: Boolean;       { Aide visible }
  PromptVisible: Boolean;     { Invite visible }
 End;

Var
 { Variables globales }
 ElmConfig: TElmConfig;
 MailMessages: Array[0..9999] of TMailMessage;
 MessageCount: Integer;
 MailStats: TMailStats;
 ElmInterface: TElmInterface;

 { Commandes et états }
 QuitRequested: Boolean;
 DataChanged: Boolean;
 LastErrorMessage: String[255];

{ Initialiser la configuration ELM }
Procedure InitializeElmConfig;
Begin
 With ElmConfig Do Begin
  UserName := 'user';
  UserEmail := 'user@localhost';
  FullName := 'Local User';
  MailDir := '/var/mail/';
  InboxFile := '/var/mail/user';
  SentFile := '/var/mail/sent';
  DraftFile := '/var/mail/drafts';
  TrashFile := '/var/mail/trash';
  SMTPServer := 'localhost';
  SMTPPort := 25;
  POP3Server := 'localhost';
  POP3Port := 110;
  IMAPServer := 'localhost';
  IMAPPort := 143;
  UseSSL := False;
  AuthMethod := 'PLAIN';
  Password := '';
  Editor := 'vi';
  Pager := 'more';
  PrintCommand := 'lpr';
  Signature := '~/.signature';
  ReplyPrefix := 'Re: ';
  ForwardPrefix := 'Fw: ';
  DateFormat := 'dd/mm/yyyy hh:nn';
  SortBy := 'date';
  SortOrder := 'desc';
  AutoSave := True;
  AutoSaveInterval := 5;
  ShowHeaders := False;
  WrapLines := 78;
  PageSize := 20;
  ConfirmDelete := True;
  ConfirmQuit := True;
  BeepOnNewMail := True;
  CheckInterval := 5;
 End;

 { Initialiser l'interface }
 With ElmInterface Do Begin
  CurrentFolder := 'INBOX';
  CurrentMessage := 1;
  PageStart := 1;
  PageEnd := ElmConfig.PageSize;
  ListMode := 'summary';
  ViewMode := 'normal';
  SearchPattern := '';
  FilterActive := False;
  FilterPattern := '';
  MenuLevel := 0;
  StatusMessage := 'ELM Mail Reader ready';
  LastCommand := '';
  HelpVisible := False;
  PromptVisible := True;
 End;

 { Initialiser les variables globales }
 MessageCount := 0;
 QuitRequested := False;
 DataChanged := False;
 LastErrorMessage := '';
End;

{ Créer des messages d'exemple }
Procedure CreateSampleMessages;
Var
 I: Integer;
Begin
 { Message 1: Nouveau message important }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'admin@company.com';
  FromName := 'System Administrator';
  ToAddr := ElmConfig.UserEmail;
  ToName := ElmConfig.FullName;
  Subject := 'Système de maintenance programmée';
  DateSent := Now - 0.5; { Il y a 12 heures }
  DateReceived := Now - 0.4;
  Priority := 1; { Haute }
  Status := 'new';
  Size := 1024;
  Lines := 15;
  ContentType := 'text/plain';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 0;
  IsRead := False;
  IsDeleted := False;
  IsReplied := False;
  IsForwarded := False;
  IsFlagged := True;

  { Corps du message }
  MessageBody.Add('Cher utilisateur,');
  MessageBody.Add('');
  MessageBody.Add('Une maintenance système est programmée ce week-end.');
  MessageBody.Add('Le système sera indisponible samedi de 02:00 à 06:00.');
  MessageBody.Add('');
  MessageBody.Add('Veuillez planifier vos tâches en conséquence.');
  MessageBody.Add('');
  MessageBody.Add('Cordialement,');
  MessageBody.Add('L''équipe système');

  { En-têtes }
  Headers.Add('From: admin@company.com (System Administrator)');
  Headers.Add('To: ' + ElmConfig.UserEmail);
  Headers.Add('Subject: Système de maintenance programmée');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  Headers.Add('Message-ID: <maintenance-2026022101@company.com>');
  Headers.Add('Priority: high');
  Headers.Add('Content-Type: text/plain; charset=UTF-8');
 End;
 Inc(MessageCount);

 { Message 2: Message lu avec réponse }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'colleague@company.com';
  FromName := 'Jean Dupont';
  ToAddr := ElmConfig.UserEmail;
  ToName := ElmConfig.FullName;
  Subject := 'Réunion équipe lundi matin';
  DateSent := Now - 2.2;
  DateReceived := Now - 2.1;
  Priority := 2; { Normale }
  Status := 'read';
  Size := 512;
  Lines := 8;
  ContentType := 'text/plain';
  Encoding := 'UTF-8';
  MessageBody := TStringList.Create;
  Headers := TStringList.Create;
  AttachmentCount := 1;
  IsRead := True;
  IsDeleted := False;
  IsReplied := True;
  IsForwarded := False;
  IsFlagged := False;

  { Corps du message }
  MessageBody.Add('Bonjour,');
  MessageBody.Add('');
  MessageBody.Add('N''oublie pas la réunion équipe lundi à 9h en salle A12.');
  MessageBody.Add('Ordre du jour en pièce jointe.');
  MessageBody.Add('');
  MessageBody.Add('À lundi,');
  MessageBody.Add('Jean');

  { Pièce jointe }
  Attachments[0] := 'agenda-reunion.pdf';

  { En-têtes }
  Headers.Add('From: colleague@company.com (Jean Dupont)');
  Headers.Add('To: ' + ElmConfig.UserEmail);
  Headers.Add('Subject: Réunion équipe lundi matin');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  Headers.Add('Message-ID: <meeting-2026021901@company.com>');
 End;
 Inc(MessageCount);

 { Message 3: Newsletter }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'newsletter@techsite.com';
  FromName := 'TechSite Newsletter';
  ToAddr := ElmConfig.UserEmail;
  ToName := ElmConfig.FullName;
  Subject := 'Actualités technologiques de la semaine';
  DateSent := Now - 3.5;
  DateReceived := Now - 3.4;
  Priority := 3; { Basse }
  Status := 'read';
  Size := 2048;
  Lines := 25;
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

  { Corps du message }
  MessageBody.Add('=== NEWSLETTER TECHSITE ===');
  MessageBody.Add('');
  MessageBody.Add('1. Nouvelles versions de Free Pascal');
  MessageBody.Add('2. Sécurité réseau : les bonnes pratiques');
  MessageBody.Add('3. Outils de développement Open Source');
  MessageBody.Add('');
  MessageBody.Add('Lire la suite sur notre site web...');

  { En-têtes }
  Headers.Add('From: newsletter@techsite.com (TechSite Newsletter)');
  Headers.Add('To: ' + ElmConfig.UserEmail);
  Headers.Add('Subject: Actualités technologiques de la semaine');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  Headers.Add('Message-ID: <newsletter-2026021801@techsite.com>');
  Headers.Add('List-Unsubscribe: <mailto:unsubscribe@techsite.com>');
 End;
 Inc(MessageCount);

 { Message 4: Spam supprimé }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := 'promo@spam.example';
  FromName := 'Promotion Spéciale';
  ToAddr := ElmConfig.UserEmail;
  ToName := ElmConfig.FullName;
  Subject := 'Offre exceptionnelle limitée !!!';
  DateSent := Now - 1.8;
  DateReceived := Now - 1.7;
  Priority := 2;
  Status := 'deleted';
  Size := 1536;
  Lines := 20;
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

  { Corps du message }
  MessageBody.Add('OFFRE EXCEPTIONNELLE !!!!');
  MessageBody.Add('Cliquez ici pour gagner 1000€ !');
  MessageBody.Add('');
  MessageBody.Add('[Message identifié comme spam]');

  { En-têtes }
  Headers.Add('From: promo@spam.example (Promotion Spéciale)');
  Headers.Add('To: ' + ElmConfig.UserEmail);
  Headers.Add('Subject: Offre exceptionnelle limitée !!!');
  Headers.Add('Date: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss', DateSent));
  Headers.Add('X-Spam-Score: 9.5');
 End;
 Inc(MessageCount);

 { Message 5: Brouillon }
 With MailMessages[MessageCount] Do Begin
  MessageID := MessageCount + 1;
  FromAddr := ElmConfig.UserEmail;
  FromName := ElmConfig.FullName;
  ToAddr := 'friend@example.com';
  ToName := 'Mon ami';
  Subject := 'Invitation dîner samedi';
  DateSent := 0; { Pas encore envoyé }
  DateReceived := Now - 0.1;
  Priority := 2;
  Status := 'draft';
  Size := 256;
  Lines := 6;
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

  { Corps du message }
  MessageBody.Add('Salut,');
  MessageBody.Add('');
  MessageBody.Add('Es-tu libre samedi soir pour un dîner ?');
  MessageBody.Add('');
  MessageBody.Add('[Brouillon - à terminer]');

  { En-têtes }
  Headers.Add('From: ' + ElmConfig.UserEmail + ' (' + ElmConfig.FullName + ')');
  Headers.Add('To: friend@example.com (Mon ami)');
  Headers.Add('Subject: Invitation dîner samedi');
  Headers.Add('Date: [À définir]');
 End;
 Inc(MessageCount);
End;

{ Calculer les statistiques }
Procedure UpdateMailStats;
Var
 I: Integer;
Begin
 FillChar(MailStats, SizeOf(MailStats), 0);
 MailStats.OldestMessage := Now;
 MailStats.NewestMessage := 0;

 For I := 0 To MessageCount - 1 Do Begin
  With MailMessages[I] Do Begin
   Inc(MailStats.TotalMessages);
   MailStats.TotalSize := MailStats.TotalSize + Size;

   If Status = 'new' Then Inc(MailStats.NewMessages);
   If IsRead Then Inc(MailStats.ReadMessages) Else Inc(MailStats.UnreadMessages);
   If IsDeleted Then Inc(MailStats.DeletedMessages);
   If IsReplied Then Inc(MailStats.RepliedMessages);
   If IsForwarded Then Inc(MailStats.ForwardedMessages);
   If IsFlagged Then Inc(MailStats.FlaggedMessages);

   If DateReceived < MailStats.OldestMessage Then
    MailStats.OldestMessage := DateReceived;
   If DateReceived > MailStats.NewestMessage Then
    MailStats.NewestMessage := DateReceived;
  End;
 End;

 MailStats.LastCheck := Now;
End;

{ Afficher l'en-tête ELM }
Procedure DisplayElmHeader;
Begin
 WriteLn('ELM 1.00 [NETWORKKIT-P]                      ', FormatDateTime('dd/mm/yyyy hh:nn', Now));
 WriteLn('Dossier: ', ElmInterface.CurrentFolder, '  Messages: ', MessageCount,
         '  Nouveaux: ', MailStats.NewMessages);
 WriteLn(StringOfChar('=', 78));
End;

{ Afficher la liste des messages }
Procedure DisplayMessageList;
Var
 I: Integer;
 StatusChar: Char;
 PriorityChar: Char;
 FromDisplay: String;
 SubjectDisplay: String;
 DateDisplay: String;
Begin
 WriteLn('  # St Pri  De                  Sujet                           Date       Taille');
 WriteLn(StringOfChar('-', 78));

 For I := ElmInterface.PageStart - 1 To ElmInterface.PageEnd - 1 Do Begin
  If I >= MessageCount Then Break;

  With MailMessages[I] Do Begin
   { Caractère de statut }
   If IsDeleted Then StatusChar := 'D'
   Else If Status = 'new' Then StatusChar := 'N'
   Else If IsReplied Then StatusChar := 'R'
   Else If IsForwarded Then StatusChar := 'F'
   Else If IsRead Then StatusChar := ' '
   Else StatusChar := 'U';

   { Caractère de priorité }
   Case Priority Of
    1: PriorityChar := '!';
    3: PriorityChar := '-';
   Else
    PriorityChar := ' ';
   End;

   { Formatage des champs }
   FromDisplay := Copy(FromName + '                   ', 1, 19);
   SubjectDisplay := Copy(Subject + '                               ', 1, 31);
   DateDisplay := FormatDateTime('dd/mm/yy', DateReceived);

   { Indicateur de message actuel }
   If I + 1 = ElmInterface.CurrentMessage Then
    Write('>')
   Else
    Write(' ');

   WriteLn(I + 1:3, ' ', StatusChar, '  ', PriorityChar, '  ',
           FromDisplay, ' ', SubjectDisplay, ' ', DateDisplay, Size:8);
  End;
 End;

 WriteLn(StringOfChar('-', 78));
 WriteLn('Message ', ElmInterface.CurrentMessage, ' de ', MessageCount,
         ' (Page ', (ElmInterface.PageStart div ElmConfig.PageSize) + 1, ')');
End;

{ Afficher un message }
Procedure DisplayMessage(MessageIndex: Integer);
Var
 I: Integer;
Begin
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message non trouvé');
  Exit;
 End;

 With MailMessages[MessageIndex] Do Begin
  WriteLn(StringOfChar('=', 78));
  WriteLn('Message ', MessageID, ' de ', MessageCount, ' (', Status, ')');
  WriteLn('De      : ', FromName, ' <', FromAddr, '>');
  WriteLn('À       : ', ToName, ' <', ToAddr, '>');
  WriteLn('Sujet   : ', Subject);
  WriteLn('Date    : ', FormatDateTime('dd/mm/yyyy hh:nn:ss', DateSent));
  If AttachmentCount > 0 Then Begin
   Write('P.jointe: ');
   For I := 0 To AttachmentCount - 1 Do Begin
    Write(Attachments[I]);
    If I < AttachmentCount - 1 Then Write(', ');
   End;
   WriteLn;
  End;
  WriteLn('Taille  : ', Size, ' octets (', Lines, ' lignes)');
  WriteLn(StringOfChar('-', 78));

  { Afficher le corps du message }
  If MessageBody <> nil Then Begin
   For I := 0 To MessageBody.Count - 1 Do
    WriteLn(MessageBody[I]);
  End Else Begin
   WriteLn('[Corps du message non disponible]');
  End;

  WriteLn(StringOfChar('=', 78));

  { Marquer comme lu }
  If not IsRead Then Begin
   IsRead := True;
   Status := 'read';
   Dec(MailStats.UnreadMessages);
   Inc(MailStats.ReadMessages);
   DataChanged := True;
  End;
 End;
End;

{ Afficher les en-têtes d'un message }
Procedure DisplayMessageHeaders(MessageIndex: Integer);
Var
 I: Integer;
Begin
 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  WriteLn('Message non trouvé');
  Exit;
 End;

 With MailMessages[MessageIndex] Do Begin
  WriteLn(StringOfChar('=', 78));
  WriteLn('En-têtes du message ', MessageID);
  WriteLn(StringOfChar('-', 78));

  If Headers <> nil Then Begin
   For I := 0 To Headers.Count - 1 Do
    WriteLn(Headers[I]);
  End Else Begin
   WriteLn('[En-têtes non disponibles]');
  End;

  WriteLn(StringOfChar('=', 78));
 End;
End;

{ Marquer un message pour suppression }
Function DeleteMessage(MessageIndex: Integer): Boolean;
Begin
 DeleteMessage := False;

 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  LastErrorMessage := 'Message non trouvé';
  Exit;
 End;

 With MailMessages[MessageIndex] Do Begin
  If IsDeleted Then Begin
   { Restaurer le message }
   IsDeleted := False;
   Status := 'read';
   Dec(MailStats.DeletedMessages);
   LastErrorMessage := 'Message restauré';
  End Else Begin
   { Marquer pour suppression }
   If ElmConfig.ConfirmDelete Then Begin
    Write('Supprimer le message "', Copy(Subject, 1, 40), '" ? (o/N) ');
    { En simulation, on accepte }
    WriteLn('o');
   End;

   IsDeleted := True;
   Status := 'deleted';
   Inc(MailStats.DeletedMessages);
   LastErrorMessage := 'Message marqué pour suppression';
  End;

  DataChanged := True;
  DeleteMessage := True;
 End;
End;

{ Répondre à un message }
Function ReplyToMessage(MessageIndex: Integer): Boolean;
Var
 ReplySubject: String;
 I: Integer;
Begin
 ReplyToMessage := False;

 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  LastErrorMessage := 'Message non trouvé';
  Exit;
 End;

 With MailMessages[MessageIndex] Do Begin
  { Préparer le sujet de réponse }
  If Copy(UpperCase(Subject), 1, 3) = 'RE:' Then
   ReplySubject := Subject
  Else
   ReplySubject := ElmConfig.ReplyPrefix + Subject;

  WriteLn(StringOfChar('=', 78));
  WriteLn('Réponse au message de ', FromName);
  WriteLn('Sujet: ', ReplySubject);
  WriteLn(StringOfChar('-', 78));
  WriteLn;
  WriteLn('À      : ', FromAddr);
  WriteLn('Sujet  : ', ReplySubject);
  WriteLn;
  WriteLn('Corps du message:');
  WriteLn('> Message original du ', FormatDateTime('dd/mm/yyyy', DateSent), ':');

  { Citer le message original }
  If MessageBody <> nil Then Begin
   For I := 0 To MessageBody.Count - 1 Do Begin
    If I > 5 Then Break;
    WriteLn('> ', MessageBody[I]);
   End;
   If MessageBody.Count > 5 Then
    WriteLn('> [...]');
  End;

  WriteLn;
  WriteLn('Votre réponse:');
  WriteLn('[Tapez votre réponse ici]');
  WriteLn;
  WriteLn('Réponse envoyée avec succès !');

  { Marquer comme ayant reçu une réponse }
  IsReplied := True;
  Inc(MailStats.RepliedMessages);
  DataChanged := True;
  ReplyToMessage := True;
 End;
End;

{ Transférer un message }
Function ForwardMessage(MessageIndex: Integer): Boolean;
Var
 ForwardSubject: String;
 I: Integer;
Begin
 ForwardMessage := False;

 If (MessageIndex < 0) or (MessageIndex >= MessageCount) Then Begin
  LastErrorMessage := 'Message non trouvé';
  Exit;
 End;

 With MailMessages[MessageIndex] Do Begin
  { Préparer le sujet de transfert }
  If Copy(UpperCase(Subject), 1, 3) = 'FW:' Then
   ForwardSubject := Subject
  Else
   ForwardSubject := ElmConfig.ForwardPrefix + Subject;

  WriteLn(StringOfChar('=', 78));
  WriteLn('Transfert du message de ', FromName);
  WriteLn('Sujet: ', ForwardSubject);
  WriteLn(StringOfChar('-', 78));
  WriteLn;
  WriteLn('À      : [Entrez l''adresse destinataire]');
  WriteLn('Sujet  : ', ForwardSubject);
  WriteLn;
  WriteLn('Corps du message:');
  WriteLn('--- Message transféré ---');
  WriteLn('De: ', FromName, ' <', FromAddr, '>');
  WriteLn('Date: ', FormatDateTime('dd/mm/yyyy hh:nn', DateSent));
  WriteLn('Sujet: ', Subject);
  WriteLn;

  { Inclure le message original }
  If MessageBody <> nil Then Begin
   For I := 0 To MessageBody.Count - 1 Do
    WriteLn(MessageBody[I]);
  End;

  WriteLn('--- Fin du message transféré ---');
  WriteLn;
  WriteLn('Message transféré avec succès !');

  { Marquer comme transféré }
  IsForwarded := True;
  Inc(MailStats.ForwardedMessages);
  DataChanged := True;
  ForwardMessage := True;
 End;
End;

{ Créer un nouveau message }
Function ComposeNewMessage: Boolean;
Begin
 ComposeNewMessage := False;

 WriteLn(StringOfChar('=', 78));
 WriteLn('Nouveau message');
 WriteLn(StringOfChar('-', 78));
 WriteLn;
 WriteLn('De     : ', ElmConfig.FullName, ' <', ElmConfig.UserEmail, '>');
 WriteLn('À      : [Entrez l''adresse destinataire]');
 WriteLn('Cc     : ');
 WriteLn('Sujet  : [Entrez le sujet]');
 WriteLn;
 WriteLn('Corps du message:');
 WriteLn('[Tapez votre message ici]');
 WriteLn;
 WriteLn('-- ');
 WriteLn('[Signature automatique]');
 WriteLn;

 Write('Envoyer ce message ? (o/N) ');
 { En simulation, on accepte }
 WriteLn('o');

 WriteLn('Message envoyé avec succès !');
 ComposeNewMessage := True;
End;

{ Rechercher dans les messages }
Function SearchMessages(Pattern: String): Integer;
Var
 I, Found: Integer;
Begin
 Found := 0;
 Pattern := LowerCase(Pattern);

 WriteLn('Recherche de "', Pattern, '"...');
 WriteLn;

 For I := 0 To MessageCount - 1 Do Begin
  With MailMessages[I] Do Begin
   If (Pos(Pattern, LowerCase(Subject)) > 0) or
      (Pos(Pattern, LowerCase(FromName)) > 0) or
      (Pos(Pattern, LowerCase(FromAddr)) > 0) Then Begin
    Inc(Found);
    Write(I + 1:3, ': ');
    WriteLn(Copy(FromName + '                   ', 1, 19), ' - ', Subject);
   End;
  End;
 End;

 WriteLn;
 WriteLn(Found, ' message(s) trouvé(s)');
 SearchMessages := Found;
End;

{ Afficher les statistiques }
Procedure DisplayMailStats;
Begin
 WriteLn(StringOfChar('=', 78));
 WriteLn('Statistiques de la boîte mail');
 WriteLn(StringOfChar('-', 78));
 WriteLn('Dossier actuel      : ', ElmInterface.CurrentFolder);
 WriteLn('Total des messages  : ', MailStats.TotalMessages);
 WriteLn('Messages nouveaux   : ', MailStats.NewMessages);
 WriteLn('Messages lus        : ', MailStats.ReadMessages);
 WriteLn('Messages non lus    : ', MailStats.UnreadMessages);
 WriteLn('Messages supprimés  : ', MailStats.DeletedMessages);
 WriteLn('Avec réponse        : ', MailStats.RepliedMessages);
 WriteLn('Transférés          : ', MailStats.ForwardedMessages);
 WriteLn('Marqués             : ', MailStats.FlaggedMessages);
 WriteLn('Taille totale       : ', MailStats.TotalSize, ' octets');

 If MailStats.TotalMessages > 0 Then Begin
  WriteLn('Message plus ancien : ', FormatDateTime('dd/mm/yyyy hh:nn', MailStats.OldestMessage));
  WriteLn('Message plus récent : ', FormatDateTime('dd/mm/yyyy hh:nn', MailStats.NewestMessage));
 End;

 WriteLn('Dernière vérif.     : ', FormatDateTime('dd/mm/yyyy hh:nn', MailStats.LastCheck));
 WriteLn(StringOfChar('=', 78));
End;

{ Afficher la configuration }
Procedure DisplayElmConfig;
Begin
 WriteLn(StringOfChar('=', 78));
 WriteLn('Configuration ELM');
 WriteLn(StringOfChar('-', 78));
 WriteLn('Utilisateur         : ', ElmConfig.FullName, ' <', ElmConfig.UserEmail, '>');
 WriteLn('Répertoire mail     : ', ElmConfig.MailDir);
 WriteLn('Boîte de réception  : ', ElmConfig.InboxFile);
 WriteLn('Messages envoyés    : ', ElmConfig.SentFile);
 WriteLn('Brouillons          : ', ElmConfig.DraftFile);
 WriteLn('Corbeille           : ', ElmConfig.TrashFile);
 WriteLn;
 WriteLn('Serveurs:');
 WriteLn('  SMTP              : ', ElmConfig.SMTPServer, ':', ElmConfig.SMTPPort);
 WriteLn('  POP3              : ', ElmConfig.POP3Server, ':', ElmConfig.POP3Port);
 WriteLn('  IMAP              : ', ElmConfig.IMAPServer, ':', ElmConfig.IMAPPort);
 WriteLn('  SSL/TLS           : ', BoolToStr(ElmConfig.UseSSL, 'Oui', 'Non'));
 WriteLn;
 WriteLn('Outils:');
 WriteLn('  Éditeur           : ', ElmConfig.Editor);
 WriteLn('  Pager             : ', ElmConfig.Pager);
 WriteLn('  Impression        : ', ElmConfig.PrintCommand);
 WriteLn('  Signature         : ', ElmConfig.Signature);
 WriteLn;
 WriteLn('Préférences:');
 WriteLn('  Format date       : ', ElmConfig.DateFormat);
 WriteLn('  Tri               : ', ElmConfig.SortBy, ' (', ElmConfig.SortOrder, ')');
 WriteLn('  Retour ligne      : ', ElmConfig.WrapLines, ' caractères');
 WriteLn('  Taille page       : ', ElmConfig.PageSize, ' messages');
 WriteLn('  Sauveg. auto      : ', BoolToStr(ElmConfig.AutoSave, 'Oui', 'Non'));
 WriteLn('  Confirmer suppr.  : ', BoolToStr(ElmConfig.ConfirmDelete, 'Oui', 'Non'));
 WriteLn('  Bip nouveau msg   : ', BoolToStr(ElmConfig.BeepOnNewMail, 'Oui', 'Non'));
 WriteLn(StringOfChar('=', 78));
End;

{ Afficher l'aide }
Procedure DisplayElmHelp;
Begin
 WriteLn(StringOfChar('=', 78));
 WriteLn('Aide ELM - Commandes disponibles');
 WriteLn(StringOfChar('-', 78));
 WriteLn('Navigation:');
 WriteLn('  j, ↓    Message suivant           k, ↑    Message précédent');
 WriteLn('  n       Page suivante             p       Page précédente');
 WriteLn('  t       Aller au début            b       Aller à la fin');
 WriteLn('  g NUM   Aller au message NUM      /MOTIF  Rechercher');
 WriteLn;
 WriteLn('Actions sur les messages:');
 WriteLn('  r       Répondre                  f       Transférer');
 WriteLn('  d       Supprimer/Restaurer       m       Marquer');
 WriteLn('  c       Composer nouveau          s       Sauvegarder');
 WriteLn('  ESPACE  Lire message              h       Afficher en-têtes');
 WriteLn;
 WriteLn('Dossiers:');
 WriteLn('  o       Changer dossier           i       Retour à INBOX');
 WriteLn('  +       Dossier suivant           -       Dossier précédent');
 WriteLn;
 WriteLn('Système:');
 WriteLn('  !       Commande shell            |       Filtrer');
 WriteLn('  ?       Aide                      v       Version');
 WriteLn('  x       Quitter et sauver         q       Quitter sans sauver');
 WriteLn;
 WriteLn('Configuration:');
 WriteLn('  C       Afficher config           S       Statistiques');
 WriteLn('  O       Options                   A       Alias');
 WriteLn(StringOfChar('=', 78));
 WriteLn('Appuyez sur une touche pour continuer...');
End;

{ Interface interactive simulée }
Procedure RunElmInterface;
Var
 Command: String;
 MessageNum: Integer;
 SearchPattern: String;
Begin
 WriteLn('=== Interface ELM Interactive ===');
 WriteLn;
 WriteLn('Simulation d''interface interactive');
 WriteLn('Commandes simulées automatiquement:');
 WriteLn;

 { Simulation de navigation }
 WriteLn('> Liste des messages');
 DisplayElmHeader;
 DisplayMessageList;
 WriteLn;

 { Simulation de lecture d''un message }
 WriteLn('> Lecture du message 1 (ESPACE)');
 DisplayMessage(0);
 WriteLn;

 { Simulation d''aide }
 WriteLn('> Affichage de l''aide (?)');
 DisplayElmHelp;
 WriteLn;

 { Simulation de statistiques }
 WriteLn('> Affichage des statistiques (S)');
 DisplayMailStats;
 WriteLn;

 { Simulation de composition }
 WriteLn('> Composition d''un nouveau message (c)');
 ComposeNewMessage;
 WriteLn;

 { Simulation de recherche }
 WriteLn('> Recherche de "système" (/)');
 SearchMessages('système');
 WriteLn;

 WriteLn('=== Fin de simulation ===');
End;

{ Analyser la ligne de commande }
Procedure ParseElmCommandLine;
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
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--stats') Then Begin
   Action := 'stats';
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--config') Then Begin
   Action := 'config';
  End
  Else If (LowerCase(Param) = '-l') or (LowerCase(Param) = '--list') Then Begin
   Action := 'list';
  End
  Else If (LowerCase(Param) = '-i') or (LowerCase(Param) = '--interactive') Then Begin
   Action := 'interactive';
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   { Paramètre non reconnu }
  End;

  Inc(I);
 End;

 { Créer les messages d'exemple }
 CreateSampleMessages;
 UpdateMailStats;

 { Exécuter l'action }
 Case Action Of
  'version': Begin
   WriteLn('ELM 1.00 - Electronic Mail Reader');
   WriteLn('NETWORKKIT-P Implementation');
   WriteLn('Compatible avec ELM standard Unix/Linux');
  End;

  'stats': DisplayMailStats;
  'config': DisplayElmConfig;
  'list': Begin
   DisplayElmHeader;
   DisplayMessageList;
  End;
  'interactive': RunElmInterface;
  'help': Begin
   { L'aide sera affichée par le bloc principal }
  End;
 End;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedElm;
Begin
 WriteLn('ELM 1.00 [NETWORKKIT-P] Electronic Mail (simulation)');
 WriteLn('======================================================');
 WriteLn;
 WriteLn('Dossier: INBOX  Messages: 5  Nouveaux: 1');
 WriteLn('======================================================');
 WriteLn;
 WriteLn('  # St Pri  De                  Sujet');
 WriteLn('------------------------------------------------------');
 WriteLn('> 1 N  !  System Admin        Maintenance système');
 WriteLn('  2 R     Jean Dupont          Réunion équipe lundi');
 WriteLn('  3 R     TechSite Newsletter  Actualités tech');
 WriteLn('  4 D     Promotion Spéciale   Offre exceptionnelle');
 WriteLn('  5       [Brouillon]          Invitation dîner');
 WriteLn('------------------------------------------------------');
 WriteLn('Message 1 de 5 (Page 1)');
 WriteLn;
 WriteLn('Commandes: r)épondre d)upprimer c)omposer q)uitter ?');
End;
{$ENDIF}

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('ELM : Cette commande permet de lancer le ELM (Electronic Mail Reader).');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  ELM [options]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -i, --interactive     Mode interactif (défaut)');
  WriteLn('  -l, --list            Lister les messages');
  WriteLn('  -s, --stats           Afficher les statistiques');
  WriteLn('  -c, --config          Afficher la configuration');
  WriteLn('  -v, --version         Afficher la version');
  WriteLn;
  WriteLn('Fonctionnalités principales :');
  WriteLn('  - Lecture et gestion des emails');
  WriteLn('  - Composition de nouveaux messages');
  WriteLn('  - Réponse et transfert de messages');
  WriteLn('  - Organisation en dossiers');
  WriteLn('  - Recherche dans les messages');
  WriteLn('  - Support POP3, IMAP et SMTP');
  WriteLn('  - Interface en mode texte intuitive');
  WriteLn('  - Gestion des pièces jointes');
  WriteLn('  - Filtres et règles de tri');
  WriteLn('  - Carnet d''adresses intégré');
  WriteLn;
  WriteLn('Commandes interactives principales :');
  WriteLn('  Navigation:');
  WriteLn('    j, ↓        Message suivant');
  WriteLn('    k, ↑        Message précédent');
  WriteLn('    n           Page suivante');
  WriteLn('    p           Page précédente');
  WriteLn('    g NUM       Aller au message NUM');
  WriteLn('    /MOTIF      Rechercher un motif');
  WriteLn;
  WriteLn('  Actions sur les messages:');
  WriteLn('    ESPACE      Lire le message courant');
  WriteLn('    r           Répondre au message');
  WriteLn('    f           Transférer le message');
  WriteLn('    d           Supprimer/Restaurer le message');
  WriteLn('    c           Composer un nouveau message');
  WriteLn('    s           Sauvegarder le message');
  WriteLn('    h           Afficher les en-têtes complètes');
  WriteLn('    m           Marquer/Démarquer le message');
  WriteLn;
  WriteLn('  Gestion des dossiers:');
  WriteLn('    o           Ouvrir un autre dossier');
  WriteLn('    i           Retour à la boîte de réception');
  WriteLn('    +           Dossier suivant');
  WriteLn('    -           Dossier précédent');
  WriteLn;
  WriteLn('  Système:');
  WriteLn('    ?           Afficher l''aide');
  WriteLn('    S           Afficher les statistiques');
  WriteLn('    C           Afficher la configuration');
  WriteLn('    O           Modifier les options');
  WriteLn('    !           Exécuter une commande shell');
  WriteLn('    x           Quitter et sauvegarder');
  WriteLn('    q           Quitter sans sauvegarder');
  WriteLn;
  WriteLn('Types de messages supportés :');
  WriteLn('  N     Nouveau (non lu)');
  WriteLn('  R     Lu avec réponse envoyée');
  WriteLn('  F     Transféré');
  WriteLn('  D     Marqué pour suppression');
  WriteLn('  !     Priorité haute');
  WriteLn('  -     Priorité basse');
  WriteLn;
  WriteLn('Configuration :');
  WriteLn('  ~/.elmrc          Fichier de configuration principal');
  WriteLn('  ~/.elm/           Répertoire de configuration');
  WriteLn('  ~/.signature      Signature automatique');
  WriteLn('  /var/mail/user    Boîte de réception par défaut');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  ELM               # Mode interactif');
  WriteLn('  ELM --list        # Lister les messages');
  WriteLn('  ELM --stats       # Voir les statistiques');
  WriteLn('  ELM --config      # Voir la configuration');
  WriteLn;
  WriteLn('Note: Client de messagerie électronique en mode texte');
  WriteLn('compatible avec le standard ELM d''Unix/Linux.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('ELM 1.00 - Electronic Mail Reader, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Compatible avec ELM Unix/Linux');
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeElmConfig;
  ParseElmCommandLine;
  {$ELSE}
  ShowSimulatedElm;
  {$ENDIF}
 End;
END.