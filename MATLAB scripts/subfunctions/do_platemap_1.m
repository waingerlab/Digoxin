function[cond_assigns]=do_platemap_1(data,all_conditions,all_names, cond_assigns)

for n=1:numel(all_conditions{1,1})
            c=1;
            for f=1:height(data)
                well_name=string(data{f, 'well'});            
                if contains(well_name, all_conditions{1,1}{1,n})
                   cond_assigns{f,1}=all_names{1,1}{1,n};
                   c=c+1;
                end
            end
 end
 