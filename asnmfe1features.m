function [config, store, obs] = asnmfe1features(config, setting, data)                 
% asnmfe1features FEATURES step of the expLanes experiment ass_nmf_features            
%    [config, store, obs] = asnmfe1features(config, setting, data)                     
%      - config : expLanes configuration state                                         
%      - setting   : set of factors to be evaluated                                    
%      - data   : processing data stored during the previous step                      
%      -- store  : processing data to be saved for the other steps                     
%      -- obs    : observations to be saved for analysis                               
                                                                                       
% Copyright: <userName>                                                                
% Date: 11-Jun-2016                                                                    

framing_short=4;
framing_long=3;

preemph=1;
freqRange=2;

ftrsNorm1=1;
ftrsNorm2 =1;
ftrsNorm_scat_selection=11;
ftrsNorm_scat_threshold=2;

ftrsSel=2;

sourceSep=3;
nRank=0;
weighting=0;

cluster_norm=1;
cluster_sel=0;
similarity=3; 
similarity_nn=0;
similarity_thresh=0;

similarity_dist =1;

%% 100 scenes
% scattering

dataset=2;
features =3;

if nargin==0, ass_nmf_features('do',1:8, 'mask', {...
       dataset 1:100 ...
       features framing_short [2 3] preemph freqRange...
       [1 4] [1 2] ftrsNorm_scat_selection ftrsNorm_scat_threshold ...
       ftrsSel 1:100 ...
       sourceSep nRank weighting...
       [1 2 4] cluster_sel ...
       similarity [1 3 5] [1 2 4] similarity_dist}); return; else store=[]; obs=[]; end
                                                                                       
%% check sound index

switch setting.dataset
    case {'train','test'}
        if setting.soundIndex >100
            error('too many sound index')
        end
end

%% setting

switch setting.features
    case {'mel','cqt'}
        f=strsplit(setting.framing_short,'_');
    case {'scattering','scatteringJoint'}
        f=strsplit(setting.framing_long,'_');
    otherwise 
        error('wrong features setting')
end
    
store.xp_settings.hoptime = str2double(strrep(f{1},',','.'));
store.xp_settings.wintime = str2double(strrep(f{2},',','.'));

store.xp_settings.sr=44100;
store.xp_settings.classes = {'bus','busystreet','office','openairmarket','park','quietstreet','restaurant','supermarket','tube','tubestation'};
store.xp_settings.datasetPath='environment/dcase/scenes/';


%% setting features

store.xp_settings.preemph=setting.preemph;

switch setting.features,
    case {'scattering','scatteringJoint'}
        store.xp_settings.minFreq=0;
        store.xp_settings.maxFreq=store.xp_settings.sr/2;
    otherwise
        store.xp_settings.cqtNbBins=20;
        store.xp_settings.melBand=40;
        freqRange=strsplit(setting.freqRange,'_');
        store.xp_settings.minFreq=str2double(strrep(freqRange{1},',','.'));
        store.xp_settings.maxFreq=str2double(strrep(freqRange{2},',','.'));
end

%% setting scattering

if any(strcmp(setting.features,{'scattering','scatteringJoint'}))
    
    scat.N = 2^(nextpow2(store.xp_settings.sr*store.xp_settings.wintime )-1);
    scat.Q=8;
    scat.octave_bounds = [2 8];
    scat.nfo = 12;
    scat.gamma_bounds = [(scat.octave_bounds(1)-1)*scat.nfo scat.octave_bounds(2)*scat.nfo-1];
    
    scat.opts{1}.banks.time.nFilters_per_octave = scat.nfo;
    scat.opts{1}.banks.time.size = scat.N;
    scat.opts{1}.banks.time.T = scat.N;
    scat.opts{1}.banks.is_chunked = false;
    scat.opts{1}.banks.gamma_bounds = scat.gamma_bounds;
    scat.opts{1}.banks.wavelet_handle = @gammatone_1d;
    scat.opts{1}.invariants.time.invariance = 'summed';
    scat.opts{2}.banks.time.nFilters_per_octave = 1;
    if strcmp(setting.features, 'scatteringJoint')
        scat.opts{2}.banks.gamma.nFilters_per_octave = 1;
        scat.opts{2}.banks.gamma.T = 2^5;
    end
    scat.opts{2}.banks.wavelet_handle = @gammatone_1d;
    scat.opts{2}.invariants.time.invariance = 'summed';
    
    scat.archs = sc_setup(scat.opts);
    scat.w = tukeywin(scat.N, .1);
    
    store.xp_settings.scat=scat;
end


%% select sound

fileId = fopen([config.inputPath store.xp_settings.datasetPath 'sampleList_' setting.dataset '.txt']);
store.xp_settings.sounds=textscan(fileId,'%s');store.xp_settings.sounds=store.xp_settings.sounds{1};
fclose(fileId);

%% load sound

store.xp_settings.soundIndex = setting.soundIndex;

% init
eval(['store.features.' setting.features ' = [];']);
store.indSample=[];
store.class=[];

for jj=1:length(store.xp_settings.soundIndex)
    
    [signal,fs]=audioread([config.inputPath store.xp_settings.datasetPath store.xp_settings.sounds{store.xp_settings.soundIndex(jj)}  '.wav']);
    
    if fs~=store.xp_settings.sr
        error('wrong sr')
    end    
    
    % mono
    if min(size(signal)) > 1
        signal=signal(:,1);
    end
    
    store.xp_settings.soundDuration = length(signal)/store.xp_settings.sr;
    
    % norm
     signal=signal/max(abs(signal))*.9;
    
    % pre emph
    if store.xp_settings.preemph > 0
        signal = filter([1 -store.xp_settings.preemph], 1, signal);
    end
    
    % get features
    ftrs= getFeatures(signal,setting.features,store.xp_settings,0);
    
    % store features
    eval(['store.features.' setting.features ' = [store.features.' setting.features ' ftrs.' setting.features '];']);
    
    store.indSample=[store.indSample ones(1,ftrs.size)*jj];
    
    soundname=store.xp_settings.sounds{store.xp_settings.soundIndex(jj)}(1:end-2);
    soundname=soundname(strfind(soundname,'/')+1:end);
    store.class=[store.class ones(1,ftrs.size)*find(strcmp(soundname,store.xp_settings.classes))];
    
end