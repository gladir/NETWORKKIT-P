{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Client FTP)
}

Program FTP;

{$IFDEF FPC}
 Uses
  Winsock,SysUtils;

 Type
  TFTPConnection = Record
   ControlSocket:Integer;
   DataSocket:Integer;
   ServerAddress:String;
   Username:String;
   Password:String;
   Connected:Boolean;
   PassiveMode:Boolean;
  End;

 Var
  FTPConn:TFTPConnection;
  WSAData:TWSADATA;
  Buffer:Array[0..1023] of AnsiChar;
  Command:String;
  Response:String;
{$ELSE}
 { Impl√©mentation pour Turbo Pascal avec simulation }
 Type
  TFTPConnection = Record
   ServerAddress:String;
   Username:String;
   Password:String;
   Connected:Boolean;
   PassiveMode:Boolean;
  End;

 Var
  FTPConn:TFTPConnection;
  Command:String;
{$ENDIF}

{$IFNDEF FPC}
Function IntToStr(Value:LongInt):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Function StrToInt(S:String):LongInt;
Var
 Value:LongInt;
 Code:Integer;
Begin
 Val(S,Value,Code);
 If Code<>0 Then Value:=0;
 StrToInt:=Value;
End;

Function UpperCase(S:String):String;
Var
 I:Integer;
Begin
 For I:=1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I]:=Chr(Ord(S[I])-32);
 UpperCase:=S;
End;

Function Copy(S:String;Index,Count:Integer):String;
Var
 Result:String;
 I:Integer;
Begin
 Result:='';
 For I:=Index To Index+Count-1 Do
  If I<=Length(S) Then Result:=Result+S[I];
 Copy:=Result;
End;

Function Pos(SubStr,S:String):Integer;
Var
 I,J:Integer;
 Found:Boolean;
Begin
 Pos:=0;
 For I:=1 To Length(S)-Length(SubStr)+1 Do Begin
  Found:=True;
  For J:=1 To Length(SubStr) Do
   If S[I+J-1]<>SubStr[J] Then Begin
    Found:=False;
    Break;
   End;
  If Found Then Begin
   Pos:=I;
   Break;
  End;
 End;
End;
{$ENDIF}

{$IFDEF FPC}
{ Fonction pour envoyer une commande FTP }
Function SendFTPCommand(Socket:Integer;Cmd:String):Boolean;
Var
 CmdLine:String;
Begin
 CmdLine:=Cmd+#13#10;
 SendFTPCommand:=send(Socket,CmdLine[1],Length(CmdLine),0)>0;
End;

{ Fonction pour recevoir une r√©ponse FTP }
Function ReceiveFTPResponse(Socket:Integer):String;
Var
 BytesReceived:Integer;
 Response:String;
