function[data]=add_neur_norms(data,neur_timepoint,Neur0,nn)
neur=neur_timepoint;
normNeur=100*(neur./Neur0);
data=addvars(data, normNeur, 'NewVariableNames',strcat('normNeur',string(nn)));