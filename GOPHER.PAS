{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Client Gopher)
}

Program GOPHER;

{$IFDEF FPC}
 Uses
  Winsock,SysUtils;
{$ENDIF}

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
{$ENDIF}

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
 WriteLn('GOPHER : Client Gopher en ligne de commande');
 WriteLn;
 WriteLn('Syntaxe : GOPHER [gopher://serveur[:port][/sélecteur]]');
 WriteLn;
 WriteLn('Le protocole Gopher était populaire avant le Web (RFC 1436)');
 WriteLn('Port par défaut : 70');
 WriteLn;
 WriteLn('Types d''éléments Gopher :');
 WriteLn(' [TXT] - Fichier texte');
 WriteLn(' [DIR] - Répertoire/Menu');
 WriteLn(' [BIN] - Fichier binaire');
 WriteLn;
 WriteLn('Exemples :');
 WriteLn(' GOPHER gopher://gopher.floodgap.com');
 WriteLn(' GOPHER gopher://gopher.quux.org:70/');  
 End
  Else
 If ParamStr(1)='--version'Then Begin
  WriteLn('GOPHER 1.00 - Client Gopher Pascal, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
  Else
 Begin
  WriteLn('Client Gopher Pascal - NETWORKKIT-P');
  WriteLn;
  
  If ParamCount>=1 Then Begin
   WriteLn('Simulation : Navigation Gopher vers ',ParamStr(1));
   WriteLn;
   WriteLn('Contenu Gopher simulé :');
   WriteLn('[DIR] À propos de ce serveur');
   WriteLn('[TXT] Fichier README');
   WriteLn('[DIR] Archives publiques');
   WriteLn('      Bienvenue sur ce serveur Gopher !');
   WriteLn;
   WriteLn('Note: Version complète disponible avec Free Pascal');
  End Else Begin
   WriteLn('Serveurs Gopher populaires à essayer :');
   WriteLn('• gopher://gopher.floodgap.com - Serveur principal');
   WriteLn('• gopher://gopherhole.org - Archive Gopher');
   WriteLn('• gopher://gopher.quux.org - Serveur historique');
   WriteLn;
   WriteLn('Utilisation : GOPHER gopher://serveur[:port][/chemin]');
   WriteLn('Tapez GOPHER /? pour plus d''aide');
  End;
 End;
END.
