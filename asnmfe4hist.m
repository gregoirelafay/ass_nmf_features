function [config, store, obs] = asnmfe4hist(config, setting, data)
% asnmfe3nmf NMF step of the expLanes experiment ass_nmf_features
%    [config, store, obs] = asnmfe3nmf(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: <userName>
% Date: 11-Jun-2016

% Set behavior for debug mode
dataset=2;
features =3;
framing_short=4;
framing_long=3;
preemph=1;
freqRange=2;

ftrsNorm=1;
ftrsNorm_scat_selection=11;
ftrsNorm_scat_threshold=2;
ftrsNorm_scat_norm=4;
ftrsSel=1;

sourceSep=3;
nRank=2;
weighting=0;

cluster_sel=1;
similarity=3;
similarity_nn=1;
similarity_thresh=4;
similarity_dist=1;

%% 100 scenes
% Set behavior for debug mode

if nargin==0, ass_nmf_features('do',3, 'mask', {...
        dataset 1 ...
        features framing_short framing_long preemph freqRange...
        ftrsNorm ftrsNorm_scat_selection ftrsNorm_scat_threshold ftrsNorm_scat_norm ftrsSel 1 ...
        [1 2 3] nRank weighting...
        cluster_sel ...
        similarity [1 4 6] [2 4] similarity_dist}); return; else store=[]; obs=[]; end



%% store

store.xp_settings=data.xp_settings;

%% weight

switch setting.weighting
    case 'full'
        
        store.weight=sum(data.prediction,2);
        
    case 'clustering'
        
        [~,data.prediction]=max(data.prediction,[],1);
        params.histType='';
        params.nbc=setting.nRank;
        [store.weight] = histFeatures(data.prediction,ones(1,length(data.prediction)),params);
        
end

store.weight=store.weight/sum(store.weight);
