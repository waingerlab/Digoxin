%% duplicate this script before using and put in the folder for your experiment %%

%%this script organizes data for BFP+TdTo (2 channel) cells and produces
%%excels of the data sorted with normalized vals and treatments/conditions
%%assigned, as well as an excel of outliers with reasons why they were
%%excluded

%requires gramm visulisation toolbox by Pierre Morel

addpath('.../gramm', ...
    '.../Martha_subfunctions');

file = '.../screening_plate.xlsx';
sheet = 'SN_Count'; %% change to name of BFP sheet on excel

data=readtable(file, 'Sheet', sheet);
well=data.Var1;
neur_data=readtable(file, 'Sheet', 'Neurite_Area');

%if want outliers removed in graphs etc, make this true
%otherwise outliers will be noted in outlier sheet but not removed from
%rest of analysis
options.remove_outliers="false";

% change this to your treatments!
neg_control_name='...';
pos_control_name='...';
experimental_name='...';
treatments={pos_control_name,neg_control_name,experimental_name};

% order you want things graphed in from L to R
order={pos_control_name,neg_control_name,experimental_name,'Empty'};

% change to have same # of timepoints as the images
num_timepoints={'1','2','3'};
timepoints=[0 24 48];

% assign conditions, either via column of via individual wells if the
% columns/rows are split within the condition
%%% INCLUDE ZEROS FOR COLS 01-09
    tr_pos=["A02","B02","C02","D02","E02","F02","G02","H02","I01","J01","K01","L01","M01","N01","O01","P01","A24","B24","C24","D24","E24","F24","G24","H24","I23","J23","K23","L23","M23","N23","O23","P23",];
    tr_neg=["I02","J02","K02","L02","M02","N02","O02","P02","A01","B01","C01","D01","E01","F01","G01","H01","I24","J24","K24","L24","M24","N24","O24","P24","A23","B23","C23","D23","E23","F23","G23","H23"];
    tr_exp=["03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22"];
    all_treatments={tr_pos tr_neg tr_exp};
    treatment_names=[string(pos_control_name),string(neg_control_name),string(experimental_name)];

%change to be the groups of your conditions
all_conditions={all_treatments};
all_names={treatment_names};

num_variables=numel(all_conditions);    

% change to the correct conditions
condition={'treatment'};
treatment=cell(height(data),1);
cond_assigns={treatment};

% if want script to calculate Z' for plate, make this = "true", otherwise 
% make it ="false";
options.zprime='true';
pos_control={string(pos_control_name)};
neg_control={string(neg_control_name)};

% add paths to export excels and figures to 
export_path= 'export folder';
sorted_data_path='.../sorted.xlsx';
outlier_path='.../outliers.xlsx';


%% DO NOT CHANGE BELOW HERE %%

data=renamevars(data,"Var1","well");
neur_data=renamevars(neur_data,"Var1","well");

%rename vars 
if numel(num_timepoints)==1
    var_num=strcat('Var',num2str(2));
    var_rename=strcat('BFP',num2str(0));
    data=renamevars(data, var_num, var_rename);
else 
    for n=1:numel(num_timepoints)
    var_num=strcat('Var',num2str(str2double(num_timepoints(n))+1));
    var_rename=strcat('BFP',num2str(str2double(num_timepoints(n))-1));
    data=renamevars(data, var_num, var_rename);
    end
end

% isolate time 0 for normalisation
BFP0=table2array(data(:, "BFP0"));
mm=1;

% normalise to baseline
if numel(num_timepoints)>1
    for m=2:numel(num_timepoints)
        BFP_timepoint=table2array(data(:,m+1));
        [data]=add_norms(data, BFP_timepoint, BFP0,mm);
        mm=mm+1;
    end

    for i=1:numel(num_timepoints)
        var_num1=strcat('Var', num2str(str2double(num_timepoints(i))+1));
        var_rename1=strcat('Neur',num2str(str2double(num_timepoints(i))-1));
        neur_data=renamevars(neur_data, var_num1, var_rename1);
    end
