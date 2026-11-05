function [V1]=smoothCurve(F1,V1,nc,ns,indList1)
clear cPar
cPar.n=nc;
cPar.Method='HC';
e=[(1:numel(indList1))' [(2:numel(indList1))';1]];
v=V1(indList1,:);
[v]=patchSmooth(e,v,[],cPar);
V1(indList1,:)=v;

indTouch=unique(F1(any(ismember(F1,indList1),2),:));
indTouch=unique(F1(any(ismember(F1,indTouch),2),:));
logicRigid=true(size(V1,1),1);
logicRigid(indTouch)=0;
logicRigid(indList1)=1;
indRigid=find(logicRigid);

cPar.n=ns;
cPar.Method='HC';
cPar.RigidConstraints=indRigid;
[V1]=patchSmooth(F1,V1,[],cPar);
end
