function[data]=add_multiple_norms(data, BFP_timepoint, which_norms, which_to_norm_to, mm, num_timepoints, column)
BFP=BFP_timepoint;
%normBFP=cell(height(data), 1);
criteria=table2array(data(:,column));

for t=1:numel(which_norms)
    for g=1:height(data)
        if contains(cellstr(criteria(g,1)),cellstr(which_norms(1,t)))
            normBFP(g,1)=100*(BFP(g,1)./table2array(data(g,which_to_norm_to(t))));
        end
    end
end
data=addvars(data, normBFP, 'NewVariableNames',strcat('normBFP',num2str(str2double(num_timepoints(mm)))));