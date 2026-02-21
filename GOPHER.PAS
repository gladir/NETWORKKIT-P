{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Client Gopher)
}

Program GOPHER;

{$IFDEF FPC}
Uses SysUtils, Winsock;

Var
 Socket:Integer;
 WSAData:TWSADATA;
 Buffer:Array[0..4095] of AnsiChar;
{$ENDIF}

Var
 Server:String;
 Port:Word;
 Selector:String;

{$IFNDEF FPC}
Function IntToStr(Value:LongInt):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Function UpperCase(S:String):String;
Var
 I:Integer;
Begin
 For I:=1 To Length(S) Do
  If S[I] in ['a'..'z'] Then S[I]:=Chr(Ord(S[I])-32);
 UpperCase:=S;
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

{ Fonction pour analyser une URL Gopher }
Function ParseGopherURL(URL:String;Var ServerName:String;Var PortNum:Word;Var GopherSelector:String):Boolean;
Var
 RestURL:String;
 ColonPos,SlashPos:Integer;
 PortStr:String;
Begin
 ParseGopherURL:=False;
 ServerName:='';
 PortNum:=70;
 GopherSelector:='';

 { VÇrifier le prÇfixe gopher:// }
 If UpperCase(Copy(URL,1,9))<>'GOPHER://' Then Exit;
 RestURL:=Copy(URL,10,Length(URL));

 { Chercher le premier slash }
 SlashPos:=Pos('/',RestURL);
 If SlashPos>0 Then Begin
  GopherSelector:=Copy(RestURL,SlashPos+1,Length(RestURL));
  RestURL:=Copy(RestURL,1,SlashPos-1);
 End;

 { Chercher le deux-points pour le port }
 ColonPos:=Pos(':',RestURL);
 If ColonPos>0 Then Begin
  ServerName:=Copy(RestURL,1,ColonPos-1);
  PortStr:=Copy(RestURL,ColonPos+1,Length(RestURL));
  PortNum:=StrToInt(PortStr);
  If PortNum=0 Then PortNum:=70;
 End Else
  ServerName:=RestURL;

 ParseGopherURL:=Length(ServerName)>0;
End;

{$IFDEF FPC}
 { Fonction pour se connecter au serveur Gopher }
Function ConnectToGopher(ServerName:String;PortNum:Word):Boolean;
Var
 SockAddr:TSockAddrIn;
 HostEnt:PHostEnt;
 ServerCStr:Array[0..255] of AnsiChar;
Begin
 ConnectToGopher:=False;
  { CrÇer le socket }
 Socket:=Winsock.socket(AF_INET,SOCK_STREAM,0);
 If Socket=INVALID_SOCKET Then Begin
  WriteLn('Erreur crÇation socket: ',WSAGetLastError);
  Exit;
 End;

 { PrÇparer la chaåne C }
 Move(ServerName[1],ServerCStr[0],Length(ServerName));
 ServerCStr[Length(ServerName)]:=#0;

 { RÇsoudre l'adresse du serveur }
 FillChar(SockAddr,SizeOf(SockAddr),0);
 SockAddr.sin_family:=AF_INET;
 SockAddr.sin_port:=htons(PortNum);

 { Convertir le nom du serveur en adresse IP }
 SockAddr.sin_addr.s_addr:=inet_addr(ServerCStr);
 If SockAddr.sin_addr.s_addr=INADDR_NONE Then Begin
  WriteLn('RÇsolution DNS pour ',ServerName,'...');
  HostEnt:=gethostbyname(ServerCStr);
  If HostEnt<>nil Then Begin
   SockAddr.sin_addr.s_addr:=PInAddr(HostEnt^.h_addr_list^)^.s_addr;
   WriteLn('Adresse IP trouvÇe: ',inet_ntoa(SockAddr.sin_addr));
  End Else Begin
   WriteLn('Erreur rÇsolution DNS: ',WSAGetLastError);
   closesocket(Socket);
   Exit;
  End;
 End;

 { Se connecter au serveur }
 WriteLn('Tentative de connexion...');
 If connect(Socket,SockAddr,SizeOf(SockAddr))=0 Then Begin
  ConnectToGopher:=True;
  WriteLn('Connexion Çtablie !');
 End Else Begin
  WriteLn('Erreur connexion: ',WSAGetLastError);
  closesocket(Socket);
 End;
End;

{ Fonction pour envoyer une requ√™te Gopher }
Function SendGopherRequest(GopherSelector:String):Boolean;
Var
 Request:String;
Begin
 Request:=GopherSelector+#13#10;
 SendGopherRequest:=send(Socket,Request[1],Length(Request),0)>0;
End;

{ Fonction pour recevoir la rÇponse Gopher }
Function ReceiveGopherResponse:String;
Var
 BytesReceived:Integer;
 TotalResponse:String;
Begin
 TotalResponse:='';
 Repeat
  FillChar(Buffer,SizeOf(Buffer),0);
  BytesReceived:=recv(Socket,Buffer,SizeOf(Buffer)-1,0);
  If BytesReceived>0 Then Begin
   Buffer[BytesReceived]:=#0;
   TotalResponse:=TotalResponse+StrPas(Buffer);
  End;
 Until BytesReceived<=0;
 ReceiveGopherResponse:=TotalResponse;
End;

{ ProcÇdure pour afficher le contenu Gopher }
Procedure DisplayGopherContent(Content:String;IsMenu:Boolean);
Var
 I:Integer;
 LineStart,LineEnd:Integer;
 MenuLine:String;
 ItemType:Char;
 TabPos:Integer;
 DisplayText:String;
Begin
 If Not IsMenu Then Begin
  { Afficher comme texte brut }
  For I:=1 To Length(Content) Do Begin
   If Content[I]=#13 Then { Ignorer CR }
   Else If Content[I]=#10 Then WriteLn
   Else Write(Content[I]);
  End;
  WriteLn;
  Exit;
 End;

 { Analyser et afficher comme menu Gopher }
 LineStart:=1;
 For I:=1 To Length(Content) Do Begin
  If Content[I]=#10 Then Begin
   LineEnd:=I-1;
   If (LineEnd>=LineStart) and (LineEnd<Length(Content)) and (Content[LineEnd]=#13) Then Dec(LineEnd);
   If LineEnd>=LineStart Then Begin
    MenuLine:=Copy(Content,LineStart,LineEnd-LineStart+1);
    If Length(MenuLine)>0 Then Begin
     ItemType:=MenuLine[1];
     If ItemType<>'.' Then Begin
      { Extraire le texte d'affichage (jusqu'au premier TAB) }
      TabPos:=Pos(#9,MenuLine);
      If TabPos>0 Then DisplayText:=Copy(MenuLine,2,TabPos-2)
                  Else DisplayText:=Copy(MenuLine,2,Length(MenuLine));
      { Afficher avec le symbole appropriÇ }
      Case ItemType Of
       '0':Write('[TXT] ');
       '1':Write('[DIR] ');
       '7':Write('[?]   ');
       '8':Write('[TEL] ');
       '9':Write('[BIN] ');
       'g':Write('[GIF] ');
       'h':Write('[HTM] ');
       'I':Write('[IMG] ');
       's':Write('[SND] ');
       'd':Write('[DOC] ');
       'i':Write('      ');
      Else
       Write('[???] ');
      End;
      WriteLn(DisplayText);
     End;
    End;
   End;
   LineStart:=I+1;
  End;
 End;
End;
{$ENDIF}

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('GOPHER : Client Gopher en ligne de commande');
  WriteLn;
  WriteLn('Syntaxe : GOPHER [gopher://serveur[:port][/sÇlecteur]]');
  WriteLn;
  WriteLn('Le protocole Gopher Çtait populaire avant le Web (RFC 1436)');
  WriteLn('Port par dÇfaut : 70');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn(' GOPHER gopher://gopher.floodgap.com');
  WriteLn(' GOPHER gopher://gopher.quux.org:70/0/readme.txt');
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('GOPHER 1.00 - Client Gopher Pascal, NETWORKKIT-P, corail');
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
  WriteLn('Client Gopher Pascal - NETWORKKIT-P');
  WriteLn;
  If ParamCount>=1 Then Begin
   If ParseGopherURL(ParamStr(1),Server,Port,Selector) Then Begin
    WriteLn('Connexion Ö ',Server,':',IntToStr(Port),'...');
    {$IFDEF FPC}
     If ConnectToGopher(Server,Port) Then Begin
      WriteLn('ConnectÇ ! SÇlecteur: "',Selector,'"');
      WriteLn('Envoi de la requàte...');
      If SendGopherRequest(Selector) Then Begin
       WriteLn('RÇception des donnÇes...');
       WriteLn;
       WriteLn('--- Contenu du serveur Gopher ---');
       { DÇterminer si c'est un menu (sÇlecteur vide ou commenáant par 1) }
       If (Length(Selector)=0) or ((Length(Selector)>0) and (Selector[1]='1')) Then
        DisplayGopherContent(ReceiveGopherResponse,True)
       Else
        DisplayGopherContent(ReceiveGopherResponse,False);
       WriteLn('--- Fin du contenu ---');
      End
       Else
      WriteLn('Erreur lors de l''envoi de la requàte');
      closesocket(Socket);
     End
      Else
     WriteLn('Impossible de se connecter Ö ',Server,':',IntToStr(Port));
   {$ELSE}
    WriteLn('Simulation Turbo Pascal :');
    WriteLn('[DIR] A propos de ',Server);
    WriteLn('[TXT] Fichier README');
    WriteLn('[DIR] Archives publiques');
    WriteLn('      Bienvenue sur ce serveur Gopher !');
    WriteLn;
    WriteLn('Note: Version complàte disponible avec Free Pascal');
   {$ENDIF}
   End
    Else
   Begin
    WriteLn('URL Gopher invalide !');
    WriteLn;
    WriteLn('Format : gopher://serveur[:port][/s√©lecteur]');
    WriteLn;
    WriteLn('Exemples :');
    WriteLn('  gopher://gopher.floodgap.com');
    WriteLn('  gopher://gopher.quux.org:70/');
    WriteLn('  gopher://gopherhole.org:70/0/readme.txt');
   End;
  End
   Else
  Begin
   WriteLn('Serveurs Gopher populaires :');
   WriteLn('˛ gopher://gopher.floodgap.com');
   WriteLn('˛ gopher://gopherhole.org');
   WriteLn('˛ gopher://gopher.quux.org');
   WriteLn;
   WriteLn('Usage : GOPHER gopher://serveur[:port][/chemin]');
  End;
  {$IFDEF FPC}
   WSACleanup;
  {$ENDIF}
 End;
END.