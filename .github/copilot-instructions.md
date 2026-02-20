# Instructions Copilot pour NETWORKKIT-P

## Vue d'ensemble du projet
NETWORKKIT-P est une collection d'utilitaires réseau Pascal autonomes conçus pour fonctionner avec les compilateurs Free Pascal et Turbo Pascal. Chaque fichier `.PAS` est un outil en ligne de commande indépendant qui fournit des fonctionnalités réseau spécifiques.

## Architecture et structure

### Modèle d'utilitaire individuel
- **Un fichier = Un programme complet** : Chaque fichier `.PAS` contient un programme complet et autonome sans dépendances partagées
- **Auto-suffisant** : Tous les utilitaires sont indépendants et peuvent être compilés individuellement
- **Structure cohérente** : Tous les programmes suivent les mêmes modèles pour l'affichage de l'aide, la gestion des erreurs et le formatage de sortie

### Organisation des fichiers
```
CURL.PAS     - Client HTTP pour récupérer des URLs (utilise fphttpclient, OpenSSLSockets)
IPCONFIG.PAS - Affichage de l'adresse IP locale (utilise Winsock)  
ISEMAIL.PAS  - Validation d'email (Pascal pur, aucune dépendance externe)
WHOAMI.PAS   - Affichage de l'utilisateur actuel (utilise l'unité DOS)
WHOIS.PAS    - Recherche IP vers organisation avec base de données intégrée (utilise Strings)
```

## Modèles de développement

### Compatibilité des compilateurs Pascal
- Cible à la fois **Free Pascal** (`fpc`) et **Turbo Pascal** (`tpc`)
- Utilise la directive `{$mode objfpc}` pour les fonctionnalités spécifiques à Free Pascal
- Évite les fonctionnalités modernes du langage qui cassent la compatibilité Turbo Pascal

### Structure standard du programme
```pascal
{ Commentaire d'en-tête avec @author, @created, @website, @abstract }
Program NOMPROGRAMME;
{$mode objfpc}  { Seulement quand les fonctionnalités Free Pascal sont nécessaires }

Uses [unite1, unite2];  { Garder minimal }

Var [variables globales];

{ Fonctions d'aide ici }

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  { Texte d'aide en français }
 End
  Else
 Begin
  { Logique principale du programme }
 End;
END.
```

### Convention du système d'aide
Chaque programme supporte plusieurs drapeaux d'aide : `/?`, `--help`, `-h`, `/h`, `/H`
Le texte d'aide est toujours en français et suit le format :
```
NOMPROGRAMME : Description de la commande
Syntaxe : NOMPROGRAMME [parametres]
```

### Modèles de gestion d'erreurs
- Utilise `Halt(1)` pour les erreurs de validation des paramètres
- Utilise `Halt(Code)` où Code représente le nombre d'échecs de validation (voir `ISEMAIL.PAS`)
- Entoure les opérations externes dans des blocs `Try/Except` avec des messages d'erreur conviviaux

### Modèle d'intégration de données (WHOIS.PAS)
Les données de recherche volumineuses sont intégrées directement dans le code source sous forme de tableaux constants :
- `CountryList:Array[0..242]of CountryRec` - Mappage des codes pays vers les noms
- `IPNetRangeList:Array[0..1074]of IPNetRange` - Plages IP vers mappage d'organisation
- Utilise des chaînes PChar pour économiser la mémoire dans les grands ensembles de données

## Compilation et construction

### Commandes de compilation
```bash
# Free Pascal (préféré)
fpc NOMFICHIER.PAS

# Turbo Pascal (support hérité)  
tpc NOMFICHIER.PAS
```

### Aucune dépendance de construction
- Aucun Makefile ou script de construction - chaque fichier se compile indépendamment
- Aucune dépendance externe au-delà des bibliothèques d'exécution Pascal
- Unités utilisées : `fphttpclient`, `OpenSSLSockets`, `Winsock`, `DOS`, `Strings`, `SysUtils`

## Détails d'implémentation clés

### Gestion des chaînes
- Utilise des chaînes de style Pascal (préfixées par la longueur)
- La fonction `StrPas()` convertit PChar en chaîne Pascal
- Implémentations personnalisées de `StrToLower()` pour la conversion de casse

### Opérations réseau
- **HTTP** : Utilise la méthode `TFPHTTPClient.SimpleGet()` de Free Pascal
- **Résolution IP** : Appels Winsock directs (`GetHostByName`, `inet_ntoa`)
- **Aucune bibliothèque HTTP externe** - s'appuie sur les intégrés de Free Pascal

### Optimisation des structures de données
- Plages IP stockées comme champs d'octets séparés (`A_IP1,A_IP2,A_IP3,A_IP4`) plutôt que comme chaînes
- PChar utilisé pour les noms d'organisation afin de minimiser la mémoire dans les grands tableaux
- Codes pays comme valeurs Word avec table de recherche

## Langue et localisation
- Utilisation la page de code OEM-US pour la compatibilité avec les systèmes DOS et Turbo Pascal
- Tout le texte orienté utilisateur en **français**
- Commentaires en français 
- Noms de variables en anglais
- Messages d'erreur et texte d'aide localisés selon les conventions du français canadien