else 
    var_num=strcat('Var',num2str(2));
    var_rename=strcat('Neur',num2str(0));
    neur_data=renamevars(neur_data, var_num, var_rename);
end

% extract neurite data and get baseline
data=[data neur_data(:, 2:end)];
Neur0=table2array(data(:,"Neur0"));
hh=1;

%normalise neurite data to baseline
if numel(num_timepoints)>1
    for y=2:numel(num_timepoints)
        neur_timepoint=table2array(neur_data(:,y+1));
        [data]=neur_norms(data, neur_timepoint, Neur0, hh, num_timepoints);
        hh=hh+1;
    end
end

%initiating counters
aa=1; bb=1; cc=1; dd=1; ee=1; eee=1; ff=1; gg=1; hh=1; ii=1; jj=1; kk=1;
ll=1; mm=1; nn=1; g=1; h=1; i=1; j=1; k=1; l=1; m=1; mm=1; o=1; p=1; q=1;
qq=1; r=1; s=1; t=1; u=1; v=1; w=1; x=1; y=1;
num_conditions=0;

% asigns correct treatment to cells
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
iqr_Neur0=iqr(Neur0);
upq_Neur0=quantile(Neur0, 0.75);
lowq_Neur0=quantile(Neur0, 0.25);


% create list to variable names for the outliers table
aa=1;
variables=string(varfun(@class,data,'OutputFormat','cell'));
variables=[variables "cell"];
for b=1:numel(variables)
    if variables(b)=='cell'
        variables(b)='string';
    end
end

% initialise outlier table with reason column, remove outliers based on +/-
% 1.5*IQR
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
    elseif (olddata2(d,2*numel(num_timepoints)) > upq_Neur0+(1.5*iqr_Neur0))
        removed_outliers_T0(aa,:)=data(d,:);
        removed_outliers_T0(aa, end)= {['Neur0 > ' num2str(lowq_Neur0+(1.5*iqr_Neur0))]};
        aa=aa+1;
   elseif (olddata2(d,2*numel(num_timepoints)) < lowq_BFP0-(1.5*iqr_Neur0))
        removed_outliers_T0(aa,:)=data(d,:);
        removed_outliers_T0(aa, end)= {['Neur0 < ' num2str(lowq_Neur0-(1.5*iqr_Neur0))]};
        aa=aa+1;
    end
end

%change removed_outliers to the function specific for your experiment/plate
outliers=removed_outliers_T0;
for z=1:numel(treats_combined)
    TR=treats_combined(z);
    [new_outliers]=removed_outliers_in_progress(data, TR, variables, condition, num_timepoints);
    [neur_outliers]=removed_outliers_neur_in_progress(data, TR, variables, condition, num_timepoints);
    outliers=[outliers;new_outliers;neur_outliers];
end

%rename outliers and save excel
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

