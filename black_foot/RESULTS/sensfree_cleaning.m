%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Free sensor filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleans the signal from the unloaded sensor and return the thrshold values

function [Min,Max,offset,Sigma]=sensfree_cleaning

sens_free = load('sens_free.txt');

[s,~]=size(sens_free);

offset=mean(sens_free(:,2:13));
offset=repmat(offset,s,1);

sens_free(:,2:13)=sens_free(:,2:13)-offset;

Min=min(sens_free(1:end,2:13));
Max=max(sens_free(1:end,2:13));

Sigma = sqrt(var(sens_free(:,2:13)));

end