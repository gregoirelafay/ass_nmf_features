function [config, store, obs] = asnmfe2norm(config, setting, data)                     
% asnmfe2norm NORM step of the expLanes experiment ass_nmf_features                    
%    [config, store, obs] = asnmfe2norm(config, setting, data)                         
%      - config : expLanes configuration state                                         
%      - setting   : set of factors to be evaluated                                    
%      - data   : processing data stored during the previous step                      
%      -- store  : processing data to be saved for the other steps                     
%      -- obs    : observations to be saved for analysis                               
                                                                                       
% Copyright: <userName>                                                                
% Date: 11-Jun-2016                                                                    
                                                                                       
% Set behavior for debug mode                                                          
if nargin==0, ass_nmf_features('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                       
%%  merge features

X=[];
soundIndex=[];

for jj=1:length(data)
    eval(['X=[X  data(jj).features.' setting.features '];']);
    eval(['soundIndex=[soundIndex ones(1,size(data(jj).features.' setting.features ',2))*data(jj).xp_settings.soundIndex];']);
    if data(jj).xp_settings.soundIndex==setting.soundIndex2
        store.xp_settings=data(jj).xp_settings;
        store.class=data(jj).class;
    end
end
clearvars data

%% features normalization

params.type=setting.ftrsNorm1;
[X,store.xp_settings.ftrsNorm] = normFtrs(X,params);


switch setting.features
    case {'mfcc','mfccD1','cqt'}
        params.type=setting.ftrsNorm2;
    case {'scattering','scatteringJoint'}
        params.type='scattering';
        params.ftrsNorm_scat_selection =  setting.ftrsNorm_scat_selection;
        params.ftrsNorm_scat_threshold = setting.ftrsNorm_scat_threshold;
end

[X,~] = normFtrs(X,params);

%% features selection

params.type=setting.ftrsSel;
[X,store.xp_settings.ftrsSel] = featuresSelection(X,params);

%% store

store.features=X(:,soundIndex==setting.soundIndex2);