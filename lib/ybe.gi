BindGlobal("YBFamily", NewFamily("YBFamily"));
InstallValue(YBType, NewType(YBFamily, IsYB));

### This function returns the set-theoretic solution given by the permutations <l_actions> and <r_actions>
### <l_action> and <r_action> are matrices!
InstallMethod(YB, "for a two lists of permutations", [ IsList, IsList ], 
function(l, r)
  local obj;
  if not IS_YB(l, r) then
    Error("this is not a solution of the YBE\n");
  fi;
  
  obj := Objectify(YBType, rec());

  SetSize(obj, Size(l));
  SetLMatrix(obj, List(l, x->List(x, y->y)));
  SetRMatrix(obj, List(r, x->List(x, y->y)));

  return obj;

end);

InstallMethod(ViewObj,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  Print("<A set-theoretical solution of size ", Size(obj), ">");
end);

InstallMethod(PrintObj,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  if Size(obj) < 5 then
    Print("YB(", LMatrix(obj), ",", RMatrix(obj), ")");
  else
    Print("<A set-theoretical solution of size ", Size(obj), ">");
  fi;
end);

InstallMethod(SmallIYB, "for two integers", [ IsInt, IsInt ],
function(size, number)
  return CycleSet2YB(SmallCycleSet(size, number));
end);

InstallMethod(Permutations2YB, "for a list of permutations", [ IsList, IsList ],
function(l, r)
  return YB(List(l, x->ListPerm(x, Size(l))), List(r, y->ListPerm(y, Size(l))));
end);

### This function returns the set-theoretic solution
### corresponding to the matrix <table> such that the (i,j) entry is r(i,j)
#InstallMethod(Table2YB, "for a square matrix", [ IsList ],
#function(table)
#  local ll, rr, x, y, p, n;
#
#  n := Sqrt(Size(table));
#
#  ll := List([1..n], x->[1..n]);
#  rr := List([1..n], x->[1..n]);
#
#  for p in table do
#    x := p[1][1];
#    y := p[1][2];
#    ll[x][y] := p[2][1];
#    rr[y][x] := p[2][2];
#  od;
#  return YB(ll, rr);
#end);

##### This function returns the table of the solution, which is 
##### the matrix that in the (i,j)-entry has r(i,j)
#InstallMethod(DisplayTable, "for a set theoretic solution", [ IsYB ], 
#function(obj)
#  local m, x, y;
#  m := NullMat(Size(obj), Size(obj));
#  for x in [1..Size(obj)] do
#    for y in [1..Size(obj)] do
#      m[x][y] := TableYB(obj, x, y);
#    od;
#  od;
#  return m;
#end);

### This function returns true if <obj> is square-free
### A solution r is square-free iff r(x,x)=(x,x) for all x
InstallOtherMethod(IsSquareFree,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  local x;
  for x in [1..Size(obj)] do
    if [LMatrix(obj)[x][x], RMatrix(obj)[x][x]] <> [x, x] then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IYBGroup, "for a set-theoretical solution", [ IsYB ],
function(obj)
  return YBPermutationGroup(obj);
end);

InstallMethod(YBPermutationGroup, "for a set-theoretical solution", [ IsYB ],
function(obj)
  return Group(LPerms(obj));
end);

### This function returns the vector value of <obj> at (<x>,<y>)
InstallMethod(TableYB, "for a set-theoretical solution", [ IsYB, IsInt, IsInt ],
function(obj, x, y)
  return [LMatrix(obj)[x][y], RMatrix(obj)[y][x]];
end);

### This function returns true if <obj> is involutive
### r is involutive <=> r^2=id
InstallMethod(IsInvolutive, "for a set-theoretical solution", [ IsYB ],
function(obj)
  local x,y,s;
  for x in [1..Size(obj)] do
    for y in [1..Size(obj)] do
      s :=  TableYB(obj, x, y);
      if TableYB(obj, s[1], s[2]) <> [x,y] then
        return false;
      fi;
    od;
  od;
  return true;
end);

#InstallMethod(YBTable, "for a set-theoretical solution", [ IsYB, IsInt, IsInt ],
#function(obj, i, j)
#  return [obj!.l_actions[x][y], obj!.r_actions[y][x]];
#end);


