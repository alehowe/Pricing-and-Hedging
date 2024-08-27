function caps_notionals=hedgeVegaRiskCaps(contract,instruments_complete, macro_buckets, shift, today, X,  maturitiesCaps,cap_strikes, vega_bucket_sensitivities)
 % hedgeVegaRiskCaps: hedges the vega risk of the contract with caps
    %
    % INPUTS:
    % contract: contract details
    % instruments_complete: struct with complete instrument data
    % macro_buckets: vector containing the macro-buckets (years)
    % shift: shift to be applied to the bucket
    % today: Today's date
    % X: Principal amount
    % maturitiesCaps: maturities of the caps
    % cap_strikes: strikes of the considered caps
    % vega_bucket_sensitivities: vega bucket sensitivities (of macro_buckets) for the contract
    %
    % OUTPUTS:
    % caps_notionals: vector of the caps notionals (each notional corresponds to the swap with maturity in maturitiesCaps)


% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the cap notionals
caps_notionals=zeros(length(weights(:,1)), 1);

% Compute vega course-grained bucket_sensitivities of the contract
if nargin==8
    [vega_course_grained_bucket_sensitivities] = computeVegaCourseGrainedBucketSensitivities(contract,instruments_complete,...
     macro_buckets, shift, today,X);
elseif nargin==9
    [vega_course_grained_bucket_sensitivities] = computeVegaCourseGrainedBucketSensitivities(contract,instruments_complete,...
     macro_buckets, shift, today,X,  vega_bucket_sensitivities);
end

% Initialize quantities of interest
vega_course_grained_bucket_sensitivities_cap=zeros(length(maturitiesCaps),1);
interesting_sens=zeros(length(maturitiesCaps), 1);

% Start from the cap with latest maturity: this will hedge the last
% course-grained bucket vega. We saw indeed that changes of buckets after
% the cap's/ the contract's maturity does ot affect the vega sensitivity.
previous=zeros(length(maturitiesCaps),1);
for ii=length(maturitiesCaps):-1:1
    vega_course_grained_bucket_sensitivities_cap = computeVegaCourseGrainedBucketSensitivitiesCaps(instruments_complete, macro_buckets,maturitiesCaps(ii),cap_strikes(ii),shift, today);
    
    caps_notionals(ii)=(vega_course_grained_bucket_sensitivities(ii)-previous(ii))/vega_course_grained_bucket_sensitivities_cap(ii);

    previous=previous+vega_course_grained_bucket_sensitivities_cap*caps_notionals(ii);
    
end

end
