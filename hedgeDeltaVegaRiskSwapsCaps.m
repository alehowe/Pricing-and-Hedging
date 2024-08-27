function swaps_notionals=hedgeDeltaVegaRiskSwapsCaps(contract, instruments,instruments_complete,filename, macro_buckets, shift, today, X, maturitiesSwaps, swap_rates,cap_maturity,cap_strike)
                                                   
 % hedgeDeltaVegaRiskSwapsCaps: hedges the delta risk of the contract with swaps having hedged the total vega with the cap
    %
    % INPUTS:
    % filename: name of the excel file
    % instruments_complete: struct with complete instrument data
    % macro_buckets: vector containing the macro-buckets (years)
    % shift: shift to be applied to the bucket
    % today: Today's date.
    % X: Principal amount
    % maturitiesSwaps: maturities of the swaps
    % swap_rates: swap rates of the considered swaps
    % cap_strike: strike of the cap
    % cap_maturity: maturity of the cap
    %
    % OUTPUTS:
    % swaps_notionals: Vector of the swaps notionals (each notional corresponds to the swap with maturity in maturitiesSwaps)

% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the swap notionals
swaps_notionals=zeros(length(weights(:,1)), 1);

% Compute delta course-grained bucket_sensitivities of the contract
[delta_course_grained_bucket_sensitivities] = computeDeltaCourseGrainedBucketSensitivities(contract,instruments,instruments_complete,filename, ...
    macro_buckets, shift, X);

% Compute delta course-grained bucket_sensitivities of the cap
delta_course_grained_bucket_sensitivities_cap=computeDeltaCourseGrainedBucketSensitivitiesCap(instruments,instruments_complete, filename, macro_buckets, shift, today, cap_maturity,cap_strike);

% Initialize quantities of interest (obviously assuming that the number of swaps is
% equal to the number of macro buckets to have a unique solution of the system)
delta_course_grained_bucket_sensitivities_swap=zeros(length(maturitiesSwaps));

for ii=1:length(maturitiesSwaps)
    delta_course_grained_bucket_sensitivities_swap(:,ii) = computeDeltaCourseGrainedBucketSensitivitiesSwaps(filename,instruments,instruments_complete, ...
    macro_buckets, shift, today, swap_rates(ii), maturitiesSwaps(ii), 1);
end

% Solve the linear system
swaps_notionals=-delta_course_grained_bucket_sensitivities_swap\(delta_course_grained_bucket_sensitivities+delta_course_grained_bucket_sensitivities_cap);

end