Begin
 FillChar(Buffer,SizeOf(Buffer),0);
 BytesReceived:=recv(Socket,Buffer,SizeOf(Buffer)-1,0);
 If BytesReceived>0 Then Begin
  Buffer[BytesReceived]:=#0;
  Response:=StrPas(Buffer);
  { Enlever les caract√®res de fin de ligne }
  While (Length(Response)>0) and (Response[Length(Response)] in [#10,#13]) Do
   Delete(Response,Length(Response),1);
  ReceiveFTPResponse:=Response;
 End Else
  ReceiveFTPResponse:='';
End;

{ Fonction pour se connecter au serveur FTP }
Function ConnectToFTP(Server:String;Port:Word):Boolean;
Var
 SockAddr:TSockAddrIn;
 HostEnt:PHostEnt;
 ServerPChar:Array[0..255] of AnsiChar;
Begin
 ConnectToFTP:=False;
  { CrÇer le socket de contr√¥le }
 FTPConn.ControlSocket:=socket(AF_INET,SOCK_STREAM,0);
 If FTPConn.ControlSocket=INVALID_SOCKET Then Exit;
  { RÇsoudre l'adresse du serveur }
 FillChar(SockAddr,SizeOf(SockAddr),0);
 SockAddr.sin_family:=AF_INET;
 SockAddr.sin_port:=htons(Port);
  { Convertir String en PChar }
 StrPCopy(ServerPChar,Server);
 SockAddr.sin_addr.s_addr:=inet_addr(ServerPChar);
 If SockAddr.sin_addr.s_addr=INADDR_NONE Then Begin
  HostEnt:=gethostbyname(ServerPChar);
  If HostEnt<>nil Then
   SockAddr.sin_addr.s_addr:=PInAddr(HostEnt^.h_addr_list^)^.s_addr
  Else Exit;
 End;
  { Se connecter au serveur }
 If connect(FTPConn.ControlSocket,SockAddr,SizeOf(SockAddr))=0 Then Begin
  FTPConn.ServerAddress:=Server;
  FTPConn.Connected:=True;
  ConnectToFTP:=True;
 End;
End;

 { Fonction pour se dÇconnecter du serveur FTP }
Procedure DisconnectFromFTP;Begin
 If FTPConn.Connected Then Begin
  SendFTPCommand(FTPConn.ControlSocket,'QUIT');
  closesocket(FTPConn.ControlSocket);
  FTPConn.Connected:=False;
 End;
End;

 { Fonction pour s'authentifier }
Function LoginToFTP(Username,Password:String):Boolean;
Var
 Response:String;
 Code:Integer;
Begin
 LoginToFTP:=False;
 If Not FTPConn.Connected Then Exit;
  { Envoyer le nom d'utilisateur }
 If SendFTPCommand(FTPConn.ControlSocket,'USER '+Username) Then Begin
  Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
  Code:=StrToInt(Copy(Response,1,3));
   { Si code 331, envoyer le mot de passe }
  If Code=331 Then Begin
   If SendFTPCommand(FTPConn.ControlSocket,'PASS '+Password) Then Begin
    Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
    Code:=StrToInt(Copy(Response,1,3));
    If Code=230 Then Begin
     FTPConn.Username:=Username;
     FTPConn.Password:=Password;
     LoginToFTP:=True;
    End;
   End;
  End Else If Code=230 Then
   LoginToFTP:=True; { Connexion sans mot de passe }
 End;
End;

{ Fonction pour lister les fichiers }
Procedure ListFiles;
Var
 Response:String;
Begin
 If Not FTPConn.Connected Then Begin
  WriteLn('Pas connectÇ au serveur FTP.');
  Exit;
 End;
 If SendFTPCommand(FTPConn.ControlSocket,'LIST') Then Begin
  Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
  WriteLn(Response);
 End;
End;

 { Fonction pour changer de rÇpertoire }
Procedure ChangeDirectory(Dir:String);
Var
 Response:String;
 Code:Integer;
Begin
 If Not FTPConn.Connected Then Begin
  WriteLn('Pas connectÇ au serveur FTP.');
  Exit;
 End;
 If SendFTPCommand(FTPConn.ControlSocket,'CWD '+Dir) Then Begin
  Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
  Code:=StrToInt(Copy(Response,1,3));
  If Code=250 Then
   WriteLn('RÇpertoire changÇ: '+Dir)
  Else
   WriteLn('Erreur changement rÇpertoire: '+Response);
 End;
End;

{ Fonction pour afficher le rÇpertoire courant }
Procedure PrintWorkingDirectory;
Var
 Response:String;
 Code:Integer;
 StartPos,EndPos:Integer;
Begin
 If Not FTPConn.Connected Then Begin
  WriteLn('Pas connectÇ au serveur FTP.');
  Exit;
 End;
 If SendFTPCommand(FTPConn.ControlSocket,'PWD') Then Begin
  Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
  Code:=StrToInt(Copy(Response,1,3));
  If Code=257 Then Begin
   StartPos:=Pos('"',Response);
   If StartPos>0 Then Begin
    EndPos:=Pos('"',Copy(Response,StartPos+1,Length(Response)))+StartPos;
    WriteLn('RÇpertoire courant: '+Copy(Response,StartPos+1,EndPos-StartPos-1));
   End Else
    WriteLn(Response);
  End Else
   WriteLn('Erreur: '+Response);
 End;
End;
{$ENDIF}

{ ProcÇdure pour analyser et exÇcuter une commande }
Procedure ProcessCommand(Cmd:String);
Var
 Parts:Array[0..3] of String;
 PartCount:Integer;
 I,Start:Integer;
 InWord:Boolean;
 {$IFDEF FPC}
  Port:Word;
 {$ENDIF}
Begin
 { Diviser la commande en parties }
 PartCount:=0;
 Start:=1;
 InWord:=False;
 For I:=1 To Length(Cmd)+1 Do Begin
  If (I>Length(Cmd)) or (Cmd[I]=' ') Then Begin
   If InWord and (PartCount<=3) Then Begin
    Parts[PartCount]:=Copy(Cmd,Start,I-Start);
    Inc(PartCount);
    InWord:=False;
   End;
  End Else Begin
   If Not InWord Then Begin
    Start:=I;
    InWord:=True;
   End;
  End;
 End;

 If PartCount=0 Then Exit;
  { Traiter les commandes }
 Parts[0]:=UpperCase(Parts[0]);
 {$IFDEF FPC}
  If Parts[0]='OPEN' Then Begin
   If PartCount>=2 Then Begin
    Port:=21; { Port par dÇfaut }
    If PartCount>=3 Then Port:=StrToInt(Parts[2]);
    If ConnectToFTP(Parts[1],Port) Then Begin
     WriteLn('ConnectÇ Ö '+Parts[1]+':'+IntToStr(Port));
     Response:=ReceiveFTPResponse(FTPConn.ControlSocket);
     WriteLn(Response);
    End
     Else
    WriteLn('Impossible de se connecter Ö '+Parts[1]);
   End
    Else
   WriteLn('Syntaxe : open serveur [port]');
  End
   Else
  If Parts[0]='USER' Then Begin
   If PartCount>=2 Then Begin
    If PartCount>=3 Then Begin
     If LoginToFTP(Parts[1],Parts[2]) Then WriteLn('Authentification rÇussie')
                                      Else WriteLn('êchec de l''authentification');
    End
     Else
    Begin
     Write('Mot de passe : ');
     ReadLn(Command);
     If LoginToFTP(Parts[1],Command)Then WriteLn('Authentification r√©ussie')
                                    Else WriteLn('êchec de l''authentification');
    End;
   End
    Else
   WriteLn('Syntaxe : user nom [motdepasse]');
  End
   Else
  If (Parts[0]='LS') or (Parts[0]='DIR') Then ListFiles
   Else
  If Parts[0]='CD' Then Begin
   If PartCount>=2 Then ChangeDirectory(Parts[1])
                   Else WriteLn('Syntaxe : cd rÇpertoire');
  End
   Else
  If Parts[0]='PWD' Then PrintWorkingDirectory
   Else
  If (Parts[0]='QUIT') or (Parts[0]='EXIT') Then Begin
   DisconnectFromFTP;
   WriteLn('Au revoir !');
   Halt(0);
  End
   Else
 {$ELSE}
  If Parts[0]='OPEN' Then Begin
   WriteLn('Simulation : Connexion Ö '+Parts[1]);
   FTPConn.ServerAddress:=Parts[1];
   FTPConn.Connected:=True;
  End
   Else
  If Parts[0]='USER' Then Begin
   WriteLn('Simulation : Authentification utilisateur '+Parts[1]);
   FTPConn.Username:=Parts[1];
  End
   Else
  If (Parts[0]='LS') or (Parts[0]='DIR') Then WriteLn('Simulation : Liste des fichiers du serveur') Else
  If Parts[0]='CD' Then WriteLn('Simulation : Changement vers rÇpertoire '+Parts[1]) Else
  If Parts[0]='PWD' Then WriteLn('Simulation : RÇpertoire courant /home/user') Else
  If (Parts[0]='QUIT') or (Parts[0]='EXIT') Then Begin
   WriteLn('Au revoir !');
   Halt(0);
  End
   Else
 {$ENDIF}
 If (Parts[0]='HELP') or (Parts[0]='?') Then Begin
  WriteLn(' open serveur [port]   - Se connecter Ö un serveur FTP');
  WriteLn(' user nom [motdepasse] - S''authentifier');
  WriteLn(' ls ou dir             - Lister les fichiers');
  WriteLn(' cd rÇpertoire         - Changer de rÇpertoire');
  WriteLn(' pwd                   - Afficher le rÇpertoire courant');
  WriteLn(' quit ou exit          - Quitter le client FTP');
  WriteLn(' help ou ?             - Afficher cette aide');
 End
  Else
 WriteLn('Commande inconnue : '+Parts[0]+' (tapez "help" pour l''aide)');
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('FTP : Client FTP en ligne de commande');
  WriteLn;
  WriteLn('Syntaxe : FTP [serveur] [port]');
  WriteLn;
  WriteLn('Commandes disponibles :');
  WriteLn(' open serveur [port]   - Se connecter Ö un serveur FTP');
  WriteLn(' user nom [motdepasse] - S''authentifier');
  WriteLn(' ls ou dir             - Lister les fichiers');
  WriteLn(' cd rÇpertoire         - Changer de rÇpertoire');
  WriteLn(' pwd                   - Afficher le rÇpertoire courant');
  WriteLn(' quit ou exit          - Quitter le client FTP');
  WriteLn(' help ou ?             - Afficher cette aide');
  WriteLn;
  WriteLn('Exemple : FTP ftp.example.com 21');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('FTP 1.00 - Client FTP Pascal, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('êcrit par Sylvain Maltais');
 End
  Else
 Begin
   {$IFDEF FPC}
    { Initialisation Winsock }
    If WSAStartup($0202,WSAData)<>0 Then Begin
     WriteLn('Erreur d''initialisation Winsock');
     Halt(1);
    End;
  {$ENDIF}
   { Initialisation de la connexion FTP }
  FillChar(FTPConn,SizeOf(FTPConn),0);
  FTPConn.PassiveMode:=True;
  WriteLn('Client FTP Pascal - NETWORKKIT-P, Corail');
  WriteLn('Tapez "help" pour l''aide, "quit" pour quitter');
  WriteLn;
   { Si serveur spÇcifiÇ en paramätre }
  If ParamCount>=1 Then Begin
   Command:='open '+ParamStr(1);
   If ParamCount>=2 Then Command:=Command+' '+ParamStr(2);
   ProcessCommand(Command);
  End;
   { Boucle principale de commandes }
  Repeat
   Write('ftp> ');
   ReadLn(Command);
   If Length(Command)>0 Then ProcessCommand(Command);
  Until False;
  {$IFDEF FPC}
   WSACleanup;
  {$ENDIF}
 End;
END.