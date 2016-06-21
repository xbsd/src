
\l /home/softadmin/qutil.q
\c 20 30000
.z.pp:{seralisedjson:-8!.h.uh x 0;show serialisedjson; .z.ph[ raze ".jxo? execute 0x",string serialisedjson]}

getMkt:{exec distinct ROUTE_NAME from PR}

getProds:{$[101h~type x;exec distinct PROPRIETARY_NAME from PR;exec distinct PROPRIETARY_NAME from PR where ROUTE_NAME in `$";" vs (.j.k x)[`market]]}

json1:{"{ id: \"",x,"\", text: \"",x,"\"}"}; 

getProdJSON:{[d] d:$[101h~type d;{x:()!();x[`market]:x[`product]:"";:x}[];.j.k d]; mkt:$[""~d`market; exec ROUTE_NAME from PR;`$";" vs d`market]; prod:$[""~d`product; exec PROPRIETARY_NAME from PR;`$";" vs d`product]; Prx: 0!select distinct FN:(((string PROPRIETARY_NAME),\:"-"),'(string ACTIVE_NUMERATOR_STRENGTH)) by string PROPRIETARY_NAME from PR where ROUTE_NAME in mkt, PROPRIETARY_NAME in prod; : "[",("," sv {("{text:\"",(x`PROPRIETARY_NAME),"\",children:["),("," sv json1 each x`FN),"]}"} each Prx),"]"}

asis:{eval parse x`query};

fnt:([]f:`asis`getMkt`getProds`getProdJSON;v:(asis;getMkt;getProds;getProdJSON))

/Env Vars
grp:"PH:PHID,CITY:grp:x;PL:PLID:grp:x;PL:PLAN_TYPE:grp:x"
piv:"PH:STATE:piv:x"
met:"RXM:TRX:met:sum"

/Static
tattr:1!([]ts:`PH`PL`PR`PE;ke:`PHID`PLID`PRID`month)
fhand:{prs:`ta xkey getProcs[]; }

/Metric Map
metmap:`sum`avg`cdi!({(sum;x)};{(avg;x)};{(#:;(?:;x))})

/Code
getne:{(key x) where ((key x) like y) and (count each value x) > 0}
getfilod:{[od] ne!od[ne:getne[od;"*fil:x"]]}
getfil:{[d] d:mknorm d; ne!d[ne:getne[d;"*fil:x"]]}
normd:{[od] d:(`fn`user`dtt`start`end`ref`grp`piv`met)!od[`x_fn`x_user`x_datetype`x_startdate`x_enddate`x_ref`x_grp`x_piv`x_met];d[`stdt]:"M"$od`x_startdate; d[`endt]:"M"$od`x_enddate;if[d[`dtt] like "current*";ms:(neg "I"$ ssr[d[`dtt];"current";""])#month;d[`stdt]:first ms;d[`endt]:last ms];d[`nd]:`Y;d,:getfilod[od];:d}
mknorm:{[d] if[not `nd in key d;d:normd d];:d}

/Filters
filta:{[d] d:mknorm d; sch:`tab`col`act`cat`ok`ov`ty;spr:string sd:getne[d;"PR:*"];res:raze {[d;sch;x]sch:`tab`col`act`cat`ok`ov`ty; flip sch!ens each (`$":" vs x),(`$x),(enlist d `$x),(string fmt[`$(":" vs x)0;`$(":" vs x)1])}[d;sch;] each spr;$[not count res;:flip sch!enlist each 7#`;:res]}

crpt:{[t;x;vdx;ty] enlist $[ty in "sS";(in;x;ens `$vdx);ty in "Cc";(like;x;vdx);(in;x;ty$vdx)]}
crfl:{[d;t] ftdfull:(filta d); ftd:select from ftdfull where tab=t; raze {crpt[x 0; x 1; x 2; x 3]} each ftd[;`tab`col`ov`ty]}

/Create Parse Tree for Product
getPRID:{[d] prpt:crfl[d;`PR];$[count prpt;?[`PR;prpt;();`PRID];]}

k)ens:{$[(1=#x)&(11h~@x);x;,x]}
fmt:{[t;x] upper (exec t from meta t where c=x)0}
getPR:{[d] d:mknorm d; prc:getne[d;"PR:*"];}

getpt:{[d] pt:enlist (within;`month;(enlist;d`stdt;d`endt)); prid:getPRID d; if[not 101h~type prid;pt,:enlist (in;`PRID;prid)];:pt}
getlj:{1!?[x 0;();0b;x1!x1:distinct (tattr[x 0][`ke]),x 1]}
getmt:{[ta] t:select from ta where act=`met; raze {(enlist x 0)!enlist metmap[x 1] x 0} each t[;`col`cat]}
getgr:{[tb] (,)/ [(0!tb)`col]}

/Accepts 1 item of the format "TAB:ACT:COL:CAT" and converts to table
fgen:{sch:`tab`col`act`cat; if[""~x;:flip sch!enlist each 4#`];xgrp:":" vs x; xgrp:`$$["," in xgrp 1;@[xgrp;1;:;"," vs xgrp 1];xgrp]; flip sch!enlist each xgrp}

/Accepts 1 item of format "TAB:ACT:COL:CAT" from d and converts to table
dgen:{[d] d:mknorm d; }
getbt:{?[x`ta;x`c;x`b;x`a]}

execdict:getRes:{[d] run $[10h~type d;.j.k d;d]}
execute:{[serialisedjson] json:-9!serialisedjson; d:.j.k json; (eval parse -2_d`x_fn)[json]}

run:{[od] 
 d:normd od;

 ta:update ke:{tattr[x][`ke]}each tab from select from (raze fgen each ";" vs ";" sv (d`grp;d`piv;d`met)) where not null tab;
 tb:update raze each col from select distinct col by tab from ta where act in `grp`piv, cat=`x;

 ts:(`ta`tb!(ta;tb));

 ljt: getlj each (0!tb)[;`tab`col];
 xmet:getmt ta;
 btd:`ta`c`b`a!(`RXM;getpt d;gr!gr:exec distinct ke from ta where act=`grp;xmet);
 bt:{[x;btd] h:getH x;res:h (getbt;btd);:res} [`rxqatest;btd];
 bt:(lj)/ [bt;ljt];
 ft:fillNullSym ?[bt;();(getgr tb)!getgr tb;btd`a];
 :ft

 }

/od:.j.k "{\"x_fn\": \"execdict\", \"x_user\": \"raj\", \"x_ref\": \"month\", \"x_datetype\": \"current3\", \"x_startdate\": \"2018.01.01\", \"x_enddate\":\"2018.03.01\", \"x_grp\":\"PH:STATE:grp:x;PR:PROPRIETARY_NAME,DEA_SCHEDULE:grp:x\", \"x_met\":\"RXM:TRX:met:sum;RXM:NRX:met:sum\", \"x_piv\":\"PE:YEAR:grp:x\"}"

