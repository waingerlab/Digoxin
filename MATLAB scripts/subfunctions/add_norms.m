function[data]=add_norms(data, BFP_timepoint, BFP0,mm)
BFP=BFP_timepoint;
normBFP=100*(BFP./BFP0);
data=addvars(data, normBFP, 'NewVariableNames',strcat('normBFP',num2str(mm)));