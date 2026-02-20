{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal)
}

Program FINGER;

Uses DOS;

Type
 UserInfo=Record
  UserName:String[50];
  FullName:String[100];
  Terminal:String[20];
  LoginTime:String[50];
  IdleTime:String[20];
  Host:String[100];
 End;

Var
 TargetUser,TargetHost:String;
 UserList:Array[1..100]of UserInfo;
 UserCount:Integer;
 CurrentUser:String;

Function StrToLower(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['A'..'Z']Then S[I]:=Chr(Ord(S[I])+32);
 End;
 StrToLower:=S;
End;

Function IntToStr(I:Integer):String;
Var
 S:String;
Begin
 Str(I,S);
 IntToStr:=S;
End;

Function GetCurrentTime:String;
Begin
 { Simulation d'un horodatage pour les besoins de d‚monstration }
 GetCurrentTime:='20/02/2026 14:30';
End;

Function GetIdleTime(Terminal:String):String;Begin
 { Simulation d'un temps d'inactivitÃ© pour les besoins de dÃ©monstration }
 If Terminal='console'Then GetIdleTime:='0:05' Else
 If Terminal='tty1'Then GetIdleTime:='1:30'
                   Else GetIdleTime:='0:00';
End;

Function GetCurrentUser:String;Begin
 { Tente de r‚cup‚rer l'utilisateur actuel via les variables d'environnement }
 GetCurrentUser:=GetEnv('USERNAME');
End;

Procedure AddUser(UserName,FullName,Terminal,Host:String);Begin
 Inc(UserCount);
 UserList[UserCount].UserName:=UserName;
 UserList[UserCount].FullName:=FullName;
 UserList[UserCount].Terminal:=Terminal;
 UserList[UserCount].LoginTime:=GetCurrentTime;
 UserList[UserCount].IdleTime:=GetIdleTime(Terminal);
 UserList[UserCount].Host:=Host;
End;

Procedure InitializeUsers;Begin
 UserCount:=0;
 CurrentUser:=GetCurrentUser;
 { Simulation d'utilisateurs connect‚s pour les besoins de d‚monstration }
 AddUser(CurrentUser,'Utilisateur actuel','console','localhost');
 AddUser('admin','Administrateur systŠme','tty1','192.168.1.100');
 AddUser('guest','Invit‚','tty2','192.168.1.101');
 AddUser('root','Super utilisateur','tty3','localhost');
End;

Procedure DisplayAllUsers;
Var
 I:Integer;
Begin
 WriteLn('Utilisateurs connect‚s actuellement :');
 WriteLn;
 WriteLn('Utilisateur   Nom complet              Terminal  Temps connexion   Inactif  H“te');
 WriteLn('------------ ------------------------- --------- ----------------- -------- ----------------');
 For I:=1 to UserCount do Begin
  Write(UserList[I].UserName:12,' ');
  Write(UserList[I].FullName:25,' ');
  Write(UserList[I].Terminal:9,' ');
  Write(UserList[I].LoginTime:17,' ');
  Write(UserList[I].IdleTime:8,' ');
  WriteLn(UserList[I].Host);
 End;
End;

Procedure DisplayUserInfo(UserName:String);
Var
 I:Integer;
 Found:Boolean;
Begin
 Found:=False;
 UserName:=StrToLower(UserName);
 For I:=1 to UserCount do Begin
  If StrToLower(UserList[I].UserName)=UserName Then Begin
   Found:=True;
   WriteLn('Informations sur l''utilisateur : ',UserList[I].UserName);
   WriteLn;
   WriteLn('Nom d''utilisateur : ',UserList[I].UserName);
   WriteLn('Nom complet       : ',UserList[I].FullName);
   WriteLn('Terminal          : ',UserList[I].Terminal);
   WriteLn('Temps de connexion: ',UserList[I].LoginTime);
   WriteLn('Temps d''inactivit‚: ',UserList[I].IdleTime);
   WriteLn('H“te              : ',UserList[I].Host);
   WriteLn;
   Break;
  End;
 End;
 If Not Found Then Begin
  WriteLn('finger: utilisateur ''',UserName,''' non trouv‚');
  Halt(1);
 End;
End;

Procedure ParseUserHost(Param:String;Var User,Host:String);
Var
 AtPos:Integer;
Begin
 AtPos:=Pos('@',Param);
 If AtPos>0 Then Begin
  User:=Copy(Param,1,AtPos-1);
  Host:=Copy(Param,AtPos+1,Length(Param));
 End
  Else
 Begin
  User:=Param;
  Host:='localhost';
 End;
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('FINGER : Cette commande permet d''afficher des informations sur les ');
  WriteLn('         utilisateurs connect‚s au systŠme local ou … distance');
  WriteLn;
  WriteLn('Syntaxe : FINGER [utilisateur[@h“te]]');
  WriteLn;
  WriteLn(' utilisateur  Nom de l''utilisateur Ã  rechercher');
  WriteLn(' @h“te        H“te … distance … interroger (optionnel)');
  WriteLn;
  WriteLn('Exemples:');
  WriteLn(' FINGER              - Affiche tous les utilisateurs connect‚s');
  WriteLn(' FINGER admin        - Affiche les informations sur l''utilisateur admin');
  WriteLn(' FINGER user@host    - Interroge l''utilisateur user sur l''h“te host');
 End
  Else
 Begin
  InitializeUsers;
  If ParamCount=0 Then Begin
   { Affichage de tous les utilisateurs }
   DisplayAllUsers;
  End
   Else
  Begin
   { Affichage d'un utilisateur spÃ©cifique }
   ParseUserHost(ParamStr(1),TargetUser,TargetHost);
   If TargetHost<>'localhost'Then Begin
    WriteLn('finger: connexion … l''h“te distant ''',TargetHost,''' non impl‚ment‚e');
    WriteLn('Note: Cette version ne supporte que les requˆtes locales');
    Halt(1);
   End;
   DisplayUserInfo(TargetUser);
  End;
 End;
END.