### This function returns true if the maps x->L_x are bijective
### r(x,y)=(L_x(y), R_y(x))
### CHECK
InstallMethod(IsLeftNonDegenerate,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  local l;
  l := List(LMatrix(obj), PermList);
  if fail in l then
    return false;
  else
    SetLPerms(obj, l);
    return true;
  fi;

  #for x in [1..Size(obj)] do
  #  if PermList(LMatrix(obj)[x]) = fail then
  #    return false;
  #  fi;
  #od;
  #SetLPerms(obj, List(LMatrix(obj), PermList));
  #return true;
end);

### This function returns true if the maps x->R_x are bijective
### r(x,y)=(L_x(y), R_y(x))
InstallMethod(IsRightNonDegenerate,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  local l;
  l := List(RMatrix(obj), PermList);
  if fail in l then
    return false;
  else
    SetRPerms(obj, l);
    return true;
  fi;
end);

### This function returns true if <r> is left and right non-degenerate
InstallMethod(IsNonDegenerate,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  return IsLeftNonDegenerate(obj) and IsRightNonDegenerate(obj);
end);

InstallMethod(LPerms, 
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  if IsLeftNonDegenerate(obj) then
    return LPerms(obj);# List(obj!.l_actions, x->PermList(x));
  fi;
  return fail;
end);

InstallMethod(RPerms, 
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  if IsRightNonDegenerate(obj) then
    return RPerms(obj);
  fi;
  return fail;
end);
 
InstallMethod(YB2CycleSet,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)

  if not IsInvolutive(obj) then
    Error("the solution of the YBE is not involutive\n");
  fi;

  if not IsRightNonDegenerate(obj) then
    Error("the soslution of the YBE is not (right) non-degenerate\n");
  fi;

  return CycleSet(RMatrix(obj));
end);

InstallGlobalFunction(YB_xy,
  "for a set-theoretical solution",
  function(obj, x, y)
  return [LMatrix(obj)[x][y], RMatrix(obj)[y][x]];
  #return [obj!.l_actions[x][y], obj!.r_actions[y][x]];
end);

InstallMethod(Retract,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  local e, c, s, pairs, x, y, z, ll, rr;

  if not IsInvolutive(obj) then
    Error("the solutions of the YBE is not involutive\n");
  fi;

  pairs := [];
  for x in [1..Size(obj)] do
    for y in [1..Size(obj)] do
      if LPerms(obj)[x] = LPerms(obj)[y] then
        Add(pairs, [x, y]);
      fi;
    od;
  od;

  e := EquivalenceRelationByPairs(Domain([1..Size(obj)]), pairs);
  c := EquivalenceClasses(e); 
  s := Size(c);

  ll := List([1..s], x->[1..s]);
  rr := List([1..s], x->[1..s]);

  for x in [1..s] do
    for y in [1..s] do
      z := YB_xy(obj, Representative(c[x]), Representative(c[y]));
      ll[x][y] := Position(c, First(c, u->z[1] in u));
      rr[y][x] := Position(c, First(c, u->z[2] in u));
    od;
  od;
  return YB(ll, rr);
end);

InstallMethod(IsRetractable,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  local r;
  r := Retract(obj);
  if Size(r) = Size(obj) then
    return false;
  else
    return true;
  fi;
end);

InstallMethod(IsMultipermutation,
  "for a set-theoretical solution",
  [ IsYB ],
  function(obj)
  if not MultipermutationLevel(obj) = fail then
    return true;
  else
    return false;
  fi;
end);

InstallMethod(MultipermutationLevel,
  "for a set-theoretical solution",
   [ IsYB ],
  function(obj)
  local r,s,l;

  l := 0;
  r := ShallowCopy(obj);

  repeat
    s := ShallowCopy(r);
    r := Retract(s);
    if Size(r) <> Size(s) then
      l := l+1;
    else
      return fail;
    fi;
  until Size(r) = 1;
  return l;
end);

### This function returns the number of involutive set-theoretic solutions of size <n>
InstallGlobalFunction(NrSmallIYB, 
function(n)
  return NrSmallCycleSets(n);
end);

### This function returns the permutations defining the set-theoretic solution
### These permutations are in the following form: [ left_permutations, right_permutations ]
InstallOtherMethod(Permutations,
  "for set-theoretic solutions", 
  [ IsYB ],
  function(obj)
  return [LPerms(obj), RPerms(obj)];
end);


