function [data, outliers,timedata] =my_analysis_bfp_only_beepboop(file, sheet, options, all_conditions, all_names, condition, num_timepoints)

filename=char(file);
sorted_data_path=strcat(string(filename(2:end-5)), '-sorted.xlsx');
outlier_path=strcat(string(filename(2:end-5)), '-outliers.xlsx');

data=readtable(file, 'Sheet', sheet);
data=data(:,[1 2:end]);
well=data.Var1;
data=renamevars(data,"Var1","well");
num_variables=numel(all_conditions);   


%creates an empty cell structure to assign conditions to each well
for g=1:numel(condition)
    cond_assigns(1,g)={cell(height(data),1)};
end

% renames Vars into BFP names
for n=1:numel(num_timepoints)
    var_num=strcat('Var',num2str(n+1));
    var_rename=strcat('BFP',num2str(n-1));
    data=renamevars(data, var_num, var_rename);
end

BFP0=table2array(data(:, "BFP0"));
mm=1;

% normalizes each BFP to BFP0
for m=2:numel(num_timepoints)
    BFP_timepoint=table2array(data(:,m+1));
    [data]=add_norms(data, BFP_timepoint, BFP0,mm);
    mm=mm+1;
end

% do not change 
num_conditions=0;

% assigns correct genotype, etc to cells
if numel(all_conditions)==3
    [cond_assigns]=do_platemap_3(data,all_conditions,all_names,cond_assigns);
elseif numel(all_conditions)==2
    [cond_assigns]=do_platemap_2(data,all_conditions,all_names,cond_assigns);
elseif numel(all_conditions)==1
    [cond_assigns]=do_platemap_1(data,all_conditions,all_names,cond_assigns);
end

if numel(condition)==1
    data=addvars(data, cond_assigns(:,1),'After','well');
    data=renamevars(data,"Var2",string(condition(1)));
else
    for m=numel(cond_assigns):-1:1
    for w=1:numel(cond_assigns{1,m})
        if contains(cond_assigns{1,m}{w,1}, 'NT')
            cond_assigns{1,m+1}{w,1} = 'NT';
        end 
    end
    data=addvars(data, cond_assigns{1,m},'After','well');
    data=renamevars(data, "Var2", string(condition(m)));   
    end
end 

% makes individual treatment groups for outlier removal
[all_treats, treats_combined]=group_it_woo(data, cond_assigns,condition);

olddata=data; % creates copy of data to remove outliers from
olddata2=table2array(olddata(:,vartype('numeric'))); 

% remove outliers based on both BFP0 and Neur0 based on +/- 1.5* IQR for
% entire plate

iqr_BFP0=iqr(BFP0);
upq_BFP0=quantile(BFP0, 0.75);
lowq_BFP0=quantile(BFP0, 0.25);

aa=1;

variables=string(varfun(@class,data,'OutputFormat','cell'));
variables=[variables "cell"];

for b=1:numel(variables)
    if variables(b)=='cell'
        variables(b)='string';
    end
end

% this section will start by removing outliers based on initial cell count
% if too few or too many (probably due to bad mask/proliferation) starting cells
% wells will be added to outliers sheet
data.reason=zeros(height(data), 1);
removed_outliers_T0=table('Size',[height(data) width(data)],VariableTypes=variables);
for d=1:height(olddata2)
    if (olddata2(d,1) > upq_BFP0+(1.5*iqr_BFP0))
        removed_outliers_T0(aa,:)=data(d,:);
        removed_outliers_T0(aa, end)= {['BFP0 > ' num2str(upq_BFP0+(1.5*iqr_BFP0))]};
        aa=aa+1;
    elseif (olddata2(d,1) < lowq_BFP0-(1.5*iqr_BFP0))
        removed_outliers_T0(aa,:)=data(d,:);
        removed_outliers_T0(aa, end)= {['BFP0 < ' num2str(lowq_BFP0-(1.5*iqr_BFP0))]};
        aa=aa+1;
    end
end

% here removes outliers based on remaining timepoints (based on normalized
% values per group at each timepoint) e.g. toxic treated wells removed
% based on ave cell count in toxic treated wells, not based on plate
% average since DMSO/NT wells will have high cojnt
outliers=removed_outliers_T0;
for z=1:numel(treats_combined)
    TR=treats_combined(z);
    [new_outliers]=removed_outliers_in_progress(data, TR, variables, condition, num_timepoints);
    outliers=[outliers;new_outliers];
end

outliers=unique(outliers,'rows');

old_names=outliers.Properties.VariableNames;
new_names=data.Properties.VariableNames;

outliers=renamevars(outliers, old_names,new_names);
writetable(outliers, outlier_path,'Sheet', 1);

data=data(:, 1:end-1);
outliers=outliers(:, 1:end-1);

%removes outliers from rest of analysis/sorted data if option is selected.
% otherwise, outliers are stored in outliers excel but still used in
% analysis/graphs
if options.remove_outliers=="true"
    data=setdiff(data, outliers, 'rows');
end 
writetable(data, sorted_data_path);

% here calculating means and variances for each treatment group at each parameter/timepoint
% then using the variance to determine if hetero or homoscedatic variance
% and choose which t.test, then calculate and add all data to sheet 3 


