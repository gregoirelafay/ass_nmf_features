function [config, store, obs] = asnmfe3nmf(config, setting, data)
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

%% seed

rng(0);

%% store

store.xp_settings=data.xp_settings;
store.class=data.class;

visu=0;
data.features(data.features<0)=eps;

%% test kmeans

if visu
    kmeans_params.clustering='kmeans';
    kmeans_params.similarity='sqeuclidean';
    kmeans_params.nbc=setting.nRank;
    kmeans_params.emptyAction='singleton';
    [kmeans_prediction,kmeans_centroid,~] = featuresBasedClustering(data.features,kmeans_params);
    kmeans_prediction=kmeans_prediction';
    kmeans_params.histType='';
    kmeans_params.nbc=size(kmeans_centroid,2);
    [weight] = histFeatures(kmeans_prediction,ones(1,length(kmeans_prediction)),kmeans_params);
    weight=weight'/sum(weight);
end
%% scene features

params.sourceSep=setting.sourceSep;
params.nRank=setting.nRank;
params.nIter=500;
params.nRun=5;
bestErrs=inf;

switch params.sourceSep
    case 'nmf_euc_sparse_es'
        params.alpha=mean(data.features(:));
    case 'nmfbpas'
        params.alpha=0;
    case 'sparsenmf2rule'
        option.dis=false;
        option.iter=params.nIter;
end

for ii=1:params.nRun;
    
    switch params.sourceSep
        case 'nmf_beta'
            
            [W,H,errs,~] = nmf_beta(data.features,params.nRank,'W0',[],'H0',[],'norm_w',0,'norm_h',0,'beta',2,'niter',params.nIter);
            
        case 'nmf_euc_sparse_es'
            
            [W,H,errs,~] = nmf_euc_sparse_es(data.features,params.nRank,'W0',[],'H0',[],'norm_w',1,'norm_h',1,'niter',params.nIter,'alpha',params.alpha);
            
        case 'nmfbpas'
            
            H0 = rand(params.nRank,size(data.features,2));
            W0 = rand(size(data.features,1),params.nRank);
            [W,H,~,~,finalLog]=nmf(data.features,params.nRank,'type','sparse','ALPHA',params.alpha,'MAX_ITER',params.nIter,'W_INIT',W0,'H_INIT',H0,'TOL',1e-4);
            errs=finalLog.relative_error;
            
        case 'sparsenmf2rule'
            
            [W,H,~,~,errs]=sparsenmf2rule(data.features,params.nRank,option);
            
    end
    
    if errs(end)<bestErrs
        bestErrs=errs(end);
        store.centroid=W;
        prediction=H;
    end
end

store.prediction=prediction./sum(prediction(:));
store.params=params;

%% visu

if visu
    
    [~,nmf_prediction]=max(prediction,[],1);
    
    figure(1)
    subplot 411
    imagesc(data.features)
    title(['features; ' params.sourceSep],'interpreter','none')
    xlabel('time')
    subplot 412
    imagesc(store.centroid)
    title('W (Dic)')
    subplot 413
    imagesc(prediction)
    title('H (activation)')
    subplot 414
    bar(sum(prediction,2))
    title('hist')
    axis tight
    ylim([0 max(sum(prediction,2))+0.1])
    disp('')
    
    figure(2)
    subplot 411
    imagesc(data.features)
    title('features')
    xlabel('time')
    subplot 412
    imagesc([kmeans_prediction;nmf_prediction])
    title('Prediction')
    set(gca,'ytick',[1 2],'yticklabel',{'kmeans','nmf'})
    subplot 413
    imagesc(kmeans_centroid)
    title('Centroids')
    subplot 414
    bar(weight)
    title('hist')
    axis tight
    ylim([0 max(weight)+0.1])
    disp('')
end