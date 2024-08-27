function vega_course_grained_bucket_sensitivities_cap=computeVegaCourseGrainedBucketSensitivitiesCaps(instruments_complete, macro_buckets,maturity,strike, shift, today)
% computeVegaCourseGrainedBucketSensitivitiesCaps: computes the vega course 
    % grained bucket sensitivities of a Cap
    %
    % INPUTS:
    %       instruments_complete: struct containing complete instrument data
    %       macro_buckets: vector containing the macro-buckets (years)
    %       maturity: maturity of the cap (in years)
    %       strike: strike of the cap
    %       shift: shift to be applied to the bucket
    %       today: Today's date
    %
    % OUTPUTS:
    %       vega_course_grained_bucket_sensitivities_cap: vega course grained bucket 
    %       sensitivities of the cap


% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the vector of sensitivities
vega_course_grained_bucket_sensitivities_cap=zeros(length(weights(:,1)), 1);

% Compute NPV of the cap in the normal case 
NPV_cap=priceCapBachelier(instruments_complete, today, maturity, strike);

% Find the index up to which vary the flat volatilities
last_index=find(instruments_complete.caps.maturities>=macro_buckets(end), 1);

% Compute the delta bucket sensitivities for each bucket until the swap's
% maturity
vega_bucket_sensitivities_caps=zeros(last_index, 1);

% Vary the flat volatilities of 1bp for every bucket and compute the delta
% NPV
instruments_complete_mod=instruments_complete;

for ii=1:last_index

    instruments_complete_mod.caps.flat_vols(ii,:)=instruments_complete.caps.flat_vols(ii,:)+shift; 

    instruments_complete_mod.caps=calibrateSpotVol(instruments_complete_mod.bootstrap, instruments_complete_mod.caps);

    vega_bucket_sensitivities_caps(ii)=priceCapBachelier(instruments_complete_mod, today, maturity, strike)-NPV_cap;
   
    instruments_complete_mod=instruments_complete;

end

% Find the weights indexed affected by such shift (we know that Caps have
% yearly maturities)
indexes=instruments_complete.caps.maturities([1:last_index]);
used_weights=weights(:, indexes);

% Compute the vega grained bucket sensitivities
for ii=1:length(weights(:,1))
    vega_course_grained_bucket_sensitivities_cap(ii)=sum(used_weights(ii, :)'.*vega_bucket_sensitivities_caps);
end

end

