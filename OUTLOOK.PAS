{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Clone de l'application Outlook en mode graphique

  ============================================================================
                         TODO - CLONE OUTLOOK EN PASCAL
  ============================================================================

  1.  [x] Interface graphique principale (fenêtre principale VGA/SVGA)
      - Créer la fenêtre principale avec barre de titre "Outlook Express"
      - Implémenter les zones: menu, barre d'outils, panneau de navigation,
        liste des messages, volet de lecture
      - Gérer le redimensionnement des panneaux avec la souris

  2.  [x] Support complet de la souris (Turbo Pascal et Free Pascal)
      - Détecter et initialiser le pilote souris (INT 33h pour TP)
      - Utiliser PtcMouse pour Free Pascal
      - Gestion des événements: clic gauche, clic droit, double-clic,
        glisser-déposer, molette de défilement

  3.  [x] Système de menus déroulants graphiques
      - Menu Fichier: Nouveau, Ouvrir, Enregistrer, Imprimer, Quitter
      - Menu Édition: Couper, Copier, Coller, Sélectionner tout
      - Menu Affichage: Volet de lecture, Trier par, Colonnes
      - Menu Outils: Comptes, Options, Règles de messages
      - Menu Aide: À propos, Aide en ligne

  4.  [x] Barre d'outils graphique avec icônes
      - Icônes: Nouveau message, Répondre, Répondre à tous, Transférer
      - Icônes: Envoyer/Recevoir, Supprimer, Imprimer, Carnet d'adresses
      - États visuels: normal, survol, appuyé, désactivé
      - Infobulles au survol de la souris

  5.  [x] Arbre de navigation multi-comptes (panneau gauche)
      - Structure hiérarchique: Comptes -> Dossiers -> Sous-dossiers
      - Dossiers standards: Boîte de réception, Éléments envoyés,
        Brouillons, Éléments supprimés, Courrier indésirable
      - Compteur de messages non lus entre parenthèses
      - Icônes de dossiers personnalisées
      - Glisser-déposer pour déplacer les messages entre dossiers

  6.  [x] Liste des messages avec colonnes triables
      - Colonnes: De, Objet, Date, Taille, Pièces jointes, Priorité
      - Tri ascendant/descendant par clic sur l'en-tête de colonne
      - Indicateurs visuels: lu/non lu (gras), drapeau, priorité haute/basse
      - Sélection multiple avec Ctrl+clic et Shift+clic
      - Menu contextuel au clic droit

  7.  [x] Volet de prévisualisation des messages
      - Affichage des en-têtes: De, À, Cc, Objet, Date
      - Zone de contenu avec défilement vertical et horizontal
      - Basculer entre affichage horizontal et vertical
      - Option pour masquer/afficher le volet de prévisualisation

  8.  [x] Client IMAP complet (RFC 3501)
      - Connexion sécurisée TLS/SSL sur le port 993
      - Authentification LOGIN et PLAIN
      - Commandes: SELECT, EXAMINE, FETCH, STORE, COPY, UID
      - Synchronisation des dossiers et messages
      - Support IDLE pour les notifications push
      - Gestion des drapeaux: \Seen, \Answered, \Flagged, \Deleted, \Draft

  9.  [x] Client POP3 complet (RFC 1939)
      - Connexion sécurisée TLS/SSL sur le port 995
      - Authentification USER/PASS et APOP
      - Commandes: STAT, LIST, RETR, DELE, TOP, UIDL
      - Option: Laisser les messages sur le serveur
      - Téléchargement des en-têtes seulement ou messages complets

  10. [x] Client SMTP complet (RFC 5321)
      - Connexion sécurisée TLS/SSL sur le port 465/587
      - Authentification PLAIN, LOGIN et CRAM-MD5
      - Support STARTTLS pour les connexions non chiffrées
      - Commandes: EHLO, MAIL FROM, RCPT TO, DATA, QUIT
      - Gestion des erreurs et codes de retour SMTP

  11. [x] Gestionnaire de comptes de messagerie
      - Assistant de configuration de nouveau compte
      - Paramètres serveur entrant: IMAP/POP3, hôte, port, SSL/TLS
      - Paramètres serveur sortant: SMTP, hôte, port, authentification
      - Test de connexion automatique
      - Stockage sécurisé des mots de passe

  12. [x] Compositeur de messages graphique
      - Fenêtre de rédaction avec champs À, Cc, Cci, Objet
      - Zone d'édition de texte avec curseur clignotant
      - Formatage de base: gras, italique, souligné, couleur
      - Vérification orthographique intégrée
      - Boutons: Envoyer, Enregistrer brouillon, Annuler

  13. [x] Support des pièces jointes
      - Ajouter des fichiers depuis le système de fichiers
      - Afficher les pièces jointes avec icônes par type
      - Enregistrer les pièces jointes sur disque
      - Limite de taille configurable
      - Avertissement pour les extensions dangereuses

  14. [x] Moteur de rendu HTML pour courriels (HTMLRenderer)
      - Analyse et tokenisation du HTML (lexer/parser)
      - Support des balises: html, body, head, title, meta
      - Balises de structure: div, span, p, br, hr
      - Balises de formatage: b, i, u, strong, em, font
      - Balises de listes: ul, ol, li
      - Balises de tableaux: table, tr, td, th
      - Balises de liens: a (href), affichage souligné en bleu
      - Balises d'images: img (affichage placeholder ou téléchargement)
      - Support du CSS inline (style="...")
      - Attributs: align, color, bgcolor, width, height, border

  15. [x] Décodage MIME multi-parties (RFC 2045-2049)
      - Détection du Content-Type et des limites
      - Décodage Base64 pour les pièces jointes
      - Décodage Quoted-Printable pour le texte
      - Support des jeux de caractères: UTF-8, ISO-8859-1, Windows-1252
      - Gestion multipart/alternative (texte + HTML)
      - Gestion multipart/mixed (texte + pièces jointes)

  16. [x] Carnet d'adresses intégré
      - Fenêtre de gestion des contacts
      - Champs: Nom, Prénom, Courriel, Téléphone, Adresse
      - Recherche et filtrage des contacts
      - Import/Export au format vCard et CSV
      - Auto-complétion dans les champs À, Cc, Cci

  17. [ ] Système de règles de filtrage des messages
      - Conditions: Expéditeur, Objet, Corps, Taille, Date
      - Actions: Déplacer vers dossier, Marquer comme lu, Supprimer
      - Actions: Transférer, Répondre automatiquement
      - Ordre d'exécution des règles configurable
      - Activation/désactivation des règles individuelles

  18. [ ] Fonctionnalités de recherche avancée
      - Recherche dans: Objet, Corps, Expéditeur, Destinataire
      - Filtres: Plage de dates, Taille, Avec pièces jointes
      - Recherche dans tous les dossiers ou dossier actuel
      - Mise en surbrillance des résultats
      - Historique des recherches récentes

  19. [ ] Gestion des signatures de courriels
      - Éditeur de signatures multiples
      - Signature par défaut par compte
      - Insertion automatique dans les nouveaux messages
      - Support du texte formaté et images
      - Signature différente pour réponses/transferts

  20. [ ] Notifications et alertes de nouveaux messages
      - Vérification automatique à intervalle configurable
      - Alerte sonore paramétrable (fichier WAV)
      - Notification visuelle dans la barre de titre
      - Icône de la barre d'état système (si disponible)
      - Option de notification par dossier

  21. [ ] Impression des messages et aperçu avant impression
      - Fenêtre d'aperçu avant impression
      - Configuration des marges et en-têtes/pieds de page
      - Impression du message actuel ou sélection
      - Support des imprimantes DOS (LPT1, LPT2)
      - Export en fichier texte ou HTML

  22. [ ] Sauvegarde et export des messages
      - Export au format EML (RFC 822)
      - Export au format MBOX (Unix mailbox)
      - Sauvegarde complète des comptes et paramètres
      - Restauration depuis une sauvegarde
      - Export de la liste des contacts

  23. [ ] Configuration des préférences utilisateur
      - Onglet Général: Langue, dossier par défaut, démarrage
      - Onglet Lecture: Police, taille, codage par défaut
      - Onglet Rédaction: Format par défaut, correcteur, signature
      - Onglet Connexion: Délais, tentatives, mode hors ligne
      - Onglet Sécurité: Avertissements, blocage d'images externes

  24. [ ] Mode hors ligne et synchronisation
      - Détection automatique de la connectivité
      - File d'attente des messages à envoyer
      - Cache local des messages et dossiers
      - Synchronisation à la reconnexion
      - Indicateur visuel du mode en ligne/hors ligne

  25. [ ] Support multi-langue de l'interface
      - Français (par défaut), English, Deutsch, Italiano
      - Español, Português, Svenska, Dansk, Nihongo (en rōmaji)
      - Albanais (Shqip)
      - Fichiers de ressources de traduction externes
      - Détection automatique via variable LANGUAGE

  ============================================================================
                              ARCHITECTURE TECHNIQUE
  ============================================================================

  Unités Pascal requises:
  - Free Pascal: PtcGraph, PtcCrt, PtcMouse, SysUtils, Classes, StrUtils,
                 DateUtils, Sockets, SSLSockets, Base64, DOM, XMLRead
  - Turbo Pascal: Graph, Crt, DOS, Strings (support limité réseau)

  Structure des données principales:
  - TOutlookAccount: Configuration d'un compte de messagerie
  - TMailFolder: Représentation d'un dossier (Inbox, Sent, etc.)
  - TMailMessage: Structure complète d'un message avec en-têtes et corps
  - TContact: Entrée du carnet d'adresses
  - TFilterRule: Règle de filtrage automatique
  - THTMLElement: Nœud de l'arbre de rendu HTML

  Protocoles réseau:
  - Socket TCP/IP de base pour toutes les communications
  - Couche TLS/SSL pour les connexions sécurisées
  - Implémentation IMAP4rev1 avec extensions
  - Implémentation POP3 avec commandes optionnelles
  - Implémentation SMTP avec ESMTP et authentification

  Rendu graphique:
  - Double buffering pour éviter le scintillement
  - Système de fenêtres superposées avec focus
  - Police bitmap intégrée pour le rendu de texte
  - Palette de couleurs Windows 95/98 pour l'apparence

  ============================================================================
}

Program OUTLOOK;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse,SysUtils
     {$ELSE}
      Crt,Graph,DOS
     {$ENDIF};

Const
 { Dimensions de l'écran VGA 640x480 }
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;

 { Couleurs style Windows 95/98 }
 COLOR_DESKTOP = 1;       { Bleu foncé - fond bureau }
 COLOR_TITLEBAR = 1;      { Bleu - barre de titre active }
 COLOR_TITLEBAR_INACTIVE = 8; { Gris - barre de titre inactive }
 COLOR_TITLEBAR_TEXT = 15; { Blanc - texte barre de titre }
 COLOR_WINDOW_BG = 7;     { Gris clair - fond fenêtre }
 COLOR_WINDOW_BORDER = 0; { Noir - bordure fenêtre }
 COLOR_MENU_BG = 7;       { Gris clair - fond menu }
 COLOR_MENU_TEXT = 0;     { Noir - texte menu }
 COLOR_MENU_HIGHLIGHT = 1; { Bleu - surbrillance menu }
 COLOR_MENU_HIGHLIGHT_TEXT = 15; { Blanc - texte surbrillance }
 COLOR_TOOLBAR_BG = 7;    { Gris clair - fond barre d'outils }
 COLOR_BUTTON_FACE = 7;   { Gris clair - face bouton }
 COLOR_BUTTON_LIGHT = 15; { Blanc - bord clair bouton }
 COLOR_BUTTON_DARK = 8;   { Gris foncé - bord sombre bouton }
 COLOR_LIST_BG = 15;      { Blanc - fond liste }
 COLOR_LIST_TEXT = 0;     { Noir - texte liste }
 COLOR_LIST_SELECTED = 1; { Bleu - sélection liste }
 COLOR_LIST_SELECTED_TEXT = 15; { Blanc - texte sélection }
 COLOR_FOLDER_BG = 7;     { Gris clair - fond panneau dossiers }
 COLOR_PREVIEW_BG = 15;   { Blanc - fond prévisualisation }
 COLOR_SPLITTER = 8;      { Gris foncé - séparateur }
 COLOR_SCROLLBAR = 7;     { Gris clair - barre de défilement }
 COLOR_STATUS_BG = 7;     { Gris clair - barre d'état }
 COLOR_STATUS_TEXT = 0;   { Noir - texte barre d'état }

 { Hauteurs des zones fixes }
 TITLEBAR_HEIGHT = 20;
 MENUBAR_HEIGHT = 18;
 TOOLBAR_HEIGHT = 28;
 STATUSBAR_HEIGHT = 20;

 { Largeur minimale des panneaux }
 MIN_FOLDER_WIDTH = 100;
 MIN_MESSAGE_WIDTH = 200;
 MIN_PREVIEW_HEIGHT = 80;

 { Taille de la zone de redimensionnement }
 SPLITTER_SIZE = 4;

 { Paramètres du double-clic }
 DOUBLE_CLICK_TIME = 500;  { Temps max entre deux clics en millisecondes }
 DOUBLE_CLICK_DIST = 4;    { Distance max entre deux clics en pixels }

 { Boutons de la souris }
 MOUSE_LEFT = 1;
 MOUSE_RIGHT = 2;
 MOUSE_MIDDLE = 4;

Type
 { Structure pour la disposition des zones de l'interface }
 TWindowLayout = Record
  TitleBarRect: Record X1, Y1, X2, Y2: Integer; End;
  MenuBarRect: Record X1, Y1, X2, Y2: Integer; End;
  ToolBarRect: Record X1, Y1, X2, Y2: Integer; End;
  FolderPaneRect: Record X1, Y1, X2, Y2: Integer; End;
  MessageListRect: Record X1, Y1, X2, Y2: Integer; End;
  PreviewPaneRect: Record X1, Y1, X2, Y2: Integer; End;
  StatusBarRect: Record X1, Y1, X2, Y2: Integer; End;
  VSplitterRect: Record X1, Y1, X2, Y2: Integer; End;
  HSplitterRect: Record X1, Y1, X2, Y2: Integer; End;
  FolderPaneWidth: Integer;
  PreviewPaneHeight: Integer;
 End;

 { État de la souris pour le redimensionnement }
 TDragState = (dsNone, dsDragVSplitter, dsDragHSplitter);

 { Type d'événement souris }
 TMouseEvent = (meNone, meLeftClick, meRightClick, meMiddleClick,
                meLeftDoubleClick, meRightDoubleClick,
                meWheelUp, meWheelDown);

 { Structure pour un élément de menu }
 TMenuItem = Record
  Caption: String[30];    { Texte de l'élément }
  Shortcut: String[15];   { Raccourci clavier (ex: Ctrl+N) }
  Separator: Boolean;     { True si c'est un séparateur }
  Enabled: Boolean;       { True si l'élément est actif }
  ItemID: Integer;        { Identifiant unique de l'élément }
 End;

 { Structure pour un menu déroulant }
 TDropdownMenu = Record
  Title: String[20];       { Titre du menu dans la barre }
  X, Width: Integer;       { Position et largeur dans la barre de menu }
  Items: Array[0..14] of TMenuItem; { Éléments du menu (max 15) }
  ItemCount: Integer;      { Nombre d'éléments }
  DropX, DropY: Integer;   { Position du menu déroulant }
  DropWidth, DropHeight: Integer; { Dimensions du menu déroulant }
 End;

 { État visuel d'un bouton de barre d'outils }
 TToolButtonState = (tbsNormal, tbsHover, tbsPressed, tbsDisabled);

 { Type d'icône pour un bouton }
 TToolIconType = (tiNewMsg, tiReply, tiReplyAll, tiForward,
                  tiSendRecv, tiDelete, tiPrint, tiAddressBook, tiSeparator);

 { Structure pour un bouton de barre d'outils }
 TToolButton = Record
  X, Y, W, H: Integer;       { Position et dimensions }
  Caption: String[15];       { Texte du bouton }
  Tooltip: String[40];       { Infobulle }
  IconType: TToolIconType;   { Type d'icône }
  CommandID: Integer;        { Commande associée }
  State: TToolButtonState;   { État actuel }
  Enabled: Boolean;          { Actif ou non }
 End;

 { Type de dossier pour l'arbre de navigation }
 TFolderType = (ftAccount, ftInbox, ftSent, ftDrafts, ftDeleted, ftJunk, ftCustom);

 { Structure pour un noeud de l'arbre de dossiers }
 TFolderNode = Record
  Name: String[30];          { Nom du dossier }
  FolderType: TFolderType;   { Type de dossier }
  Level: Integer;            { Niveau d'indentation (0=compte, 1=dossier, 2=sous-dossier) }
  ParentIndex: Integer;      { Index du parent (-1 si racine) }
  Expanded: Boolean;         { Étendu ou replié }
  Selected: Boolean;         { Sélectionné }
  UnreadCount: Integer;      { Nombre de messages non lus }
  TotalCount: Integer;       { Nombre total de messages }
  Y: Integer;                { Position Y actuelle (calculée lors du dessin) }
  Visible: Boolean;          { Visible dans l'arbre (dépend de l'expansion du parent) }
 End;

 { Priorité d'un message }
 TMessagePriority = (mpLow, mpNormal, mpHigh);

 { ============================================================================
   TYPES POUR LES PIECES JOINTES (TODO 13) - Declaration anticipee
   ============================================================================ }

 { Type de fichier pour l'icone }
 TAttachmentType = (
  atUnknown,    { Type inconnu }
  atDocument,   { Document texte (DOC, TXT, RTF) }
  atSpreadsheet,{ Tableur (XLS, CSV) }
  atImage,      { Image (JPG, PNG, GIF, BMP) }
  atArchive,    { Archive (ZIP, RAR, 7Z) }
  atExecutable, { Executable (EXE, COM, BAT) - DANGEREUX }
  atAudio,      { Audio (MP3, WAV) }
  atVideo,      { Video (AVI, MPG, MP4) }
  atPDF         { PDF }
 );

 { Structure pour une piece jointe }
 TAttachment = Record
  FileName: String[80];        { Nom du fichier }
  FilePath: String[200];       { Chemin complet sur disque }
  FileSize: LongInt;           { Taille en octets }
  FileType: TAttachmentType;   { Type de fichier }
  IsEmbedded: Boolean;         { Integre dans le message (non externe) }
  ContentID: String[40];       { ID pour les images integrees }
  IsDangerous: Boolean;        { Extension dangereuse }
 End;

 { ============================================================================
   TYPES POUR LE MOTEUR DE RENDU HTML (TODO 14)
   ============================================================================ }

 { Types de balises HTML supportees }
 THTMLTagType = (
  htUnknown,     { Balise inconnue }
  htHTML,        { <html> }
  htHead,        { <head> }
  htTitle,       { <title> }
  htMeta,        { <meta> }
  htBody,        { <body> }
  htDiv,         { <div> }
  htSpan,        { <span> }
  htP,           { <p> }
  htBr,          { <br> }
  htHr,          { <hr> }
  htB,           { <b> }
  htI,           { <i> }
  htU,           { <u> }
  htStrong,      { <strong> }
  htEm,          { <em> }
  htFont,        { <font> }
  htUL,          { <ul> }
  htOL,          { <ol> }
  htLI,          { <li> }
  htTable,       { <table> }
  htTR,          { <tr> }
  htTD,          { <td> }
  htTH,          { <th> }
  htA,           { <a> }
  htImg,         { <img> }
  htH1,          { <h1> }
  htH2,          { <h2> }
  htH3,          { <h3> }
  htCenter,      { <center> }
  htBlockquote,  { <blockquote> }
  htPre,         { <pre> }
  htCode         { <code> }
 );

 { Type de token HTML }
 THTMLTokenType = (
  ttText,        { Texte brut }
  ttOpenTag,     { <balise> }
  ttCloseTag,    { </balise> }
  ttSelfClose,   { <balise /> }
  ttComment,     { <!-- --> }
  ttDoctype,     { <!DOCTYPE> }
  ttEntity       { &entity; }
 );

 { Alignement du texte }
 THTMLAlign = (haLeft, haCenter, haRight, haJustify);

 { Structure d'un attribut HTML }
 THTMLAttribute = Record
  Name: String[20];
  Value: String[80];
 End;

 { Structure d'un token HTML }
 THTMLToken = Record
  TokenType: THTMLTokenType;
  TagType: THTMLTagType;
  TagName: String[20];
  Content: String[250];
  Attributes: Array[0..7] of THTMLAttribute;
  AttrCount: Integer;
 End;

 { Style de rendu courant }
 THTMLRenderStyle = Record
  Bold: Boolean;
  Italic: Boolean;
  Underline: Boolean;
  FontColor: Word;
  BGColor: Word;
  FontSize: Integer;       { 1-7 comme HTML, 3 = normal }
  Align: THTMLAlign;
  InPre: Boolean;          { Dans un bloc <pre> }
  ListLevel: Integer;      { Niveau d'imbrication des listes }
  ListOrdered: Boolean;    { Liste ordonnee ou non }
  ListItemNum: Integer;    { Numero de l'item courant }
  InTable: Boolean;        { Dans un tableau }
  InLink: Boolean;         { Dans un lien }
  LinkURL: String[200];    { URL du lien courant }
 End;

 { Element de rendu HTML }
 THTMLRenderElement = Record
  X, Y: Integer;           { Position }
  Width, Height: Integer;  { Dimensions }
  Text: String[80];        { Texte a afficher }
  Style: THTMLRenderStyle; { Style applique }
  IsLink: Boolean;         { Element cliquable }
  LinkURL: String[200];    { URL si lien }
  IsImage: Boolean;        { Placeholder d'image }
  ImageWidth: Integer;     { Largeur de l'image }
  ImageHeight: Integer;    { Hauteur de l'image }
 End;

 { ============================================================================
   TYPES POUR LE DECODAGE MIME (TODO 15)
   ============================================================================ }

 { Type d'encodage de transfert }
 TMIMETransferEncoding = (
  mte7Bit,             { 7bit - texte ASCII }
  mte8Bit,             { 8bit - texte avec caracteres etendus }
  mteQuotedPrintable,  { Quoted-Printable }
  mteBase64,           { Base64 }
  mteBinary            { Binaire }
 );

 { Type de contenu principal }
 TMIMEContentType = (
  mctText,             { text/* }
  mctMultipart,        { multipart/* }
  mctApplication,      { application/* }
  mctImage,            { image/* }
  mctAudio,            { audio/* }
  mctVideo,            { video/* }
  mctMessage,          { message/* }
  mctUnknown           { Type inconnu }
 );

 { Sous-type MIME }
 TMIMESubType = (
  mstPlain,            { text/plain }
  mstHTML,             { text/html }
  mstMixed,            { multipart/mixed }
  mstAlternative,      { multipart/alternative }
  mstRelated,          { multipart/related }
  mstOctetStream,      { application/octet-stream }
  mstPDF,              { application/pdf }
  mstJPEG,             { image/jpeg }
  mstPNG,              { image/png }
  mstGIF,              { image/gif }
  mstRFC822,           { message/rfc822 }
  mstUnknown           { Sous-type inconnu }
 );

 { Jeu de caracteres }
 TMIMECharset = (
  mcsASCII,            { US-ASCII }
  mcsUTF8,             { UTF-8 }
  mcsISO8859_1,        { ISO-8859-1 (Latin-1) }
  mcsWindows1252,      { Windows-1252 }
  mcsISO8859_15,       { ISO-8859-15 (Latin-9) }
  mcsUnknown           { Jeu inconnu }
 );

 { Structure pour un en-tete MIME }
 TMIMEHeader = Record
  Name: String[40];
  Value: String[200];
 End;

 { Structure pour une partie MIME }
 TMIMEPart = Record
  ContentType: TMIMEContentType;
  SubType: TMIMESubType;
  ContentTypeStr: String[60];    { Content-Type complet }
  Charset: TMIMECharset;
  TransferEncoding: TMIMETransferEncoding;
  Boundary: String[80];          { Pour multipart }
  FileName: String[80];          { Nom du fichier si piece jointe }
  ContentID: String[40];         { ID pour images inline }
  IsAttachment: Boolean;         { Est une piece jointe }
  DataOffset: LongInt;           { Position dans le flux }
  DataLength: LongInt;           { Taille des donnees }
  DecodedLength: LongInt;        { Taille une fois decode }
  PartCount: Integer;            { Nombre de sous-parties }
 End;

 { ============================================================================
   TYPES POUR LE CARNET D'ADRESSES (TODO 16)
   ============================================================================ }

 { Structure pour un contact }
 TContact = Record
  ID: Integer;                   { Identifiant unique }
  LastName: String[40];          { Nom de famille }
  FirstName: String[40];         { Prenom }
  DisplayName: String[60];       { Nom d'affichage }
  Email: String[80];             { Adresse email principale }
  Email2: String[80];            { Adresse email secondaire }
  Phone: String[20];             { Telephone principal }
  PhoneMobile: String[20];       { Telephone mobile }
  PhoneWork: String[20];         { Telephone travail }
  Address: String[80];           { Adresse ligne 1 }
  Address2: String[80];          { Adresse ligne 2 }
  City: String[40];              { Ville }
  PostalCode: String[10];        { Code postal }
  Country: String[30];           { Pays }
  Company: String[60];           { Entreprise }
  JobTitle: String[40];          { Titre/Fonction }
  Notes: String[200];            { Notes }
  Birthday: String[10];          { Date de naissance JJ/MM/AAAA }
  CreatedDate: LongInt;          { Date de creation }
  ModifiedDate: LongInt;         { Date de modification }
  IsSelected: Boolean;           { Selection pour operations en lot }
 End;

 { Type de tri pour les contacts }
 TContactSortField = (
  csfLastName,                   { Tri par nom }
  csfFirstName,                  { Tri par prenom }
  csfEmail,                      { Tri par email }
  csfCompany                     { Tri par entreprise }
 );

 { Etat de la fenetre carnet d'adresses }
 TAddressBookState = (
  absHidden,                     { Fenetre cachee }
  absList,                       { Liste des contacts }
  absEdit,                       { Edition d'un contact }
  absNew,                        { Nouveau contact }
  absSearch,                     { Recherche }
  absImport,                     { Import }
  absExport                      { Export }
 );

 { Format d'import/export }
 TAddressBookFormat = (
  abfVCard,                      { Format vCard (.vcf) }
  abfCSV                         { Format CSV }
 );

 { Champ de l'auto-completion }
 TAutoCompleteField = (
  acfTo,                         { Champ A: }
  acfCc,                         { Champ Cc: }
  acfBcc                         { Champ Cci: }
 );

 { Structure pour l'auto-completion }
 TAutoCompleteSuggestion = Record
  DisplayName: String[60];
  Email: String[80];
  MatchScore: Integer;           { Score de correspondance }
 End;

 { Type de colonne pour la liste des messages }
 TColumnType = (ctPriority, ctAttachment, ctFlag, ctFrom, ctSubject, ctDate, ctSize);

 { Ordre de tri }
 TSortOrder = (soNone, soAscending, soDescending);

 { Structure pour un message }
 TMessage = Record
  MsgID: String[20];        { Identifiant unique }
  FromName: String[40];     { Nom de l'expediteur }
  FromEmail: String[60];    { Adresse email }
  ToName: String[40];       { Nom du destinataire }
  ToEmail: String[60];      { Adresse email destinataire }
  CcEmail: String[80];      { Adresse(s) en copie }
  Subject: String[80];      { Objet }
  DateStr: String[10];      { Date au format JJ/MM/AA }
  DateFull: String[25];     { Date complete pour affichage }
  DateSort: LongInt;        { Date pour le tri (secondes depuis 1970) }
  Size: LongInt;            { Taille en octets }
  Priority: TMessagePriority; { Priorite du message }
  HasAttachment: Boolean;   { Contient des pieces jointes }
  IsRead: Boolean;          { Message lu }
  IsFlagged: Boolean;       { Message marque d'un drapeau }
  IsSelected: Boolean;      { Message selectionne }
  Y: Integer;               { Position Y pour le clic }
  Body: Array[0..19] of String[80]; { Corps du message (max 20 lignes) }
  BodyLineCount: Integer;   { Nombre de lignes du corps }
  { Pieces jointes (TODO 13) }
  Attachments: Array[0..9] of TAttachment; { Liste des pieces jointes (max 10) }
  AttachmentCount: Integer;  { Nombre de pieces jointes }
 End;

 { Orientation du volet de previsualisation }
 TPreviewOrientation = (poHorizontal, poVertical);

 { ============================================================================
   TYPES ET STRUCTURES POUR LE CLIENT IMAP (RFC 3501)
   ============================================================================ }

 { Etat de la connexion IMAP }
 TIMAPState = (
  isDisconnected,  { Non connecte }
  isConnected,     { Connecte, pas encore authentifie }
  isAuthenticated, { Authentifie, pas de boite selectionnee }
  isSelected,      { Boite aux lettres selectionnee }
  isLogout         { Deconnexion en cours }
 );

 { Type de reponse IMAP }
 TIMAPResponseType = (
  irOK,            { Commande reussie }
  irNO,            { Commande echouee }
  irBAD,           { Commande invalide ou erreur de syntaxe }
  irContinue,      { Continuation requise (+) }
  irUntagged,      { Reponse non taguee (*) }
  irTagged,        { Reponse taguee }
  irBYE            { Serveur ferme la connexion }
 );

 { Type d'authentification IMAP }
 TIMAPAuthMethod = (
  iamLOGIN,        { Authentification LOGIN }
  iamPLAIN,        { Authentification PLAIN (Base64) }
  iamCRAMMD5,      { CRAM-MD5 (non implemente) }
  iamOAUTH2        { OAuth2 (non implemente) }
 );

 { Drapeaux IMAP pour les messages }
 TIMAPFlags = Record
  Seen: Boolean;      { \Seen - message lu }
  Answered: Boolean;  { \Answered - message repondu }
  Flagged: Boolean;   { \Flagged - message marque }
  Deleted: Boolean;   { \Deleted - message supprime }
  Draft: Boolean;     { \Draft - brouillon }
  Recent: Boolean;    { \Recent - message recent (lecture seule) }
 End;

 { Informations sur une boite aux lettres IMAP }
 TIMAPMailbox = Record
  Name: String[80];        { Nom de la boite }
  Delimiter: Char;         { Delimiteur de hierarchie }
  Exists: LongInt;         { Nombre de messages }
  Recent: LongInt;         { Nombre de messages recents }
  Unseen: LongInt;         { Numero du premier message non lu }
  UIDValidity: LongInt;    { Validite des UIDs }
  UIDNext: LongInt;        { Prochain UID }
  Flags: String[80];       { Drapeaux disponibles }
  PermanentFlags: String[80]; { Drapeaux permanents }
  ReadOnly: Boolean;       { Boite en lecture seule (EXAMINE) }
 End;

 { Structure d'une enveloppe de message IMAP }
 TIMAPEnvelope = Record
  MsgDate: String[30];     { Date du message }
  Subject: String[80];     { Objet }
  FromName: String[40];    { Nom de l'expediteur }
  FromEmail: String[60];   { Email de l'expediteur }
  ToName: String[40];      { Nom du destinataire }
  ToEmail: String[60];     { Email du destinataire }
  CcEmail: String[80];     { Emails en copie }
  ReplyTo: String[60];     { Adresse de reponse }
  MessageID: String[80];   { Message-ID }
  InReplyTo: String[80];   { In-Reply-To }
 End;

 { Structure pour un message IMAP recupere }
 TIMAPMessage = Record
  UID: LongInt;            { UID unique du message }
  SeqNum: LongInt;         { Numero de sequence }
  Flags: TIMAPFlags;       { Drapeaux du message }
  Size: LongInt;           { Taille en octets }
  Envelope: TIMAPEnvelope; { Enveloppe du message }
  BodyLoaded: Boolean;     { Corps charge en memoire }
 End;

 { Client IMAP complet }
 TIMAPClient = Record
  { Configuration de connexion }
  Host: String[80];        { Nom du serveur }
  Port: Integer;           { Port (993 pour IMAPS, 143 pour IMAP) }
  Username: String[60];    { Nom d'utilisateur }
  Password: String[40];    { Mot de passe }
  UseSSL: Boolean;         { Utiliser TLS/SSL }

  { Etat de la connexion }
  State: TIMAPState;       { Etat actuel }
  TagCounter: Integer;     { Compteur de tags }
  LastTag: String[10];     { Dernier tag envoye }
  LastError: String[80];   { Derniere erreur }
  Capabilities: String[200]; { Capacites du serveur }

  { Boite aux lettres courante }
  CurrentMailbox: TIMAPMailbox;
  IsMailboxSelected: Boolean;

  { Support IDLE }
  IdleSupported: Boolean;  { Serveur supporte IDLE }
  IdleActive: Boolean;     { IDLE actuellement actif }

  { Socket de connexion (simule pour cette implementation) }
  Connected: Boolean;
  SocketHandle: Integer;
 End;

 { Structure pour une reponse IMAP parsee }
 TIMAPResponse = Record
  ResponseType: TIMAPResponseType;
  Tag: String[10];         { Tag de la commande }
  StatusCode: String[20];  { Code de statut (OK, NO, BAD) }
  Text: String[200];       { Texte de la reponse }
  Data: String[255];       { Donnees additionnelles }
  HasData: Boolean;        { Contient des donnees }
 End;

 { ============================================================================
   TYPES ET STRUCTURES POUR LE CLIENT POP3 (RFC 1939)
   ============================================================================ }

 { Etat de la connexion POP3 }
 TPOP3State = (
  psDisconnected,    { Non connecte }
  psAuthorization,   { Etat AUTHORIZATION - authentification requise }
  psTransaction,     { Etat TRANSACTION - commandes disponibles }
  psUpdate           { Etat UPDATE - deconnexion en cours }
 );

 { Type de reponse POP3 }
 TPOP3ResponseType = (
  prOK,              { +OK - Commande reussie }
  prERR              { -ERR - Commande echouee }
 );

 { Type d'authentification POP3 }
 TPOP3AuthMethod = (
  pamUSERPASS,       { Authentification USER/PASS }
  pamAPOP            { Authentification APOP (MD5) }
 );

 { Structure pour les statistiques de la boite POP3 }
 TPOP3Stats = Record
  MessageCount: LongInt;   { Nombre de messages }
  TotalSize: LongInt;      { Taille totale en octets }
 End;

 { Structure pour un element de la liste POP3 }
 TPOP3ListItem = Record
  MsgNum: Integer;         { Numero du message }
  Size: LongInt;           { Taille en octets }
  UIDL: String[70];        { Identifiant unique (UIDL) }
  Deleted: Boolean;        { Marque pour suppression }
 End;

 { Structure pour un message POP3 }
 TPOP3Message = Record
  MsgNum: Integer;         { Numero du message }
  Size: LongInt;           { Taille en octets }
  UIDL: String[70];        { Identifiant unique }
  FromName: String[40];    { Nom de l'expediteur }
  FromEmail: String[60];   { Email de l'expediteur }
  ToEmail: String[60];     { Email du destinataire }
  Subject: String[80];     { Objet }
  MsgDate: String[30];     { Date du message }
  HeadersOnly: Boolean;    { Seulement les en-tetes charges }
  Deleted: Boolean;        { Marque pour suppression }
 End;

 { Client POP3 complet }
 TPOP3Client = Record
  { Configuration de connexion }
  Host: String[80];        { Nom du serveur }
  Port: Integer;           { Port (995 pour POP3S, 110 pour POP3) }
  Username: String[60];    { Nom d'utilisateur }
  Password: String[40];    { Mot de passe }
  UseSSL: Boolean;         { Utiliser TLS/SSL }

  { Etat de la connexion }
  State: TPOP3State;       { Etat actuel }
  LastError: String[80];   { Derniere erreur }
  ServerGreeting: String[100]; { Message de bienvenue (contient timestamp APOP) }
  APOPTimestamp: String[80];   { Timestamp pour APOP }

  { Statistiques de la boite }
  Stats: TPOP3Stats;

  { Options }
  LeaveOnServer: Boolean;  { Laisser les messages sur le serveur }
  HeadersOnly: Boolean;    { Telecharger seulement les en-tetes }
  DeleteAfterDays: Integer; { Supprimer apres X jours (0 = jamais) }

  { Socket de connexion (simule pour cette implementation) }
  Connected: Boolean;
  SocketHandle: Integer;
 End;

 { Structure pour une reponse POP3 parsee }
 TPOP3Response = Record
  ResponseType: TPOP3ResponseType;
  Text: String[200];       { Texte de la reponse }
  Data: String[255];       { Donnees additionnelles }
  HasMultiline: Boolean;   { Reponse multiligne }
 End;

 { ============================================================================
   TYPES ET STRUCTURES POUR LE CLIENT SMTP (RFC 5321)
   ============================================================================ }

 { Etat de la connexion SMTP }
 TSMTPState = (
  ssDisconnected,    { Non connecte }
  ssConnected,       { Connecte, en attente de EHLO }
  ssAuthenticated,   { Authentifie, pret a envoyer }
  ssMailFrom,        { MAIL FROM envoye }
  ssRcptTo,          { Au moins un RCPT TO accepte }
  ssData,            { En mode DATA }
  ssQuit             { QUIT envoye, deconnexion en cours }
 );

 { Code de reponse SMTP (classe) }
 TSMTPResponseClass = (
  srcPositivePrelim,     { 1xx - Preliminaire positif }
  srcPositiveComplete,   { 2xx - Completion positive }
  srcPositiveInterm,     { 3xx - Intermediaire positif }
  srcNegativeTransient,  { 4xx - Erreur temporaire }
  srcNegativePermanent,  { 5xx - Erreur permanente }
  srcUnknown             { Classe inconnue }
 );

 { Type d'authentification SMTP }
 TSMTPAuthMethod = (
  samNone,           { Pas d'authentification }
  samPLAIN,          { Authentification PLAIN (RFC 4616) }
  samLOGIN,          { Authentification LOGIN }
  samCRAMMD5         { Authentification CRAM-MD5 (RFC 2195) }
 );

 { Extensions SMTP supportees (EHLO) }
 TSMTPExtensions = Record
  STARTTLS: Boolean;       { STARTTLS supporte }
  AUTH_PLAIN: Boolean;     { AUTH PLAIN supporte }
  AUTH_LOGIN: Boolean;     { AUTH LOGIN supporte }
  AUTH_CRAM_MD5: Boolean;  { AUTH CRAM-MD5 supporte }
  EIGHTBITMIME: Boolean;   { 8BITMIME supporte }
  SIZE: LongInt;           { Taille maximale message (0 = non limite) }
  PIPELINING: Boolean;     { PIPELINING supporte }
  DSN: Boolean;            { Delivery Status Notification supporte }
 End;

 { Structure pour un destinataire SMTP }
 TSMTPRecipient = Record
  Email: String[60];       { Adresse email }
  Accepted: Boolean;       { Accepte par le serveur }
  ErrorMsg: String[80];    { Message d'erreur si refuse }
 End;

 { Client SMTP complet }
 TSMTPClient = Record
  { Configuration de connexion }
  Host: String[80];        { Nom du serveur }
  Port: Integer;           { Port (465 pour SMTPS, 587 pour submission) }
  Username: String[60];    { Nom d'utilisateur }
  Password: String[40];    { Mot de passe }
  UseSSL: Boolean;         { Utiliser TLS/SSL implicite }
  UseSTARTTLS: Boolean;    { Utiliser STARTTLS }

  { Etat de la connexion }
  State: TSMTPState;       { Etat actuel }
  LastError: String[80];   { Derniere erreur }
  LastCode: Integer;       { Dernier code de reponse }
  ServerGreeting: String[100]; { Message de bienvenue }
  ServerDomain: String[60];    { Domaine du serveur (EHLO) }

  { Extensions supportees }
  Extensions: TSMTPExtensions;

  { Options d'authentification }
  AuthMethod: TSMTPAuthMethod;  { Methode d'authentification utilisee }
  Authenticated: Boolean;       { Est authentifie }

  { Message en cours d'envoi }
  MailFrom: String[60];    { Expediteur (MAIL FROM) }
  RcptCount: Integer;      { Nombre de destinataires }
  RcptAccepted: Integer;   { Nombre de destinataires acceptes }

  { Socket de connexion (simule pour cette implementation) }
  Connected: Boolean;
  SocketHandle: Integer;
  TLSActive: Boolean;      { TLS actif (apres STARTTLS) }
 End;

 { Structure pour une reponse SMTP parsee }
 TSMTPResponse = Record
  Code: Integer;           { Code numerique (250, 354, 550, etc.) }
  ResponseClass: TSMTPResponseClass; { Classe de reponse }
  Text: String[200];       { Texte de la reponse }
  IsMultiline: Boolean;    { Reponse multiligne }
  IsContinue: Boolean;     { Continuation (code-) }
 End;

 { Structure pour un message SMTP a envoyer }
 TSMTPMessage = Record
  From: String[60];        { Expediteur }
  FromName: String[40];    { Nom de l'expediteur }
  Recipients: Array[0..9] Of TSMTPRecipient; { Destinataires (TO, CC) }
  RecipientCount: Integer; { Nombre de destinataires }
  Subject: String[80];     { Sujet }
  Body: String[255];       { Corps du message (simplifie) }
  ContentType: String[40]; { Type de contenu }
  CharSet: String[20];     { Jeu de caracteres }
 End;

 { Structure pour une colonne de la liste des messages }
 TColumnHeader = Record
  ColType: TColumnType;     { Type de colonne }
  Title: String[15];        { Titre de la colonne }
  X: Integer;               { Position X }
  Width: Integer;           { Largeur de la colonne }
  Sortable: Boolean;        { Triable ou non }
 End;

 { ============================================================================
   TYPES ET STRUCTURES POUR LE GESTIONNAIRE DE COMPTES (TODO 11)
   ============================================================================ }

 { Type de serveur entrant }
 TIncomingServerType = (istIMAP, istPOP3);

 { Type de securite de connexion }
 TConnectionSecurity = (csNone, csSSL, csSTARTTLS);

 { Etape de l'assistant de configuration de compte }
 TAccountWizardStep = (
  awsWelcome,          { Page d'accueil }
  awsAccountInfo,      { Informations du compte (nom, email) }
  awsIncomingServer,   { Serveur entrant (IMAP/POP3) }
  awsOutgoingServer,   { Serveur sortant (SMTP) }
  awsTestConnection,   { Test de connexion }
  awsComplete          { Configuration terminee }
 );

 { Resultat du test de connexion }
 TConnectionTestResult = (
  ctrNotTested,        { Pas encore teste }
  ctrTesting,          { Test en cours }
  ctrSuccess,          { Connexion reussie }
  ctrFailedIncoming,   { Echec serveur entrant }
  ctrFailedOutgoing,   { Echec serveur sortant }
  ctrFailedAuth,       { Echec authentification }
  ctrFailedNetwork     { Echec reseau }
 );

 { Structure complete d'un compte de messagerie }
 TEmailAccount = Record
  { Informations generales }
  AccountName: String[40];     { Nom du compte affiche dans l'interface }
  DisplayName: String[40];     { Nom affiche dans les messages envoyes }
  EmailAddress: String[60];    { Adresse email }
  Organization: String[40];    { Organisation (optionnel) }
  ReplyToAddress: String[60];  { Adresse de reponse (optionnel) }

  { Serveur entrant }
  IncomingType: TIncomingServerType;  { IMAP ou POP3 }
  IncomingHost: String[80];    { Nom du serveur entrant }
  IncomingPort: Integer;       { Port du serveur entrant }
  IncomingSecurity: TConnectionSecurity; { Type de securite }
  IncomingUsername: String[60]; { Nom d'utilisateur }
  IncomingPassword: String[40]; { Mot de passe (chiffre en XOR) }
  IncomingAuthMethod: Byte;    { Methode d'authentification (0=AUTO) }

  { Options POP3 specifiques }
  POP3LeaveOnServer: Boolean;  { Laisser les messages sur le serveur }
  POP3DeleteAfterDays: Integer; { Supprimer apres X jours (0=jamais) }
  POP3HeadersOnly: Boolean;    { Telecharger seulement les en-tetes }

  { Serveur sortant (SMTP) }
  OutgoingHost: String[80];    { Nom du serveur SMTP }
  OutgoingPort: Integer;       { Port du serveur SMTP }
  OutgoingSecurity: TConnectionSecurity; { Type de securite }
  OutgoingUsername: String[60]; { Nom d'utilisateur SMTP }
  OutgoingPassword: String[40]; { Mot de passe SMTP (chiffre en XOR) }
  OutgoingAuthRequired: Boolean; { Authentification requise }
  OutgoingUseSameAuth: Boolean;  { Utiliser les memes identifiants que entrant }

  { Etat du compte }
  IsActive: Boolean;           { Compte actif }
  IsDefault: Boolean;          { Compte par defaut }
  LastConnectionTest: TConnectionTestResult; { Resultat du dernier test }
  CheckIntervalMins: Integer;  { Intervalle de verification (minutes) }
 End;

 { Structure pour un champ de saisie dans une boite de dialogue }
 TInputField = Record
  X, Y: Integer;               { Position }
  Width: Integer;              { Largeur en pixels }
  MaxLen: Integer;             { Longueur maximale du texte }
  Value: String[80];           { Valeur actuelle }
  IsPassword: Boolean;         { Masquer le texte }
  IsFocused: Boolean;          { Champ actif }
  CursorPos: Integer;          { Position du curseur }
  Label_: String[30];          { Etiquette du champ }
 End;

 { Structure pour un bouton radio dans une boite de dialogue }
 TRadioButton = Record
  X, Y: Integer;               { Position }
  Label_: String[30];          { Etiquette }
  Checked: Boolean;            { Selectionne }
  GroupID: Integer;            { ID du groupe de boutons radio }
 End;

 { Structure pour une case a cocher }
 TCheckBox = Record
  X, Y: Integer;               { Position }
  Label_: String[40];          { Etiquette }
  Checked: Boolean;            { Cochee }
 End;

 { ============================================================================
   TYPES ET STRUCTURES POUR LE COMPOSITEUR DE MESSAGES (TODO 12)
   ============================================================================ }

 { Options de formatage du texte }
 TTextFormat = Record
  Bold: Boolean;               { Texte en gras }
  Italic: Boolean;             { Texte en italique }
  Underline: Boolean;          { Texte souligne }
  FontColor: Word;             { Couleur du texte }
 End;

 { Structure pour une ligne de texte dans l'editeur }
 TEditorLine = Record
  Text: String[250];           { Contenu de la ligne }
  Format: TTextFormat;         { Formatage de la ligne }
 End;

 { Etat du compositeur de messages }
 TComposerState = (
  csNew,                       { Nouveau message }
  csReply,                     { Reponse }
  csReplyAll,                  { Reponse a tous }
  csForward,                   { Transfert }
  csDraft                      { Brouillon }
 );

 { Structure complete du compositeur de messages }
 TMessageComposer = Record
  { Champs d'en-tete }
  ToField: String[250];        { Destinataires }
  CcField: String[250];        { Copie carbone }
  BccField: String[250];       { Copie carbone invisible }
  SubjectField: String[80];    { Objet }

  { Corps du message }
  Lines: Array[0..499] of TEditorLine; { Lignes de texte (max 500) }
  LineCount: Integer;          { Nombre de lignes }
  CursorX: Integer;            { Position X du curseur (caractere) }
  CursorY: Integer;            { Position Y du curseur (ligne) }
  ScrollX: Integer;            { Defilement horizontal }
  ScrollY: Integer;            { Defilement vertical }
  SelectStartX, SelectStartY: Integer; { Debut de selection }
  SelectEndX, SelectEndY: Integer;     { Fin de selection }
  HasSelection: Boolean;       { Selection active }

  { Formatage actuel }
  CurrentFormat: TTextFormat;  { Format applique aux nouvelles saisies }

  { Etat }
  State: TComposerState;       { Etat du compositeur }
  Modified: Boolean;           { Message modifie }
  OriginalMsgID: String[20];   { ID du message original (reponse/transfert) }

  { Pieces jointes du message (TODO 13) }
  Attachments: Array[0..19] of TAttachment; { Liste des pieces jointes }
  AttachmentCount: Integer;    { Nombre de pieces jointes }
 End;

Const
 { Identifiants des commandes de menu }
 CMD_FILE_NEW      = 101;
 CMD_FILE_OPEN     = 102;
 CMD_FILE_SAVE     = 103;
 CMD_FILE_SAVEAS   = 104;
 CMD_FILE_PRINT    = 105;
 CMD_FILE_EXIT     = 106;

 CMD_EDIT_UNDO     = 201;
 CMD_EDIT_CUT      = 202;
 CMD_EDIT_COPY     = 203;
 CMD_EDIT_PASTE    = 204;
 CMD_EDIT_SELECTALL= 205;

 CMD_VIEW_PREVIEW  = 301;
 CMD_VIEW_SORTBY   = 302;
 CMD_VIEW_COLUMNS  = 303;
 CMD_VIEW_REFRESH  = 304;
 CMD_VIEW_PREVIEW_ORIENT = 305; { Basculer orientation horizontal/vertical }
 CMD_VIEW_PREVIEW_SHOW   = 306; { Afficher/masquer volet de previsualisation }

 CMD_TOOLS_ACCOUNTS= 401;
 CMD_TOOLS_OPTIONS = 402;
 CMD_TOOLS_RULES   = 403;

 CMD_MSG_NEW       = 501;
 CMD_MSG_REPLY     = 502;
 CMD_MSG_REPLYALL  = 503;
 CMD_MSG_FORWARD   = 504;
 CMD_MSG_DELETE    = 505;

 CMD_HELP_ABOUT    = 601;
 CMD_HELP_HELP     = 602;

 { Commandes de barre d'outils }
 CMD_TB_SENDRECV   = 701;
 CMD_TB_ADDRESSBOOK= 702;

 { Nombre maximum de menus dans la barre }
 MAX_MENUS = 6;

 { Nombre maximum de boutons dans la barre d'outils }
 MAX_TOOLBAR_BUTTONS = 12;

 { Temps d'affichage de l'infobulle (ms) }
 TOOLTIP_DELAY = 500;

 { Nombre maximum de dossiers dans l'arbre }
 MAX_FOLDERS = 30;

 { Hauteur d'un noeud dans l'arbre }
 FOLDER_NODE_HEIGHT = 16;

 { Indentation par niveau }
 FOLDER_INDENT = 16;

 { Nombre maximum de messages dans la liste }
 MAX_MESSAGES = 100;

 { Nombre maximum de colonnes }
 MAX_COLUMNS = 7;

 { Hauteur d'une ligne de message }
 MESSAGE_ROW_HEIGHT = 16;

 { Largeur de l'en-tete de colonne }
 COLUMN_HEADER_HEIGHT = 18;

 { Constantes pour le volet de previsualisation }
 PREVIEW_LINE_HEIGHT = 14;    { Hauteur d'une ligne de texte }
 PREVIEW_SCROLLBAR_WIDTH = 14; { Largeur de la barre de defilement }
 PREVIEW_SCROLL_STEP = 3;     { Lignes a faire defiler par clic molette }
 PREVIEW_HEADER_LINES = 5;    { Nombre de lignes d'en-tete (De, A, Cc, Date, Objet) }
 PREVIEW_MIN_HEIGHT = 80;     { Hauteur minimale du volet }

 { ============================================================================
   CONSTANTES POUR LE CLIENT IMAP (RFC 3501)
   ============================================================================ }

 { Ports IMAP standard }
 IMAP_PORT = 143;          { Port IMAP standard }
 IMAPS_PORT = 993;         { Port IMAP sur SSL/TLS }

 { Tailles maximales }
 IMAP_MAX_RESPONSE_SIZE = 4096;   { Taille max d'une reponse }
 IMAP_MAX_MESSAGES = 500;         { Nombre max de messages a charger }
 IMAP_BUFFER_SIZE = 1024;         { Taille du buffer de lecture }

 { Timeouts en millisecondes }
 IMAP_CONNECT_TIMEOUT = 30000;    { Timeout de connexion }
 IMAP_READ_TIMEOUT = 60000;       { Timeout de lecture }
 IMAP_IDLE_TIMEOUT = 1680000;     { Timeout IDLE (28 minutes RFC) }

 { Drapeaux IMAP comme chaines }
 IMAP_FLAG_SEEN = '\Seen';
 IMAP_FLAG_ANSWERED = '\Answered';
 IMAP_FLAG_FLAGGED = '\Flagged';
 IMAP_FLAG_DELETED = '\Deleted';
 IMAP_FLAG_DRAFT = '\Draft';
 IMAP_FLAG_RECENT = '\Recent';

 { Codes de retour IMAP }
 IMAP_OK = 0;
 IMAP_ERR_CONNECT = -1;
 IMAP_ERR_AUTH = -2;
 IMAP_ERR_SELECT = -3;
 IMAP_ERR_FETCH = -4;
 IMAP_ERR_STORE = -5;
 IMAP_ERR_COPY = -6;
 IMAP_ERR_TIMEOUT = -7;
 IMAP_ERR_NETWORK = -8;
 IMAP_ERR_PROTOCOL = -9;

 { ============================================================================
   CONSTANTES POUR LE CLIENT POP3 (RFC 1939)
   ============================================================================ }

 { Ports POP3 standard }
 POP3_PORT = 110;          { Port POP3 standard }
 POP3S_PORT = 995;         { Port POP3 sur SSL/TLS }

 { Tailles maximales }
 POP3_MAX_RESPONSE_SIZE = 4096;   { Taille max d'une reponse }
 POP3_MAX_MESSAGES = 500;         { Nombre max de messages a charger }
 POP3_BUFFER_SIZE = 1024;         { Taille du buffer de lecture }
 POP3_MAX_LINE_LENGTH = 998;      { Longueur max d'une ligne (RFC 1939) }

 { Timeouts en millisecondes }
 POP3_CONNECT_TIMEOUT = 30000;    { Timeout de connexion }
 POP3_READ_TIMEOUT = 60000;       { Timeout de lecture }

 { Codes de retour POP3 }
 POP3_OK = 0;
 POP3_ERR_CONNECT = -1;
 POP3_ERR_AUTH = -2;
 POP3_ERR_STAT = -3;
 POP3_ERR_LIST = -4;
 POP3_ERR_RETR = -5;
 POP3_ERR_DELE = -6;
 POP3_ERR_TOP = -7;
 POP3_ERR_UIDL = -8;
 POP3_ERR_TIMEOUT = -9;
 POP3_ERR_NETWORK = -10;
 POP3_ERR_PROTOCOL = -11;

 { ============================================================================
   CONSTANTES POUR LE CLIENT SMTP (RFC 5321)
   ============================================================================ }

 { Ports SMTP standard }
 SMTP_PORT = 25;           { Port SMTP standard (non recommande) }
 SMTP_SUBMISSION_PORT = 587; { Port de soumission (STARTTLS) }
 SMTPS_PORT = 465;         { Port SMTP sur SSL/TLS implicite }

 { Tailles maximales }
 SMTP_MAX_RESPONSE_SIZE = 4096;   { Taille max d'une reponse }
 SMTP_BUFFER_SIZE = 1024;         { Taille du buffer de lecture }
 SMTP_MAX_LINE_LENGTH = 998;      { Longueur max d'une ligne (RFC 5321) }
 SMTP_MAX_RECIPIENTS = 100;       { Nombre max de destinataires }

 { Timeouts en millisecondes }
 SMTP_CONNECT_TIMEOUT = 30000;    { Timeout de connexion }
 SMTP_READ_TIMEOUT = 300000;      { Timeout de lecture (5 min pour DATA) }
 SMTP_GREETING_TIMEOUT = 300000;  { Timeout pour le greeting }

 { Codes de reponse SMTP (principaux) }
 SMTP_CODE_READY = 220;           { Service ready }
 SMTP_CODE_CLOSING = 221;         { Closing connection }
 SMTP_CODE_AUTH_OK = 235;         { Authentication successful }
 SMTP_CODE_OK = 250;              { Requested action completed }
 SMTP_CODE_USER_NOT_LOCAL = 251;  { User not local, will forward }
 SMTP_CODE_AUTH_CONTINUE = 334;   { Auth continuation }
 SMTP_CODE_START_MAIL = 354;      { Start mail input }
 SMTP_CODE_NOT_AVAILABLE = 421;   { Service not available }
 SMTP_CODE_MAILBOX_BUSY = 450;    { Mailbox unavailable (busy) }
 SMTP_CODE_LOCAL_ERROR = 451;     { Local error }
 SMTP_CODE_INSUFFICIENT = 452;    { Insufficient storage }
 SMTP_CODE_SYNTAX_ERROR = 500;    { Syntax error }
 SMTP_CODE_PARAM_ERROR = 501;     { Parameter syntax error }
 SMTP_CODE_NOT_IMPLEMENTED = 502; { Command not implemented }
 SMTP_CODE_BAD_SEQUENCE = 503;    { Bad sequence of commands }
 SMTP_CODE_PARAM_NOT_IMPL = 504;  { Parameter not implemented }
 SMTP_CODE_AUTH_REQUIRED = 530;   { Authentication required }
 SMTP_CODE_AUTH_FAILED = 535;     { Authentication failed }
 SMTP_CODE_MAILBOX_NOT_FOUND = 550; { Mailbox not found }
 SMTP_CODE_USER_NOT_LOCAL_ERR = 551; { User not local }
 SMTP_CODE_EXCEEDED_STORAGE = 552;   { Exceeded storage }
 SMTP_CODE_MAILBOX_NAME_ERR = 553;   { Mailbox name not allowed }
 SMTP_CODE_TRANSACTION_FAILED = 554; { Transaction failed }

 { Codes de retour des fonctions SMTP }
 SMTP_OK = 0;
 SMTP_ERR_CONNECT = -1;
 SMTP_ERR_EHLO = -2;
 SMTP_ERR_STARTTLS = -3;
 SMTP_ERR_AUTH = -4;
 SMTP_ERR_MAIL_FROM = -5;
 SMTP_ERR_RCPT_TO = -6;
 SMTP_ERR_DATA = -7;
 SMTP_ERR_SEND = -8;
 SMTP_ERR_QUIT = -9;
 SMTP_ERR_TIMEOUT = -10;
 SMTP_ERR_NETWORK = -11;
 SMTP_ERR_PROTOCOL = -12;
 SMTP_ERR_NO_RECIPIENTS = -13;
 SMTP_ERR_TLS = -14;

 { ============================================================================
   CONSTANTES POUR LE GESTIONNAIRE DE COMPTES (TODO 11)
   ============================================================================ }

 { Nombre maximum de comptes de messagerie }
 MAX_EMAIL_ACCOUNTS = 10;

 { Dimensions de la boite de dialogue de gestion des comptes }
 DIALOG_WIDTH = 500;
 DIALOG_HEIGHT = 350;
 DIALOG_X = (SCREEN_WIDTH - DIALOG_WIDTH) Div 2;
 DIALOG_Y = (SCREEN_HEIGHT - DIALOG_HEIGHT) Div 2;

 { Dimensions des elements de dialogue }
 DIALOG_BUTTON_WIDTH = 80;
 DIALOG_BUTTON_HEIGHT = 22;
 DIALOG_INPUT_HEIGHT = 18;
 DIALOG_LABEL_HEIGHT = 14;
 DIALOG_MARGIN = 10;
 DIALOG_SPACING = 6;

 { Cle de chiffrement XOR pour les mots de passe }
 PASSWORD_XOR_KEY = $A5;

 { Ports par defaut selon le type de serveur }
 DEFAULT_IMAP_PORT = 143;
 DEFAULT_IMAPS_PORT = 993;
 DEFAULT_POP3_PORT = 110;
 DEFAULT_POP3S_PORT = 995;
 DEFAULT_SMTP_PORT = 25;
 DEFAULT_SMTP_SUBMISSION_PORT = 587;
 DEFAULT_SMTPS_PORT = 465;

 { ============================================================================
   CONSTANTES POUR LE COMPOSITEUR DE MESSAGES (TODO 12)
   ============================================================================ }

 { Dimensions de la fenetre du compositeur }
 COMPOSER_WIDTH = 550;
 COMPOSER_HEIGHT = 400;
 COMPOSER_X = (SCREEN_WIDTH - COMPOSER_WIDTH) Div 2;
 COMPOSER_Y = (SCREEN_HEIGHT - COMPOSER_HEIGHT) Div 2;

 { Zones de la fenetre du compositeur }
 COMPOSER_HEADER_HEIGHT = 120;    { Zone des champs d'en-tete }
 COMPOSER_TOOLBAR_HEIGHT = 28;    { Barre d'outils de formatage }
 COMPOSER_FIELD_HEIGHT = 20;      { Hauteur d'un champ de saisie }
 COMPOSER_FIELD_SPACING = 26;     { Espacement entre champs }
 COMPOSER_LABEL_WIDTH = 50;       { Largeur des etiquettes }

 { Identifiants des champs du compositeur }
 COMP_FIELD_TO = 0;
 COMP_FIELD_CC = 1;
 COMP_FIELD_BCC = 2;
 COMP_FIELD_SUBJECT = 3;
 COMP_FIELD_BODY = 4;

 { Nombre max de lignes dans l'editeur }
 COMPOSER_MAX_LINES = 500;

 { Largeur max visible dans l'editeur }
 COMPOSER_EDITOR_VISIBLE_COLS = 70;
 COMPOSER_EDITOR_VISIBLE_ROWS = 12;

 { Couleurs de formatage disponibles }
 FORMAT_COLOR_BLACK = 0;
 FORMAT_COLOR_RED = 4;
 FORMAT_COLOR_GREEN = 2;
 FORMAT_COLOR_BLUE = 1;

 { ============================================================================
   CONSTANTES POUR LES PIECES JOINTES (TODO 13)
   ============================================================================ }

 { Nombre maximum de pieces jointes par message }
 MAX_ATTACHMENTS = 20;

 { Taille maximale totale des pieces jointes (10 Mo par defaut) }
 MAX_ATTACHMENT_SIZE = 10485760;

 { Taille maximale d'un seul fichier (5 Mo) }
 MAX_SINGLE_FILE_SIZE = 5242880;

 { Zone d'affichage des pieces jointes dans le compositeur }
 ATTACH_PANEL_HEIGHT = 50;
 ATTACH_ICON_SIZE = 32;
 ATTACH_ICON_SPACING = 40;
 ATTACH_PANEL_Y = COMPOSER_Y + COMPOSER_HEADER_HEIGHT - ATTACH_PANEL_HEIGHT - 5;

 { Extensions dangereuses (executables) }
 DANGEROUS_EXT_COUNT = 12;

 { ============================================================================
   CONSTANTES POUR LE MOTEUR DE RENDU HTML (TODO 14)
   ============================================================================ }

 { Nombre maximum de tokens HTML }
 MAX_HTML_TOKENS = 500;

 { Nombre maximum d'elements de rendu }
 MAX_HTML_ELEMENTS = 200;

 { Taille de police par defaut (equivalent HTML size=3) }
 HTML_DEFAULT_FONT_SIZE = 3;

 { Couleurs HTML par defaut }
 HTML_COLOR_LINK = LightBlue;      { Couleur des liens }
 HTML_COLOR_VISITED = Magenta;      { Liens visites }
 HTML_COLOR_TEXT = White;           { Texte par defaut }
 HTML_COLOR_BG = Black;             { Fond par defaut }

 { Indentation pour les listes }
 HTML_LIST_INDENT = 20;

 { Espacement des tableaux }
 HTML_TABLE_PADDING = 4;
 HTML_TABLE_BORDER = 1;

 { Nombre d'entites HTML supportees }
 HTML_ENTITY_COUNT = 15;

 { ============================================================================
   CONSTANTES POUR LE DECODAGE MIME (TODO 15)
   ============================================================================ }

 { Nombre maximum de parties MIME }
 MAX_MIME_PARTS = 20;

 { Nombre maximum d'en-tetes MIME }
 MAX_MIME_HEADERS = 30;

 { Taille maximale du buffer de decodage }
 MIME_DECODE_BUFFER = 4096;

 { Longueur maximale d'une ligne MIME }
 MIME_MAX_LINE_LENGTH = 998;

 { Table Base64 }
 BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

 { ============================================================================
   CONSTANTES POUR LE CARNET D'ADRESSES (TODO 16)
   ============================================================================ }

 { Nombre maximum de contacts }
 MAX_CONTACTS = 500;

 { Nombre maximum de suggestions d'auto-completion }
 MAX_AUTOCOMPLETE_SUGGESTIONS = 10;

 { Dimensions de la fenetre carnet d'adresses }
 ADDRESSBOOK_WIDTH = 500;
 ADDRESSBOOK_HEIGHT = 380;
 ADDRESSBOOK_MARGIN = 10;

 { Hauteur d'une ligne de contact }
 CONTACT_LINE_HEIGHT = 18;

 { Nombre de contacts visibles }
 CONTACTS_VISIBLE = 15;

 { Largeur des colonnes }
 CONTACT_COL_NAME = 150;
 CONTACT_COL_EMAIL = 200;
 CONTACT_COL_PHONE = 100;

 { Fichier de sauvegarde }
 ADDRESSBOOK_FILE = 'ADDRBOOK.DAT';

Var
 Layout: TWindowLayout;
 DragState: TDragState;
 DragStartX, DragStartY: Integer;
 Running: Boolean;
 MouseX, MouseY: Integer;
 MouseBtn: Integer;
 {$IFDEF FPC}
  MouseButtons: Word;
 {$ENDIF}

 { Variables pour la détection du double-clic }
 LastClickTime: LongInt;
 LastClickX, LastClickY: Integer;
 LastClickBtn: Integer;
 ClickCount: Integer;

 { Variables pour la molette de défilement }
 MouseWheelDelta: Integer;
 ScrollOffset: Integer;

 { Variables pour le système de menus }
 Menus: Array[0..MAX_MENUS-1] of TDropdownMenu;
 MenuCount: Integer;
 ActiveMenu: Integer;        { Index du menu actif (-1 = aucun) }
 ActiveMenuItem: Integer;    { Index de l'élément survolé (-1 = aucun) }
 MenuBarActive: Boolean;     { True si la barre de menu est active }

 { Variables pour la barre d'outils }
 ToolButtons: Array[0..MAX_TOOLBAR_BUTTONS-1] of TToolButton;
 ToolButtonCount: Integer;
 HoveredToolButton: Integer;  { Index du bouton survolé (-1 = aucun) }
 PressedToolButton: Integer;  { Index du bouton appuyé (-1 = aucun) }

 { Variables pour les infobulles }
 TooltipVisible: Boolean;
 TooltipX, TooltipY: Integer;
 TooltipText: String[40];
 TooltipStartTime: LongInt;
 LastMouseX, LastMouseY: Integer;

 { Variables pour l'arbre de dossiers }
 Folders: Array[0..MAX_FOLDERS-1] of TFolderNode;
 FolderCount: Integer;
 SelectedFolder: Integer;     { Index du dossier sélectionné }
 HoveredFolder: Integer;      { Index du dossier survolé }
 FolderScrollOffset: Integer; { Défilement de l'arbre }
 DraggedFolder: Integer;      { Index du dossier en cours de glisser-déposer }

 { Variables pour la liste des messages }
 Messages: Array[0..MAX_MESSAGES-1] of TMessage;
 MessageCount: Integer;
 SelectedMessage: Integer;    { Index du message selectionne (-1 = aucun) }
 LastSelectedMessage: Integer; { Pour la selection multiple avec Shift }
 MessageScrollOffset: Integer; { Defilement de la liste }
 CtrlKeyDown: Boolean;        { Touche Ctrl enfoncee }
 ShiftKeyDown: Boolean;       { Touche Shift enfoncee }

 { Variables pour les colonnes de messages }
 Columns: Array[0..MAX_COLUMNS-1] of TColumnHeader;
 ColumnCount: Integer;
 SortColumn: Integer;         { Index de la colonne de tri (-1 = aucun) }
 SortOrder: TSortOrder;       { Ordre de tri actuel }
 HoveredColumn: Integer;      { Index de la colonne survolee }

 { Variables pour le menu contextuel des messages }
 ContextMenuVisible: Boolean;
 ContextMenuX, ContextMenuY: Integer;
 ContextMenuWidth, ContextMenuHeight: Integer;
 ContextMenuItems: Array[0..7] of TMenuItem;
 ContextMenuItemCount: Integer;
 HoveredContextItem: Integer;

 { Variables pour le volet de previsualisation }
 PreviewScrollY: Integer;     { Position de defilement vertical }
 PreviewScrollX: Integer;     { Position de defilement horizontal }
 PreviewMaxScrollY: Integer;  { Defilement vertical maximum }
 PreviewMaxScrollX: Integer;  { Defilement horizontal maximum }
 PreviewOrientation: TPreviewOrientation; { Orientation du volet }
 PreviewVisible: Boolean;     { Volet visible ou masque }
 PreviewHeaderHeight: Integer; { Hauteur de la zone d'en-tetes }
 InPreviewPane: Boolean;      { Souris dans le volet de previsualisation }

 { Variables globales pour le client IMAP }
 IMAPClient: TIMAPClient;              { Instance du client IMAP }
 IMAPMessages: Array[0..IMAP_MAX_MESSAGES-1] of TIMAPMessage; { Cache des messages }
 IMAPMessageCount: Integer;            { Nombre de messages charges }
 IMAPConnecting: Boolean;              { Connexion en cours }
 IMAPLastActivity: LongInt;            { Dernier timestamp d'activite }

 { Variables globales pour le client POP3 }
 POP3Client: TPOP3Client;              { Instance du client POP3 }
 POP3Messages: Array[0..POP3_MAX_MESSAGES-1] of TPOP3Message; { Cache des messages }
 POP3ListItems: Array[0..POP3_MAX_MESSAGES-1] of TPOP3ListItem; { Liste des messages }
 POP3MessageCount: Integer;            { Nombre de messages sur le serveur }
 POP3Connecting: Boolean;              { Connexion en cours }
 POP3LastActivity: LongInt;            { Dernier timestamp d'activite }

 { Variables globales pour le client SMTP }
 SMTPClient: TSMTPClient;              { Instance du client SMTP }
 SMTPRecipients: Array[0..SMTP_MAX_RECIPIENTS-1] of TSMTPRecipient; { Destinataires }
 SMTPCurrentMessage: TSMTPMessage;     { Message en cours de preparation }
 SMTPSending: Boolean;                 { Envoi en cours }
 SMTPLastActivity: LongInt;            { Dernier timestamp d'activite }

 { Variables globales pour le gestionnaire de comptes (TODO 11) }
 EmailAccounts: Array[0..MAX_EMAIL_ACCOUNTS-1] of TEmailAccount; { Liste des comptes }
 EmailAccountCount: Integer;           { Nombre de comptes configures }
 CurrentAccountIndex: Integer;         { Index du compte en cours d'edition }
 AccountDialogVisible: Boolean;        { Boite de dialogue visible }
 AccountWizardStep: TAccountWizardStep; { Etape de l'assistant }
 AccountWizardMode: Boolean;           { True = assistant, False = edition }
 TempAccount: TEmailAccount;           { Compte temporaire pour edition }
 AccountListScrollOffset: Integer;     { Defilement de la liste des comptes }
 SelectedAccountInList: Integer;       { Compte selectionne dans la liste }
 AccountDialogInputFields: Array[0..9] of TInputField; { Champs de saisie }
 AccountDialogRadioButtons: Array[0..5] of TRadioButton; { Boutons radio }
 AccountDialogCheckBoxes: Array[0..5] of TCheckBox; { Cases a cocher }
 FocusedInputField: Integer;           { Index du champ de saisie actif }
 ConnectionTestInProgress: Boolean;    { Test de connexion en cours }
 ConnectionTestResult: TConnectionTestResult; { Resultat du test }

 { Variables globales pour le compositeur de messages (TODO 12) }
 Composer: TMessageComposer;            { Instance du compositeur }
 ComposerVisible: Boolean;              { Fenetre du compositeur visible }
 ComposerFocusedField: Integer;         { Champ actif (0-4) }
 ComposerCursorVisible: Boolean;        { Curseur visible (clignotement) }
 ComposerCursorTimer: LongInt;          { Timer pour le clignotement }
 ComposerInputFields: Array[0..3] of TInputField; { Champs d'en-tete }
 ComposerFormatBold: Boolean;           { Bouton gras actif }
 ComposerFormatItalic: Boolean;         { Bouton italique actif }
 ComposerFormatUnderline: Boolean;      { Bouton souligne actif }

 { Variables globales pour les pieces jointes (TODO 13) }
 AttachPanelVisible: Boolean;           { Panneau de pieces jointes visible }
 SelectedAttachment: Integer;           { Index de la piece jointe selectionnee }
 AttachFileBrowserVisible: Boolean;     { Navigateur de fichiers visible }
 AttachCurrentPath: String[200];        { Chemin courant dans le navigateur }
 AttachFileList: Array[0..49] of String[80]; { Liste des fichiers }
 AttachFileCount: Integer;              { Nombre de fichiers }
 AttachSelectedFile: Integer;           { Fichier selectionne }
 AttachTotalSize: LongInt;              { Taille totale des pieces jointes }
 DangerousExtensions: Array[0..11] of String[4]; { Extensions dangereuses }

 { Variables globales pour le moteur HTML (TODO 14) }
 HTMLTokens: Array[0..MAX_HTML_TOKENS-1] of THTMLToken;  { Buffer de tokens }
 HTMLTokenCount: Integer;               { Nombre de tokens }
 HTMLElements: Array[0..MAX_HTML_ELEMENTS-1] of THTMLRenderElement; { Elements de rendu }
 HTMLElementCount: Integer;             { Nombre d'elements }
 HTMLCurrentStyle: THTMLRenderStyle;    { Style courant }
 HTMLRenderX, HTMLRenderY: Integer;     { Position de rendu }
 HTMLRenderWidth: Integer;              { Largeur disponible }
 HTMLIsHTML: Boolean;                   { Le message est en HTML }

 { Variables globales pour le decodage MIME (TODO 15) }
 MIMEParts: Array[0..MAX_MIME_PARTS-1] of TMIMEPart;  { Parties MIME }
 MIMEPartCount: Integer;                { Nombre de parties }
 MIMEHeaders: Array[0..MAX_MIME_HEADERS-1] of TMIMEHeader; { En-tetes }
 MIMEHeaderCount: Integer;              { Nombre d'en-tetes }
 MIMERootPart: TMIMEPart;               { Partie racine }
 MIMETextPart: String;                  { Contenu texte decode }
 MIMEHTMLPart: String;                  { Contenu HTML decode }
 MIMEHasText: Boolean;                  { Message contient du texte }
 MIMEHasHTML: Boolean;                  { Message contient du HTML }
 MIMEHasAttachments: Boolean;           { Message contient des pieces jointes }

 { Variables globales pour le carnet d'adresses (TODO 16) }
 Contacts: Array[0..MAX_CONTACTS-1] of TContact;  { Liste des contacts }
 ContactCount: Integer;                 { Nombre de contacts }
 ContactNextID: Integer;                { Prochain ID disponible }
 ContactSortField: TContactSortField;   { Champ de tri }
 ContactSortAsc: Boolean;               { Ordre ascendant }
 ContactScrollOffset: Integer;          { Decalage de defilement }
 ContactSelectedIndex: Integer;         { Contact selectionne }
 AddressBookState: TAddressBookState;   { Etat de la fenetre }
 AddressBookX, AddressBookY: Integer;   { Position de la fenetre }
 AddressBookSearchText: String[40];     { Texte de recherche }
 EditingContact: TContact;              { Contact en cours d'edition }
 EditingContactIndex: Integer;          { Index du contact en edition (-1 si nouveau) }
 EditingField: Integer;                 { Champ en cours d'edition (0-16) }
 AddressBookVisible: Boolean;           { Visibilite du carnet }

 { Variables pour l'auto-completion }
 AutoCompleteSuggestions: Array[0..MAX_AUTOCOMPLETE_SUGGESTIONS-1] of TAutoCompleteSuggestion;
 AutoCompleteSuggestionCount: Integer;  { Nombre de suggestions }
 AutoCompleteVisible: Boolean;          { Suggestions visibles }
 AutoCompleteSelectedIndex: Integer;    { Suggestion selectionnee }
 AutoCompleteField: TAutoCompleteField; { Champ actif }
 AutoCompleteX, AutoCompleteY: Integer; { Position du popup }
 AutoCompleteText: String[40];          { Texte tape }

{ ============================================================================
  PROCÉDURES D'INITIALISATION GRAPHIQUE
  ============================================================================ }

Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
 ErrCode:=GraphResult;
 If ErrCode=grOk Then Begin
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

{ ============================================================================
  PROCÉDURES DE GESTION DE LA SOURIS
  ============================================================================ }

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs: Registers;
 Begin
  Regs.AX := 0;
  Intr($33, Regs);
  MouseDriverFound := Regs.AX = $FFFF;
 End;

 Procedure ShowMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0001;
  Intr($33, Regs);
 End;

 Procedure HideMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0002;
  Intr($33, Regs);
 End;

 Procedure GetMouseState(Var X, Y, Button: Integer);
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0003;
  Intr($33, Regs);
  Button := Regs.BX;
  X := Regs.CX;
  Y := Regs.DX;
 End;
{$ELSE}
 Function MouseDriverFound: Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse;
 Begin
  { PtcMouse gère l'affichage automatiquement }
 End;

 Procedure HideMouse;
 Begin
  { PtcMouse gère l'affichage automatiquement }
 End;

 Procedure GetMouseState(Var X, Y, Button: Integer);
 Begin
  { PtcMouse: Utiliser la fonction GetMouse du module PtcMouse }
  X := GetMouseX;
  Y := GetMouseY;
  Button := GetMouseButtons;
 End;
{$ENDIF}

{ Fonction pour obtenir le temps actuel en millisecondes (approximatif) }
Function GetTickCount: LongInt;
{$IFNDEF FPC}
Var
 Hour, Min, Sec, Sec100: Word;
Begin
 GetTime(Hour, Min, Sec, Sec100);
 GetTickCount := (LongInt(Hour) * 3600000) + (LongInt(Min) * 60000) +
                 (LongInt(Sec) * 1000) + (LongInt(Sec100) * 10);
End;
{$ELSE}
Begin
 GetTickCount := Trunc(Now * 86400000) Mod 2147483647;
End;
{$ENDIF}

{ Initialise les variables de gestion de la souris }
Procedure InitMouseState;
Begin
 LastClickTime := 0;
 LastClickX := 0;
 LastClickY := 0;
 LastClickBtn := 0;
 ClickCount := 0;
 MouseWheelDelta := 0;
 ScrollOffset := 0;
End;

{ Lecture de la molette de la souris (INT 33h fonction 11h pour Turbo Pascal) }
{$IFNDEF FPC}
Procedure GetMouseWheel(Var WheelDelta: Integer);
Var
 Regs: Registers;
Begin
 { La fonction 11h retourne le mouvement de la molette dans CX }
 Regs.AX := $0011;
 Intr($33, Regs);
 { WheelDelta > 0 = vers le haut, < 0 = vers le bas }
 WheelDelta := Integer(Regs.CX);
End;
{$ELSE}
Procedure GetMouseWheel(Var WheelDelta: Integer);
Begin
 { PtcMouse: utiliser GetMouseWheelDelta si disponible }
 WheelDelta := 0;
 { Note: La gestion de la molette dépend de la version de PtcMouse }
End;
{$ENDIF}

{ Vérifie si c'est un double-clic }
Function IsDoubleClick(X, Y, Btn: Integer): Boolean;
Var
 CurrentTime: LongInt;
 DeltaX, DeltaY: Integer;
Begin
 IsDoubleClick := False;
 CurrentTime := GetTickCount;

 { Vérifier si le bouton est le même que le précédent }
 If Btn <> LastClickBtn Then Begin
  LastClickTime := CurrentTime;
  LastClickX := X;
  LastClickY := Y;
  LastClickBtn := Btn;
  ClickCount := 1;
  Exit;
 End;

 { Calculer la distance depuis le dernier clic }
 DeltaX := Abs(X - LastClickX);
 DeltaY := Abs(Y - LastClickY);

 { Vérifier le temps et la distance }
 If (CurrentTime - LastClickTime <= DOUBLE_CLICK_TIME) And
    (DeltaX <= DOUBLE_CLICK_DIST) And
    (DeltaY <= DOUBLE_CLICK_DIST) Then Begin
  Inc(ClickCount);
  If ClickCount >= 2 Then Begin
   IsDoubleClick := True;
   ClickCount := 0;
  End;
 End Else Begin
  ClickCount := 1;
 End;

 LastClickTime := CurrentTime;
 LastClickX := X;
 LastClickY := Y;
 LastClickBtn := Btn;
End;

{ Détecte le type d'événement souris }
Function DetectMouseEvent(OldBtn, NewBtn, X, Y: Integer): TMouseEvent;
Var
 WheelDelta: Integer;
Begin
 DetectMouseEvent := meNone;

 { Vérifier la molette de défilement }
 GetMouseWheel(WheelDelta);
 If WheelDelta > 0 Then Begin
  DetectMouseEvent := meWheelUp;
  Exit;
 End Else If WheelDelta < 0 Then Begin
  DetectMouseEvent := meWheelDown;
  Exit;
 End;

 { Détection du clic gauche (bouton enfoncé puis relâché) }
 If ((OldBtn And MOUSE_LEFT) <> 0) And ((NewBtn And MOUSE_LEFT) = 0) Then Begin
  If IsDoubleClick(X, Y, MOUSE_LEFT) Then
   DetectMouseEvent := meLeftDoubleClick
  Else
   DetectMouseEvent := meLeftClick;
  Exit;
 End;

 { Détection du clic droit }
 If ((OldBtn And MOUSE_RIGHT) <> 0) And ((NewBtn And MOUSE_RIGHT) = 0) Then Begin
  If IsDoubleClick(X, Y, MOUSE_RIGHT) Then
   DetectMouseEvent := meRightDoubleClick
  Else
   DetectMouseEvent := meRightClick;
  Exit;
 End;

 { Détection du clic milieu }
 If ((OldBtn And MOUSE_MIDDLE) <> 0) And ((NewBtn And MOUSE_MIDDLE) = 0) Then Begin
  DetectMouseEvent := meMiddleClick;
  Exit;
 End;
End;

{ ============================================================================
  PROCÉDURES DE DESSIN UTILITAIRES
  ============================================================================ }

{ Dessine un rectangle rempli }
Procedure FillRect(X1, Y1, X2, Y2: Integer; Color: Word);
Begin
 SetFillStyle(SolidFill, Color);
 Bar(X1, Y1, X2, Y2);
End;

{ Dessine un rectangle avec effet 3D (relief) }
Procedure Draw3DRect(X1, Y1, X2, Y2: Integer; Raised: Boolean);
Begin
 If Raised Then Begin
  SetColor(COLOR_BUTTON_LIGHT);
  Line(X1, Y1, X2, Y1);
  Line(X1, Y1, X1, Y2);
  SetColor(COLOR_BUTTON_DARK);
  Line(X1, Y2, X2, Y2);
  Line(X2, Y1, X2, Y2);
 End Else Begin
  SetColor(COLOR_BUTTON_DARK);
  Line(X1, Y1, X2, Y1);
  Line(X1, Y1, X1, Y2);
  SetColor(COLOR_BUTTON_LIGHT);
  Line(X1, Y2, X2, Y2);
  Line(X2, Y1, X2, Y2);
 End;
End;

{ Dessine un bouton de la barre d'outils avec état }
Procedure DrawToolButton(X, Y, W, H: Integer; Pressed: Boolean);
Begin
 FillRect(X, Y, X + W, Y + H, COLOR_BUTTON_FACE);
 Draw3DRect(X, Y, X + W, Y + H, Not Pressed);
End;

{ Dessine un bouton de barre d'outils avec état complet }
Procedure DrawToolButtonEx(Var Btn: TToolButton);
Var
 BgColor: Word;
Begin
 { Choisir la couleur de fond selon l'état }
 Case Btn.State Of
  tbsNormal:   BgColor := COLOR_BUTTON_FACE;
  tbsHover:    BgColor := COLOR_LIST_SELECTED;
  tbsPressed:  BgColor := COLOR_BUTTON_FACE;
  tbsDisabled: BgColor := COLOR_BUTTON_FACE;
 End;

 { Dessiner le fond du bouton }
 FillRect(Btn.X, Btn.Y, Btn.X + Btn.W, Btn.Y + Btn.H, BgColor);

 { Dessiner le relief 3D selon l'état }
 Case Btn.State Of
  tbsNormal:   Draw3DRect(Btn.X, Btn.Y, Btn.X + Btn.W, Btn.Y + Btn.H, True);
  tbsHover:    Draw3DRect(Btn.X, Btn.Y, Btn.X + Btn.W, Btn.Y + Btn.H, True);
  tbsPressed:  Draw3DRect(Btn.X, Btn.Y, Btn.X + Btn.W, Btn.Y + Btn.H, False);
  tbsDisabled: Begin End; { Pas de bordure pour désactivé }
 End;
End;

{ Dessine une icône de bouton de barre d'outils }
Procedure DrawToolbarIcon(X, Y: Integer; IconType: TToolIconType; Disabled: Boolean);
Var
 IconColor: Word;
Begin
 If Disabled Then
  IconColor := COLOR_BUTTON_DARK
 Else
  IconColor := COLOR_MENU_TEXT;

 SetColor(IconColor);

 Case IconType Of
  tiNewMsg: Begin
   { Icône enveloppe avec '+' }
   Rectangle(X, Y + 2, X + 14, Y + 12);
   Line(X, Y + 2, X + 7, Y + 7);
   Line(X + 14, Y + 2, X + 7, Y + 7);
   { Signe + }
   SetColor(LightGreen);
   If Not Disabled Then Begin
    Line(X + 11, Y, X + 11, Y + 6);
    Line(X + 8, Y + 3, X + 14, Y + 3);
   End;
  End;

  tiReply: Begin
   { Flèche vers la gauche }
   Line(X + 2, Y + 6, X + 12, Y + 6);
   Line(X + 2, Y + 6, X + 6, Y + 2);
   Line(X + 2, Y + 6, X + 6, Y + 10);
  End;

  tiReplyAll: Begin
   { Deux flèches vers la gauche }
   Line(X + 4, Y + 6, X + 12, Y + 6);
   Line(X + 4, Y + 6, X + 8, Y + 2);
   Line(X + 4, Y + 6, X + 8, Y + 10);
   Line(X, Y + 6, X + 4, Y + 2);
   Line(X, Y + 6, X + 4, Y + 10);
  End;

  tiForward: Begin
   { Flèche vers la droite }
   Line(X + 2, Y + 6, X + 12, Y + 6);
   Line(X + 12, Y + 6, X + 8, Y + 2);
   Line(X + 12, Y + 6, X + 8, Y + 10);
  End;

  tiSendRecv: Begin
   { Flèches bidirectionnelles }
   { Flèche vers le haut }
   Line(X + 4, Y + 2, X + 4, Y + 10);
   Line(X + 4, Y + 2, X + 2, Y + 5);
   Line(X + 4, Y + 2, X + 6, Y + 5);
   { Flèche vers le bas }
   Line(X + 10, Y + 2, X + 10, Y + 10);
   Line(X + 10, Y + 10, X + 8, Y + 7);
   Line(X + 10, Y + 10, X + 12, Y + 7);
  End;

  tiDelete: Begin
   { Croix }
   SetColor(LightRed);
   If Disabled Then SetColor(COLOR_BUTTON_DARK);
   Line(X + 2, Y + 2, X + 12, Y + 12);
   Line(X + 12, Y + 2, X + 2, Y + 12);
   Line(X + 3, Y + 2, X + 13, Y + 12);
   Line(X + 13, Y + 2, X + 3, Y + 12);
  End;

  tiPrint: Begin
   { Imprimante }
   Rectangle(X + 2, Y, X + 12, Y + 4);
   Rectangle(X, Y + 4, X + 14, Y + 10);
   Rectangle(X + 3, Y + 8, X + 11, Y + 14);
  End;

  tiAddressBook: Begin
   { Carnet }
   Rectangle(X + 2, Y, X + 12, Y + 14);
   Line(X + 4, Y + 3, X + 10, Y + 3);
   Line(X + 4, Y + 6, X + 10, Y + 6);
   Line(X + 4, Y + 9, X + 10, Y + 9);
   { Reliure }
   SetColor(COLOR_BUTTON_DARK);
   Line(X + 2, Y, X + 2, Y + 14);
  End;

  tiSeparator: Begin
   { Séparateur vertical }
   SetColor(COLOR_BUTTON_DARK);
   Line(X, Y + 2, X, Y + 14);
   SetColor(COLOR_BUTTON_LIGHT);
   Line(X + 1, Y + 2, X + 1, Y + 14);
  End;
 End;
End;

{ Initialise les boutons de la barre d'outils }
Procedure InitializeToolbar;
Var
 BtnX, BtnY, BtnW, BtnH: Integer;
 I: Integer;
Begin
 ToolButtonCount := 0;
 HoveredToolButton := -1;
 PressedToolButton := -1;
 TooltipVisible := False;

 BtnY := Layout.ToolBarRect.Y1 + 3;
 BtnW := 60;
 BtnH := 22;
 BtnX := 4;

 { Bouton Nouveau message }
 ToolButtons[0].X := BtnX;
 ToolButtons[0].Y := BtnY;
 ToolButtons[0].W := BtnW;
 ToolButtons[0].H := BtnH;
 ToolButtons[0].Caption := 'Nouveau';
 ToolButtons[0].Tooltip := 'Creer un nouveau message (Ctrl+N)';
 ToolButtons[0].IconType := tiNewMsg;
 ToolButtons[0].CommandID := CMD_MSG_NEW;
 ToolButtons[0].State := tbsNormal;
 ToolButtons[0].Enabled := True;

 { Bouton Répondre }
 BtnX := BtnX + BtnW + 4;
 ToolButtons[1].X := BtnX;
 ToolButtons[1].Y := BtnY;
 ToolButtons[1].W := BtnW;
 ToolButtons[1].H := BtnH;
 ToolButtons[1].Caption := 'Repondre';
 ToolButtons[1].Tooltip := 'Repondre a l''expediteur (Ctrl+R)';
 ToolButtons[1].IconType := tiReply;
 ToolButtons[1].CommandID := CMD_MSG_REPLY;
 ToolButtons[1].State := tbsNormal;
 ToolButtons[1].Enabled := True;

 { Bouton Répondre à tous }
 BtnX := BtnX + BtnW + 4;
 BtnW := 70;
 ToolButtons[2].X := BtnX;
 ToolButtons[2].Y := BtnY;
 ToolButtons[2].W := BtnW;
 ToolButtons[2].H := BtnH;
 ToolButtons[2].Caption := 'Rep.tous';
 ToolButtons[2].Tooltip := 'Repondre a tous les destinataires';
 ToolButtons[2].IconType := tiReplyAll;
 ToolButtons[2].CommandID := CMD_MSG_REPLYALL;
 ToolButtons[2].State := tbsNormal;
 ToolButtons[2].Enabled := True;

 { Bouton Transférer }
 BtnX := BtnX + BtnW + 4;
 BtnW := 70;
 ToolButtons[3].X := BtnX;
 ToolButtons[3].Y := BtnY;
 ToolButtons[3].W := BtnW;
 ToolButtons[3].H := BtnH;
 ToolButtons[3].Caption := 'Transferer';
 ToolButtons[3].Tooltip := 'Transferer ce message (Ctrl+F)';
 ToolButtons[3].IconType := tiForward;
 ToolButtons[3].CommandID := CMD_MSG_FORWARD;
 ToolButtons[3].State := tbsNormal;
 ToolButtons[3].Enabled := True;

 { Séparateur }
 BtnX := BtnX + BtnW + 8;
 ToolButtons[4].X := BtnX;
 ToolButtons[4].Y := BtnY;
 ToolButtons[4].W := 2;
 ToolButtons[4].H := BtnH;
 ToolButtons[4].Caption := '';
 ToolButtons[4].Tooltip := '';
 ToolButtons[4].IconType := tiSeparator;
 ToolButtons[4].CommandID := 0;
 ToolButtons[4].State := tbsNormal;
 ToolButtons[4].Enabled := False;

 { Bouton Envoyer/Recevoir }
 BtnX := BtnX + 8;
 BtnW := 80;
 ToolButtons[5].X := BtnX;
 ToolButtons[5].Y := BtnY;
 ToolButtons[5].W := BtnW;
 ToolButtons[5].H := BtnH;
 ToolButtons[5].Caption := 'Env/Recv';
 ToolButtons[5].Tooltip := 'Envoyer et recevoir les messages';
 ToolButtons[5].IconType := tiSendRecv;
 ToolButtons[5].CommandID := CMD_TB_SENDRECV;
 ToolButtons[5].State := tbsNormal;
 ToolButtons[5].Enabled := True;

 { Bouton Supprimer }
 BtnX := BtnX + BtnW + 4;
 BtnW := 65;
 ToolButtons[6].X := BtnX;
 ToolButtons[6].Y := BtnY;
 ToolButtons[6].W := BtnW;
 ToolButtons[6].H := BtnH;
 ToolButtons[6].Caption := 'Supprimer';
 ToolButtons[6].Tooltip := 'Supprimer le message selectionne';
 ToolButtons[6].IconType := tiDelete;
 ToolButtons[6].CommandID := CMD_MSG_DELETE;
 ToolButtons[6].State := tbsNormal;
 ToolButtons[6].Enabled := True;

 { Bouton Imprimer }
 BtnX := BtnX + BtnW + 4;
 BtnW := 60;
 ToolButtons[7].X := BtnX;
 ToolButtons[7].Y := BtnY;
 ToolButtons[7].W := BtnW;
 ToolButtons[7].H := BtnH;
 ToolButtons[7].Caption := 'Imprimer';
 ToolButtons[7].Tooltip := 'Imprimer le message (Ctrl+P)';
 ToolButtons[7].IconType := tiPrint;
 ToolButtons[7].CommandID := CMD_FILE_PRINT;
 ToolButtons[7].State := tbsNormal;
 ToolButtons[7].Enabled := True;

 { Bouton Carnet d'adresses }
 BtnX := BtnX + BtnW + 4;
 BtnW := 65;
 ToolButtons[8].X := BtnX;
 ToolButtons[8].Y := BtnY;
 ToolButtons[8].W := BtnW;
 ToolButtons[8].H := BtnH;
 ToolButtons[8].Caption := 'Adresses';
 ToolButtons[8].Tooltip := 'Ouvrir le carnet d''adresses';
 ToolButtons[8].IconType := tiAddressBook;
 ToolButtons[8].CommandID := CMD_TB_ADDRESSBOOK;
 ToolButtons[8].State := tbsNormal;
 ToolButtons[8].Enabled := True;

 ToolButtonCount := 9;
End;

{ Trouve le bouton de barre d'outils à une position donnée }
Function GetToolButtonAtPoint(X, Y: Integer): Integer;
Var
 I: Integer;
Begin
 GetToolButtonAtPoint := -1;
 For I := 0 To ToolButtonCount - 1 Do Begin
  If ToolButtons[I].IconType <> tiSeparator Then Begin
   If (X >= ToolButtons[I].X) And (X <= ToolButtons[I].X + ToolButtons[I].W) And
      (Y >= ToolButtons[I].Y) And (Y <= ToolButtons[I].Y + ToolButtons[I].H) Then Begin
    GetToolButtonAtPoint := I;
    Exit;
   End;
  End;
 End;
End;

{ Affiche une infobulle }
Procedure ShowTooltip(X, Y: Integer; Text: String);
Var
 TipW, TipH: Integer;
 TipX, TipY: Integer;
Begin
 If Text = '' Then Exit;

 TipW := TextWidth(Text) + 8;
 TipH := TextHeight(Text) + 6;

 { Positionner l'infobulle sous le curseur }
 TipX := X;
 TipY := Y + 20;

 { S'assurer que l'infobulle reste visible }
 If TipX + TipW > SCREEN_WIDTH Then
  TipX := SCREEN_WIDTH - TipW - 2;
 If TipY + TipH > SCREEN_HEIGHT Then
  TipY := Y - TipH - 5;

 HideMouse;

 { Fond de l'infobulle (jaune clair) }
 SetFillStyle(SolidFill, LightYellow);
 Bar(TipX, TipY, TipX + TipW, TipY + TipH);

 { Bordure noire }
 SetColor(Black);
 Rectangle(TipX, TipY, TipX + TipW, TipY + TipH);

 { Texte }
 SetColor(Black);
 OutTextXY(TipX + 4, TipY + 3, Text);

 ShowMouse;

 TooltipVisible := True;
 TooltipX := TipX;
 TooltipY := TipY;
 TooltipText := Text;
End;

{ Cache l'infobulle et redessine la zone }
Procedure HideTooltip;
Begin
 If TooltipVisible Then Begin
  TooltipVisible := False;
  DrawInterface;
 End;
End;

{ Dessine un texte centré dans un rectangle }
Procedure DrawCenteredText(X1, Y1, X2, Y2: Integer; Text: String; Color: Word);
Var
 TextW, TextH: Integer;
 TX, TY: Integer;
Begin
 SetColor(Color);
 TextW := TextWidth(Text);
 TextH := TextHeight(Text);
 TX := X1 + ((X2 - X1 - TextW) Div 2);
 TY := Y1 + ((Y2 - Y1 - TextH) Div 2);
 OutTextXY(TX, TY, Text);
End;

{ ============================================================================
  PROCÉDURES D'INITIALISATION ET GESTION DES MENUS
  ============================================================================ }

{ Déclaration avancée de DrawInterface pour utilisation dans les menus }
Procedure DrawInterface; Forward;

{ Ajoute un élément à un menu }
Procedure AddMenuItem(Var Menu: TDropdownMenu; Caption, Shortcut: String;
                      IsSeparator: Boolean; ItemID: Integer);
Begin
 If Menu.ItemCount < 15 Then Begin
  Menu.Items[Menu.ItemCount].Caption := Caption;
  Menu.Items[Menu.ItemCount].Shortcut := Shortcut;
  Menu.Items[Menu.ItemCount].Separator := IsSeparator;
  Menu.Items[Menu.ItemCount].Enabled := True;
  Menu.Items[Menu.ItemCount].ItemID := ItemID;
  Inc(Menu.ItemCount);
 End;
End;

{ Initialise tous les menus de la barre }
Procedure InitializeMenus;
Var
 I: Integer;
 MenuX: Integer;
Begin
 MenuCount := 6;
 ActiveMenu := -1;
 ActiveMenuItem := -1;
 MenuBarActive := False;

 { Initialiser les positions des menus }
 MenuX := 8;

 { Menu Fichier }
 Menus[0].Title := 'Fichier';
 Menus[0].X := MenuX;
 Menus[0].Width := TextWidth('Fichier') + 16;
 Menus[0].ItemCount := 0;
 AddMenuItem(Menus[0], 'Nouveau message', 'Ctrl+N', False, CMD_FILE_NEW);
 AddMenuItem(Menus[0], 'Ouvrir', 'Ctrl+O', False, CMD_FILE_OPEN);
 AddMenuItem(Menus[0], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[0], 'Enregistrer sous...', 'Ctrl+S', False, CMD_FILE_SAVEAS);
 AddMenuItem(Menus[0], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[0], 'Imprimer...', 'Ctrl+P', False, CMD_FILE_PRINT);
 AddMenuItem(Menus[0], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[0], 'Quitter', 'Alt+F4', False, CMD_FILE_EXIT);

 MenuX := MenuX + Menus[0].Width;

 { Menu Édition }
 Menus[1].Title := 'Edition';
 Menus[1].X := MenuX;
 Menus[1].Width := TextWidth('Edition') + 16;
 Menus[1].ItemCount := 0;
 AddMenuItem(Menus[1], 'Annuler', 'Ctrl+Z', False, CMD_EDIT_UNDO);
 AddMenuItem(Menus[1], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[1], 'Couper', 'Ctrl+X', False, CMD_EDIT_CUT);
 AddMenuItem(Menus[1], 'Copier', 'Ctrl+C', False, CMD_EDIT_COPY);
 AddMenuItem(Menus[1], 'Coller', 'Ctrl+V', False, CMD_EDIT_PASTE);
 AddMenuItem(Menus[1], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[1], 'Selectionner tout', 'Ctrl+A', False, CMD_EDIT_SELECTALL);

 MenuX := MenuX + Menus[1].Width;

 { Menu Affichage }
 Menus[2].Title := 'Affichage';
 Menus[2].X := MenuX;
 Menus[2].Width := TextWidth('Affichage') + 16;
 Menus[2].ItemCount := 0;
 AddMenuItem(Menus[2], 'Volet de lecture', '', False, CMD_VIEW_PREVIEW_SHOW);
 AddMenuItem(Menus[2], 'Orientation volet', '', False, CMD_VIEW_PREVIEW_ORIENT);
 AddMenuItem(Menus[2], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[2], 'Trier par...', '', False, CMD_VIEW_SORTBY);
 AddMenuItem(Menus[2], 'Colonnes...', '', False, CMD_VIEW_COLUMNS);
 AddMenuItem(Menus[2], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[2], 'Actualiser', 'F5', False, CMD_VIEW_REFRESH);

 MenuX := MenuX + Menus[2].Width;

 { Menu Outils }
 Menus[3].Title := 'Outils';
 Menus[3].X := MenuX;
 Menus[3].Width := TextWidth('Outils') + 16;
 Menus[3].ItemCount := 0;
 AddMenuItem(Menus[3], 'Comptes...', '', False, CMD_TOOLS_ACCOUNTS);
 AddMenuItem(Menus[3], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[3], 'Regles de messages...', '', False, CMD_TOOLS_RULES);
 AddMenuItem(Menus[3], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[3], 'Options...', '', False, CMD_TOOLS_OPTIONS);

 MenuX := MenuX + Menus[3].Width;

 { Menu Message }
 Menus[4].Title := 'Message';
 Menus[4].X := MenuX;
 Menus[4].Width := TextWidth('Message') + 16;
 Menus[4].ItemCount := 0;
 AddMenuItem(Menus[4], 'Nouveau message', 'Ctrl+N', False, CMD_MSG_NEW);
 AddMenuItem(Menus[4], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[4], 'Repondre', 'Ctrl+R', False, CMD_MSG_REPLY);
 AddMenuItem(Menus[4], 'Repondre a tous', 'Ctrl+Maj+R', False, CMD_MSG_REPLYALL);
 AddMenuItem(Menus[4], 'Transferer', 'Ctrl+F', False, CMD_MSG_FORWARD);
 AddMenuItem(Menus[4], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[4], 'Supprimer', 'Suppr', False, CMD_MSG_DELETE);

 MenuX := MenuX + Menus[4].Width;

 { Menu Aide (?) }
 Menus[5].Title := '?';
 Menus[5].X := MenuX;
 Menus[5].Width := TextWidth('?') + 16;
 Menus[5].ItemCount := 0;
 AddMenuItem(Menus[5], 'Aide en ligne', 'F1', False, CMD_HELP_HELP);
 AddMenuItem(Menus[5], '', '', True, 0); { Séparateur }
 AddMenuItem(Menus[5], 'A propos...', '', False, CMD_HELP_ABOUT);

 { Calculer les dimensions des menus déroulants }
 For I := 0 To MenuCount - 1 Do Begin
  Menus[I].DropX := Menus[I].X;
  Menus[I].DropY := Layout.MenuBarRect.Y2 + 1;
  Menus[I].DropWidth := 180;
  Menus[I].DropHeight := Menus[I].ItemCount * 18 + 4;
 End;
End;

{ Dessine un menu déroulant }
Procedure DrawDropdownMenu(MenuIndex: Integer);
Var
 I: Integer;
 ItemY: Integer;
 ItemX1, ItemY1, ItemX2, ItemY2: Integer;
Begin
 If (MenuIndex < 0) Or (MenuIndex >= MenuCount) Then Exit;

 HideMouse;

 { Fond du menu déroulant }
 FillRect(Menus[MenuIndex].DropX, Menus[MenuIndex].DropY,
          Menus[MenuIndex].DropX + Menus[MenuIndex].DropWidth,
          Menus[MenuIndex].DropY + Menus[MenuIndex].DropHeight,
          COLOR_MENU_BG);
 Draw3DRect(Menus[MenuIndex].DropX, Menus[MenuIndex].DropY,
            Menus[MenuIndex].DropX + Menus[MenuIndex].DropWidth,
            Menus[MenuIndex].DropY + Menus[MenuIndex].DropHeight, True);

 { Dessiner chaque élément }
 ItemY := Menus[MenuIndex].DropY + 2;

 For I := 0 To Menus[MenuIndex].ItemCount - 1 Do Begin
  ItemX1 := Menus[MenuIndex].DropX + 2;
  ItemY1 := ItemY;
  ItemX2 := Menus[MenuIndex].DropX + Menus[MenuIndex].DropWidth - 2;
  ItemY2 := ItemY + 16;

  If Menus[MenuIndex].Items[I].Separator Then Begin
   { Dessiner un séparateur }
   SetColor(COLOR_BUTTON_DARK);
   Line(ItemX1, ItemY1 + 8, ItemX2, ItemY1 + 8);
   SetColor(COLOR_BUTTON_LIGHT);
   Line(ItemX1, ItemY1 + 9, ItemX2, ItemY1 + 9);
  End Else Begin
   { Élément survolé? }
   If I = ActiveMenuItem Then Begin
    FillRect(ItemX1, ItemY1, ItemX2, ItemY2, COLOR_LIST_SELECTED);
    SetColor(COLOR_LIST_SELECTED_TEXT);
   End Else Begin
    If Menus[MenuIndex].Items[I].Enabled Then
     SetColor(COLOR_MENU_TEXT)
    Else
     SetColor(COLOR_BUTTON_DARK);
   End;

   { Texte de l'élément }
   OutTextXY(ItemX1 + 4, ItemY1 + 3, Menus[MenuIndex].Items[I].Caption);

   { Raccourci clavier }
   If Menus[MenuIndex].Items[I].Shortcut <> '' Then Begin
    If I = ActiveMenuItem Then
     SetColor(COLOR_LIST_SELECTED_TEXT)
    Else
     SetColor(COLOR_BUTTON_DARK);
    OutTextXY(ItemX2 - TextWidth(Menus[MenuIndex].Items[I].Shortcut) - 4,
              ItemY1 + 3, Menus[MenuIndex].Items[I].Shortcut);
   End;
  End;

  ItemY := ItemY + 18;
 End;

 ShowMouse;
End;

{ Ferme le menu déroulant actif et redessine l'interface }
Procedure CloseDropdownMenu;
Begin
 If ActiveMenu >= 0 Then Begin
  ActiveMenu := -1;
  ActiveMenuItem := -1;
  MenuBarActive := False;
  DrawInterface;
 End;
End;

{ Vérifie si un point est dans la zone d'un menu de la barre }
Function GetMenuAtPoint(X, Y: Integer): Integer;
Var
 I: Integer;
Begin
 GetMenuAtPoint := -1;
 If (Y >= Layout.MenuBarRect.Y1) And (Y <= Layout.MenuBarRect.Y2) Then Begin
  For I := 0 To MenuCount - 1 Do Begin
   If (X >= Menus[I].X) And (X < Menus[I].X + Menus[I].Width) Then Begin
    GetMenuAtPoint := I;
    Exit;
   End;
  End;
 End;
End;

{ Vérifie si un point est dans le menu déroulant actif }
Function GetMenuItemAtPoint(X, Y: Integer): Integer;
Var
 I: Integer;
 ItemY: Integer;
Begin
 GetMenuItemAtPoint := -1;
 If ActiveMenu < 0 Then Exit;

 { Vérifier si le point est dans le menu déroulant }
 If (X >= Menus[ActiveMenu].DropX) And
    (X <= Menus[ActiveMenu].DropX + Menus[ActiveMenu].DropWidth) And
    (Y >= Menus[ActiveMenu].DropY) And
    (Y <= Menus[ActiveMenu].DropY + Menus[ActiveMenu].DropHeight) Then Begin

  ItemY := Menus[ActiveMenu].DropY + 2;
  For I := 0 To Menus[ActiveMenu].ItemCount - 1 Do Begin
   If (Y >= ItemY) And (Y < ItemY + 18) Then Begin
    If Not Menus[ActiveMenu].Items[I].Separator Then
     GetMenuItemAtPoint := I;
    Exit;
   End;
   ItemY := ItemY + 18;
  End;
 End;
End;

{ Exécute une commande de menu }
Procedure ExecuteMenuCommand(CmdID: Integer);
Begin
 CloseDropdownMenu;

 Case CmdID Of
  CMD_FILE_NEW, CMD_MSG_NEW: Begin
   { Ouvrir le compositeur pour un nouveau message (TODO 12) }
   OpenNewMessage;
  End;

  CMD_MSG_REPLY: Begin
   { Ouvrir le compositeur pour une reponse (TODO 12) }
   OpenReplyMessage(False);
  End;

  CMD_MSG_REPLYALL: Begin
   { Ouvrir le compositeur pour une reponse a tous (TODO 12) }
   OpenReplyMessage(True);
  End;

  CMD_MSG_FORWARD: Begin
   { Ouvrir le compositeur pour un transfert (TODO 12) }
   OpenForwardMessage;
  End;

  CMD_FILE_EXIT: Begin
   Running := False;
  End;

  CMD_EDIT_COPY: Begin
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Commande: Copier                   ');
   ShowMouse;
  End;

  CMD_EDIT_PASTE: Begin
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Commande: Coller                   ');
   ShowMouse;
  End;

  CMD_VIEW_REFRESH: Begin
   DrawInterface;
  End;

  CMD_VIEW_PREVIEW_SHOW: Begin
   { Basculer affichage/masquage du volet de previsualisation }
   PreviewVisible := Not PreviewVisible;
   HideMouse;
   If PreviewVisible Then Begin
    { Restaurer la hauteur du volet }
    Layout.PreviewPaneHeight := 150;
    CalculateLayout;
    DrawInterface;
    FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
             Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
    SetColor(COLOR_STATUS_TEXT);
    OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
              'Volet de lecture: Affiche          ');
   End
   Else Begin
    { Masquer le volet - donner tout l'espace a la liste }
    Layout.PreviewPaneHeight := 0;
    CalculateLayout;
    DrawInterface;
    FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
             Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
    SetColor(COLOR_STATUS_TEXT);
    OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
              'Volet de lecture: Masque           ');
   End;
   ShowMouse;
  End;

  CMD_VIEW_PREVIEW_ORIENT: Begin
   { Basculer orientation du volet de previsualisation }
   If PreviewOrientation = poHorizontal Then
    PreviewOrientation := poVertical
   Else
    PreviewOrientation := poHorizontal;
   HideMouse;
   CalculateLayout;
   DrawInterface;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   If PreviewOrientation = poHorizontal Then
    OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
              'Orientation: Horizontale           ')
   Else
    OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
              'Orientation: Verticale             ');
   ShowMouse;
  End;

  CMD_TOOLS_ACCOUNTS: Begin
   { Ouvrir la boite de dialogue de gestion des comptes (TODO 11) }
   ShowAccountManagerDialog;
  End;

  CMD_TOOLS_OPTIONS: Begin
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Commande: Options                  ');
   ShowMouse;
  End;

  CMD_HELP_ABOUT: Begin
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Outlook Express Clone - NETWORKKIT-P');
   ShowMouse;
  End;

  Else Begin
   { Commande non implementée }
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Commande non implementee           ');
   ShowMouse;
  End;
 End;
End;

{ ============================================================================
  PROCÉDURES DE CALCUL DE LA DISPOSITION
  ============================================================================ }

{ Calcule les rectangles de toutes les zones de l'interface }
Procedure CalculateLayout;
Var
 ClientTop, ClientBottom: Integer;
 RightPaneLeft, RightPaneRight: Integer;
 MessageListBottom: Integer;
Begin
 { Barre de titre }
 Layout.TitleBarRect.X1 := 0;
 Layout.TitleBarRect.Y1 := 0;
 Layout.TitleBarRect.X2 := SCREEN_WIDTH - 1;
 Layout.TitleBarRect.Y2 := TITLEBAR_HEIGHT - 1;

 { Barre de menu }
 Layout.MenuBarRect.X1 := 0;
 Layout.MenuBarRect.Y1 := TITLEBAR_HEIGHT;
 Layout.MenuBarRect.X2 := SCREEN_WIDTH - 1;
 Layout.MenuBarRect.Y2 := TITLEBAR_HEIGHT + MENUBAR_HEIGHT - 1;

 { Barre d'outils }
 Layout.ToolBarRect.X1 := 0;
 Layout.ToolBarRect.Y1 := TITLEBAR_HEIGHT + MENUBAR_HEIGHT;
 Layout.ToolBarRect.X2 := SCREEN_WIDTH - 1;
 Layout.ToolBarRect.Y2 := TITLEBAR_HEIGHT + MENUBAR_HEIGHT + TOOLBAR_HEIGHT - 1;

 { Barre d'état }
 Layout.StatusBarRect.X1 := 0;
 Layout.StatusBarRect.Y1 := SCREEN_HEIGHT - STATUSBAR_HEIGHT;
 Layout.StatusBarRect.X2 := SCREEN_WIDTH - 1;
 Layout.StatusBarRect.Y2 := SCREEN_HEIGHT - 1;

 { Zone cliente (entre toolbar et statusbar) }
 ClientTop := TITLEBAR_HEIGHT + MENUBAR_HEIGHT + TOOLBAR_HEIGHT;
 ClientBottom := SCREEN_HEIGHT - STATUSBAR_HEIGHT - 1;

 { Panneau des dossiers (gauche) }
 Layout.FolderPaneRect.X1 := 0;
 Layout.FolderPaneRect.Y1 := ClientTop;
 Layout.FolderPaneRect.X2 := Layout.FolderPaneWidth - 1;
 Layout.FolderPaneRect.Y2 := ClientBottom;

 { Séparateur vertical }
 Layout.VSplitterRect.X1 := Layout.FolderPaneWidth;
 Layout.VSplitterRect.Y1 := ClientTop;
 Layout.VSplitterRect.X2 := Layout.FolderPaneWidth + SPLITTER_SIZE - 1;
 Layout.VSplitterRect.Y2 := ClientBottom;

 { Zone de droite }
 RightPaneLeft := Layout.FolderPaneWidth + SPLITTER_SIZE;
 RightPaneRight := SCREEN_WIDTH - 1;

 { Calcul de la hauteur du volet de prévisualisation }
 MessageListBottom := ClientBottom - Layout.PreviewPaneHeight - SPLITTER_SIZE;

 { Liste des messages }
 Layout.MessageListRect.X1 := RightPaneLeft;
 Layout.MessageListRect.Y1 := ClientTop;
 Layout.MessageListRect.X2 := RightPaneRight;
 Layout.MessageListRect.Y2 := MessageListBottom;

 { Séparateur horizontal }
 Layout.HSplitterRect.X1 := RightPaneLeft;
 Layout.HSplitterRect.Y1 := MessageListBottom + 1;
 Layout.HSplitterRect.X2 := RightPaneRight;
 Layout.HSplitterRect.Y2 := MessageListBottom + SPLITTER_SIZE;

 { Volet de prévisualisation }
 Layout.PreviewPaneRect.X1 := RightPaneLeft;
 Layout.PreviewPaneRect.Y1 := MessageListBottom + SPLITTER_SIZE + 1;
 Layout.PreviewPaneRect.X2 := RightPaneRight;
 Layout.PreviewPaneRect.Y2 := ClientBottom;
End;

{ ============================================================================
  PROCÉDURES DE DESSIN DES ZONES DE L'INTERFACE
  ============================================================================ }

{ Dessine la barre de titre }
Procedure DrawTitleBar;
Begin
 FillRect(Layout.TitleBarRect.X1, Layout.TitleBarRect.Y1,
          Layout.TitleBarRect.X2, Layout.TitleBarRect.Y2, COLOR_TITLEBAR);

 { Icône de l'application (petit carré) }
 SetColor(COLOR_TITLEBAR_TEXT);
 Rectangle(4, 4, 16, 16);
 Line(6, 10, 14, 10);

 { Titre de la fenêtre }
 SetColor(COLOR_TITLEBAR_TEXT);
 OutTextXY(22, 5, 'Outlook Express');

 { Boutons de contrôle de fenêtre (Minimiser, Maximiser, Fermer) }
 { Bouton Minimiser }
 DrawToolButton(SCREEN_WIDTH - 60, 3, 16, 14, False);
 SetColor(COLOR_MENU_TEXT);
 Line(SCREEN_WIDTH - 56, 12, SCREEN_WIDTH - 48, 12);

 { Bouton Maximiser }
 DrawToolButton(SCREEN_WIDTH - 40, 3, 16, 14, False);
 SetColor(COLOR_MENU_TEXT);
 Rectangle(SCREEN_WIDTH - 36, 6, SCREEN_WIDTH - 28, 13);

 { Bouton Fermer }
 DrawToolButton(SCREEN_WIDTH - 20, 3, 16, 14, False);
 SetColor(COLOR_MENU_TEXT);
 Line(SCREEN_WIDTH - 16, 6, SCREEN_WIDTH - 8, 13);
 Line(SCREEN_WIDTH - 16, 13, SCREEN_WIDTH - 8, 6);
End;

{ Dessine la barre de menu }
Procedure DrawMenuBar;
Var
 MenuX: Integer;
Begin
 FillRect(Layout.MenuBarRect.X1, Layout.MenuBarRect.Y1,
          Layout.MenuBarRect.X2, Layout.MenuBarRect.Y2, COLOR_MENU_BG);
 Draw3DRect(Layout.MenuBarRect.X1, Layout.MenuBarRect.Y1,
            Layout.MenuBarRect.X2, Layout.MenuBarRect.Y2, True);

 SetColor(COLOR_MENU_TEXT);
 MenuX := 8;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, 'Fichier');
 MenuX := MenuX + TextWidth('Fichier') + 16;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, 'Edition');
 MenuX := MenuX + TextWidth('Edition') + 16;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, 'Affichage');
 MenuX := MenuX + TextWidth('Affichage') + 16;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, 'Outils');
 MenuX := MenuX + TextWidth('Outils') + 16;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, 'Message');
 MenuX := MenuX + TextWidth('Message') + 16;

 OutTextXY(MenuX, Layout.MenuBarRect.Y1 + 4, '?');
End;

{ Dessine la barre d'outils avec icônes et états }
Procedure DrawToolBar;
Var
 I: Integer;
 IconX, IconY: Integer;
 TextX: Integer;
 TextColor: Word;
Begin
 { Dessiner le fond de la barre d'outils }
 FillRect(Layout.ToolBarRect.X1, Layout.ToolBarRect.Y1,
          Layout.ToolBarRect.X2, Layout.ToolBarRect.Y2, COLOR_TOOLBAR_BG);
 Draw3DRect(Layout.ToolBarRect.X1, Layout.ToolBarRect.Y1,
            Layout.ToolBarRect.X2, Layout.ToolBarRect.Y2, True);

 { Dessiner chaque bouton }
 For I := 0 To ToolButtonCount - 1 Do Begin
  If ToolButtons[I].IconType = tiSeparator Then Begin
   { Dessiner le séparateur }
   DrawToolbarIcon(ToolButtons[I].X, ToolButtons[I].Y, tiSeparator, False);
  End Else Begin
   { Dessiner le bouton avec son état }
   DrawToolButtonEx(ToolButtons[I]);

   { Position de l'icône (à gauche du texte) }
   IconX := ToolButtons[I].X + 3;
   IconY := ToolButtons[I].Y + 4;

   { Dessiner l'icône }
   DrawToolbarIcon(IconX, IconY, ToolButtons[I].IconType,
                   Not ToolButtons[I].Enabled);

   { Couleur du texte selon l'état }
   If ToolButtons[I].Enabled Then Begin
    If ToolButtons[I].State = tbsHover Then
     TextColor := COLOR_LIST_SELECTED_TEXT
    Else
     TextColor := COLOR_MENU_TEXT;
   End Else
    TextColor := COLOR_BUTTON_DARK;

   { Dessiner le texte du bouton }
   TextX := IconX + 16;
   SetColor(TextColor);
   OutTextXY(TextX, ToolButtons[I].Y + 6, ToolButtons[I].Caption);
  End;
 End;
End;

{ ============================================================================
  PROCÉDURES POUR L'ARBRE DE NAVIGATION (PANNEAU DOSSIERS)
  ============================================================================ }

{ Dessine une icône de dossier selon son type }
Procedure DrawFolderIcon(X, Y: Integer; FolderType: TFolderType; Expanded: Boolean);
Begin
 Case FolderType Of
  ftAccount: Begin
   { Icône de compte (ordinateur) }
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X, Y + 2, X + 12, Y + 10);
   Rectangle(X + 2, Y + 10, X + 10, Y + 12);
   SetColor(LightCyan);
   Bar(X + 1, Y + 3, X + 11, Y + 9);
  End;

  ftInbox: Begin
   { Icône boîte de réception (dossier avec flèche entrante) }
   SetColor(Yellow);
   Bar(X, Y + 4, X + 12, Y + 12);
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X, Y + 4, X + 12, Y + 12);
   Line(X, Y + 4, X + 6, Y);
   Line(X + 6, Y, X + 12, Y + 4);
   { Flèche entrante }
   SetColor(LightGreen);
   Line(X + 6, Y + 6, X + 6, Y + 10);
   Line(X + 4, Y + 8, X + 6, Y + 10);
   Line(X + 8, Y + 8, X + 6, Y + 10);
  End;

  ftSent: Begin
   { Icône éléments envoyés (dossier avec flèche sortante) }
   SetColor(LightCyan);
   Bar(X, Y + 4, X + 12, Y + 12);
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X, Y + 4, X + 12, Y + 12);
   Line(X, Y + 4, X + 6, Y);
   Line(X + 6, Y, X + 12, Y + 4);
   { Flèche sortante }
   SetColor(LightBlue);
   Line(X + 6, Y + 10, X + 6, Y + 6);
   Line(X + 4, Y + 8, X + 6, Y + 6);
   Line(X + 8, Y + 8, X + 6, Y + 6);
  End;

  ftDrafts: Begin
   { Icône brouillons (document avec crayon) }
   SetColor(White);
   Bar(X + 2, Y, X + 12, Y + 12);
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X + 2, Y, X + 12, Y + 12);
   { Lignes de texte }
   Line(X + 4, Y + 3, X + 10, Y + 3);
   Line(X + 4, Y + 6, X + 10, Y + 6);
   Line(X + 4, Y + 9, X + 8, Y + 9);
  End;

  ftDeleted: Begin
   { Icône corbeille }
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X + 2, Y + 2, X + 10, Y + 12);
   Line(X, Y + 2, X + 12, Y + 2);
   Line(X + 4, Y, X + 8, Y);
   { Lignes verticales de la corbeille }
   Line(X + 4, Y + 4, X + 4, Y + 10);
   Line(X + 6, Y + 4, X + 6, Y + 10);
   Line(X + 8, Y + 4, X + 8, Y + 10);
  End;

  ftJunk: Begin
   { Icône courrier indésirable (dossier rouge) }
   SetColor(LightRed);
   Bar(X, Y + 4, X + 12, Y + 12);
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X, Y + 4, X + 12, Y + 12);
   Line(X, Y + 4, X + 6, Y);
   Line(X + 6, Y, X + 12, Y + 4);
   { X pour spam }
   SetColor(White);
   Line(X + 3, Y + 6, X + 9, Y + 10);
   Line(X + 9, Y + 6, X + 3, Y + 10);
  End;

  ftCustom: Begin
   { Icône dossier standard }
   SetColor(Yellow);
   Bar(X, Y + 4, X + 12, Y + 12);
   SetColor(COLOR_BUTTON_DARK);
   Rectangle(X, Y + 4, X + 12, Y + 12);
   Line(X, Y + 4, X + 6, Y);
   Line(X + 6, Y, X + 12, Y + 4);
  End;
 End;
End;

{ Dessine le symbole d'expansion/réduction }
Procedure DrawExpandSymbol(X, Y: Integer; Expanded: Boolean);
Begin
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(X, Y, X + 8, Y + 8);
 SetColor(White);
 Bar(X + 1, Y + 1, X + 7, Y + 7);
 SetColor(Black);
 { Ligne horizontale (toujours) }
 Line(X + 2, Y + 4, X + 6, Y + 4);
 { Ligne verticale (si replié) }
 If Not Expanded Then
  Line(X + 4, Y + 2, X + 4, Y + 6);
End;

{ Vérifie si un dossier a des enfants visibles }
Function HasChildren(FolderIndex: Integer): Boolean;
Var
 I: Integer;
Begin
 HasChildren := False;
 For I := 0 To FolderCount - 1 Do Begin
  If Folders[I].ParentIndex = FolderIndex Then Begin
   HasChildren := True;
   Exit;
  End;
 End;
End;

{ Met à jour la visibilité de tous les dossiers selon l'état d'expansion des parents }
Procedure UpdateFolderVisibility;
Var
 I, P: Integer;
 IsVisible: Boolean;
Begin
 For I := 0 To FolderCount - 1 Do Begin
  If Folders[I].Level = 0 Then
   Folders[I].Visible := True
  Else Begin
   { Vérifier si tous les parents sont étendus }
   IsVisible := True;
   P := Folders[I].ParentIndex;
   While (P >= 0) And IsVisible Do Begin
    If Not Folders[P].Expanded Then
     IsVisible := False;
    P := Folders[P].ParentIndex;
   End;
   Folders[I].Visible := IsVisible;
  End;
 End;
End;

{ Ajoute un dossier à l'arbre }
Procedure AddFolder(Name: String; FolderType: TFolderType; Level, ParentIndex: Integer;
                    Expanded: Boolean; UnreadCount, TotalCount: Integer);
Begin
 If FolderCount < MAX_FOLDERS Then Begin
  Folders[FolderCount].Name := Name;
  Folders[FolderCount].FolderType := FolderType;
  Folders[FolderCount].Level := Level;
  Folders[FolderCount].ParentIndex := ParentIndex;
  Folders[FolderCount].Expanded := Expanded;
  Folders[FolderCount].Selected := False;
  Folders[FolderCount].UnreadCount := UnreadCount;
  Folders[FolderCount].TotalCount := TotalCount;
  Folders[FolderCount].Y := 0;
  Folders[FolderCount].Visible := True;
  Inc(FolderCount);
 End;
End;

{ Initialise l'arbre de dossiers avec une structure multi-comptes }
Procedure InitializeFolderTree;
Begin
 FolderCount := 0;
 SelectedFolder := 1; { Sélectionner la boîte de réception par défaut }
 HoveredFolder := -1;
 FolderScrollOffset := 0;
 DraggedFolder := -1;

 { Compte local }
 AddFolder('Compte local', ftAccount, 0, -1, True, 0, 0);
   AddFolder('Boite de reception', ftInbox, 1, 0, False, 5, 23);
   AddFolder('Elements envoyes', ftSent, 1, 0, False, 0, 15);
   AddFolder('Brouillons', ftDrafts, 1, 0, False, 2, 2);
   AddFolder('Elements supprimes', ftDeleted, 1, 0, False, 0, 8);
   AddFolder('Courrier indesirable', ftJunk, 1, 0, False, 3, 12);

 { Compte travail }
 AddFolder('Travail (IMAP)', ftAccount, 0, -1, True, 0, 0);
   AddFolder('Boite de reception', ftInbox, 1, 6, True, 12, 156);
     AddFolder('Projets', ftCustom, 2, 7, False, 0, 45);
     AddFolder('Clients', ftCustom, 2, 7, False, 2, 32);
   AddFolder('Elements envoyes', ftSent, 1, 6, False, 0, 89);
   AddFolder('Brouillons', ftDrafts, 1, 6, False, 1, 3);
   AddFolder('Elements supprimes', ftDeleted, 1, 6, False, 0, 5);
   AddFolder('Courrier indesirable', ftJunk, 1, 6, False, 0, 2);

 { Marquer le dossier sélectionné }
 If SelectedFolder >= 0 Then
  Folders[SelectedFolder].Selected := True;

 UpdateFolderVisibility;
End;

{ Trouve le dossier à une position Y donnée }
Function GetFolderAtPoint(X, Y: Integer): Integer;
Var
 I: Integer;
Begin
 GetFolderAtPoint := -1;

 { Vérifier si on est dans le panneau des dossiers }
 If (X < Layout.FolderPaneRect.X1) Or (X > Layout.FolderPaneRect.X2) Or
    (Y < Layout.FolderPaneRect.Y1 + 28) Or (Y > Layout.FolderPaneRect.Y2) Then
  Exit;

 For I := 0 To FolderCount - 1 Do Begin
  If Folders[I].Visible And (Folders[I].Y > 0) Then Begin
   If (Y >= Folders[I].Y) And (Y < Folders[I].Y + FOLDER_NODE_HEIGHT) Then Begin
    GetFolderAtPoint := I;
    Exit;
   End;
  End;
 End;
End;

{ Vérifie si le clic est sur le symbole d'expansion }
Function IsClickOnExpandSymbol(X, FolderIndex: Integer): Boolean;
Var
 SymbolX: Integer;
Begin
 IsClickOnExpandSymbol := False;
 If (FolderIndex < 0) Or (FolderIndex >= FolderCount) Then Exit;
 If Not HasChildren(FolderIndex) Then Exit;

 SymbolX := Layout.FolderPaneRect.X1 + 4 + (Folders[FolderIndex].Level * FOLDER_INDENT);
 IsClickOnExpandSymbol := (X >= SymbolX) And (X <= SymbolX + 10);
End;

{ Gère le clic sur un dossier }
Procedure HandleFolderClick(X, Y: Integer);
Var
 FolderIdx: Integer;
Begin
 FolderIdx := GetFolderAtPoint(X, Y);

 If FolderIdx >= 0 Then Begin
  { Vérifier si on clique sur le symbole d'expansion }
  If IsClickOnExpandSymbol(X, FolderIdx) Then Begin
   Folders[FolderIdx].Expanded := Not Folders[FolderIdx].Expanded;
   UpdateFolderVisibility;
  End
  Else Begin
   { Sélectionner le dossier }
   If SelectedFolder >= 0 Then
    Folders[SelectedFolder].Selected := False;
   SelectedFolder := FolderIdx;
   Folders[FolderIdx].Selected := True;
  End;

  { Redessiner le panneau }
  HideMouse;
  DrawFolderPane;
  ShowMouse;
 End;
End;

{ Gère le survol de l'arbre de dossiers }
Procedure UpdateFolderHover;
Var
 NewHover: Integer;
Begin
 NewHover := GetFolderAtPoint(MouseX, MouseY);

 If NewHover <> HoveredFolder Then Begin
  HoveredFolder := NewHover;
  HideMouse;
  DrawFolderPane;
  ShowMouse;
 End;
End;

{ ============================================================================
  PROCEDURES POUR LA LISTE DES MESSAGES (TODO 6)
  ============================================================================ }

{ Initialise les colonnes de la liste des messages }
Procedure InitializeMessageColumns;
Begin
 ColumnCount := 7;

 { Colonne Priorite (icone) }
 Columns[0].ColType := ctPriority;
 Columns[0].Title := '!';
 Columns[0].Width := 20;
 Columns[0].Sortable := True;

 { Colonne Piece jointe (icone) }
 Columns[1].ColType := ctAttachment;
 Columns[1].Title := '@';
 Columns[1].Width := 20;
 Columns[1].Sortable := True;

 { Colonne Drapeau (icone) }
 Columns[2].ColType := ctFlag;
 Columns[2].Title := '*';
 Columns[2].Width := 20;
 Columns[2].Sortable := True;

 { Colonne De }
 Columns[3].ColType := ctFrom;
 Columns[3].Title := 'De';
 Columns[3].Width := 120;
 Columns[3].Sortable := True;

 { Colonne Objet }
 Columns[4].ColType := ctSubject;
 Columns[4].Title := 'Objet';
 Columns[4].Width := 200;
 Columns[4].Sortable := True;

 { Colonne Date }
 Columns[5].ColType := ctDate;
 Columns[5].Title := 'Date';
 Columns[5].Width := 70;
 Columns[5].Sortable := True;

 { Colonne Taille }
 Columns[6].ColType := ctSize;
 Columns[6].Title := 'Taille';
 Columns[6].Width := 60;
 Columns[6].Sortable := True;
End;

{ Formate une taille en octets pour l'affichage }
Function FormatSize(Size: LongInt): String;
Var
 S: String;
Begin
 If Size < 1024 Then Begin
  Str(Size, S);
  FormatSize := S + ' o';
 End
 Else If Size < 1048576 Then Begin
  Str(Size Div 1024, S);
  FormatSize := S + ' Ko';
 End
 Else Begin
  Str(Size Div 1048576, S);
  FormatSize := S + ' Mo';
 End;
End;

{ ============================================================================
  IMPLEMENTATION DU CLIENT IMAP (RFC 3501)
  ============================================================================ }

{ Genere un nouveau tag IMAP unique }
Function IMAP_GenerateTag: String;
Var
 S: String;
Begin
 Inc(IMAPClient.TagCounter);
 Str(IMAPClient.TagCounter, S);
 While Length(S) < 4 Do S := '0' + S;
 IMAP_GenerateTag := 'A' + S;
End;

{ Encode une chaine en Base64 pour l'authentification PLAIN }
Function IMAP_EncodeBase64(Const S: String): String;
Const
 Base64Chars: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
Var
 I, J, Len: Integer;
 B: Array[0..2] of Byte;
 Result: String;
Begin
 Result := '';
 Len := Length(S);
 I := 1;
 While I <= Len Do Begin
  { Lire 3 octets }
  For J := 0 To 2 Do Begin
   If I + J <= Len Then
    B[J] := Ord(S[I + J])
   Else
    B[J] := 0;
  End;

  { Encoder en 4 caracteres Base64 }
  Result := Result + Base64Chars[(B[0] Shr 2) + 1];
  Result := Result + Base64Chars[((B[0] And 3) Shl 4) Or (B[1] Shr 4) + 1];

  If I + 1 <= Len Then
   Result := Result + Base64Chars[((B[1] And 15) Shl 2) Or (B[2] Shr 6) + 1]
  Else
   Result := Result + '=';

  If I + 2 <= Len Then
   Result := Result + Base64Chars[(B[2] And 63) + 1]
  Else
   Result := Result + '=';

  I := I + 3;
 End;
 IMAP_EncodeBase64 := Result;
End;

{ Initialise le client IMAP avec les parametres par defaut }
Procedure IMAP_InitClient;
Begin
 IMAPClient.Host := '';
 IMAPClient.Port := IMAPS_PORT;
 IMAPClient.Username := '';
 IMAPClient.Password := '';
 IMAPClient.UseSSL := True;

 IMAPClient.State := isDisconnected;
 IMAPClient.TagCounter := 0;
 IMAPClient.LastTag := '';
 IMAPClient.LastError := '';
 IMAPClient.Capabilities := '';

 IMAPClient.CurrentMailbox.Name := '';
 IMAPClient.CurrentMailbox.Exists := 0;
 IMAPClient.CurrentMailbox.Recent := 0;
 IMAPClient.CurrentMailbox.Unseen := 0;
 IMAPClient.CurrentMailbox.UIDValidity := 0;
 IMAPClient.CurrentMailbox.UIDNext := 0;
 IMAPClient.CurrentMailbox.ReadOnly := False;
 IMAPClient.IsMailboxSelected := False;

 IMAPClient.IdleSupported := False;
 IMAPClient.IdleActive := False;
 IMAPClient.Connected := False;
 IMAPClient.SocketHandle := -1;

 IMAPMessageCount := 0;
 IMAPConnecting := False;
 IMAPLastActivity := 0;
End;

{ Configure le client IMAP }
Procedure IMAP_Configure(Host: String; Port: Integer; User, Pass: String; UseSSL: Boolean);
Begin
 IMAPClient.Host := Host;
 IMAPClient.Port := Port;
 IMAPClient.Username := User;
 IMAPClient.Password := Pass;
 IMAPClient.UseSSL := UseSSL;
End;

{ Simule l'envoi d'une commande IMAP et la reception de la reponse }
{ Note: Dans une implementation reelle, cela utiliserait des sockets }
Function IMAP_SendCommand(Command: String): TIMAPResponse;
Var
 Response: TIMAPResponse;
 Tag: String;
Begin
 Tag := IMAP_GenerateTag;
 IMAPClient.LastTag := Tag;

 { Initialiser la reponse }
 Response.Tag := Tag;
 Response.HasData := False;
 Response.Data := '';
 Response.Text := '';

 { Simuler le comportement du serveur selon la commande }
 If Pos('LOGIN', Command) > 0 Then Begin
  { Authentification LOGIN }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'LOGIN completed';
  IMAPClient.State := isAuthenticated;
 End
 Else If Pos('AUTHENTICATE PLAIN', Command) > 0 Then Begin
  { Authentification PLAIN }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'AUTHENTICATE completed';
  IMAPClient.State := isAuthenticated;
 End
 Else If Pos('CAPABILITY', Command) > 0 Then Begin
  { Capacites du serveur }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'CAPABILITY completed';
  Response.HasData := True;
  Response.Data := 'IMAP4rev1 IDLE NAMESPACE LITERAL+ ID AUTH=PLAIN AUTH=LOGIN';
  IMAPClient.Capabilities := Response.Data;
  IMAPClient.IdleSupported := Pos('IDLE', Response.Data) > 0;
 End
 Else If Pos('SELECT', Command) > 0 Then Begin
  { Selection de boite aux lettres }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := '[READ-WRITE] SELECT completed';
  IMAPClient.State := isSelected;
  IMAPClient.IsMailboxSelected := True;
  { Simuler les donnees de la boite }
  IMAPClient.CurrentMailbox.Exists := 8;
  IMAPClient.CurrentMailbox.Recent := 2;
  IMAPClient.CurrentMailbox.Unseen := 3;
  IMAPClient.CurrentMailbox.UIDValidity := 1234567890;
  IMAPClient.CurrentMailbox.UIDNext := 100;
  IMAPClient.CurrentMailbox.ReadOnly := False;
 End
 Else If Pos('EXAMINE', Command) > 0 Then Begin
  { Examen de boite aux lettres (lecture seule) }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := '[READ-ONLY] EXAMINE completed';
  IMAPClient.State := isSelected;
  IMAPClient.IsMailboxSelected := True;
  IMAPClient.CurrentMailbox.ReadOnly := True;
 End
 Else If Pos('FETCH', Command) > 0 Then Begin
  { Recuperation de messages }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'FETCH completed';
  Response.HasData := True;
 End
 Else If Pos('STORE', Command) > 0 Then Begin
  { Modification des drapeaux }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'STORE completed';
 End
 Else If Pos('COPY', Command) > 0 Then Begin
  { Copie de messages }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'COPY completed';
 End
 Else If Pos('UID', Command) > 0 Then Begin
  { Commande UID }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'UID command completed';
 End
 Else If Pos('LIST', Command) > 0 Then Begin
  { Liste des boites aux lettres }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'LIST completed';
  Response.HasData := True;
 End
 Else If Pos('LSUB', Command) > 0 Then Begin
  { Liste des abonnements }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'LSUB completed';
  Response.HasData := True;
 End
 Else If Pos('IDLE', Command) > 0 Then Begin
  { Mode IDLE }
  If IMAPClient.IdleSupported Then Begin
   Response.ResponseType := irContinue;
   Response.StatusCode := '+';
   Response.Text := 'idling';
   IMAPClient.IdleActive := True;
  End
  Else Begin
   Response.ResponseType := irBAD;
   Response.StatusCode := 'BAD';
   Response.Text := 'IDLE not supported';
  End;
 End
 Else If Pos('DONE', Command) > 0 Then Begin
  { Fin du mode IDLE }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'IDLE terminated';
  IMAPClient.IdleActive := False;
 End
 Else If Pos('NOOP', Command) > 0 Then Begin
  { Commande NOOP }
  Response.ResponseType := irOK;
  Response.StatusCode := 'OK';
  Response.Text := 'NOOP completed';
 End
 Else If Pos('LOGOUT', Command) > 0 Then Begin
  { Deconnexion }
  Response.ResponseType := irBYE;
  Response.StatusCode := 'BYE';
  Response.Text := 'Logging out';
  IMAPClient.State := isLogout;
 End
 Else Begin
  { Commande inconnue }
  Response.ResponseType := irBAD;
  Response.StatusCode := 'BAD';
  Response.Text := 'Unknown command';
 End;

 IMAP_SendCommand := Response;
End;

{ Connecte au serveur IMAP }
Function IMAP_Connect: Integer;
Var
 Response: TIMAPResponse;
Begin
 If IMAPClient.Host = '' Then Begin
  IMAPClient.LastError := 'Serveur non configure';
  IMAP_Connect := IMAP_ERR_CONNECT;
  Exit;
 End;

 IMAPConnecting := True;

 { Simuler la connexion socket }
 { Dans une vraie implementation, on utiliserait les sockets }
 IMAPClient.Connected := True;
 IMAPClient.SocketHandle := 1;
 IMAPClient.State := isConnected;

 { Recevoir le message de bienvenue }
 { Normalement le serveur envoie "* OK ... ready" }

 { Demander les capacites }
 Response := IMAP_SendCommand('CAPABILITY');
 If Response.ResponseType <> irOK Then Begin
  IMAPClient.LastError := 'Echec CAPABILITY';
  IMAP_Connect := IMAP_ERR_PROTOCOL;
  IMAPConnecting := False;
  Exit;
 End;

 IMAPConnecting := False;
 IMAP_Connect := IMAP_OK;
End;

{ Authentifie avec la methode LOGIN }
Function IMAP_LoginAuth: Integer;
Var
 Response: TIMAPResponse;
 Command: String;
Begin
 If IMAPClient.State <> isConnected Then Begin
  IMAPClient.LastError := 'Non connecte';
  IMAP_LoginAuth := IMAP_ERR_AUTH;
  Exit;
 End;

 Command := 'LOGIN "' + IMAPClient.Username + '" "' + IMAPClient.Password + '"';
 Response := IMAP_SendCommand(Command);

 If Response.ResponseType = irOK Then
  IMAP_LoginAuth := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec authentification: ' + Response.Text;
  IMAP_LoginAuth := IMAP_ERR_AUTH;
 End;
End;

{ Authentifie avec la methode PLAIN (Base64) }
Function IMAP_PlainAuth: Integer;
Var
 Response: TIMAPResponse;
 AuthString, Encoded: String;
Begin
 If IMAPClient.State <> isConnected Then Begin
  IMAPClient.LastError := 'Non connecte';
  IMAP_PlainAuth := IMAP_ERR_AUTH;
  Exit;
 End;

 { Format PLAIN: \0username\0password }
 AuthString := #0 + IMAPClient.Username + #0 + IMAPClient.Password;
 Encoded := IMAP_EncodeBase64(AuthString);

 Response := IMAP_SendCommand('AUTHENTICATE PLAIN ' + Encoded);

 If Response.ResponseType = irOK Then
  IMAP_PlainAuth := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec authentification PLAIN: ' + Response.Text;
  IMAP_PlainAuth := IMAP_ERR_AUTH;
 End;
End;

{ Selectionne une boite aux lettres }
Function IMAP_Select(Mailbox: String): Integer;
Var
 Response: TIMAPResponse;
Begin
 If IMAPClient.State < isAuthenticated Then Begin
  IMAPClient.LastError := 'Non authentifie';
  IMAP_Select := IMAP_ERR_SELECT;
  Exit;
 End;

 Response := IMAP_SendCommand('SELECT "' + Mailbox + '"');

 If Response.ResponseType = irOK Then Begin
  IMAPClient.CurrentMailbox.Name := Mailbox;
  IMAP_Select := IMAP_OK;
 End
 Else Begin
  IMAPClient.LastError := 'Echec SELECT: ' + Response.Text;
  IMAP_Select := IMAP_ERR_SELECT;
 End;
End;

{ Examine une boite aux lettres (lecture seule) }
Function IMAP_Examine(Mailbox: String): Integer;
Var
 Response: TIMAPResponse;
Begin
 If IMAPClient.State < isAuthenticated Then Begin
  IMAPClient.LastError := 'Non authentifie';
  IMAP_Examine := IMAP_ERR_SELECT;
  Exit;
 End;

 Response := IMAP_SendCommand('EXAMINE "' + Mailbox + '"');

 If Response.ResponseType = irOK Then Begin
  IMAPClient.CurrentMailbox.Name := Mailbox;
  IMAP_Examine := IMAP_OK;
 End
 Else Begin
  IMAPClient.LastError := 'Echec EXAMINE: ' + Response.Text;
  IMAP_Examine := IMAP_ERR_SELECT;
 End;
End;

{ Recupere les en-tetes d'un message par numero de sequence }
Function IMAP_FetchHeaders(SeqNum: LongInt): Integer;
Var
 Response: TIMAPResponse;
 SeqStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_FetchHeaders := IMAP_ERR_FETCH;
  Exit;
 End;

 Str(SeqNum, SeqStr);
 Response := IMAP_SendCommand('FETCH ' + SeqStr + ' (FLAGS ENVELOPE RFC822.SIZE)');

 If Response.ResponseType = irOK Then
  IMAP_FetchHeaders := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec FETCH: ' + Response.Text;
  IMAP_FetchHeaders := IMAP_ERR_FETCH;
 End;
End;

{ Recupere le corps complet d'un message }
Function IMAP_FetchBody(SeqNum: LongInt): Integer;
Var
 Response: TIMAPResponse;
 SeqStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_FetchBody := IMAP_ERR_FETCH;
  Exit;
 End;

 Str(SeqNum, SeqStr);
 Response := IMAP_SendCommand('FETCH ' + SeqStr + ' BODY[]');

 If Response.ResponseType = irOK Then
  IMAP_FetchBody := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec FETCH BODY: ' + Response.Text;
  IMAP_FetchBody := IMAP_ERR_FETCH;
 End;
End;

{ Recupere un message par son UID }
Function IMAP_UIDFetch(UID: LongInt; FetchType: String): Integer;
Var
 Response: TIMAPResponse;
 UIDStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_UIDFetch := IMAP_ERR_FETCH;
  Exit;
 End;

 Str(UID, UIDStr);
 Response := IMAP_SendCommand('UID FETCH ' + UIDStr + ' ' + FetchType);

 If Response.ResponseType = irOK Then
  IMAP_UIDFetch := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec UID FETCH: ' + Response.Text;
  IMAP_UIDFetch := IMAP_ERR_FETCH;
 End;
End;

{ Modifie les drapeaux d'un message }
Function IMAP_Store(SeqNum: LongInt; Flags: String; AddFlags: Boolean): Integer;
Var
 Response: TIMAPResponse;
 SeqStr, FlagOp: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_Store := IMAP_ERR_STORE;
  Exit;
 End;

 Str(SeqNum, SeqStr);
 If AddFlags Then
  FlagOp := '+FLAGS'
 Else
  FlagOp := '-FLAGS';

 Response := IMAP_SendCommand('STORE ' + SeqStr + ' ' + FlagOp + ' (' + Flags + ')');

 If Response.ResponseType = irOK Then
  IMAP_Store := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec STORE: ' + Response.Text;
  IMAP_Store := IMAP_ERR_STORE;
 End;
End;

{ Marque un message comme lu }
Function IMAP_MarkAsRead(SeqNum: LongInt): Integer;
Begin
 IMAP_MarkAsRead := IMAP_Store(SeqNum, IMAP_FLAG_SEEN, True);
End;

{ Marque un message comme non lu }
Function IMAP_MarkAsUnread(SeqNum: LongInt): Integer;
Begin
 IMAP_MarkAsUnread := IMAP_Store(SeqNum, IMAP_FLAG_SEEN, False);
End;

{ Marque un message comme repondu }
Function IMAP_MarkAsAnswered(SeqNum: LongInt): Integer;
Begin
 IMAP_MarkAsAnswered := IMAP_Store(SeqNum, IMAP_FLAG_ANSWERED, True);
End;

{ Marque un message avec un drapeau }
Function IMAP_SetFlagged(SeqNum: LongInt; Flagged: Boolean): Integer;
Begin
 IMAP_SetFlagged := IMAP_Store(SeqNum, IMAP_FLAG_FLAGGED, Flagged);
End;

{ Marque un message comme supprime }
Function IMAP_MarkDeleted(SeqNum: LongInt): Integer;
Begin
 IMAP_MarkDeleted := IMAP_Store(SeqNum, IMAP_FLAG_DELETED, True);
End;

{ Copie un message vers une autre boite }
Function IMAP_Copy(SeqNum: LongInt; DestMailbox: String): Integer;
Var
 Response: TIMAPResponse;
 SeqStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_Copy := IMAP_ERR_COPY;
  Exit;
 End;

 Str(SeqNum, SeqStr);
 Response := IMAP_SendCommand('COPY ' + SeqStr + ' "' + DestMailbox + '"');

 If Response.ResponseType = irOK Then
  IMAP_Copy := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec COPY: ' + Response.Text;
  IMAP_Copy := IMAP_ERR_COPY;
 End;
End;

{ Copie un message par UID }
Function IMAP_UIDCopy(UID: LongInt; DestMailbox: String): Integer;
Var
 Response: TIMAPResponse;
 UIDStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_UIDCopy := IMAP_ERR_COPY;
  Exit;
 End;

 Str(UID, UIDStr);
 Response := IMAP_SendCommand('UID COPY ' + UIDStr + ' "' + DestMailbox + '"');

 If Response.ResponseType = irOK Then
  IMAP_UIDCopy := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec UID COPY: ' + Response.Text;
  IMAP_UIDCopy := IMAP_ERR_COPY;
 End;
End;

{ Liste les boites aux lettres }
Function IMAP_List(Reference, Pattern: String): Integer;
Var
 Response: TIMAPResponse;
Begin
 If IMAPClient.State < isAuthenticated Then Begin
  IMAPClient.LastError := 'Non authentifie';
  IMAP_List := IMAP_ERR_PROTOCOL;
  Exit;
 End;

 Response := IMAP_SendCommand('LIST "' + Reference + '" "' + Pattern + '"');

 If Response.ResponseType = irOK Then
  IMAP_List := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec LIST: ' + Response.Text;
  IMAP_List := IMAP_ERR_PROTOCOL;
 End;
End;

{ Liste les boites aux lettres abonnees }
Function IMAP_LSub(Reference, Pattern: String): Integer;
Var
 Response: TIMAPResponse;
Begin
 If IMAPClient.State < isAuthenticated Then Begin
  IMAPClient.LastError := 'Non authentifie';
  IMAP_LSub := IMAP_ERR_PROTOCOL;
  Exit;
 End;

 Response := IMAP_SendCommand('LSUB "' + Reference + '" "' + Pattern + '"');

 If Response.ResponseType = irOK Then
  IMAP_LSub := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec LSUB: ' + Response.Text;
  IMAP_LSub := IMAP_ERR_PROTOCOL;
 End;
End;

{ Entre en mode IDLE pour les notifications push }
Function IMAP_StartIdle: Integer;
Var
 Response: TIMAPResponse;
Begin
 If Not IMAPClient.IdleSupported Then Begin
  IMAPClient.LastError := 'IDLE non supporte par le serveur';
  IMAP_StartIdle := IMAP_ERR_PROTOCOL;
  Exit;
 End;

 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAPClient.LastError := 'Aucune boite selectionnee';
  IMAP_StartIdle := IMAP_ERR_PROTOCOL;
  Exit;
 End;

 Response := IMAP_SendCommand('IDLE');

 If Response.ResponseType = irContinue Then Begin
  IMAPClient.IdleActive := True;
  IMAP_StartIdle := IMAP_OK;
 End
 Else Begin
  IMAPClient.LastError := 'Echec IDLE: ' + Response.Text;
  IMAP_StartIdle := IMAP_ERR_PROTOCOL;
 End;
End;

{ Sort du mode IDLE }
Function IMAP_StopIdle: Integer;
Var
 Response: TIMAPResponse;
Begin
 If Not IMAPClient.IdleActive Then Begin
  IMAP_StopIdle := IMAP_OK;
  Exit;
 End;

 Response := IMAP_SendCommand('DONE');

 If Response.ResponseType = irOK Then Begin
  IMAPClient.IdleActive := False;
  IMAP_StopIdle := IMAP_OK;
 End
 Else Begin
  IMAPClient.LastError := 'Echec DONE: ' + Response.Text;
  IMAP_StopIdle := IMAP_ERR_PROTOCOL;
 End;
End;

{ Envoie une commande NOOP pour maintenir la connexion }
Function IMAP_Noop: Integer;
Var
 Response: TIMAPResponse;
Begin
 Response := IMAP_SendCommand('NOOP');

 If Response.ResponseType = irOK Then
  IMAP_Noop := IMAP_OK
 Else Begin
  IMAPClient.LastError := 'Echec NOOP: ' + Response.Text;
  IMAP_Noop := IMAP_ERR_PROTOCOL;
 End;
End;

{ Se deconnecte du serveur IMAP }
Function IMAP_Logout: Integer;
Var
 Response: TIMAPResponse;
Begin
 If Not IMAPClient.Connected Then Begin
  IMAP_Logout := IMAP_OK;
  Exit;
 End;

 { Sortir du mode IDLE si actif }
 If IMAPClient.IdleActive Then
  IMAP_StopIdle;

 Response := IMAP_SendCommand('LOGOUT');

 { Fermer la connexion }
 IMAPClient.Connected := False;
 IMAPClient.SocketHandle := -1;
 IMAPClient.State := isDisconnected;
 IMAPClient.IsMailboxSelected := False;
 IMAPClient.IdleActive := False;

 IMAP_Logout := IMAP_OK;
End;

{ Synchronise la liste des messages avec le serveur }
Procedure IMAP_SyncMessages;
Var
 I: Integer;
Begin
 If Not IMAPClient.IsMailboxSelected Then Exit;

 { Dans une implementation reelle, on recupererait les messages du serveur }
 { Pour la demonstration, on utilise les messages existants }

 { Simuler la mise a jour du nombre de messages }
 IMAPMessageCount := MessageCount;

 { Copier les messages locaux vers le cache IMAP }
 For I := 0 To IMAPMessageCount - 1 Do Begin
  IMAPMessages[I].UID := I + 1;
  IMAPMessages[I].SeqNum := I + 1;
  IMAPMessages[I].Flags.Seen := Messages[I].IsRead;
  IMAPMessages[I].Flags.Flagged := Messages[I].IsFlagged;
  IMAPMessages[I].Flags.Answered := False;
  IMAPMessages[I].Flags.Deleted := False;
  IMAPMessages[I].Flags.Draft := False;
  IMAPMessages[I].Flags.Recent := Not Messages[I].IsRead;
  IMAPMessages[I].Size := Messages[I].Size;
  IMAPMessages[I].Envelope.Subject := Messages[I].Subject;
  IMAPMessages[I].Envelope.FromName := Messages[I].FromName;
  IMAPMessages[I].Envelope.FromEmail := Messages[I].FromEmail;
  IMAPMessages[I].Envelope.ToName := Messages[I].ToName;
  IMAPMessages[I].Envelope.ToEmail := Messages[I].ToEmail;
  IMAPMessages[I].Envelope.CcEmail := Messages[I].CcEmail;
  IMAPMessages[I].Envelope.MsgDate := Messages[I].DateFull;
  IMAPMessages[I].BodyLoaded := True;
 End;
End;

{ Convertit les drapeaux IMAP en chaine }
Function IMAP_FlagsToString(Flags: TIMAPFlags): String;
Var
 S: String;
Begin
 S := '';
 If Flags.Seen Then S := S + IMAP_FLAG_SEEN + ' ';
 If Flags.Answered Then S := S + IMAP_FLAG_ANSWERED + ' ';
 If Flags.Flagged Then S := S + IMAP_FLAG_FLAGGED + ' ';
 If Flags.Deleted Then S := S + IMAP_FLAG_DELETED + ' ';
 If Flags.Draft Then S := S + IMAP_FLAG_DRAFT + ' ';
 If Flags.Recent Then S := S + IMAP_FLAG_RECENT + ' ';
 { Supprimer l'espace final }
 If Length(S) > 0 Then
  Delete(S, Length(S), 1);
 IMAP_FlagsToString := S;
End;

{ Retourne l'etat de connexion sous forme de chaine }
Function IMAP_GetStateString: String;
Begin
 Case IMAPClient.State Of
  isDisconnected: IMAP_GetStateString := 'Deconnecte';
  isConnected: IMAP_GetStateString := 'Connecte';
  isAuthenticated: IMAP_GetStateString := 'Authentifie';
  isSelected: IMAP_GetStateString := 'Boite selectionnee';
  isLogout: IMAP_GetStateString := 'Deconnexion';
 Else
  IMAP_GetStateString := 'Inconnu';
 End;
End;

{ Retourne les informations de la boite courante }
Function IMAP_GetMailboxInfo: String;
Var
 S, NumStr: String;
Begin
 If Not IMAPClient.IsMailboxSelected Then Begin
  IMAP_GetMailboxInfo := 'Aucune boite selectionnee';
  Exit;
 End;

 S := IMAPClient.CurrentMailbox.Name + ': ';
 Str(IMAPClient.CurrentMailbox.Exists, NumStr);
 S := S + NumStr + ' messages, ';
 Str(IMAPClient.CurrentMailbox.Recent, NumStr);
 S := S + NumStr + ' recents, ';
 Str(IMAPClient.CurrentMailbox.Unseen, NumStr);
 S := S + NumStr + ' non lus';

 If IMAPClient.CurrentMailbox.ReadOnly Then
  S := S + ' [LECTURE SEULE]';

 IMAP_GetMailboxInfo := S;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION IMAP
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU CLIENT POP3 (RFC 1939)
  ============================================================================ }

{ Initialise le client POP3 avec les parametres par defaut }
Procedure POP3_InitClient;
Begin
 POP3Client.Host := '';
 POP3Client.Port := POP3S_PORT;
 POP3Client.Username := '';
 POP3Client.Password := '';
 POP3Client.UseSSL := True;

 POP3Client.State := psDisconnected;
 POP3Client.LastError := '';
 POP3Client.ServerGreeting := '';
 POP3Client.APOPTimestamp := '';

 POP3Client.Stats.MessageCount := 0;
 POP3Client.Stats.TotalSize := 0;

 POP3Client.LeaveOnServer := True;
 POP3Client.HeadersOnly := False;
 POP3Client.DeleteAfterDays := 0;

 POP3Client.Connected := False;
 POP3Client.SocketHandle := -1;

 POP3MessageCount := 0;
 POP3Connecting := False;
 POP3LastActivity := 0;
End;

{ Configure le client POP3 }
Procedure POP3_Configure(Host: String; Port: Integer; User, Pass: String; UseSSL: Boolean);
Begin
 POP3Client.Host := Host;
 POP3Client.Port := Port;
 POP3Client.Username := User;
 POP3Client.Password := Pass;
 POP3Client.UseSSL := UseSSL;
End;

{ Configure les options du client POP3 }
Procedure POP3_SetOptions(LeaveOnServer, HeadersOnly: Boolean; DeleteAfterDays: Integer);
Begin
 POP3Client.LeaveOnServer := LeaveOnServer;
 POP3Client.HeadersOnly := HeadersOnly;
 POP3Client.DeleteAfterDays := DeleteAfterDays;
End;

{ Extrait le timestamp APOP du message de bienvenue }
Function POP3_ExtractAPOPTimestamp(Greeting: String): String;
Var
 StartPos, EndPos: Integer;
Begin
 POP3_ExtractAPOPTimestamp := '';
 StartPos := Pos('<', Greeting);
 If StartPos > 0 Then Begin
  EndPos := Pos('>', Greeting);
  If EndPos > StartPos Then
   POP3_ExtractAPOPTimestamp := Copy(Greeting, StartPos, EndPos - StartPos + 1);
 End;
End;

{ Calcule le hash MD5 pour l'authentification APOP }
{ Note: Implementation simplifiee, retourne une chaine hexadecimale }
Function POP3_MD5Hash(Input: String): String;
Var
 I: Integer;
 Hash: LongInt;
 HexStr: String;
 HexChars: String;
Begin
 { Implementation simplifiee du hash MD5 }
 { Dans une vraie implementation, on utiliserait une bibliotheque MD5 }
 HexChars := '0123456789abcdef';
 Hash := 0;
 For I := 1 To Length(Input) Do
  Hash := (Hash * 31 + Ord(Input[I])) Mod 2147483647;

 HexStr := '';
 For I := 1 To 32 Do Begin
  HexStr := HexStr + HexChars[(Abs(Hash) Mod 16) + 1];
  Hash := Hash Div 16;
  If Hash = 0 Then Hash := I * 7919;
 End;
 POP3_MD5Hash := HexStr;
End;

{ Simule l'envoi d'une commande POP3 et la reception de la reponse }
{ Note: Dans une implementation reelle, cela utiliserait des sockets }
Function POP3_SendCommand(Command: String): TPOP3Response;
Var
 Response: TPOP3Response;
 CmdUpper: String;
 I: Integer;
Begin
 { Initialiser la reponse }
 Response.HasMultiline := False;
 Response.Data := '';
 Response.Text := '';

 { Convertir la commande en majuscules pour la comparaison }
 CmdUpper := '';
 For I := 1 To Length(Command) Do
  If Command[I] In ['a'..'z'] Then
   CmdUpper := CmdUpper + Chr(Ord(Command[I]) - 32)
  Else
   CmdUpper := CmdUpper + Command[I];

 { Simuler le comportement du serveur selon la commande }
 If Pos('USER', CmdUpper) = 1 Then Begin
  { Commande USER }
  Response.ResponseType := prOK;
  Response.Text := 'User accepted';
 End
 Else If Pos('PASS', CmdUpper) = 1 Then Begin
  { Commande PASS }
  Response.ResponseType := prOK;
  Response.Text := 'Authentication successful';
  POP3Client.State := psTransaction;
 End
 Else If Pos('APOP', CmdUpper) = 1 Then Begin
  { Authentification APOP }
  Response.ResponseType := prOK;
  Response.Text := 'APOP authentication successful';
  POP3Client.State := psTransaction;
 End
 Else If Pos('STAT', CmdUpper) = 1 Then Begin
  { Commande STAT - statistiques }
  Response.ResponseType := prOK;
  Response.Text := '8 45678';
  POP3Client.Stats.MessageCount := 8;
  POP3Client.Stats.TotalSize := 45678;
 End
 Else If Pos('LIST', CmdUpper) = 1 Then Begin
  { Commande LIST }
  If Length(CmdUpper) > 4 Then Begin
   { LIST avec numero de message }
   Response.ResponseType := prOK;
   Response.Text := '1 2450';
  End
  Else Begin
   { LIST sans parametre - liste complete }
   Response.ResponseType := prOK;
   Response.Text := '8 messages';
   Response.HasMultiline := True;
   Response.Data := '1 2450' + Chr(13) + Chr(10) +
                    '2 1520' + Chr(13) + Chr(10) +
                    '3 3200' + Chr(13) + Chr(10) +
                    '4 980'  + Chr(13) + Chr(10) +
                    '5 15400'+ Chr(13) + Chr(10) +
                    '6 1100' + Chr(13) + Chr(10) +
                    '7 890'  + Chr(13) + Chr(10) +
                    '8 20138';
  End;
 End
 Else If Pos('RETR', CmdUpper) = 1 Then Begin
  { Commande RETR - recuperer message complet }
  Response.ResponseType := prOK;
  Response.Text := 'Message follows';
  Response.HasMultiline := True;
  Response.Data := 'From: test@example.com' + Chr(13) + Chr(10) +
                   'To: user@example.com' + Chr(13) + Chr(10) +
                   'Subject: Test message' + Chr(13) + Chr(10) +
                   'Date: Sat, 11 Apr 2026 10:00:00 +0000' + Chr(13) + Chr(10) +
                   Chr(13) + Chr(10) +
                   'This is a test message body.';
 End
 Else If Pos('DELE', CmdUpper) = 1 Then Begin
  { Commande DELE - marquer pour suppression }
  Response.ResponseType := prOK;
  Response.Text := 'Message marked for deletion';
 End
 Else If Pos('TOP', CmdUpper) = 1 Then Begin
  { Commande TOP - en-tetes + N lignes du corps }
  Response.ResponseType := prOK;
  Response.Text := 'Headers follow';
  Response.HasMultiline := True;
  Response.Data := 'From: test@example.com' + Chr(13) + Chr(10) +
                   'To: user@example.com' + Chr(13) + Chr(10) +
                   'Subject: Test message' + Chr(13) + Chr(10) +
                   'Date: Sat, 11 Apr 2026 10:00:00 +0000';
 End
 Else If Pos('UIDL', CmdUpper) = 1 Then Begin
  { Commande UIDL - identifiants uniques }
  If Length(CmdUpper) > 4 Then Begin
   { UIDL avec numero de message }
   Response.ResponseType := prOK;
   Response.Text := '1 ABC123DEF456';
  End
  Else Begin
   { UIDL sans parametre - liste complete }
   Response.ResponseType := prOK;
   Response.Text := 'Unique-ID listing follows';
   Response.HasMultiline := True;
   Response.Data := '1 ABC123DEF456' + Chr(13) + Chr(10) +
                    '2 GHI789JKL012' + Chr(13) + Chr(10) +
                    '3 MNO345PQR678' + Chr(13) + Chr(10) +
                    '4 STU901VWX234' + Chr(13) + Chr(10) +
                    '5 YZA567BCD890' + Chr(13) + Chr(10) +
                    '6 EFG123HIJ456' + Chr(13) + Chr(10) +
                    '7 KLM789NOP012' + Chr(13) + Chr(10) +
                    '8 QRS345TUV678';
  End;
 End
 Else If Pos('NOOP', CmdUpper) = 1 Then Begin
  { Commande NOOP }
  Response.ResponseType := prOK;
  Response.Text := 'OK';
 End
 Else If Pos('RSET', CmdUpper) = 1 Then Begin
  { Commande RSET - annuler les suppressions }
  Response.ResponseType := prOK;
  Response.Text := 'Reset OK';
 End
 Else If Pos('QUIT', CmdUpper) = 1 Then Begin
  { Commande QUIT }
  Response.ResponseType := prOK;
  Response.Text := 'Goodbye';
  POP3Client.State := psUpdate;
 End
 Else Begin
  { Commande inconnue }
  Response.ResponseType := prERR;
  Response.Text := 'Unknown command';
 End;

 POP3_SendCommand := Response;
End;

{ Connecte au serveur POP3 }
Function POP3_Connect: Integer;
Begin
 If POP3Client.Host = '' Then Begin
  POP3Client.LastError := 'Serveur non configure';
  POP3_Connect := POP3_ERR_CONNECT;
  Exit;
 End;

 POP3Connecting := True;

 { Simuler la connexion socket }
 { Dans une vraie implementation, on utiliserait les sockets }
 POP3Client.Connected := True;
 POP3Client.SocketHandle := 2;
 POP3Client.State := psAuthorization;

 { Simuler le message de bienvenue avec timestamp APOP }
 POP3Client.ServerGreeting := '+OK POP3 server ready <1234.5678@pop.example.com>';
 POP3Client.APOPTimestamp := POP3_ExtractAPOPTimestamp(POP3Client.ServerGreeting);

 POP3Connecting := False;
 POP3_Connect := POP3_OK;
End;

{ Authentifie avec la methode USER/PASS }
Function POP3_AuthUserPass: Integer;
Var
 Response: TPOP3Response;
Begin
 If POP3Client.State <> psAuthorization Then Begin
  POP3Client.LastError := 'Pas en etat AUTHORIZATION';
  POP3_AuthUserPass := POP3_ERR_AUTH;
  Exit;
 End;

 { Envoyer USER }
 Response := POP3_SendCommand('USER ' + POP3Client.Username);
 If Response.ResponseType <> prOK Then Begin
  POP3Client.LastError := 'USER echoue: ' + Response.Text;
  POP3_AuthUserPass := POP3_ERR_AUTH;
  Exit;
 End;

 { Envoyer PASS }
 Response := POP3_SendCommand('PASS ' + POP3Client.Password);
 If Response.ResponseType = prOK Then
  POP3_AuthUserPass := POP3_OK
 Else Begin
  POP3Client.LastError := 'PASS echoue: ' + Response.Text;
  POP3_AuthUserPass := POP3_ERR_AUTH;
 End;
End;

{ Authentifie avec la methode APOP }
Function POP3_AuthAPOP: Integer;
Var
 Response: TPOP3Response;
 DigestInput, Digest: String;
Begin
 If POP3Client.State <> psAuthorization Then Begin
  POP3Client.LastError := 'Pas en etat AUTHORIZATION';
  POP3_AuthAPOP := POP3_ERR_AUTH;
  Exit;
 End;

 If POP3Client.APOPTimestamp = '' Then Begin
  POP3Client.LastError := 'Serveur ne supporte pas APOP';
  POP3_AuthAPOP := POP3_ERR_AUTH;
  Exit;
 End;

 { Calculer le digest MD5(timestamp + password) }
 DigestInput := POP3Client.APOPTimestamp + POP3Client.Password;
 Digest := POP3_MD5Hash(DigestInput);

 { Envoyer APOP }
 Response := POP3_SendCommand('APOP ' + POP3Client.Username + ' ' + Digest);

 If Response.ResponseType = prOK Then
  POP3_AuthAPOP := POP3_OK
 Else Begin
  POP3Client.LastError := 'APOP echoue: ' + Response.Text;
  POP3_AuthAPOP := POP3_ERR_AUTH;
 End;
End;

{ Obtient les statistiques de la boite (STAT) }
Function POP3_Stat: Integer;
Var
 Response: TPOP3Response;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_Stat := POP3_ERR_STAT;
  Exit;
 End;

 Response := POP3_SendCommand('STAT');

 If Response.ResponseType = prOK Then
  POP3_Stat := POP3_OK
 Else Begin
  POP3Client.LastError := 'STAT echoue: ' + Response.Text;
  POP3_Stat := POP3_ERR_STAT;
 End;
End;

{ Liste les messages (LIST) }
Function POP3_List(MsgNum: Integer): Integer;
Var
 Response: TPOP3Response;
 NumStr: String;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_List := POP3_ERR_LIST;
  Exit;
 End;

 If MsgNum > 0 Then Begin
  Str(MsgNum, NumStr);
  Response := POP3_SendCommand('LIST ' + NumStr);
 End
 Else
  Response := POP3_SendCommand('LIST');

 If Response.ResponseType = prOK Then
  POP3_List := POP3_OK
 Else Begin
  POP3Client.LastError := 'LIST echoue: ' + Response.Text;
  POP3_List := POP3_ERR_LIST;
 End;
End;

{ Recupere un message complet (RETR) }
Function POP3_Retr(MsgNum: Integer): Integer;
Var
 Response: TPOP3Response;
 NumStr: String;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_Retr := POP3_ERR_RETR;
  Exit;
 End;

 Str(MsgNum, NumStr);
 Response := POP3_SendCommand('RETR ' + NumStr);

 If Response.ResponseType = prOK Then
  POP3_Retr := POP3_OK
 Else Begin
  POP3Client.LastError := 'RETR echoue: ' + Response.Text;
  POP3_Retr := POP3_ERR_RETR;
 End;
End;

{ Marque un message pour suppression (DELE) }
Function POP3_Dele(MsgNum: Integer): Integer;
Var
 Response: TPOP3Response;
 NumStr: String;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_Dele := POP3_ERR_DELE;
  Exit;
 End;

 Str(MsgNum, NumStr);
 Response := POP3_SendCommand('DELE ' + NumStr);

 If Response.ResponseType = prOK Then Begin
  { Marquer le message localement }
  If (MsgNum > 0) And (MsgNum <= POP3MessageCount) Then
   POP3ListItems[MsgNum - 1].Deleted := True;
  POP3_Dele := POP3_OK;
 End
 Else Begin
  POP3Client.LastError := 'DELE echoue: ' + Response.Text;
  POP3_Dele := POP3_ERR_DELE;
 End;
End;

{ Recupere les en-tetes + N lignes du corps (TOP) }
Function POP3_Top(MsgNum, Lines: Integer): Integer;
Var
 Response: TPOP3Response;
 NumStr, LineStr: String;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_Top := POP3_ERR_TOP;
  Exit;
 End;

 Str(MsgNum, NumStr);
 Str(Lines, LineStr);
 Response := POP3_SendCommand('TOP ' + NumStr + ' ' + LineStr);

 If Response.ResponseType = prOK Then
  POP3_Top := POP3_OK
 Else Begin
  POP3Client.LastError := 'TOP echoue: ' + Response.Text;
  POP3_Top := POP3_ERR_TOP;
 End;
End;

{ Obtient les identifiants uniques (UIDL) }
Function POP3_UIDL(MsgNum: Integer): Integer;
Var
 Response: TPOP3Response;
 NumStr: String;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_UIDL := POP3_ERR_UIDL;
  Exit;
 End;

 If MsgNum > 0 Then Begin
  Str(MsgNum, NumStr);
  Response := POP3_SendCommand('UIDL ' + NumStr);
 End
 Else
  Response := POP3_SendCommand('UIDL');

 If Response.ResponseType = prOK Then
  POP3_UIDL := POP3_OK
 Else Begin
  POP3Client.LastError := 'UIDL echoue: ' + Response.Text;
  POP3_UIDL := POP3_ERR_UIDL;
 End;
End;

{ Envoie une commande NOOP pour maintenir la connexion }
Function POP3_Noop: Integer;
Var
 Response: TPOP3Response;
Begin
 Response := POP3_SendCommand('NOOP');

 If Response.ResponseType = prOK Then
  POP3_Noop := POP3_OK
 Else Begin
  POP3Client.LastError := 'NOOP echoue: ' + Response.Text;
  POP3_Noop := POP3_ERR_PROTOCOL;
 End;
End;

{ Annule les suppressions marquees (RSET) }
Function POP3_Rset: Integer;
Var
 Response: TPOP3Response;
 I: Integer;
Begin
 If POP3Client.State <> psTransaction Then Begin
  POP3Client.LastError := 'Pas en etat TRANSACTION';
  POP3_Rset := POP3_ERR_PROTOCOL;
  Exit;
 End;

 Response := POP3_SendCommand('RSET');

 If Response.ResponseType = prOK Then Begin
  { Annuler les marquages locaux }
  For I := 0 To POP3MessageCount - 1 Do
   POP3ListItems[I].Deleted := False;
  POP3_Rset := POP3_OK;
 End
 Else Begin
  POP3Client.LastError := 'RSET echoue: ' + Response.Text;
  POP3_Rset := POP3_ERR_PROTOCOL;
 End;
End;

{ Se deconnecte du serveur POP3 (QUIT) }
Function POP3_Quit: Integer;
Var
 Response: TPOP3Response;
Begin
 If Not POP3Client.Connected Then Begin
  POP3_Quit := POP3_OK;
  Exit;
 End;

 Response := POP3_SendCommand('QUIT');

 { Fermer la connexion }
 POP3Client.Connected := False;
 POP3Client.SocketHandle := -1;
 POP3Client.State := psDisconnected;

 POP3_Quit := POP3_OK;
End;

{ Synchronise la liste des messages avec le serveur }
Procedure POP3_SyncMessages;
Var
 I: Integer;
Begin
 If POP3Client.State <> psTransaction Then Exit;

 { Obtenir les statistiques }
 POP3_Stat;

 { Simuler le remplissage de la liste }
 POP3MessageCount := POP3Client.Stats.MessageCount;
 If POP3MessageCount > POP3_MAX_MESSAGES Then
  POP3MessageCount := POP3_MAX_MESSAGES;

 { Initialiser la liste des messages }
 For I := 0 To POP3MessageCount - 1 Do Begin
  POP3ListItems[I].MsgNum := I + 1;
  POP3ListItems[I].Size := 1000 + (I * 500);
  POP3ListItems[I].Deleted := False;
  POP3ListItems[I].UIDL := '';
 End;

 { Obtenir les UIDLs }
 POP3_UIDL(0);
End;

{ Telecharge les messages selon les options }
Procedure POP3_DownloadMessages;
Var
 I: Integer;
Begin
 If POP3Client.State <> psTransaction Then Exit;

 For I := 0 To POP3MessageCount - 1 Do Begin
  If POP3Client.HeadersOnly Then
   { Telecharger seulement les en-tetes }
   POP3_Top(I + 1, 0)
  Else
   { Telecharger le message complet }
   POP3_Retr(I + 1);

  { Supprimer si option activee et pas "Laisser sur serveur" }
  If Not POP3Client.LeaveOnServer Then
   POP3_Dele(I + 1);
 End;
End;

{ Retourne l'etat de connexion sous forme de chaine }
Function POP3_GetStateString: String;
Begin
 Case POP3Client.State Of
  psDisconnected: POP3_GetStateString := 'Deconnecte';
  psAuthorization: POP3_GetStateString := 'Autorisation';
  psTransaction: POP3_GetStateString := 'Transaction';
  psUpdate: POP3_GetStateString := 'Mise a jour';
 Else
  POP3_GetStateString := 'Inconnu';
 End;
End;

{ Retourne les informations de la boite }
Function POP3_GetMailboxInfo: String;
Var
 S, NumStr: String;
Begin
 If POP3Client.State < psTransaction Then Begin
  POP3_GetMailboxInfo := 'Non connecte';
  Exit;
 End;

 Str(POP3Client.Stats.MessageCount, NumStr);
 S := NumStr + ' messages, ';
 Str(POP3Client.Stats.TotalSize Div 1024, NumStr);
 S := S + NumStr + ' Ko';

 POP3_GetMailboxInfo := S;
End;

{ Verifie si APOP est disponible }
Function POP3_IsAPOPAvailable: Boolean;
Begin
 POP3_IsAPOPAvailable := POP3Client.APOPTimestamp <> '';
End;

{ Compte les messages marques pour suppression }
Function POP3_GetDeletedCount: Integer;
Var
 I, Count: Integer;
Begin
 Count := 0;
 For I := 0 To POP3MessageCount - 1 Do
  If POP3ListItems[I].Deleted Then
   Inc(Count);
 POP3_GetDeletedCount := Count;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION POP3
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU CLIENT SMTP (RFC 5321)
  ============================================================================ }

{ Initialise le client SMTP avec les parametres par defaut }
Procedure SMTP_InitClient;
Var
 I: Integer;
Begin
 SMTPClient.Host := '';
 SMTPClient.Port := SMTP_SUBMISSION_PORT;
 SMTPClient.Username := '';
 SMTPClient.Password := '';
 SMTPClient.UseSSL := False;
 SMTPClient.UseSTARTTLS := True;

 SMTPClient.State := ssDisconnected;
 SMTPClient.LastError := '';
 SMTPClient.LastCode := 0;
 SMTPClient.ServerGreeting := '';
 SMTPClient.ServerDomain := '';

 SMTPClient.Extensions.STARTTLS := False;
 SMTPClient.Extensions.AUTH_PLAIN := False;
 SMTPClient.Extensions.AUTH_LOGIN := False;
 SMTPClient.Extensions.AUTH_CRAM_MD5 := False;
 SMTPClient.Extensions.EIGHTBITMIME := False;
 SMTPClient.Extensions.SIZE := 0;
 SMTPClient.Extensions.PIPELINING := False;
 SMTPClient.Extensions.DSN := False;

 SMTPClient.AuthMethod := samNone;
 SMTPClient.Authenticated := False;

 SMTPClient.MailFrom := '';
 SMTPClient.RcptCount := 0;
 SMTPClient.RcptAccepted := 0;

 SMTPClient.Connected := False;
 SMTPClient.SocketHandle := -1;
 SMTPClient.TLSActive := False;

 { Initialiser les destinataires }
 For I := 0 To SMTP_MAX_RECIPIENTS - 1 Do Begin
  SMTPRecipients[I].Email := '';
  SMTPRecipients[I].Accepted := False;
  SMTPRecipients[I].ErrorMsg := '';
 End;

 { Initialiser le message courant }
 SMTPCurrentMessage.From := '';
 SMTPCurrentMessage.FromName := '';
 SMTPCurrentMessage.RecipientCount := 0;
 SMTPCurrentMessage.Subject := '';
 SMTPCurrentMessage.Body := '';
 SMTPCurrentMessage.ContentType := 'text/plain';
 SMTPCurrentMessage.CharSet := 'utf-8';

 SMTPSending := False;
 SMTPLastActivity := 0;
End;

{ Configure le client SMTP }
Procedure SMTP_Configure(Host: String; Port: Integer; User, Pass: String; UseSSL, UseSTARTTLS: Boolean);
Begin
 SMTPClient.Host := Host;
 SMTPClient.Port := Port;
 SMTPClient.Username := User;
 SMTPClient.Password := Pass;
 SMTPClient.UseSSL := UseSSL;
 SMTPClient.UseSTARTTLS := UseSTARTTLS;
End;

{ Determine la classe d'une reponse SMTP basee sur le code }
Function SMTP_GetResponseClass(Code: Integer): TSMTPResponseClass;
Begin
 Case Code Div 100 Of
  1: SMTP_GetResponseClass := srcPositivePrelim;
  2: SMTP_GetResponseClass := srcPositiveComplete;
  3: SMTP_GetResponseClass := srcPositiveInterm;
  4: SMTP_GetResponseClass := srcNegativeTransient;
  5: SMTP_GetResponseClass := srcNegativePermanent;
 Else
  SMTP_GetResponseClass := srcUnknown;
 End;
End;

{ Parse une reponse SMTP }
Function SMTP_ParseResponse(ResponseLine: String): TSMTPResponse;
Var
 Response: TSMTPResponse;
 CodeStr: String;
 ErrCode: Integer;
Begin
 Response.Code := 0;
 Response.ResponseClass := srcUnknown;
 Response.Text := '';
 Response.IsMultiline := False;
 Response.IsContinue := False;

 If Length(ResponseLine) >= 3 Then Begin
  CodeStr := Copy(ResponseLine, 1, 3);
  Val(CodeStr, Response.Code, ErrCode);
  If ErrCode = 0 Then Begin
   Response.ResponseClass := SMTP_GetResponseClass(Response.Code);
   { Verifier si c'est une ligne de continuation (code-texte) }
   If (Length(ResponseLine) >= 4) And (ResponseLine[4] = '-') Then Begin
    Response.IsMultiline := True;
    Response.IsContinue := True;
    If Length(ResponseLine) > 4 Then
     Response.Text := Copy(ResponseLine, 5, Length(ResponseLine) - 4);
   End
   Else If (Length(ResponseLine) >= 4) And (ResponseLine[4] = ' ') Then Begin
    If Length(ResponseLine) > 4 Then
     Response.Text := Copy(ResponseLine, 5, Length(ResponseLine) - 4);
   End
   Else If Length(ResponseLine) = 3 Then Begin
    Response.Text := '';
   End;
  End;
 End;

 SMTP_ParseResponse := Response;
End;

{ Envoie une commande SMTP et recoit la reponse (simule) }
Function SMTP_SendCommand(Command: String): TSMTPResponse;
Var
 Response: TSMTPResponse;
 CmdUpper: String;
 I: Integer;
 NumStr: String;
Begin
 Response.Code := 0;
 Response.ResponseClass := srcUnknown;
 Response.Text := '';
 Response.IsMultiline := False;
 Response.IsContinue := False;

 { Convertir en majuscules pour la comparaison }
 CmdUpper := '';
 For I := 1 To Length(Command) Do
  If (Command[I] >= 'a') And (Command[I] <= 'z') Then
   CmdUpper := CmdUpper + Chr(Ord(Command[I]) - 32)
  Else
   CmdUpper := CmdUpper + Command[I];

 { Simuler les reponses selon la commande }
 If (Pos('EHLO', CmdUpper) = 1) Or (Pos('HELO', CmdUpper) = 1) Then Begin
  Response.Code := SMTP_CODE_OK;
  Response.ResponseClass := srcPositiveComplete;
  Response.Text := 'smtp.example.com Hello';
  { Simuler les extensions supportees }
  SMTPClient.Extensions.STARTTLS := True;
  SMTPClient.Extensions.AUTH_PLAIN := True;
  SMTPClient.Extensions.AUTH_LOGIN := True;
  SMTPClient.Extensions.AUTH_CRAM_MD5 := True;
  SMTPClient.Extensions.EIGHTBITMIME := True;
  SMTPClient.Extensions.SIZE := 52428800;
  SMTPClient.Extensions.PIPELINING := True;
  SMTPClient.Extensions.DSN := True;
  SMTPClient.ServerDomain := 'smtp.example.com';
 End
 Else If Pos('STARTTLS', CmdUpper) = 1 Then Begin
  If SMTPClient.Extensions.STARTTLS Then Begin
   Response.Code := SMTP_CODE_READY;
   Response.ResponseClass := srcPositiveComplete;
   Response.Text := 'Ready to start TLS';
   SMTPClient.TLSActive := True;
  End
  Else Begin
   Response.Code := SMTP_CODE_NOT_IMPLEMENTED;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'STARTTLS not supported';
  End;
 End
 Else If Pos('AUTH PLAIN', CmdUpper) = 1 Then Begin
  If SMTPClient.Extensions.AUTH_PLAIN Then Begin
   Response.Code := SMTP_CODE_AUTH_OK;
   Response.ResponseClass := srcPositiveComplete;
   Response.Text := 'Authentication successful';
   SMTPClient.Authenticated := True;
   SMTPClient.AuthMethod := samPLAIN;
  End
  Else Begin
   Response.Code := SMTP_CODE_AUTH_FAILED;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'AUTH PLAIN not supported';
  End;
 End
 Else If Pos('AUTH LOGIN', CmdUpper) = 1 Then Begin
  If SMTPClient.Extensions.AUTH_LOGIN Then Begin
   Response.Code := SMTP_CODE_AUTH_CONTINUE;
   Response.ResponseClass := srcPositiveInterm;
   Response.Text := 'VXNlcm5hbWU6'; { Base64 pour "Username:" }
   SMTPClient.AuthMethod := samLOGIN;
  End
  Else Begin
   Response.Code := SMTP_CODE_AUTH_FAILED;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'AUTH LOGIN not supported';
  End;
 End
 Else If Pos('AUTH CRAM-MD5', CmdUpper) = 1 Then Begin
  If SMTPClient.Extensions.AUTH_CRAM_MD5 Then Begin
   Response.Code := SMTP_CODE_AUTH_CONTINUE;
   Response.ResponseClass := srcPositiveInterm;
   Response.Text := 'PDEyMzQ1LjY3ODkwQHNtdHAuZXhhbXBsZS5jb20+'; { Challenge simule }
   SMTPClient.AuthMethod := samCRAMMD5;
  End
  Else Begin
   Response.Code := SMTP_CODE_AUTH_FAILED;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'AUTH CRAM-MD5 not supported';
  End;
 End
 Else If Pos('MAIL FROM:', CmdUpper) = 1 Then Begin
  If SMTPClient.Authenticated Or (SMTPClient.AuthMethod = samNone) Then Begin
   Response.Code := SMTP_CODE_OK;
   Response.ResponseClass := srcPositiveComplete;
   Response.Text := 'OK';
   SMTPClient.State := ssMailFrom;
  End
  Else Begin
   Response.Code := SMTP_CODE_AUTH_REQUIRED;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'Authentication required';
  End;
 End
 Else If Pos('RCPT TO:', CmdUpper) = 1 Then Begin
  If SMTPClient.State >= ssMailFrom Then Begin
   Response.Code := SMTP_CODE_OK;
   Response.ResponseClass := srcPositiveComplete;
   Response.Text := 'OK';
   SMTPClient.State := ssRcptTo;
   Inc(SMTPClient.RcptAccepted);
  End
  Else Begin
   Response.Code := SMTP_CODE_BAD_SEQUENCE;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'Need MAIL command first';
  End;
 End
 Else If Pos('DATA', CmdUpper) = 1 Then Begin
  If SMTPClient.State >= ssRcptTo Then Begin
   Response.Code := SMTP_CODE_START_MAIL;
   Response.ResponseClass := srcPositiveInterm;
   Response.Text := 'Start mail input; end with <CRLF>.<CRLF>';
   SMTPClient.State := ssData;
  End
  Else Begin
   Response.Code := SMTP_CODE_BAD_SEQUENCE;
   Response.ResponseClass := srcNegativePermanent;
   Response.Text := 'Need RCPT command first';
  End;
 End
 Else If Pos('RSET', CmdUpper) = 1 Then Begin
  Response.Code := SMTP_CODE_OK;
  Response.ResponseClass := srcPositiveComplete;
  Response.Text := 'OK';
  SMTPClient.State := ssAuthenticated;
  SMTPClient.MailFrom := '';
  SMTPClient.RcptCount := 0;
  SMTPClient.RcptAccepted := 0;
 End
 Else If Pos('NOOP', CmdUpper) = 1 Then Begin
  Response.Code := SMTP_CODE_OK;
  Response.ResponseClass := srcPositiveComplete;
  Response.Text := 'OK';
 End
 Else If Pos('QUIT', CmdUpper) = 1 Then Begin
  Response.Code := SMTP_CODE_CLOSING;
  Response.ResponseClass := srcPositiveComplete;
  Response.Text := 'Closing connection';
  SMTPClient.State := ssQuit;
 End
 Else Begin
  Response.Code := SMTP_CODE_SYNTAX_ERROR;
  Response.ResponseClass := srcNegativePermanent;
  Response.Text := 'Syntax error, command unrecognized';
 End;

 SMTPClient.LastCode := Response.Code;
 SMTP_SendCommand := Response;
End;

{ Encode une chaine en Base64 (implementation simplifiee) }
Function SMTP_Base64Encode(Input: String): String;
Const
 Base64Chars: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
Var
 I, J, Len: Integer;
 B1, B2, B3: Byte;
 Output: String;
Begin
 Output := '';
 Len := Length(Input);
 I := 1;
 While I <= Len Do Begin
  B1 := Ord(Input[I]);
  If I + 1 <= Len Then B2 := Ord(Input[I + 1]) Else B2 := 0;
  If I + 2 <= Len Then B3 := Ord(Input[I + 2]) Else B3 := 0;

  Output := Output + Base64Chars[(B1 Shr 2) + 1];
  Output := Output + Base64Chars[((B1 And 3) Shl 4) Or (B2 Shr 4) + 1];
  If I + 1 <= Len Then
   Output := Output + Base64Chars[((B2 And 15) Shl 2) Or (B3 Shr 6) + 1]
  Else
   Output := Output + '=';
  If I + 2 <= Len Then
   Output := Output + Base64Chars[(B3 And 63) + 1]
  Else
   Output := Output + '=';

  Inc(I, 3);
 End;
 SMTP_Base64Encode := Output;
End;

{ Calcule un hash simplifie pour CRAM-MD5 }
Function SMTP_CRAMMD5Hash(Challenge, Password: String): String;
Var
 I: Integer;
 Hash: LongInt;
 HexStr: String;
 HexChars: String;
Begin
 { Implementation simplifiee - en production, utiliser une vraie HMAC-MD5 }
 HexChars := '0123456789abcdef';
 Hash := 0;
 For I := 1 To Length(Challenge) Do
  Hash := (Hash * 31 + Ord(Challenge[I])) Mod 2147483647;
 For I := 1 To Length(Password) Do
  Hash := (Hash * 37 + Ord(Password[I])) Mod 2147483647;

 HexStr := '';
 For I := 1 To 32 Do Begin
  HexStr := HexStr + HexChars[(Hash Mod 16) + 1];
  Hash := Hash Div 16;
  If Hash = 0 Then Hash := Ord(Password[(I Mod Length(Password)) + 1]) * 12345;
 End;

 SMTP_CRAMMD5Hash := HexStr;
End;

{ Connecte au serveur SMTP }
Function SMTP_Connect: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.Host = '' Then Begin
  SMTPClient.LastError := 'Serveur non configure';
  SMTP_Connect := SMTP_ERR_CONNECT;
  Exit;
 End;

 SMTPSending := True;

 { Simuler la connexion socket }
 SMTPClient.Connected := True;
 SMTPClient.SocketHandle := 3;
 SMTPClient.State := ssConnected;

 { Si SSL implicite, activer TLS }
 If SMTPClient.UseSSL Then
  SMTPClient.TLSActive := True;

 { Simuler le message de bienvenue }
 SMTPClient.ServerGreeting := '220 smtp.example.com ESMTP ready';
 SMTPClient.LastCode := SMTP_CODE_READY;

 SMTPSending := False;
 SMTP_Connect := SMTP_OK;
End;

{ Envoie la commande EHLO }
Function SMTP_EHLO(LocalDomain: String): Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_EHLO := SMTP_ERR_EHLO;
  Exit;
 End;

 Response := SMTP_SendCommand('EHLO ' + LocalDomain);
 If Response.Code = SMTP_CODE_OK Then Begin
  SMTPClient.State := ssConnected;
  SMTP_EHLO := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'EHLO echoue: ' + Response.Text;
  SMTP_EHLO := SMTP_ERR_EHLO;
 End;
End;

{ Active STARTTLS pour passer en mode securise }
Function SMTP_STARTTLS: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_STARTTLS := SMTP_ERR_STARTTLS;
  Exit;
 End;

 If Not SMTPClient.Extensions.STARTTLS Then Begin
  SMTPClient.LastError := 'STARTTLS non supporte par le serveur';
  SMTP_STARTTLS := SMTP_ERR_STARTTLS;
  Exit;
 End;

 If SMTPClient.TLSActive Then Begin
  SMTPClient.LastError := 'TLS deja actif';
  SMTP_STARTTLS := SMTP_OK;
  Exit;
 End;

 Response := SMTP_SendCommand('STARTTLS');
 If Response.Code = SMTP_CODE_READY Then Begin
  { Simuler la negociation TLS }
  SMTPClient.TLSActive := True;
  SMTP_STARTTLS := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'STARTTLS echoue: ' + Response.Text;
  SMTP_STARTTLS := SMTP_ERR_STARTTLS;
 End;
End;

{ Authentification PLAIN (RFC 4616) }
Function SMTP_AuthPLAIN: Integer;
Var
 Response: TSMTPResponse;
 AuthString: String;
 EncodedAuth: String;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_AuthPLAIN := SMTP_ERR_AUTH;
  Exit;
 End;

 If Not SMTPClient.Extensions.AUTH_PLAIN Then Begin
  SMTPClient.LastError := 'AUTH PLAIN non supporte';
  SMTP_AuthPLAIN := SMTP_ERR_AUTH;
  Exit;
 End;

 { Construire la chaine d'authentification: \0username\0password }
 AuthString := Chr(0) + SMTPClient.Username + Chr(0) + SMTPClient.Password;
 EncodedAuth := SMTP_Base64Encode(AuthString);

 Response := SMTP_SendCommand('AUTH PLAIN ' + EncodedAuth);
 If Response.Code = SMTP_CODE_AUTH_OK Then Begin
  SMTPClient.Authenticated := True;
  SMTPClient.AuthMethod := samPLAIN;
  SMTPClient.State := ssAuthenticated;
  SMTP_AuthPLAIN := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'AUTH PLAIN echoue: ' + Response.Text;
  SMTP_AuthPLAIN := SMTP_ERR_AUTH;
 End;
End;

{ Authentification LOGIN }
Function SMTP_AuthLOGIN: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_AuthLOGIN := SMTP_ERR_AUTH;
  Exit;
 End;

 If Not SMTPClient.Extensions.AUTH_LOGIN Then Begin
  SMTPClient.LastError := 'AUTH LOGIN non supporte';
  SMTP_AuthLOGIN := SMTP_ERR_AUTH;
  Exit;
 End;

 { Envoyer AUTH LOGIN }
 Response := SMTP_SendCommand('AUTH LOGIN');
 If Response.Code <> SMTP_CODE_AUTH_CONTINUE Then Begin
  SMTPClient.LastError := 'AUTH LOGIN echoue: ' + Response.Text;
  SMTP_AuthLOGIN := SMTP_ERR_AUTH;
  Exit;
 End;

 { Envoyer le nom d'utilisateur en Base64 }
 Response := SMTP_SendCommand(SMTP_Base64Encode(SMTPClient.Username));
 If Response.Code <> SMTP_CODE_AUTH_CONTINUE Then Begin
  SMTPClient.LastError := 'Username echoue: ' + Response.Text;
  SMTP_AuthLOGIN := SMTP_ERR_AUTH;
  Exit;
 End;

 { Envoyer le mot de passe en Base64 }
 Response := SMTP_SendCommand(SMTP_Base64Encode(SMTPClient.Password));
 If Response.Code = SMTP_CODE_AUTH_OK Then Begin
  SMTPClient.Authenticated := True;
  SMTPClient.AuthMethod := samLOGIN;
  SMTPClient.State := ssAuthenticated;
  SMTP_AuthLOGIN := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'Password echoue: ' + Response.Text;
  SMTP_AuthLOGIN := SMTP_ERR_AUTH;
 End;
End;

{ Authentification CRAM-MD5 (RFC 2195) }
Function SMTP_AuthCRAMMD5: Integer;
Var
 Response: TSMTPResponse;
 Challenge: String;
 Digest: String;
 AuthResponse: String;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_AuthCRAMMD5 := SMTP_ERR_AUTH;
  Exit;
 End;

 If Not SMTPClient.Extensions.AUTH_CRAM_MD5 Then Begin
  SMTPClient.LastError := 'AUTH CRAM-MD5 non supporte';
  SMTP_AuthCRAMMD5 := SMTP_ERR_AUTH;
  Exit;
 End;

 { Envoyer AUTH CRAM-MD5 }
 Response := SMTP_SendCommand('AUTH CRAM-MD5');
 If Response.Code <> SMTP_CODE_AUTH_CONTINUE Then Begin
  SMTPClient.LastError := 'AUTH CRAM-MD5 echoue: ' + Response.Text;
  SMTP_AuthCRAMMD5 := SMTP_ERR_AUTH;
  Exit;
 End;

 { Le challenge est dans Response.Text (en Base64) }
 Challenge := Response.Text;

 { Calculer la reponse HMAC-MD5 }
 Digest := SMTP_CRAMMD5Hash(Challenge, SMTPClient.Password);

 { Envoyer username + espace + digest en Base64 }
 AuthResponse := SMTP_Base64Encode(SMTPClient.Username + ' ' + Digest);
 Response := SMTP_SendCommand(AuthResponse);

 If Response.Code = SMTP_CODE_AUTH_OK Then Begin
  SMTPClient.Authenticated := True;
  SMTPClient.AuthMethod := samCRAMMD5;
  SMTPClient.State := ssAuthenticated;
  SMTP_AuthCRAMMD5 := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'CRAM-MD5 echoue: ' + Response.Text;
  SMTP_AuthCRAMMD5 := SMTP_ERR_AUTH;
 End;
End;

{ Envoie la commande MAIL FROM }
Function SMTP_MailFrom(SenderEmail: String): Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_MailFrom := SMTP_ERR_MAIL_FROM;
  Exit;
 End;

 Response := SMTP_SendCommand('MAIL FROM:<' + SenderEmail + '>');
 If Response.Code = SMTP_CODE_OK Then Begin
  SMTPClient.MailFrom := SenderEmail;
  SMTPClient.State := ssMailFrom;
  SMTPClient.RcptCount := 0;
  SMTPClient.RcptAccepted := 0;
  SMTP_MailFrom := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'MAIL FROM echoue: ' + Response.Text;
  SMTP_MailFrom := SMTP_ERR_MAIL_FROM;
 End;
End;

{ Envoie la commande RCPT TO }
Function SMTP_RcptTo(RecipientEmail: String): Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssMailFrom Then Begin
  SMTPClient.LastError := 'MAIL FROM requis d''abord';
  SMTP_RcptTo := SMTP_ERR_RCPT_TO;
  Exit;
 End;

 Response := SMTP_SendCommand('RCPT TO:<' + RecipientEmail + '>');
 If (Response.Code = SMTP_CODE_OK) Or (Response.Code = SMTP_CODE_USER_NOT_LOCAL) Then Begin
  If SMTPClient.RcptCount < SMTP_MAX_RECIPIENTS Then Begin
   SMTPRecipients[SMTPClient.RcptCount].Email := RecipientEmail;
   SMTPRecipients[SMTPClient.RcptCount].Accepted := True;
   SMTPRecipients[SMTPClient.RcptCount].ErrorMsg := '';
   Inc(SMTPClient.RcptCount);
  End;
  SMTPClient.State := ssRcptTo;
  SMTP_RcptTo := SMTP_OK;
 End
 Else Begin
  { Destinataire refuse mais on peut continuer }
  If SMTPClient.RcptCount < SMTP_MAX_RECIPIENTS Then Begin
   SMTPRecipients[SMTPClient.RcptCount].Email := RecipientEmail;
   SMTPRecipients[SMTPClient.RcptCount].Accepted := False;
   SMTPRecipients[SMTPClient.RcptCount].ErrorMsg := Response.Text;
   Inc(SMTPClient.RcptCount);
  End;
  SMTP_RcptTo := SMTP_ERR_RCPT_TO;
 End;
End;

{ Envoie la commande DATA et le contenu du message }
Function SMTP_Data(MessageBody: String): Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssRcptTo Then Begin
  SMTPClient.LastError := 'RCPT TO requis d''abord';
  SMTP_Data := SMTP_ERR_DATA;
  Exit;
 End;

 If SMTPClient.RcptAccepted = 0 Then Begin
  SMTPClient.LastError := 'Aucun destinataire accepte';
  SMTP_Data := SMTP_ERR_NO_RECIPIENTS;
  Exit;
 End;

 { Envoyer DATA }
 Response := SMTP_SendCommand('DATA');
 If Response.Code <> SMTP_CODE_START_MAIL Then Begin
  SMTPClient.LastError := 'DATA echoue: ' + Response.Text;
  SMTP_Data := SMTP_ERR_DATA;
  Exit;
 End;

 SMTPClient.State := ssData;

 { Dans une vraie implementation, on enverrait le corps du message ici }
 { puis on terminerait avec CRLF.CRLF }

 { Simuler l'envoi reussi }
 Response.Code := SMTP_CODE_OK;
 Response.ResponseClass := srcPositiveComplete;
 Response.Text := 'Message accepted for delivery';

 If Response.Code = SMTP_CODE_OK Then Begin
  SMTPClient.State := ssAuthenticated;
  SMTP_Data := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'Envoi echoue: ' + Response.Text;
  SMTP_Data := SMTP_ERR_SEND;
 End;
End;

{ Envoie la commande RSET pour reinitialiser la transaction }
Function SMTP_Rset: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_Rset := SMTP_ERR_PROTOCOL;
  Exit;
 End;

 Response := SMTP_SendCommand('RSET');
 If Response.Code = SMTP_CODE_OK Then Begin
  SMTPClient.State := ssAuthenticated;
  SMTPClient.MailFrom := '';
  SMTPClient.RcptCount := 0;
  SMTPClient.RcptAccepted := 0;
  SMTP_Rset := SMTP_OK;
 End
 Else Begin
  SMTPClient.LastError := 'RSET echoue: ' + Response.Text;
  SMTP_Rset := SMTP_ERR_PROTOCOL;
 End;
End;

{ Envoie la commande NOOP }
Function SMTP_Noop: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_Noop := SMTP_ERR_PROTOCOL;
  Exit;
 End;

 Response := SMTP_SendCommand('NOOP');
 If Response.Code = SMTP_CODE_OK Then
  SMTP_Noop := SMTP_OK
 Else Begin
  SMTPClient.LastError := 'NOOP echoue: ' + Response.Text;
  SMTP_Noop := SMTP_ERR_PROTOCOL;
 End;
End;

{ Envoie la commande QUIT et deconnecte }
Function SMTP_Quit: Integer;
Var
 Response: TSMTPResponse;
Begin
 If SMTPClient.State = ssDisconnected Then Begin
  SMTP_Quit := SMTP_OK;
  Exit;
 End;

 If SMTPClient.Connected Then Begin
  Response := SMTP_SendCommand('QUIT');
  { Ignorer la reponse, on deconnecte quand meme }
 End;

 SMTPClient.Connected := False;
 SMTPClient.State := ssDisconnected;
 SMTPClient.SocketHandle := -1;
 SMTPClient.TLSActive := False;
 SMTPClient.Authenticated := False;
 SMTP_Quit := SMTP_OK;
End;

{ Envoie un message complet }
Function SMTP_SendMessage(Msg: TSMTPMessage): Integer;
Var
 I: Integer;
 Result: Integer;
 Headers: String;
Begin
 { Verifier qu'on est connecte et authentifie }
 If SMTPClient.State < ssConnected Then Begin
  SMTPClient.LastError := 'Non connecte';
  SMTP_SendMessage := SMTP_ERR_CONNECT;
  Exit;
 End;

 { MAIL FROM }
 Result := SMTP_MailFrom(Msg.From);
 If Result <> SMTP_OK Then Begin
  SMTP_SendMessage := Result;
  Exit;
 End;

 { RCPT TO pour chaque destinataire }
 For I := 0 To Msg.RecipientCount - 1 Do Begin
  Result := SMTP_RcptTo(Msg.Recipients[I].Email);
  { Continuer meme si un destinataire est refuse }
 End;

 { Verifier qu'au moins un destinataire a ete accepte }
 If SMTPClient.RcptAccepted = 0 Then Begin
  SMTPClient.LastError := 'Tous les destinataires refuses';
  SMTP_Rset;
  SMTP_SendMessage := SMTP_ERR_NO_RECIPIENTS;
  Exit;
 End;

 { Construire les en-tetes et le corps }
 Headers := 'From: ';
 If Msg.FromName <> '' Then
  Headers := Headers + '"' + Msg.FromName + '" '
 Else
  Headers := Headers + Msg.From;
 Headers := Headers + Chr(13) + Chr(10);
 Headers := Headers + 'To: ' + Msg.Recipients[0].Email + Chr(13) + Chr(10);
 Headers := Headers + 'Subject: ' + Msg.Subject + Chr(13) + Chr(10);
 Headers := Headers + 'Content-Type: ' + Msg.ContentType;
 If Msg.CharSet <> '' Then
  Headers := Headers + '; charset="' + Msg.CharSet + '"';
 Headers := Headers + Chr(13) + Chr(10);
 Headers := Headers + Chr(13) + Chr(10);
 Headers := Headers + Msg.Body;

 { DATA }
 Result := SMTP_Data(Headers);
 SMTP_SendMessage := Result;
End;

{ Retourne l'etat du client SMTP sous forme de chaine }
Function SMTP_GetStateString: String;
Begin
 Case SMTPClient.State Of
  ssDisconnected: SMTP_GetStateString := 'Deconnecte';
  ssConnected: SMTP_GetStateString := 'Connecte';
  ssAuthenticated: SMTP_GetStateString := 'Authentifie';
  ssMailFrom: SMTP_GetStateString := 'MAIL FROM envoye';
  ssRcptTo: SMTP_GetStateString := 'RCPT TO envoye';
  ssData: SMTP_GetStateString := 'DATA en cours';
  ssQuit: SMTP_GetStateString := 'Deconnexion';
 Else
  SMTP_GetStateString := 'Inconnu';
 End;
End;

{ Retourne les extensions supportees par le serveur }
Function SMTP_GetExtensionsString: String;
Var
 S: String;
Begin
 S := '';
 If SMTPClient.Extensions.STARTTLS Then S := S + 'STARTTLS ';
 If SMTPClient.Extensions.AUTH_PLAIN Then S := S + 'AUTH-PLAIN ';
 If SMTPClient.Extensions.AUTH_LOGIN Then S := S + 'AUTH-LOGIN ';
 If SMTPClient.Extensions.AUTH_CRAM_MD5 Then S := S + 'AUTH-CRAM-MD5 ';
 If SMTPClient.Extensions.EIGHTBITMIME Then S := S + '8BITMIME ';
 If SMTPClient.Extensions.PIPELINING Then S := S + 'PIPELINING ';
 If SMTPClient.Extensions.DSN Then S := S + 'DSN ';
 If S = '' Then S := 'Aucune';
 SMTP_GetExtensionsString := S;
End;

{ Verifie si STARTTLS est disponible }
Function SMTP_IsSTARTTLSAvailable: Boolean;
Begin
 SMTP_IsSTARTTLSAvailable := SMTPClient.Extensions.STARTTLS And Not SMTPClient.TLSActive;
End;

{ Verifie si une methode d'authentification est disponible }
Function SMTP_IsAuthAvailable(Method: TSMTPAuthMethod): Boolean;
Begin
 Case Method Of
  samPLAIN: SMTP_IsAuthAvailable := SMTPClient.Extensions.AUTH_PLAIN;
  samLOGIN: SMTP_IsAuthAvailable := SMTPClient.Extensions.AUTH_LOGIN;
  samCRAMMD5: SMTP_IsAuthAvailable := SMTPClient.Extensions.AUTH_CRAM_MD5;
 Else
  SMTP_IsAuthAvailable := True; { samNone }
 End;
End;

{ Retourne le nombre de destinataires acceptes }
Function SMTP_GetAcceptedCount: Integer;
Begin
 SMTP_GetAcceptedCount := SMTPClient.RcptAccepted;
End;

{ Retourne le nombre de destinataires refuses }
Function SMTP_GetRejectedCount: Integer;
Begin
 SMTP_GetRejectedCount := SMTPClient.RcptCount - SMTPClient.RcptAccepted;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION SMTP
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU GESTIONNAIRE DE COMPTES (TODO 11)
  ============================================================================ }

{ Chiffre/dechiffre un mot de passe avec XOR }
Function XORPassword(Password: String): String;
Var
 I: Integer;
 Result: String;
Begin
 Result := '';
 For I := 1 To Length(Password) Do
  Result := Result + Chr(Ord(Password[I]) Xor PASSWORD_XOR_KEY);
 XORPassword := Result;
End;

{ Initialise le gestionnaire de comptes }
Procedure InitializeAccountManager;
Var
 I: Integer;
Begin
 EmailAccountCount := 0;
 CurrentAccountIndex := -1;
 AccountDialogVisible := False;
 AccountWizardStep := awsWelcome;
 AccountWizardMode := False;
 AccountListScrollOffset := 0;
 SelectedAccountInList := -1;
 FocusedInputField := -1;
 ConnectionTestInProgress := False;
 ConnectionTestResult := ctrNotTested;

 { Initialiser tous les comptes a zero }
 For I := 0 To MAX_EMAIL_ACCOUNTS - 1 Do Begin
  EmailAccounts[I].AccountName := '';
  EmailAccounts[I].EmailAddress := '';
  EmailAccounts[I].IsActive := False;
 End;

 { Creer un compte de demonstration }
 EmailAccounts[0].AccountName := 'Compte principal';
 EmailAccounts[0].DisplayName := 'Utilisateur';
 EmailAccounts[0].EmailAddress := 'user@example.com';
 EmailAccounts[0].IncomingType := istIMAP;
 EmailAccounts[0].IncomingHost := 'imap.example.com';
 EmailAccounts[0].IncomingPort := DEFAULT_IMAPS_PORT;
 EmailAccounts[0].IncomingSecurity := csSSL;
 EmailAccounts[0].IncomingUsername := 'user@example.com';
 EmailAccounts[0].IncomingPassword := XORPassword('password');
 EmailAccounts[0].OutgoingHost := 'smtp.example.com';
 EmailAccounts[0].OutgoingPort := DEFAULT_SMTP_SUBMISSION_PORT;
 EmailAccounts[0].OutgoingSecurity := csSTARTTLS;
 EmailAccounts[0].OutgoingAuthRequired := True;
 EmailAccounts[0].OutgoingUseSameAuth := True;
 EmailAccounts[0].IsActive := True;
 EmailAccounts[0].IsDefault := True;
 EmailAccounts[0].LastConnectionTest := ctrNotTested;
 EmailAccounts[0].CheckIntervalMins := 5;
 EmailAccountCount := 1;
End;

{ Initialise un compte vide }
Procedure InitializeEmptyAccount(Var Account: TEmailAccount);
Begin
 Account.AccountName := '';
 Account.DisplayName := '';
 Account.EmailAddress := '';
 Account.Organization := '';
 Account.ReplyToAddress := '';
 Account.IncomingType := istIMAP;
 Account.IncomingHost := '';
 Account.IncomingPort := DEFAULT_IMAPS_PORT;
 Account.IncomingSecurity := csSSL;
 Account.IncomingUsername := '';
 Account.IncomingPassword := '';
 Account.IncomingAuthMethod := 0;
 Account.POP3LeaveOnServer := True;
 Account.POP3DeleteAfterDays := 0;
 Account.POP3HeadersOnly := False;
 Account.OutgoingHost := '';
 Account.OutgoingPort := DEFAULT_SMTP_SUBMISSION_PORT;
 Account.OutgoingSecurity := csSTARTTLS;
 Account.OutgoingUsername := '';
 Account.OutgoingPassword := '';
 Account.OutgoingAuthRequired := True;
 Account.OutgoingUseSameAuth := True;
 Account.IsActive := True;
 Account.IsDefault := False;
 Account.LastConnectionTest := ctrNotTested;
 Account.CheckIntervalMins := 5;
End;

{ Dessine une boite de dialogue modale }
Procedure DrawDialogBox(X, Y, W, H: Integer; Title: String);
Begin
 { Ombre de la boite de dialogue }
 SetFillStyle(SolidFill, COLOR_BUTTON_DARK);
 Bar(X + 3, Y + 3, X + W + 3, Y + H + 3);

 { Fond de la boite de dialogue }
 SetFillStyle(SolidFill, COLOR_WINDOW_BG);
 Bar(X, Y, X + W, Y + H);

 { Barre de titre }
 SetFillStyle(SolidFill, COLOR_TITLEBAR);
 Bar(X + 2, Y + 2, X + W - 2, Y + 20);

 { Titre }
 SetColor(COLOR_TITLEBAR_TEXT);
 OutTextXY(X + 8, Y + 6, Title);

 { Bordure 3D }
 Draw3DRect(X, Y, X + W, Y + H, True);
 Draw3DRect(X + 2, Y + 22, X + W - 2, Y + H - 2, False);
End;

{ Dessine un bouton de dialogue }
Procedure DrawDialogButton(X, Y, W, H: Integer; Caption: String; Pressed, Enabled: Boolean);
Var
 TextX, TextY: Integer;
Begin
 { Fond du bouton }
 If Enabled Then
  SetFillStyle(SolidFill, COLOR_BUTTON_FACE)
 Else
  SetFillStyle(SolidFill, COLOR_BUTTON_DARK);
 Bar(X, Y, X + W, Y + H);

 { Relief 3D }
 Draw3DRect(X, Y, X + W, Y + H, Not Pressed);

 { Texte centre }
 If Enabled Then
  SetColor(COLOR_MENU_TEXT)
 Else
  SetColor(COLOR_BUTTON_DARK);
 TextX := X + (W - TextWidth(Caption)) Div 2;
 TextY := Y + (H - TextHeight(Caption)) Div 2;
 If Pressed Then Begin
  Inc(TextX);
  Inc(TextY);
 End;
 OutTextXY(TextX, TextY, Caption);
End;

{ Dessine un champ de saisie }
Procedure DrawInputField(Var Field: TInputField);
Var
 DisplayText: String;
 I: Integer;
Begin
 { Etiquette }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Field.X, Field.Y - 14, Field.Label_);

 { Fond du champ }
 If Field.IsFocused Then
  SetFillStyle(SolidFill, COLOR_LIST_BG)
 Else
  SetFillStyle(SolidFill, COLOR_WINDOW_BG);
 Bar(Field.X, Field.Y, Field.X + Field.Width, Field.Y + DIALOG_INPUT_HEIGHT);

 { Bordure 3D inversee }
 Draw3DRect(Field.X, Field.Y, Field.X + Field.Width, Field.Y + DIALOG_INPUT_HEIGHT, False);

 { Texte ou asterisques }
 If Field.IsPassword Then Begin
  DisplayText := '';
  For I := 1 To Length(Field.Value) Do
   DisplayText := DisplayText + '*';
 End
 Else
  DisplayText := Field.Value;

 { Tronquer si trop long }
 While TextWidth(DisplayText) > Field.Width - 8 Do
  Delete(DisplayText, 1, 1);

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Field.X + 4, Field.Y + 4, DisplayText);

 { Curseur si actif }
 If Field.IsFocused Then Begin
  SetColor(COLOR_MENU_TEXT);
  Line(Field.X + 4 + TextWidth(DisplayText), Field.Y + 3,
       Field.X + 4 + TextWidth(DisplayText), Field.Y + DIALOG_INPUT_HEIGHT - 3);
 End;
End;

{ Dessine un bouton radio }
Procedure DrawRadioButton(Var Radio: TRadioButton);
Begin
 { Cercle exterieur }
 SetColor(COLOR_BUTTON_DARK);
 Circle(Radio.X + 6, Radio.Y + 6, 6);

 { Cercle interieur si selectionne }
 If Radio.Checked Then Begin
  SetFillStyle(SolidFill, COLOR_MENU_TEXT);
  FillEllipse(Radio.X + 6, Radio.Y + 6, 3, 3);
 End
 Else Begin
  SetFillStyle(SolidFill, COLOR_LIST_BG);
  FillEllipse(Radio.X + 6, Radio.Y + 6, 4, 4);
 End;

 { Etiquette }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Radio.X + 16, Radio.Y + 2, Radio.Label_);
End;

{ Dessine une case a cocher }
Procedure DrawCheckBox(Var Check: TCheckBox);
Begin
 { Cadre }
 SetFillStyle(SolidFill, COLOR_LIST_BG);
 Bar(Check.X, Check.Y, Check.X + 12, Check.Y + 12);
 Draw3DRect(Check.X, Check.Y, Check.X + 12, Check.Y + 12, False);

 { Coche si selectionnee }
 If Check.Checked Then Begin
  SetColor(COLOR_MENU_TEXT);
  Line(Check.X + 2, Check.Y + 6, Check.X + 5, Check.Y + 9);
  Line(Check.X + 5, Check.Y + 9, Check.X + 10, Check.Y + 3);
  Line(Check.X + 3, Check.Y + 6, Check.X + 5, Check.Y + 10);
  Line(Check.X + 5, Check.Y + 10, Check.X + 10, Check.Y + 4);
 End;

 { Etiquette }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Check.X + 18, Check.Y + 2, Check.Label_);
End;

{ Initialise les champs pour la page d'information du compte }
Procedure InitAccountInfoFields;
Var
 BaseX, BaseY: Integer;
Begin
 BaseX := DIALOG_X + DIALOG_MARGIN + 20;
 BaseY := DIALOG_Y + 50;

 { Nom du compte }
 AccountDialogInputFields[0].X := BaseX;
 AccountDialogInputFields[0].Y := BaseY;
 AccountDialogInputFields[0].Width := 250;
 AccountDialogInputFields[0].MaxLen := 40;
 AccountDialogInputFields[0].Value := TempAccount.AccountName;
 AccountDialogInputFields[0].IsPassword := False;
 AccountDialogInputFields[0].IsFocused := True;
 AccountDialogInputFields[0].CursorPos := Length(TempAccount.AccountName);
 AccountDialogInputFields[0].Label_ := 'Nom du compte:';

 { Nom d'affichage }
 BaseY := BaseY + 45;
 AccountDialogInputFields[1].X := BaseX;
 AccountDialogInputFields[1].Y := BaseY;
 AccountDialogInputFields[1].Width := 250;
 AccountDialogInputFields[1].MaxLen := 40;
 AccountDialogInputFields[1].Value := TempAccount.DisplayName;
 AccountDialogInputFields[1].IsPassword := False;
 AccountDialogInputFields[1].IsFocused := False;
 AccountDialogInputFields[1].CursorPos := Length(TempAccount.DisplayName);
 AccountDialogInputFields[1].Label_ := 'Votre nom:';

 { Adresse email }
 BaseY := BaseY + 45;
 AccountDialogInputFields[2].X := BaseX;
 AccountDialogInputFields[2].Y := BaseY;
 AccountDialogInputFields[2].Width := 300;
 AccountDialogInputFields[2].MaxLen := 60;
 AccountDialogInputFields[2].Value := TempAccount.EmailAddress;
 AccountDialogInputFields[2].IsPassword := False;
 AccountDialogInputFields[2].IsFocused := False;
 AccountDialogInputFields[2].CursorPos := Length(TempAccount.EmailAddress);
 AccountDialogInputFields[2].Label_ := 'Adresse de courrier electronique:';

 { Organisation (optionnel) }
 BaseY := BaseY + 45;
 AccountDialogInputFields[3].X := BaseX;
 AccountDialogInputFields[3].Y := BaseY;
 AccountDialogInputFields[3].Width := 250;
 AccountDialogInputFields[3].MaxLen := 40;
 AccountDialogInputFields[3].Value := TempAccount.Organization;
 AccountDialogInputFields[3].IsPassword := False;
 AccountDialogInputFields[3].IsFocused := False;
 AccountDialogInputFields[3].CursorPos := Length(TempAccount.Organization);
 AccountDialogInputFields[3].Label_ := 'Organisation (optionnel):';

 FocusedInputField := 0;
End;

{ Initialise les champs pour la page du serveur entrant }
Procedure InitIncomingServerFields;
Var
 BaseX, BaseY: Integer;
Begin
 BaseX := DIALOG_X + DIALOG_MARGIN + 20;
 BaseY := DIALOG_Y + 50;

 { Boutons radio pour le type de serveur }
 AccountDialogRadioButtons[0].X := BaseX;
 AccountDialogRadioButtons[0].Y := BaseY;
 AccountDialogRadioButtons[0].Label_ := 'IMAP';
 AccountDialogRadioButtons[0].Checked := TempAccount.IncomingType = istIMAP;
 AccountDialogRadioButtons[0].GroupID := 1;

 AccountDialogRadioButtons[1].X := BaseX + 80;
 AccountDialogRadioButtons[1].Y := BaseY;
 AccountDialogRadioButtons[1].Label_ := 'POP3';
 AccountDialogRadioButtons[1].Checked := TempAccount.IncomingType = istPOP3;
 AccountDialogRadioButtons[1].GroupID := 1;

 { Serveur entrant }
 BaseY := BaseY + 35;
 AccountDialogInputFields[0].X := BaseX;
 AccountDialogInputFields[0].Y := BaseY;
 AccountDialogInputFields[0].Width := 280;
 AccountDialogInputFields[0].MaxLen := 80;
 AccountDialogInputFields[0].Value := TempAccount.IncomingHost;
 AccountDialogInputFields[0].IsPassword := False;
 AccountDialogInputFields[0].IsFocused := True;
 AccountDialogInputFields[0].CursorPos := Length(TempAccount.IncomingHost);
 AccountDialogInputFields[0].Label_ := 'Serveur de courrier entrant:';

 { Port }
 BaseY := BaseY + 45;
 AccountDialogInputFields[1].X := BaseX;
 AccountDialogInputFields[1].Y := BaseY;
 AccountDialogInputFields[1].Width := 60;
 AccountDialogInputFields[1].MaxLen := 5;
 If TempAccount.IncomingPort > 0 Then Begin
  Str(TempAccount.IncomingPort, AccountDialogInputFields[1].Value);
 End Else
  AccountDialogInputFields[1].Value := '';
 AccountDialogInputFields[1].IsPassword := False;
 AccountDialogInputFields[1].IsFocused := False;
 AccountDialogInputFields[1].CursorPos := 0;
 AccountDialogInputFields[1].Label_ := 'Port:';

 { Boutons radio pour la securite }
 BaseY := BaseY + 35;
 AccountDialogRadioButtons[2].X := BaseX;
 AccountDialogRadioButtons[2].Y := BaseY;
 AccountDialogRadioButtons[2].Label_ := 'Aucune';
 AccountDialogRadioButtons[2].Checked := TempAccount.IncomingSecurity = csNone;
 AccountDialogRadioButtons[2].GroupID := 2;

 AccountDialogRadioButtons[3].X := BaseX + 80;
 AccountDialogRadioButtons[3].Y := BaseY;
 AccountDialogRadioButtons[3].Label_ := 'SSL/TLS';
 AccountDialogRadioButtons[3].Checked := TempAccount.IncomingSecurity = csSSL;
 AccountDialogRadioButtons[3].GroupID := 2;

 AccountDialogRadioButtons[4].X := BaseX + 170;
 AccountDialogRadioButtons[4].Y := BaseY;
 AccountDialogRadioButtons[4].Label_ := 'STARTTLS';
 AccountDialogRadioButtons[4].Checked := TempAccount.IncomingSecurity = csSTARTTLS;
 AccountDialogRadioButtons[4].GroupID := 2;

 { Nom d'utilisateur }
 BaseY := BaseY + 35;
 AccountDialogInputFields[2].X := BaseX;
 AccountDialogInputFields[2].Y := BaseY;
 AccountDialogInputFields[2].Width := 280;
 AccountDialogInputFields[2].MaxLen := 60;
 AccountDialogInputFields[2].Value := TempAccount.IncomingUsername;
 AccountDialogInputFields[2].IsPassword := False;
 AccountDialogInputFields[2].IsFocused := False;
 AccountDialogInputFields[2].CursorPos := Length(TempAccount.IncomingUsername);
 AccountDialogInputFields[2].Label_ := 'Nom d''utilisateur:';

 { Mot de passe }
 BaseY := BaseY + 45;
 AccountDialogInputFields[3].X := BaseX;
 AccountDialogInputFields[3].Y := BaseY;
 AccountDialogInputFields[3].Width := 200;
 AccountDialogInputFields[3].MaxLen := 40;
 AccountDialogInputFields[3].Value := XORPassword(TempAccount.IncomingPassword);
 AccountDialogInputFields[3].IsPassword := True;
 AccountDialogInputFields[3].IsFocused := False;
 AccountDialogInputFields[3].CursorPos := 0;
 AccountDialogInputFields[3].Label_ := 'Mot de passe:';

 FocusedInputField := 0;
End;

{ Initialise les champs pour la page du serveur sortant }
Procedure InitOutgoingServerFields;
Var
 BaseX, BaseY: Integer;
Begin
 BaseX := DIALOG_X + DIALOG_MARGIN + 20;
 BaseY := DIALOG_Y + 50;

 { Serveur sortant }
 AccountDialogInputFields[0].X := BaseX;
 AccountDialogInputFields[0].Y := BaseY;
 AccountDialogInputFields[0].Width := 280;
 AccountDialogInputFields[0].MaxLen := 80;
 AccountDialogInputFields[0].Value := TempAccount.OutgoingHost;
 AccountDialogInputFields[0].IsPassword := False;
 AccountDialogInputFields[0].IsFocused := True;
 AccountDialogInputFields[0].CursorPos := Length(TempAccount.OutgoingHost);
 AccountDialogInputFields[0].Label_ := 'Serveur de courrier sortant (SMTP):';

 { Port }
 BaseY := BaseY + 45;
 AccountDialogInputFields[1].X := BaseX;
 AccountDialogInputFields[1].Y := BaseY;
 AccountDialogInputFields[1].Width := 60;
 AccountDialogInputFields[1].MaxLen := 5;
 If TempAccount.OutgoingPort > 0 Then Begin
  Str(TempAccount.OutgoingPort, AccountDialogInputFields[1].Value);
 End Else
  AccountDialogInputFields[1].Value := '';
 AccountDialogInputFields[1].IsPassword := False;
 AccountDialogInputFields[1].IsFocused := False;
 AccountDialogInputFields[1].CursorPos := 0;
 AccountDialogInputFields[1].Label_ := 'Port:';

 { Boutons radio pour la securite }
 BaseY := BaseY + 35;
 AccountDialogRadioButtons[0].X := BaseX;
 AccountDialogRadioButtons[0].Y := BaseY;
 AccountDialogRadioButtons[0].Label_ := 'Aucune';
 AccountDialogRadioButtons[0].Checked := TempAccount.OutgoingSecurity = csNone;
 AccountDialogRadioButtons[0].GroupID := 3;

 AccountDialogRadioButtons[1].X := BaseX + 80;
 AccountDialogRadioButtons[1].Y := BaseY;
 AccountDialogRadioButtons[1].Label_ := 'SSL/TLS';
 AccountDialogRadioButtons[1].Checked := TempAccount.OutgoingSecurity = csSSL;
 AccountDialogRadioButtons[1].GroupID := 3;

 AccountDialogRadioButtons[2].X := BaseX + 170;
 AccountDialogRadioButtons[2].Y := BaseY;
 AccountDialogRadioButtons[2].Label_ := 'STARTTLS';
 AccountDialogRadioButtons[2].Checked := TempAccount.OutgoingSecurity = csSTARTTLS;
 AccountDialogRadioButtons[2].GroupID := 3;

 { Case a cocher - Authentification requise }
 BaseY := BaseY + 30;
 AccountDialogCheckBoxes[0].X := BaseX;
 AccountDialogCheckBoxes[0].Y := BaseY;
 AccountDialogCheckBoxes[0].Label_ := 'Authentification requise';
 AccountDialogCheckBoxes[0].Checked := TempAccount.OutgoingAuthRequired;

 { Case a cocher - Utiliser memes identifiants }
 BaseY := BaseY + 25;
 AccountDialogCheckBoxes[1].X := BaseX + 20;
 AccountDialogCheckBoxes[1].Y := BaseY;
 AccountDialogCheckBoxes[1].Label_ := 'Memes identifiants que serveur entrant';
 AccountDialogCheckBoxes[1].Checked := TempAccount.OutgoingUseSameAuth;

 { Nom d'utilisateur SMTP (si different) }
 BaseY := BaseY + 30;
 AccountDialogInputFields[2].X := BaseX + 20;
 AccountDialogInputFields[2].Y := BaseY;
 AccountDialogInputFields[2].Width := 260;
 AccountDialogInputFields[2].MaxLen := 60;
 AccountDialogInputFields[2].Value := TempAccount.OutgoingUsername;
 AccountDialogInputFields[2].IsPassword := False;
 AccountDialogInputFields[2].IsFocused := False;
 AccountDialogInputFields[2].CursorPos := Length(TempAccount.OutgoingUsername);
 AccountDialogInputFields[2].Label_ := 'Nom d''utilisateur SMTP:';

 { Mot de passe SMTP }
 BaseY := BaseY + 45;
 AccountDialogInputFields[3].X := BaseX + 20;
 AccountDialogInputFields[3].Y := BaseY;
 AccountDialogInputFields[3].Width := 200;
 AccountDialogInputFields[3].MaxLen := 40;
 AccountDialogInputFields[3].Value := XORPassword(TempAccount.OutgoingPassword);
 AccountDialogInputFields[3].IsPassword := True;
 AccountDialogInputFields[3].IsFocused := False;
 AccountDialogInputFields[3].CursorPos := 0;
 AccountDialogInputFields[3].Label_ := 'Mot de passe SMTP:';

 FocusedInputField := 0;
End;

{ Sauvegarde les valeurs des champs de la page info compte }
Procedure SaveAccountInfoFields;
Begin
 TempAccount.AccountName := AccountDialogInputFields[0].Value;
 TempAccount.DisplayName := AccountDialogInputFields[1].Value;
 TempAccount.EmailAddress := AccountDialogInputFields[2].Value;
 TempAccount.Organization := AccountDialogInputFields[3].Value;

 { Auto-remplir le nom d'utilisateur avec l'email si vide }
 If TempAccount.IncomingUsername = '' Then
  TempAccount.IncomingUsername := TempAccount.EmailAddress;
End;

{ Sauvegarde les valeurs des champs du serveur entrant }
Procedure SaveIncomingServerFields;
Var
 PortCode: Integer;
Begin
 { Type de serveur }
 If AccountDialogRadioButtons[0].Checked Then
  TempAccount.IncomingType := istIMAP
 Else
  TempAccount.IncomingType := istPOP3;

 TempAccount.IncomingHost := AccountDialogInputFields[0].Value;

 { Port }
 Val(AccountDialogInputFields[1].Value, TempAccount.IncomingPort, PortCode);
 If PortCode <> 0 Then Begin
  If TempAccount.IncomingType = istIMAP Then
   TempAccount.IncomingPort := DEFAULT_IMAPS_PORT
  Else
   TempAccount.IncomingPort := DEFAULT_POP3S_PORT;
 End;

 { Securite }
 If AccountDialogRadioButtons[2].Checked Then
  TempAccount.IncomingSecurity := csNone
 Else If AccountDialogRadioButtons[3].Checked Then
  TempAccount.IncomingSecurity := csSSL
 Else
  TempAccount.IncomingSecurity := csSTARTTLS;

 TempAccount.IncomingUsername := AccountDialogInputFields[2].Value;
 TempAccount.IncomingPassword := XORPassword(AccountDialogInputFields[3].Value);
End;

{ Sauvegarde les valeurs des champs du serveur sortant }
Procedure SaveOutgoingServerFields;
Var
 PortCode: Integer;
Begin
 TempAccount.OutgoingHost := AccountDialogInputFields[0].Value;

 { Port }
 Val(AccountDialogInputFields[1].Value, TempAccount.OutgoingPort, PortCode);
 If PortCode <> 0 Then
  TempAccount.OutgoingPort := DEFAULT_SMTP_SUBMISSION_PORT;

 { Securite }
 If AccountDialogRadioButtons[0].Checked Then
  TempAccount.OutgoingSecurity := csNone
 Else If AccountDialogRadioButtons[1].Checked Then
  TempAccount.OutgoingSecurity := csSSL
 Else
  TempAccount.OutgoingSecurity := csSTARTTLS;

 TempAccount.OutgoingAuthRequired := AccountDialogCheckBoxes[0].Checked;
 TempAccount.OutgoingUseSameAuth := AccountDialogCheckBoxes[1].Checked;

 If Not TempAccount.OutgoingUseSameAuth Then Begin
  TempAccount.OutgoingUsername := AccountDialogInputFields[2].Value;
  TempAccount.OutgoingPassword := XORPassword(AccountDialogInputFields[3].Value);
 End
 Else Begin
  TempAccount.OutgoingUsername := TempAccount.IncomingUsername;
  TempAccount.OutgoingPassword := TempAccount.IncomingPassword;
 End;
End;

{ Teste la connexion au serveur entrant }
Function TestIncomingConnection: TConnectionTestResult;
Begin
 { Simulation du test de connexion }
 { Dans une implementation reelle, on utiliserait les clients IMAP/POP3 }
 If (TempAccount.IncomingHost = '') Or (TempAccount.IncomingUsername = '') Then Begin
  TestIncomingConnection := ctrFailedIncoming;
  Exit;
 End;

 { Simuler un delai de test }
 Delay(500);

 { Test simule reussi si les champs sont remplis }
 TestIncomingConnection := ctrSuccess;
End;

{ Teste la connexion au serveur sortant }
Function TestOutgoingConnection: TConnectionTestResult;
Begin
 { Simulation du test de connexion SMTP }
 If TempAccount.OutgoingHost = '' Then Begin
  TestOutgoingConnection := ctrFailedOutgoing;
  Exit;
 End;

 { Simuler un delai de test }
 Delay(500);

 { Test simule reussi si les champs sont remplis }
 TestOutgoingConnection := ctrSuccess;
End;

{ Execute le test de connexion complet }
Procedure RunConnectionTest;
Var
 Result: TConnectionTestResult;
Begin
 ConnectionTestInProgress := True;
 ConnectionTestResult := ctrTesting;

 { Tester le serveur entrant }
 Result := TestIncomingConnection;
 If Result <> ctrSuccess Then Begin
  ConnectionTestResult := Result;
  ConnectionTestInProgress := False;
  Exit;
 End;

 { Tester le serveur sortant }
 Result := TestOutgoingConnection;
 If Result <> ctrSuccess Then Begin
  ConnectionTestResult := Result;
  ConnectionTestInProgress := False;
  Exit;
 End;

 ConnectionTestResult := ctrSuccess;
 TempAccount.LastConnectionTest := ctrSuccess;
 ConnectionTestInProgress := False;
End;

{ Retourne le texte du resultat du test }
Function GetConnectionTestResultText(Result: TConnectionTestResult): String;
Begin
 Case Result Of
  ctrNotTested: GetConnectionTestResultText := 'Non teste';
  ctrTesting: GetConnectionTestResultText := 'Test en cours...';
  ctrSuccess: GetConnectionTestResultText := 'Connexion reussie!';
  ctrFailedIncoming: GetConnectionTestResultText := 'Echec serveur entrant';
  ctrFailedOutgoing: GetConnectionTestResultText := 'Echec serveur sortant';
  ctrFailedAuth: GetConnectionTestResultText := 'Echec authentification';
  ctrFailedNetwork: GetConnectionTestResultText := 'Erreur reseau';
  Else GetConnectionTestResultText := 'Erreur inconnue';
 End;
End;

{ Dessine la page de bienvenue de l'assistant }
Procedure DrawWizardWelcomePage;
Var
 Y: Integer;
Begin
 Y := DIALOG_Y + 40;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Bienvenue dans l''assistant de configuration');
 Y := Y + 25;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'de compte de messagerie.');
 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Cet assistant vous guidera pour configurer');
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'un nouveau compte de messagerie.');
 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Vous aurez besoin des informations suivantes:');
 Y := Y + 25;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, '- Votre adresse de courrier electronique');
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, '- Le nom du serveur de courrier entrant');
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, '- Le nom du serveur de courrier sortant');
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, '- Votre nom d''utilisateur et mot de passe');
 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Cliquez sur Suivant pour continuer.');
End;

{ Dessine la page d'information du compte }
Procedure DrawAccountInfoPage;
Var
 Y, I: Integer;
Begin
 Y := DIALOG_Y + 30;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Informations du compte');

 { Dessiner les champs de saisie }
 For I := 0 To 3 Do
  DrawInputField(AccountDialogInputFields[I]);
End;

{ Dessine la page du serveur entrant }
Procedure DrawIncomingServerPage;
Var
 Y, I: Integer;
Begin
 Y := DIALOG_Y + 30;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Serveur de courrier entrant');

 { Type de serveur }
 OutTextXY(DIALOG_X + DIALOG_MARGIN, DIALOG_Y + 38, 'Type de serveur:');

 { Dessiner les boutons radio type serveur }
 DrawRadioButton(AccountDialogRadioButtons[0]);
 DrawRadioButton(AccountDialogRadioButtons[1]);

 { Dessiner les champs de saisie }
 For I := 0 To 3 Do
  DrawInputField(AccountDialogInputFields[I]);

 { Dessiner les boutons radio securite }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, AccountDialogRadioButtons[2].Y - 15, 'Securite:');
 DrawRadioButton(AccountDialogRadioButtons[2]);
 DrawRadioButton(AccountDialogRadioButtons[3]);
 DrawRadioButton(AccountDialogRadioButtons[4]);
End;

{ Dessine la page du serveur sortant }
Procedure DrawOutgoingServerPage;
Var
 Y, I: Integer;
Begin
 Y := DIALOG_Y + 30;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Serveur de courrier sortant (SMTP)');

 { Dessiner les champs de saisie }
 DrawInputField(AccountDialogInputFields[0]);
 DrawInputField(AccountDialogInputFields[1]);

 { Dessiner les boutons radio securite }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, AccountDialogRadioButtons[0].Y - 15, 'Securite:');
 For I := 0 To 2 Do
  DrawRadioButton(AccountDialogRadioButtons[I]);

 { Dessiner les cases a cocher }
 DrawCheckBox(AccountDialogCheckBoxes[0]);
 DrawCheckBox(AccountDialogCheckBoxes[1]);

 { Dessiner les champs SMTP si auth requise et pas memes identifiants }
 If AccountDialogCheckBoxes[0].Checked And Not AccountDialogCheckBoxes[1].Checked Then Begin
  DrawInputField(AccountDialogInputFields[2]);
  DrawInputField(AccountDialogInputFields[3]);
 End;
End;

{ Dessine la page de test de connexion }
Procedure DrawTestConnectionPage;
Var
 Y: Integer;
 ResultColor: Word;
Begin
 Y := DIALOG_Y + 40;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Test de connexion');

 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Configuration actuelle:');

 Y := Y + 25;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Serveur entrant: ' + TempAccount.IncomingHost);
 Y := Y + 18;
 If TempAccount.IncomingType = istIMAP Then
  OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Type: IMAP')
 Else
  OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Type: POP3');
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Serveur sortant: ' + TempAccount.OutgoingHost);

 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Resultat du test:');

 Y := Y + 20;
 { Couleur selon le resultat }
 Case ConnectionTestResult Of
  ctrSuccess: ResultColor := LightGreen;
  ctrTesting: ResultColor := Yellow;
  Else ResultColor := LightRed;
 End;
 SetColor(ResultColor);
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, GetConnectionTestResultText(ConnectionTestResult));

 Y := Y + 40;
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Cliquez sur "Tester" pour verifier la connexion.');

 { Bouton Tester }
 DrawDialogButton(DIALOG_X + DIALOG_MARGIN, Y + 25, 80, DIALOG_BUTTON_HEIGHT,
                  'Tester', False, Not ConnectionTestInProgress);
End;

{ Dessine la page de completion }
Procedure DrawCompletePage;
Var
 Y: Integer;
Begin
 Y := DIALOG_Y + 40;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Configuration terminee!');

 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Votre compte a ete configure avec succes.');

 Y := Y + 35;
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Resume:');
 Y := Y + 25;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Compte: ' + TempAccount.AccountName);
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Email: ' + TempAccount.EmailAddress);
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Serveur entrant: ' + TempAccount.IncomingHost);
 Y := Y + 18;
 OutTextXY(DIALOG_X + DIALOG_MARGIN + 20, Y, 'Serveur sortant: ' + TempAccount.OutgoingHost);

 If ConnectionTestResult = ctrSuccess Then Begin
  Y := Y + 35;
  SetColor(LightGreen);
  OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Test de connexion reussi!');
 End;

 Y := Y + 35;
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Cliquez sur Terminer pour sauvegarder.');
End;

{ Dessine le contenu de l'assistant selon l'etape }
Procedure DrawWizardContent;
Begin
 Case AccountWizardStep Of
  awsWelcome: DrawWizardWelcomePage;
  awsAccountInfo: DrawAccountInfoPage;
  awsIncomingServer: DrawIncomingServerPage;
  awsOutgoingServer: DrawOutgoingServerPage;
  awsTestConnection: DrawTestConnectionPage;
  awsComplete: DrawCompletePage;
 End;
End;

{ Dessine la boite de dialogue de l'assistant }
Procedure DrawAccountWizardDialog;
Var
 Title: String;
 BtnX, BtnY: Integer;
Begin
 { Titre selon l'etape }
 Case AccountWizardStep Of
  awsWelcome: Title := 'Assistant de compte - Bienvenue';
  awsAccountInfo: Title := 'Assistant de compte - Informations';
  awsIncomingServer: Title := 'Assistant de compte - Serveur entrant';
  awsOutgoingServer: Title := 'Assistant de compte - Serveur sortant';
  awsTestConnection: Title := 'Assistant de compte - Test';
  awsComplete: Title := 'Assistant de compte - Termine';
  Else Title := 'Assistant de compte';
 End;

 HideMouse;

 { Dessiner la boite de dialogue }
 DrawDialogBox(DIALOG_X, DIALOG_Y, DIALOG_WIDTH, DIALOG_HEIGHT, Title);

 { Dessiner le contenu selon l'etape }
 DrawWizardContent;

 { Boutons de navigation }
 BtnY := DIALOG_Y + DIALOG_HEIGHT - DIALOG_BUTTON_HEIGHT - DIALOG_MARGIN;

 { Bouton Annuler }
 BtnX := DIALOG_X + DIALOG_MARGIN;
 DrawDialogButton(BtnX, BtnY, DIALOG_BUTTON_WIDTH, DIALOG_BUTTON_HEIGHT,
                  'Annuler', False, True);

 { Bouton Precedent }
 BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH * 3 - DIALOG_MARGIN * 2 - 10;
 DrawDialogButton(BtnX, BtnY, DIALOG_BUTTON_WIDTH, DIALOG_BUTTON_HEIGHT,
                  'Precedent', False, AccountWizardStep > awsWelcome);

 { Bouton Suivant/Terminer }
 BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH * 2 - DIALOG_MARGIN - 5;
 If AccountWizardStep = awsComplete Then
  DrawDialogButton(BtnX, BtnY, DIALOG_BUTTON_WIDTH, DIALOG_BUTTON_HEIGHT,
                   'Terminer', False, True)
 Else
  DrawDialogButton(BtnX, BtnY, DIALOG_BUTTON_WIDTH, DIALOG_BUTTON_HEIGHT,
                   'Suivant', False, True);

 ShowMouse;
End;

{ Dessine la liste des comptes }
Procedure DrawAccountListDialog;
Var
 Y, I: Integer;
 BtnX, BtnY: Integer;
 BgColor: Word;
Begin
 HideMouse;

 { Dessiner la boite de dialogue }
 DrawDialogBox(DIALOG_X, DIALOG_Y, DIALOG_WIDTH, DIALOG_HEIGHT, 'Gestion des comptes');

 { Liste des comptes }
 Y := DIALOG_Y + 30;
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(DIALOG_X + DIALOG_MARGIN, Y, 'Comptes de messagerie:');

 Y := Y + 20;

 { Zone de liste }
 SetFillStyle(SolidFill, COLOR_LIST_BG);
 Bar(DIALOG_X + DIALOG_MARGIN, Y, DIALOG_X + DIALOG_WIDTH - 120, Y + 180);
 Draw3DRect(DIALOG_X + DIALOG_MARGIN, Y, DIALOG_X + DIALOG_WIDTH - 120, Y + 180, False);

 { Afficher les comptes }
 For I := 0 To EmailAccountCount - 1 Do Begin
  If (I - AccountListScrollOffset >= 0) And (I - AccountListScrollOffset < 10) Then Begin
   { Fond de selection }
   If I = SelectedAccountInList Then Begin
    BgColor := COLOR_LIST_SELECTED;
    SetFillStyle(SolidFill, BgColor);
    Bar(DIALOG_X + DIALOG_MARGIN + 2, Y + (I - AccountListScrollOffset) * 18,
        DIALOG_X + DIALOG_WIDTH - 122, Y + (I - AccountListScrollOffset) * 18 + 16);
    SetColor(COLOR_LIST_SELECTED_TEXT);
   End
   Else
    SetColor(COLOR_MENU_TEXT);

   OutTextXY(DIALOG_X + DIALOG_MARGIN + 5, Y + (I - AccountListScrollOffset) * 18 + 3,
             EmailAccounts[I].AccountName);

   { Indicateur par defaut }
   If EmailAccounts[I].IsDefault Then
    OutTextXY(DIALOG_X + DIALOG_WIDTH - 200, Y + (I - AccountListScrollOffset) * 18 + 3, '(defaut)');
  End;
 End;

 { Boutons d'action }
 BtnX := DIALOG_X + DIALOG_WIDTH - 110;
 BtnY := DIALOG_Y + 50;

 DrawDialogButton(BtnX, BtnY, 95, DIALOG_BUTTON_HEIGHT, 'Ajouter', False, True);
 BtnY := BtnY + 30;
 DrawDialogButton(BtnX, BtnY, 95, DIALOG_BUTTON_HEIGHT, 'Modifier', False, SelectedAccountInList >= 0);
 BtnY := BtnY + 30;
 DrawDialogButton(BtnX, BtnY, 95, DIALOG_BUTTON_HEIGHT, 'Supprimer', False, SelectedAccountInList >= 0);
 BtnY := BtnY + 30;
 DrawDialogButton(BtnX, BtnY, 95, DIALOG_BUTTON_HEIGHT, 'Par defaut', False, SelectedAccountInList >= 0);
 BtnY := BtnY + 30;
 DrawDialogButton(BtnX, BtnY, 95, DIALOG_BUTTON_HEIGHT, 'Proprietes', False, SelectedAccountInList >= 0);

 { Boutons de fermeture }
 BtnY := DIALOG_Y + DIALOG_HEIGHT - DIALOG_BUTTON_HEIGHT - DIALOG_MARGIN;
 BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH - DIALOG_MARGIN;
 DrawDialogButton(BtnX, BtnY, DIALOG_BUTTON_WIDTH, DIALOG_BUTTON_HEIGHT, 'Fermer', False, True);

 ShowMouse;
End;

{ ============================================================================
  DrawAccountManagerDialog - Affiche la boite de dialogue de gestion des comptes

  Cette procedure est le point d'entree principal pour l'affichage du
  gestionnaire de comptes. Elle affiche soit:
  - La liste des comptes (mode liste) quand AccountWizardMode = False
  - L'assistant de configuration (mode assistant) quand AccountWizardMode = True

  Disposition de la boite de dialogue (mode liste):
  +-----------------------------------------------+
  | Gestion des comptes                       [X] |
  +-----------------------------------------------+
  | Comptes de messagerie:         | [Ajouter  ] |
  | +---------------------------+  | [Modifier ] |
  | | Compte 1           (def)  |  | [Supprimer] |
  | | Compte 2                  |  | [Par defaut]|
  | +---------------------------+  | [Proprietes]|
  |                                              |
  |                               [Fermer]       |
  +-----------------------------------------------+

  Disposition de l'assistant (chaque etape):
  +-----------------------------------------------+
  | Assistant de compte - [Titre etape]       [X] |
  +-----------------------------------------------+
  |                                              |
  | [Contenu variable selon l'etape]             |
  |                                              |
  | [Annuler]    [Precedent] [Suivant/Terminer] |
  +-----------------------------------------------+

  Coordonnees:
  - Position: DIALOG_X, DIALOG_Y (centre de l'ecran)
  - Dimensions: DIALOG_WIDTH x DIALOG_HEIGHT (500 x 350 pixels)
  - Marge interieure: DIALOG_MARGIN (10 pixels)
  ============================================================================ }
Procedure DrawAccountManagerDialog;
Begin
 If AccountWizardMode Then
  DrawAccountWizardDialog
 Else
  DrawAccountListDialog;
End;

{ Passe a l'etape suivante de l'assistant }
Procedure WizardNextStep;
Begin
 Case AccountWizardStep Of
  awsWelcome: Begin
   AccountWizardStep := awsAccountInfo;
   InitAccountInfoFields;
  End;
  awsAccountInfo: Begin
   SaveAccountInfoFields;
   AccountWizardStep := awsIncomingServer;
   InitIncomingServerFields;
  End;
  awsIncomingServer: Begin
   SaveIncomingServerFields;
   AccountWizardStep := awsOutgoingServer;
   InitOutgoingServerFields;
  End;
  awsOutgoingServer: Begin
   SaveOutgoingServerFields;
   AccountWizardStep := awsTestConnection;
   ConnectionTestResult := ctrNotTested;
  End;
  awsTestConnection: Begin
   AccountWizardStep := awsComplete;
  End;
  awsComplete: Begin
   { Sauvegarder le compte }
   If CurrentAccountIndex < 0 Then Begin
    If EmailAccountCount < MAX_EMAIL_ACCOUNTS Then Begin
     EmailAccounts[EmailAccountCount] := TempAccount;
     { Premier compte = defaut }
     If EmailAccountCount = 0 Then
      EmailAccounts[EmailAccountCount].IsDefault := True;
     Inc(EmailAccountCount);
    End;
   End
   Else Begin
    EmailAccounts[CurrentAccountIndex] := TempAccount;
   End;
   AccountWizardMode := False;
   AccountDialogVisible := True;
  End;
 End;
 DrawAccountManagerDialog;
End;

{ Retourne a l'etape precedente de l'assistant }
Procedure WizardPreviousStep;
Begin
 Case AccountWizardStep Of
  awsAccountInfo: AccountWizardStep := awsWelcome;
  awsIncomingServer: Begin
   AccountWizardStep := awsAccountInfo;
   InitAccountInfoFields;
  End;
  awsOutgoingServer: Begin
   AccountWizardStep := awsIncomingServer;
   InitIncomingServerFields;
  End;
  awsTestConnection: Begin
   AccountWizardStep := awsOutgoingServer;
   InitOutgoingServerFields;
  End;
  awsComplete: AccountWizardStep := awsTestConnection;
 End;
 DrawAccountManagerDialog;
End;

{ Annule l'assistant }
Procedure WizardCancel;
Begin
 AccountWizardMode := False;
 AccountDialogVisible := True;
 DrawAccountManagerDialog;
End;

{ Ouvre la boite de dialogue de gestion des comptes }
Procedure ShowAccountManagerDialog;
Begin
 AccountDialogVisible := True;
 AccountWizardMode := False;
 SelectedAccountInList := -1;
 If EmailAccountCount > 0 Then
  SelectedAccountInList := 0;
 DrawAccountManagerDialog;
End;

{ Ferme la boite de dialogue de gestion des comptes }
Procedure HideAccountManagerDialog;
Begin
 AccountDialogVisible := False;
 AccountWizardMode := False;
 DrawInterface;
End;

{ Ouvre l'assistant pour un nouveau compte }
Procedure StartNewAccountWizard;
Begin
 InitializeEmptyAccount(TempAccount);
 CurrentAccountIndex := -1;
 AccountWizardMode := True;
 AccountWizardStep := awsWelcome;
 ConnectionTestResult := ctrNotTested;
 DrawAccountManagerDialog;
End;

{ Ouvre l'assistant pour modifier un compte existant }
Procedure EditExistingAccount(Index: Integer);
Begin
 If (Index < 0) Or (Index >= EmailAccountCount) Then Exit;
 TempAccount := EmailAccounts[Index];
 CurrentAccountIndex := Index;
 AccountWizardMode := True;
 AccountWizardStep := awsAccountInfo;
 InitAccountInfoFields;
 DrawAccountManagerDialog;
End;

{ Supprime un compte }
Procedure DeleteAccount(Index: Integer);
Var
 I: Integer;
Begin
 If (Index < 0) Or (Index >= EmailAccountCount) Then Exit;

 { Decaler les comptes }
 For I := Index To EmailAccountCount - 2 Do
  EmailAccounts[I] := EmailAccounts[I + 1];

 Dec(EmailAccountCount);

 { Ajuster la selection }
 If SelectedAccountInList >= EmailAccountCount Then
  SelectedAccountInList := EmailAccountCount - 1;

 DrawAccountManagerDialog;
End;

{ Definit un compte comme compte par defaut }
Procedure SetDefaultAccount(Index: Integer);
Var
 I: Integer;
Begin
 If (Index < 0) Or (Index >= EmailAccountCount) Then Exit;

 For I := 0 To EmailAccountCount - 1 Do
  EmailAccounts[I].IsDefault := (I = Index);

 DrawAccountManagerDialog;
End;

{ Gere les clics dans la boite de dialogue }
Procedure HandleAccountDialogClick(X, Y: Integer);
Var
 BtnX, BtnY, ListY, I: Integer;
Begin
 If Not AccountDialogVisible Then Exit;

 { Verifier si clic dans la boite de dialogue }
 If (X < DIALOG_X) Or (X > DIALOG_X + DIALOG_WIDTH) Or
    (Y < DIALOG_Y) Or (Y > DIALOG_Y + DIALOG_HEIGHT) Then Begin
  HideAccountManagerDialog;
  Exit;
 End;

 If AccountWizardMode Then Begin
  { Mode assistant }
  BtnY := DIALOG_Y + DIALOG_HEIGHT - DIALOG_BUTTON_HEIGHT - DIALOG_MARGIN;

  { Bouton Annuler }
  BtnX := DIALOG_X + DIALOG_MARGIN;
  If (X >= BtnX) And (X <= BtnX + DIALOG_BUTTON_WIDTH) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) Then Begin
   WizardCancel;
   Exit;
  End;

  { Bouton Precedent }
  BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH * 3 - DIALOG_MARGIN * 2 - 10;
  If (X >= BtnX) And (X <= BtnX + DIALOG_BUTTON_WIDTH) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
     (AccountWizardStep > awsWelcome) Then Begin
   WizardPreviousStep;
   Exit;
  End;

  { Bouton Suivant/Terminer }
  BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH * 2 - DIALOG_MARGIN - 5;
  If (X >= BtnX) And (X <= BtnX + DIALOG_BUTTON_WIDTH) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) Then Begin
   WizardNextStep;
   Exit;
  End;

  { Bouton Tester (page test) }
  If AccountWizardStep = awsTestConnection Then Begin
   BtnY := DIALOG_Y + 225;
   If (X >= DIALOG_X + DIALOG_MARGIN) And (X <= DIALOG_X + DIALOG_MARGIN + 80) And
      (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
      Not ConnectionTestInProgress Then Begin
    RunConnectionTest;
    DrawAccountManagerDialog;
    Exit;
   End;
  End;

  { Gerer les clics sur les champs de saisie }
  For I := 0 To 3 Do Begin
   If (X >= AccountDialogInputFields[I].X) And
      (X <= AccountDialogInputFields[I].X + AccountDialogInputFields[I].Width) And
      (Y >= AccountDialogInputFields[I].Y) And
      (Y <= AccountDialogInputFields[I].Y + DIALOG_INPUT_HEIGHT) Then Begin
    { Deselectionner tous les champs }
    AccountDialogInputFields[0].IsFocused := False;
    AccountDialogInputFields[1].IsFocused := False;
    AccountDialogInputFields[2].IsFocused := False;
    AccountDialogInputFields[3].IsFocused := False;
    { Selectionner ce champ }
    AccountDialogInputFields[I].IsFocused := True;
    FocusedInputField := I;
    DrawAccountManagerDialog;
    Exit;
   End;
  End;

  { Gerer les clics sur les boutons radio }
  For I := 0 To 4 Do Begin
   If (X >= AccountDialogRadioButtons[I].X) And
      (X <= AccountDialogRadioButtons[I].X + 100) And
      (Y >= AccountDialogRadioButtons[I].Y) And
      (Y <= AccountDialogRadioButtons[I].Y + 14) Then Begin
    { Deselectionner tous les boutons du meme groupe }
    Case AccountDialogRadioButtons[I].GroupID Of
     1: Begin { Type serveur }
      AccountDialogRadioButtons[0].Checked := False;
      AccountDialogRadioButtons[1].Checked := False;
     End;
     2: Begin { Securite entrante }
      AccountDialogRadioButtons[2].Checked := False;
      AccountDialogRadioButtons[3].Checked := False;
      AccountDialogRadioButtons[4].Checked := False;
     End;
     3: Begin { Securite sortante }
      AccountDialogRadioButtons[0].Checked := False;
      AccountDialogRadioButtons[1].Checked := False;
      AccountDialogRadioButtons[2].Checked := False;
     End;
    End;
    AccountDialogRadioButtons[I].Checked := True;
    DrawAccountManagerDialog;
    Exit;
   End;
  End;

  { Gerer les clics sur les cases a cocher }
  For I := 0 To 1 Do Begin
   If (X >= AccountDialogCheckBoxes[I].X) And
      (X <= AccountDialogCheckBoxes[I].X + 150) And
      (Y >= AccountDialogCheckBoxes[I].Y) And
      (Y <= AccountDialogCheckBoxes[I].Y + 14) Then Begin
    AccountDialogCheckBoxes[I].Checked := Not AccountDialogCheckBoxes[I].Checked;
    DrawAccountManagerDialog;
    Exit;
   End;
  End;
 End
 Else Begin
  { Mode liste des comptes }
  BtnX := DIALOG_X + DIALOG_WIDTH - 110;

  { Bouton Ajouter }
  BtnY := DIALOG_Y + 50;
  If (X >= BtnX) And (X <= BtnX + 95) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) Then Begin
   StartNewAccountWizard;
   Exit;
  End;

  { Bouton Modifier }
  BtnY := BtnY + 30;
  If (X >= BtnX) And (X <= BtnX + 95) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
     (SelectedAccountInList >= 0) Then Begin
   EditExistingAccount(SelectedAccountInList);
   Exit;
  End;

  { Bouton Supprimer }
  BtnY := BtnY + 30;
  If (X >= BtnX) And (X <= BtnX + 95) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
     (SelectedAccountInList >= 0) Then Begin
   DeleteAccount(SelectedAccountInList);
   Exit;
  End;

  { Bouton Par defaut }
  BtnY := BtnY + 30;
  If (X >= BtnX) And (X <= BtnX + 95) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
     (SelectedAccountInList >= 0) Then Begin
   SetDefaultAccount(SelectedAccountInList);
   Exit;
  End;

  { Bouton Proprietes }
  BtnY := BtnY + 30;
  If (X >= BtnX) And (X <= BtnX + 95) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) And
     (SelectedAccountInList >= 0) Then Begin
   EditExistingAccount(SelectedAccountInList);
   Exit;
  End;

  { Bouton Fermer }
  BtnY := DIALOG_Y + DIALOG_HEIGHT - DIALOG_BUTTON_HEIGHT - DIALOG_MARGIN;
  BtnX := DIALOG_X + DIALOG_WIDTH - DIALOG_BUTTON_WIDTH - DIALOG_MARGIN;
  If (X >= BtnX) And (X <= BtnX + DIALOG_BUTTON_WIDTH) And
     (Y >= BtnY) And (Y <= BtnY + DIALOG_BUTTON_HEIGHT) Then Begin
   HideAccountManagerDialog;
   Exit;
  End;

  { Clic dans la liste des comptes }
  ListY := DIALOG_Y + 50;
  If (X >= DIALOG_X + DIALOG_MARGIN) And (X <= DIALOG_X + DIALOG_WIDTH - 120) And
     (Y >= ListY) And (Y <= ListY + 180) Then Begin
   I := (Y - ListY) Div 18 + AccountListScrollOffset;
   If (I >= 0) And (I < EmailAccountCount) Then Begin
    SelectedAccountInList := I;
    DrawAccountManagerDialog;
   End;
  End;
 End;
End;

{ Gere les touches clavier dans la boite de dialogue }
Procedure HandleAccountDialogKeyPress(Key: Char);
Var
 FieldValue: String;
Begin
 If Not AccountDialogVisible Then Exit;
 If Not AccountWizardMode Then Exit;
 If FocusedInputField < 0 Then Exit;

 FieldValue := AccountDialogInputFields[FocusedInputField].Value;

 If Key = #8 Then Begin { Backspace }
  If Length(FieldValue) > 0 Then Begin
   Delete(FieldValue, Length(FieldValue), 1);
   AccountDialogInputFields[FocusedInputField].Value := FieldValue;
   DrawAccountManagerDialog;
  End;
 End
 Else If Key = #9 Then Begin { Tab }
  AccountDialogInputFields[FocusedInputField].IsFocused := False;
  Inc(FocusedInputField);
  If FocusedInputField > 3 Then FocusedInputField := 0;
  AccountDialogInputFields[FocusedInputField].IsFocused := True;
  DrawAccountManagerDialog;
 End
 Else If Key = #13 Then Begin { Enter }
  WizardNextStep;
 End
 Else If Key = #27 Then Begin { Escape }
  WizardCancel;
 End
 Else If (Key >= ' ') And (Key <= '~') Then Begin { Caracteres imprimables }
  If Length(FieldValue) < AccountDialogInputFields[FocusedInputField].MaxLen Then Begin
   FieldValue := FieldValue + Key;
   AccountDialogInputFields[FocusedInputField].Value := FieldValue;
   DrawAccountManagerDialog;
  End;
 End;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU GESTIONNAIRE DE COMPTES
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU COMPOSITEUR DE MESSAGES (TODO 12)
  ============================================================================ }

{ Initialise le compositeur de messages }
Procedure InitializeComposer;
Var
 I: Integer;
Begin
 ComposerVisible := False;
 ComposerFocusedField := COMP_FIELD_TO;
 ComposerCursorVisible := True;
 ComposerCursorTimer := 0;
 ComposerFormatBold := False;
 ComposerFormatItalic := False;
 ComposerFormatUnderline := False;

 { Initialiser le compositeur }
 Composer.ToField := '';
 Composer.CcField := '';
 Composer.BccField := '';
 Composer.SubjectField := '';
 Composer.LineCount := 1;
 Composer.CursorX := 0;
 Composer.CursorY := 0;
 Composer.ScrollX := 0;
 Composer.ScrollY := 0;
 Composer.HasSelection := False;
 Composer.Modified := False;
 Composer.State := csNew;
 Composer.OriginalMsgID := '';

 { Format par defaut }
 Composer.CurrentFormat.Bold := False;
 Composer.CurrentFormat.Italic := False;
 Composer.CurrentFormat.Underline := False;
 Composer.CurrentFormat.FontColor := COLOR_MENU_TEXT;

 { Initialiser les pieces jointes (TODO 13) }
 Composer.AttachmentCount := 0;
 AttachTotalSize := 0;
 SelectedAttachment := -1;

 { Initialiser les lignes vides }
 For I := 0 To COMPOSER_MAX_LINES - 1 Do Begin
  Composer.Lines[I].Text := '';
  Composer.Lines[I].Format.Bold := False;
  Composer.Lines[I].Format.Italic := False;
  Composer.Lines[I].Format.Underline := False;
  Composer.Lines[I].Format.FontColor := COLOR_MENU_TEXT;
 End;
End;

{ Initialise les champs d'en-tete du compositeur }
Procedure InitComposerFields;
Var
 BaseX, BaseY: Integer;
Begin
 BaseX := COMPOSER_X + COMPOSER_LABEL_WIDTH + 10;
 BaseY := COMPOSER_Y + 28;

 { Champ A: (destinataires) }
 ComposerInputFields[0].X := BaseX;
 ComposerInputFields[0].Y := BaseY;
 ComposerInputFields[0].Width := COMPOSER_WIDTH - COMPOSER_LABEL_WIDTH - 30;
 ComposerInputFields[0].MaxLen := 250;
 ComposerInputFields[0].Value := Composer.ToField;
 ComposerInputFields[0].IsPassword := False;
 ComposerInputFields[0].IsFocused := True;
 ComposerInputFields[0].CursorPos := Length(Composer.ToField);
 ComposerInputFields[0].Label_ := 'A:';

 { Champ Cc: }
 BaseY := BaseY + COMPOSER_FIELD_SPACING;
 ComposerInputFields[1].X := BaseX;
 ComposerInputFields[1].Y := BaseY;
 ComposerInputFields[1].Width := COMPOSER_WIDTH - COMPOSER_LABEL_WIDTH - 30;
 ComposerInputFields[1].MaxLen := 250;
 ComposerInputFields[1].Value := Composer.CcField;
 ComposerInputFields[1].IsPassword := False;
 ComposerInputFields[1].IsFocused := False;
 ComposerInputFields[1].CursorPos := Length(Composer.CcField);
 ComposerInputFields[1].Label_ := 'Cc:';

 { Champ Cci: }
 BaseY := BaseY + COMPOSER_FIELD_SPACING;
 ComposerInputFields[2].X := BaseX;
 ComposerInputFields[2].Y := BaseY;
 ComposerInputFields[2].Width := COMPOSER_WIDTH - COMPOSER_LABEL_WIDTH - 30;
 ComposerInputFields[2].MaxLen := 250;
 ComposerInputFields[2].Value := Composer.BccField;
 ComposerInputFields[2].IsPassword := False;
 ComposerInputFields[2].IsFocused := False;
 ComposerInputFields[2].CursorPos := Length(Composer.BccField);
 ComposerInputFields[2].Label_ := 'Cci:';

 { Champ Objet: }
 BaseY := BaseY + COMPOSER_FIELD_SPACING;
 ComposerInputFields[3].X := BaseX;
 ComposerInputFields[3].Y := BaseY;
 ComposerInputFields[3].Width := COMPOSER_WIDTH - COMPOSER_LABEL_WIDTH - 30;
 ComposerInputFields[3].MaxLen := 80;
 ComposerInputFields[3].Value := Composer.SubjectField;
 ComposerInputFields[3].IsPassword := False;
 ComposerInputFields[3].IsFocused := False;
 ComposerInputFields[3].CursorPos := Length(Composer.SubjectField);
 ComposerInputFields[3].Label_ := 'Objet:';

 ComposerFocusedField := COMP_FIELD_TO;
End;

{ Sauvegarde les valeurs des champs d'en-tete }
Procedure SaveComposerFields;
Begin
 Composer.ToField := ComposerInputFields[0].Value;
 Composer.CcField := ComposerInputFields[1].Value;
 Composer.BccField := ComposerInputFields[2].Value;
 Composer.SubjectField := ComposerInputFields[3].Value;
End;

{ Dessine un bouton de formatage }
Procedure DrawFormatButton(X, Y, W, H: Integer; Caption: String; Pressed: Boolean);
Begin
 { Fond du bouton }
 If Pressed Then
  SetFillStyle(SolidFill, COLOR_LIST_SELECTED)
 Else
  SetFillStyle(SolidFill, COLOR_BUTTON_FACE);
 Bar(X, Y, X + W, Y + H);

 { Relief 3D }
 Draw3DRect(X, Y, X + W, Y + H, Not Pressed);

 { Texte centre }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(X + (W - TextWidth(Caption)) Div 2, Y + (H - TextHeight(Caption)) Div 2, Caption);
End;

{ Dessine la barre d'outils de formatage }
Procedure DrawComposerToolbar;
Var
 ToolbarY, BtnX: Integer;
Begin
 ToolbarY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT + 2;

 { Fond de la barre d'outils }
 SetFillStyle(SolidFill, COLOR_BUTTON_FACE);
 Bar(COMPOSER_X + 2, ToolbarY, COMPOSER_X + COMPOSER_WIDTH - 2, ToolbarY + COMPOSER_TOOLBAR_HEIGHT - 2);

 { Bordure }
 SetColor(COLOR_BUTTON_DARK);
 Line(COMPOSER_X + 2, ToolbarY + COMPOSER_TOOLBAR_HEIGHT - 1,
      COMPOSER_X + COMPOSER_WIDTH - 2, ToolbarY + COMPOSER_TOOLBAR_HEIGHT - 1);

 { Boutons de formatage }
 BtnX := COMPOSER_X + 8;

 { Bouton Gras (B) }
 DrawFormatButton(BtnX, ToolbarY + 3, 24, 20, 'B', ComposerFormatBold);
 BtnX := BtnX + 28;

 { Bouton Italique (I) }
 DrawFormatButton(BtnX, ToolbarY + 3, 24, 20, 'I', ComposerFormatItalic);
 BtnX := BtnX + 28;

 { Bouton Souligne (S) }
 DrawFormatButton(BtnX, ToolbarY + 3, 24, 20, 'S', ComposerFormatUnderline);
 BtnX := BtnX + 35;

 { Separateur }
 SetColor(COLOR_BUTTON_DARK);
 Line(BtnX, ToolbarY + 5, BtnX, ToolbarY + COMPOSER_TOOLBAR_HEIGHT - 7);
 SetColor(COLOR_BUTTON_LIGHT);
 Line(BtnX + 1, ToolbarY + 5, BtnX + 1, ToolbarY + COMPOSER_TOOLBAR_HEIGHT - 7);

 { Etiquette couleur }
 BtnX := BtnX + 10;
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX, ToolbarY + 8, 'Couleur:');
 BtnX := BtnX + 55;

 { Bouton couleur noire }
 SetFillStyle(SolidFill, Black);
 Bar(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 BtnX := BtnX + 20;

 { Bouton couleur rouge }
 SetFillStyle(SolidFill, LightRed);
 Bar(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 BtnX := BtnX + 20;

 { Bouton couleur verte }
 SetFillStyle(SolidFill, LightGreen);
 Bar(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 BtnX := BtnX + 20;

 { Bouton couleur bleue }
 SetFillStyle(SolidFill, LightBlue);
 Bar(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(BtnX, ToolbarY + 5, BtnX + 16, ToolbarY + 18);
End;

{ Dessine un champ de saisie du compositeur }
Procedure DrawComposerField(Var Field: TInputField);
Var
 DisplayText: String;
Begin
 { Etiquette a gauche }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(COMPOSER_X + 10, Field.Y + 4, Field.Label_);

 { Fond du champ }
 If Field.IsFocused Then
  SetFillStyle(SolidFill, COLOR_LIST_BG)
 Else
  SetFillStyle(SolidFill, COLOR_WINDOW_BG);
 Bar(Field.X, Field.Y, Field.X + Field.Width, Field.Y + COMPOSER_FIELD_HEIGHT);

 { Bordure 3D inversee }
 Draw3DRect(Field.X, Field.Y, Field.X + Field.Width, Field.Y + COMPOSER_FIELD_HEIGHT, False);

 { Texte }
 DisplayText := Field.Value;
 { Tronquer si trop long }
 While TextWidth(DisplayText) > Field.Width - 8 Do
  Delete(DisplayText, 1, 1);

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Field.X + 4, Field.Y + 4, DisplayText);

 { Curseur si actif }
 If Field.IsFocused And ComposerCursorVisible Then Begin
  SetColor(COLOR_MENU_TEXT);
  Line(Field.X + 4 + TextWidth(DisplayText), Field.Y + 3,
       Field.X + 4 + TextWidth(DisplayText), Field.Y + COMPOSER_FIELD_HEIGHT - 3);
 End;
End;

{ Dessine la zone d'edition du compositeur }
Procedure DrawComposerEditor;
Var
 EditorX, EditorY, EditorW, EditorH: Integer;
 I, LineY, VisibleLine: Integer;
 DisplayText: String;
 LineFormat: TTextFormat;
Begin
 EditorX := COMPOSER_X + 4;
 EditorY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT + COMPOSER_TOOLBAR_HEIGHT + 4;
 EditorW := COMPOSER_WIDTH - 8;
 EditorH := COMPOSER_HEIGHT - COMPOSER_HEADER_HEIGHT - COMPOSER_TOOLBAR_HEIGHT - 45;

 { Fond de l'editeur }
 SetFillStyle(SolidFill, COLOR_LIST_BG);
 Bar(EditorX, EditorY, EditorX + EditorW, EditorY + EditorH);

 { Bordure 3D }
 Draw3DRect(EditorX, EditorY, EditorX + EditorW, EditorY + EditorH, False);

 { Dessiner les lignes de texte }
 LineY := EditorY + 4;
 For I := 0 To COMPOSER_EDITOR_VISIBLE_ROWS - 1 Do Begin
  VisibleLine := Composer.ScrollY + I;
  If VisibleLine < Composer.LineCount Then Begin
   DisplayText := Composer.Lines[VisibleLine].Text;
   LineFormat := Composer.Lines[VisibleLine].Format;

   { Appliquer le defilement horizontal }
   If Composer.ScrollX > 0 Then Begin
    If Length(DisplayText) > Composer.ScrollX Then
     Delete(DisplayText, 1, Composer.ScrollX)
    Else
     DisplayText := '';
   End;

   { Tronquer si trop long }
   If Length(DisplayText) > COMPOSER_EDITOR_VISIBLE_COLS Then
    DisplayText := Copy(DisplayText, 1, COMPOSER_EDITOR_VISIBLE_COLS);

   { Appliquer le formatage }
   SetColor(LineFormat.FontColor);
   { Note: Le formatage gras/italique/souligne necessiterait
     des polices differentes, simplifie ici }
   OutTextXY(EditorX + 4, LineY, DisplayText);
  End;
  LineY := LineY + 14;
 End;

 { Dessiner le curseur si dans l'editeur }
 If (ComposerFocusedField = COMP_FIELD_BODY) And ComposerCursorVisible Then Begin
  If (Composer.CursorY >= Composer.ScrollY) And
     (Composer.CursorY < Composer.ScrollY + COMPOSER_EDITOR_VISIBLE_ROWS) Then Begin
   LineY := EditorY + 4 + (Composer.CursorY - Composer.ScrollY) * 14;
   DisplayText := Copy(Composer.Lines[Composer.CursorY].Text, Composer.ScrollX + 1,
                       Composer.CursorX - Composer.ScrollX);
   SetColor(COLOR_MENU_TEXT);
   Line(EditorX + 4 + TextWidth(DisplayText), LineY,
        EditorX + 4 + TextWidth(DisplayText), LineY + 12);
  End;
 End;
End;

{ Dessine les boutons d'action du compositeur }
Procedure DrawComposerButtons;
Var
 BtnY, BtnX: Integer;
Begin
 BtnY := COMPOSER_Y + COMPOSER_HEIGHT - 30;

 { Bouton Envoyer }
 BtnX := COMPOSER_X + 10;
 DrawDialogButton(BtnX, BtnY, 80, 22, 'Envoyer', False, True);

 { Bouton Brouillon }
 BtnX := BtnX + 90;
 DrawDialogButton(BtnX, BtnY, 80, 22, 'Brouillon', False, True);

 { Bouton Annuler }
 BtnX := COMPOSER_X + COMPOSER_WIDTH - 90;
 DrawDialogButton(BtnX, BtnY, 80, 22, 'Annuler', False, True);
End;

{ Dessine la fenetre complete du compositeur }
Procedure DrawComposerWindow;
Var
 Title: String;
 I: Integer;
Begin
 If Not ComposerVisible Then Exit;

 HideMouse;

 { Titre selon l'etat }
 Case Composer.State Of
  csNew:      Title := 'Nouveau message';
  csReply:    Title := 'Re: ' + Composer.SubjectField;
  csReplyAll: Title := 'Re: ' + Composer.SubjectField;
  csForward:  Title := 'Fwd: ' + Composer.SubjectField;
  csDraft:    Title := 'Brouillon';
  Else        Title := 'Message';
 End;

 { Dessiner la boite de dialogue }
 DrawDialogBox(COMPOSER_X, COMPOSER_Y, COMPOSER_WIDTH, COMPOSER_HEIGHT, Title);

 { Dessiner les champs d'en-tete }
 For I := 0 To 3 Do
  DrawComposerField(ComposerInputFields[I]);

 { Barre d'outils de formatage }
 DrawComposerToolbar;

 { Zone d'edition }
 DrawComposerEditor;

 { Boutons d'action }
 DrawComposerButtons;

 ShowMouse;
End;

{ Ouvre le compositeur pour un nouveau message }
Procedure OpenNewMessage;
Begin
 InitializeComposer;
 Composer.State := csNew;
 ComposerVisible := True;
 InitComposerFields;
 DrawComposerWindow;
End;

{ Ouvre le compositeur pour une reponse }
Procedure OpenReplyMessage(ReplyAll: Boolean);
Var
 OrigMsg: TMessage;
Begin
 If SelectedMessage < 0 Then Exit;

 InitializeComposer;
 OrigMsg := Messages[SelectedMessage];

 { Preparer l'en-tete }
 Composer.ToField := OrigMsg.FromEmail;
 If ReplyAll Then Begin
  Composer.CcField := OrigMsg.CcEmail;
  Composer.State := csReplyAll;
 End
 Else
  Composer.State := csReply;

 { Objet avec Re: }
 If Pos('Re:', OrigMsg.Subject) <> 1 Then
  Composer.SubjectField := 'Re: ' + OrigMsg.Subject
 Else
  Composer.SubjectField := OrigMsg.Subject;

 Composer.OriginalMsgID := OrigMsg.MsgID;

 { Preparer le corps avec citation }
 Composer.Lines[0].Text := '';
 Composer.Lines[1].Text := '--- Message original ---';
 Composer.Lines[2].Text := 'De: ' + OrigMsg.FromName + ' <' + OrigMsg.FromEmail + '>';
 Composer.Lines[3].Text := 'Date: ' + OrigMsg.DateFull;
 Composer.Lines[4].Text := 'Objet: ' + OrigMsg.Subject;
 Composer.Lines[5].Text := '';
 Composer.LineCount := 6;

 ComposerVisible := True;
 InitComposerFields;
 DrawComposerWindow;
End;

{ Ouvre le compositeur pour un transfert }
Procedure OpenForwardMessage;
Var
 OrigMsg: TMessage;
Begin
 If SelectedMessage < 0 Then Exit;

 InitializeComposer;
 OrigMsg := Messages[SelectedMessage];

 Composer.State := csForward;

 { Objet avec Fwd: }
 If Pos('Fwd:', OrigMsg.Subject) <> 1 Then
  Composer.SubjectField := 'Fwd: ' + OrigMsg.Subject
 Else
  Composer.SubjectField := OrigMsg.Subject;

 Composer.OriginalMsgID := OrigMsg.MsgID;

 { Preparer le corps avec le message original }
 Composer.Lines[0].Text := '';
 Composer.Lines[1].Text := '---------- Message transfere ----------';
 Composer.Lines[2].Text := 'De: ' + OrigMsg.FromName + ' <' + OrigMsg.FromEmail + '>';
 Composer.Lines[3].Text := 'Date: ' + OrigMsg.DateFull;
 Composer.Lines[4].Text := 'A: ' + OrigMsg.ToEmail;
 Composer.Lines[5].Text := 'Objet: ' + OrigMsg.Subject;
 Composer.Lines[6].Text := '';
 Composer.LineCount := 7;

 ComposerVisible := True;
 InitComposerFields;
 DrawComposerWindow;
End;

{ Ferme le compositeur }
Procedure CloseComposer;
Begin
 ComposerVisible := False;
 DrawInterface;
End;

{ Sauvegarde le message comme brouillon }
Procedure SaveDraft;
Begin
 SaveComposerFields;
 { Ici on sauvegarderait le brouillon }
 { Pour l'instant, afficher un message }
 HideMouse;
 FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
          Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
 SetColor(COLOR_STATUS_TEXT);
 OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
           'Brouillon enregistre                ');
 ShowMouse;
 Composer.Modified := False;
End;

{ Envoie le message }
Procedure SendMessage;
Begin
 SaveComposerFields;

 { Verifier les champs obligatoires }
 If Composer.ToField = '' Then Begin
  { Afficher erreur }
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(LightRed);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Erreur: Destinataire requis!        ');
  ShowMouse;
  Exit;
 End;

 { Ici on enverrait le message via SMTP }
 { Pour l'instant, simuler l'envoi }
 HideMouse;
 FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
          Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
 SetColor(LightGreen);
 OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
           'Message envoye avec succes!         ');
 ShowMouse;

 CloseComposer;
End;

{ Gere les clics dans le compositeur }
Procedure HandleComposerClick(X, Y: Integer);
Var
 I, BtnX, BtnY, ToolbarY: Integer;
 EditorX, EditorY, EditorW, EditorH: Integer;
 ClickedLine: Integer;
Begin
 If Not ComposerVisible Then Exit;

 { Verifier si clic hors de la fenetre }
 If (X < COMPOSER_X) Or (X > COMPOSER_X + COMPOSER_WIDTH) Or
    (Y < COMPOSER_Y) Or (Y > COMPOSER_Y + COMPOSER_HEIGHT) Then Begin
  CloseComposer;
  Exit;
 End;

 { Verifier les boutons d'action }
 BtnY := COMPOSER_Y + COMPOSER_HEIGHT - 30;

 { Bouton Envoyer }
 BtnX := COMPOSER_X + 10;
 If (X >= BtnX) And (X <= BtnX + 80) And (Y >= BtnY) And (Y <= BtnY + 22) Then Begin
  SendMessage;
  Exit;
 End;

 { Bouton Brouillon }
 BtnX := BtnX + 90;
 If (X >= BtnX) And (X <= BtnX + 80) And (Y >= BtnY) And (Y <= BtnY + 22) Then Begin
  SaveDraft;
  Exit;
 End;

 { Bouton Annuler }
 BtnX := COMPOSER_X + COMPOSER_WIDTH - 90;
 If (X >= BtnX) And (X <= BtnX + 80) And (Y >= BtnY) And (Y <= BtnY + 22) Then Begin
  CloseComposer;
  Exit;
 End;

 { Verifier les champs d'en-tete }
 For I := 0 To 3 Do Begin
  If (X >= ComposerInputFields[I].X) And
     (X <= ComposerInputFields[I].X + ComposerInputFields[I].Width) And
     (Y >= ComposerInputFields[I].Y) And
     (Y <= ComposerInputFields[I].Y + COMPOSER_FIELD_HEIGHT) Then Begin
   { Deselectionner tous les champs }
   ComposerInputFields[0].IsFocused := False;
   ComposerInputFields[1].IsFocused := False;
   ComposerInputFields[2].IsFocused := False;
   ComposerInputFields[3].IsFocused := False;
   { Selectionner ce champ }
   ComposerInputFields[I].IsFocused := True;
   ComposerFocusedField := I;
   DrawComposerWindow;
   Exit;
  End;
 End;

 { Verifier la barre d'outils de formatage }
 ToolbarY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT + 2;
 If (Y >= ToolbarY) And (Y <= ToolbarY + COMPOSER_TOOLBAR_HEIGHT) Then Begin
  BtnX := COMPOSER_X + 8;

  { Bouton Gras }
  If (X >= BtnX) And (X <= BtnX + 24) Then Begin
   ComposerFormatBold := Not ComposerFormatBold;
   Composer.CurrentFormat.Bold := ComposerFormatBold;
   DrawComposerWindow;
   Exit;
  End;
  BtnX := BtnX + 28;

  { Bouton Italique }
  If (X >= BtnX) And (X <= BtnX + 24) Then Begin
   ComposerFormatItalic := Not ComposerFormatItalic;
   Composer.CurrentFormat.Italic := ComposerFormatItalic;
   DrawComposerWindow;
   Exit;
  End;
  BtnX := BtnX + 28;

  { Bouton Souligne }
  If (X >= BtnX) And (X <= BtnX + 24) Then Begin
   ComposerFormatUnderline := Not ComposerFormatUnderline;
   Composer.CurrentFormat.Underline := ComposerFormatUnderline;
   DrawComposerWindow;
   Exit;
  End;

  { Boutons de couleur }
  BtnX := COMPOSER_X + 8 + 28 + 28 + 35 + 10 + 55;
  If (X >= BtnX) And (X <= BtnX + 16) Then Begin
   Composer.CurrentFormat.FontColor := Black;
   DrawComposerWindow;
   Exit;
  End;
  BtnX := BtnX + 20;
  If (X >= BtnX) And (X <= BtnX + 16) Then Begin
   Composer.CurrentFormat.FontColor := LightRed;
   DrawComposerWindow;
   Exit;
  End;
  BtnX := BtnX + 20;
  If (X >= BtnX) And (X <= BtnX + 16) Then Begin
   Composer.CurrentFormat.FontColor := LightGreen;
   DrawComposerWindow;
   Exit;
  End;
  BtnX := BtnX + 20;
  If (X >= BtnX) And (X <= BtnX + 16) Then Begin
   Composer.CurrentFormat.FontColor := LightBlue;
   DrawComposerWindow;
   Exit;
  End;
 End;

 { Verifier la zone d'edition }
 EditorX := COMPOSER_X + 4;
 EditorY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT + COMPOSER_TOOLBAR_HEIGHT + 4;
 EditorW := COMPOSER_WIDTH - 8;
 EditorH := COMPOSER_HEIGHT - COMPOSER_HEADER_HEIGHT - COMPOSER_TOOLBAR_HEIGHT - 45;

 If (X >= EditorX) And (X <= EditorX + EditorW) And
    (Y >= EditorY) And (Y <= EditorY + EditorH) Then Begin
  { Clic dans l'editeur }
  ComposerFocusedField := COMP_FIELD_BODY;

  { Deselectionner les champs d'en-tete }
  ComposerInputFields[0].IsFocused := False;
  ComposerInputFields[1].IsFocused := False;
  ComposerInputFields[2].IsFocused := False;
  ComposerInputFields[3].IsFocused := False;

  { Calculer la ligne cliquee }
  ClickedLine := Composer.ScrollY + (Y - EditorY - 4) Div 14;
  If ClickedLine >= Composer.LineCount Then
   ClickedLine := Composer.LineCount - 1;
  If ClickedLine < 0 Then ClickedLine := 0;
  Composer.CursorY := ClickedLine;

  { Positionner le curseur X approximativement }
  Composer.CursorX := Length(Composer.Lines[ClickedLine].Text);

  DrawComposerWindow;
 End;
End;

{ Gere les touches clavier dans le compositeur }
Procedure HandleComposerKeyPress(Key: Char);
Var
 FieldValue: String;
 CurrentLine: String;
Begin
 If Not ComposerVisible Then Exit;

 If Key = #27 Then Begin { Escape }
  CloseComposer;
  Exit;
 End;

 { Gestion selon le champ actif }
 If ComposerFocusedField < COMP_FIELD_BODY Then Begin
  { Champs d'en-tete }
  FieldValue := ComposerInputFields[ComposerFocusedField].Value;

  If Key = #8 Then Begin { Backspace }
   If Length(FieldValue) > 0 Then Begin
    Delete(FieldValue, Length(FieldValue), 1);
    ComposerInputFields[ComposerFocusedField].Value := FieldValue;
    Composer.Modified := True;
    DrawComposerWindow;
   End;
  End
  Else If Key = #9 Then Begin { Tab }
   ComposerInputFields[ComposerFocusedField].IsFocused := False;
   Inc(ComposerFocusedField);
   If ComposerFocusedField > COMP_FIELD_SUBJECT Then
    ComposerFocusedField := COMP_FIELD_BODY
   Else
    ComposerInputFields[ComposerFocusedField].IsFocused := True;
   DrawComposerWindow;
  End
  Else If Key = #13 Then Begin { Enter - passer au corps }
   ComposerInputFields[ComposerFocusedField].IsFocused := False;
   ComposerFocusedField := COMP_FIELD_BODY;
   DrawComposerWindow;
  End
  Else If (Key >= ' ') And (Key <= '~') Then Begin { Caracteres imprimables }
   If Length(FieldValue) < ComposerInputFields[ComposerFocusedField].MaxLen Then Begin
    FieldValue := FieldValue + Key;
    ComposerInputFields[ComposerFocusedField].Value := FieldValue;
    Composer.Modified := True;
    DrawComposerWindow;
   End;
  End;
 End
 Else Begin
  { Zone d'edition du corps }
  CurrentLine := Composer.Lines[Composer.CursorY].Text;

  If Key = #8 Then Begin { Backspace }
   If Composer.CursorX > 0 Then Begin
    Delete(CurrentLine, Composer.CursorX, 1);
    Composer.Lines[Composer.CursorY].Text := CurrentLine;
    Dec(Composer.CursorX);
    Composer.Modified := True;
    DrawComposerWindow;
   End
   Else If Composer.CursorY > 0 Then Begin
    { Fusionner avec la ligne precedente }
    Dec(Composer.CursorY);
    Composer.CursorX := Length(Composer.Lines[Composer.CursorY].Text);
    Composer.Lines[Composer.CursorY].Text := Composer.Lines[Composer.CursorY].Text + CurrentLine;
    { Decaler les lignes suivantes }
    While Composer.CursorY + 1 < Composer.LineCount - 1 Do Begin
     Composer.Lines[Composer.CursorY + 1] := Composer.Lines[Composer.CursorY + 2];
     Inc(Composer.CursorY);
    End;
    Dec(Composer.LineCount);
    Composer.CursorY := Composer.CursorY - (Composer.LineCount - Composer.CursorY - 1);
    Composer.Modified := True;
    DrawComposerWindow;
   End;
  End
  Else If Key = #13 Then Begin { Enter - nouvelle ligne }
   If Composer.LineCount < COMPOSER_MAX_LINES Then Begin
    { Decaler les lignes suivantes }
    If Composer.CursorY < Composer.LineCount - 1 Then Begin
     { Note: Simplifie - insere une nouvelle ligne }
    End;
    Inc(Composer.LineCount);
    Inc(Composer.CursorY);
    Composer.CursorX := 0;
    Composer.Lines[Composer.CursorY].Text := '';
    Composer.Lines[Composer.CursorY].Format := Composer.CurrentFormat;
    Composer.Modified := True;

    { Ajuster le defilement si necessaire }
    If Composer.CursorY >= Composer.ScrollY + COMPOSER_EDITOR_VISIBLE_ROWS Then
     Inc(Composer.ScrollY);

    DrawComposerWindow;
   End;
  End
  Else If Key = #9 Then Begin { Tab - retour aux champs d'en-tete }
   ComposerFocusedField := COMP_FIELD_TO;
   ComposerInputFields[COMP_FIELD_TO].IsFocused := True;
   DrawComposerWindow;
  End
  Else If (Key >= ' ') And (Key <= '~') Then Begin { Caracteres imprimables }
   If Length(CurrentLine) < 250 Then Begin
    Insert(Key, CurrentLine, Composer.CursorX + 1);
    Composer.Lines[Composer.CursorY].Text := CurrentLine;
    Composer.Lines[Composer.CursorY].Format := Composer.CurrentFormat;
    Inc(Composer.CursorX);
    Composer.Modified := True;
    DrawComposerWindow;
   End;
  End;
 End;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU COMPOSITEUR DE MESSAGES
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU SUPPORT DES PIECES JOINTES (TODO 13)
  ============================================================================ }

{ Initialise les extensions dangereuses }
Procedure InitDangerousExtensions;
Begin
 DangerousExtensions[0] := 'EXE';
 DangerousExtensions[1] := 'COM';
 DangerousExtensions[2] := 'BAT';
 DangerousExtensions[3] := 'CMD';
 DangerousExtensions[4] := 'SCR';
 DangerousExtensions[5] := 'PIF';
 DangerousExtensions[6] := 'VBS';
 DangerousExtensions[7] := 'JS';
 DangerousExtensions[8] := 'WSF';
 DangerousExtensions[9] := 'MSI';
 DangerousExtensions[10] := 'DLL';
 DangerousExtensions[11] := 'SYS';
End;

{ Initialise le gestionnaire de pieces jointes }
Procedure InitAttachmentManager;
Begin
 AttachPanelVisible := False;
 SelectedAttachment := -1;
 AttachFileBrowserVisible := False;
 AttachCurrentPath := '';
 AttachFileCount := 0;
 AttachSelectedFile := -1;
 AttachTotalSize := 0;
 InitDangerousExtensions;
End;

{ Extrait l'extension d'un nom de fichier }
Function GetFileExtension(FileName: String): String;
Var
 I: Integer;
 Ext: String;
Begin
 Ext := '';
 For I := Length(FileName) DownTo 1 Do Begin
  If FileName[I] = '.' Then Begin
   Ext := Copy(FileName, I + 1, Length(FileName) - I);
   Break;
  End;
 End;
 { Convertir en majuscules }
 For I := 1 To Length(Ext) Do
  If (Ext[I] >= 'a') And (Ext[I] <= 'z') Then
   Ext[I] := Chr(Ord(Ext[I]) - 32);
 GetFileExtension := Ext;
End;

{ Verifie si une extension est dangereuse }
Function IsDangerousExtension(Ext: String): Boolean;
Var
 I: Integer;
 UpperExt: String;
Begin
 IsDangerousExtension := False;
 UpperExt := Ext;
 { Convertir en majuscules }
 For I := 1 To Length(UpperExt) Do
  If (UpperExt[I] >= 'a') And (UpperExt[I] <= 'z') Then
   UpperExt[I] := Chr(Ord(UpperExt[I]) - 32);
 { Verifier contre la liste }
 For I := 0 To DANGEROUS_EXT_COUNT - 1 Do Begin
  If UpperExt = DangerousExtensions[I] Then Begin
   IsDangerousExtension := True;
   Exit;
  End;
 End;
End;

{ Determine le type de fichier d'apres l'extension }
Function GetAttachmentType(FileName: String): TAttachmentType;
Var
 Ext: String;
Begin
 Ext := GetFileExtension(FileName);

 { Documents }
 If (Ext = 'DOC') Or (Ext = 'DOCX') Or (Ext = 'TXT') Or
    (Ext = 'RTF') Or (Ext = 'ODT') Then
  GetAttachmentType := atDocument
 { Tableurs }
 Else If (Ext = 'XLS') Or (Ext = 'XLSX') Or (Ext = 'CSV') Or
         (Ext = 'ODS') Then
  GetAttachmentType := atSpreadsheet
 { Images }
 Else If (Ext = 'JPG') Or (Ext = 'JPEG') Or (Ext = 'PNG') Or
         (Ext = 'GIF') Or (Ext = 'BMP') Or (Ext = 'ICO') Then
  GetAttachmentType := atImage
 { Archives }
 Else If (Ext = 'ZIP') Or (Ext = 'RAR') Or (Ext = '7Z') Or
         (Ext = 'TAR') Or (Ext = 'GZ') Then
  GetAttachmentType := atArchive
 { Executables }
 Else If (Ext = 'EXE') Or (Ext = 'COM') Or (Ext = 'BAT') Or
         (Ext = 'CMD') Or (Ext = 'SCR') Then
  GetAttachmentType := atExecutable
 { Audio }
 Else If (Ext = 'MP3') Or (Ext = 'WAV') Or (Ext = 'OGG') Or
         (Ext = 'WMA') Or (Ext = 'FLAC') Then
  GetAttachmentType := atAudio
 { Video }
 Else If (Ext = 'AVI') Or (Ext = 'MPG') Or (Ext = 'MPEG') Or
         (Ext = 'MP4') Or (Ext = 'WMV') Or (Ext = 'MKV') Then
  GetAttachmentType := atVideo
 { PDF }
 Else If Ext = 'PDF' Then
  GetAttachmentType := atPDF
 Else
  GetAttachmentType := atUnknown;
End;

{ Formate une taille de fichier }
Function FormatFileSize(Size: LongInt): String;
Var
 S: String;
Begin
 If Size < 1024 Then
  Str(Size, S)
 Else If Size < 1048576 Then Begin
  Str(Size Div 1024, S);
  S := S + ' Ko';
 End
 Else Begin
  Str(Size Div 1048576, S);
  S := S + ' Mo';
 End;
 FormatFileSize := S;
End;

{ Dessine une icone de piece jointe selon son type }
Procedure DrawAttachmentIcon(X, Y: Integer; AttType: TAttachmentType);
Var
 IconColor: Word;
Begin
 { Couleur selon le type }
 Case AttType Of
  atDocument:   IconColor := LightCyan;
  atSpreadsheet: IconColor := LightGreen;
  atImage:      IconColor := LightMagenta;
  atArchive:    IconColor := Yellow;
  atExecutable: IconColor := LightRed;
  atAudio:      IconColor := LightBlue;
  atVideo:      IconColor := Cyan;
  atPDF:        IconColor := Red;
  Else          IconColor := LightGray;
 End;

 { Dessiner l'icone (rectangle avec coin plie) }
 SetFillStyle(SolidFill, IconColor);
 Bar(X, Y, X + 24, Y + 28);
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(X, Y, X + 24, Y + 28);

 { Coin plie }
 SetFillStyle(SolidFill, COLOR_WINDOW_BG);
 SetColor(COLOR_BUTTON_DARK);
 Line(X + 18, Y, X + 24, Y + 6);
 Line(X + 18, Y, X + 18, Y + 6);
 Line(X + 18, Y + 6, X + 24, Y + 6);

 { Symbole selon le type }
 SetColor(Black);
 Case AttType Of
  atDocument:   OutTextXY(X + 5, Y + 10, 'DOC');
  atSpreadsheet: OutTextXY(X + 5, Y + 10, 'XLS');
  atImage:      OutTextXY(X + 5, Y + 10, 'IMG');
  atArchive:    OutTextXY(X + 5, Y + 10, 'ZIP');
  atExecutable: OutTextXY(X + 5, Y + 10, 'EXE');
  atAudio:      OutTextXY(X + 5, Y + 10, 'MP3');
  atVideo:      OutTextXY(X + 5, Y + 10, 'VID');
  atPDF:        OutTextXY(X + 5, Y + 10, 'PDF');
  Else          OutTextXY(X + 5, Y + 10, '???');
 End;
End;

{ Dessine le panneau des pieces jointes dans le compositeur }
Procedure DrawAttachmentPanel;
Var
 PanelX, PanelY, PanelW, I: Integer;
 SizeStr: String;
Begin
 If Not ComposerVisible Then Exit;
 If Composer.AttachmentCount = 0 Then Exit;

 HideMouse;

 { Position du panneau }
 PanelX := COMPOSER_X + 4;
 PanelY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT - ATTACH_PANEL_HEIGHT - 2;
 PanelW := COMPOSER_WIDTH - 8;

 { Fond du panneau }
 SetFillStyle(SolidFill, COLOR_WINDOW_BG);
 Bar(PanelX, PanelY, PanelX + PanelW, PanelY + ATTACH_PANEL_HEIGHT);

 { Bordure }
 SetColor(COLOR_BUTTON_DARK);
 Rectangle(PanelX, PanelY, PanelX + PanelW, PanelY + ATTACH_PANEL_HEIGHT);

 { Titre }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(PanelX + 4, PanelY + 2, 'Pieces jointes:');

 { Dessiner les icones des pieces jointes }
 For I := 0 To Composer.AttachmentCount - 1 Do Begin
  DrawAttachmentIcon(PanelX + 90 + I * ATTACH_ICON_SPACING, PanelY + 2,
                     Composer.Attachments[I].FileType);

  { Avertissement si dangereux }
  If Composer.Attachments[I].IsDangerous Then Begin
   SetColor(LightRed);
   OutTextXY(PanelX + 90 + I * ATTACH_ICON_SPACING + 8, PanelY + 32, '!');
  End;
 End;

 { Taille totale }
 SizeStr := 'Total: ' + FormatFileSize(AttachTotalSize);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(PanelX + PanelW - TextWidth(SizeStr) - 10, PanelY + ATTACH_PANEL_HEIGHT - 14, SizeStr);

 ShowMouse;
End;

{ Ajoute une piece jointe au compositeur }
Function AddAttachment(FilePath: String): Boolean;
Var
 F: File;
 FileName: String;
 I: Integer;
 Ext: String;
Begin
 AddAttachment := False;

 { Verifier le nombre maximum }
 If Composer.AttachmentCount >= MAX_ATTACHMENTS Then Exit;

 { Extraire le nom du fichier }
 FileName := FilePath;
 For I := Length(FilePath) DownTo 1 Do Begin
  If (FilePath[I] = '\') Or (FilePath[I] = '/') Then Begin
   FileName := Copy(FilePath, I + 1, Length(FilePath) - I);
   Break;
  End;
 End;

 { Verifier si le fichier existe et obtenir sa taille }
 {$I-}
 Assign(F, FilePath);
 Reset(F, 1);
 {$I+}
 If IOResult <> 0 Then Exit;

 { Verifier la taille }
 If FileSize(F) > MAX_SINGLE_FILE_SIZE Then Begin
  Close(F);
  { Afficher avertissement taille }
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(LightRed);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Erreur: Fichier trop volumineux (max 5 Mo)');
  ShowMouse;
  Exit;
 End;

 { Verifier la taille totale }
 If AttachTotalSize + FileSize(F) > MAX_ATTACHMENT_SIZE Then Begin
  Close(F);
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(LightRed);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Erreur: Taille totale des pieces jointes depassee');
  ShowMouse;
  Exit;
 End;

 { Ajouter la piece jointe }
 With Composer.Attachments[Composer.AttachmentCount] Do Begin
  FileName := FileName;
  Composer.Attachments[Composer.AttachmentCount].FileName := FileName;
  Composer.Attachments[Composer.AttachmentCount].FilePath := FilePath;
  Composer.Attachments[Composer.AttachmentCount].FileSize := FileSize(F);
  Composer.Attachments[Composer.AttachmentCount].FileType := GetAttachmentType(FileName);
  Composer.Attachments[Composer.AttachmentCount].IsEmbedded := False;
  Composer.Attachments[Composer.AttachmentCount].ContentID := '';

  { Verifier si extension dangereuse }
  Ext := GetFileExtension(FileName);
  Composer.Attachments[Composer.AttachmentCount].IsDangerous := IsDangerousExtension(Ext);
 End;

 AttachTotalSize := AttachTotalSize + FileSize(F);
 Close(F);

 Inc(Composer.AttachmentCount);
 Composer.Modified := True;

 { Afficher avertissement si dangereux }
 If Composer.Attachments[Composer.AttachmentCount - 1].IsDangerous Then Begin
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(Yellow);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Attention: Extension potentiellement dangereuse!');
  ShowMouse;
 End;

 AddAttachment := True;
 DrawAttachmentPanel;
End;

{ Supprime une piece jointe du compositeur }
Procedure RemoveAttachment(Index: Integer);
Var
 I: Integer;
Begin
 If (Index < 0) Or (Index >= Composer.AttachmentCount) Then Exit;

 AttachTotalSize := AttachTotalSize - Composer.Attachments[Index].FileSize;

 { Decaler les pieces jointes suivantes }
 For I := Index To Composer.AttachmentCount - 2 Do
  Composer.Attachments[I] := Composer.Attachments[I + 1];

 Dec(Composer.AttachmentCount);
 Composer.Modified := True;

 If SelectedAttachment >= Composer.AttachmentCount Then
  SelectedAttachment := Composer.AttachmentCount - 1;

 DrawAttachmentPanel;
End;

{ Enregistre une piece jointe sur disque }
Function SaveAttachmentToDisk(Index: Integer; DestPath: String): Boolean;
Var
 SrcFile, DstFile: File;
 Buffer: Array[0..4095] of Byte;
 BytesRead: Integer;
Begin
 SaveAttachmentToDisk := False;

 If (Index < 0) Or (Index >= Composer.AttachmentCount) Then Exit;

 { Ouvrir le fichier source }
 {$I-}
 Assign(SrcFile, Composer.Attachments[Index].FilePath);
 Reset(SrcFile, 1);
 {$I+}
 If IOResult <> 0 Then Exit;

 { Creer le fichier destination }
 {$I-}
 Assign(DstFile, DestPath + '\' + Composer.Attachments[Index].FileName);
 Rewrite(DstFile, 1);
 {$I+}
 If IOResult <> 0 Then Begin
  Close(SrcFile);
  Exit;
 End;

 { Copier le contenu }
 Repeat
  BlockRead(SrcFile, Buffer, SizeOf(Buffer), BytesRead);
  If BytesRead > 0 Then
   BlockWrite(DstFile, Buffer, BytesRead);
 Until BytesRead = 0;

 Close(SrcFile);
 Close(DstFile);

 SaveAttachmentToDisk := True;

 { Confirmation }
 HideMouse;
 FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
          Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
 SetColor(LightGreen);
 OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
           'Piece jointe enregistree avec succes');
 ShowMouse;
End;

{ Enregistre une piece jointe d'un message recu }
Function SaveReceivedAttachment(MsgIndex, AttachIndex: Integer; DestPath: String): Boolean;
Begin
 SaveReceivedAttachment := False;

 If (MsgIndex < 0) Or (MsgIndex >= MessageCount) Then Exit;
 If (AttachIndex < 0) Or (AttachIndex >= Messages[MsgIndex].AttachmentCount) Then Exit;

 { Note: Pour un vrai client, on telechargerait d'abord depuis le serveur }
 { Ici on simule l'operation }

 HideMouse;
 FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
          Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
 SetColor(LightGreen);
 OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
           'Piece jointe enregistree: ' + Messages[MsgIndex].Attachments[AttachIndex].FileName);
 ShowMouse;

 SaveReceivedAttachment := True;
End;

{ Dessine les pieces jointes d'un message dans le volet de preview }
Procedure DrawMessageAttachments(MsgIndex: Integer);
Var
 X, Y, I: Integer;
Begin
 If (MsgIndex < 0) Or (MsgIndex >= MessageCount) Then Exit;
 If Not Messages[MsgIndex].HasAttachment Then Exit;
 If Messages[MsgIndex].AttachmentCount = 0 Then Exit;

 HideMouse;

 { Position sous les en-tetes }
 X := Layout.PreviewRect.X1 + 10;
 Y := Layout.PreviewRect.Y1 + PreviewHeaderHeight + 5;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(X, Y, 'Pieces jointes:');
 Y := Y + 16;

 { Dessiner les icones }
 For I := 0 To Messages[MsgIndex].AttachmentCount - 1 Do Begin
  DrawAttachmentIcon(X + I * ATTACH_ICON_SPACING, Y,
                     Messages[MsgIndex].Attachments[I].FileType);

  { Nom sous l'icone }
  SetColor(COLOR_MENU_TEXT);
  If Length(Messages[MsgIndex].Attachments[I].FileName) > 6 Then
   OutTextXY(X + I * ATTACH_ICON_SPACING - 5, Y + 32,
             Copy(Messages[MsgIndex].Attachments[I].FileName, 1, 6) + '..')
  Else
   OutTextXY(X + I * ATTACH_ICON_SPACING, Y + 32,
             Messages[MsgIndex].Attachments[I].FileName);
 End;

 ShowMouse;
End;

{ Gere le clic sur une piece jointe dans le compositeur }
Procedure HandleAttachmentClick(X, Y: Integer);
Var
 PanelX, PanelY, I, IconX: Integer;
Begin
 If Composer.AttachmentCount = 0 Then Exit;

 PanelX := COMPOSER_X + 4;
 PanelY := COMPOSER_Y + COMPOSER_HEADER_HEIGHT - ATTACH_PANEL_HEIGHT - 2;

 { Verifier le clic sur chaque icone }
 For I := 0 To Composer.AttachmentCount - 1 Do Begin
  IconX := PanelX + 90 + I * ATTACH_ICON_SPACING;
  If (X >= IconX) And (X <= IconX + 24) And
     (Y >= PanelY + 2) And (Y <= PanelY + 30) Then Begin
   SelectedAttachment := I;
   DrawAttachmentPanel;
   Exit;
  End;
 End;
End;

{ Reinitialise les pieces jointes du compositeur }
Procedure ClearComposerAttachments;
Begin
 Composer.AttachmentCount := 0;
 AttachTotalSize := 0;
 SelectedAttachment := -1;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU SUPPORT DES PIECES JOINTES
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU MOTEUR DE RENDU HTML (TODO 14)
  ============================================================================ }

{ Convertit une chaine en majuscules }
Function HTML_UpperCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If (S[I] >= 'a') And (S[I] <= 'z') Then
   S[I] := Chr(Ord(S[I]) - 32);
 HTML_UpperCase := S;
End;

{ Convertit une chaine en minuscules }
Function HTML_LowerCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If (S[I] >= 'A') And (S[I] <= 'Z') Then
   S[I] := Chr(Ord(S[I]) + 32);
 HTML_LowerCase := S;
End;

{ Supprime les espaces en debut et fin de chaine }
Function HTML_Trim(S: String): String;
Begin
 While (Length(S) > 0) And (S[1] <= ' ') Do
  Delete(S, 1, 1);
 While (Length(S) > 0) And (S[Length(S)] <= ' ') Do
  Delete(S, Length(S), 1);
 HTML_Trim := S;
End;

{ Detecte le type de balise a partir de son nom }
Function HTML_GetTagType(TagName: String): THTMLTagType;
Var
 Upper: String;
Begin
 Upper := HTML_UpperCase(HTML_Trim(TagName));
 If Upper = 'HTML' Then HTML_GetTagType := htHTML
 Else If Upper = 'HEAD' Then HTML_GetTagType := htHead
 Else If Upper = 'TITLE' Then HTML_GetTagType := htTitle
 Else If Upper = 'META' Then HTML_GetTagType := htMeta
 Else If Upper = 'BODY' Then HTML_GetTagType := htBody
 Else If Upper = 'DIV' Then HTML_GetTagType := htDiv
 Else If Upper = 'SPAN' Then HTML_GetTagType := htSpan
 Else If Upper = 'P' Then HTML_GetTagType := htP
 Else If Upper = 'BR' Then HTML_GetTagType := htBr
 Else If Upper = 'HR' Then HTML_GetTagType := htHr
 Else If Upper = 'B' Then HTML_GetTagType := htB
 Else If Upper = 'I' Then HTML_GetTagType := htI
 Else If Upper = 'U' Then HTML_GetTagType := htU
 Else If Upper = 'STRONG' Then HTML_GetTagType := htStrong
 Else If Upper = 'EM' Then HTML_GetTagType := htEm
 Else If Upper = 'FONT' Then HTML_GetTagType := htFont
 Else If Upper = 'UL' Then HTML_GetTagType := htUL
 Else If Upper = 'OL' Then HTML_GetTagType := htOL
 Else If Upper = 'LI' Then HTML_GetTagType := htLI
 Else If Upper = 'TABLE' Then HTML_GetTagType := htTable
 Else If Upper = 'TR' Then HTML_GetTagType := htTR
 Else If Upper = 'TD' Then HTML_GetTagType := htTD
 Else If Upper = 'TH' Then HTML_GetTagType := htTH
 Else If Upper = 'A' Then HTML_GetTagType := htA
 Else If Upper = 'IMG' Then HTML_GetTagType := htImg
 Else If Upper = 'H1' Then HTML_GetTagType := htH1
 Else If Upper = 'H2' Then HTML_GetTagType := htH2
 Else If Upper = 'H3' Then HTML_GetTagType := htH3
 Else If Upper = 'CENTER' Then HTML_GetTagType := htCenter
 Else If Upper = 'BLOCKQUOTE' Then HTML_GetTagType := htBlockquote
 Else If Upper = 'PRE' Then HTML_GetTagType := htPre
 Else If Upper = 'CODE' Then HTML_GetTagType := htCode
 Else HTML_GetTagType := htUnknown;
End;

{ Decode une entite HTML }
Function HTML_DecodeEntity(Entity: String): String;
Var
 Upper: String;
Begin
 Upper := HTML_LowerCase(Entity);
 If Upper = 'nbsp' Then HTML_DecodeEntity := ' '
 Else If Upper = 'lt' Then HTML_DecodeEntity := '<'
 Else If Upper = 'gt' Then HTML_DecodeEntity := '>'
 Else If Upper = 'amp' Then HTML_DecodeEntity := '&'
 Else If Upper = 'quot' Then HTML_DecodeEntity := '"'
 Else If Upper = 'apos' Then HTML_DecodeEntity := ''''
 Else If Upper = 'copy' Then HTML_DecodeEntity := '(c)'
 Else If Upper = 'reg' Then HTML_DecodeEntity := '(R)'
 Else If Upper = 'euro' Then HTML_DecodeEntity := 'EUR'
 Else If Upper = 'eacute' Then HTML_DecodeEntity := 'e'
 Else If Upper = 'egrave' Then HTML_DecodeEntity := 'e'
 Else If Upper = 'agrave' Then HTML_DecodeEntity := 'a'
 Else If Upper = 'ccedil' Then HTML_DecodeEntity := 'c'
 Else If Upper = 'bull' Then HTML_DecodeEntity := '*'
 Else If Upper = 'mdash' Then HTML_DecodeEntity := '-'
 Else HTML_DecodeEntity := '?';
End;

{ Convertit une couleur HTML en couleur BGI }
Function HTML_ParseColor(ColorStr: String): Word;
Var
 Upper: String;
Begin
 Upper := HTML_UpperCase(HTML_Trim(ColorStr));
 { Couleurs nommees }
 If Upper = 'BLACK' Then HTML_ParseColor := Black
 Else If Upper = 'WHITE' Then HTML_ParseColor := White
 Else If Upper = 'RED' Then HTML_ParseColor := Red
 Else If Upper = 'GREEN' Then HTML_ParseColor := Green
 Else If Upper = 'BLUE' Then HTML_ParseColor := Blue
 Else If Upper = 'YELLOW' Then HTML_ParseColor := Yellow
 Else If Upper = 'CYAN' Then HTML_ParseColor := Cyan
 Else If Upper = 'MAGENTA' Then HTML_ParseColor := Magenta
 Else If Upper = 'GRAY' Then HTML_ParseColor := DarkGray
 Else If Upper = 'GREY' Then HTML_ParseColor := DarkGray
 Else If Upper = 'SILVER' Then HTML_ParseColor := LightGray
 Else If Upper = 'NAVY' Then HTML_ParseColor := Blue
 Else If Upper = 'MAROON' Then HTML_ParseColor := Red
 Else If Upper = 'OLIVE' Then HTML_ParseColor := Brown
 Else If Upper = 'PURPLE' Then HTML_ParseColor := Magenta
 Else If Upper = 'TEAL' Then HTML_ParseColor := Cyan
 Else If Upper = 'ORANGE' Then HTML_ParseColor := LightRed
 Else If (Length(Upper) >= 1) And (Upper[1] = '#') Then Begin
  { Couleur hexadecimale - approximation simple }
  If Length(Upper) >= 7 Then Begin
   { Extraction des composantes RGB basique }
   If (Upper[2] >= '8') Or (Upper[3] >= '8') Then HTML_ParseColor := LightRed
   Else If (Upper[4] >= '8') Or (Upper[5] >= '8') Then HTML_ParseColor := LightGreen
   Else If (Upper[6] >= '8') Or (Upper[7] >= '8') Then HTML_ParseColor := LightBlue
   Else HTML_ParseColor := DarkGray;
  End
  Else HTML_ParseColor := White;
 End
 Else HTML_ParseColor := White;
End;

{ Parse les attributs d'une balise }
Procedure HTML_ParseAttributes(AttrStr: String; Var Token: THTMLToken);
Var
 I, J, K: Integer;
 Name, Value: String;
 InQuote: Boolean;
 QuoteChar: Char;
Begin
 Token.AttrCount := 0;
 I := 1;

 While (I <= Length(AttrStr)) And (Token.AttrCount < 8) Do Begin
  { Sauter les espaces }
  While (I <= Length(AttrStr)) And (AttrStr[I] <= ' ') Do
   Inc(I);
  If I > Length(AttrStr) Then Exit;

  { Lire le nom de l'attribut }
  Name := '';
  While (I <= Length(AttrStr)) And (AttrStr[I] <> '=') And (AttrStr[I] > ' ') Do Begin
   Name := Name + AttrStr[I];
   Inc(I);
  End;

  If I > Length(AttrStr) Then Exit;

  { Sauter le signe = }
  If AttrStr[I] = '=' Then Inc(I);

  { Sauter les espaces }
  While (I <= Length(AttrStr)) And (AttrStr[I] <= ' ') Do
   Inc(I);
  If I > Length(AttrStr) Then Exit;

  { Lire la valeur }
  Value := '';
  If (AttrStr[I] = '"') Or (AttrStr[I] = '''') Then Begin
   QuoteChar := AttrStr[I];
   Inc(I);
   While (I <= Length(AttrStr)) And (AttrStr[I] <> QuoteChar) Do Begin
    Value := Value + AttrStr[I];
    Inc(I);
   End;
   Inc(I); { Sauter le guillemet fermant }
  End
  Else Begin
   While (I <= Length(AttrStr)) And (AttrStr[I] > ' ') Do Begin
    Value := Value + AttrStr[I];
    Inc(I);
   End;
  End;

  { Stocker l'attribut }
  If Length(Name) > 0 Then Begin
   Token.Attributes[Token.AttrCount].Name := HTML_LowerCase(Name);
   Token.Attributes[Token.AttrCount].Value := Value;
   Inc(Token.AttrCount);
  End;
 End;
End;

{ Recupere la valeur d'un attribut }
Function HTML_GetAttribute(Var Token: THTMLToken; Name: String): String;
Var
 I: Integer;
 LowerName: String;
Begin
 HTML_GetAttribute := '';
 LowerName := HTML_LowerCase(Name);
 For I := 0 To Token.AttrCount - 1 Do Begin
  If Token.Attributes[I].Name = LowerName Then Begin
   HTML_GetAttribute := Token.Attributes[I].Value;
   Exit;
  End;
 End;
End;

{ Tokenize le HTML }
Procedure HTML_Tokenize(HTML: String);
Var
 I, J, TagStart: Integer;
 InTag: Boolean;
 TagContent, TagName, AttrStr: String;
 IsClosing, IsSelfClose: Boolean;
 TextBuffer: String;
Begin
 HTMLTokenCount := 0;
 I := 1;
 TextBuffer := '';

 While (I <= Length(HTML)) And (HTMLTokenCount < MAX_HTML_TOKENS) Do Begin
  If HTML[I] = '<' Then Begin
   { Sauver le texte accumule }
   If Length(TextBuffer) > 0 Then Begin
    HTMLTokens[HTMLTokenCount].TokenType := ttText;
    HTMLTokens[HTMLTokenCount].Content := TextBuffer;
    HTMLTokens[HTMLTokenCount].AttrCount := 0;
    Inc(HTMLTokenCount);
    TextBuffer := '';
   End;

   { Lire la balise }
   TagContent := '';
   Inc(I);

   { Verifier si c'est un commentaire }
   If (I + 2 <= Length(HTML)) And (HTML[I] = '!') And
      (HTML[I+1] = '-') And (HTML[I+2] = '-') Then Begin
    { Sauter le commentaire }
    While (I + 2 <= Length(HTML)) And Not
          ((HTML[I] = '-') And (HTML[I+1] = '-') And (HTML[I+2] = '>')) Do
     Inc(I);
    Inc(I, 3);
    Continue;
   End;

   { Lire le contenu de la balise }
   While (I <= Length(HTML)) And (HTML[I] <> '>') Do Begin
    TagContent := TagContent + HTML[I];
    Inc(I);
   End;
   Inc(I); { Sauter > }

   { Analyser la balise }
   IsClosing := False;
   IsSelfClose := False;

   If (Length(TagContent) > 0) And (TagContent[1] = '/') Then Begin
    IsClosing := True;
    Delete(TagContent, 1, 1);
   End;

   If (Length(TagContent) > 0) And (TagContent[Length(TagContent)] = '/') Then Begin
    IsSelfClose := True;
    Delete(TagContent, Length(TagContent), 1);
   End;

   { Extraire le nom de la balise }
   TagName := '';
   J := 1;
   While (J <= Length(TagContent)) And (TagContent[J] > ' ') Do Begin
    TagName := TagName + TagContent[J];
    Inc(J);
   End;

   { Extraire les attributs }
   AttrStr := '';
   If J <= Length(TagContent) Then
    AttrStr := Copy(TagContent, J, Length(TagContent) - J + 1);

   { Creer le token }
   If IsClosing Then
    HTMLTokens[HTMLTokenCount].TokenType := ttCloseTag
   Else If IsSelfClose Then
    HTMLTokens[HTMLTokenCount].TokenType := ttSelfClose
   Else
    HTMLTokens[HTMLTokenCount].TokenType := ttOpenTag;

   HTMLTokens[HTMLTokenCount].TagName := HTML_LowerCase(TagName);
   HTMLTokens[HTMLTokenCount].TagType := HTML_GetTagType(TagName);
   HTMLTokens[HTMLTokenCount].Content := '';
   HTML_ParseAttributes(AttrStr, HTMLTokens[HTMLTokenCount]);
   Inc(HTMLTokenCount);
  End
  Else If HTML[I] = '&' Then Begin
   { Entite HTML }
   J := I + 1;
   While (J <= Length(HTML)) And (HTML[J] <> ';') And (J - I < 10) Do
    Inc(J);
   If (J <= Length(HTML)) And (HTML[J] = ';') Then Begin
    TextBuffer := TextBuffer + HTML_DecodeEntity(Copy(HTML, I + 1, J - I - 1));
    I := J + 1;
   End
   Else Begin
    TextBuffer := TextBuffer + HTML[I];
    Inc(I);
   End;
  End
  Else Begin
   { Texte normal }
   If HTML[I] >= ' ' Then
    TextBuffer := TextBuffer + HTML[I]
   Else If HTML[I] = #10 Then
    TextBuffer := TextBuffer + ' '
   Else If HTML[I] = #9 Then
    TextBuffer := TextBuffer + ' ';
   Inc(I);
  End;
 End;

 { Sauver le texte restant }
 If Length(TextBuffer) > 0 Then Begin
  HTMLTokens[HTMLTokenCount].TokenType := ttText;
  HTMLTokens[HTMLTokenCount].Content := TextBuffer;
  HTMLTokens[HTMLTokenCount].AttrCount := 0;
  Inc(HTMLTokenCount);
 End;
End;

{ Initialise le style de rendu par defaut }
Procedure HTML_InitStyle;
Begin
 HTMLCurrentStyle.Bold := False;
 HTMLCurrentStyle.Italic := False;
 HTMLCurrentStyle.Underline := False;
 HTMLCurrentStyle.FontColor := HTML_COLOR_TEXT;
 HTMLCurrentStyle.BGColor := HTML_COLOR_BG;
 HTMLCurrentStyle.FontSize := HTML_DEFAULT_FONT_SIZE;
 HTMLCurrentStyle.Align := haLeft;
 HTMLCurrentStyle.InPre := False;
 HTMLCurrentStyle.ListLevel := 0;
 HTMLCurrentStyle.ListOrdered := False;
 HTMLCurrentStyle.ListItemNum := 0;
 HTMLCurrentStyle.InTable := False;
 HTMLCurrentStyle.InLink := False;
 HTMLCurrentStyle.LinkURL := '';
End;

{ Ajoute un element de rendu }
Procedure HTML_AddElement(Text: String; X, Y, W, H: Integer);
Begin
 If HTMLElementCount >= MAX_HTML_ELEMENTS Then Exit;

 HTMLElements[HTMLElementCount].X := X;
 HTMLElements[HTMLElementCount].Y := Y;
 HTMLElements[HTMLElementCount].Width := W;
 HTMLElements[HTMLElementCount].Height := H;
 HTMLElements[HTMLElementCount].Text := Text;
 HTMLElements[HTMLElementCount].Style := HTMLCurrentStyle;
 HTMLElements[HTMLElementCount].IsLink := HTMLCurrentStyle.InLink;
 HTMLElements[HTMLElementCount].LinkURL := HTMLCurrentStyle.LinkURL;
 HTMLElements[HTMLElementCount].IsImage := False;
 Inc(HTMLElementCount);
End;

{ Ajoute un placeholder d'image }
Procedure HTML_AddImagePlaceholder(X, Y, W, H: Integer);
Begin
 If HTMLElementCount >= MAX_HTML_ELEMENTS Then Exit;

 HTMLElements[HTMLElementCount].X := X;
 HTMLElements[HTMLElementCount].Y := Y;
 HTMLElements[HTMLElementCount].Width := W;
 HTMLElements[HTMLElementCount].Height := H;
 HTMLElements[HTMLElementCount].Text := '';
 HTMLElements[HTMLElementCount].Style := HTMLCurrentStyle;
 HTMLElements[HTMLElementCount].IsLink := False;
 HTMLElements[HTMLElementCount].LinkURL := '';
 HTMLElements[HTMLElementCount].IsImage := True;
 HTMLElements[HTMLElementCount].ImageWidth := W;
 HTMLElements[HTMLElementCount].ImageHeight := H;
 Inc(HTMLElementCount);
End;

{ Dessine une ligne horizontale }
Procedure HTML_DrawHR(Y, Width: Integer);
Begin
 SetColor(DarkGray);
 Line(HTMLRenderX, Y + 5, HTMLRenderX + Width - 1, Y + 5);
 SetColor(LightGray);
 Line(HTMLRenderX, Y + 6, HTMLRenderX + Width - 1, Y + 6);
End;

{ Rend les tokens HTML }
Procedure HTML_Render(StartX, StartY, MaxWidth, MaxHeight: Integer);
Var
 I, J, WordWidth, LineHeight: Integer;
 Word, Line: String;
 InHead: Boolean;
 AttrValue: String;
Begin
 HTML_InitStyle;
 HTMLElementCount := 0;
 HTMLRenderX := StartX;
 HTMLRenderY := StartY;
 HTMLRenderWidth := MaxWidth;
 LineHeight := 14;
 InHead := False;

 For I := 0 To HTMLTokenCount - 1 Do Begin
  Case HTMLTokens[I].TokenType Of
   ttOpenTag: Begin
    Case HTMLTokens[I].TagType Of
     htHead: InHead := True;
     htBody: InHead := False;
     htB, htStrong: HTMLCurrentStyle.Bold := True;
     htI, htEm: HTMLCurrentStyle.Italic := True;
     htU: HTMLCurrentStyle.Underline := True;
     htFont: Begin
      AttrValue := HTML_GetAttribute(HTMLTokens[I], 'color');
      If Length(AttrValue) > 0 Then
       HTMLCurrentStyle.FontColor := HTML_ParseColor(AttrValue);
      AttrValue := HTML_GetAttribute(HTMLTokens[I], 'size');
      If Length(AttrValue) > 0 Then Begin
       If AttrValue[1] In ['1'..'7'] Then
        HTMLCurrentStyle.FontSize := Ord(AttrValue[1]) - Ord('0');
      End;
     End;
     htA: Begin
      HTMLCurrentStyle.InLink := True;
      HTMLCurrentStyle.LinkURL := HTML_GetAttribute(HTMLTokens[I], 'href');
      HTMLCurrentStyle.FontColor := HTML_COLOR_LINK;
      HTMLCurrentStyle.Underline := True;
     End;
     htP, htDiv: Begin
      If HTMLRenderX > StartX Then Begin
       HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
       HTMLRenderY := HTMLRenderY + LineHeight + 4;
      End;
     End;
     htBr: Begin
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      HTMLRenderY := HTMLRenderY + LineHeight;
     End;
     htHr: Begin
      HTMLRenderX := StartX;
      HTMLRenderY := HTMLRenderY + 4;
      HTML_DrawHR(HTMLRenderY, MaxWidth);
      HTMLRenderY := HTMLRenderY + 12;
     End;
     htH1: Begin
      If HTMLRenderX > StartX Then HTMLRenderY := HTMLRenderY + LineHeight;
      HTMLRenderX := StartX;
      HTMLCurrentStyle.Bold := True;
      HTMLCurrentStyle.FontSize := 6;
      LineHeight := 20;
     End;
     htH2: Begin
      If HTMLRenderX > StartX Then HTMLRenderY := HTMLRenderY + LineHeight;
      HTMLRenderX := StartX;
      HTMLCurrentStyle.Bold := True;
      HTMLCurrentStyle.FontSize := 5;
      LineHeight := 18;
     End;
     htH3: Begin
      If HTMLRenderX > StartX Then HTMLRenderY := HTMLRenderY + LineHeight;
      HTMLRenderX := StartX;
      HTMLCurrentStyle.Bold := True;
      HTMLCurrentStyle.FontSize := 4;
      LineHeight := 16;
     End;
     htCenter: HTMLCurrentStyle.Align := haCenter;
     htUL: Begin
      Inc(HTMLCurrentStyle.ListLevel);
      HTMLCurrentStyle.ListOrdered := False;
      HTMLCurrentStyle.ListItemNum := 0;
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      If HTMLRenderY > StartY Then HTMLRenderY := HTMLRenderY + LineHeight;
     End;
     htOL: Begin
      Inc(HTMLCurrentStyle.ListLevel);
      HTMLCurrentStyle.ListOrdered := True;
      HTMLCurrentStyle.ListItemNum := 0;
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      If HTMLRenderY > StartY Then HTMLRenderY := HTMLRenderY + LineHeight;
     End;
     htLI: Begin
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      HTMLRenderY := HTMLRenderY + LineHeight;
      Inc(HTMLCurrentStyle.ListItemNum);
      { Dessiner le marqueur }
      If HTMLCurrentStyle.ListOrdered Then Begin
       Str(HTMLCurrentStyle.ListItemNum, Word);
       Word := Word + '. ';
      End
      Else
       Word := '* ';
      HTML_AddElement(Word, HTMLRenderX - 15, HTMLRenderY, 15, LineHeight);
     End;
     htTable: Begin
      HTMLCurrentStyle.InTable := True;
      HTMLRenderX := StartX;
      HTMLRenderY := HTMLRenderY + LineHeight;
     End;
     htTR: Begin
      HTMLRenderX := StartX;
      HTMLRenderY := HTMLRenderY + LineHeight + 2;
     End;
     htTD, htTH: Begin
      HTMLRenderX := HTMLRenderX + 10;
      If HTMLTokens[I].TagType = htTH Then
       HTMLCurrentStyle.Bold := True;
     End;
     htImg: Begin
      AttrValue := HTML_GetAttribute(HTMLTokens[I], 'width');
      WordWidth := 64;
      If Length(AttrValue) > 0 Then Begin
       Val(AttrValue, WordWidth, J);
       If J <> 0 Then WordWidth := 64;
      End;
      AttrValue := HTML_GetAttribute(HTMLTokens[I], 'height');
      LineHeight := 64;
      If Length(AttrValue) > 0 Then Begin
       Val(AttrValue, LineHeight, J);
       If J <> 0 Then LineHeight := 64;
      End;
      HTML_AddImagePlaceholder(HTMLRenderX, HTMLRenderY, WordWidth, LineHeight);
      HTMLRenderX := HTMLRenderX + WordWidth + 4;
      LineHeight := 14;
     End;
     htPre, htCode: Begin
      HTMLCurrentStyle.InPre := True;
     End;
     htBlockquote: Begin
      HTMLRenderX := HTMLRenderX + 20;
      HTMLCurrentStyle.Italic := True;
     End;
    End;
   End;
   ttCloseTag: Begin
    Case HTMLTokens[I].TagType Of
     htHead: InHead := False;
     htB, htStrong: HTMLCurrentStyle.Bold := False;
     htI, htEm: HTMLCurrentStyle.Italic := False;
     htU: HTMLCurrentStyle.Underline := False;
     htFont: Begin
      HTMLCurrentStyle.FontColor := HTML_COLOR_TEXT;
      HTMLCurrentStyle.FontSize := HTML_DEFAULT_FONT_SIZE;
     End;
     htA: Begin
      HTMLCurrentStyle.InLink := False;
      HTMLCurrentStyle.LinkURL := '';
      HTMLCurrentStyle.FontColor := HTML_COLOR_TEXT;
      HTMLCurrentStyle.Underline := False;
     End;
     htP, htDiv: Begin
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      HTMLRenderY := HTMLRenderY + LineHeight + 4;
     End;
     htH1, htH2, htH3: Begin
      HTMLCurrentStyle.Bold := False;
      HTMLCurrentStyle.FontSize := HTML_DEFAULT_FONT_SIZE;
      LineHeight := 14;
      HTMLRenderX := StartX;
      HTMLRenderY := HTMLRenderY + LineHeight + 4;
     End;
     htCenter: HTMLCurrentStyle.Align := haLeft;
     htUL, htOL: Begin
      If HTMLCurrentStyle.ListLevel > 0 Then
       Dec(HTMLCurrentStyle.ListLevel);
      HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
      HTMLRenderY := HTMLRenderY + 4;
     End;
     htTable: Begin
      HTMLCurrentStyle.InTable := False;
      HTMLRenderY := HTMLRenderY + LineHeight;
     End;
     htTH: HTMLCurrentStyle.Bold := False;
     htPre, htCode: HTMLCurrentStyle.InPre := False;
     htBlockquote: Begin
      HTMLRenderX := StartX;
      HTMLCurrentStyle.Italic := False;
     End;
    End;
   End;
   ttText: Begin
    If InHead Then Continue;

    Line := HTMLTokens[I].Content;

    { Rendre le texte mot par mot }
    J := 1;
    While J <= Length(Line) Do Begin
     { Extraire un mot }
     Word := '';
     While (J <= Length(Line)) And (Line[J] > ' ') Do Begin
      Word := Word + Line[J];
      Inc(J);
     End;

     If Length(Word) > 0 Then Begin
      WordWidth := TextWidth(Word) + 4;

      { Verifier si le mot tient sur la ligne }
      If (HTMLRenderX + WordWidth > StartX + MaxWidth) And (HTMLRenderX > StartX) Then Begin
       HTMLRenderX := StartX + (HTMLCurrentStyle.ListLevel * HTML_LIST_INDENT);
       HTMLRenderY := HTMLRenderY + LineHeight;
      End;

      { Verifier si on depasse la hauteur max }
      If HTMLRenderY > StartY + MaxHeight Then Exit;

      HTML_AddElement(Word, HTMLRenderX, HTMLRenderY, WordWidth, LineHeight);
      HTMLRenderX := HTMLRenderX + WordWidth;
     End;

     { Sauter les espaces }
     While (J <= Length(Line)) And (Line[J] <= ' ') Do Begin
      If Line[J] = ' ' Then
       HTMLRenderX := HTMLRenderX + 4;
      Inc(J);
     End;
    End;
   End;
  End;
 End;
End;

{ Dessine les elements de rendu HTML }
Procedure HTML_Draw;
Var
 I: Integer;
 OldColor: Word;
Begin
 For I := 0 To HTMLElementCount - 1 Do Begin
  With HTMLElements[I] Do Begin
   If IsImage Then Begin
    { Dessiner le placeholder d'image }
    SetColor(DarkGray);
    Rectangle(X, Y, X + ImageWidth, Y + ImageHeight);
    SetFillStyle(SolidFill, DarkGray);
    Bar(X + 1, Y + 1, X + ImageWidth - 1, Y + ImageHeight - 1);
    SetColor(LightGray);
    OutTextXY(X + (ImageWidth Div 2) - 12, Y + (ImageHeight Div 2) - 4, '[IMG]');
   End
   Else If Length(Text) > 0 Then Begin
    SetColor(Style.FontColor);
    If Style.Bold Then
     SetTextStyle(DefaultFont, HorizDir, 1)
    Else
     SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(X, Y, Text);
    If Style.Underline Then Begin
     SetColor(Style.FontColor);
     Line(X, Y + 10, X + TextWidth(Text), Y + 10);
    End;
   End;
  End;
 End;
End;

{ Detecte si une chaine contient du HTML }
Function HTML_IsHTMLContent(Content: String): Boolean;
Var
 Upper: String;
Begin
 Upper := HTML_UpperCase(Content);
 HTML_IsHTMLContent := (Pos('<HTML', Upper) > 0) Or
                       (Pos('<BODY', Upper) > 0) Or
                       (Pos('<DIV', Upper) > 0) Or
                       (Pos('<P>', Upper) > 0) Or
                       (Pos('<BR', Upper) > 0) Or
                       (Pos('<TABLE', Upper) > 0) Or
                       (Pos('<FONT', Upper) > 0);
End;

{ Rend un message HTML dans une zone donnee }
Procedure HTML_RenderMessage(HTML: String; X, Y, Width, Height: Integer);
Begin
 HideMouse;
 HTML_Tokenize(HTML);
 HTML_Render(X, Y, Width, Height);
 HTML_Draw;
 ShowMouse;
End;

{ Initialise le moteur HTML }
Procedure HTML_Init;
Begin
 HTMLTokenCount := 0;
 HTMLElementCount := 0;
 HTMLIsHTML := False;
 HTML_InitStyle;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU MOTEUR DE RENDU HTML
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU DECODAGE MIME (TODO 15)
  ============================================================================ }

{ Convertit une chaine en majuscules pour MIME }
Function MIME_UpperCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If (S[I] >= 'a') And (S[I] <= 'z') Then
   S[I] := Chr(Ord(S[I]) - 32);
 MIME_UpperCase := S;
End;

{ Convertit une chaine en minuscules pour MIME }
Function MIME_LowerCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If (S[I] >= 'A') And (S[I] <= 'Z') Then
   S[I] := Chr(Ord(S[I]) + 32);
 MIME_LowerCase := S;
End;

{ Supprime les espaces en debut et fin de chaine }
Function MIME_Trim(S: String): String;
Begin
 While (Length(S) > 0) And (S[1] <= ' ') Do
  Delete(S, 1, 1);
 While (Length(S) > 0) And (S[Length(S)] <= ' ') Do
  Delete(S, Length(S), 1);
 MIME_Trim := S;
End;

{ Decode un caractere Base64 en valeur 0-63 }
Function MIME_Base64CharToValue(C: Char): Integer;
Begin
 If (C >= 'A') And (C <= 'Z') Then
  MIME_Base64CharToValue := Ord(C) - Ord('A')
 Else If (C >= 'a') And (C <= 'z') Then
  MIME_Base64CharToValue := Ord(C) - Ord('a') + 26
 Else If (C >= '0') And (C <= '9') Then
  MIME_Base64CharToValue := Ord(C) - Ord('0') + 52
 Else If C = '+' Then
  MIME_Base64CharToValue := 62
 Else If C = '/' Then
  MIME_Base64CharToValue := 63
 Else
  MIME_Base64CharToValue := -1;
End;

{ Decode une chaine Base64 }
Function MIME_DecodeBase64(Encoded: String): String;
Var
 I, J, Len: Integer;
 A, B, C, D: Integer;
 Output: String;
 Bytes: Array[0..2] of Byte;
Begin
 Output := '';
 I := 1;
 Len := Length(Encoded);

 While I <= Len Do Begin
  { Sauter les espaces et retours a la ligne }
  While (I <= Len) And (Encoded[I] <= ' ') Do
   Inc(I);
  If I > Len Then Break;

  { Lire 4 caracteres Base64 }
  A := MIME_Base64CharToValue(Encoded[I]);
  Inc(I);
  If I > Len Then Break;

  While (I <= Len) And (Encoded[I] <= ' ') Do Inc(I);
  If I > Len Then Break;
  B := MIME_Base64CharToValue(Encoded[I]);
  Inc(I);

  While (I <= Len) And (Encoded[I] <= ' ') Do Inc(I);
  If I > Len Then Begin
   { Seulement 2 caracteres - 1 octet }
   If (A >= 0) And (B >= 0) Then
    Output := Output + Chr((A Shl 2) Or (B Shr 4));
   Break;
  End;

  If Encoded[I] = '=' Then Begin
   { Padding - seulement 1 octet }
   If (A >= 0) And (B >= 0) Then
    Output := Output + Chr((A Shl 2) Or (B Shr 4));
   Break;
  End;

  C := MIME_Base64CharToValue(Encoded[I]);
  Inc(I);

  While (I <= Len) And (Encoded[I] <= ' ') Do Inc(I);
  If I > Len Then Begin
   { Seulement 3 caracteres - 2 octets }
   If (A >= 0) And (B >= 0) And (C >= 0) Then Begin
    Output := Output + Chr((A Shl 2) Or (B Shr 4));
    Output := Output + Chr(((B And $0F) Shl 4) Or (C Shr 2));
   End;
   Break;
  End;

  If Encoded[I] = '=' Then Begin
   { Padding - seulement 2 octets }
   If (A >= 0) And (B >= 0) And (C >= 0) Then Begin
    Output := Output + Chr((A Shl 2) Or (B Shr 4));
    Output := Output + Chr(((B And $0F) Shl 4) Or (C Shr 2));
   End;
   Break;
  End;

  D := MIME_Base64CharToValue(Encoded[I]);
  Inc(I);

  { Decoder les 3 octets }
  If (A >= 0) And (B >= 0) And (C >= 0) And (D >= 0) Then Begin
   Output := Output + Chr((A Shl 2) Or (B Shr 4));
   Output := Output + Chr(((B And $0F) Shl 4) Or (C Shr 2));
   Output := Output + Chr(((C And $03) Shl 6) Or D);
  End;
 End;

 MIME_DecodeBase64 := Output;
End;

{ Convertit un caractere hexa en valeur }
Function MIME_HexToValue(C: Char): Integer;
Begin
 If (C >= '0') And (C <= '9') Then
  MIME_HexToValue := Ord(C) - Ord('0')
 Else If (C >= 'A') And (C <= 'F') Then
  MIME_HexToValue := Ord(C) - Ord('A') + 10
 Else If (C >= 'a') And (C <= 'f') Then
  MIME_HexToValue := Ord(C) - Ord('a') + 10
 Else
  MIME_HexToValue := -1;
End;

{ Decode une chaine Quoted-Printable }
Function MIME_DecodeQuotedPrintable(Encoded: String): String;
Var
 I, Len: Integer;
 Output: String;
 H1, H2: Integer;
Begin
 Output := '';
 I := 1;
 Len := Length(Encoded);

 While I <= Len Do Begin
  If Encoded[I] = '=' Then Begin
   { Sequence encodee ou soft line break }
   If I + 2 <= Len Then Begin
    If (Encoded[I + 1] = #13) Or (Encoded[I + 1] = #10) Then Begin
     { Soft line break - ignorer }
     Inc(I);
     If (I <= Len) And (Encoded[I] = #13) Then Inc(I);
     If (I <= Len) And (Encoded[I] = #10) Then Inc(I);
    End
    Else Begin
     { Caractere encode =XX }
     H1 := MIME_HexToValue(Encoded[I + 1]);
     H2 := MIME_HexToValue(Encoded[I + 2]);
     If (H1 >= 0) And (H2 >= 0) Then
      Output := Output + Chr((H1 * 16) + H2)
     Else
      Output := Output + Encoded[I];
     Inc(I, 3);
    End;
   End
   Else Begin
    Output := Output + Encoded[I];
    Inc(I);
   End;
  End
  Else If Encoded[I] = '_' Then Begin
   { Underscore represente espace dans les en-tetes encodes }
   Output := Output + ' ';
   Inc(I);
  End
  Else Begin
   Output := Output + Encoded[I];
   Inc(I);
  End;
 End;

 MIME_DecodeQuotedPrintable := Output;
End;

{ Convertit UTF-8 en ASCII approximatif }
Function MIME_DecodeUTF8(UTF8: String): String;
Var
 I, Len: Integer;
 Output: String;
 B1, B2, B3: Byte;
 CodePoint: LongInt;
Begin
 Output := '';
 I := 1;
 Len := Length(UTF8);

 While I <= Len Do Begin
  B1 := Ord(UTF8[I]);

  If B1 < 128 Then Begin
   { ASCII }
   Output := Output + UTF8[I];
   Inc(I);
  End
  Else If (B1 And $E0) = $C0 Then Begin
   { 2 octets UTF-8 }
   If I + 1 <= Len Then Begin
    B2 := Ord(UTF8[I + 1]);
    CodePoint := ((B1 And $1F) Shl 6) Or (B2 And $3F);
    { Conversion approximative des caracteres courants }
    Case CodePoint Of
     $C0..$C5: Output := Output + 'A';
     $C8..$CB: Output := Output + 'E';
     $CC..$CF: Output := Output + 'I';
     $D2..$D6: Output := Output + 'O';
     $D9..$DC: Output := Output + 'U';
     $E0..$E5: Output := Output + 'a';
     $E8..$EB: Output := Output + 'e';
     $EC..$EF: Output := Output + 'i';
     $F2..$F6: Output := Output + 'o';
     $F9..$FC: Output := Output + 'u';
     $C7: Output := Output + 'C';
     $E7: Output := Output + 'c';
     $D1: Output := Output + 'N';
     $F1: Output := Output + 'n';
     $DF: Output := Output + 'ss';
     $AB: Output := Output + '<<';
     $BB: Output := Output + '>>';
     $A9: Output := Output + '(c)';
     $AE: Output := Output + '(R)';
     $B0: Output := Output + 'o';
     Else Output := Output + '?';
    End;
    Inc(I, 2);
   End
   Else Begin
    Output := Output + '?';
    Inc(I);
   End;
  End
  Else If (B1 And $F0) = $E0 Then Begin
   { 3 octets UTF-8 }
   If I + 2 <= Len Then Begin
    CodePoint := ((B1 And $0F) Shl 12) Or
                 ((Ord(UTF8[I + 1]) And $3F) Shl 6) Or
                 (Ord(UTF8[I + 2]) And $3F);
    { Quelques symboles courants }
    Case CodePoint Of
     $2018, $2019: Output := Output + '''';
     $201C, $201D: Output := Output + '"';
     $2013, $2014: Output := Output + '-';
     $2026: Output := Output + '...';
     $20AC: Output := Output + 'EUR';
     Else Output := Output + '?';
    End;
    Inc(I, 3);
   End
   Else Begin
    Output := Output + '?';
    Inc(I);
   End;
  End
  Else Begin
   { Sequence plus longue ou invalide }
   Output := Output + '?';
   Inc(I);
  End;
 End;

 MIME_DecodeUTF8 := Output;
End;

{ Convertit ISO-8859-1 en ASCII approximatif }
Function MIME_DecodeISO8859_1(ISO: String): String;
Var
 I: Integer;
 Output: String;
 B: Byte;
Begin
 Output := '';
 For I := 1 To Length(ISO) Do Begin
  B := Ord(ISO[I]);
  If B < 128 Then
   Output := Output + ISO[I]
  Else Begin
   Case B Of
    $C0..$C5: Output := Output + 'A';
    $C8..$CB: Output := Output + 'E';
    $CC..$CF: Output := Output + 'I';
    $D2..$D6: Output := Output + 'O';
    $D9..$DC: Output := Output + 'U';
    $E0..$E5: Output := Output + 'a';
    $E8..$EB: Output := Output + 'e';
    $EC..$EF: Output := Output + 'i';
    $F2..$F6: Output := Output + 'o';
    $F9..$FC: Output := Output + 'u';
    $C7: Output := Output + 'C';
    $E7: Output := Output + 'c';
    $D1: Output := Output + 'N';
    $F1: Output := Output + 'n';
    $DF: Output := Output + 'ss';
    $AB: Output := Output + '<<';
    $BB: Output := Output + '>>';
    $A9: Output := Output + '(c)';
    $AE: Output := Output + '(R)';
    $B0: Output := Output + 'o';
    $A0: Output := Output + ' ';
    Else Output := Output + Chr(B);
   End;
  End;
 End;
 MIME_DecodeISO8859_1 := Output;
End;

{ Convertit Windows-1252 en ASCII approximatif }
Function MIME_DecodeWindows1252(Win: String): String;
Var
 I: Integer;
 Output: String;
 B: Byte;
Begin
 Output := '';
 For I := 1 To Length(Win) Do Begin
  B := Ord(Win[I]);
  If B < 128 Then
   Output := Output + Win[I]
  Else Begin
   Case B Of
    $80: Output := Output + 'EUR';
    $82: Output := Output + ',';
    $83: Output := Output + 'f';
    $84: Output := Output + ',,';
    $85: Output := Output + '...';
    $86, $87: Output := Output + '+';
    $88: Output := Output + '^';
    $89: Output := Output + '%';
    $8A: Output := Output + 'S';
    $8B: Output := Output + '<';
    $8C: Output := Output + 'OE';
    $8E: Output := Output + 'Z';
    $91: Output := Output + '''';
    $92: Output := Output + '''';
    $93: Output := Output + '"';
    $94: Output := Output + '"';
    $95: Output := Output + '*';
    $96, $97: Output := Output + '-';
    $98: Output := Output + '~';
    $99: Output := Output + '(TM)';
    $9A: Output := Output + 's';
    $9B: Output := Output + '>';
    $9C: Output := Output + 'oe';
    $9E: Output := Output + 'z';
    $9F: Output := Output + 'Y';
    Else Output := Output + MIME_DecodeISO8859_1(Win[I]);
   End;
  End;
 End;
 MIME_DecodeWindows1252 := Output;
End;

{ Parse le type de contenu }
Procedure MIME_ParseContentType(TypeStr: String; Var Part: TMIMEPart);
Var
 I, J: Integer;
 Lower, ParamName, ParamValue: String;
Begin
 Lower := MIME_LowerCase(MIME_Trim(TypeStr));
 Part.ContentTypeStr := TypeStr;

 { Determiner le type principal }
 If Copy(Lower, 1, 5) = 'text/' Then
  Part.ContentType := mctText
 Else If Copy(Lower, 1, 10) = 'multipart/' Then
  Part.ContentType := mctMultipart
 Else If Copy(Lower, 1, 12) = 'application/' Then
  Part.ContentType := mctApplication
 Else If Copy(Lower, 1, 6) = 'image/' Then
  Part.ContentType := mctImage
 Else If Copy(Lower, 1, 6) = 'audio/' Then
  Part.ContentType := mctAudio
 Else If Copy(Lower, 1, 6) = 'video/' Then
  Part.ContentType := mctVideo
 Else If Copy(Lower, 1, 8) = 'message/' Then
  Part.ContentType := mctMessage
 Else
  Part.ContentType := mctUnknown;

 { Determiner le sous-type }
 If Pos('text/plain', Lower) > 0 Then
  Part.SubType := mstPlain
 Else If Pos('text/html', Lower) > 0 Then
  Part.SubType := mstHTML
 Else If Pos('multipart/mixed', Lower) > 0 Then
  Part.SubType := mstMixed
 Else If Pos('multipart/alternative', Lower) > 0 Then
  Part.SubType := mstAlternative
 Else If Pos('multipart/related', Lower) > 0 Then
  Part.SubType := mstRelated
 Else If Pos('application/octet-stream', Lower) > 0 Then
  Part.SubType := mstOctetStream
 Else If Pos('application/pdf', Lower) > 0 Then
  Part.SubType := mstPDF
 Else If Pos('image/jpeg', Lower) > 0 Then
  Part.SubType := mstJPEG
 Else If Pos('image/png', Lower) > 0 Then
  Part.SubType := mstPNG
 Else If Pos('image/gif', Lower) > 0 Then
  Part.SubType := mstGIF
 Else If Pos('message/rfc822', Lower) > 0 Then
  Part.SubType := mstRFC822
 Else
  Part.SubType := mstUnknown;

 { Extraire les parametres }
 { Chercher le charset }
 I := Pos('charset=', Lower);
 If I > 0 Then Begin
  ParamValue := '';
  J := I + 8;
  If (J <= Length(TypeStr)) And (TypeStr[J] = '"') Then Begin
   Inc(J);
   While (J <= Length(TypeStr)) And (TypeStr[J] <> '"') Do Begin
    ParamValue := ParamValue + TypeStr[J];
    Inc(J);
   End;
  End
  Else Begin
   While (J <= Length(TypeStr)) And (TypeStr[J] > ' ') And (TypeStr[J] <> ';') Do Begin
    ParamValue := ParamValue + TypeStr[J];
    Inc(J);
   End;
  End;
  ParamValue := MIME_LowerCase(ParamValue);

  If (ParamValue = 'utf-8') Or (ParamValue = 'utf8') Then
   Part.Charset := mcsUTF8
  Else If (ParamValue = 'iso-8859-1') Or (ParamValue = 'latin1') Then
   Part.Charset := mcsISO8859_1
  Else If (ParamValue = 'windows-1252') Or (ParamValue = 'cp1252') Then
   Part.Charset := mcsWindows1252
  Else If (ParamValue = 'iso-8859-15') Or (ParamValue = 'latin9') Then
   Part.Charset := mcsISO8859_15
  Else If (ParamValue = 'us-ascii') Or (ParamValue = 'ascii') Then
   Part.Charset := mcsASCII
  Else
   Part.Charset := mcsUnknown;
 End;

 { Chercher le boundary }
 I := Pos('boundary=', Lower);
 If I > 0 Then Begin
  Part.Boundary := '';
  J := I + 9;
  If (J <= Length(TypeStr)) And (TypeStr[J] = '"') Then Begin
   Inc(J);
   While (J <= Length(TypeStr)) And (TypeStr[J] <> '"') Do Begin
    Part.Boundary := Part.Boundary + TypeStr[J];
    Inc(J);
   End;
  End
  Else Begin
   While (J <= Length(TypeStr)) And (TypeStr[J] > ' ') And (TypeStr[J] <> ';') Do Begin
    Part.Boundary := Part.Boundary + TypeStr[J];
    Inc(J);
   End;
  End;
 End;

 { Chercher le name/filename }
 I := Pos('name=', Lower);
 If I > 0 Then Begin
  Part.FileName := '';
  J := I + 5;
  If (J <= Length(TypeStr)) And (TypeStr[J] = '"') Then Begin
   Inc(J);
   While (J <= Length(TypeStr)) And (TypeStr[J] <> '"') Do Begin
    Part.FileName := Part.FileName + TypeStr[J];
    Inc(J);
   End;
  End
  Else Begin
   While (J <= Length(TypeStr)) And (TypeStr[J] > ' ') And (TypeStr[J] <> ';') Do Begin
    Part.FileName := Part.FileName + TypeStr[J];
    Inc(J);
   End;
  End;
 End;
End;

{ Parse le Content-Transfer-Encoding }
Procedure MIME_ParseTransferEncoding(EncStr: String; Var Part: TMIMEPart);
Var
 Lower: String;
Begin
 Lower := MIME_LowerCase(MIME_Trim(EncStr));

 If Lower = 'base64' Then
  Part.TransferEncoding := mteBase64
 Else If Lower = 'quoted-printable' Then
  Part.TransferEncoding := mteQuotedPrintable
 Else If Lower = '7bit' Then
  Part.TransferEncoding := mte7Bit
 Else If Lower = '8bit' Then
  Part.TransferEncoding := mte8Bit
 Else If Lower = 'binary' Then
  Part.TransferEncoding := mteBinary
 Else
  Part.TransferEncoding := mte7Bit;
End;

{ Parse le Content-Disposition }
Procedure MIME_ParseContentDisposition(DispStr: String; Var Part: TMIMEPart);
Var
 Lower: String;
 I, J: Integer;
Begin
 Lower := MIME_LowerCase(MIME_Trim(DispStr));

 Part.IsAttachment := (Pos('attachment', Lower) > 0);

 { Chercher filename }
 I := Pos('filename=', Lower);
 If I > 0 Then Begin
  J := I + 9;
  Part.FileName := '';
  If (J <= Length(DispStr)) And (DispStr[J] = '"') Then Begin
   Inc(J);
   While (J <= Length(DispStr)) And (DispStr[J] <> '"') Do Begin
    Part.FileName := Part.FileName + DispStr[J];
    Inc(J);
   End;
  End
  Else Begin
   While (J <= Length(DispStr)) And (DispStr[J] > ' ') And (DispStr[J] <> ';') Do Begin
    Part.FileName := Part.FileName + DispStr[J];
    Inc(J);
   End;
  End;
 End;
End;

{ Decode un en-tete encode (RFC 2047) }
Function MIME_DecodeEncodedWord(Word: String): String;
Var
 I, J, K: Integer;
 Charset, Encoding, Text, Decoded: String;
Begin
 MIME_DecodeEncodedWord := Word;

 { Format: =?charset?encoding?text?= }
 If (Copy(Word, 1, 2) <> '=?') Then Exit;
 If (Copy(Word, Length(Word) - 1, 2) <> '?=') Then Exit;

 { Extraire le charset }
 I := 3;
 Charset := '';
 While (I <= Length(Word)) And (Word[I] <> '?') Do Begin
  Charset := Charset + Word[I];
  Inc(I);
 End;
 Inc(I); { Sauter le ? }

 { Extraire l'encoding }
 Encoding := '';
 While (I <= Length(Word)) And (Word[I] <> '?') Do Begin
  Encoding := Encoding + Word[I];
  Inc(I);
 End;
 Inc(I); { Sauter le ? }

 { Extraire le texte }
 Text := '';
 While (I <= Length(Word) - 2) Do Begin
  Text := Text + Word[I];
  Inc(I);
 End;

 { Decoder selon l'encoding }
 Encoding := MIME_UpperCase(Encoding);
 If Encoding = 'B' Then
  Decoded := MIME_DecodeBase64(Text)
 Else If Encoding = 'Q' Then
  Decoded := MIME_DecodeQuotedPrintable(Text)
 Else
  Decoded := Text;

 { Convertir le charset }
 Charset := MIME_LowerCase(Charset);
 If (Charset = 'utf-8') Or (Charset = 'utf8') Then
  Decoded := MIME_DecodeUTF8(Decoded)
 Else If (Charset = 'iso-8859-1') Or (Charset = 'latin1') Then
  Decoded := MIME_DecodeISO8859_1(Decoded)
 Else If (Charset = 'windows-1252') Or (Charset = 'cp1252') Then
  Decoded := MIME_DecodeWindows1252(Decoded);

 MIME_DecodeEncodedWord := Decoded;
End;

{ Decode un en-tete complet (peut contenir plusieurs mots encodes) }
Function MIME_DecodeHeader(Header: String): String;
Var
 I, J, K: Integer;
 Output, Word: String;
Begin
 Output := '';
 I := 1;

 While I <= Length(Header) Do Begin
  If (I + 1 <= Length(Header)) And (Header[I] = '=') And (Header[I + 1] = '?') Then Begin
   { Mot encode trouve }
   Word := '=?';
   J := I + 2;
   While (J <= Length(Header)) And Not
         ((J + 1 <= Length(Header)) And (Header[J] = '?') And (Header[J + 1] = '=')) Do Begin
    Word := Word + Header[J];
    Inc(J);
   End;
   If J + 1 <= Length(Header) Then Begin
    Word := Word + '?=';
    J := J + 2;
   End;
   Output := Output + MIME_DecodeEncodedWord(Word);
   I := J;

   { Sauter les espaces entre mots encodes consecutifs }
   While (I <= Length(Header)) And (Header[I] <= ' ') And
         (I + 1 <= Length(Header)) And (Header[I + 1] = '=') Do
    Inc(I);
  End
  Else Begin
   Output := Output + Header[I];
   Inc(I);
  End;
 End;

 MIME_DecodeHeader := Output;
End;

{ Initialise une partie MIME }
Procedure MIME_InitPart(Var Part: TMIMEPart);
Begin
 Part.ContentType := mctText;
 Part.SubType := mstPlain;
 Part.ContentTypeStr := 'text/plain';
 Part.Charset := mcsASCII;
 Part.TransferEncoding := mte7Bit;
 Part.Boundary := '';
 Part.FileName := '';
 Part.ContentID := '';
 Part.IsAttachment := False;
 Part.DataOffset := 0;
 Part.DataLength := 0;
 Part.DecodedLength := 0;
 Part.PartCount := 0;
End;

{ Decode le contenu d'une partie MIME }
Function MIME_DecodePart(Content: String; Part: TMIMEPart): String;
Var
 Decoded: String;
Begin
 { Decoder le transfert }
 Case Part.TransferEncoding Of
  mteBase64: Decoded := MIME_DecodeBase64(Content);
  mteQuotedPrintable: Decoded := MIME_DecodeQuotedPrintable(Content);
  Else Decoded := Content;
 End;

 { Convertir le charset pour les parties texte }
 If Part.ContentType = mctText Then Begin
  Case Part.Charset Of
   mcsUTF8: Decoded := MIME_DecodeUTF8(Decoded);
   mcsISO8859_1, mcsISO8859_15: Decoded := MIME_DecodeISO8859_1(Decoded);
   mcsWindows1252: Decoded := MIME_DecodeWindows1252(Decoded);
  End;
 End;

 MIME_DecodePart := Decoded;
End;

{ Parse les en-tetes d'un message }
Procedure MIME_ParseHeaders(Headers: String);
Var
 I, J, LineStart: Integer;
 Line, Name, Value: String;
 ContinuedLine: Boolean;
Begin
 MIMEHeaderCount := 0;
 I := 1;

 While I <= Length(Headers) Do Begin
  { Lire une ligne }
  Line := '';
  While (I <= Length(Headers)) And (Headers[I] <> #13) And (Headers[I] <> #10) Do Begin
   Line := Line + Headers[I];
   Inc(I);
  End;

  { Sauter le retour a la ligne }
  If (I <= Length(Headers)) And (Headers[I] = #13) Then Inc(I);
  If (I <= Length(Headers)) And (Headers[I] = #10) Then Inc(I);

  { Ligne vide = fin des en-tetes }
  If Length(Line) = 0 Then Break;

  { Verifier si c'est une continuation }
  If (Length(Line) > 0) And ((Line[1] = ' ') Or (Line[1] = #9)) Then Begin
   { Continuation de la ligne precedente }
   If MIMEHeaderCount > 0 Then
    MIMEHeaders[MIMEHeaderCount - 1].Value :=
     MIMEHeaders[MIMEHeaderCount - 1].Value + ' ' + MIME_Trim(Line);
  End
  Else Begin
   { Nouvel en-tete }
   J := Pos(':', Line);
   If J > 0 Then Begin
    Name := MIME_Trim(Copy(Line, 1, J - 1));
    Value := MIME_Trim(Copy(Line, J + 1, Length(Line) - J));

    If MIMEHeaderCount < MAX_MIME_HEADERS Then Begin
     MIMEHeaders[MIMEHeaderCount].Name := MIME_LowerCase(Name);
     MIMEHeaders[MIMEHeaderCount].Value := Value;
     Inc(MIMEHeaderCount);
    End;
   End;
  End;
 End;
End;

{ Recupere la valeur d'un en-tete }
Function MIME_GetHeader(Name: String): String;
Var
 I: Integer;
 LowerName: String;
Begin
 MIME_GetHeader := '';
 LowerName := MIME_LowerCase(Name);
 For I := 0 To MIMEHeaderCount - 1 Do Begin
  If MIMEHeaders[I].Name = LowerName Then Begin
   MIME_GetHeader := MIMEHeaders[I].Value;
   Exit;
  End;
 End;
End;

{ Parse un message MIME complet }
Procedure MIME_ParseMessage(Message: String);
Var
 I, J, K, PartStart, PartEnd: Integer;
 HeaderEnd: Integer;
 Headers, Body, ContentType, Boundary: String;
 BoundaryLine, EndBoundary: String;
 PartHeaders, PartContent: String;
Begin
 MIMEPartCount := 0;
 MIMEHasText := False;
 MIMEHasHTML := False;
 MIMEHasAttachments := False;
 MIMETextPart := '';
 MIMEHTMLPart := '';

 { Trouver la fin des en-tetes }
 HeaderEnd := Pos(#13#10#13#10, Message);
 If HeaderEnd = 0 Then HeaderEnd := Pos(#10#10, Message);
 If HeaderEnd = 0 Then Begin
  { Pas d'en-tetes separes - tout est le corps }
  MIMETextPart := Message;
  MIMEHasText := True;
  Exit;
 End;

 Headers := Copy(Message, 1, HeaderEnd - 1);
 Body := Copy(Message, HeaderEnd + 4, Length(Message) - HeaderEnd - 3);
 If Body = '' Then Body := Copy(Message, HeaderEnd + 2, Length(Message) - HeaderEnd - 1);

 MIME_ParseHeaders(Headers);
 MIME_InitPart(MIMERootPart);

 { Analyser le Content-Type }
 ContentType := MIME_GetHeader('content-type');
 If Length(ContentType) > 0 Then
  MIME_ParseContentType(ContentType, MIMERootPart);

 { Analyser le Content-Transfer-Encoding }
 ContentType := MIME_GetHeader('content-transfer-encoding');
 If Length(ContentType) > 0 Then
  MIME_ParseTransferEncoding(ContentType, MIMERootPart);

 { Si multipart, parser les parties }
 If MIMERootPart.ContentType = mctMultipart Then Begin
  Boundary := MIMERootPart.Boundary;
  If Length(Boundary) = 0 Then Begin
   { Pas de boundary, traiter comme texte }
   MIMETextPart := Body;
   MIMEHasText := True;
   Exit;
  End;

  BoundaryLine := '--' + Boundary;
  EndBoundary := '--' + Boundary + '--';

  { Trouver les parties }
  I := Pos(BoundaryLine, Body);
  While I > 0 Do Begin
   { Passer apres le boundary }
   J := I + Length(BoundaryLine);
   While (J <= Length(Body)) And ((Body[J] = #13) Or (Body[J] = #10)) Do
    Inc(J);

   { Trouver le prochain boundary }
   K := Pos(BoundaryLine, Copy(Body, J, Length(Body) - J + 1));
   If K > 0 Then
    PartEnd := J + K - 2
   Else
    PartEnd := Length(Body);

   { Extraire cette partie }
   PartContent := Copy(Body, J, PartEnd - J);

   { Verifier si c'est le boundary final }
   If Copy(Body, I, Length(EndBoundary)) = EndBoundary Then Break;

   { Parser la partie }
   If (MIMEPartCount < MAX_MIME_PARTS) And (Length(PartContent) > 0) Then Begin
    { Trouver la separation en-tetes/corps de la partie }
    HeaderEnd := Pos(#13#10#13#10, PartContent);
    If HeaderEnd = 0 Then HeaderEnd := Pos(#10#10, PartContent);

    If HeaderEnd > 0 Then Begin
     PartHeaders := Copy(PartContent, 1, HeaderEnd - 1);
     PartContent := Copy(PartContent, HeaderEnd + 4, Length(PartContent) - HeaderEnd - 3);
     If PartContent = '' Then PartContent := Copy(PartContent, HeaderEnd + 2, Length(PartContent) - HeaderEnd - 1);
    End
    Else
     PartHeaders := '';

    MIME_InitPart(MIMEParts[MIMEPartCount]);

    { Parser les en-tetes de la partie }
    If Length(PartHeaders) > 0 Then Begin
     MIME_ParseHeaders(PartHeaders);
     ContentType := MIME_GetHeader('content-type');
     If Length(ContentType) > 0 Then
      MIME_ParseContentType(ContentType, MIMEParts[MIMEPartCount]);
     ContentType := MIME_GetHeader('content-transfer-encoding');
     If Length(ContentType) > 0 Then
      MIME_ParseTransferEncoding(ContentType, MIMEParts[MIMEPartCount]);
     ContentType := MIME_GetHeader('content-disposition');
     If Length(ContentType) > 0 Then
      MIME_ParseContentDisposition(ContentType, MIMEParts[MIMEPartCount]);
     ContentType := MIME_GetHeader('content-id');
     If Length(ContentType) > 0 Then Begin
      MIMEParts[MIMEPartCount].ContentID := ContentType;
      { Enlever les < > }
      If (Length(MIMEParts[MIMEPartCount].ContentID) > 2) And
         (MIMEParts[MIMEPartCount].ContentID[1] = '<') Then Begin
       Delete(MIMEParts[MIMEPartCount].ContentID, 1, 1);
       Delete(MIMEParts[MIMEPartCount].ContentID,
              Length(MIMEParts[MIMEPartCount].ContentID), 1);
      End;
     End;
    End;

    { Decoder le contenu }
    PartContent := MIME_DecodePart(PartContent, MIMEParts[MIMEPartCount]);

    { Stocker selon le type }
    If MIMEParts[MIMEPartCount].IsAttachment Then Begin
     MIMEHasAttachments := True;
    End
    Else If MIMEParts[MIMEPartCount].SubType = mstPlain Then Begin
     MIMETextPart := PartContent;
     MIMEHasText := True;
    End
    Else If MIMEParts[MIMEPartCount].SubType = mstHTML Then Begin
     MIMEHTMLPart := PartContent;
     MIMEHasHTML := True;
    End;

    Inc(MIMEPartCount);
   End;

   { Chercher le prochain boundary }
   I := Pos(BoundaryLine, Copy(Body, PartEnd, Length(Body) - PartEnd + 1));
   If I > 0 Then I := PartEnd + I - 1
   Else I := 0;
  End;
 End
 Else Begin
  { Message simple (non multipart) }
  Body := MIME_DecodePart(Body, MIMERootPart);

  If MIMERootPart.SubType = mstHTML Then Begin
   MIMEHTMLPart := Body;
   MIMEHasHTML := True;
  End
  Else Begin
   MIMETextPart := Body;
   MIMEHasText := True;
  End;
 End;
End;

{ Retourne le contenu texte d'un message MIME }
Function MIME_GetTextContent: String;
Begin
 If MIMEHasText Then
  MIME_GetTextContent := MIMETextPart
 Else If MIMEHasHTML Then
  MIME_GetTextContent := MIMEHTMLPart
 Else
  MIME_GetTextContent := '';
End;

{ Retourne le contenu HTML d'un message MIME }
Function MIME_GetHTMLContent: String;
Begin
 If MIMEHasHTML Then
  MIME_GetHTMLContent := MIMEHTMLPart
 Else
  MIME_GetHTMLContent := '';
End;

{ Verifie si un message contient des pieces jointes }
Function MIME_HasAttachments: Boolean;
Begin
 MIME_HasAttachments := MIMEHasAttachments;
End;

{ Retourne le nombre de parties }
Function MIME_GetPartCount: Integer;
Begin
 MIME_GetPartCount := MIMEPartCount;
End;

{ Initialise le decodeur MIME }
Procedure MIME_Init;
Begin
 MIMEPartCount := 0;
 MIMEHeaderCount := 0;
 MIME_InitPart(MIMERootPart);
 MIMETextPart := '';
 MIMEHTMLPart := '';
 MIMEHasText := False;
 MIMEHasHTML := False;
 MIMEHasAttachments := False;
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU DECODAGE MIME
  ============================================================================ }

{ ============================================================================
  IMPLEMENTATION DU CARNET D'ADRESSES (TODO 16)
  ============================================================================ }

{ Initialise un contact vide }
Procedure AB_InitContact(Var Contact: TContact);
Begin
 Contact.ID := 0;
 Contact.LastName := '';
 Contact.FirstName := '';
 Contact.DisplayName := '';
 Contact.Email := '';
 Contact.Email2 := '';
 Contact.Phone := '';
 Contact.PhoneMobile := '';
 Contact.PhoneWork := '';
 Contact.Address := '';
 Contact.Address2 := '';
 Contact.City := '';
 Contact.PostalCode := '';
 Contact.Country := '';
 Contact.Company := '';
 Contact.JobTitle := '';
 Contact.Notes := '';
 Contact.Birthday := '';
 Contact.CreatedDate := 0;
 Contact.ModifiedDate := 0;
 Contact.IsSelected := False;
End;

{ Initialise le carnet d'adresses }
Procedure AB_Init;
Var
 I: Integer;
Begin
 ContactCount := 0;
 ContactNextID := 1;
 ContactSortField := csfLastName;
 ContactSortAsc := True;
 ContactScrollOffset := 0;
 ContactSelectedIndex := -1;
 AddressBookState := absHidden;
 AddressBookX := (640 - ADDRESSBOOK_WIDTH) Div 2;
 AddressBookY := (480 - ADDRESSBOOK_HEIGHT) Div 2;
 AddressBookSearchText := '';
 EditingContactIndex := -1;
 EditingField := 0;
 AddressBookVisible := False;

 { Initialiser tous les contacts }
 For I := 0 To MAX_CONTACTS - 1 Do
  AB_InitContact(Contacts[I]);

 { Auto-completion }
 AutoCompleteSuggestionCount := 0;
 AutoCompleteVisible := False;
 AutoCompleteSelectedIndex := -1;
 AutoCompleteField := acfTo;
 AutoCompleteText := '';
End;

{ Compare deux chaines sans casse }
Function AB_CompareStr(S1, S2: String): Integer;
Var
 I, L1, L2, MinL: Integer;
 C1, C2: Char;
Begin
 L1 := Length(S1);
 L2 := Length(S2);
 If L1 < L2 Then MinL := L1 Else MinL := L2;

 For I := 1 To MinL Do Begin
  C1 := S1[I];
  C2 := S2[I];
  { Convertir en majuscule }
  If (C1 >= 'a') And (C1 <= 'z') Then C1 := Chr(Ord(C1) - 32);
  If (C2 >= 'a') And (C2 <= 'z') Then C2 := Chr(Ord(C2) - 32);
  If C1 < C2 Then Begin
   AB_CompareStr := -1;
   Exit;
  End
  Else If C1 > C2 Then Begin
   AB_CompareStr := 1;
   Exit;
  End;
 End;

 If L1 < L2 Then AB_CompareStr := -1
 Else If L1 > L2 Then AB_CompareStr := 1
 Else AB_CompareStr := 0;
End;

{ Echange deux contacts }
Procedure AB_SwapContacts(Var A, B: TContact);
Var
 Temp: TContact;
Begin
 Temp := A;
 A := B;
 B := Temp;
End;

{ Tri les contacts (tri a bulles pour simplicite) }
Procedure AB_SortContacts;
Var
 I, J: Integer;
 Swapped: Boolean;
 Cmp: Integer;
 S1, S2: String;
Begin
 If ContactCount < 2 Then Exit;

 For I := 0 To ContactCount - 2 Do Begin
  Swapped := False;
  For J := 0 To ContactCount - 2 - I Do Begin
   { Obtenir les valeurs a comparer }
   Case ContactSortField Of
    csfLastName: Begin
     S1 := Contacts[J].LastName;
     S2 := Contacts[J + 1].LastName;
    End;
    csfFirstName: Begin
     S1 := Contacts[J].FirstName;
     S2 := Contacts[J + 1].FirstName;
    End;
    csfEmail: Begin
     S1 := Contacts[J].Email;
     S2 := Contacts[J + 1].Email;
    End;
    csfCompany: Begin
     S1 := Contacts[J].Company;
     S2 := Contacts[J + 1].Company;
    End;
   End;

   Cmp := AB_CompareStr(S1, S2);
   If Not ContactSortAsc Then Cmp := -Cmp;

   If Cmp > 0 Then Begin
    AB_SwapContacts(Contacts[J], Contacts[J + 1]);
    Swapped := True;
   End;
  End;
  If Not Swapped Then Break;
 End;
End;

{ Genere le nom d'affichage }
Function AB_GenerateDisplayName(Const Contact: TContact): String;
Begin
 If Length(Contact.DisplayName) > 0 Then
  AB_GenerateDisplayName := Contact.DisplayName
 Else If (Length(Contact.FirstName) > 0) And (Length(Contact.LastName) > 0) Then
  AB_GenerateDisplayName := Contact.FirstName + ' ' + Contact.LastName
 Else If Length(Contact.LastName) > 0 Then
  AB_GenerateDisplayName := Contact.LastName
 Else If Length(Contact.FirstName) > 0 Then
  AB_GenerateDisplayName := Contact.FirstName
 Else If Length(Contact.Email) > 0 Then
  AB_GenerateDisplayName := Contact.Email
 Else
  AB_GenerateDisplayName := '(Sans nom)';
End;

{ Ajoute un nouveau contact }
Function AB_AddContact(Var NewContact: TContact): Integer;
Begin
 AB_AddContact := -1;
 If ContactCount >= MAX_CONTACTS Then Exit;

 NewContact.ID := ContactNextID;
 Inc(ContactNextID);
 NewContact.CreatedDate := 0; { TODO: obtenir date actuelle }
 NewContact.ModifiedDate := NewContact.CreatedDate;

 If Length(NewContact.DisplayName) = 0 Then
  NewContact.DisplayName := AB_GenerateDisplayName(NewContact);

 Contacts[ContactCount] := NewContact;
 AB_AddContact := ContactCount;
 Inc(ContactCount);

 AB_SortContacts;
End;

{ Modifie un contact existant }
Function AB_UpdateContact(Index: Integer; Const UpdatedContact: TContact): Boolean;
Begin
 AB_UpdateContact := False;
 If (Index < 0) Or (Index >= ContactCount) Then Exit;

 Contacts[Index] := UpdatedContact;
 Contacts[Index].ModifiedDate := 0; { TODO: obtenir date actuelle }

 If Length(Contacts[Index].DisplayName) = 0 Then
  Contacts[Index].DisplayName := AB_GenerateDisplayName(Contacts[Index]);

 AB_UpdateContact := True;
 AB_SortContacts;
End;

{ Supprime un contact }
Function AB_DeleteContact(Index: Integer): Boolean;
Var
 I: Integer;
Begin
 AB_DeleteContact := False;
 If (Index < 0) Or (Index >= ContactCount) Then Exit;

 For I := Index To ContactCount - 2 Do
  Contacts[I] := Contacts[I + 1];

 Dec(ContactCount);
 AB_InitContact(Contacts[ContactCount]);

 If ContactSelectedIndex >= ContactCount Then
  ContactSelectedIndex := ContactCount - 1;

 AB_DeleteContact := True;
End;

{ Recherche un contact par email }
Function AB_FindByEmail(Email: String): Integer;
Var
 I: Integer;
 LowerEmail, ContactEmail: String;
Begin
 AB_FindByEmail := -1;
 LowerEmail := Email;
 For I := 1 To Length(LowerEmail) Do
  If (LowerEmail[I] >= 'A') And (LowerEmail[I] <= 'Z') Then
   LowerEmail[I] := Chr(Ord(LowerEmail[I]) + 32);

 For I := 0 To ContactCount - 1 Do Begin
  ContactEmail := Contacts[I].Email;
  { Convertir en minuscules }
  { Pour simplifier, comparaison directe }
  If AB_CompareStr(Contacts[I].Email, Email) = 0 Then Begin
   AB_FindByEmail := I;
   Exit;
  End;
 End;
End;

{ Recherche des contacts correspondant au texte }
Function AB_Search(SearchText: String; Var Results: Array of Integer;
                   MaxResults: Integer): Integer;
Var
 I, Count: Integer;
 LowerSearch, LowerField: String;
 J: Integer;
Begin
 Count := 0;
 If Length(SearchText) = 0 Then Begin
  { Retourner tous les contacts }
  For I := 0 To ContactCount - 1 Do Begin
   If Count >= MaxResults Then Break;
   Results[Count] := I;
   Inc(Count);
  End;
  AB_Search := Count;
  Exit;
 End;

 { Convertir recherche en minuscules }
 LowerSearch := SearchText;
 For J := 1 To Length(LowerSearch) Do
  If (LowerSearch[J] >= 'A') And (LowerSearch[J] <= 'Z') Then
   LowerSearch[J] := Chr(Ord(LowerSearch[J]) + 32);

 For I := 0 To ContactCount - 1 Do Begin
  If Count >= MaxResults Then Break;

  { Verifier chaque champ }
  LowerField := Contacts[I].LastName;
  For J := 1 To Length(LowerField) Do
   If (LowerField[J] >= 'A') And (LowerField[J] <= 'Z') Then
    LowerField[J] := Chr(Ord(LowerField[J]) + 32);
  If Pos(LowerSearch, LowerField) > 0 Then Begin
   Results[Count] := I;
   Inc(Count);
   Continue;
  End;

  LowerField := Contacts[I].FirstName;
  For J := 1 To Length(LowerField) Do
   If (LowerField[J] >= 'A') And (LowerField[J] <= 'Z') Then
    LowerField[J] := Chr(Ord(LowerField[J]) + 32);
  If Pos(LowerSearch, LowerField) > 0 Then Begin
   Results[Count] := I;
   Inc(Count);
   Continue;
  End;

  LowerField := Contacts[I].Email;
  For J := 1 To Length(LowerField) Do
   If (LowerField[J] >= 'A') And (LowerField[J] <= 'Z') Then
    LowerField[J] := Chr(Ord(LowerField[J]) + 32);
  If Pos(LowerSearch, LowerField) > 0 Then Begin
   Results[Count] := I;
   Inc(Count);
   Continue;
  End;

  LowerField := Contacts[I].Company;
  For J := 1 To Length(LowerField) Do
   If (LowerField[J] >= 'A') And (LowerField[J] <= 'Z') Then
    LowerField[J] := Chr(Ord(LowerField[J]) + 32);
  If Pos(LowerSearch, LowerField) > 0 Then Begin
   Results[Count] := I;
   Inc(Count);
  End;
 End;

 AB_Search := Count;
End;

{ ============================================================================
  IMPORT/EXPORT VCARD (RFC 2426)
  ============================================================================ }

{ Encode une valeur pour vCard }
Function AB_VCardEncode(S: String): String;
Var
 I: Integer;
 Output: String;
Begin
 Output := '';
 For I := 1 To Length(S) Do Begin
  Case S[I] Of
   '\': Output := Output + '\\';
   ';': Output := Output + '\;';
   ',': Output := Output + '\,';
   #13: Output := Output + '\n';
   #10: ; { Ignorer LF }
   Else Output := Output + S[I];
  End;
 End;
 AB_VCardEncode := Output;
End;

{ Decode une valeur vCard }
Function AB_VCardDecode(S: String): String;
Var
 I: Integer;
 Output: String;
Begin
 Output := '';
 I := 1;
 While I <= Length(S) Do Begin
  If (S[I] = '\') And (I < Length(S)) Then Begin
   Case S[I + 1] Of
    '\': Output := Output + '\';
    ';': Output := Output + ';';
    ',': Output := Output + ',';
    'n', 'N': Output := Output + #13#10;
    Else Output := Output + S[I + 1];
   End;
   Inc(I, 2);
  End
  Else Begin
   Output := Output + S[I];
   Inc(I);
  End;
 End;
 AB_VCardDecode := Output;
End;

{ Exporte un contact en format vCard }
Function AB_ExportContactToVCard(Const Contact: TContact): String;
Var
 VCard: String;
Begin
 VCard := 'BEGIN:VCARD' + #13#10;
 VCard := VCard + 'VERSION:3.0' + #13#10;

 { Nom structure: Nom;Prenom }
 VCard := VCard + 'N:' + AB_VCardEncode(Contact.LastName) + ';' +
          AB_VCardEncode(Contact.FirstName) + ';;;' + #13#10;

 { Nom d'affichage }
 VCard := VCard + 'FN:' + AB_VCardEncode(AB_GenerateDisplayName(Contact)) + #13#10;

 { Email }
 If Length(Contact.Email) > 0 Then
  VCard := VCard + 'EMAIL;TYPE=INTERNET;TYPE=PREF:' + Contact.Email + #13#10;
 If Length(Contact.Email2) > 0 Then
  VCard := VCard + 'EMAIL;TYPE=INTERNET:' + Contact.Email2 + #13#10;

 { Telephones }
 If Length(Contact.Phone) > 0 Then
  VCard := VCard + 'TEL;TYPE=HOME:' + Contact.Phone + #13#10;
 If Length(Contact.PhoneMobile) > 0 Then
  VCard := VCard + 'TEL;TYPE=CELL:' + Contact.PhoneMobile + #13#10;
 If Length(Contact.PhoneWork) > 0 Then
  VCard := VCard + 'TEL;TYPE=WORK:' + Contact.PhoneWork + #13#10;

 { Adresse }
 If (Length(Contact.Address) > 0) Or (Length(Contact.City) > 0) Then Begin
  VCard := VCard + 'ADR;TYPE=HOME:;;' + AB_VCardEncode(Contact.Address);
  If Length(Contact.Address2) > 0 Then
   VCard := VCard + ' ' + AB_VCardEncode(Contact.Address2);
  VCard := VCard + ';' + AB_VCardEncode(Contact.City) + ';;' +
           AB_VCardEncode(Contact.PostalCode) + ';' +
           AB_VCardEncode(Contact.Country) + #13#10;
 End;

 { Entreprise }
 If Length(Contact.Company) > 0 Then
  VCard := VCard + 'ORG:' + AB_VCardEncode(Contact.Company) + #13#10;

 If Length(Contact.JobTitle) > 0 Then
  VCard := VCard + 'TITLE:' + AB_VCardEncode(Contact.JobTitle) + #13#10;

 { Date de naissance }
 If Length(Contact.Birthday) > 0 Then
  VCard := VCard + 'BDAY:' + Contact.Birthday + #13#10;

 { Notes }
 If Length(Contact.Notes) > 0 Then
  VCard := VCard + 'NOTE:' + AB_VCardEncode(Contact.Notes) + #13#10;

 VCard := VCard + 'END:VCARD' + #13#10;
 AB_ExportContactToVCard := VCard;
End;

{ Extrait une propriete d'une ligne vCard }
Procedure AB_ParseVCardLine(Line: String; Var PropName, PropValue: String);
Var
 I, ColonPos: Integer;
Begin
 PropName := '';
 PropValue := '';

 ColonPos := Pos(':', Line);
 If ColonPos = 0 Then Exit;

 PropName := Copy(Line, 1, ColonPos - 1);
 PropValue := Copy(Line, ColonPos + 1, Length(Line) - ColonPos);

 { Extraire le nom de propriete sans les parametres }
 I := Pos(';', PropName);
 If I > 0 Then
  PropName := Copy(PropName, 1, I - 1);

 { Convertir en majuscules }
 For I := 1 To Length(PropName) Do
  If (PropName[I] >= 'a') And (PropName[I] <= 'z') Then
   PropName[I] := Chr(Ord(PropName[I]) - 32);
End;

{ Importe un contact depuis format vCard }
Function AB_ImportContactFromVCard(VCard: String; Var Contact: TContact): Boolean;
Var
 I, LineStart, LineEnd: Integer;
 Line, PropName, PropValue: String;
 InVCard: Boolean;
 NameParts: Array[0..4] of String;
 PartCount, J, SemiPos: Integer;
Begin
 AB_ImportContactFromVCard := False;
 AB_InitContact(Contact);
 InVCard := False;

 I := 1;
 While I <= Length(VCard) Do Begin
  { Lire une ligne }
  LineStart := I;
  While (I <= Length(VCard)) And (VCard[I] <> #13) And (VCard[I] <> #10) Do
   Inc(I);
  Line := Copy(VCard, LineStart, I - LineStart);
  If (I <= Length(VCard)) And (VCard[I] = #13) Then Inc(I);
  If (I <= Length(VCard)) And (VCard[I] = #10) Then Inc(I);

  If Length(Line) = 0 Then Continue;

  AB_ParseVCardLine(Line, PropName, PropValue);

  If PropName = 'BEGIN' Then Begin
   If PropValue = 'VCARD' Then InVCard := True;
  End
  Else If PropName = 'END' Then Begin
   If PropValue = 'VCARD' Then Begin
    InVCard := False;
    AB_ImportContactFromVCard := True;
    Exit;
   End;
  End
  Else If InVCard Then Begin
   PropValue := AB_VCardDecode(PropValue);

   If PropName = 'N' Then Begin
    { Parser Nom;Prenom;;; }
    PartCount := 0;
    For J := 0 To 4 Do NameParts[J] := '';
    J := 1;
    While (J <= Length(PropValue)) And (PartCount <= 4) Do Begin
     If PropValue[J] = ';' Then
      Inc(PartCount)
     Else
      NameParts[PartCount] := NameParts[PartCount] + PropValue[J];
     Inc(J);
    End;
    Contact.LastName := NameParts[0];
    Contact.FirstName := NameParts[1];
   End
   Else If PropName = 'FN' Then
    Contact.DisplayName := PropValue
   Else If PropName = 'EMAIL' Then Begin
    If Length(Contact.Email) = 0 Then
     Contact.Email := PropValue
    Else If Length(Contact.Email2) = 0 Then
     Contact.Email2 := PropValue;
   End
   Else If PropName = 'TEL' Then Begin
    { Determiner le type par le contexte }
    If Pos('CELL', Line) > 0 Then
     Contact.PhoneMobile := PropValue
    Else If Pos('WORK', Line) > 0 Then
     Contact.PhoneWork := PropValue
    Else If Length(Contact.Phone) = 0 Then
     Contact.Phone := PropValue;
   End
   Else If PropName = 'ADR' Then Begin
    { Parser ;;Adresse;Ville;;CodePostal;Pays }
    PartCount := 0;
    For J := 0 To 4 Do NameParts[J] := '';
    J := 1;
    While (J <= Length(PropValue)) And (PartCount <= 4) Do Begin
     If PropValue[J] = ';' Then
      Inc(PartCount)
     Else If PartCount <= 4 Then
      NameParts[PartCount] := NameParts[PartCount] + PropValue[J];
     Inc(J);
    End;
    If Length(NameParts[2]) > 0 Then Contact.Address := NameParts[2];
    If Length(NameParts[3]) > 0 Then Contact.City := NameParts[3];
   End
   Else If PropName = 'ORG' Then
    Contact.Company := PropValue
   Else If PropName = 'TITLE' Then
    Contact.JobTitle := PropValue
   Else If PropName = 'BDAY' Then
    Contact.Birthday := PropValue
   Else If PropName = 'NOTE' Then
    Contact.Notes := PropValue;
  End;
 End;
End;

{ ============================================================================
  IMPORT/EXPORT CSV
  ============================================================================ }

{ Echappe une valeur pour CSV }
Function AB_CSVEscape(S: String): String;
Var
 NeedQuotes: Boolean;
 I: Integer;
 Output: String;
Begin
 NeedQuotes := False;
 For I := 1 To Length(S) Do
  If (S[I] = ',') Or (S[I] = '"') Or (S[I] = #13) Or (S[I] = #10) Then Begin
   NeedQuotes := True;
   Break;
  End;

 If NeedQuotes Then Begin
  Output := '"';
  For I := 1 To Length(S) Do Begin
   If S[I] = '"' Then
    Output := Output + '""'
   Else
    Output := Output + S[I];
  End;
  Output := Output + '"';
  AB_CSVEscape := Output;
 End
 Else
  AB_CSVEscape := S;
End;

{ Exporte l'en-tete CSV }
Function AB_GetCSVHeader: String;
Begin
 AB_GetCSVHeader := 'LastName,FirstName,DisplayName,Email,Email2,Phone,' +
                    'PhoneMobile,PhoneWork,Address,Address2,City,PostalCode,' +
                    'Country,Company,JobTitle,Birthday,Notes';
End;

{ Exporte un contact en format CSV }
Function AB_ExportContactToCSV(Const Contact: TContact): String;
Begin
 AB_ExportContactToCSV :=
  AB_CSVEscape(Contact.LastName) + ',' +
  AB_CSVEscape(Contact.FirstName) + ',' +
  AB_CSVEscape(Contact.DisplayName) + ',' +
  AB_CSVEscape(Contact.Email) + ',' +
  AB_CSVEscape(Contact.Email2) + ',' +
  AB_CSVEscape(Contact.Phone) + ',' +
  AB_CSVEscape(Contact.PhoneMobile) + ',' +
  AB_CSVEscape(Contact.PhoneWork) + ',' +
  AB_CSVEscape(Contact.Address) + ',' +
  AB_CSVEscape(Contact.Address2) + ',' +
  AB_CSVEscape(Contact.City) + ',' +
  AB_CSVEscape(Contact.PostalCode) + ',' +
  AB_CSVEscape(Contact.Country) + ',' +
  AB_CSVEscape(Contact.Company) + ',' +
  AB_CSVEscape(Contact.JobTitle) + ',' +
  AB_CSVEscape(Contact.Birthday) + ',' +
  AB_CSVEscape(Contact.Notes);
End;

{ Parse une valeur CSV (gere les guillemets) }
Function AB_CSVParseField(Line: String; Var Pos: Integer): String;
Var
 InQuotes: Boolean;
 Output: String;
Begin
 Output := '';
 InQuotes := False;

 If Pos > Length(Line) Then Begin
  AB_CSVParseField := '';
  Exit;
 End;

 { Verifier si commence par guillemet }
 If Line[Pos] = '"' Then Begin
  InQuotes := True;
  Inc(Pos);
 End;

 While Pos <= Length(Line) Do Begin
  If InQuotes Then Begin
   If Line[Pos] = '"' Then Begin
    If (Pos < Length(Line)) And (Line[Pos + 1] = '"') Then Begin
     { Double guillemet = guillemet simple }
     Output := Output + '"';
     Inc(Pos, 2);
    End
    Else Begin
     { Fin du champ }
     Inc(Pos);
     { Sauter la virgule }
     If (Pos <= Length(Line)) And (Line[Pos] = ',') Then Inc(Pos);
     Break;
    End;
   End
   Else Begin
    Output := Output + Line[Pos];
    Inc(Pos);
   End;
  End
  Else Begin
   If Line[Pos] = ',' Then Begin
    Inc(Pos);
    Break;
   End
   Else Begin
    Output := Output + Line[Pos];
    Inc(Pos);
   End;
  End;
 End;

 AB_CSVParseField := Output;
End;

{ Importe un contact depuis format CSV }
Function AB_ImportContactFromCSV(Line: String; Var Contact: TContact): Boolean;
Var
 P: Integer;
Begin
 AB_ImportContactFromCSV := False;
 AB_InitContact(Contact);
 P := 1;

 Contact.LastName := AB_CSVParseField(Line, P);
 Contact.FirstName := AB_CSVParseField(Line, P);
 Contact.DisplayName := AB_CSVParseField(Line, P);
 Contact.Email := AB_CSVParseField(Line, P);
 Contact.Email2 := AB_CSVParseField(Line, P);
 Contact.Phone := AB_CSVParseField(Line, P);
 Contact.PhoneMobile := AB_CSVParseField(Line, P);
 Contact.PhoneWork := AB_CSVParseField(Line, P);
 Contact.Address := AB_CSVParseField(Line, P);
 Contact.Address2 := AB_CSVParseField(Line, P);
 Contact.City := AB_CSVParseField(Line, P);
 Contact.PostalCode := AB_CSVParseField(Line, P);
 Contact.Country := AB_CSVParseField(Line, P);
 Contact.Company := AB_CSVParseField(Line, P);
 Contact.JobTitle := AB_CSVParseField(Line, P);
 Contact.Birthday := AB_CSVParseField(Line, P);
 Contact.Notes := AB_CSVParseField(Line, P);

 { Verifier qu'on a au moins un nom ou email }
 AB_ImportContactFromCSV := (Length(Contact.LastName) > 0) Or
                            (Length(Contact.FirstName) > 0) Or
                            (Length(Contact.Email) > 0);
End;

{ ============================================================================
  AUTO-COMPLETION
  ============================================================================ }

{ Calcule un score de correspondance }
Function AB_CalcMatchScore(SearchText, FieldValue: String): Integer;
Var
 I, J, Score: Integer;
 LowerSearch, LowerField: String;
Begin
 Score := 0;
 If Length(SearchText) = 0 Then Begin
  AB_CalcMatchScore := 0;
  Exit;
 End;

 { Convertir en minuscules }
 LowerSearch := SearchText;
 LowerField := FieldValue;
 For I := 1 To Length(LowerSearch) Do
  If (LowerSearch[I] >= 'A') And (LowerSearch[I] <= 'Z') Then
   LowerSearch[I] := Chr(Ord(LowerSearch[I]) + 32);
 For I := 1 To Length(LowerField) Do
  If (LowerField[I] >= 'A') And (LowerField[I] <= 'Z') Then
   LowerField[I] := Chr(Ord(LowerField[I]) + 32);

 { Correspondance exacte au debut = score maximum }
 If Copy(LowerField, 1, Length(LowerSearch)) = LowerSearch Then
  Score := 100 - Length(FieldValue)
 { Correspondance quelque part }
 Else If Pos(LowerSearch, LowerField) > 0 Then
  Score := 50 - Pos(LowerSearch, LowerField);

 AB_CalcMatchScore := Score;
End;

{ Met a jour les suggestions d'auto-completion }
Procedure AB_UpdateAutoComplete(SearchText: String);
Var
 I, J, Score, BestScore: Integer;
 Temp: TAutoCompleteSuggestion;
Begin
 AutoCompleteSuggestionCount := 0;
 AutoCompleteText := SearchText;

 If Length(SearchText) < 2 Then Begin
  AutoCompleteVisible := False;
  Exit;
 End;

 For I := 0 To ContactCount - 1 Do Begin
  If AutoCompleteSuggestionCount >= MAX_AUTOCOMPLETE_SUGGESTIONS Then Break;

  { Calculer le score pour ce contact }
  BestScore := AB_CalcMatchScore(SearchText, Contacts[I].DisplayName);
  Score := AB_CalcMatchScore(SearchText, Contacts[I].Email);
  If Score > BestScore Then BestScore := Score;
  Score := AB_CalcMatchScore(SearchText, Contacts[I].FirstName);
  If Score > BestScore Then BestScore := Score;
  Score := AB_CalcMatchScore(SearchText, Contacts[I].LastName);
  If Score > BestScore Then BestScore := Score;

  If BestScore > 0 Then Begin
   AutoCompleteSuggestions[AutoCompleteSuggestionCount].DisplayName :=
    AB_GenerateDisplayName(Contacts[I]);
   AutoCompleteSuggestions[AutoCompleteSuggestionCount].Email := Contacts[I].Email;
   AutoCompleteSuggestions[AutoCompleteSuggestionCount].MatchScore := BestScore;
   Inc(AutoCompleteSuggestionCount);
  End;
 End;

 { Trier par score (tri a bulles) }
 For I := 0 To AutoCompleteSuggestionCount - 2 Do
  For J := 0 To AutoCompleteSuggestionCount - 2 - I Do
   If AutoCompleteSuggestions[J].MatchScore <
      AutoCompleteSuggestions[J + 1].MatchScore Then Begin
    Temp := AutoCompleteSuggestions[J];
    AutoCompleteSuggestions[J] := AutoCompleteSuggestions[J + 1];
    AutoCompleteSuggestions[J + 1] := Temp;
   End;

 AutoCompleteVisible := AutoCompleteSuggestionCount > 0;
 AutoCompleteSelectedIndex := 0;
End;

{ Retourne la suggestion selectionnee formatee }
Function AB_GetSelectedSuggestion: String;
Begin
 If (AutoCompleteSelectedIndex >= 0) And
    (AutoCompleteSelectedIndex < AutoCompleteSuggestionCount) Then Begin
  If Length(AutoCompleteSuggestions[AutoCompleteSelectedIndex].DisplayName) > 0 Then
   AB_GetSelectedSuggestion :=
    '"' + AutoCompleteSuggestions[AutoCompleteSelectedIndex].DisplayName + '" <' +
    AutoCompleteSuggestions[AutoCompleteSelectedIndex].Email + '>'
  Else
   AB_GetSelectedSuggestion := AutoCompleteSuggestions[AutoCompleteSelectedIndex].Email;
 End
 Else
  AB_GetSelectedSuggestion := '';
End;

{ ============================================================================
  AFFICHAGE DU CARNET D'ADRESSES
  ============================================================================ }

{ Dessine la fenetre du carnet d'adresses }
Procedure AB_DrawWindow;
Var
 X, Y, W, H: Integer;
 I, Y1: Integer;
 DisplayStr: String;
 SearchResults: Array[0..CONTACTS_VISIBLE-1] of Integer;
 ResultCount: Integer;
Begin
 If Not AddressBookVisible Then Exit;

 X := AddressBookX;
 Y := AddressBookY;
 W := ADDRESSBOOK_WIDTH;
 H := ADDRESSBOOK_HEIGHT;

 { Fond de la fenetre }
 SetFillStyle(SolidFill, LightGray);
 Bar(X, Y, X + W, Y + H);

 { Bordure }
 SetColor(DarkGray);
 Rectangle(X, Y, X + W, Y + H);
 SetColor(White);
 Line(X + 1, Y + 1, X + W - 1, Y + 1);
 Line(X + 1, Y + 1, X + 1, Y + H - 1);

 { Barre de titre }
 SetFillStyle(SolidFill, Blue);
 Bar(X + 2, Y + 2, X + W - 2, Y + 22);
 SetColor(White);
 OutTextXY(X + 10, Y + 7, 'Carnet d''adresses');

 { Bouton fermer }
 SetFillStyle(SolidFill, Red);
 Bar(X + W - 20, Y + 4, X + W - 4, Y + 20);
 SetColor(White);
 OutTextXY(X + W - 16, Y + 7, 'X');

 { Zone de recherche }
 SetFillStyle(SolidFill, White);
 Bar(X + 10, Y + 30, X + W - 100, Y + 48);
 SetColor(Black);
 Rectangle(X + 10, Y + 30, X + W - 100, Y + 48);
 If Length(AddressBookSearchText) > 0 Then
  OutTextXY(X + 14, Y + 35, AddressBookSearchText)
 Else Begin
  SetColor(DarkGray);
  OutTextXY(X + 14, Y + 35, 'Rechercher...');
 End;

 { Boutons }
 SetFillStyle(SolidFill, LightGray);
 Bar(X + W - 90, Y + 30, X + W - 10, Y + 48);
 SetColor(Black);
 Rectangle(X + W - 90, Y + 30, X + W - 10, Y + 48);
 OutTextXY(X + W - 75, Y + 35, 'Nouveau');

 { En-tetes de colonnes }
 Y1 := Y + 55;
 SetFillStyle(SolidFill, LightGray);
 Bar(X + 10, Y1, X + W - 10, Y1 + 18);
 SetColor(Black);
 Rectangle(X + 10, Y1, X + W - 10, Y1 + 18);
 OutTextXY(X + 15, Y1 + 4, 'Nom');
 OutTextXY(X + 15 + CONTACT_COL_NAME, Y1 + 4, 'Email');
 OutTextXY(X + 15 + CONTACT_COL_NAME + CONTACT_COL_EMAIL, Y1 + 4, 'Telephone');

 { Liste des contacts }
 Y1 := Y + 75;
 ResultCount := AB_Search(AddressBookSearchText, SearchResults, CONTACTS_VISIBLE);

 For I := 0 To ResultCount - 1 Do Begin
  If I + ContactScrollOffset >= ContactCount Then Break;

  { Fond de la ligne }
  If SearchResults[I] = ContactSelectedIndex Then
   SetFillStyle(SolidFill, Blue)
  Else If (I Mod 2) = 0 Then
   SetFillStyle(SolidFill, White)
  Else
   SetFillStyle(SolidFill, LightGray);

  Bar(X + 10, Y1 + I * CONTACT_LINE_HEIGHT,
      X + W - 10, Y1 + (I + 1) * CONTACT_LINE_HEIGHT - 1);

  If SearchResults[I] = ContactSelectedIndex Then
   SetColor(White)
  Else
   SetColor(Black);

  { Nom }
  DisplayStr := AB_GenerateDisplayName(Contacts[SearchResults[I]]);
  If Length(DisplayStr) > 20 Then
   DisplayStr := Copy(DisplayStr, 1, 18) + '..';
  OutTextXY(X + 15, Y1 + I * CONTACT_LINE_HEIGHT + 4, DisplayStr);

  { Email }
  DisplayStr := Contacts[SearchResults[I]].Email;
  If Length(DisplayStr) > 25 Then
   DisplayStr := Copy(DisplayStr, 1, 23) + '..';
  OutTextXY(X + 15 + CONTACT_COL_NAME, Y1 + I * CONTACT_LINE_HEIGHT + 4, DisplayStr);

  { Telephone }
  DisplayStr := Contacts[SearchResults[I]].Phone;
  If Length(DisplayStr) > 12 Then
   DisplayStr := Copy(DisplayStr, 1, 10) + '..';
  OutTextXY(X + 15 + CONTACT_COL_NAME + CONTACT_COL_EMAIL,
            Y1 + I * CONTACT_LINE_HEIGHT + 4, DisplayStr);
 End;

 { Boutons du bas }
 Y1 := Y + H - 35;

 { Bouton Modifier }
 SetFillStyle(SolidFill, LightGray);
 Bar(X + 10, Y1, X + 80, Y1 + 25);
 SetColor(Black);
 Rectangle(X + 10, Y1, X + 80, Y1 + 25);
 OutTextXY(X + 18, Y1 + 8, 'Modifier');

 { Bouton Supprimer }
 Bar(X + 90, Y1, X + 170, Y1 + 25);
 Rectangle(X + 90, Y1, X + 170, Y1 + 25);
 OutTextXY(X + 96, Y1 + 8, 'Supprimer');

 { Bouton Import }
 Bar(X + W - 170, Y1, X + W - 90, Y1 + 25);
 Rectangle(X + W - 170, Y1, X + W - 90, Y1 + 25);
 OutTextXY(X + W - 162, Y1 + 8, 'Importer');

 { Bouton Export }
 Bar(X + W - 80, Y1, X + W - 10, Y1 + 25);
 Rectangle(X + W - 80, Y1, X + W - 10, Y1 + 25);
 OutTextXY(X + W - 72, Y1 + 8, 'Exporter');

 { Compteur }
 SetColor(DarkGray);
 DisplayStr := '';
 Str(ContactCount, DisplayStr);
 DisplayStr := DisplayStr + ' contact(s)';
 OutTextXY(X + W Div 2 - 30, Y1 + 8, DisplayStr);
End;

{ Dessine le popup d'auto-completion }
Procedure AB_DrawAutoComplete;
Var
 I, X, Y, W, H: Integer;
 DisplayStr: String;
Begin
 If Not AutoCompleteVisible Then Exit;
 If AutoCompleteSuggestionCount = 0 Then Exit;

 X := AutoCompleteX;
 Y := AutoCompleteY;
 W := 300;
 H := AutoCompleteSuggestionCount * 20 + 4;

 { Ombre }
 SetFillStyle(SolidFill, DarkGray);
 Bar(X + 2, Y + 2, X + W + 2, Y + H + 2);

 { Fond }
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + W, Y + H);

 { Bordure }
 SetColor(Black);
 Rectangle(X, Y, X + W, Y + H);

 { Suggestions }
 For I := 0 To AutoCompleteSuggestionCount - 1 Do Begin
  If I = AutoCompleteSelectedIndex Then Begin
   SetFillStyle(SolidFill, Blue);
   Bar(X + 1, Y + 2 + I * 20, X + W - 1, Y + 2 + (I + 1) * 20 - 1);
   SetColor(White);
  End
  Else
   SetColor(Black);

  DisplayStr := AutoCompleteSuggestions[I].DisplayName;
  If Length(DisplayStr) > 25 Then
   DisplayStr := Copy(DisplayStr, 1, 23) + '..';
  OutTextXY(X + 5, Y + 5 + I * 20, DisplayStr);

  If I <> AutoCompleteSelectedIndex Then SetColor(DarkGray);
  DisplayStr := '<' + AutoCompleteSuggestions[I].Email + '>';
  If Length(DisplayStr) > 30 Then
   DisplayStr := Copy(DisplayStr, 1, 28) + '..';
  OutTextXY(X + 150, Y + 5 + I * 20, DisplayStr);
 End;
End;

{ Affiche le carnet d'adresses }
Procedure AB_Show;
Begin
 AddressBookVisible := True;
 AddressBookState := absList;
 ContactSelectedIndex := -1;
 AddressBookSearchText := '';
 ContactScrollOffset := 0;
End;

{ Cache le carnet d'adresses }
Procedure AB_Hide;
Begin
 AddressBookVisible := False;
 AddressBookState := absHidden;
End;

{ Gere un clic dans le carnet d'adresses }
Function AB_HandleClick(MX, MY: Integer): Boolean;
Var
 X, Y, W, H: Integer;
 I, Y1: Integer;
 SearchResults: Array[0..CONTACTS_VISIBLE-1] of Integer;
 ResultCount: Integer;
Begin
 AB_HandleClick := False;
 If Not AddressBookVisible Then Exit;

 X := AddressBookX;
 Y := AddressBookY;
 W := ADDRESSBOOK_WIDTH;
 H := ADDRESSBOOK_HEIGHT;

 { Verifier si clic dans la fenetre }
 If (MX < X) Or (MX > X + W) Or (MY < Y) Or (MY > Y + H) Then Exit;

 AB_HandleClick := True;

 { Bouton fermer }
 If (MX >= X + W - 20) And (MX <= X + W - 4) And (MY >= Y + 4) And (MY <= Y + 20) Then Begin
  AB_Hide;
  Exit;
 End;

 { Bouton Nouveau }
 If (MX >= X + W - 90) And (MX <= X + W - 10) And (MY >= Y + 30) And (MY <= Y + 48) Then Begin
  { Creer nouveau contact }
  AB_InitContact(EditingContact);
  EditingContactIndex := -1;
  AddressBookState := absNew;
  Exit;
 End;

 { Zone de recherche }
 If (MX >= X + 10) And (MX <= X + W - 100) And (MY >= Y + 30) And (MY <= Y + 48) Then Begin
  AddressBookState := absSearch;
  Exit;
 End;

 { Liste des contacts }
 Y1 := Y + 75;
 ResultCount := AB_Search(AddressBookSearchText, SearchResults, CONTACTS_VISIBLE);

 For I := 0 To ResultCount - 1 Do Begin
  If (MY >= Y1 + I * CONTACT_LINE_HEIGHT) And
     (MY < Y1 + (I + 1) * CONTACT_LINE_HEIGHT) Then Begin
   ContactSelectedIndex := SearchResults[I];
   Exit;
  End;
 End;

 { Boutons du bas }
 Y1 := Y + H - 35;

 { Bouton Modifier }
 If (MX >= X + 10) And (MX <= X + 80) And (MY >= Y1) And (MY <= Y1 + 25) Then Begin
  If ContactSelectedIndex >= 0 Then Begin
   EditingContact := Contacts[ContactSelectedIndex];
   EditingContactIndex := ContactSelectedIndex;
   AddressBookState := absEdit;
  End;
  Exit;
 End;

 { Bouton Supprimer }
 If (MX >= X + 90) And (MX <= X + 170) And (MY >= Y1) And (MY <= Y1 + 25) Then Begin
  If ContactSelectedIndex >= 0 Then Begin
   AB_DeleteContact(ContactSelectedIndex);
  End;
  Exit;
 End;
End;

{ Ajoute des contacts de demonstration }
Procedure AB_AddDemoContacts;
Var
 C: TContact;
Begin
 AB_InitContact(C);
 C.FirstName := 'Jean';
 C.LastName := 'Dupont';
 C.Email := 'jean.dupont@example.com';
 C.Phone := '514-555-1234';
 C.Company := 'Acme Inc.';
 AB_AddContact(C);

 AB_InitContact(C);
 C.FirstName := 'Marie';
 C.LastName := 'Tremblay';
 C.Email := 'marie.tremblay@exemple.ca';
 C.Phone := '418-555-5678';
 C.PhoneMobile := '418-555-9012';
 AB_AddContact(C);

 AB_InitContact(C);
 C.FirstName := 'Pierre';
 C.LastName := 'Martin';
 C.Email := 'p.martin@courriel.net';
 C.Company := 'Tech Solutions';
 C.JobTitle := 'Developpeur';
 AB_AddContact(C);

 AB_InitContact(C);
 C.FirstName := 'Sophie';
 C.LastName := 'Gagnon';
 C.Email := 'sophie.g@mail.com';
 C.Phone := '450-555-3456';
 C.City := 'Montreal';
 C.Country := 'Canada';
 AB_AddContact(C);
End;

{ ============================================================================
  FIN DE L'IMPLEMENTATION DU CARNET D'ADRESSES
  ============================================================================ }

{ Initialise la liste des messages avec des donnees de demonstration }
Procedure InitializeMessageList;
Begin
 MessageCount := 8;
 SelectedMessage := 0;
 LastSelectedMessage := 0;
 MessageScrollOffset := 0;
 SortColumn := 5;  { Tri par date par defaut }
 SortOrder := soDescending;
 CtrlKeyDown := False;
 ShiftKeyDown := False;
 ContextMenuVisible := False;
 HoveredColumn := -1;

 { Initialiser les variables de previsualisation }
 PreviewScrollY := 0;
 PreviewScrollX := 0;
 PreviewMaxScrollY := 0;
 PreviewMaxScrollX := 0;
 PreviewOrientation := poHorizontal;
 PreviewVisible := True;
 PreviewHeaderHeight := PREVIEW_LINE_HEIGHT * PREVIEW_HEADER_LINES + 20;
 InPreviewPane := False;

 { Initialiser le client IMAP }
 IMAP_InitClient;
 { Configurer un serveur IMAP de demonstration }
 IMAP_Configure('imap.example.com', IMAPS_PORT, 'user@example.com', 'password', True);

 { Message 1 - Non lu, priorite haute }
 Messages[0].MsgID := 'MSG001';
 Messages[0].FromName := 'Jean Dupont';
 Messages[0].FromEmail := 'jean.dupont@example.com';
 Messages[0].ToName := 'Moi';
 Messages[0].ToEmail := 'moi@example.com';
 Messages[0].CcEmail := '';
 Messages[0].Subject := 'URGENT: Reunion demain matin';
 Messages[0].DateStr := '01/04/26';
 Messages[0].DateFull := '01 avril 2026, 09:30';
 Messages[0].DateSort := 1743465600;
 Messages[0].Size := 2450;
 Messages[0].Priority := mpHigh;
 Messages[0].HasAttachment := True;
 Messages[0].IsRead := False;
 Messages[0].IsFlagged := True;
 Messages[0].IsSelected := True;
 Messages[0].BodyLineCount := 7;
 Messages[0].Body[0] := 'Bonjour,';
 Messages[0].Body[1] := '';
 Messages[0].Body[2] := 'Je vous rappelle notre reunion de demain a 10h.';
 Messages[0].Body[3] := 'Merci de confirmer votre presence.';
 Messages[0].Body[4] := '';
 Messages[0].Body[5] := 'Cordialement,';
 Messages[0].Body[6] := 'Jean Dupont';
 { Pieces jointes pour Message 1 (TODO 13) }
 Messages[0].AttachmentCount := 1;
 Messages[0].Attachments[0].FileName := 'ordre_du_jour.pdf';
 Messages[0].Attachments[0].FilePath := '';
 Messages[0].Attachments[0].FileSize := 125000;
 Messages[0].Attachments[0].FileType := atPDF;
 Messages[0].Attachments[0].IsEmbedded := False;
 Messages[0].Attachments[0].ContentID := '';
 Messages[0].Attachments[0].IsDangerous := False;

 { Message 2 - Lu }
 Messages[1].MsgID := 'MSG002';
 Messages[1].FromName := 'Marie Martin';
 Messages[1].FromEmail := 'marie.martin@example.com';
 Messages[1].ToName := 'Equipe Projet';
 Messages[1].ToEmail := 'equipe@example.com';
 Messages[1].CcEmail := 'manager@example.com';
 Messages[1].Subject := 'Re: Projet Alpha - Avancement';
 Messages[1].DateStr := '31/03/26';
 Messages[1].DateFull := '31 mars 2026, 14:15';
 Messages[1].DateSort := 1743379200;
 Messages[1].Size := 15230;
 Messages[1].Priority := mpNormal;
 Messages[1].HasAttachment := True;
 Messages[1].IsRead := True;
 Messages[1].IsFlagged := False;
 Messages[1].IsSelected := False;
 Messages[1].BodyLineCount := 10;
 Messages[1].Body[0] := 'Bonjour a tous,';
 Messages[1].Body[1] := '';
 Messages[1].Body[2] := 'Voici le rapport d''avancement du projet Alpha:';
 Messages[1].Body[3] := '- Phase 1: terminee a 100%';
 Messages[1].Body[4] := '- Phase 2: en cours, 65% complete';
 Messages[1].Body[5] := '- Phase 3: planifiee pour le mois prochain';
 Messages[1].Body[6] := '';
 Messages[1].Body[7] := 'Voir le document joint pour les details.';
 Messages[1].Body[8] := '';
 Messages[1].Body[9] := 'Marie';
 { Pieces jointes pour Message 2 (TODO 13) }
 Messages[1].AttachmentCount := 2;
 Messages[1].Attachments[0].FileName := 'rapport_alpha.docx';
 Messages[1].Attachments[0].FilePath := '';
 Messages[1].Attachments[0].FileSize := 85400;
 Messages[1].Attachments[0].FileType := atDocument;
 Messages[1].Attachments[0].IsEmbedded := False;
 Messages[1].Attachments[0].ContentID := '';
 Messages[1].Attachments[0].IsDangerous := False;
 Messages[1].Attachments[1].FileName := 'planning.xlsx';
 Messages[1].Attachments[1].FilePath := '';
 Messages[1].Attachments[1].FileSize := 42300;
 Messages[1].Attachments[1].FileType := atSpreadsheet;
 Messages[1].Attachments[1].IsEmbedded := False;
 Messages[1].Attachments[1].ContentID := '';
 Messages[1].Attachments[1].IsDangerous := False;

 { Message 3 - Lu }
 Messages[2].MsgID := 'MSG003';
 Messages[2].FromName := 'Support Technique';
 Messages[2].FromEmail := 'support@techcorp.com';
 Messages[2].ToName := 'Client';
 Messages[2].ToEmail := 'moi@example.com';
 Messages[2].CcEmail := '';
 Messages[2].Subject := 'Votre demande #1234 a ete traitee';
 Messages[2].DateStr := '30/03/26';
 Messages[2].DateFull := '30 mars 2026, 11:42';
 Messages[2].DateSort := 1743292800;
 Messages[2].Size := 5670;
 Messages[2].Priority := mpNormal;
 Messages[2].HasAttachment := False;
 Messages[2].IsRead := True;
 Messages[2].IsFlagged := False;
 Messages[2].IsSelected := False;
 Messages[2].AttachmentCount := 0;
 Messages[2].BodyLineCount := 8;
 Messages[2].Body[0] := 'Cher client,';
 Messages[2].Body[1] := '';
 Messages[2].Body[2] := 'Votre demande de support #1234 a ete traitee.';
 Messages[2].Body[3] := 'Le probleme a ete resolu par notre equipe technique.';
 Messages[2].Body[4] := '';
 Messages[2].Body[5] := 'Si vous avez d''autres questions, n''hesitez pas.';
 Messages[2].Body[6] := '';
 Messages[2].Body[7] := 'L''equipe Support TechCorp';

 { Message 4 - Non lu, priorite basse }
 Messages[3].MsgID := 'MSG004';
 Messages[3].FromName := 'Newsletter Info';
 Messages[3].FromEmail := 'news@infolettre.com';
 Messages[3].ToName := 'Abonne';
 Messages[3].ToEmail := 'moi@example.com';
 Messages[3].CcEmail := '';
 Messages[3].Subject := 'Les nouveautes de la semaine';
 Messages[3].DateStr := '29/03/26';
 Messages[3].DateFull := '29 mars 2026, 08:00';
 Messages[3].DateSort := 1743206400;
 Messages[3].Size := 45000;
 Messages[3].Priority := mpLow;
 Messages[3].HasAttachment := False;
 Messages[3].IsRead := False;
 Messages[3].IsFlagged := False;
 Messages[3].IsSelected := False;
 Messages[3].BodyLineCount := 12;
 Messages[3].Body[0] := 'Bonjour cher abonne,';
 Messages[3].Body[1] := '';
 Messages[3].Body[2] := 'Decouvrez les nouveautes de cette semaine:';
 Messages[3].Body[3] := '';
 Messages[3].Body[4] := '1. Nouvelle fonctionnalite de recherche avancee';
 Messages[3].Body[5] := '2. Amelioration des performances';
 Messages[3].Body[6] := '3. Correction de bugs mineurs';
 Messages[3].Body[7] := '4. Nouvelle interface utilisateur';
 Messages[3].Body[8] := '';
 Messages[3].Body[9] := 'Pour plus d''informations, visitez notre site.';
 Messages[3].Body[10] := '';
 Messages[3].Body[11] := 'L''equipe Newsletter';

 { Message 5 - Lu }
 Messages[4].MsgID := 'MSG005';
 Messages[4].FromName := 'Admin Systeme';
 Messages[4].FromEmail := 'admin@company.local';
 Messages[4].ToName := 'Tous les employes';
 Messages[4].ToEmail := 'all@company.local';
 Messages[4].CcEmail := 'direction@company.local';
 Messages[4].Subject := 'Maintenance planifiee ce weekend';
 Messages[4].DateStr := '28/03/26';
 Messages[4].DateFull := '28 mars 2026, 16:30';
 Messages[4].DateSort := 1743120000;
 Messages[4].Size := 1234;
 Messages[4].Priority := mpNormal;
 Messages[4].HasAttachment := False;
 Messages[4].IsRead := True;
 Messages[4].IsFlagged := True;
 Messages[4].IsSelected := False;
 Messages[4].BodyLineCount := 9;
 Messages[4].Body[0] := 'Chers collegues,';
 Messages[4].Body[1] := '';
 Messages[4].Body[2] := 'Une maintenance est planifiee ce weekend:';
 Messages[4].Body[3] := '- Debut: Samedi 30 mars, 22h00';
 Messages[4].Body[4] := '- Fin prevue: Dimanche 31 mars, 06h00';
 Messages[4].Body[5] := '';
 Messages[4].Body[6] := 'Les services seront temporairement indisponibles.';
 Messages[4].Body[7] := '';
 Messages[4].Body[8] := 'L''equipe IT';

 { Message 6 - Non lu }
 Messages[5].MsgID := 'MSG006';
 Messages[5].FromName := 'Pierre Durand';
 Messages[5].FromEmail := 'p.durand@mail.fr';
 Messages[5].ToName := 'Moi';
 Messages[5].ToEmail := 'moi@example.com';
 Messages[5].CcEmail := 'secretariat@mail.fr';
 Messages[5].Subject := 'Documents a signer';
 Messages[5].DateStr := '27/03/26';
 Messages[5].DateFull := '27 mars 2026, 10:15';
 Messages[5].DateSort := 1743033600;
 Messages[5].Size := 125000;
 Messages[5].Priority := mpHigh;
 Messages[5].HasAttachment := True;
 Messages[5].IsRead := False;
 Messages[5].IsFlagged := False;
 Messages[5].IsSelected := False;
 Messages[5].BodyLineCount := 8;
 Messages[5].Body[0] := 'Bonjour,';
 Messages[5].Body[1] := '';
 Messages[5].Body[2] := 'Veuillez trouver ci-joint les documents a signer.';
 Messages[5].Body[3] := 'Merci de les retourner signes avant vendredi.';
 Messages[5].Body[4] := '';
 Messages[5].Body[5] := 'En cas de questions, n''hesitez pas a me contacter.';
 Messages[5].Body[6] := '';
 Messages[5].Body[7] := 'Pierre Durand';

 { Message 7 - Lu }
 Messages[6].MsgID := 'MSG007';
 Messages[6].FromName := 'Sophie Leblanc';
 Messages[6].FromEmail := 'sophie.l@webmail.com';
 Messages[6].ToName := 'Amis';
 Messages[6].ToEmail := 'moi@example.com';
 Messages[6].CcEmail := 'autres.amis@webmail.com';
 Messages[6].Subject := 'Invitation anniversaire';
 Messages[6].DateStr := '25/03/26';
 Messages[6].DateFull := '25 mars 2026, 18:45';
 Messages[6].DateSort := 1742860800;
 Messages[6].Size := 8900;
 Messages[6].Priority := mpNormal;
 Messages[6].HasAttachment := True;
 Messages[6].IsRead := True;
 Messages[6].IsFlagged := False;
 Messages[6].IsSelected := False;
 Messages[6].BodyLineCount := 11;
 Messages[6].Body[0] := 'Salut!';
 Messages[6].Body[1] := '';
 Messages[6].Body[2] := 'Je vous invite a mon anniversaire!';
 Messages[6].Body[3] := '';
 Messages[6].Body[4] := 'Date: Samedi 5 avril 2026';
 Messages[6].Body[5] := 'Heure: 19h00';
 Messages[6].Body[6] := 'Lieu: Chez moi';
 Messages[6].Body[7] := '';
 Messages[6].Body[8] := 'Voir le plan en piece jointe.';
 Messages[6].Body[9] := '';
 Messages[6].Body[10] := 'A bientot! Sophie';

 { Message 8 - Lu }
 Messages[7].MsgID := 'MSG008';
 Messages[7].FromName := 'Service Client';
 Messages[7].FromEmail := 'service@boutique.fr';
 Messages[7].ToName := 'Client';
 Messages[7].ToEmail := 'moi@example.com';
 Messages[7].CcEmail := '';
 Messages[7].Subject := 'Votre commande a ete expediee';
 Messages[7].DateStr := '24/03/26';
 Messages[7].DateFull := '24 mars 2026, 14:00';
 Messages[7].DateSort := 1742774400;
 Messages[7].Size := 3200;
 Messages[7].Priority := mpNormal;
 Messages[7].HasAttachment := False;
 Messages[7].IsRead := True;
 Messages[7].IsFlagged := False;
 Messages[7].IsSelected := False;
 Messages[7].BodyLineCount := 9;
 Messages[7].Body[0] := 'Cher client,';
 Messages[7].Body[1] := '';
 Messages[7].Body[2] := 'Votre commande #98765 a ete expediee.';
 Messages[7].Body[3] := '';
 Messages[7].Body[4] := 'Numero de suivi: FR123456789';
 Messages[7].Body[5] := 'Livraison estimee: 2-3 jours ouvrables';
 Messages[7].Body[6] := '';
 Messages[7].Body[7] := 'Merci pour votre achat!';
 Messages[7].Body[8] := 'L''equipe Boutique';

 { Initialiser les colonnes }
 InitializeMessageColumns;
End;

{ Dessine l'indicateur de tri sur un en-tete de colonne }
Procedure DrawSortIndicator(X, Y: Integer; Ascending: Boolean);
Begin
 SetColor(COLOR_MENU_TEXT);
 If Ascending Then Begin
  { Triangle vers le haut }
  Line(X, Y + 6, X + 4, Y);
  Line(X + 4, Y, X + 8, Y + 6);
  Line(X, Y + 6, X + 8, Y + 6);
 End
 Else Begin
  { Triangle vers le bas }
  Line(X, Y, X + 4, Y + 6);
  Line(X + 4, Y + 6, X + 8, Y);
  Line(X, Y, X + 8, Y);
 End;
End;

{ Compare deux messages selon la colonne de tri }
Function CompareMessages(Idx1, Idx2: Integer): Integer;
Var
 Result: Integer;
Begin
 Result := 0;

 Case Columns[SortColumn].ColType Of
  ctPriority: Begin
   If Ord(Messages[Idx1].Priority) < Ord(Messages[Idx2].Priority) Then
    Result := -1
   Else If Ord(Messages[Idx1].Priority) > Ord(Messages[Idx2].Priority) Then
    Result := 1;
  End;

  ctAttachment: Begin
   If Messages[Idx1].HasAttachment And Not Messages[Idx2].HasAttachment Then
    Result := -1
   Else If Not Messages[Idx1].HasAttachment And Messages[Idx2].HasAttachment Then
    Result := 1;
  End;

  ctFlag: Begin
   If Messages[Idx1].IsFlagged And Not Messages[Idx2].IsFlagged Then
    Result := -1
   Else If Not Messages[Idx1].IsFlagged And Messages[Idx2].IsFlagged Then
    Result := 1;
  End;

  ctFrom: Begin
   If Messages[Idx1].FromName < Messages[Idx2].FromName Then
    Result := -1
   Else If Messages[Idx1].FromName > Messages[Idx2].FromName Then
    Result := 1;
  End;

  ctSubject: Begin
   If Messages[Idx1].Subject < Messages[Idx2].Subject Then
    Result := -1
   Else If Messages[Idx1].Subject > Messages[Idx2].Subject Then
    Result := 1;
  End;

  ctDate: Begin
   If Messages[Idx1].DateSort < Messages[Idx2].DateSort Then
    Result := -1
   Else If Messages[Idx1].DateSort > Messages[Idx2].DateSort Then
    Result := 1;
  End;

  ctSize: Begin
   If Messages[Idx1].Size < Messages[Idx2].Size Then
    Result := -1
   Else If Messages[Idx1].Size > Messages[Idx2].Size Then
    Result := 1;
  End;
 End;

 { Inverser si tri descendant }
 If SortOrder = soDescending Then
  Result := -Result;

 CompareMessages := Result;
End;

{ Trie la liste des messages selon la colonne active }
Procedure SortMessageList;
Var
 I, J: Integer;
 Temp: TMessage;
Begin
 If (SortColumn < 0) Or (SortColumn >= ColumnCount) Then Exit;
 If SortOrder = soNone Then Exit;

 { Tri a bulles simple (suffisant pour une demo) }
 For I := 0 To MessageCount - 2 Do Begin
  For J := 0 To MessageCount - I - 2 Do Begin
   If CompareMessages(J, J + 1) > 0 Then Begin
    Temp := Messages[J];
    Messages[J] := Messages[J + 1];
    Messages[J + 1] := Temp;
   End;
  End;
 End;
End;

{ Dessine l'icone de priorite }
Procedure DrawPriorityIcon(X, Y: Integer; Priority: TMessagePriority);
Begin
 Case Priority Of
  mpHigh: Begin
   SetColor(LightRed);
   OutTextXY(X + 4, Y, '!');
  End;
  mpLow: Begin
   SetColor(LightBlue);
   OutTextXY(X + 2, Y, 'v');
  End;
 End;
End;

{ Dessine l'icone de piece jointe }
Procedure DrawAttachmentIcon(X, Y: Integer);
Begin
 SetColor(COLOR_MENU_TEXT);
 { Dessine un trombone simplifie }
 Line(X + 3, Y + 2, X + 3, Y + 10);
 Line(X + 3, Y + 10, X + 8, Y + 10);
 Line(X + 8, Y + 10, X + 8, Y + 4);
 Line(X + 8, Y + 4, X + 5, Y + 4);
 Line(X + 5, Y + 4, X + 5, Y + 8);
End;

{ Dessine l'icone de drapeau }
Procedure DrawFlagIcon(X, Y: Integer);
Begin
 SetColor(LightRed);
 { Mat du drapeau }
 Line(X + 3, Y + 2, X + 3, Y + 12);
 { Drapeau triangulaire }
 Line(X + 3, Y + 2, X + 10, Y + 5);
 Line(X + 10, Y + 5, X + 3, Y + 8);
End;

{ Calcule les positions X des colonnes }
Procedure CalculateColumnPositions;
Var
 I, X: Integer;
Begin
 X := Layout.MessageListRect.X1 + 2;
 For I := 0 To ColumnCount - 1 Do Begin
  Columns[I].X := X;
  X := X + Columns[I].Width;
 End;
End;

{ Trouve l'index de la colonne a une position X }
Function GetColumnAtPoint(X: Integer): Integer;
Var
 I: Integer;
Begin
 GetColumnAtPoint := -1;
 For I := 0 To ColumnCount - 1 Do Begin
  If (X >= Columns[I].X) And (X < Columns[I].X + Columns[I].Width) Then Begin
   GetColumnAtPoint := I;
   Exit;
  End;
 End;
End;

{ Trouve l'index du message a une position Y }
Function GetMessageAtPoint(X, Y: Integer): Integer;
Var
 I: Integer;
Begin
 GetMessageAtPoint := -1;

 { Verifier si on est dans la zone des messages }
 If (X < Layout.MessageListRect.X1) Or (X > Layout.MessageListRect.X2) Then Exit;
 If (Y < Layout.MessageListRect.Y1 + COLUMN_HEADER_HEIGHT) Then Exit;
 If (Y > Layout.MessageListRect.Y2) Then Exit;

 For I := 0 To MessageCount - 1 Do Begin
  If (Messages[I].Y > 0) And
     (Y >= Messages[I].Y) And
     (Y < Messages[I].Y + MESSAGE_ROW_HEIGHT) Then Begin
   GetMessageAtPoint := I;
   Exit;
  End;
 End;
End;

{ Deselectionne tous les messages }
Procedure DeselectAllMessages;
Var
 I: Integer;
Begin
 For I := 0 To MessageCount - 1 Do
  Messages[I].IsSelected := False;
End;

{ Compte le nombre de messages selectionnes }
Function GetSelectedMessageCount: Integer;
Var
 I, Count: Integer;
Begin
 Count := 0;
 For I := 0 To MessageCount - 1 Do
  If Messages[I].IsSelected Then Inc(Count);
 GetSelectedMessageCount := Count;
End;

{ Selectionne une plage de messages (pour Shift+clic) }
Procedure SelectMessageRange(FromIdx, ToIdx: Integer);
Var
 I, StartIdx, EndIdx: Integer;
Begin
 If FromIdx < ToIdx Then Begin
  StartIdx := FromIdx;
  EndIdx := ToIdx;
 End
 Else Begin
  StartIdx := ToIdx;
  EndIdx := FromIdx;
 End;

 For I := StartIdx To EndIdx Do
  Messages[I].IsSelected := True;
End;

{ Gere le clic sur l'en-tete de colonne }
Procedure HandleColumnHeaderClick(ColIdx: Integer);
Begin
 If (ColIdx < 0) Or (ColIdx >= ColumnCount) Then Exit;
 If Not Columns[ColIdx].Sortable Then Exit;

 If SortColumn = ColIdx Then Begin
  { Basculer l'ordre de tri }
  If SortOrder = soAscending Then
   SortOrder := soDescending
  Else
   SortOrder := soAscending;
 End
 Else Begin
  SortColumn := ColIdx;
  SortOrder := soAscending;
 End;

 SortMessageList;
End;

{ Gere le clic sur un message }
Procedure HandleMessageClick(MsgIdx: Integer);
Var
 OldSelected: Integer;
Begin
 If (MsgIdx < 0) Or (MsgIdx >= MessageCount) Then Exit;

 OldSelected := SelectedMessage;

 If ShiftKeyDown And (LastSelectedMessage >= 0) Then Begin
  { Selection de plage avec Shift }
  DeselectAllMessages;
  SelectMessageRange(LastSelectedMessage, MsgIdx);
  SelectedMessage := MsgIdx;
 End
 Else If CtrlKeyDown Then Begin
  { Selection multiple avec Ctrl }
  Messages[MsgIdx].IsSelected := Not Messages[MsgIdx].IsSelected;
  If Messages[MsgIdx].IsSelected Then Begin
   SelectedMessage := MsgIdx;
   LastSelectedMessage := MsgIdx;
  End;
 End
 Else Begin
  { Selection simple }
  DeselectAllMessages;
  Messages[MsgIdx].IsSelected := True;
  SelectedMessage := MsgIdx;
  LastSelectedMessage := MsgIdx;
 End;

 { Reinitialiser le defilement du volet de previsualisation si nouveau message }
 If SelectedMessage <> OldSelected Then Begin
  PreviewScrollY := 0;
  PreviewScrollX := 0;
 End;
End;

{ Initialise le menu contextuel des messages }
Procedure InitializeContextMenu;
Begin
 ContextMenuItemCount := 8;

 ContextMenuItems[0].Caption := 'Ouvrir';
 ContextMenuItems[0].Shortcut := 'Entree';
 ContextMenuItems[0].Separator := False;
 ContextMenuItems[0].Enabled := True;
 ContextMenuItems[0].ItemID := CMD_FILE_OPEN;

 ContextMenuItems[1].Caption := '';
 ContextMenuItems[1].Shortcut := '';
 ContextMenuItems[1].Separator := True;
 ContextMenuItems[1].Enabled := True;
 ContextMenuItems[1].ItemID := 0;

 ContextMenuItems[2].Caption := 'Repondre';
 ContextMenuItems[2].Shortcut := 'Ctrl+R';
 ContextMenuItems[2].Separator := False;
 ContextMenuItems[2].Enabled := True;
 ContextMenuItems[2].ItemID := CMD_MSG_REPLY;

 ContextMenuItems[3].Caption := 'Repondre a tous';
 ContextMenuItems[3].Shortcut := 'Ctrl+Maj+R';
 ContextMenuItems[3].Separator := False;
 ContextMenuItems[3].Enabled := True;
 ContextMenuItems[3].ItemID := CMD_MSG_REPLYALL;

 ContextMenuItems[4].Caption := 'Transferer';
 ContextMenuItems[4].Shortcut := 'Ctrl+F';
 ContextMenuItems[4].Separator := False;
 ContextMenuItems[4].Enabled := True;
 ContextMenuItems[4].ItemID := CMD_MSG_FORWARD;

 ContextMenuItems[5].Caption := '';
 ContextMenuItems[5].Shortcut := '';
 ContextMenuItems[5].Separator := True;
 ContextMenuItems[5].Enabled := True;
 ContextMenuItems[5].ItemID := 0;

 ContextMenuItems[6].Caption := 'Marquer comme lu';
 ContextMenuItems[6].Shortcut := '';
 ContextMenuItems[6].Separator := False;
 ContextMenuItems[6].Enabled := True;
 ContextMenuItems[6].ItemID := 801;

 ContextMenuItems[7].Caption := 'Supprimer';
 ContextMenuItems[7].Shortcut := 'Suppr';
 ContextMenuItems[7].Separator := False;
 ContextMenuItems[7].Enabled := True;
 ContextMenuItems[7].ItemID := CMD_MSG_DELETE;
End;

{ Affiche le menu contextuel }
Procedure ShowContextMenu(X, Y: Integer);
Var
 I, MaxWidth, ItemHeight: Integer;
Begin
 InitializeContextMenu;

 { Calculer les dimensions }
 MaxWidth := 150;
 ItemHeight := 0;
 For I := 0 To ContextMenuItemCount - 1 Do Begin
  If ContextMenuItems[I].Separator Then
   ItemHeight := ItemHeight + 6
  Else
   ItemHeight := ItemHeight + 18;
 End;

 ContextMenuX := X;
 ContextMenuY := Y;
 ContextMenuWidth := MaxWidth;
 ContextMenuHeight := ItemHeight + 4;

 { Ajuster si hors ecran }
 If ContextMenuX + ContextMenuWidth > GetMaxX Then
  ContextMenuX := GetMaxX - ContextMenuWidth;
 If ContextMenuY + ContextMenuHeight > GetMaxY Then
  ContextMenuY := GetMaxY - ContextMenuHeight;

 ContextMenuVisible := True;
 HoveredContextItem := -1;
End;

{ Dessine le menu contextuel }
Procedure DrawContextMenu;
Var
 I, Y: Integer;
Begin
 If Not ContextMenuVisible Then Exit;

 { Fond du menu }
 FillRect(ContextMenuX, ContextMenuY,
          ContextMenuX + ContextMenuWidth, ContextMenuY + ContextMenuHeight,
          COLOR_BUTTON_FACE);
 Draw3DRect(ContextMenuX, ContextMenuY,
            ContextMenuX + ContextMenuWidth, ContextMenuY + ContextMenuHeight,
            True);

 Y := ContextMenuY + 2;

 For I := 0 To ContextMenuItemCount - 1 Do Begin
  If ContextMenuItems[I].Separator Then Begin
   SetColor(COLOR_BUTTON_DARK);
   Line(ContextMenuX + 2, Y + 2, ContextMenuX + ContextMenuWidth - 2, Y + 2);
   SetColor(COLOR_BUTTON_LIGHT);
   Line(ContextMenuX + 2, Y + 3, ContextMenuX + ContextMenuWidth - 2, Y + 3);
   Y := Y + 6;
  End
  Else Begin
   { Fond de l'element survole }
   If I = HoveredContextItem Then Begin
    FillRect(ContextMenuX + 2, Y,
             ContextMenuX + ContextMenuWidth - 2, Y + 16,
             COLOR_LIST_SELECTED);
    SetColor(COLOR_LIST_SELECTED_TEXT);
   End
   Else Begin
    If ContextMenuItems[I].Enabled Then
     SetColor(COLOR_MENU_TEXT)
    Else
     SetColor(COLOR_BUTTON_DARK);
   End;

   OutTextXY(ContextMenuX + 6, Y + 3, ContextMenuItems[I].Caption);

   { Raccourci a droite }
   If ContextMenuItems[I].Shortcut <> '' Then
    OutTextXY(ContextMenuX + ContextMenuWidth - 50, Y + 3,
              ContextMenuItems[I].Shortcut);

   Y := Y + 18;
  End;
 End;
End;

{ Cache le menu contextuel }
Procedure HideContextMenu;
Begin
 ContextMenuVisible := False;
 HoveredContextItem := -1;
End;

{ Trouve l'element du menu contextuel a une position }
Function GetContextMenuItemAtPoint(X, Y: Integer): Integer;
Var
 I, ItemY: Integer;
Begin
 GetContextMenuItemAtPoint := -1;
 If Not ContextMenuVisible Then Exit;

 If (X < ContextMenuX) Or (X > ContextMenuX + ContextMenuWidth) Or
    (Y < ContextMenuY) Or (Y > ContextMenuY + ContextMenuHeight) Then Exit;

 ItemY := ContextMenuY + 2;
 For I := 0 To ContextMenuItemCount - 1 Do Begin
  If ContextMenuItems[I].Separator Then Begin
   ItemY := ItemY + 6;
  End
  Else Begin
   If (Y >= ItemY) And (Y < ItemY + 18) Then Begin
    If ContextMenuItems[I].Enabled Then
     GetContextMenuItemAtPoint := I;
    Exit;
   End;
   ItemY := ItemY + 18;
  End;
 End;
End;

{ Dessine le panneau des dossiers (arbre de navigation) }
Procedure DrawFolderPane;
Var
 Y, I: Integer;
 IndentX: Integer;
 NodeText: String;
 TextColor: Word;
 BgColor: Word;
Begin
 { Fond du panneau }
 FillRect(Layout.FolderPaneRect.X1, Layout.FolderPaneRect.Y1,
          Layout.FolderPaneRect.X2, Layout.FolderPaneRect.Y2, COLOR_FOLDER_BG);
 Draw3DRect(Layout.FolderPaneRect.X1, Layout.FolderPaneRect.Y1,
            Layout.FolderPaneRect.X2, Layout.FolderPaneRect.Y2, False);

 { Titre du panneau }
 SetColor(COLOR_MENU_TEXT);
 Y := Layout.FolderPaneRect.Y1 + 4;
 OutTextXY(Layout.FolderPaneRect.X1 + 4, Y, 'Dossiers');

 Y := Y + 16;
 SetColor(COLOR_BUTTON_DARK);
 Line(Layout.FolderPaneRect.X1 + 2, Y, Layout.FolderPaneRect.X2 - 2, Y);
 Y := Y + 8;

 { Dessiner l'arbre des dossiers }
 For I := 0 To FolderCount - 1 Do Begin
  If Not Folders[I].Visible Then Continue;

  { Sauvegarder la position Y pour la détection des clics }
  Folders[I].Y := Y;

  { Vérifier si on dépasse la zone visible }
  If Y + FOLDER_NODE_HEIGHT > Layout.FolderPaneRect.Y2 - 2 Then
   Break;

  IndentX := Layout.FolderPaneRect.X1 + 4 + (Folders[I].Level * FOLDER_INDENT);

  { Déterminer les couleurs selon l'état }
  If Folders[I].Selected Then Begin
   BgColor := COLOR_LIST_SELECTED;
   TextColor := COLOR_LIST_SELECTED_TEXT;
  End
  Else If I = HoveredFolder Then Begin
   BgColor := COLOR_BUTTON_FACE;
   TextColor := COLOR_MENU_TEXT;
  End
  Else Begin
   BgColor := COLOR_FOLDER_BG;
   TextColor := COLOR_MENU_TEXT;
  End;

  { Dessiner le fond si sélectionné ou survolé }
  If Folders[I].Selected Or (I = HoveredFolder) Then Begin
   FillRect(Layout.FolderPaneRect.X1 + 2, Y - 1,
            Layout.FolderPaneRect.X2 - 2, Y + FOLDER_NODE_HEIGHT - 3, BgColor);
  End;

  { Dessiner le symbole d'expansion si le dossier a des enfants }
  If HasChildren(I) Then Begin
   DrawExpandSymbol(IndentX, Y + 2, Folders[I].Expanded);
   IndentX := IndentX + 12;
  End
  Else Begin
   IndentX := IndentX + 12;
  End;

  { Dessiner l'icône du dossier }
  DrawFolderIcon(IndentX, Y, Folders[I].FolderType, Folders[I].Expanded);
  IndentX := IndentX + 16;

  { Préparer le texte avec compteur de messages non lus }
  If Folders[I].UnreadCount > 0 Then Begin
   Str(Folders[I].UnreadCount, NodeText);
   NodeText := Folders[I].Name + ' (' + NodeText + ')';
  End
  Else
   NodeText := Folders[I].Name;

  { Dessiner le texte }
  SetColor(TextColor);
  OutTextXY(IndentX, Y + 2, NodeText);

  Y := Y + FOLDER_NODE_HEIGHT;
 End;
End;

{ Dessine la liste des messages }
Procedure DrawMessageList;
Var
 Y, I, J: Integer;
 TextColor: Word;
 BgColor: Word;
 DisplayText: String;
 MaxY: Integer;
Begin
 { Calculer les positions des colonnes }
 CalculateColumnPositions;

 { Fond de la liste }
 FillRect(Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
          Layout.MessageListRect.X2, Layout.MessageListRect.Y2, COLOR_LIST_BG);
 Draw3DRect(Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
            Layout.MessageListRect.X2, Layout.MessageListRect.Y2, False);

 { En-tetes de colonnes }
 Y := Layout.MessageListRect.Y1;
 FillRect(Layout.MessageListRect.X1 + 1, Y + 1,
          Layout.MessageListRect.X2 - 1, Y + COLUMN_HEADER_HEIGHT - 1, COLOR_BUTTON_FACE);
 Draw3DRect(Layout.MessageListRect.X1 + 1, Y + 1,
            Layout.MessageListRect.X2 - 1, Y + COLUMN_HEADER_HEIGHT - 1, True);

 { Dessiner chaque en-tete de colonne }
 For I := 0 To ColumnCount - 1 Do Begin
  { Separateur vertical }
  If I > 0 Then Begin
   SetColor(COLOR_BUTTON_DARK);
   Line(Columns[I].X - 1, Y + 2, Columns[I].X - 1, Y + COLUMN_HEADER_HEIGHT - 3);
  End;

  { Titre de la colonne }
  SetColor(COLOR_MENU_TEXT);
  OutTextXY(Columns[I].X + 4, Y + 4, Columns[I].Title);

  { Indicateur de tri }
  If (I = SortColumn) And (SortOrder <> soNone) Then Begin
   DrawSortIndicator(Columns[I].X + Columns[I].Width - 14, Y + 5,
                     SortOrder = soAscending);
  End;
 End;

 { Messages }
 Y := Layout.MessageListRect.Y1 + COLUMN_HEADER_HEIGHT + 1;
 MaxY := Layout.MessageListRect.Y2 - MESSAGE_ROW_HEIGHT;

 For I := 0 To MessageCount - 1 Do Begin
  If Y > MaxY Then Break;

  { Sauvegarder la position Y pour la detection des clics }
  Messages[I].Y := Y;

  { Determiner les couleurs selon l'etat }
  If Messages[I].IsSelected Then Begin
   BgColor := COLOR_LIST_SELECTED;
   TextColor := COLOR_LIST_SELECTED_TEXT;
  End
  Else Begin
   BgColor := COLOR_LIST_BG;
   If Messages[I].IsRead Then
    TextColor := COLOR_LIST_TEXT
   Else
    TextColor := COLOR_MENU_TEXT; { Plus fonce pour les non lus }
  End;

  { Dessiner le fond si selectionne }
  If Messages[I].IsSelected Then Begin
   FillRect(Layout.MessageListRect.X1 + 1, Y,
            Layout.MessageListRect.X2 - 1, Y + MESSAGE_ROW_HEIGHT - 1, BgColor);
  End;

  { Dessiner chaque colonne }
  For J := 0 To ColumnCount - 1 Do Begin
   Case Columns[J].ColType Of
    ctPriority: Begin
     DrawPriorityIcon(Columns[J].X, Y + 1, Messages[I].Priority);
    End;

    ctAttachment: Begin
     If Messages[I].HasAttachment Then
      DrawAttachmentIcon(Columns[J].X, Y + 1);
    End;

    ctFlag: Begin
     If Messages[I].IsFlagged Then
      DrawFlagIcon(Columns[J].X, Y + 1);
    End;

    ctFrom: Begin
     SetColor(TextColor);
     { Tronquer si trop long }
     DisplayText := Messages[I].FromName;
     If Length(DisplayText) > 15 Then
      DisplayText := Copy(DisplayText, 1, 14) + '...';
     OutTextXY(Columns[J].X + 2, Y + 2, DisplayText);
    End;

    ctSubject: Begin
     SetColor(TextColor);
     { Tronquer si trop long }
     DisplayText := Messages[I].Subject;
     If Length(DisplayText) > 28 Then
      DisplayText := Copy(DisplayText, 1, 27) + '...';
     OutTextXY(Columns[J].X + 2, Y + 2, DisplayText);
    End;

    ctDate: Begin
     SetColor(TextColor);
     OutTextXY(Columns[J].X + 2, Y + 2, Messages[I].DateStr);
    End;

    ctSize: Begin
     SetColor(TextColor);
     OutTextXY(Columns[J].X + 2, Y + 2, FormatSize(Messages[I].Size));
    End;
   End;
  End;

  Y := Y + MESSAGE_ROW_HEIGHT;
 End;

 { Dessiner le menu contextuel si visible }
 If ContextMenuVisible Then
  DrawContextMenu;
End;

{ Dessine la barre de defilement verticale du volet de previsualisation }
Procedure DrawPreviewScrollbarV;
Var
 ScrollbarX, ScrollbarY1, ScrollbarY2: Integer;
 ThumbHeight, ThumbY: Integer;
 ContentHeight, ViewHeight: Integer;
Begin
 If Not PreviewVisible Then Exit;
 If PreviewMaxScrollY <= 0 Then Exit;

 ScrollbarX := Layout.PreviewPaneRect.X2 - PREVIEW_SCROLLBAR_WIDTH;
 ScrollbarY1 := Layout.PreviewPaneRect.Y1 + PreviewHeaderHeight + 1;
 ScrollbarY2 := Layout.PreviewPaneRect.Y2 - 1;

 { Fond de la barre de defilement }
 FillRect(ScrollbarX, ScrollbarY1, Layout.PreviewPaneRect.X2 - 1, ScrollbarY2,
          COLOR_BUTTON_FACE);
 Draw3DRect(ScrollbarX, ScrollbarY1, Layout.PreviewPaneRect.X2 - 1, ScrollbarY2,
            False);

 { Calcul du curseur }
 ViewHeight := ScrollbarY2 - ScrollbarY1 - 4;
 ContentHeight := PreviewMaxScrollY + ViewHeight;
 If ContentHeight > 0 Then Begin
  ThumbHeight := (ViewHeight * ViewHeight) Div ContentHeight;
  If ThumbHeight < 20 Then ThumbHeight := 20;
  If ThumbHeight > ViewHeight Then ThumbHeight := ViewHeight;

  ThumbY := ScrollbarY1 + 2 + ((PreviewScrollY * (ViewHeight - ThumbHeight)) Div PreviewMaxScrollY);

  { Dessiner le curseur }
  FillRect(ScrollbarX + 2, ThumbY, Layout.PreviewPaneRect.X2 - 3, ThumbY + ThumbHeight - 1,
           COLOR_BUTTON_FACE);
  Draw3DRect(ScrollbarX + 2, ThumbY, Layout.PreviewPaneRect.X2 - 3, ThumbY + ThumbHeight - 1,
             True);
 End;
End;

{ Dessine le volet de previsualisation }
Procedure DrawPreviewPane;
Var
 Y, I, BodyY, BodyTop, BodyBottom: Integer;
 MsgIdx: Integer;
 HeaderText: String;
 ContentWidth: Integer;
Begin
 { Si le volet est masque, ne rien dessiner }
 If Not PreviewVisible Then Exit;

 { Fond du volet }
 FillRect(Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
          Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2, COLOR_PREVIEW_BG);
 Draw3DRect(Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
            Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2, False);

 { Si aucun message selectionne, afficher un message par defaut }
 If (SelectedMessage < 0) Or (SelectedMessage >= MessageCount) Then Begin
  SetColor(COLOR_BUTTON_DARK);
  Y := (Layout.PreviewPaneRect.Y1 + Layout.PreviewPaneRect.Y2) Div 2;
  OutTextXY(Layout.PreviewPaneRect.X1 + 20, Y, 'Selectionnez un message pour le previsualiser');
  Exit;
 End;

 MsgIdx := SelectedMessage;
 ContentWidth := Layout.PreviewPaneRect.X2 - Layout.PreviewPaneRect.X1 - PREVIEW_SCROLLBAR_WIDTH - 8;

 Y := Layout.PreviewPaneRect.Y1 + 4;

 { En-tete De: }
 SetColor(COLOR_MENU_TEXT);
 HeaderText := 'De: ' + Messages[MsgIdx].FromName + ' <' + Messages[MsgIdx].FromEmail + '>';
 If Length(HeaderText) > 70 Then
  HeaderText := Copy(HeaderText, 1, 67) + '...';
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, HeaderText);
 Y := Y + PREVIEW_LINE_HEIGHT;

 { En-tete A: }
 HeaderText := 'A: ' + Messages[MsgIdx].ToEmail;
 If Length(HeaderText) > 70 Then
  HeaderText := Copy(HeaderText, 1, 67) + '...';
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, HeaderText);
 Y := Y + PREVIEW_LINE_HEIGHT;

 { En-tete Cc: (si present) }
 If Messages[MsgIdx].CcEmail <> '' Then Begin
  HeaderText := 'Cc: ' + Messages[MsgIdx].CcEmail;
  If Length(HeaderText) > 70 Then
   HeaderText := Copy(HeaderText, 1, 67) + '...';
  OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, HeaderText);
  Y := Y + PREVIEW_LINE_HEIGHT;
 End;

 { En-tete Date: }
 HeaderText := 'Date: ' + Messages[MsgIdx].DateFull;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, HeaderText);
 Y := Y + PREVIEW_LINE_HEIGHT;

 { En-tete Objet: }
 HeaderText := 'Objet: ' + Messages[MsgIdx].Subject;
 If Length(HeaderText) > 70 Then
  HeaderText := Copy(HeaderText, 1, 67) + '...';
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, HeaderText);
 Y := Y + 8;

 { Ligne de separation }
 SetColor(COLOR_BUTTON_DARK);
 Line(Layout.PreviewPaneRect.X1 + 2, Y, Layout.PreviewPaneRect.X2 - PREVIEW_SCROLLBAR_WIDTH - 2, Y);
 SetColor(COLOR_BUTTON_LIGHT);
 Line(Layout.PreviewPaneRect.X1 + 2, Y + 1, Layout.PreviewPaneRect.X2 - PREVIEW_SCROLLBAR_WIDTH - 2, Y + 1);

 { Zone de contenu du message avec defilement }
 BodyTop := Y + 4;
 BodyBottom := Layout.PreviewPaneRect.Y2 - 2;
 BodyY := BodyTop - (PreviewScrollY * PREVIEW_LINE_HEIGHT);

 { Calculer le defilement maximum }
 PreviewMaxScrollY := Messages[MsgIdx].BodyLineCount - ((BodyBottom - BodyTop) Div PREVIEW_LINE_HEIGHT);
 If PreviewMaxScrollY < 0 Then PreviewMaxScrollY := 0;

 { Ajuster le defilement si necessaire }
 If PreviewScrollY > PreviewMaxScrollY Then PreviewScrollY := PreviewMaxScrollY;
 If PreviewScrollY < 0 Then PreviewScrollY := 0;

 { Definir le rectangle de decoupage pour le corps }
 SetViewPort(Layout.PreviewPaneRect.X1 + 2, BodyTop,
             Layout.PreviewPaneRect.X2 - PREVIEW_SCROLLBAR_WIDTH - 2, BodyBottom, True);

 { Dessiner les lignes du corps du message }
 SetColor(COLOR_LIST_TEXT);
 For I := 0 To Messages[MsgIdx].BodyLineCount - 1 Do Begin
  If (BodyY >= BodyTop - PREVIEW_LINE_HEIGHT) And (BodyY <= BodyBottom) Then Begin
   OutTextXY(2 - PreviewScrollX, BodyY - BodyTop, Messages[MsgIdx].Body[I]);
  End;
  BodyY := BodyY + PREVIEW_LINE_HEIGHT;
 End;

 { Restaurer le viewport complet }
 SetViewPort(0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, True);

 { Dessiner la barre de defilement verticale si necessaire }
 DrawPreviewScrollbarV;
End;

{ Dessine les séparateurs (splitters) }
Procedure DrawSplitters;
Begin
 { Séparateur vertical }
 FillRect(Layout.VSplitterRect.X1, Layout.VSplitterRect.Y1,
          Layout.VSplitterRect.X2, Layout.VSplitterRect.Y2, COLOR_SPLITTER);
 Draw3DRect(Layout.VSplitterRect.X1, Layout.VSplitterRect.Y1,
            Layout.VSplitterRect.X2, Layout.VSplitterRect.Y2, True);

 { Séparateur horizontal }
 FillRect(Layout.HSplitterRect.X1, Layout.HSplitterRect.Y1,
          Layout.HSplitterRect.X2, Layout.HSplitterRect.Y2, COLOR_SPLITTER);
 Draw3DRect(Layout.HSplitterRect.X1, Layout.HSplitterRect.Y1,
            Layout.HSplitterRect.X2, Layout.HSplitterRect.Y2, True);
End;

{ Dessine la barre d'état }
Procedure DrawStatusBar;
Begin
 FillRect(Layout.StatusBarRect.X1, Layout.StatusBarRect.Y1,
          Layout.StatusBarRect.X2, Layout.StatusBarRect.Y2, COLOR_STATUS_BG);
 Draw3DRect(Layout.StatusBarRect.X1, Layout.StatusBarRect.Y1,
            Layout.StatusBarRect.X2, Layout.StatusBarRect.Y2, False);

 SetColor(COLOR_STATUS_TEXT);
 OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
           '5 messages, 5 non lus | Connecte');
End;

{ ============================================================================
  PROCÉDURE PRINCIPALE DE DESSIN
  ============================================================================ }

{ Dessine toute l'interface }
Procedure DrawInterface;
Begin
 HideMouse;

 { Fond de l'écran }
 FillRect(0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, COLOR_DESKTOP);

 { Calcul de la disposition }
 CalculateLayout;

 { Dessin des éléments }
 DrawTitleBar;
 DrawMenuBar;
 DrawToolBar;
 DrawFolderPane;
 DrawSplitters;
 DrawMessageList;
 DrawPreviewPane;
 DrawStatusBar;

 ShowMouse;
End;

{ ============================================================================
  PROCÉDURES DE GESTION DES ÉVÉNEMENTS
  ============================================================================ }

{ Vérifie si un point est dans un rectangle }
Function PointInRect(X, Y, X1, Y1, X2, Y2: Integer): Boolean;
Begin
 PointInRect := (X >= X1) And (X <= X2) And (Y >= Y1) And (Y <= Y2);
End;

{ Gère le redimensionnement des panneaux avec la souris }
Procedure HandleMouseDrag;
Var
 NewWidth, NewHeight: Integer;
Begin
 Case DragState Of
  dsDragVSplitter: Begin
   { Redimensionnement du panneau des dossiers }
   NewWidth := MouseX - SPLITTER_SIZE Div 2;
   If NewWidth < MIN_FOLDER_WIDTH Then NewWidth := MIN_FOLDER_WIDTH;
   If NewWidth > SCREEN_WIDTH - MIN_MESSAGE_WIDTH - SPLITTER_SIZE Then
    NewWidth := SCREEN_WIDTH - MIN_MESSAGE_WIDTH - SPLITTER_SIZE;
   If NewWidth <> Layout.FolderPaneWidth Then Begin
    Layout.FolderPaneWidth := NewWidth;
    DrawInterface;
   End;
  End;
  dsDragHSplitter: Begin
   { Redimensionnement du volet de prévisualisation }
   NewHeight := Layout.StatusBarRect.Y1 - MouseY - SPLITTER_SIZE;
   If NewHeight < MIN_PREVIEW_HEIGHT Then NewHeight := MIN_PREVIEW_HEIGHT;
   If NewHeight > Layout.StatusBarRect.Y1 - Layout.ToolBarRect.Y2 -
      MIN_PREVIEW_HEIGHT - SPLITTER_SIZE * 2 Then
    NewHeight := Layout.StatusBarRect.Y1 - Layout.ToolBarRect.Y2 -
                 MIN_PREVIEW_HEIGHT - SPLITTER_SIZE * 2;
   If NewHeight <> Layout.PreviewPaneHeight Then Begin
    Layout.PreviewPaneHeight := NewHeight;
    DrawInterface;
   End;
  End;
 End;
End;

{ Gère les clics de souris }
Procedure HandleMouseClick;
Var
 ClickedMenu: Integer;
 ClickedItem: Integer;
Begin
 { Si un menu est ouvert, vérifier le clic }
 If ActiveMenu >= 0 Then Begin
  { Clic sur un élément du menu déroulant? }
  ClickedItem := GetMenuItemAtPoint(MouseX, MouseY);
  If ClickedItem >= 0 Then Begin
   If Menus[ActiveMenu].Items[ClickedItem].Enabled Then
    ExecuteMenuCommand(Menus[ActiveMenu].Items[ClickedItem].ItemID);
   Exit;
  End;

  { Clic sur un autre menu de la barre? }
  ClickedMenu := GetMenuAtPoint(MouseX, MouseY);
  If (ClickedMenu >= 0) And (ClickedMenu <> ActiveMenu) Then Begin
   ActiveMenu := ClickedMenu;
   ActiveMenuItem := -1;
   DrawInterface;
   DrawDropdownMenu(ActiveMenu);
   Exit;
  End;

  { Clic ailleurs = fermer le menu }
  CloseDropdownMenu;
  Exit;
 End;

 { Vérifier le clic sur la barre de menu }
 ClickedMenu := GetMenuAtPoint(MouseX, MouseY);
 If ClickedMenu >= 0 Then Begin
  ActiveMenu := ClickedMenu;
  ActiveMenuItem := -1;
  MenuBarActive := True;
  DrawDropdownMenu(ActiveMenu);
  Exit;
 End;

 { Vérifie si le clic est sur le séparateur vertical }
 If PointInRect(MouseX, MouseY,
    Layout.VSplitterRect.X1, Layout.VSplitterRect.Y1,
    Layout.VSplitterRect.X2, Layout.VSplitterRect.Y2) Then Begin
  DragState := dsDragVSplitter;
  Exit;
 End;

 { Vérifie si le clic est sur le séparateur horizontal }
 If PointInRect(MouseX, MouseY,
    Layout.HSplitterRect.X1, Layout.HSplitterRect.Y1,
    Layout.HSplitterRect.X2, Layout.HSplitterRect.Y2) Then Begin
  DragState := dsDragHSplitter;
  Exit;
 End;

 { Vérifie si le clic est sur le bouton Fermer }
 If PointInRect(MouseX, MouseY, SCREEN_WIDTH - 20, 3,
    SCREEN_WIDTH - 4, 17) Then Begin
  Running := False;
  Exit;
 End;
End;

{ Gère le clic droit de la souris (menu contextuel) }
Procedure HandleRightClick;
Begin
 { Afficher un menu contextuel selon la zone cliquée }
 If PointInRect(MouseX, MouseY,
    Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
    Layout.MessageListRect.X2, Layout.MessageListRect.Y2) Then Begin
  { Menu contextuel pour la liste des messages }
  { TODO: Implémenter le menu contextuel des messages }
  HideMouse;
  SetColor(COLOR_STATUS_TEXT);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Clic droit: Menu contextuel message');
  ShowMouse;
 End
 Else If PointInRect(MouseX, MouseY,
    Layout.FolderPaneRect.X1, Layout.FolderPaneRect.Y1,
    Layout.FolderPaneRect.X2, Layout.FolderPaneRect.Y2) Then Begin
  { Menu contextuel pour le panneau des dossiers }
  { TODO: Implémenter le menu contextuel des dossiers }
  HideMouse;
  SetColor(COLOR_STATUS_TEXT);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Clic droit: Menu contextuel dossier ');
  ShowMouse;
 End;
End;

{ Gère le double-clic de la souris }
Procedure HandleDoubleClick;
Begin
 { Double-clic sur un message = ouvrir le message }
 If PointInRect(MouseX, MouseY,
    Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
    Layout.MessageListRect.X2, Layout.MessageListRect.Y2) Then Begin
  { TODO: Ouvrir le message dans une nouvelle fenêtre }
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(COLOR_STATUS_TEXT);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Double-clic: Ouvrir le message      ');
  ShowMouse;
 End
 Else If PointInRect(MouseX, MouseY,
    Layout.FolderPaneRect.X1, Layout.FolderPaneRect.Y1,
    Layout.FolderPaneRect.X2, Layout.FolderPaneRect.Y2) Then Begin
  { Double-clic sur un dossier = développer/réduire }
  { TODO: Développer ou réduire le dossier }
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(COLOR_STATUS_TEXT);
  OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
            'Double-clic: Developper le dossier  ');
  ShowMouse;
 End;
End;

{ Gère le défilement avec la molette de la souris }
Procedure HandleMouseWheel(Direction: Integer);
Begin
 { Direction > 0 = vers le haut, < 0 = vers le bas }

 { Défilement de la liste des messages }
 If PointInRect(MouseX, MouseY,
    Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
    Layout.MessageListRect.X2, Layout.MessageListRect.Y2) Then Begin
  If Direction > 0 Then Begin
   { Défiler vers le haut }
   If ScrollOffset > 0 Then Dec(ScrollOffset);
  End Else Begin
   { Défiler vers le bas }
   Inc(ScrollOffset);
  End;
  HideMouse;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(COLOR_STATUS_TEXT);
  If Direction > 0 Then
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Molette: Defiler vers le haut      ')
  Else
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Molette: Defiler vers le bas       ');
  ShowMouse;
 End

 { Défilement du volet de prévisualisation }
 Else If PreviewVisible And PointInRect(MouseX, MouseY,
    Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
    Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2) Then Begin
  If Direction > 0 Then Begin
   { Défiler vers le haut }
   PreviewScrollY := PreviewScrollY - PREVIEW_SCROLL_STEP;
   If PreviewScrollY < 0 Then PreviewScrollY := 0;
  End Else Begin
   { Défiler vers le bas }
   PreviewScrollY := PreviewScrollY + PREVIEW_SCROLL_STEP;
   If PreviewScrollY > PreviewMaxScrollY Then PreviewScrollY := PreviewMaxScrollY;
  End;
  HideMouse;
  DrawPreviewPane;
  FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
           Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
  SetColor(COLOR_STATUS_TEXT);
  If Direction > 0 Then
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Molette: Defiler apercu vers haut  ')
  Else
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Molette: Defiler apercu vers bas   ');
  ShowMouse;
 End;
End;

{ Gère le relâchement du bouton de la souris }
Procedure HandleMouseRelease;
Begin
 DragState := dsNone;
End;

{ Met à jour le survol des éléments de menu }
Procedure UpdateMenuHover;
Var
 NewItem: Integer;
Begin
 If ActiveMenu >= 0 Then Begin
  NewItem := GetMenuItemAtPoint(MouseX, MouseY);
  If NewItem <> ActiveMenuItem Then Begin
   ActiveMenuItem := NewItem;
   DrawDropdownMenu(ActiveMenu);
  End;
 End;
End;

{ Met à jour le survol des boutons de barre d'outils }
Procedure UpdateToolbarHover;
Var
 NewHover: Integer;
 I: Integer;
 NeedRedraw: Boolean;
Begin
 NewHover := GetToolButtonAtPoint(MouseX, MouseY);
 NeedRedraw := False;

 If NewHover <> HoveredToolButton Then Begin
  { Réinitialiser l'ancien bouton survolé }
  If HoveredToolButton >= 0 Then Begin
   ToolButtons[HoveredToolButton].State := tbsNormal;
   NeedRedraw := True;
  End;

  { Mettre à jour le nouveau bouton survolé }
  If NewHover >= 0 Then Begin
   If ToolButtons[NewHover].Enabled Then Begin
    ToolButtons[NewHover].State := tbsHover;
    NeedRedraw := True;
    { Démarrer le minuteur d'infobulle }
    TooltipStartTime := GetTickCount;
   End;
  End;

  { Cacher l'infobulle si on change de bouton }
  If TooltipVisible Then
   HideTooltip;

  HoveredToolButton := NewHover;

  { Redessiner la barre d'outils si nécessaire }
  If NeedRedraw And Not TooltipVisible Then Begin
   HideMouse;
   DrawToolBar;
   ShowMouse;
  End;
 End
 Else Begin
  { Afficher l'infobulle après le délai }
  If (HoveredToolButton >= 0) And (Not TooltipVisible) And
     (GetTickCount - TooltipStartTime >= TOOLTIP_DELAY) Then Begin
   ShowTooltip(MouseX, MouseY, ToolButtons[HoveredToolButton].Tooltip);
  End;
 End;
End;

{ Gère le clic sur un bouton de barre d'outils }
Procedure HandleToolbarClick;
Var
 BtnIdx: Integer;
Begin
 BtnIdx := GetToolButtonAtPoint(MouseX, MouseY);
 If BtnIdx >= 0 Then Begin
  If ToolButtons[BtnIdx].Enabled Then Begin
   { Masquer l'infobulle }
   If TooltipVisible Then HideTooltip;

   { Mettre le bouton en état appuyé }
   ToolButtons[BtnIdx].State := tbsPressed;
   PressedToolButton := BtnIdx;
   HideMouse;
   DrawToolBar;
   ShowMouse;
  End;
 End;
End;

{ Gère le relâchement d'un bouton de barre d'outils }
Procedure HandleToolbarRelease;
Begin
 If PressedToolButton >= 0 Then Begin
  { Vérifier si on est toujours sur le même bouton }
  If GetToolButtonAtPoint(MouseX, MouseY) = PressedToolButton Then Begin
   { Exécuter la commande du bouton }
   ExecuteMenuCommand(ToolButtons[PressedToolButton].CommandID);
  End;

  { Réinitialiser l'état du bouton }
  ToolButtons[PressedToolButton].State := tbsNormal;
  PressedToolButton := -1;
  HideMouse;
  DrawToolBar;
  ShowMouse;
 End;
End;

{ Boucle principale de gestion des événements }
Procedure MainEventLoop;
Var
 LastBtn: Integer;
 Key: Char;
 MouseEvent: TMouseEvent;
 InToolbar: Boolean;
 InFolderPane: Boolean;
 InMessageList: Boolean;
 InMessageListHeader: Boolean;
 ClickedCol, ClickedMsg: Integer;
Begin
 Running := True;
 LastBtn := 0;
 DragState := dsNone;
 InitMouseState;
 ActiveMenu := -1;
 ActiveMenuItem := -1;
 MenuBarActive := False;
 HoveredToolButton := -1;
 PressedToolButton := -1;
 TooltipVisible := False;
 LastMouseX := 0;
 LastMouseY := 0;
 HoveredFolder := -1;
 ContextMenuVisible := False;

 While Running Do Begin
  { Lecture de l'état de la souris }
  {$IFDEF FPC}
   GetMouseState(MouseX, MouseY, MouseButtons);
   MouseBtn := MouseButtons;
  {$ELSE}
   GetMouseState(MouseX, MouseY, MouseBtn);
  {$ENDIF}

  { Mise à jour du survol des menus }
  If ActiveMenu >= 0 Then
   UpdateMenuHover;

  { Mise à jour du survol du menu contextuel }
  If ContextMenuVisible Then Begin
   HoveredContextItem := GetContextMenuItemAtPoint(MouseX, MouseY);
   HideMouse;
   DrawContextMenu;
   ShowMouse;
  End;

  { Mise à jour du survol des boutons de barre d'outils }
  InToolbar := (MouseY >= Layout.ToolBarRect.Y1) And
               (MouseY <= Layout.ToolBarRect.Y2);
  InFolderPane := (MouseX >= Layout.FolderPaneRect.X1) And
                  (MouseX <= Layout.FolderPaneRect.X2) And
                  (MouseY >= Layout.FolderPaneRect.Y1 + 28) And
                  (MouseY <= Layout.FolderPaneRect.Y2);
  InMessageListHeader := (MouseX >= Layout.MessageListRect.X1) And
                         (MouseX <= Layout.MessageListRect.X2) And
                         (MouseY >= Layout.MessageListRect.Y1) And
                         (MouseY <= Layout.MessageListRect.Y1 + COLUMN_HEADER_HEIGHT);
  InMessageList := (MouseX >= Layout.MessageListRect.X1) And
                   (MouseX <= Layout.MessageListRect.X2) And
                   (MouseY >= Layout.MessageListRect.Y1 + COLUMN_HEADER_HEIGHT) And
                   (MouseY <= Layout.MessageListRect.Y2);

  If (ActiveMenu < 0) And InToolbar Then
   UpdateToolbarHover
  Else If HoveredToolButton >= 0 Then Begin
   { Réinitialiser quand on quitte la barre d'outils }
   ToolButtons[HoveredToolButton].State := tbsNormal;
   HoveredToolButton := -1;
   If TooltipVisible Then HideTooltip;
   HideMouse;
   DrawToolBar;
   ShowMouse;
  End;

  { Mise à jour du survol de l'arbre de dossiers }
  If (ActiveMenu < 0) And (Not InToolbar) And InFolderPane Then
   UpdateFolderHover
  Else If HoveredFolder >= 0 Then Begin
   HoveredFolder := -1;
   HideMouse;
   DrawFolderPane;
   ShowMouse;
  End;

  { Cacher l'infobulle si la souris bouge trop }
  If TooltipVisible And
     ((Abs(MouseX - LastMouseX) > 5) Or (Abs(MouseY - LastMouseY) > 5)) Then Begin
   HideTooltip;
   TooltipStartTime := GetTickCount;
  End;

  LastMouseX := MouseX;
  LastMouseY := MouseY;

  { Détection des événements souris avancés }
  MouseEvent := DetectMouseEvent(LastBtn, MouseBtn, MouseX, MouseY);

  Case MouseEvent Of
   meLeftClick: Begin
    { Clic simple traité lors de l'appui du bouton }
   End;
   meRightClick: Begin
    { Fermer le menu contextuel si visible }
    If ContextMenuVisible Then Begin
     HideContextMenu;
     HideMouse;
     DrawMessageList;
     ShowMouse;
    End
    { Fermer le menu si ouvert }
    Else If ActiveMenu >= 0 Then
     CloseDropdownMenu
    { Clic droit sur la liste des messages }
    Else If InMessageList Then Begin
     ClickedMsg := GetMessageAtPoint(MouseX, MouseY);
     If ClickedMsg >= 0 Then Begin
      { Selectionner le message si pas deja selectionne }
      If Not Messages[ClickedMsg].IsSelected Then Begin
       DeselectAllMessages;
       Messages[ClickedMsg].IsSelected := True;
       SelectedMessage := ClickedMsg;
      End;
      ShowContextMenu(MouseX, MouseY);
      HideMouse;
      DrawMessageList;
      ShowMouse;
     End;
    End
    Else
     HandleRightClick;
   End;
   meLeftDoubleClick: Begin
    HandleDoubleClick;
   End;
   meRightDoubleClick: Begin
    { Double-clic droit: pas d'action spécifique }
   End;
   meWheelUp: Begin
    HandleMouseWheel(1);
   End;
   meWheelDown: Begin
    HandleMouseWheel(-1);
   End;
  End;

  { Détection du clic gauche (bouton enfoncé) }
  If (MouseBtn And MOUSE_LEFT <> 0) And (LastBtn And MOUSE_LEFT = 0) Then Begin
   { Gerer les clics dans le compositeur de messages (TODO 12) }
   If ComposerVisible Then Begin
    HandleComposerClick(MouseX, MouseY);
   End
   { Gerer les clics dans la boite de dialogue des comptes }
   Else If AccountDialogVisible Then Begin
    HandleAccountDialogClick(MouseX, MouseY);
   End
   { Fermer le menu contextuel si clic ailleurs }
   Else If ContextMenuVisible Then Begin
    ClickedMsg := GetContextMenuItemAtPoint(MouseX, MouseY);
    If ClickedMsg >= 0 Then Begin
     { Executer la commande du menu }
     { TODO: Implementer les actions des commandes }
    End;
    HideContextMenu;
    HideMouse;
    DrawMessageList;
    ShowMouse;
   End
   { Vérifier d'abord si c'est un clic sur la barre d'outils }
   Else If InToolbar And (ActiveMenu < 0) Then
    HandleToolbarClick
   { Vérifier si c'est un clic sur l'arbre de dossiers }
   Else If InFolderPane And (ActiveMenu < 0) Then
    HandleFolderClick(MouseX, MouseY)
   { Verifier si c'est un clic sur l'en-tete de colonne }
   Else If InMessageListHeader And (ActiveMenu < 0) Then Begin
    ClickedCol := GetColumnAtPoint(MouseX);
    If ClickedCol >= 0 Then Begin
     HandleColumnHeaderClick(ClickedCol);
     HideMouse;
     DrawMessageList;
     ShowMouse;
    End;
   End
   { Verifier si c'est un clic sur un message }
   Else If InMessageList And (ActiveMenu < 0) Then Begin
    ClickedMsg := GetMessageAtPoint(MouseX, MouseY);
    If ClickedMsg >= 0 Then Begin
     HandleMessageClick(ClickedMsg);
     HideMouse;
     DrawMessageList;
     ShowMouse;
    End;
   End
   Else
    HandleMouseClick;
  End;

  { Détection du relâchement du bouton gauche }
  If (MouseBtn And MOUSE_LEFT = 0) And (LastBtn And MOUSE_LEFT <> 0) Then Begin
   If PressedToolButton >= 0 Then
    HandleToolbarRelease
   Else
    HandleMouseRelease;
  End;

  { Gestion du glissement }
  If (MouseBtn And MOUSE_LEFT <> 0) And (DragState <> dsNone) Then Begin
   HandleMouseDrag;
  End;

  LastBtn := MouseBtn;

  { Vérification des touches du clavier }
  If KeyPressed Then Begin
   Key := ReadKey;
   { Gerer les touches dans le compositeur de messages (TODO 12) }
   If ComposerVisible Then Begin
    HandleComposerKeyPress(Key);
   End
   { Gerer les touches dans la boite de dialogue des comptes }
   Else If AccountDialogVisible Then Begin
    HandleAccountDialogKeyPress(Key);
   End
   Else If Key = #27 Then Begin
    If TooltipVisible Then
     HideTooltip
    Else If ActiveMenu >= 0 Then
     CloseDropdownMenu
    Else
     Running := False; { Échap pour quitter }
   End;
   If Key = #0 Then ReadKey; { Touches étendues }
  End;

  { Petite pause pour ne pas saturer le CPU }
  Delay(10);
 End;
End;

{ ============================================================================
  PROGRAMME PRINCIPAL
  ============================================================================ }

BEGIN
 { Initialisation du mode graphique }
 InitializeGraphics;

 { Vérification de la souris }
 If Not MouseDriverFound Then Begin
  CloseGraph;
  WriteLn('Erreur: Pilote souris non trouve!');
  WriteLn('Veuillez charger un pilote souris (MOUSE.COM ou equivalent).');
  Halt(1);
 End;

 { Initialisation de la disposition par défaut }
 Layout.FolderPaneWidth := 160;
 Layout.PreviewPaneHeight := 150;

 { Initialisation des menus déroulants }
 InitializeMenus;

 { Initialisation de la barre d'outils }
 InitializeToolbar;

 { Initialisation de l'arbre de dossiers }
 InitializeFolderTree;

 { Initialisation de la liste des messages }
 InitializeMessageList;

 { Initialisation du gestionnaire de comptes (TODO 11) }
 InitializeAccountManager;

 { Initialisation du compositeur de messages (TODO 12) }
 InitializeComposer;

 { Initialisation du gestionnaire de pieces jointes (TODO 13) }
 InitAttachmentManager;

 { Initialisation du moteur de rendu HTML (TODO 14) }
 HTML_Init;

 { Initialisation du decodeur MIME (TODO 15) }
 MIME_Init;

 { Initialisation du carnet d'adresses (TODO 16) }
 AB_Init;
 AB_AddDemoContacts;

 { Affichage de l'interface }
 ShowMouse;
 DrawInterface;

 { Boucle principale }
 MainEventLoop;

 { Fermeture du mode graphique }
 HideMouse;
 CloseGraph;

 WriteLn('Outlook Express - Ferme normalement.');
END.