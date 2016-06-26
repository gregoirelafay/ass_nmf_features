function [config, store] = asnmfeInit(config)                          
% asnmfeInit INITIALIZATION of the expLanes experiment ass_nmf_features
%    [config, store] = asnmfeInit(config)                              
%      - config : expLanes configuration state                         
%      -- store  : processing data to be saved for the other steps     
                                                                       
% Copyright: <userName>                                                
% Date: 11-Jun-2016                                                    
                                                                       
if nargin==0, ass_nmf_features(); return; else store=[];  end          
