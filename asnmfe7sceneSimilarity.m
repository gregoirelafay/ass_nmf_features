function [config, store, obs] = asnmfe7sceneSimilarity(config, setting, data)            
% asnmfe7sceneSimilarity SCENESIMILARITY step of the expLanes experiment ass_nmf_features
%    [config, store, obs] = asnmfe7sceneSimilarity(config, setting, data)                
%      - config : expLanes configuration state                                           
%      - setting   : set of factors to be evaluated                                      
%      - data   : processing data stored during the previous step                        
%      -- store  : processing data to be saved for the other steps                       
%      -- obs    : observations to be saved for analysis                                 
                                                                                         
% Copyright: <userName>                                                                  
% Date: 11-Jun-2016                                                                      
                                                                                         
% Set behavior for debug mode                                                            
if nargin==0, ass_nmf_features('do', 7, 'mask', {2 0 1 1 2 1 4 2 0 0 1 0 1 1 2 3 2 4 5}); return; else store=[]; obs=[]; end  
                                                                                         
%% store

store.class=data.class;
store.indSample=data.indSample;

%% similarity

params.histDist=setting.similarity_dist;
params.indSample=store.indSample;
[store.A,store.params] = histSimilarity(full(data.weight),params,data.simClus);