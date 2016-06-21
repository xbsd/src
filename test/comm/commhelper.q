/General Functions

/Convert Char Cols to Sym
char2sym:{![x;();0b;c!{($;enlist`;x)}each c:exec c from meta x where t in"Cc"]}

/Usage: fillNullSym [table]
fillNullSym:{ {[t;c] ![t;();0b;c!(,)/ [{enlist (^;enlist `$("NULL_",string x);x)} each c]]}[x;exec c from meta x where t in "s"]}

/Modified Pivot
piv2:{[t;k;p;v;dataDict;f;g]
 v:(),v;
 G:group flip k!(t:.Q.v t)k;
 F:group flip p!t p;
 count[k]!g[k;P;C]xcols 0!key[G]!flip(C:f[v]P:flip value flip key F)!raze
  {[i;j;k;x;y]
   a:count[x]#x 0N;
   a[y]:x y;
   b:count[x]#0b;
   b[y]:1b;
   c:a i;
   c[k]:first'[a[j]@'where'[b j]];
   c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]
 }