% calculates Z prime for plate if option selected above
if options.zprime=="true"
    c=1;
    k=1;
    for g=1:height(data)
        if contains(string(table2array((data(g,"treatment")))), string(neg_control))
            neg_ctrl(c,:)=data(g,:);
            c=c+1;
        elseif contains(string(table2array((data(g,"treatment")))), string(pos_control))
            pos_ctrl(k,:)=data(g,:);
            k=k+1;
        end
    end 
    z_vars=repmat("double", 1, numel(num_timepoints)-1);
    row_names=[];

    for h=1:numel(num_timepoints)-1
        row_names=[row_names strcat("T", num2str(h))];
    end

    z_prime=table('Size',[numel(num_timepoints)-1 2], 'VariableTypes',z_vars, 'VariableNames', ["normBFP" "normNeurite"],'RowNames',row_names);
    
    for jj=1:numel(num_timepoints)-1
        pos_BFP_ave=mean(table2array(pos_ctrl(:,strcat('normBFP', num2str(jj)))));
        pos_neur_ave=mean(table2array(pos_ctrl(:,strcat('normNeur',num2str(jj)))));
        pos_BFP_stdev=std(table2array(pos_ctrl(:, strcat('normBFP',num2str(jj)))));
        pos_neur_stdev=std(table2array(pos_ctrl(:, strcat('normNeur',num2str(jj)))));
        neg_BFP_ave=mean(table2array(neg_ctrl(:,strcat('normBFP', num2str(jj)))));
        neg_neur_ave=mean(table2array(neg_ctrl(:,strcat('normNeur',num2str(jj)))));
        neg_BFP_stdev=std(table2array(neg_ctrl(:, strcat('normBFP',num2str(jj)))));
        neg_neur_stdev=std(table2array(neg_ctrl(:, strcat('normNeur',num2str(jj)))));
        pos_BFP_threshold=pos_BFP_ave-3*pos_BFP_stdev;
        pos_neur_threshold=pos_neur_ave-3*pos_neur_stdev;
        neg_BFP_threshold=neg_BFP_ave+3*neg_BFP_stdev;
        neg_neur_threshold=neg_neur_ave+3*neg_neur_stdev;
        BFP_sep=pos_BFP_threshold-neg_BFP_threshold;
        neur_sep=pos_neur_threshold-neg_neur_threshold;
        BFP_dynamic=pos_BFP_ave-neg_BFP_ave;
        neur_dynamic=pos_neur_ave-neg_neur_ave;
        z_BFP=BFP_sep/BFP_dynamic;
        z_neur=neur_sep/neur_dynamic;
        z_prime(jj,1)={z_BFP};
        z_prime(jj,2)={z_neur};
    end
writetable(z_prime, sorted_data_path,'Sheet',2);
end

if numel(num_timepoints)==0
    time=array2table(repmat(timepoints(1),height(data),1));
    for n=1:height(data)
        timedata((n), "Var1")=time(n, "Var1");
        for g=1:numel(condition)
            timedata((n),strcat("Var", string(g+1)))=data(n, 1+g);
        end 
        timedata((n), strcat("Var", string(numel(condition)+2)))=data(n,num_variables+1);
        timedata((n), strcat("Var", string(numel(condition)+4)))=data(n,num_variables+2*numel(num_timepoints));
    end
end

% create timecourse table for plotting each well over time
for kk=1:numel(num_timepoints)
    time=array2table(repmat(timepoints(kk),height(data),1));
    for n=1:height(data)
        timedata((((kk-1)*height(data))+n), "Var1")=time(n, "Var1");
        for g=1:numel(condition)
            timedata((((kk-1)*height(data))+n),strcat("Var", string(g+1)))=data(n, 1+g);
        end 
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+2)))=data(n,num_variables+kk+1);
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+4)))=data(n,num_variables+kk+2*numel(num_timepoints));
        if kk==1
            timedata((((kk-1)*height(data))+n),strcat("Var", string(numel(condition)+3)))={100};
            timedata((((kk-1)*height(data))+n),strcat("Var", string(numel(condition)+5)))={100};
        else
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+3)))=data(n, num_variables+kk+numel(num_timepoints)); 
        timedata((((kk-1)*height(data))+n), strcat("Var", string(numel(condition)+5)))=data(n, num_variables+kk+3*numel(num_timepoints)-1); 
        end
    end
end
old_vars=[];
for hh=1:numel(condition)+5
    old_vars=[old_vars strcat("Var", string(hh))];
end 
new_vars=["Time",[condition],"BFP","normBFP","Neur","normNeur"];
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

%% choose what graphs you want below and include whatever controls you want%%

% DMSO_ctrl=strcmp(data.treatment, 'DMSO');
% BTZ_ctrl=strcmp(data.treatment, '5nM BTZ');
% Digoxin_1=logical(contains(data.treatment,'Digoxin'));
% Digoxin_2=logical(DMSO_ctrl+Digoxin_1+BTZ_ctrl);
% Pif_1=logical(contains(data.treatment,'Pifithrin-a'));
% Pif_2=logical(DMSO_ctrl+BTZ_ctrl+Pif_1);
% Trip_1=logical(contains(data.treatment,'Triptolide'));
% Trip_2=logical(DMSO_ctrl+BTZ_ctrl+Trip_1);
% 
% DMSO_ctrl_t=strcmp(timedata.treatment, 'DMSO');
% BTZ_ctrl_t=strcmp(timedata.treatment, '5nM BTZ');
% Digoxin_1_t=logical(contains(timedata.treatment,'Digoxin'));
% Digoxin_2_t=logical(DMSO_ctrl_t+Digoxin_1_t+BTZ_ctrl_t);
% Pif_1_t=logical(contains(timedata.treatment,'Pifithrin-a'));
% Pif_2_t=logical(DMSO_ctrl_t+BTZ_ctrl_t+Pif_1_t);
% Trip_1_t=logical(contains(timedata.treatment,'Triptolide'));
% Trip_2_t=logical(DMSO_ctrl_t+BTZ_ctrl_t+Trip_1_t);


