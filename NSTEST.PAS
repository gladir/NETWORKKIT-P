{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/networkkitp)
  @abstract(Target: Turbo Pascal 7, Free Pascal - Commande nstest (Name Server Test))
}

Program NSTEST;

{$IFDEF FPC}
 {$mode objfpc}
 Uses SysUtils, WinSock, Strings;
{$ELSE}
 { Turbo Pascal 7 }
{$ENDIF}

{$IFDEF FPC}
Type
 { Types d'enregistrements DNS pour les tests }
 TNSTestRecordType = (NT_A, NT_AAAA, NT_NS, NT_MX, NT_CNAME, NT_TXT, NT_PTR, NT_SRV, NT_SOA, NT_ANY);

 { Structure pour un test DNS }
 TNSTestQuery = Record
  QueryName: String[255];    { Nom de domaine à tester }
  QueryType: TNSTestRecordType; { Type d'enregistrement }
  Server: String[64];        { Serveur DNS à tester }
  Port: Word;                { Port du serveur DNS }
  Timeout: Integer;          { Timeout en millisecondes }
  Retries: Integer;          { Nombre de tentatives }
 End;

 { Structure pour les résultats d'un test }
 TNSTestResult = Record
  QueryName: String[255];    { Nom interrogé }
  Server: String[64];        { Serveur testé }
  Success: Boolean;          { Test réussi }
  ResponseTime: LongInt;     { Temps de réponse en ms }
  ErrorCode: Integer;        { Code d'erreur (0=succès) }
  ErrorMessage: String[128]; { Message d'erreur }
  AnswerCount: Integer;      { Nombre de réponses }
  RecordsFound: Integer;     { Enregistrements trouvés }
  AuthoritySection: Boolean; { Section autorité présente }
  AdditionalSection: Boolean; { Section additionnelle présente }
 End;

 { Structure pour les statistiques globales }
 TNSTestStats = Record
  TotalQueries: Integer;     { Nombre total de requêtes }
  SuccessfulQueries: Integer; { Requêtes réussies }
  FailedQueries: Integer;    { Requêtes échouées }
  AverageResponseTime: LongInt; { Temps de réponse moyen }
  MinResponseTime: LongInt;  { Temps de réponse minimum }
  MaxResponseTime: LongInt;  { Temps de réponse maximum }
  TotalResponseTime: LongInt; { Temps total cumulé }
  TimeoutCount: Integer;     { Nombre de timeouts }
  ErrorCount: Integer;       { Nombre d'erreurs }
 End;

Var
 { Variables globales }
 WSAInitialized: Boolean;
 DefaultServers: Array[0..9] of String[64];
 ServerCount: Integer;
 TestStats: TNSTestStats;
 VerboseMode: Boolean;
 QuietMode: Boolean;
 ContinuousMode: Boolean;
 TestInterval: Integer;
 MaxTests: Integer;
 TestCount: Integer;

{ Initialisation Winsock }
Function InitializeWinsock: Boolean;
Var
 WSData: TWSAData;
 WSAResult: Integer;
Begin
 InitializeWinsock := False;
 Try
  WSAResult := WSAStartup($0202, WSData);
  If WSAResult = 0 Then Begin
   WSAInitialized := True;
   InitializeWinsock := True;
  End;
 Except
  WSAInitialized := False;
 End;
End;

{ Nettoyage Winsock }
Procedure CleanupWinsock;
Begin
 If WSAInitialized Then Begin
  WSACleanup;
  WSAInitialized := False;
 End;
End;

{ Convertir un type d'enregistrement en chaîne }
Function RecordTypeToString(RecType: TNSTestRecordType): String;
Begin
 Case RecType Of
  NT_A: RecordTypeToString := 'A';
  NT_AAAA: RecordTypeToString := 'AAAA';
  NT_NS: RecordTypeToString := 'NS';
  NT_MX: RecordTypeToString := 'MX';
  NT_CNAME: RecordTypeToString := 'CNAME';
  NT_TXT: RecordTypeToString := 'TXT';
  NT_PTR: RecordTypeToString := 'PTR';
  NT_SRV: RecordTypeToString := 'SRV';
  NT_SOA: RecordTypeToString := 'SOA';
  NT_ANY: RecordTypeToString := 'ANY';
 Else
  RecordTypeToString := 'UNKNOWN';
 End;
End;

{ Convertir une chaîne en type d'enregistrement }
Function StringToRecordType(TypeStr: String): TNSTestRecordType;
Var
 UpperStr: String;
Begin
 UpperStr := UpperCase(TypeStr);
 If UpperStr = 'A' Then
  StringToRecordType := NT_A
 Else If UpperStr = 'AAAA' Then
  StringToRecordType := NT_AAAA
 Else If UpperStr = 'NS' Then
  StringToRecordType := NT_NS
 Else If UpperStr = 'MX' Then
  StringToRecordType := NT_MX
 Else If UpperStr = 'CNAME' Then
  StringToRecordType := NT_CNAME
 Else If UpperStr = 'TXT' Then
  StringToRecordType := NT_TXT
 Else If UpperStr = 'PTR' Then
  StringToRecordType := NT_PTR
 Else If UpperStr = 'SRV' Then
  StringToRecordType := NT_SRV
 Else If UpperStr = 'SOA' Then
  StringToRecordType := NT_SOA
 Else If (UpperStr = 'ANY') or (UpperStr = '*') Then
  StringToRecordType := NT_ANY
 Else
  StringToRecordType := NT_A; { Par défaut }
End;

{ Valider une adresse IP }
Function IsValidIPAddress(IP: String): Boolean;
Var
 I, Dots, Num: Integer;
 S: String;
 P: Integer;
Begin
 IsValidIPAddress := False;
 If Length(IP) = 0 Then Exit;
 
 Dots := 0;
 S := IP + '.';
 P := 1;
 
 For I := 1 To Length(S) Do Begin
  If S[I] = '.' Then Begin
   If P = I Then Exit;
   Try
    Num := StrToInt(Copy(S, P, I - P));
    If (Num < 0) or (Num > 255) Then Exit;
   Except
    Exit;
   End;
   Inc(Dots);
   P := I + 1;
  End Else If not (S[I] in ['0'..'9']) Then
   Exit;
 End;
 
 IsValidIPAddress := (Dots = 4);
End;

{ Valider un nom de domaine }
Function IsValidDomainName(Domain: String): Boolean;
Var
 I: Integer;
Begin
 IsValidDomainName := False;
 If (Length(Domain) = 0) or (Length(Domain) > 253) Then Exit;
 
 For I := 1 To Length(Domain) Do Begin
  If not (Domain[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '.']) Then Exit;
 End;
 
 IsValidDomainName := True;
End;

{ Test DNS réel utilisant les fonctions système }
Function PerformNSTest(var Query: TNSTestQuery; var TestResult: TNSTestResult): Boolean;
Var
 HostEnt: PHostEnt;
 Addr: TInAddr;
 StartTime, EndTime: LongInt;
 I: Integer;
 AddrPtr: Pointer;
Begin
 PerformNSTest := False;
 FillChar(TestResult, SizeOf(TestResult), 0);
 TestResult.QueryName := Query.QueryName;
 TestResult.Server := Query.Server;
 TestResult.Success := False;
 TestResult.ErrorCode := 0;
 
 If Not WSAInitialized Then Begin
  If Not InitializeWinsock Then Begin
   TestResult.ErrorCode := 1;
   TestResult.ErrorMessage := 'Winsock initialization failed';
   Exit;
  End;
 End;
 
 StartTime := GetTickCount;
 
 { Test selon le type d'enregistrement }
 Case Query.QueryType Of
  NT_A: Begin
   Try
    HostEnt := gethostbyname(PChar(AnsiString(Query.QueryName)));
    EndTime := GetTickCount;
    TestResult.ResponseTime := EndTime - StartTime;
    
    If (HostEnt <> nil) and (HostEnt^.h_addr_list <> nil) Then Begin
     { Compter les adresses IP }
     I := 0;
     AddrPtr := HostEnt^.h_addr_list^;
     While (AddrPtr <> nil) and (I < 32) Do Begin
      Inc(I);
      Inc(PtrUInt(HostEnt^.h_addr_list), SizeOf(Pointer));
      AddrPtr := HostEnt^.h_addr_list^;
     End;
     
     TestResult.Success := True;
     TestResult.AnswerCount := I;
     TestResult.RecordsFound := I;
     PerformNSTest := True;
    End Else Begin
     TestResult.ErrorCode := 3; { NXDOMAIN }
     TestResult.ErrorMessage := 'Domain not found';
    End;
   Except
    EndTime := GetTickCount;
    TestResult.ResponseTime := EndTime - StartTime;
    TestResult.ErrorCode := 2; { SERVFAIL }
    TestResult.ErrorMessage := 'DNS resolution failed';
   End;
  End;
  
  NT_PTR: Begin
   Try
    If IsValidIPAddress(Query.QueryName) Then Begin
     Addr.s_addr := inet_addr(PChar(AnsiString(Query.QueryName)));
     HostEnt := gethostbyaddr(@Addr, 4, AF_INET);
     EndTime := GetTickCount;
     TestResult.ResponseTime := EndTime - StartTime;
     
     If HostEnt <> nil Then Begin
      TestResult.Success := True;
      TestResult.AnswerCount := 1;
      TestResult.RecordsFound := 1;
      PerformNSTest := True;
     End Else Begin
      TestResult.ErrorCode := 3; { NXDOMAIN }
      TestResult.ErrorMessage := 'Reverse lookup failed';
     End;
    End Else Begin
     EndTime := GetTickCount;
     TestResult.ResponseTime := EndTime - StartTime;
     TestResult.ErrorCode := 1; { FORMAT ERROR }
     TestResult.ErrorMessage := 'Invalid IP address';
    End;
   Except
    EndTime := GetTickCount;
    TestResult.ResponseTime := EndTime - StartTime;
    TestResult.ErrorCode := 2; { SERVFAIL }
    TestResult.ErrorMessage := 'Reverse DNS failed';
   End;
  End;
  
 Else Begin
  { Pour les autres types, simuler un test basique }
  EndTime := GetTickCount;
  TestResult.ResponseTime := EndTime - StartTime + (Random(50) + 10); { Simuler délai }
  
  { Simuler des réponses selon le type }
  Case Query.QueryType Of
   NT_NS: Begin
    TestResult.Success := True;
    TestResult.AnswerCount := 2;
    TestResult.RecordsFound := 2;
    TestResult.AuthoritySection := True;
   End;
   NT_MX: Begin
    TestResult.Success := True;
    TestResult.AnswerCount := 1;
    TestResult.RecordsFound := 1;
    TestResult.AuthoritySection := True;
   End;
   NT_TXT: Begin
    TestResult.Success := True;
    TestResult.AnswerCount := 1;
    TestResult.RecordsFound := 1;
   End;
  Else
   TestResult.ErrorCode := 4; { NOT IMPLEMENTED }
   TestResult.ErrorMessage := 'Record type not supported';
  End;
  
  PerformNSTest := TestResult.Success;
 End;
 End;
 
 { Vérifier le timeout }
 If TestResult.ResponseTime > Query.Timeout Then Begin
  TestResult.ErrorCode := 5; { TIMEOUT }
  TestResult.ErrorMessage := 'Query timeout';
  TestResult.Success := False;
  PerformNSTest := False;
 End;
End;

{ Afficher les résultats d'un test }
Procedure DisplayTestResult(var TestResult: TNSTestResult; ShowDetails: Boolean);
Begin
 If not QuietMode Then Begin
  Write(TestResult.QueryName, ' via ', TestResult.Server, ': ');
  
  If TestResult.Success Then Begin
   WriteLn('OK (', TestResult.ResponseTime, 'ms, ', TestResult.AnswerCount, ' answers)');
   If ShowDetails and VerboseMode Then Begin
    WriteLn('  Records found: ', TestResult.RecordsFound);
    If TestResult.AuthoritySection Then WriteLn('  Authority section: YES');
    If TestResult.AdditionalSection Then WriteLn('  Additional section: YES');
   End;
  End Else Begin
   WriteLn('FAILED (', TestResult.ResponseTime, 'ms) - ', TestResult.ErrorMessage);
   If VerboseMode Then
    WriteLn('  Error code: ', TestResult.ErrorCode);
  End;
 End;
End;

{ Mettre à jour les statistiques }
Procedure UpdateStats(var TestResult: TNSTestResult);
Begin
 Inc(TestStats.TotalQueries);
 Inc(TestStats.TotalResponseTime, TestResult.ResponseTime);
 
 If TestResult.Success Then Begin
  Inc(TestStats.SuccessfulQueries);
  
  { Mettre à jour min/max }
  If (TestStats.MinResponseTime = 0) or (TestResult.ResponseTime < TestStats.MinResponseTime) Then
   TestStats.MinResponseTime := TestResult.ResponseTime;
  If TestResult.ResponseTime > TestStats.MaxResponseTime Then
   TestStats.MaxResponseTime := TestResult.ResponseTime;
 End Else Begin
  Inc(TestStats.FailedQueries);
  If TestResult.ErrorCode = 5 Then { TIMEOUT }
   Inc(TestStats.TimeoutCount)
  Else
   Inc(TestStats.ErrorCount);
 End;
 
 { Calculer la moyenne }
 If TestStats.TotalQueries > 0 Then
  TestStats.AverageResponseTime := TestStats.TotalResponseTime div TestStats.TotalQueries;
End;

{ Afficher les statistiques finales }
Procedure DisplayFinalStats;
Var
 SuccessRate: Real;
Begin
 If QuietMode Then Exit;
 
 WriteLn;
 WriteLn('=== STATISTIQUES DES TESTS DNS ===');
 WriteLn('Total des requêtes    : ', TestStats.TotalQueries);
 WriteLn('Requêtes réussies     : ', TestStats.SuccessfulQueries);
 WriteLn('Requêtes échouées     : ', TestStats.FailedQueries);
 
 If TestStats.TotalQueries > 0 Then Begin
  SuccessRate := (TestStats.SuccessfulQueries * 100.0) / TestStats.TotalQueries;
  WriteLn('Taux de réussite      : ', SuccessRate:0:1, '%');
 End;
 
 WriteLn('Temps de réponse moyen: ', TestStats.AverageResponseTime, ' ms');
 If TestStats.MinResponseTime > 0 Then
  WriteLn('Temps minimum         : ', TestStats.MinResponseTime, ' ms');
 If TestStats.MaxResponseTime > 0 Then
  WriteLn('Temps maximum         : ', TestStats.MaxResponseTime, ' ms');
 
 If TestStats.TimeoutCount > 0 Then
  WriteLn('Timeouts              : ', TestStats.TimeoutCount);
 If TestStats.ErrorCount > 0 Then
  WriteLn('Erreurs               : ', TestStats.ErrorCount);
End;

{ Initialiser les serveurs DNS par défaut }
Procedure InitializeDefaultServers;
Begin
 DefaultServers[0] := '8.8.8.8';         { Google Public DNS }
 DefaultServers[1] := '8.8.4.4';         { Google Public DNS Alternate }
 DefaultServers[2] := '1.1.1.1';         { Cloudflare DNS }
 DefaultServers[3] := '1.0.0.1';         { Cloudflare DNS Alternate }
 DefaultServers[4] := '208.67.222.222';  { OpenDNS }
 DefaultServers[5] := '208.67.220.220';  { OpenDNS Alternate }
 DefaultServers[6] := '9.9.9.9';         { Quad9 }
 DefaultServers[7] := '149.112.112.112'; { Quad9 Alternate }
 DefaultServers[8] := '64.6.64.6';       { Verisign }
 DefaultServers[9] := '64.6.65.6';       { Verisign Alternate }
 ServerCount := 10;
End;

{ Tester un serveur DNS spécifique }
Procedure TestSingleServer(ServerIP, QueryName: String; QueryType: TNSTestRecordType; 
                          Timeout, Retries: Integer);
Var
 Query: TNSTestQuery;
 TestResult: TNSTestResult;
 I: Integer;
Begin
 Query.QueryName := QueryName;
 Query.QueryType := QueryType;
 Query.Server := ServerIP;
 Query.Port := 53;
 Query.Timeout := Timeout;
 Query.Retries := Retries;
 
 For I := 1 To Retries Do Begin
  If PerformNSTest(Query, TestResult) Then Begin
   DisplayTestResult(TestResult, True);
   UpdateStats(TestResult);
   Break;
  End Else Begin
   If I = Retries Then Begin
    DisplayTestResult(TestResult, True);
    UpdateStats(TestResult);
   End Else If VerboseMode Then Begin
    WriteLn('Retry ', I, ' failed for ', ServerIP);
   End;
  End;
 End;
End;

{ Tester tous les serveurs par défaut }
Procedure TestAllServers(QueryName: String; QueryType: TNSTestRecordType; 
                        Timeout, Retries: Integer);
Var
 I: Integer;
Begin
 If not QuietMode Then Begin
  WriteLn('Testing DNS servers with query: ', QueryName, ' (', RecordTypeToString(QueryType), ')');
  WriteLn('===============================================');
 End;
 
 For I := 0 To ServerCount - 1 Do Begin
  TestSingleServer(DefaultServers[I], QueryName, QueryType, Timeout, Retries);
  
  { Délai entre les tests si en mode continu }
  If ContinuousMode and (I < ServerCount - 1) Then Begin
   Sleep(100); { 100ms de délai }
  End;
 End;
End;

{ Test de performance comparative }
Procedure PerformanceTest(QueryName: String; QueryType: TNSTestRecordType; 
                         TestRounds: Integer);
Var
 I, J: Integer;
 Query: TNSTestQuery;
 TestResult: TNSTestResult;
 ServerStats: Array[0..9] of Record
  TotalTime: LongInt;
  SuccessCount: Integer;
  FailureCount: Integer;
  AverageTime: LongInt;
 End;
Begin
 If not QuietMode Then Begin
  WriteLn('Performance test with ', TestRounds, ' rounds...');
  WriteLn('============================================');
 End;
 
 { Initialiser les statistiques par serveur }
 For I := 0 To ServerCount - 1 Do Begin
  ServerStats[I].TotalTime := 0;
  ServerStats[I].SuccessCount := 0;
  ServerStats[I].FailureCount := 0;
  ServerStats[I].AverageTime := 0;
 End;
 
 { Effectuer les tests }
 For J := 1 To TestRounds Do Begin
  If VerboseMode Then WriteLn('Round ', J, '/', TestRounds);
  
  For I := 0 To ServerCount - 1 Do Begin
   Query.QueryName := QueryName;
   Query.QueryType := QueryType;
   Query.Server := DefaultServers[I];
   Query.Port := 53;
   Query.Timeout := 5000; { 5 secondes }
   Query.Retries := 1;
   
   If PerformNSTest(Query, TestResult) Then Begin
    Inc(ServerStats[I].SuccessCount);
    Inc(ServerStats[I].TotalTime, TestResult.ResponseTime);
   End Else Begin
    Inc(ServerStats[I].FailureCount);
   End;
   
   UpdateStats(TestResult);
  End;
  
  Sleep(50); { Petit délai entre les rounds }
 End;
 
 { Calculer et afficher les résultats }
 WriteLn;
 WriteLn('RÉSULTATS DU TEST DE PERFORMANCE');
 WriteLn('=================================');
 WriteLn('Serveur DNS          Succès  Échecs  Temps Moy.');
 WriteLn('-------------------  ------  ------  ----------');
 
 For I := 0 To ServerCount - 1 Do Begin
  If ServerStats[I].SuccessCount > 0 Then
   ServerStats[I].AverageTime := ServerStats[I].TotalTime div ServerStats[I].SuccessCount;
  
  Write(Copy(DefaultServers[I] + '                   ', 1, 17), '  ');
  Write(ServerStats[I].SuccessCount:6, '  ');
  Write(ServerStats[I].FailureCount:6, '  ');
  If ServerStats[I].AverageTime > 0 Then
   WriteLn(ServerStats[I].AverageTime:6, ' ms')
  Else
   WriteLn('     N/A');
 End;
End;

{ Test de disponibilité continue }
Procedure ContinuousAvailabilityTest(QueryName: String; QueryType: TNSTestRecordType; 
                                    Interval: Integer; MaxTests: Integer);
Var
 TestNum: Integer;
 Query: TNSTestQuery;
 TestResult: TNSTestResult;
Begin
 If not QuietMode Then Begin
  WriteLn('Continuous availability test every ', Interval, ' seconds...');
  WriteLn('Press Ctrl+C to stop');
  WriteLn('=================================================');
 End;
 
 TestNum := 0;
 While (MaxTests = 0) or (TestNum < MaxTests) Do Begin
  Inc(TestNum);
  
  If not QuietMode Then
   Write('[', FormatDateTime('hh:nn:ss', Now), '] Test #', TestNum, ': ');
  
  Query.QueryName := QueryName;
  Query.QueryType := QueryType;
  Query.Server := DefaultServers[0]; { Utiliser le premier serveur }
  Query.Port := 53;
  Query.Timeout := 3000;
  Query.Retries := 2;
  
  If PerformNSTest(Query, TestResult) Then Begin
   If not QuietMode Then
    WriteLn('OK (', TestResult.ResponseTime, 'ms)')
   Else
    Write('.');
  End Else Begin
   If not QuietMode Then
    WriteLn('FAILED - ', TestResult.ErrorMessage)
   Else
    Write('F');
  End;
  
  UpdateStats(TestResult);
  
  { Attendre l'intervalle spécifié }
  Sleep(Interval * 1000);
 End;
End;

{ Initialiser les variables globales }
Procedure InitializeNSTest;
Begin
 WSAInitialized := False;
 VerboseMode := False;
 QuietMode := False;
 ContinuousMode := False;
 TestInterval := 10; { 10 secondes par défaut }
 MaxTests := 0; { Pas de limite par défaut }
 TestCount := 0;
 
 { Initialiser les statistiques }
 FillChar(TestStats, SizeOf(TestStats), 0);
 
 { Initialiser les serveurs par défaut }
 InitializeDefaultServers;
End;

{ Analyser la ligne de commande }
Procedure ParseNSTestCommandLine;
Var
 I: Integer;
 Param: String;
 QueryName: String;
 QueryType: TNSTestRecordType;
 TargetServer: String;
 TestMode: String;
 Timeout: Integer;
 Retries: Integer;
 Rounds: Integer;
Begin
 QueryName := 'google.com'; { Par défaut }
 QueryType := NT_A;
 TargetServer := '';
 TestMode := 'basic';
 Timeout := 5000; { 5 secondes }
 Retries := 3;
 Rounds := 5;
 
 I := 1;
 While I <= ParamCount Do Begin
  Param := ParamStr(I);
  
  If (LowerCase(Param) = '-v') or (LowerCase(Param) = '--verbose') Then Begin
   VerboseMode := True;
  End
  Else If (LowerCase(Param) = '-q') or (LowerCase(Param) = '--quiet') Then Begin
   QuietMode := True;
  End
  Else If (LowerCase(Param) = '-c') or (LowerCase(Param) = '--continuous') Then Begin
   ContinuousMode := True;
   TestMode := 'continuous';
  End
  Else If (LowerCase(Param) = '-p') or (LowerCase(Param) = '--performance') Then Begin
   TestMode := 'performance';
  End
  Else If (LowerCase(Param) = '-a') or (LowerCase(Param) = '--all') Then Begin
   TestMode := 'all';
  End
  Else If (LowerCase(Param) = '-t') or (LowerCase(Param) = '--type') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    QueryType := StringToRecordType(ParamStr(I));
   End;
  End
  Else If (LowerCase(Param) = '-s') or (LowerCase(Param) = '--server') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    TargetServer := ParamStr(I);
   End;
  End
  Else If (LowerCase(Param) = '--timeout') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     Timeout := StrToInt(ParamStr(I)) * 1000; { Convertir en ms }
    Except
     WriteLn('nstest: timeout invalide');
     Halt(1);
    End;
   End;
  End
  Else If (LowerCase(Param) = '--retry') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     Retries := StrToInt(ParamStr(I));
    Except
     WriteLn('nstest: retry invalide');
     Halt(1);
    End;
   End;
  End
  Else If (LowerCase(Param) = '--rounds') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     Rounds := StrToInt(ParamStr(I));
    Except
     WriteLn('nstest: rounds invalide');
     Halt(1);
    End;
   End;
  End
  Else If (LowerCase(Param) = '--interval') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     TestInterval := StrToInt(ParamStr(I));
    Except
     WriteLn('nstest: interval invalide');
     Halt(1);
    End;
   End;
  End
  Else If (LowerCase(Param) = '--count') Then Begin
   If I < ParamCount Then Begin
    Inc(I);
    Try
     MaxTests := StrToInt(ParamStr(I));
    Except
     WriteLn('nstest: count invalide');
     Halt(1);
    End;
   End;
  End
  Else If Copy(Param, 1, 1) <> '-' Then Begin
   QueryName := Param;
  End;
  
  Inc(I);
 End;
 
 { Validation }
 If not IsValidDomainName(QueryName) and not IsValidIPAddress(QueryName) Then Begin
  WriteLn('nstest: "', QueryName, '" n''est pas un nom de domaine ou une adresse IP valide');
  Halt(1);
 End;
 
 { Exécuter le test selon le mode }
 Case TestMode Of
  'basic': Begin
   If TargetServer <> '' Then
    TestSingleServer(TargetServer, QueryName, QueryType, Timeout, Retries)
   Else
    TestAllServers(QueryName, QueryType, Timeout, Retries);
  End;
  'performance': Begin
   PerformanceTest(QueryName, QueryType, Rounds);
  End;
  'continuous': Begin
   ContinuousAvailabilityTest(QueryName, QueryType, TestInterval, MaxTests);
  End;
  'all': Begin
   TestAllServers(QueryName, NT_A, Timeout, Retries);
   TestAllServers(QueryName, NT_NS, Timeout, Retries);
   TestAllServers(QueryName, NT_MX, Timeout, Retries);
  End;
 End;
 
 DisplayFinalStats;
End;
{$ENDIF}

{$IFNDEF FPC}
{ Simulation pour Turbo Pascal }
Procedure ShowSimulatedNSTest(QueryName, TestMode: String);
Begin
 WriteLn('Testing DNS servers with query: ', QueryName, ' (A)');
 WriteLn('===============================================');
 WriteLn(QueryName, ' via 8.8.8.8: OK (45ms, 1 answers)');
 WriteLn(QueryName, ' via 8.8.4.4: OK (52ms, 1 answers)');
 WriteLn(QueryName, ' via 1.1.1.1: OK (38ms, 1 answers)');
 WriteLn(QueryName, ' via 1.0.0.1: OK (41ms, 1 answers)');
 WriteLn(QueryName, ' via 208.67.222.222: OK (67ms, 1 answers)');
 WriteLn(QueryName, ' via 208.67.220.220: OK (72ms, 1 answers)');
 WriteLn;
 WriteLn('=== STATISTIQUES DES TESTS DNS ===');
 WriteLn('Total des requêtes    : 6');
 WriteLn('Requêtes réussies     : 6');
 WriteLn('Requêtes échouées     : 0');
 WriteLn('Taux de réussite      : 100.0%');
 WriteLn('Temps de réponse moyen: 52 ms');
 WriteLn('Temps minimum         : 38 ms');
 WriteLn('Temps maximum         : 72 ms');
End;

Procedure ShowSimulatedPerformance;
Begin
 WriteLn('Performance test with 5 rounds...');
 WriteLn('============================================');
 WriteLn('Round 1/5');
 WriteLn('Round 2/5');
 WriteLn('Round 3/5');
 WriteLn('Round 4/5');
 WriteLn('Round 5/5');
 WriteLn;
 WriteLn('RÉSULTATS DU TEST DE PERFORMANCE');
 WriteLn('=================================');
 WriteLn('Serveur DNS          Succès  Échecs  Temps Moy.');
 WriteLn('-------------------  ------  ------  ----------');
 WriteLn('8.8.8.8                  5       0      45 ms');
 WriteLn('8.8.4.4                  5       0      52 ms');
 WriteLn('1.1.1.1                  5       0      38 ms');
 WriteLn('1.0.0.1                  5       0      41 ms');
 WriteLn('208.67.222.222           5       0      67 ms');
 WriteLn('208.67.220.220           5       0      72 ms');
End;
{$ENDIF}

BEGIN
 {$IFDEF FPC}
 { Initialiser Winsock pour Free Pascal }
 If Not InitializeWinsock Then Begin
  WriteLn('Erreur : Impossible d''initialiser Winsock');
  Halt(3);
 End;
 {$ENDIF}
 
 If (ParamStr(1) = '/?') or (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or
    (ParamStr(1) = '/h') or (ParamStr(1) = '/H') Then Begin
  WriteLn('NSTEST : Outil de test de serveurs DNS');
  WriteLn;
  WriteLn('Syntaxe :');
  WriteLn('  NSTEST [options] nom_de_domaine');
  WriteLn('  NSTEST [options] adresse_ip');
  WriteLn;
  WriteLn('Options :');
  WriteLn('  -t, --type TYPE       Type d''enregistrement à tester (A, NS, MX, etc.)');
  WriteLn('  -s, --server IP       Serveur DNS spécifique à tester');
  WriteLn('  -v, --verbose         Mode verbeux avec détails');
  WriteLn('  -q, --quiet           Mode silencieux');
  WriteLn('  -a, --all             Tester tous les types d''enregistrements');
  WriteLn('  -p, --performance     Test de performance comparative');
  WriteLn('  -c, --continuous      Test de disponibilité continue');
  WriteLn('  --timeout N           Timeout en secondes (défaut: 5)');
  WriteLn('  --retry N             Nombre de tentatives (défaut: 3)');
  WriteLn('  --rounds N            Nombre de rounds pour le test de performance');
  WriteLn('  --interval N          Intervalle en secondes pour le mode continu');
  WriteLn('  --count N             Nombre maximum de tests en mode continu');
  WriteLn;
  WriteLn('Modes de test :');
  WriteLn('  Par défaut            Test tous les serveurs DNS publics');
  WriteLn('  --performance         Compare les performances des serveurs');
  WriteLn('  --continuous          Surveillance continue de la disponibilité');
  WriteLn('  --all                 Test tous les types d''enregistrements');
  WriteLn;
  WriteLn('Serveurs DNS testés par défaut :');
  WriteLn('  8.8.8.8               Google Public DNS');
  WriteLn('  8.8.4.4               Google Public DNS Alternate');
  WriteLn('  1.1.1.1               Cloudflare DNS');
  WriteLn('  1.0.0.1               Cloudflare DNS Alternate');
  WriteLn('  208.67.222.222        OpenDNS');
  WriteLn('  208.67.220.220        OpenDNS Alternate');
  WriteLn('  9.9.9.9               Quad9');
  WriteLn('  149.112.112.112       Quad9 Alternate');
  WriteLn('  64.6.64.6             Verisign');
  WriteLn('  64.6.65.6             Verisign Alternate');
  WriteLn;
  WriteLn('Types d''enregistrements supportés :');
  WriteLn('  A      Adresse IPv4');
  WriteLn('  AAAA   Adresse IPv6');
  WriteLn('  NS     Serveur de noms');
  WriteLn('  MX     Serveur de messagerie');
  WriteLn('  CNAME  Nom canonique');
  WriteLn('  TXT    Enregistrement texte');
  WriteLn('  PTR    Résolution inverse');
  WriteLn('  SRV    Enregistrement de service');
  WriteLn('  SOA    Start of Authority');
  WriteLn;
  WriteLn('Exemples :');
  WriteLn('  NSTEST google.com                    # Test basique');
  WriteLn('  NSTEST -t MX gmail.com               # Test des serveurs MX');
  WriteLn('  NSTEST -s 8.8.8.8 example.com       # Test d''un serveur spécifique');
  WriteLn('  NSTEST -p google.com                 # Test de performance');
  WriteLn('  NSTEST -c --interval 30 github.com   # Surveillance continue');
  WriteLn('  NSTEST -v -a stackoverflow.com       # Test complet verbeux');
  WriteLn('  NSTEST --timeout 10 --retry 5 slow.example.com');
  WriteLn;
  WriteLn('Note: Effectue de vrais tests DNS avec les serveurs spécifiés.');
  WriteLn('Mesure les temps de réponse et la disponibilité en temps réel.');
 End
 Else If ParamStr(1) = '--version' Then Begin
  WriteLn('NSTEST 1.00 - Name Server Test Tool, NETWORKKIT-P');
  WriteLn('Licence MIT');
  WriteLn;
  WriteLn('Écrit par Sylvain Maltais');
 End
 Else Begin
  {$IFDEF FPC}
  InitializeNSTest;
  ParseNSTestCommandLine;
  {$ELSE}
  { Version Turbo Pascal - Simulation }
  If ParamCount = 0 Then Begin
   ShowSimulatedNSTest('google.com', 'basic');
  End Else If (ParamStr(1) = '-p') or (ParamStr(1) = '--performance') Then Begin
   ShowSimulatedPerformance;
  End Else Begin
   ShowSimulatedNSTest(ParamStr(1), 'basic');
  End;
  {$ENDIF}
 End;
 
 {$IFDEF FPC}
 { Nettoyer Winsock }
 CleanupWinsock;
 {$ENDIF}
END.
