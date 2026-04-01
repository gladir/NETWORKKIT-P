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

  6.  [ ] Liste des messages avec colonnes triables
      - Colonnes: De, Objet, Date, Taille, Pièces jointes, Priorité
      - Tri ascendant/descendant par clic sur l'en-tête de colonne
      - Indicateurs visuels: lu/non lu (gras), drapeau, priorité haute/basse
      - Sélection multiple avec Ctrl+clic et Shift+clic
      - Menu contextuel au clic droit

  7.  [ ] Volet de prévisualisation des messages
      - Affichage des en-têtes: De, À, Cc, Objet, Date
      - Zone de contenu avec défilement vertical et horizontal
      - Basculer entre affichage horizontal et vertical
      - Option pour masquer/afficher le volet de prévisualisation

  8.  [ ] Client IMAP complet (RFC 3501)
      - Connexion sécurisée TLS/SSL sur le port 993
      - Authentification LOGIN et PLAIN
      - Commandes: SELECT, EXAMINE, FETCH, STORE, COPY, UID
      - Synchronisation des dossiers et messages
      - Support IDLE pour les notifications push
      - Gestion des drapeaux: \Seen, \Answered, \Flagged, \Deleted, \Draft

  9.  [ ] Client POP3 complet (RFC 1939)
      - Connexion sécurisée TLS/SSL sur le port 995
      - Authentification USER/PASS et APOP
      - Commandes: STAT, LIST, RETR, DELE, TOP, UIDL
      - Option: Laisser les messages sur le serveur
      - Téléchargement des en-têtes seulement ou messages complets

  10. [ ] Client SMTP complet (RFC 5321)
      - Connexion sécurisée TLS/SSL sur le port 465/587
      - Authentification PLAIN, LOGIN et CRAM-MD5
      - Support STARTTLS pour les connexions non chiffrées
      - Commandes: EHLO, MAIL FROM, RCPT TO, DATA, QUIT
      - Gestion des erreurs et codes de retour SMTP

  11. [ ] Gestionnaire de comptes de messagerie
      - Assistant de configuration de nouveau compte
      - Paramètres serveur entrant: IMAP/POP3, hôte, port, SSL/TLS
      - Paramètres serveur sortant: SMTP, hôte, port, authentification
      - Test de connexion automatique
      - Stockage sécurisé des mots de passe

  12. [ ] Compositeur de messages graphique
      - Fenêtre de rédaction avec champs À, Cc, Cci, Objet
      - Zone d'édition de texte avec curseur clignotant
      - Formatage de base: gras, italique, souligné, couleur
      - Vérification orthographique intégrée
      - Boutons: Envoyer, Enregistrer brouillon, Annuler

  13. [ ] Support des pièces jointes
      - Ajouter des fichiers depuis le système de fichiers
      - Afficher les pièces jointes avec icônes par type
      - Enregistrer les pièces jointes sur disque
      - Limite de taille configurable
      - Avertissement pour les extensions dangereuses

  14. [ ] Moteur de rendu HTML pour courriels (HTMLRenderer)
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

  15. [ ] Décodage MIME multi-parties (RFC 2045-2049)
      - Détection du Content-Type et des limites
      - Décodage Base64 pour les pièces jointes
      - Décodage Quoted-Printable pour le texte
      - Support des jeux de caractères: UTF-8, ISO-8859-1, Windows-1252
      - Gestion multipart/alternative (texte + HTML)
      - Gestion multipart/mixed (texte + pièces jointes)

  16. [ ] Carnet d'adresses intégré
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
 AddMenuItem(Menus[2], 'Volet de lecture', '', False, CMD_VIEW_PREVIEW);
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
  CMD_FILE_NEW: Begin
   { TODO: Nouveau message }
   HideMouse;
   FillRect(Layout.StatusBarRect.X1 + 1, Layout.StatusBarRect.Y1 + 1,
            Layout.StatusBarRect.X2 - 1, Layout.StatusBarRect.Y2 - 1, COLOR_STATUS_BG);
   SetColor(COLOR_STATUS_TEXT);
   OutTextXY(Layout.StatusBarRect.X1 + 4, Layout.StatusBarRect.Y1 + 5,
             'Commande: Nouveau message          ');
   ShowMouse;
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
 Y, ColX: Integer;
 ColDe, ColObjet, ColDate: Integer;
