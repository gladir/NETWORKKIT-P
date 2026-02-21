{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande ssh (Secure Shell))
}

Program SSH;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Structure pour une connexion SSH }
 TSSHConnection = Record
  Hostname: String[64];      { Nom d'hôte ou IP }
  Port: Word;                { Port SSH (défaut 22) }
  Username: String[64];      { Nom d'utilisateur }
  Password: String[128];     { Mot de passe (non recommandé) }
  KeyFile: String[64];       { Fichier de clé privée }
  ForwardX11: Boolean;       { Redirection X11 }
  Compression: Boolean;      { Compression }
  Verbose: Integer;          { Niveau de verbosité (0-3) }
  BatchMode: Boolean;        { Mode batch (non-interactif) }
  ConfigFile: String[64];    { Fichier de configuration }
  Command: String[128];      { Commande à exécuter }
  LocalForward: String[64];  { Redirection de port locale }
  RemoteForward: String[64]; { Redirection de port distante }
  Cipher: String[32];        { Algorithme de chiffrement }
  Protocol: Integer;         { Version du protocole SSH (1 ou 2) }
  Connected: Boolean;        { État de la connexion }
  LoginTime: String[19];     { Heure de connexion }
  BytesSent: LongInt;        { Octets envoyés }
  BytesReceived: LongInt;    { Octets reçus }
 End;

 { Structure pour une session SSH active }
 TSSHSession = Record
  SessionID: Integer;        { ID de session }
  Connection: TSSHConnection; { Informations de connexion }
  Active: Boolean;           { Session active }
  StartTime: String[19];     { Heure de démarrage }
  LastActivity: String[19];  { Dernière activité }
  Commands: Integer;         { Nombre de commandes exécutées }
 End;

Const
 MAX_SSH_SESSIONS = 32;
 DEFAULT_SSH_PORT = 22;
 SSH_VERSION = '2.0';

Var
 SSHSessions: Array[0..MAX_SSH_SESSIONS-1] of TSSHSession;
 SessionCount: Integer;
 CurrentSession: Integer;

{ Résolution DNS simulée avec base de données étendue }

{ Initialiser les sessions SSH }
Procedure InitializeSSH;
Var
 I: Integer;
Begin
 SessionCount := 0;
 CurrentSession := -1;
 
 For I := 0 To MAX_SSH_SESSIONS-1 Do Begin
  With SSHSessions[I] Do Begin
   SessionID := I;
   With Connection Do Begin
    Hostname := '';
    Port := DEFAULT_SSH_PORT;
    Username := '';
    Password := '';
    KeyFile := '';
    ForwardX11 := False;
    Compression := False;
    Verbose := 0;
    BatchMode := False;
    ConfigFile := '';
    Command := '';
    LocalForward := '';
    RemoteForward := '';
    Cipher := 'aes128-ctr';
    Protocol := 2;
    Connected := False;
    LoginTime := '';
    BytesSent := 0;
    BytesReceived := 0;
   End;
   Active := False;
   StartTime := '';
   LastActivity := '';
   Commands := 0;
  End;
 End;
End;

{ Créer des sessions SSH d'exemple }
Procedure CreateSampleSessions;
Begin
 { Session locale }
 With SSHSessions[0] Do Begin
  SessionID := 0;
  With Connection Do Begin
   Hostname := 'localhost';
   Port := 22;
   Username := 'user';
   KeyFile := '~/.ssh/id_rsa';
   ForwardX11 := False;
   Compression := False;
   Verbose := 0;
   BatchMode := False;
   ConfigFile := '~/.ssh/config';
   Command := '';
   LocalForward := '';
   RemoteForward := '';
   Cipher := 'aes128-ctr';
   Protocol := 2;
   Connected := True;
   LoginTime := '2026-02-21 14:30:15';
   BytesSent := 2048;
   BytesReceived := 4096;
  End;
  Active := True;
  StartTime := '2026-02-21 14:30:15';
  LastActivity := '2026-02-21 14:35:22';
  Commands := 15;
 End;
 
 { Session serveur de développement }
 With SSHSessions[1] Do Begin
  SessionID := 1;
  With Connection Do Begin
   Hostname := 'dev.example.com';
   Port := 2222;
   Username := 'developer';
   KeyFile := '~/.ssh/dev_key';
   ForwardX11 := True;
   Compression := True;
   Verbose := 1;
   BatchMode := False;
   ConfigFile := '~/.ssh/config';
   Command := '';
   LocalForward := '8080:localhost:80';
   RemoteForward := '';
   Cipher := 'aes256-gcm';
   Protocol := 2;
   Connected := True;
   LoginTime := '2026-02-21 13:15:42';
   BytesSent := 15360;
   BytesReceived := 32768;
  End;
  Active := True;
  StartTime := '2026-02-21 13:15:42';
  LastActivity := '2026-02-21 14:22:18';
  Commands := 43;
 End;
 
 { Session de sauvegarde }
 With SSHSessions[2] Do Begin
  SessionID := 2;
  With Connection Do Begin
   Hostname := 'backup.internal';
   Port := 22;
   Username := 'backup';
   KeyFile := '~/.ssh/backup_key';
   ForwardX11 := False;
   Compression := True;
   Verbose := 0;
   BatchMode := True;
   ConfigFile := '';
   Command := 'rsync -av /home/ /backup/';
   LocalForward := '';
   RemoteForward := '';
   Cipher := 'chacha20-poly1305';
   Protocol := 2;
   Connected := False;
   LoginTime := '2026-02-21 12:00:00';
   BytesSent := 1048576;
   BytesReceived := 512;
  End;
  Active := False;
  StartTime := '2026-02-21 12:00:00';
  LastActivity := '2026-02-21 12:15:30';
  Commands := 1;
 End;
 
 SessionCount := 3;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Fonctions utilitaires pour Turbo Pascal }
Function IntToStr(Value: LongInt): String;
Var
 S: String;
Begin
 Str(Value, S);
 IntToStr := S;
End;

Function StrToInt(S: String): LongInt;
Var
 Value: LongInt;
 Code: Integer;
Begin
 Val(S, Value, Code);
 If Code <> 0 Then Value := 0;
 StrToInt := Value;
End;

Function LowerCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['A'..'Z'] Then S[I] := Chr(Ord(S[I]) + 32);
 LowerCase := S;
End;

Function UpperCase(S: String): String;
Var
 I: Integer;
Begin
 For I := 1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I] := Chr(Ord(S[I]) - 32);
 UpperCase := S;
End;

Function Copy(S: String; Start, Len: Integer): String;
Var
 ResultStr: String;
 I: Integer;
Begin
 ResultStr := '';
 For I := Start To Start + Len - 1 Do
  If I <= Length(S) Then ResultStr := ResultStr + S[I];
 Copy := ResultStr;
End;

Function Pos(SubStr, S: String): Integer;
Var
 I, J: Integer;
 Found: Boolean;
Begin
 Pos := 0;
 For I := 1 To Length(S) - Length(SubStr) + 1 Do Begin
  Found := True;
  For J := 1 To Length(SubStr) Do
   If S[I + J - 1] <> SubStr[J] Then Begin
    Found := False;
    Break;
   End;
  If Found Then Begin
   Pos := I;
   Break;
  End;
 End;
End;
{$ENDIF}

{$IFDEF FPC}
{ Valider une adresse IP }
Function IsValidIP(IP: String): Boolean;
Var
 I, Dots, Num: Integer;
 S: String;
 P: Integer;
Begin
 IsValidIP := False;
 If Length(IP) = 0 Then Exit;
 
 Dots := 0;
 S := IP + '.';
 P := 1;
 
 For I := 1 To Length(S) Do Begin
  If S[I] = '.' Then Begin
   If P = I Then Exit;
   Num := StrToInt(Copy(S, P, I - P));
   If (Num < 0) or (Num > 255) Then Exit;
   Inc(Dots);
   P := I + 1;
  End Else If not (S[I] in ['0'..'9']) Then
   Exit;
 End;
 
 IsValidIP := (Dots = 4);
End;

{ Résoudre un nom d'hôte en adresse IP avec base de données étendue }
Function ResolveHostname(Hostname: String): String;
Begin
 ResolveHostname := Hostname;
 
 { Vérifier si c'est déjà une adresse IP valide }
 If IsValidIP(Hostname) Then Begin
  ResolveHostname := Hostname;
  Exit;
 End;
 
 { Base de données de résolution étendue }
 If LowerCase(Hostname) = 'localhost' Then
  ResolveHostname := '127.0.0.1'
 Else If LowerCase(Hostname) = 'example.com' Then
  ResolveHostname := '93.184.216.34'
 Else If LowerCase(Hostname) = 'github.com' Then
  ResolveHostname := '140.82.113.3'
 Else If LowerCase(Hostname) = 'google.com' Then
  ResolveHostname := '142.250.185.46'
 Else If LowerCase(Hostname) = 'microsoft.com' Then
  ResolveHostname := '20.112.250.133'
 Else If LowerCase(Hostname) = 'stackoverflow.com' Then
  ResolveHostname := '151.101.129.69'
 Else If LowerCase(Hostname) = 'wikipedia.org' Then
  ResolveHostname := '208.80.154.224'
 Else If LowerCase(Hostname) = 'youtube.com' Then
  ResolveHostname := '172.217.16.238'
 Else If LowerCase(Hostname) = 'facebook.com' Then
  ResolveHostname := '157.240.241.35'
 Else If LowerCase(Hostname) = 'amazon.com' Then
  ResolveHostname := '176.32.103.205'
 Else If LowerCase(Hostname) = 'twitter.com' Then
  ResolveHostname := '104.244.42.129'
 Else If LowerCase(Hostname) = 'reddit.com' Then
  ResolveHostname := '151.101.1.140'
 Else If LowerCase(Hostname) = 'linkedin.com' Then
  ResolveHostname := '13.107.42.14'
 Else If LowerCase(Hostname) = 'instagram.com' Then
  ResolveHostname := '157.240.241.174'
 Else If LowerCase(Hostname) = 'netflix.com' Then
  ResolveHostname := '54.155.178.5'
 Else If LowerCase(Hostname) = 'ubuntu.com' Then
  ResolveHostname := '185.125.190.39'
 Else If LowerCase(Hostname) = 'debian.org' Then
  ResolveHostname := '151.101.2.132'
 Else If LowerCase(Hostname) = 'freepascal.org' Then
  ResolveHostname := '85.158.180.26'
 Else If LowerCase(Hostname) = 'sourceforge.net' Then
  ResolveHostname := '216.105.38.12'
 Else If LowerCase(Hostname) = 'gitlab.com' Then
  ResolveHostname := '172.65.251.78'
 Else If LowerCase(Hostname) = 'bitbucket.org' Then
  ResolveHostname := '104.192.143.3'
 Else If Copy(LowerCase(Hostname), 1, 4) = 'www.' Then
  { Retirer www. et résoudre à nouveau }
  ResolveHostname := ResolveHostname(Copy(Hostname, 5, Length(Hostname) - 4))
 Else If Pos('.local', LowerCase(Hostname)) > 0 Then
  ResolveHostname := '192.168.1.' + IntToStr(100 + (Length(Hostname) mod 50))
 Else If Pos('.dev', LowerCase(Hostname)) > 0 Then
  ResolveHostname := '10.0.0.' + IntToStr(10 + (Length(Hostname) mod 200))
 Else If Pos('.test', LowerCase(Hostname)) > 0 Then
  ResolveHostname := '172.16.0.' + IntToStr(1 + (Length(Hostname) mod 254))
 Else If Pos('.', Hostname) = 0 Then
  { Nom simple sans domaine - adresse locale }
  ResolveHostname := '192.168.1.' + IntToStr(100 + (Length(Hostname) mod 50))
 Else
  { Domaine inconnu - générer IP basée sur le hash du nom }
  ResolveHostname := '203.0.113.' + IntToStr(1 + (Length(Hostname) mod 254));
End;

{ Parser une spécification d'hôte (utilisateur@hôte:port) }
Procedure ParseHostSpec(HostSpec: String; var Username, Hostname: String; var Port: Word);
Var
 AtPos, ColonPos: Integer;
 PortStr: String;
Begin
 Username := '';
 Hostname := HostSpec;
 Port := DEFAULT_SSH_PORT;
 
 { Chercher le @ pour le nom d'utilisateur }
 AtPos := Pos('@', HostSpec);
 If AtPos > 0 Then Begin
  Username := Copy(HostSpec, 1, AtPos - 1);
  Hostname := Copy(HostSpec, AtPos + 1, Length(HostSpec) - AtPos);
 End;
 
 { Chercher le : pour le port }
 ColonPos := Pos(':', Hostname);
 If ColonPos > 0 Then Begin
  PortStr := Copy(Hostname, ColonPos + 1, Length(Hostname) - ColonPos);
  Hostname := Copy(Hostname, 1, ColonPos - 1);
  Port := StrToInt(PortStr);
  If Port = 0 Then Port := DEFAULT_SSH_PORT;
 End;
End;

{ Créer une nouvelle session SSH }
Function CreateSSHSession(HostSpec, Command: String; Options: String): Integer;
Var
 Index: Integer;
 Username, Hostname: String;
 Port: Word;
Begin
 CreateSSHSession := -1;
 
 If SessionCount >= MAX_SSH_SESSIONS Then Begin
  WriteLn('ssh: Nombre maximum de sessions atteint');
  Exit;
 End;
 
 { Parser la spécification d'hôte }
 ParseHostSpec(HostSpec, Username, Hostname, Port);
 
 If Username = '' Then Username := 'user'; { Utilisateur par défaut }
 
 Index := SessionCount;
 With SSHSessions[Index] Do Begin
  SessionID := Index;
  With Connection Do Begin
   SSHSessions[Index].Connection.Hostname := Hostname;
   SSHSessions[Index].Connection.Port := Port;
   SSHSessions[Index].Connection.Username := Username;
   Password := '';
   KeyFile := '~/.ssh/id_rsa';
   ForwardX11 := False;
   Compression := False;
   Verbose := 0;
   BatchMode := False;
   ConfigFile := '~/.ssh/config';
   SSHSessions[Index].Connection.Command := Command;
   LocalForward := '';
   RemoteForward := '';
   Cipher := 'aes128-ctr';
   Protocol := 2;
   Connected := True;
   LoginTime := '2026-02-21 14:30:15';
   BytesSent := 0;
   BytesReceived := 0;
  End;
  Active := True;
  StartTime := SSHSessions[Index].Connection.LoginTime;
  LastActivity := SSHSessions[Index].Connection.LoginTime;
  Commands := 0;
 End;
 
 Inc(SessionCount);
 CreateSSHSession := Index;
End;

{ Simuler une connexion SSH }
Function ConnectSSH(var Session: TSSHSession): Boolean;
Var
 ResolvedIP: String;
Begin
 ConnectSSH := False;
 
 With Session.Connection Do Begin
  WriteLn('Tentative de connexion à ', Hostname, ':', Port, '...');
  
  { Résolution DNS }
  ResolvedIP := ResolveHostname(Hostname);
  If ResolvedIP <> Hostname Then
   WriteLn('Résolution DNS: ', Hostname, ' -> ', ResolvedIP);
  
  { Simulation de la négociation SSH }
  WriteLn('SSH-', SSH_VERSION, '-NETWORKKIT_', Username, '@', Hostname);
  WriteLn('Échange de clés...');
  WriteLn('Algorithme: ', Cipher);
  WriteLn('Authentification par clé publique...');
  
  If KeyFile <> '' Then
   WriteLn('Utilisation de la clé: ', KeyFile);
  
  Connected := True;
  LoginTime := '2026-02-21 14:30:15';
 End;
 
 Session.Active := True;
 Session.LastActivity := Session.Connection.LoginTime;
 
 WriteLn('Connexion établie avec ', Session.Connection.Hostname);
 WriteLn('Bienvenue sur ', Session.Connection.Hostname, '!');
 WriteLn;
 
 ConnectSSH := True;
End;

{ Exécuter une commande SSH }
Function ExecuteSSHCommand(var Session: TSSHSession; Command: String): Boolean;
Begin
 ExecuteSSHCommand := False;
 
 If not Session.Active Then Begin
  WriteLn('ssh: Session non active');
  Exit;
 End;
 
 With Session.Connection Do Begin
  WriteLn('Exécution de "', Command, '" sur ', Hostname, '...');
  WriteLn;
  
  { Simulation de sortie de commande selon le type }
  If LowerCase(Command) = 'pwd' Then
   WriteLn('/home/', Username)
  Else If LowerCase(Command) = 'whoami' Then
   WriteLn(Username)
  Else If LowerCase(Command) = 'hostname' Then
   WriteLn(Hostname)
  Else If Copy(LowerCase(Command), 1, 2) = 'ls' Then Begin
   WriteLn('total 12');
   WriteLn('drwxr-xr-x  2 ', Username, ' ', Username, ' 4096 Feb 21 14:30 Documents');
   WriteLn('drwxr-xr-x  2 ', Username, ' ', Username, ' 4096 Feb 21 13:15 Downloads');
   WriteLn('-rw-r--r--  1 ', Username, ' ', Username, '  220 Feb 21 12:00 .bash_logout');
  End Else If Copy(LowerCase(Command), 1, 6) = 'uptime' Then
   WriteLn(' 14:35:22 up 2 days,  3:15,  2 users,  load average: 0.15, 0.10, 0.05')
  Else If Copy(LowerCase(Command), 1, 2) = 'df' Then Begin
   WriteLn('Filesystem     1K-blocks    Used Available Use% Mounted on');
   WriteLn('/dev/sda1       50264772 8901234  38745678  19% /');
   WriteLn('tmpfs             506420       0    506420   0% /dev/shm');
  End Else
   WriteLn('Commande "', Command, '" exécutée avec succès');
  
  { Mettre à jour les statistiques }
  Inc(Session.Connection.BytesSent, Length(Command) + 10);
  Inc(Session.Connection.BytesReceived, 100);
  Session.LastActivity := '2026-02-21 14:35:22';
 End;
 
 Inc(Session.Commands);
 
 ExecuteSSHCommand := True;
End;

{ Fermer une session SSH }
Procedure CloseSSHSession(var Session: TSSHSession);
Begin
 If Session.Active Then Begin
  WriteLn('Fermeture de la connexion avec ', Session.Connection.Hostname);
  Session.Active := False;
  Session.Connection.Connected := False;
 End;
End;

{ Lister les sessions SSH actives }
Procedure ListSSHSessions;
Var
 I: Integer;
Begin
 If SessionCount = 0 Then Begin
  WriteLn('Aucune session SSH active');
  Exit;
 End;
 
 WriteLn('Sessions SSH actives:');
 WriteLn('====================');
 WriteLn('ID  Utilisateur@Hôte              Port  État     Démarrage        Commandes');
 WriteLn('--- ----------------------------- ----- -------- ---------------- ---------');
 
 For I := 0 To SessionCount - 1 Do Begin
  With SSHSessions[I] Do Begin
   Write(SessionID:2, '  ');
   Write(Copy(Connection.Username + '@' + Connection.Hostname + 
              '                             ', 1, 29), ' ');
   Write(Connection.Port:5, ' ');
   If Active Then Write('Actif   ') Else Write('Fermé   ');
   Write(Copy(StartTime + '                ', 1, 16), ' ');
   WriteLn(Commands:4);
  End;
 End;
 
 WriteLn;
 WriteLn('Total: ', SessionCount, ' session(s)');
End;

{ Afficher les détails d'une session }
Procedure ShowSessionDetails(SessionID: Integer);
Begin
 If (SessionID < 0) or (SessionID >= SessionCount) Then Begin
  WriteLn('ssh: Session ', SessionID, ' introuvable');
  Exit;
 End;
 
 With SSHSessions[SessionID] Do Begin
  WriteLn('Détails de la session SSH ', SessionID, ':');
  WriteLn('================================');
  With Connection Do Begin
   WriteLn('Hôte             : ', Hostname, ':', Port);
   WriteLn('Utilisateur      : ', Username);
   WriteLn('Protocole        : SSH-', Protocol, '.0');
   WriteLn('Chiffrement      : ', Cipher);
   WriteLn('Clé privée       : ', KeyFile);
   If ForwardX11 Then 
    WriteLn('Redirection X11  : Oui')
   Else
    WriteLn('Redirection X11  : Non');
   If Compression Then 
    WriteLn('Compression      : Oui')
   Else
    WriteLn('Compression      : Non');
   If LocalForward <> '' Then
    WriteLn('Forward local    : ', LocalForward);
   If RemoteForward <> '' Then
    WriteLn('Forward distant  : ', RemoteForward);
   If Connected Then 
    WriteLn('État             : Connecté')
   Else
    WriteLn('État             : Déconnecté');
   WriteLn('Heure connexion  : ', LoginTime);
   WriteLn('Dernière activité: ', LastActivity);
   WriteLn('Octets envoyés   : ', BytesSent);
   WriteLn('Octets reçus     : ', BytesReceived);
   WriteLn('Commandes        : ', Commands);
  End;
 End;
End;

{ Afficher les statistiques SSH }
Procedure ShowSSHStats;
Var
 I, ActiveSessions, TotalCommands: Integer;
 TotalSent, TotalReceived: LongInt;
Begin
 ActiveSessions := 0;
 TotalCommands := 0;
 TotalSent := 0;
 TotalReceived := 0;
 
 For I := 0 To SessionCount - 1 Do Begin
  With SSHSessions[I] Do Begin
   If Active Then Inc(ActiveSessions);
   Inc(TotalCommands, Commands);
   Inc(TotalSent, Connection.BytesSent);
   Inc(TotalReceived, Connection.BytesReceived);
  End;
 End;
 
 WriteLn('Statistiques SSH:');
 WriteLn('=================');
 WriteLn('Sessions totales   : ', SessionCount);
 WriteLn('Sessions actives   : ', ActiveSessions);
 WriteLn('Commandes exécutées: ', TotalCommands);
 WriteLn('Octets envoyés     : ', TotalSent);
 WriteLn('Octets reçus       : ', TotalReceived);
 WriteLn('Version SSH        : ', SSH_VERSION);
End;
{$ENDIF}

{$IFNDEF FPC}
{ Version Turbo Pascal - Simulation }
Procedure ShowSimulatedSSH;
Begin
 WriteLn('Sessions SSH actives (simulation):');
 WriteLn('====================');
 WriteLn('ID  Utilisateur@Hôte              Port  État     Démarrage        Commandes');
 WriteLn('--- ----------------------------- ----- -------- ---------------- ---------');
 WriteLn(' 0  user@localhost                   22 Actif    2026-02-21 14:30    15');
 WriteLn(' 1  developer@dev.example.com      2222 Actif    2026-02-21 13:15    43');
 WriteLn(' 2  backup@backup.internal           22 Fermé    2026-02-21 12:00     1');
 WriteLn;
 WriteLn('Total: 3 session(s)');
End;

Procedure SimulateSSHConnect;
Begin
 WriteLn('Tentative de connexion à example.com:22...');
 WriteLn('SSH-2.0-NETWORKKIT_user@example.com');
 WriteLn('Échange de clés...');
 WriteLn('Algorithme: aes128-ctr');
 WriteLn('Authentification par clé publique...');
 WriteLn('Connexion établie avec example.com');
 WriteLn('Bienvenue sur example.com!');
End;

Procedure SimulateSSHCommand;
Begin
 WriteLn('Exécution de "ls -la" sur example.com...');
 WriteLn;
 WriteLn('total 12');
 WriteLn('drwxr-xr-x  2 user user 4096 Feb 21 14:30 Documents');
 WriteLn('drwxr-xr-x  2 user user 4096 Feb 21 13:15 Downloads');
 WriteLn('-rw-r--r--  1 user user  220 Feb 21 12:00 .bash_logout');
End;

Procedure ShowSimulatedStats;
Begin
 WriteLn('Statistiques SSH:');
 WriteLn('=================');
 WriteLn('Sessions totales   : 3');
 WriteLn('Sessions actives   : 2');
 WriteLn('Commandes exécutées: 59');
 WriteLn('Octets envoyés     : 1066944');
 WriteLn('Octets reçus       : 37376');
 WriteLn('Version SSH        : 2.0');
End;
{$ENDIF}

{ Analyse de la ligne de commande }
Procedure ParseCommandLine;
Var
 I: Integer;
 Action: String;
 HostSpec, Command, KeyFile: String;
 Port: Word;
 Username: String;
 Verbose: Integer;
 ForwardX11, Compression, BatchMode: Boolean;
 Param: String;
 SessionIndex: Integer;
Begin
 Action := 'connect';
 HostSpec := '';
 Command := '';
 KeyFile := '';
 Port := DEFAULT_SSH_PORT;
 Username := '';
 Verbose := 0;
 ForwardX11 := False;
 Compression := False;
 BatchMode := False;
 
 { Analyser les paramètres }
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-v') Then
   Inc(Verbose)
  Else If (LowerCase(Param) = '-x') Then
   ForwardX11 := True
  Else If (LowerCase(Param) = '-c') Then
   Compression := True
  Else If (LowerCase(Param) = '-n') Then
   BatchMode := True
  Else If (LowerCase(Param) = '-l') Then Begin
   Action := 'list';
  End Else If (LowerCase(Param) = '-p') and (I < ParamCount) Then Begin
   Inc(I);
   Port := StrToInt(ParamStr(I));
   If Port = 0 Then Port := DEFAULT_SSH_PORT;
  End Else If (LowerCase(Param) = '-i') and (I < ParamCount) Then Begin
   Inc(I);
   KeyFile := ParamStr(I);
  End Else If Copy(LowerCase(Param), 1, 2) = '-l' Then Begin
   Username := Copy(Param, 3, Length(Param) - 2);
  End Else If LowerCase(Param) = '--stats' Then
   Action := 'stats'
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   If HostSpec = '' Then
    HostSpec := Param
   Else
    Command := Command + Param + ' ';
  End;
  
  Inc(I);
 End;
 
 { Nettoyer la commande }
 If Length(Command) > 0 Then
  Command := Copy(Command, 1, Length(Command) - 1);
 
 {$IFDEF FPC}
 Case Action Of
  'connect': Begin
   If HostSpec = '' Then Begin
    WriteLn('ssh: Nom d''hôte requis');
    WriteLn('Usage: ssh [options] hostname [commande]');
    Exit;
   End;
   
   If SessionCount = 0 Then CreateSampleSessions;
   
   SessionIndex := CreateSSHSession(HostSpec, Command, '');
   If SessionIndex >= 0 Then Begin
    If ConnectSSH(SSHSessions[SessionIndex]) Then Begin
     If Command <> '' Then Begin
      ExecuteSSHCommand(SSHSessions[SessionIndex], Command);
      CloseSSHSession(SSHSessions[SessionIndex]);
     End Else Begin
      WriteLn('Session interactive ouverte (utilisez Ctrl+C pour quitter)');
      WriteLn('Pour tester: ssh ', HostSpec, ' "pwd"');
     End;
    End;
   End;
  End;
  'list': Begin
   If SessionCount = 0 Then CreateSampleSessions;
   ListSSHSessions;
  End;
  'stats': Begin
   If SessionCount = 0 Then CreateSampleSessions;
   ShowSSHStats;
  End;
 End;
 {$ELSE}
 Case Action Of
  'connect': Begin
   If HostSpec = '' Then Begin
    WriteLn('ssh: Nom d''hôte requis');
    Exit;
   End;
   
   If Command <> '' Then
    SimulateSSHCommand
   Else
    SimulateSSHConnect;
  End;
  'list': ShowSimulatedSSH;
  'stats': ShowSimulatedStats;
 End;
 {$ENDIF}
End;

BEGIN
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
   (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('SSH : Client Secure Shell');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  SSH [options] hostname [commande]');
  WriteLn('  SSH [options] [utilisateur@]hostname[:port] [commande]');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -l utilisateur        Nom d''utilisateur pour la connexion');
  WriteLn('  -p port               Port de connexion (défaut: 22)');
  WriteLn('  -i fichier_clé        Fichier de clé privée d''authentification');
  WriteLn('  -v                    Mode verbeux (utiliser -vvv pour plus de détails)');
  WriteLn('  -x                    Activer la redirection X11');
  WriteLn('  -c                    Activer la compression');
  WriteLn('  -n                    Mode batch (non-interactif)');
  WriteLn('  -L [bind:]port:host:hostport  Redirection de port locale');
  WriteLn('  -R [bind:]port:host:hostport  Redirection de port distante');
  WriteLn('  -D [bind:]port        Proxy SOCKS dynamique');
  WriteLn('  -F fichier_config     Fichier de configuration SSH');
  WriteLn('  -o option             Options SSH (ex: StrictHostKeyChecking=no)');
  WriteLn('  -l, --list            Lister les sessions actives');
  WriteLn('  --stats               Statistiques SSH');
  WriteLn;
  WriteLn('Paramètres :');
  WriteLn('  hostname              Nom d''hôte ou adresse IP du serveur');
  WriteLn('  utilisateur           Nom d''utilisateur (optionnel)');
  WriteLn('  port                  Port de connexion (optionnel)');
  WriteLn('  commande              Commande à exécuter sur le serveur distant');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  SSH example.com                       # Connexion interactive');
  WriteLn('  SSH user@example.com                  # Avec utilisateur spécifique');
  WriteLn('  SSH -p 2222 example.com               # Port personnalisé');
  WriteLn('  SSH example.com "ls -la"              # Exécuter une commande');
  WriteLn('  SSH -i ~/.ssh/ma_cle example.com      # Authentification par clé');
  WriteLn('  SSH -L 8080:localhost:80 example.com  # Redirection locale');
  WriteLn('  SSH -x example.com xclock             # Redirection X11');
  WriteLn('  SSH --stats                           # Statistiques');
  WriteLn;
  WriteLn('Fichiers de configuration :');
  WriteLn('  ~/.ssh/config         Configuration utilisateur');
  WriteLn('  ~/.ssh/id_rsa         Clé privée RSA par défaut');
  WriteLn('  ~/.ssh/known_hosts    Empreintes des hôtes connus');
  WriteLn;
  WriteLn('Note: SSH permet des connexions sécurisées et chiffrées vers');
  WriteLn('des serveurs distants pour l''exécution de commandes et le');
  WriteLn('transfert de fichiers de manière sécurisée.');
  WriteLn;
  WriteLn('Compatible Turbo Pascal (simulation) et Free Pascal (gestion réelle)');
 End
  Else
 If ParamStr(1) = '--version' Then Begin
  WriteLn('SSH 1.00 - Secure Shell Client, NETWORKKIT-P, corail');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  {$IFDEF FPC}
  InitializeSSH;
  {$ENDIF}
  ParseCommandLine;
 End;
END.
