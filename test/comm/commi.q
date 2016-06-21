/Master Configuration File

/Load Helper Functions
\l /app/kdb/src/test/comm/commhelper.q

\c 10 30000
srcDir:{"/app/kdb/src"}
procFile: {raze x,"/test/comm/proctable.csv"}
qArgs: {"-s 16"}
qPath: {"/opt/q/l64/"}
removeBl: {ssr[x;" ";""]}

/Screen Commands
createScreen:{system "screen -dm ",x}
getScreenCount: {system ("screen -ls | grep "),x," | wc -l"}
sendToScreen: {system raze "screen -S ",x," -p 0 -X stuff \"$(printf \\\\r)",y,"$(printf \\\\r)\""}
startCleanScreen: {killScreen x; createScreen x }
killScreen: {system "screen -ls | grep ",x," | cut -f1 -d'.' | sed 's/\\W//g' | xargs kill -9; screen -wipe;true"}

/Handlers

/Takes session name as argument (eg., `rxbgtest)
getH:{pr:getProcs[][x]; if[x~`$(getCurrArgs[][`start])0;:0]; handle:$[`localhost~pr[`host];hsym `$"unix://",string pr`port;hsym `$(string pr`host),":",(string pr`port)];:handle}

getCurrArgs:{.Q.opt .z.x}

/Helper Functions
/General Functions

/Convert Char Cols to Sym
char2sym:{![x;();0b;c!{($;enlist`;x)}each c:exec c from meta x where t in"Cc"]}

/Usage: fillNullSym [table]
fillNullSym:{ {[t;c] ![t;();0b;c!(,)/ [{enlist (^;enlist `$("NULL_",string x);x)} each c]]}[x;exec c from meta x where t in "s"]}

/Process File and Process Management
readProcFile: {file:read0 hsym `$procFile srcDir[]}
getProcs: {prs:readProcFile[]; csvf: prs where not any prs like/: ("#*";""); coln: 1 + count ss[(1#csvf)0;","]; :`senv xkey update senv:`$((string session),'(string env)) from (coln#"S";enlist ",") 0: csvf }

getDefs: {[x] session:-4_string x;
 env:-4#string x;
 prs:readProcFile[];
 defs: prs where prs like "# DEFAULT*";
 d:(,)/ [{[session;env;def] a:enlist each `$"," vs removeBl raze ssr[raze ssr[ssr[def;"# DEFAULT";""];"ENV";string env];"SESSION";string session];(a 0)!a 1}[session;env;] each defs];d[`logFile]:`$(string d[`logDir]),("/",session,env,"log.txt");
 d[`fnFile]: `$(string d[`srcDir]),("/",session,"f.q");
 d[`inFile]: `$(string d[`srcDir]),("/",session,"i.q");
 :d
 }

getAppParams: {prs:getProcs[]; defs: getDefs[x]; thisapp:prs[x]; :$[0=sum not null thisapp;@[defs;key defs;:;`];defs]^thisapp }


startProc:{
 params:getAppParams[x];

 show msger[x] "Executing Script ", string .z.f;

 show msger[x;] "Loading DB ",db:string params`dbDir;
 system "l ",db;

 show msger[x;] "Setting Port ",port:string params`port;
 system "p ",port;


 show msger[x;] "Loading Functions ",fnFile:string params`fnFile;
 system "l ",fnFile;
 }

startShellProc: {
 strx: $[-11h~type x;string x;x];
 symx: $[-11h~type x;x;`$x];
 params:getAppParams symx;
 startCleanScreen strx;
 params:getAppParams symx;
 appCmd:(string (getAppParams symx)`inFile)," -start ",strx;
 fullCmd:"rlwrap ",qPath[],"q ",appCmd," ",qArgs[];
 sendToScreen[strx;fullCmd];
 }

/Logging
getTime: {.z.Z}
msger: {[x;y]
 header:`LOGAPP;
 time:getTime[];
 user:.z.u;
 host:.z.h;
 app:x;
 pid:.z.i;
 message:$[10h~abs type y;`$y;y];
 ";" sv string each (header;time;user;host;app;pid;message)
 }

/Finally,
ermsgt:([]Error:enlist "System Errors")
execdict: {x:.j.k $[4h~type x;-9!x;x];fx:`$x`fn;((fnt`v)((where (fnt`f)=fx)0))x}
.z.ws: {show -9!x;res:.j.j @[execdict;x;ermsgt]; show res; neg[.z.w] res}

args:.Q.opt .z.x
keyargs:key args

if[`startall in keyargs; startShellProc each exec senv from getProcs[]];
if[`start in keyargs;startProc `$args[`start]0];
if[`exit in keyargs;exit 0];