### This function returns the <i>-th involutive set-theoretic solution of size <n>
### These solutions were computed by Etingof, Schedler and Soloviev
#InstallGlobalFunction(SmallIYB, 
#function(n, i)
#  return CycleSet2YB(SmallCycleSet(n,i));
#  local r, data;
#  data := [
#    YB_size1, 
#    YB_size2, 
#    YB_size3, 
#    YB_size4, 
#    YB_size5, 
#    YB_size6, 
#    YB_size7, 
#    YB_size8
#  ];
#  if n in [1..8] then
#    r := data[n][i];
#    return YB(r[1], r[2]);
#  else
#    return fail;
#  fi;
#end);

InstallGlobalFunction(YB_IsBraidedSet, 
function(l_actions, r_actions)
  local x, y, z, v;

  if Size(r_actions) <> Size(l_actions) then
    return false;
  fi;

  for x in [1..Size(l_actions)] do
    for y in [1..Size(l_actions)] do
      for z in [1..Size(l_actions)] do
        v := [x,y,z];
        if YB_ij(l_actions, r_actions, YB_ij(l_actions, r_actions, YB_ij(l_actions, r_actions, v, 2, 3), 1, 2), 2, 3) \
          <> YB_ij(l_actions, r_actions, YB_ij(l_actions, r_actions, YB_ij(l_actions, r_actions, v, 1, 2), 2, 3), 1, 2) then
          return false;
        fi;
      od;
    od;
  od;
  return true;
end);

### This function returns true if <subset> is r-invariant
### A subset Y of X is r-invariant if r(YxY) is included in YxY
InstallMethod(IsInvariant, "for a solution and a list", [IsYB, IsList], 
function(obj, subset)
  local x, y, z;
  for x in subset do
    for y in subset do
      z := YB_xy(obj, x, y);
      if not z[1] in subset or not z[2] in subset then
        return false;
      fi;
    od;
  od;
  return true;
end);

### This function returns the restricted solution with respect to <subset>
### If <subset> is not invariant, the function returns fail
InstallMethod(RestrictedYB, "for a solution and a list", [ IsYB, IsList ],
function(obj, subset)
  local x, y, z, ll, rr;

  if not IsInvariant(obj, subset) then
    return fail;
  fi;

  ll := List([1..Size(subset)], x->[1..Size(subset)]);
  rr := List([1..Size(subset)], x->[1..Size(subset)]);

  for x in [1..Size(subset)] do
    for y in [1..Size(subset)] do
      ll[x][y] := Position(subset, subset[y]^LPerms(obj)[subset[x]]);
      rr[y][x] := Position(subset, subset[x]^RPerms(obj)[subset[y]]);
    od;
  od;
  return YB(ll, rr);
end);

### This function returns the structure group of <r>
### Generators: x_1,x_2,...,x_n 
### Relations: x_ix_j=x_kx_l whenever r(i,j)=(k,l)
InstallMethod(StructureGroup, "for a solution", [ IsYB ], 
function(obj)
  local n, f, x, y, rels, i, j;

  n := Size(obj);
  f := FreeGroup(n);
  x := GeneratorsOfGroup(f); 

  rels := [];

  for i in [1..n] do
    for j in [1..n] do
      y := YB_xy(obj, i, j);
      Add(rels, x[i]*x[j]*Inverse(x[y[1]]*x[y[2]]));
    od;
  od;
  return f/rels;
end);

### This function returns the trivial solution over [1..size]
### r is trivial <=> r(x,y)=(y,x)
InstallMethod(TrivialYB, "for an integer", [ IsInt ],
function(n)
  return YB(List([1..n], x->[1..n]), List([1..n], x->[1..n]));
end);

### This function returns Lyubashenko solution over [1..size] with respect to <f> and <g>
### r is defined as r(x,y)=(f(y),g(x)), where f and g are permutations 
InstallMethod(LyubashenkoYB, "for an integer and two permutations", [ IsInt, IsPerm, IsPerm ],
function(size, f, g)
  if f*g=g*f then
    return YB(List([1..size], x->ListPerm(g, size)), List([1..size], x->ListPerm(f,size)));
  else
    return fail;
  fi;
end);

