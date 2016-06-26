function config = asnmfeReport(config)
% asnmfeReport REPORTING of the expLanes experiment ass_nmf_features
%    config = asnmfeInitReport(config)
%       config : expLanes configuration state

% Copyright: <userName>
% Date: 11-Jun-2016

if nargin==0, ass_nmf_features('report', 'rcv'); return; end

framing_short=4;
framing_long=3;

preemph=1;
freqRange=2;

ftrsNorm1=1;
ftrsNorm2 =1;
ftrsNorm_scat_selection=11;
ftrsNorm_scat_threshold=2;

ftrsSel=2;

sourceSep=1;
nRank=0;
weighting=0;

cluster_norm=1;
cluster_sel=0;
similarity=3;
similarity_nn=0;
similarity_thresh=0;

similarity_dist =1;

%% factor

datasetV = {'all','train','test'};
featuresV = {'mel','cqt','scattering','scatteringJoint'};
ftrsNorm1V = {'null','stand','L1','L2'};
sourceSepV = {'nmf_beta','nmf_euc_sparse_es','nmfbpas','sparsenmf2rule'};
weightingV = {'full','clustering'};
cluster_normV = {'null','stand','L1','L2'};
cluster_selV =  {'null','pca_90'};


%% scattering

dataset=2;
features =3;

for ii=[1 4] % ftrsNorm1
    for aa=[1 2] % cluster_sel
        for bb=[1 2] % weighting
            for cc=[1 2 4] % cluster_norm
                
                nameOfTable= ['ass_nmf_' datasetV{dataset} featuresV{features} ftrsNorm1V{ii} sourceSepV{sourceSep} weightingV{bb} cluster_normV{cc} cluster_selV{aa}];
                
                config = expExpose(config, 't','fontSize','scriptsize','step',8, 'mask', {...
                    dataset 1:100 ...
                    features framing_short 3 preemph freqRange...
                    ii [1 2] ftrsNorm_scat_selection ftrsNorm_scat_threshold ...
                    ftrsSel 1:100 ...
                    sourceSep nRank bb...
                    cc aa ...
                    similarity [1 3 5] [1 2 4] similarity_dist},'obs',[1 2 3 4],'precision', 2,'save',1,'name',nameOfTable);
            end
        end
    end
end

