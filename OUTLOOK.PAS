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

  3.  [ ] Système de menus déroulants graphiques
      - Menu Fichier: Nouveau, Ouvrir, Enregistrer, Imprimer, Quitter
      - Menu Édition: Couper, Copier, Coller, Sélectionner tout
      - Menu Affichage: Volet de lecture, Trier par, Colonnes
      - Menu Outils: Comptes, Options, Règles de messages
      - Menu Aide: À propos, Aide en ligne

  4.  [ ] Barre d'outils graphique avec icônes
      - Icônes: Nouveau message, Répondre, Répondre à tous, Transférer
      - Icônes: Envoyer/Recevoir, Supprimer, Imprimer, Carnet d'adresses
      - États visuels: normal, survol, appuyé, désactivé
      - Infobulles au survol de la souris

  5.  [ ] Arbre de navigation multi-comptes (panneau gauche)
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

{ Dessine un bouton de la barre d'outils }
Procedure DrawToolButton(X, Y, W, H: Integer; Pressed: Boolean);
Begin
 FillRect(X, Y, X + W, Y + H, COLOR_BUTTON_FACE);
 Draw3DRect(X, Y, X + W, Y + H, Not Pressed);
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

{ Dessine la barre d'outils }
Procedure DrawToolBar;
Var
 BtnX, BtnY, BtnW, BtnH: Integer;
Begin
 FillRect(Layout.ToolBarRect.X1, Layout.ToolBarRect.Y1,
          Layout.ToolBarRect.X2, Layout.ToolBarRect.Y2, COLOR_TOOLBAR_BG);
 Draw3DRect(Layout.ToolBarRect.X1, Layout.ToolBarRect.Y1,
            Layout.ToolBarRect.X2, Layout.ToolBarRect.Y2, True);

 BtnY := Layout.ToolBarRect.Y1 + 3;
 BtnW := 60;
 BtnH := 22;

 { Bouton Nouveau message }
 BtnX := 4;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 8, BtnY + 6, 'Nouveau');

 { Bouton Répondre }
 BtnX := BtnX + BtnW + 4;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Repondre');

 { Bouton Répondre à tous }
 BtnX := BtnX + BtnW + 4;
 BtnW := 70;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Rep.tous');

 { Bouton Transférer }
 BtnX := BtnX + BtnW + 4;
 BtnW := 70;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Transferer');

 { Séparateur }
 BtnX := BtnX + BtnW + 8;
 SetColor(COLOR_BUTTON_DARK);
 Line(BtnX, BtnY + 2, BtnX, BtnY + BtnH - 2);
 SetColor(COLOR_BUTTON_LIGHT);
 Line(BtnX + 1, BtnY + 2, BtnX + 1, BtnY + BtnH - 2);

 { Bouton Envoyer/Recevoir }
 BtnX := BtnX + 8;
 BtnW := 80;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Env/Recv');

 { Bouton Supprimer }
 BtnX := BtnX + BtnW + 4;
 BtnW := 65;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Supprimer');

 { Bouton Adresses }
 BtnX := BtnX + BtnW + 4;
 BtnW := 65;
 DrawToolButton(BtnX, BtnY, BtnW, BtnH, False);
 SetColor(COLOR_MENU_TEXT);
 OutTextXY(BtnX + 4, BtnY + 6, 'Adresses');
End;

{ Dessine le panneau des dossiers (arbre de navigation) }
Procedure DrawFolderPane;
Var
 Y, Indent: Integer;
Begin
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

 { Arbre des dossiers (simulation) }
 SetColor(COLOR_MENU_TEXT);
 Indent := 4;

 { Compte local }
 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, '[-] Compte local');
 Y := Y + 14;
 Indent := 20;

 { Boîte de réception avec compteur }
 SetColor(COLOR_LIST_SELECTED);
 FillRect(Layout.FolderPaneRect.X1 + 2, Y - 1,
          Layout.FolderPaneRect.X2 - 2, Y + 11, COLOR_LIST_SELECTED);
 SetColor(COLOR_LIST_SELECTED_TEXT);
 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, 'Boite de reception (5)');
 Y := Y + 14;

 SetColor(COLOR_MENU_TEXT);
 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, 'Elements envoyes');
 Y := Y + 14;

 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, 'Brouillons');
 Y := Y + 14;

 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, 'Elements supprimes');
 Y := Y + 14;

 OutTextXY(Layout.FolderPaneRect.X1 + Indent, Y, 'Courrier indesirable');
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
Begin
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

{ Boucle principale de gestion des événements }
Procedure MainEventLoop;
Var
 LastBtn: Integer;
 Key: Char;
 MouseEvent: TMouseEvent;
Begin
 Running := True;
 LastBtn := 0;
 DragState := dsNone;
 InitMouseState;

 While Running Do Begin
  { Lecture de l'état de la souris }
  {$IFDEF FPC}
   GetMouseState(MouseX, MouseY, MouseButtons);
   MouseBtn := MouseButtons;
  {$ELSE}
   GetMouseState(MouseX, MouseY, MouseBtn);
  {$ENDIF}

  { Détection des événements souris avancés }
  MouseEvent := DetectMouseEvent(LastBtn, MouseBtn, MouseX, MouseY);

  Case MouseEvent Of
   meLeftClick: Begin
    { Clic simple traité lors de l'appui du bouton }
   End;
   meRightClick: Begin
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
   HandleMouseClick;
  End;

  { Détection du relâchement du bouton gauche }
  If (MouseBtn And MOUSE_LEFT = 0) And (LastBtn And MOUSE_LEFT <> 0) Then Begin
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
   If Key = #27 Then Running := False; { Échap pour quitter }
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