Begin
 FillRect(Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
          Layout.MessageListRect.X2, Layout.MessageListRect.Y2, COLOR_LIST_BG);
 Draw3DRect(Layout.MessageListRect.X1, Layout.MessageListRect.Y1,
            Layout.MessageListRect.X2, Layout.MessageListRect.Y2, False);

 { En-têtes de colonnes }
 Y := Layout.MessageListRect.Y1;
 FillRect(Layout.MessageListRect.X1 + 1, Y + 1,
          Layout.MessageListRect.X2 - 1, Y + 16, COLOR_BUTTON_FACE);
 Draw3DRect(Layout.MessageListRect.X1 + 1, Y + 1,
            Layout.MessageListRect.X2 - 1, Y + 16, True);

 ColDe := Layout.MessageListRect.X1 + 4;
 ColObjet := Layout.MessageListRect.X1 + 120;
 ColDate := Layout.MessageListRect.X2 - 80;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(ColDe, Y + 4, 'De');
 OutTextXY(ColObjet, Y + 4, 'Objet');
 OutTextXY(ColDate, Y + 4, 'Date');

 { Séparateurs de colonnes }
 SetColor(COLOR_BUTTON_DARK);
 Line(ColObjet - 4, Y + 2, ColObjet - 4, Y + 14);
 Line(ColDate - 4, Y + 2, ColDate - 4, Y + 14);

 { Messages de démonstration }
 Y := Y + 18;

 { Message 1 - Non lu (en gras simulé par couleur) }
 SetColor(COLOR_LIST_SELECTED);
 FillRect(Layout.MessageListRect.X1 + 1, Y,
          Layout.MessageListRect.X2 - 1, Y + 14, COLOR_LIST_SELECTED);
 SetColor(COLOR_LIST_SELECTED_TEXT);
 OutTextXY(ColDe, Y + 2, 'Jean Dupont');
 OutTextXY(ColObjet, Y + 2, 'Reunion demain');
 OutTextXY(ColDate, Y + 2, '01/04/26');
 Y := Y + 16;

 { Message 2 }
 SetColor(COLOR_LIST_TEXT);
 OutTextXY(ColDe, Y + 2, 'Marie Martin');
 OutTextXY(ColObjet, Y + 2, 'Re: Projet X');
 OutTextXY(ColDate, Y + 2, '31/03/26');
 Y := Y + 16;

 { Message 3 }
 OutTextXY(ColDe, Y + 2, 'Support Tech');
 OutTextXY(ColObjet, Y + 2, 'Votre demande #1234');
 OutTextXY(ColDate, Y + 2, '30/03/26');
 Y := Y + 16;

 { Message 4 }
 OutTextXY(ColDe, Y + 2, 'Newsletter');
 OutTextXY(ColObjet, Y + 2, 'Nouveautes de la semaine');
 OutTextXY(ColDate, Y + 2, '29/03/26');
 Y := Y + 16;

 { Message 5 }
 OutTextXY(ColDe, Y + 2, 'Admin Systeme');
 OutTextXY(ColObjet, Y + 2, 'Maintenance prevue');
 OutTextXY(ColDate, Y + 2, '28/03/26');
End;

{ Dessine le volet de prévisualisation }
Procedure DrawPreviewPane;
Var
 Y: Integer;
Begin
 FillRect(Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
          Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2, COLOR_PREVIEW_BG);
 Draw3DRect(Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
            Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2, False);

 Y := Layout.PreviewPaneRect.Y1 + 4;

 { En-têtes du message }
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'De: Jean Dupont <jean.dupont@example.com>');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'A: moi@example.com');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Date: 01 avril 2026 09:30');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Objet: Reunion demain');

 Y := Y + 8;
 SetColor(COLOR_BUTTON_DARK);
 Line(Layout.PreviewPaneRect.X1 + 2, Y, Layout.PreviewPaneRect.X2 - 2, Y);

 { Corps du message }
 Y := Y + 8;
 SetColor(COLOR_LIST_TEXT);
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Bonjour,');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, '');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Je vous rappelle notre reunion de demain a 10h.');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Merci de confirmer votre presence.');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, '');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Cordialement,');
 Y := Y + 14;
 OutTextXY(Layout.PreviewPaneRect.X1 + 4, Y, 'Jean Dupont');
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
 Else If PointInRect(MouseX, MouseY,
    Layout.PreviewPaneRect.X1, Layout.PreviewPaneRect.Y1,
    Layout.PreviewPaneRect.X2, Layout.PreviewPaneRect.Y2) Then Begin
  HideMouse;
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

  { Mise à jour du survol des boutons de barre d'outils }
  InToolbar := (MouseY >= Layout.ToolBarRect.Y1) And
               (MouseY <= Layout.ToolBarRect.Y2);
  InFolderPane := (MouseX >= Layout.FolderPaneRect.X1) And
                  (MouseX <= Layout.FolderPaneRect.X2) And
                  (MouseY >= Layout.FolderPaneRect.Y1 + 28) And
                  (MouseY <= Layout.FolderPaneRect.Y2);

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
    { Fermer le menu si ouvert, sinon gérer clic droit }
    If ActiveMenu >= 0 Then
     CloseDropdownMenu
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
   { Vérifier d'abord si c'est un clic sur la barre d'outils }
   If InToolbar And (ActiveMenu < 0) Then
    HandleToolbarClick
   { Vérifier si c'est un clic sur l'arbre de dossiers }
   Else If InFolderPane And (ActiveMenu < 0) Then
    HandleFolderClick(MouseX, MouseY)
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
   If Key = #27 Then Begin
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