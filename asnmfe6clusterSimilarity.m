function [config, store, obs] = asnmfe6clusterSimilarity(config, setting, data)              
% asnmfe6clusterSimilarity CLUSTERSIMILARITY step of the expLanes experiment ass_nmf_features
%    [config, store, obs] = asnmfe6clusterSimilarity(config, setting, data)                  
%      - config : expLanes configuration state                                               
%      - setting   : set of factors to be evaluated                                          
%      - data   : processing data stored during the previous step                            
%      -- store  : processing data to be saved for the other steps                           
%      -- obs    : observations to be saved for analysis                                     
                                                                                             
% Copyright: <userName>                                                                      
% Date: 11-Jun-2016                                                                          
                                                                                             
% Set behavior for debug mode                                                                
if nargin==0, ass_nmf_features('do', 6, 'mask', {2 0 1 1 2 1 4 2 0 0 1 0 1 1 2 3 2 4 5}); return; else store=[]; obs=[]; end      
                                                                                             
%% store

store.xp_settings=data.xp_settings;
store.class=data.class;
store.weight=data.weight;
store.indSample=data.indSample;

%% clusters norm

params.type=setting.cluster_norm;
[data.centroid,~] = normFtrs(data.centroid,params);

%% clusters selection

params.type=setting.cluster_sel;
[data.centroid,~] = featuresSelection(data.centroid,params);

%% get clusters Similarity

params.mode='centroid';
params.similarity=setting.similarity;
params.nn=setting.similarity_nn;
params.similarity_thresh=setting.similarity_thresh;
params.class=data.centroidClass;
params.normalizedCut=0;
params.order=0;

store.simClus=clusterSimilarity(data.centroid,[],params);
