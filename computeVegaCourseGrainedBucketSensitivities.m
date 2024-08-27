function vega_course_grained_bucket_sensitivities= computeVegaCourseGrainedBucketSensitivities(contract,instruments_complete,...
     macro_buckets, shift, today, ...
    X,  vega_bucket_sensitivities)
% computeVegaCourseGrainedBucketSensitivities: computes the vega course 
    % grained bucket sensitivities
    %
    % INPUTS:
    %       contract: struct containing contract details
    %       instruments_complete: struct containing complete instrument data
    %       macro_buckets: vector containing the macro-buckets (years)
    %       shift: shift to be applied to the bucket
    %       today: Today's date
    %       X: Principal amount
    %       vega_bucket_sensitivities: vega course grained sensitivities 
    %                                   (of macro_buckets) for the contract 
    %                                   (optional parameter to speed computations up)
    %
    % OUTPUTS:
    %       vega_course_grained_bucket_sensitivities: vega course grained bucket 
    %                                                 sensitivities

% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the vector of sensitivities
vega_course_grained_bucket_sensitivities=zeros(length(weights(:,1)), 1);

% Compute NPV of the cap in the normal case 
NPV=NPVcontract(instruments_complete,contract,X);

% Find the index up to which vary the flat volatilities
last_index=find(instruments_complete.caps.maturities>=macro_buckets(end), 1);

if nargin==6
    % Compute the delta bucket sensitivities for each bucket until the
    % contract's maturity
    vega_bucket_sensitivities=zeros(last_index, 1);
    
    
    % Compute the vega bucket sensitivities (we stop at last_index after
    % observing that buckets after maturity don't have impact)
    vega_bucket_sensitivities=computeVegaBucketSensitivities(contract,instruments_complete,shift, ...
    X, last_index);
end

% Find the weights indexed affected by such shift 
indexes=instruments_complete.caps.maturities([1:last_index]);
vega_bucket_sensitivities=vega_bucket_sensitivities(1:last_index);
used_weights=weights(:, indexes);

% Compute the vega grained bucket sensitivities
for ii=1:length(weights(:,1))
    vega_course_grained_bucket_sensitivities(ii)=sum(used_weights(ii, :).*vega_bucket_sensitivities');
end

end

