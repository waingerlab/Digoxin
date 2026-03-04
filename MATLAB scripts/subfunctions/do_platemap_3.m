function[cond_assigns]=do_platemap_3(data,all_conditions,all_names, cond_assigns)

for n=1:numel(all_conditions)
    for p=1:numel(all_conditions{1,n})
        for j=1:numel(all_conditions{1,n}{1,p})
            c=1;
            for f=1:height(data)
                well_name=string(data{f, 'well'});            
                if contains(well_name, all_conditions{1,n}{1,p}{1,j})
                   cond_assigns{1,n}{f,1}=all_names{1,n}{1,p};
                   c=c+1;
                end
            end
        end
    end
end 