### This function returns the cartesian product of the solutions <r> and <s>
### This means: r((a,b),(c,d))=(r(a,c),r(b,d))
InstallMethod(CartesianProduct, "for two solutions", [ IsYB, IsYB ],
function(r, s)
  local c, l, u, v, w; 
  l := [];
  c := Cartesian([1..Size(r)], [1..Size(s)]);
  for u in c do
    for v in c do
      w := [YB_xy(r, u[1], v[1]),  YB_xy(s, u[2], v[2])];
      Add(l, [[Position(c, u), Position(c, v)], [Position(c, [w[1][1], w[2][1]]), Position(c, [w[1][2], w[2][2]])]]);
    od;
  od;
  return Table2YB(l);
end);

### This function returns the matrix of the rack corresponding to the derived solution of a solution 
InstallMethod(DerivedRack, "for a solution", [ IsYB ],
function(obj)
  local x, y, z, m;

  if not IsNonDegenerate(obj) then
    return fail;
  fi;

  m := NullMat(Size(obj), Size(obj));
  for x in [1..Size(obj)] do
    for y in [1..Size(obj)] do
      # I have two operations. Let S(x,y)=(g_x(y),f_y(x)) and 
      # xoy=g_y(x), y*x=Inverse(f)_y(x). 
      # Then the derived rack structure is given by x>y=f_x((y*x)oy)
      z := y^LPerms(obj)[x^Inverse(RPerms(obj)[y])];    
      m[x][y] := z^RPerms(obj)[x];
    od;
  od;
  return Rack(m);
end);

InstallMethod(Wada, "for a group", [ IsGroup ],
function(group)
  local x, y, e, l, r;

  e := Elements(group);
  l := NullMat(Size(group), Size(group));
  r := NullMat(Size(group), Size(group));
  for x in group do
    for y in group do
      l[Position(e, x)][Position(e, y)] := Position(e, x*Inverse(y)*Inverse(x));
      r[Position(e, y)][Position(e, x)] := Position(e, x*y^2);
    od;
  od;
  return YB(l, r);
end);

### CHECK and FIXME
InstallMethod(IsBiquandle, "for a solution", [ IsYB ],
function(obj)
  local x, y;
  for x in [1..Size(obj)] do
    if not ForAny([1..Size(obj)], y->YB_xy(obj, x, y)=[x,y]) then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(YB2Permutation, "for a solution", [ IsYB ],
function(obj)
  local perm, x, y, u, v;

  perm := [1..Size(obj)^2];

  for x in [1..Size(obj)] do
    for y in [1..Size(obj)] do
      u := YB_xy(obj, x, y)[1];
      v := YB_xy(obj, x, y)[2];
      perm[x+Size(obj)*y] := u+Size(obj)*v;
    od;
  od;
  return PermList(perm);
end);

## j>i = s_y t_(s_x^(-1)(y))(x)
#lrack := function(lperms, rperms)
#  local i,j,m,n;
#  n := Size(lperms);
#  m := NullMat(n,n);
#  for i in [1..n] do
#    for j in [1..n] do
#      m[j][i] := (i^lperms[j^Inverse(rperms[i])])^rperms[j];
#    od;
#  od;
#  return Rack(m);
#end;

InstallMethod(DerivedRightRack, "for a solution", [ IsYB ], 
function(obj)
  local i,j,m,n,lperms,rperms;
  lperms := List(obj!.l_actions, PermList);
  rperms := List(obj!.r_actions, PermList);
  n := Size(lperms);
  m := NullMat(n,n);
  for i in [1..n] do
    for j in [1..n] do
      m[j][i] := (i^rperms[j^Inverse(lperms[i])])^lperms[j];
    od;
  od;
  return Rack(m);
end);

# j>i = s_y t_(s_x^(-1)(y))(x)
# it follows the notation of my paper with Lebed
InstallMethod(DerivedLeftRack, "for a solution", [ IsYB ], 
function(obj)
  return DerivedRack(obj);
end);

InstallMethod(YB2Permutation, "for a solution", [ IsYB ], function(obj)
  local perm, x, y, u, v;

  perm := [1..Size(obj)^2];

  for x in [1..Size(obj)] do
    for y in [1..Size(obj)] do
      u := YB_xy(obj, x, y)[1];
      v := YB_xy(obj, x, y)[2];
      perm[x+Size(obj)*y] := u+Size(obj)*v;
    od;
  od;
  return PermList(perm);
end);



