
\l /home/softadmin/qutil.q

getMkt:{exec distinct ROUTE_NAME from PR}

getProds:{$[101h~type x;exec distinct PROPRIETARY_NAME from PR;exec distinct PROPRIETARY_NAME from PR where ROUTE_NAME in `$";" vs (.j.k x)[`market]]}

json1:{"{ id: \"",x,"\", text: \"",x,"\"}"}; 

getProdJSON:{[d] d:$[101h~type d;{x:()!();x[`market]:x[`product]:"";:x}[];.j.k d]; mkt:$[""~d`market; exec ROUTE_NAME from PR;`$";" vs d`market]; prod:$[""~d`product; exec PROPRIETARY_NAME from PR;`$";" vs d`product]; Prx: 0!select distinct FN:(((string PROPRIETARY_NAME),\:"-"),'(string ACTIVE_NUMERATOR_STRENGTH)) by string PROPRIETARY_NAME from PR where ROUTE_NAME in mkt, PROPRIETARY_NAME in prod; : "[",("," sv {("{text:\"",(x`PROPRIETARY_NAME),"\",children:["),("," sv json1 each x`FN),"]}"} each Prx),"]"}

asis:{eval parse x`query};
execute:{([]a: 1 2)};

fnt:([]f:`execte`asis`getMkt`getProds`getProdJSON;v:(execute;asis;getMkt;getProds;getProdJSON))

/Env Vars
grp:"PH:PHID,CITY:grp:x;PL:PLID:grp:x;PL:PLAN_TYPE:grp:x"
piv:"PH:STATE:piv:x"
met:"RXM:TRX:met:sum"

/Static
tattr:1!([]ts:`PH`PL`PR`PE;ke:`PHID`PLID`PRID`month)
fhand:{prs:`ta xkey getProcs[]; }

/Metric Map
metmap:`sum`avg`cdi!(sum;avg;(#:;(?:;`a)))

/Code

normd:{[od] d:(`fn`user`dtt`start`end`ref`grp`piv`met)!od[`x_fn`x_user`x_datetype`x_startdate`x_enddate`x_ref`x_grp`x_piv`x_met];d[`stdt]:"D"$od`x_startdate; d[`endt]:"D"$od`x_enddate;:d}

getpt:{[d] pt:enlist (within;`month;(enlist;d`stdt;d`endt)); :pt}
getlj:{1!?[x 0;();0b;x1!x1:distinct (tattr[x 0][`ke]),x 1]}
getmt:{[ta] (,)/ [{[ta] tax: select col, act:metmap[cat] from ta where act=`met; {enlist (x 1;x 0)} each tax[;`col`act]} ta]}
getag:{[xmet] d0:({x 1} each xmet)!xmet;d1:({`$(upper string x 0),"_",(string x 1),"_"} each xmet)!xmet;`d0`d1!(d0;d1)}
getgr:{[tb] (,)/ [(0!tb)`col]}

/Accepts 1 item of the format "TAB:ACT:COL:CAT" and converts to table
fgen:{sch:`tab`col`act`cat; if[""~x;:flip sch!enlist each 4#`];xgrp:":" vs x; xgrp:`$$["," in xgrp 1;@[xgrp;1;:;"," vs xgrp 1];xgrp]; flip sch!enlist each xgrp}

getbt:{?[x`ta;x`c;x`b;x`a]}

run:{[od] 
 d:normd od;

 ta:update ke:{tattr[x][`ke]}each tab from select from (raze fgen each ";" vs ";" sv (d`grp;d`piv;d`met)) where not null tab;
 tb:update raze each col from select distinct col by tab from ta where act in `grp`piv, cat=`x;

 ts:(`ta`tb!(ta;tb));

 ljt: getlj each (0!tb)[;`tab`col];
 xmet:getmt ta;
 btd:`ta`c`b`a!(`RXM;getpt d;gr!gr:exec distinct ke from ta where act=`grp;(getag xmet)`d0);
 bt:{[x;btd] h:getH x;res:h (getbt;btd);:res} [`rxqatest;btd];
 bt:(lj)/ [bt;ljt];
 ft:fillNullSym ?[bt;();(getgr tb)!getgr tb;(getag xmet)`d1]

 }

/od:.j.k "{\"x_fn\": \"execdict\", \"x_user\": \"raj\", \"x_ref\": \"month\", \"x_datetype\": \"current3\", \"x_startdate\": \"2018.01.01\", \"x_enddate\":\"2018.03.01\", \"x_grp\":\"PH:STATE:grp:x;PR:PROPRIETARY_NAME,DEA_SCHEDULE:grp:x\", \"x_met\":\"RXM:TRX:met:sum;RXM:NRX:met:sum\", \"x_piv\":\"PE:YEAR:grp:x\"}"

