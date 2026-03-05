function[data]=neurnorms(data,neur_timepoint,Neur0,nn,num_timepoints)
neur=neur_timepoint;
normNeur=100*(neur./Neur0);
data=addvars(data, normNeur, 'NewVariableNames',strcat('normNeur',num2str(str2double(num_timepoints(nn)))));