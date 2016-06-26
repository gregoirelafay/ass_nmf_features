function [config, store, obs] = asnmfe8metrics(config, setting, data)                  
% asnmfe8metrics METRICS step of the expLanes experiment ass_nmf_features              
%    [config, store, obs] = asnmfe8metrics(config, setting, data)                      
%      - config : expLanes configuration state                                         
%      - setting   : set of factors to be evaluated                                    
%      - data   : processing data stored during the previous step                      
%      -- store  : processing data to be saved for the other steps                     
%      -- obs    : observations to be saved for analysis                               
                                                                                       
% Copyright: <userName>                                                                
% Date: 11-Jun-2016                                                                    
                                                                                       
% Set behavior for debug mode                                                          
if nargin==0, ass_nmf_features('do', 8, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                       
D=1-data.A;

rm = rankingMetrics(D, data.class,3);
obs.pa3=rm.precisionAt3;
obs.map=rm.meanAveragePrecision;
rm = rankingMetrics(D, data.class,5);
obs.pa5=rm.precisionAt5;

switch setting.dataset
    case {'train','test'}
        rm = rankingMetrics(D, data.class,9);
        obs.pa9=rm.precisionAt9;
    case 'all'
        rm = rankingMetrics(D, data.class,19);
        obs.pa19=rm.precisionAt19;
end