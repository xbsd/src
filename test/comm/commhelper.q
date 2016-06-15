/General Functions

/Convert Char Cols to Sym
char2sym:{![x;();0b;c!{($;enlist`;x)}each c:exec c from meta x where t in"Cc"]}

/Usage: fillNullSym [table]
fillNullSym:{ {[t;c] ![t;();0b;c!(,)/ [{enlist (^;enlist `$("NULL_",string x);x)} each c]]}[x;exec c from meta x where t in "s"]}

