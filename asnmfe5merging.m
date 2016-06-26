function [config, store, obs] = asnmfe5merging(config, setting, data)                  
% asnmfe5merging MERGING step of the expLanes experiment ass_nmf_features              
%    [config, store, obs] = asnmfe5merging(config, setting, data)                      
%      - config : expLanes configuration state                                         
%      - setting   : set of factors to be evaluated                                    
%      - data   : processing data stored during the previous step                      
%      -- store  : processing data to be saved for the other steps                     
%      -- obs    : observations to be saved for analysis                               
                                                                                       
% Copyright: <userName>                                                                
% Date: 11-Jun-2016                                                                    
                                                                                       
% Set behavior for debug mode                                                          
if nargin==0, ass_nmf_features('do', 5, 'mask', {2 0 3 0 2 1 0 0 11 2 1 0 2 2 3 2 0 0 0 0 0}); return; else store=[]; obs=[]; end
 
%% store

store.xp_settings=data(1).xp_settings;

%% load

data_step3 = expLoad(config, [], 3,'data', [], 'data');

if length(data)~=length(data_step3)
   error('data and data step3 are not equal') 
end

%% manage index

data_step3_si=zeros(1,length(data));
data_si=zeros(1,length(data));

for jj=1:length(data)
    data_step3_si(jj)=data_step3(jj).xp_settings.soundIndex;
    data_si(jj)=data(jj).xp_settings.soundIndex;
end

[~,ind_data_step3]=sort(data_step3_si,'ascend');
[~,ind_data]=sort(data_si,'ascend');

%% data step_3

store.class=[];
store.indSample=[];
store.centroid=[];
store.centroidClass=[];

for jj=1:length(ind_data_step3)
    % data
    store.class(jj)=unique(data_step3(ind_data_step3(jj)).class);
    store.indSample=[store.indSample ones(1,size(data_step3(ind_data_step3(jj)).centroid,2))*jj];
    store.centroid=[store.centroid data_step3(ind_data_step3(jj)).centroid];
    store.centroidClass=[store.centroidClass ones(1,size(data_step3(ind_data_step3(jj)).centroid,2))*store.class(jj)];
end

clearvars data_step3

%% data hist

data=data(ind_data);

store.weight=zeros(length(store.indSample),length(data));

[onsets,offsets]=getOnsetsOffsets(store.indSample,[]);

for jj=1:length(onsets)
    store.weight(onsets(jj):offsets(jj),jj)=data(jj).weight;
end

store.weight=sparse(store.weight);

disp('')