getMkt:{exec distinct ROUTE_NAME from PR}

getProds:{[d] mkt:$[""~d`market;exec ROUTE_NAME from PR;`$";" vs d`market];exec distinct PROPRIETARY_NAME from PR where ROUTE_NAME in mkt}

json1:{"{ id: \"",x,"\", text: \"",x,"\"}"}; 

getProdJSON:{[d] mkt:$[""~d`market; exec ROUTE_NAME from PR;`$";" vs d`market]; prod:$[""~d`product; exec PROPRIETARY_NAME from PR;`$";" vs d`product]; Prx: 0!select distinct FN:(((string PROPRIETARY_NAME),\:"-"),'(string ACTIVE_NUMERATOR_STRENGTH)) by string PROPRIETARY_NAME from PR where ROUTE_NAME in mkt, PROPRIETARY_NAME in prod; : "[",("," sv {("{text:\"",(x`PROPRIETARY_NAME),"\",children:["),("," sv json1 each x`FN),"]}"} each Prx),"]"}

asis:{eval parse x`query};

fnt:([]f:`asis`getMkt`getProds`getProdJSON;v:(asis;getMkt;getProds;getProdJSON))