g24BFP=gramm('x',data.treatment,'y',data.BFP1,'color',data.treatment);
g24BFP.stat_boxplot('width',2);
g24BFP.axe_property('XTickLabelRotation',22);
g24BFP.set_order_options('x',order);
g24BFP.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g24BFP.set_title('Cell Count at 24 Hours', 'FontSize',44)
g24BFP.set_names('x','Treatment','y', 'Cell Count (Segmented BFP)');
g24BFP.set_text_options('font','Arial','base_size',40);
g24BFP.no_legend();
figure
g24BFP.draw();
set([g24BFP.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g24BFP.export('file_name','g24BFPnorm','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

g48BFP=gramm('x',data.treatment,'y',data.BFP2,'color',data.treatment);
g48BFP.stat_boxplot('width',2);
g48BFP.axe_property('XTickLabelRotation',20);
g48BFP.set_order_options('x',order);
g48BFP.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g48BFP.set_title('Cell Count at 48 Hours', 'FontSize',44)
g48BFP.set_names('x','Treatment','y', 'Cell Count (Segmented BFP)');
g48BFP.set_text_options('font','Arial','base_size',40);
g48BFP.no_legend();
figure
g48BFP.draw();
set([g48BFP.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g48BFP.export('file_name','g48BFPnorm','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

g24BFPnorm=gramm('x',data.treatment,'y',data.normBFP1,'color',data.treatment);
g24BFPnorm.stat_boxplot('width',2);
g24BFPnorm.axe_property('XTickLabelRotation',20);
g24BFPnorm.set_order_options('x',order);
g24BFPnorm.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g24BFPnorm.set_title('Normalized Cell Count at 24 Hours', 'FontSize',44)
g24BFPnorm.set_names('x','Treatment','y', 'Percent Survival');
g24BFPnorm.set_text_options('font','Arial','base_size',40);
g24BFPnorm.axe_property('YGrid','on','YTick',[0 20 40 60 80 100],'PlotBoxAspectRatio', [0.2 0.2 1]);
g24BFPnorm.no_legend();
figure
g24BFPnorm.draw();
set([g24BFPnorm.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g24BFPnorm.export('file_name','g24BFPnorm','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

g48BFPnorm=gramm('x',data.treatment,'y',data.normBFP2,'color',data.treatment);
g48BFPnorm.stat_boxplot('width',2);
g48BFPnorm.axe_property('XTickLabelRotation',20);
g48BFPnorm.set_order_options('x',order);
g48BFPnorm.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g48BFPnorm.set_title('Normalized Cell Count at 48 Hours', 'FontSize',44)
g48BFPnorm.set_names('x','Treatment','y', 'Percent Survival');
g48BFPnorm.set_text_options('font','Arial','base_size',40);
g48BFPnorm.axe_property('YGrid','on','YTick',[0 20 40 60 80 100],'PlotBoxAspectRatio', [0.2 0.2 1]);
g48BFPnorm.set_layout_options('redraw',0.04);
g48BFPnorm.no_legend();
figure
g48BFPnorm.draw();
set([g48BFPnorm.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g48BFPnorm.export('file_name','g48BFPnorm','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

g24Neur=gramm('x',data.treatment,'y',data.Neur1,'color',data.treatment);
g24Neur.stat_boxplot('width',2);
g24Neur.axe_property('XTickLabelRotation',20);
g24Neur.set_order_options('x',order);
g24Neur.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g24Neur.set_title('Neurite Outgrowth at 24 Hours', 'FontSize',44)
g24Neur.set_names('x','Treatment','y', 'Neurite Area');
g24Neur.set_text_options('font','Arial','base_size',40);
g24Neur.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1]);
g24Neur.set_layout_options('redraw',0.04);
g24Neur.no_legend();
figure
g24Neur.draw();
set([g24Neur.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g24Neur.export('file_name','g24Neur','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);


g48Neur=gramm('x',data.treatment,'y',data.Neur2,'color',data.treatment);
g48Neur.stat_boxplot('width',2);
g48Neur.axe_property('XTickLabelRotation',20);
g48Neur.set_order_options('x',order);
g48Neur.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g48Neur.set_title('Neurite Outgrowth at 48 Hours', 'FontSize',44)
g48Neur.set_names('x','Treatment','y', 'Neurite Area');
g48Neur.set_text_options('font','Arial','base_size',40);
g48Neur.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1]);
g48Neur.set_layout_options('redraw',0.04);
g48Neur.no_legend();
figure
g48Neur.draw();
set([g48Neur.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g48Neur.export('file_name','g48Neur','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);


g24Neurnorm=gramm('x',data.treatment,'y',data.normNeur1,'color',data.treatment);
g24Neurnorm.stat_boxplot('width',2);
g24Neurnorm.axe_property('XTickLabelRotation',20);
g24Neurnorm.set_order_options('x',order);
g24Neurnorm.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g24Neurnorm.set_title('Change in Outgrowth at 24 Hours', 'FontSize',44)
g24Neurnorm.set_names('x','Treatment','y', '% of Initial Neurite');
g24Neurnorm.set_text_options('font','Arial','base_size',40);
g24Neurnorm.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1]);
g24Neurnorm.set_layout_options('redraw',0.04);
g24Neurnorm.no_legend();
figure
g24Neurnorm.draw();
set([g24Neurnorm.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g24Neurnorm.export('file_name','g24Neurnorm','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);


g48Neurnorm=gramm('x',data.treatment,'y',data.normNeur2,'color',data.treatment);
g48Neurnorm.stat_boxplot('width',5);
g48Neurnorm.axe_property('XTickLabelRotation',20);
g48Neurnorm.set_order_options('x',order,'color',0);
g48Neurnorm.set_color_options('map',n_color_dec);
g48Neurnorm.set_color_options('hue_range',[200 300],'chroma',30,'lightness',65);
%g24BFP.set_continuous_color('LCH_colormap',[20 80 ; 40 30 ; 260 260 ]);
g48Neurnorm.set_title('Change in Outgrowth Outgrowth at 48 Hours', 'FontSize',44)
g48Neurnorm.set_names('x','Treatment','y', '% of Initial Neurite');
g48Neurnorm.set_text_options('font','Arial','base_size',20);
g48Neurnorm.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1]);
g48Neurnorm.set_layout_options('redraw',0.04);
g48Neurnorm.no_legend();
figure
g48Neurnorm.draw();
set([g48Neurnorm.results.stat_boxplot.box_handle],'FaceAlpha',0.4);
g48Neurnorm.export('file_name','g48Neurnrom','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

gBFPtimecourse=gramm('x', timedata.Time, 'y', timedata.BFP,'color', timedata.treatment);
gBFPtimecourse.geom_label();
gBFPtimecourse.stat_summary('type','std');
gBFPtimecourse.set_order_options('x',order);
gBFPtimecourse.set_color_options('hue_range', [70 210], 'chroma', 40, 'lightness',60);
gBFPtimecourse.set_title('Cell Count Over Time', 'FontSize',44);
gBFPtimecourse.set_names('x', 'Time (Hours)','y','Cell Count (Segmented BFP)', 'Color', 'Treatment');
gBFPtimecourse.set_text_options('font','Arial','base_size',36,'legend_scaling',0.4,'label_scaling',0.8,'legend_title_scaling',0.5);
gBFPtimecourse.set_layout_options('legend_width',0.02,'legend_pos',[0.75 0.40 0.2 0.3]);
gBFPtimecourse.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1],'XTick',[0 24 48]);
figure
gBFPtimecourse.draw();
gBFPtimecourse.export('file_name','gBFPtimecourse','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

gBFPnormtimecourse=gramm('x', timedata.Time, 'y', timedata.normBFP,'color', timedata.treatment);
gBFPnormtimecourse.geom_label();
gBFPnormtimecourse.stat_summary('type','std');
gBFPnormtimecourse.set_order_options('x',order,'color',0);
gBFPnormtimecourse.set_color_options('map',n_color_dec);
gBFPnormtimecourse.set_title('% Survival Over Time (Segmented BFP)', 'FontSize',38);
gBFPnormtimecourse.set_names('x', 'Time (Hours)','y','% Original Cell Count', 'Color', 'Treatment');
gBFPnormtimecourse.set_text_options('font','Arial','base_size',36,'legend_scaling',0.4,'label_scaling',0.8,'legend_title_scaling',0.5);
gBFPnormtimecourse.set_layout_options('legend_width',0.02,'legend_pos',[0.76 0.40 0.2 0.3]);
gBFPnormtimecourse.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1],'XTick',[0 24 48]);
figure
gBFPnormtimecourse.draw();
gBFPnormtimecourse.export('file_name','gBFPnormtimecourse_Pifithrin','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

gNeurtimecourse=gramm('x', timedata.Time, 'y', timedata.Neur,'color', timedata.treatment);
gNeurtimecourse.geom_label();
gNeurtimecourse.stat_summary('type','std');
gNeurtimecourse.set_order_options('x',order);
gNeurtimecourse.set_color_options('hue_range', [70 210], 'chroma', 40, 'lightness',60);
gNeurtimecourse.set_title('Neurite Outgrowth Over Time', 'FontSize',40);
gNeurtimecourse.set_names('x', 'Time (Hours)','y','Neurite Area', 'Color', 'Treatment');
gNeurtimecourse.set_text_options('font','Arial','base_size',18,'legend_scaling',1,'label_scaling',2.5,'legend_title_scaling',1.5);
gNeurtimecourse.set_layout_options('legend_width',0.02,'legend_pos',[0.75 0.25 0.2 0.6]);
gNeurtimecourse.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1],'XTick',[0 24 48]);
figure
gNeurtimecourse.draw();
gNeurtimecourse.export('file_name','gNeurtimecourse','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);

% n_color =   [255     0     255
%              255     165     0
%              173     228     249
%              51     189     242
%              12     155     176
%              20     106     201
%               56     20     216
%               91     13     174];
% 
% n_color_dec=n_color/255


gNeurtimecoursenorm=gramm('x', timedata.Time, 'y', timedata.normNeur,'color', timedata.treatment);
gNeurtimecoursenorm.geom_label();
gNeurtimecoursenorm.stat_summary('type','std');
gNeurtimecoursenorm.set_order_options('x',order,'color',0);
gNeurtimecourse.set_color_options('hue_range', [70 210], 'chroma', 40, 'lightness',60);
gNeurtimecoursenorm.set_title('Change in Neurite Outgrowth Over Time', 'FontSize',40);
gNeurtimecoursenorm.set_names('x', 'Time (Hours)','y','% Initial Neurite Area', 'Color', 'Treatment');
gNeurtimecoursenorm.set_text_options('font','Arial','base_size',18,'legend_scaling',1,'label_scaling',2.5,'legend_title_scaling',1.5);
gNeurtimecoursenorm.set_layout_options('legend_width',0.02,'legend_pos',[0.75 0.25 0.2 0.6]);
gNeurtimecoursenorm.axe_property('YGrid','on','PlotBoxAspectRatio', [0.2 0.2 1],'XTick',[0 24 48]);
figure
gNeurtimecoursenorm.draw();
gNeurtimecoursenorm.export('file_name','gNeurtimecourseNorm_Pifithrin','export_path',export_path, ...
    'file_type','pdf','width',30, 'height',30);