%% adjust this for BFP only
if options.stat_analysis=="true"
    rest_stats=[];
    stat_vars=["string" repmat("double", 1,3*((numel(num_timepoints)-1)))];
    stat_block=treats_combined;
    for q=1:height(stat_block)
        stat_block{q,1}=setdiff(stat_block{q,1}, outliers, 'rows');
    end
    

    stat_results=table('Size', [height(all_treats) 3*((numel(num_timepoints)-1))+1], VariableTypes=stat_vars);
    for p=1:numel(stat_block)
        if contains(stat_block{p,1}{1,2}, string(options.neg_control))
            neg_block=stat_block{p,1};
            stat_results(1,1)=options.neg_control;
            for y=1:numel(num_timepoints)-1
                stat_results(1, (y-1)*3+2)={mean(stat_block{p,1}{:,2+y+numel(num_timepoints)})};
                stat_results(1, (y-1)*3+3)={var(stat_block{p,1}{:,2+y+numel(num_timepoints)})};
                stat_results(1, (y-1)*3+4)={0};
            end
        else rest_stats=[rest_stats; {stat_block{p,1}}];
        end 
    end 

    old_vars=[];
    for y=1:(3*(numel(num_timepoints)-1)+1)
        old_vars=[old_vars strcat("Var", string(y))];
    end
       
    new_vars=[condition(1)];
    for t=1:numel(num_timepoints)-1
        new_vars=[new_vars strcat("normBFP", string(t),"_mean") strcat("normBFP", string(t), "_var") strcat("normBFP", string(t), "_pval_vsNeg")];
    end 
    stat_results=renamevars(stat_results, old_vars, new_vars);

    for t=1:numel(rest_stats)
        stat_results(t+1,1)=rest_stats{t,1}{1,2};
        for y=1:numel(num_timepoints)-1
            % for BFPs
            stat_results(t+1, (y-1)*3+2)={mean(stat_block{t,1}{:,2+y+numel(num_timepoints)})};
            stat_results(t+1, (y-1)*3+3)={var(stat_block{t,1}{:,2+y+numel(num_timepoints)})};
            if stat_results{t+1, (y-1)*3+3}/stat_results{1,(y-1)*3+3} > 4 || stat_results{t+1, (y-1)*3+3}/stat_results{1,(y-1)*3+3} < 0.25
                [hh,pp]=ttest2(stat_block{t,1}{:,2+y+numel(num_timepoints)}, stat_block{p,1}{:,2+y+numel(num_timepoints)}, 'VarType', 'unequal');
                stat_results(t+1, (y-1)*3+4)={pp};
            else 
                [hh,pp]=ttest2(stat_block{t,1}{:,2+y+numel(num_timepoints)}, stat_block{p,1}{:,2+y+numel(num_timepoints)}, 'VarType', 'equal');
                stat_results(t+1, (y-1)*3+4)={pp};
            end  
        end 
    end
   writetable(stat_results, sorted_data_path, 'Sheet', 3);
end 

% for Z prime calculations

if options.zprime=="true"
    c=1;
    k=1;
    for g=1:height(data)
        if contains(string(table2array((data(g,"treatment")))), string(options.neg_control))
            neg_ctrl(c,:)=data(g,:);
            c=c+1;
        elseif contains(string(table2array((data(g,"treatment")))), string(options.pos_control))
            pos_ctrl(k,:)=data(g,:);
            k=k+1;
        end
    end 
    z_vars=["string",repmat("double", 1, 2)];
 
    z_prime=table('Size',[numel(num_timepoints)-1 2], 'VariableTypes',z_vars, 'VariableNames', ["timepoint","normBFP"]);
    
    for jj=1:numel(num_timepoints)-1
        pos_BFP_ave=mean(table2array(pos_ctrl(:,strcat('normBFP', num2str(jj)))));
        pos_BFP_stdev=std(table2array(pos_ctrl(:, strcat('normBFP',num2str(jj)))));
        neg_BFP_ave=mean(table2array(neg_ctrl(:,strcat('normBFP', num2str(jj)))));
        neg_BFP_stdev=std(table2array(neg_ctrl(:, strcat('normBFP',num2str(jj)))));
        pos_BFP_threshold=pos_BFP_ave-3*pos_BFP_stdev;
        neg_BFP_threshold=neg_BFP_ave+3*neg_BFP_stdev;
        BFP_sep=pos_BFP_threshold-neg_BFP_threshold;
        BFP_dynamic=pos_BFP_ave-neg_BFP_ave;
        z_BFP=BFP_sep/BFP_dynamic;
        z_prime(jj,1)=strcat(num_timepoints(jj+1),'H');
        z_prime(jj,2)={z_BFP};
    end
writetable(z_prime, sorted_data_path,'Sheet',2);
end

% end of Z prime calculations, now making a vertical data set to do
% timecourse graphs
for kk=1:numel(num_timepoints)
    time=array2table(repmat(num_timepoints(kk),height(data),1));
    for n=1:height(data)
        timedata((((kk-1)*height(data))+n), "Var1")=time(n, "Var1");
        for g=1:numel(condition)
            timedata((((kk-1)*height(data))+n),strcat("Var", string(g+1)))=data(n, 1+g);
        end 
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+2)))=data(n,num_variables+kk+1);
        if kk==1
            timedata((((kk-1)*height(data))+n),strcat("Var", string(numel(condition)+3)))={100};
        else
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+3)))=data(n, num_variables+kk+numel(num_timepoints)); 
        end

    end
end

old_vars=[];
for hh=1:numel(condition)+3
    old_vars=[old_vars strcat("Var", string(hh))];
end 

new_vars=["Time",[condition],"BFP","normBFP"];
timedata=renamevars(timedata,old_vars,new_vars);

% convert data to format labeled with time for timecourse
for pp=1:width(timedata)
    beep=timedata.Properties.VariableNames{pp};
    types=string(varfun(@class,timedata,'OutputFormat','cell'));
    if types(pp) == 'double'
        new_data.(string(beep))=timedata.(string(beep));
    else
    new_data.(string(beep))=cellstr(timedata.(string(beep)));
    end
end 

