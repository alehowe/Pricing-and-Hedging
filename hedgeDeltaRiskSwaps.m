function swaps_notionals=hedgeDeltaRiskSwaps(filename, contract,instruments,instruments_complete, macro_buckets, shift, X, consider_after_maturity)
% hedgeDeltaRiskSwaps: hedges the delta risk (with course grained buckets) of the contract
    %
    % INPUTS:
    % filename: name of the excel file
    % contract: contract details
    % instruments: struct with instrument data before modification
    % instruments_complete: struct with complete instrument data before modification
    % macro_buckets: vector containing the macro-buckets (years)
    % shift: shift to be applied to the bucket
    % X: Principal amount
    %
    % OUTPUTS:
    % swaps_notionals: Vector of the swaps notionals (each notional corresponds to the swap with 
    % maturity in maturitiesSwaps)
    % consider_after_maturity: if true, it takes into account also the
    % shift of the instrument after the maturity of the swap

swap_maturities=instruments_complete.hedging.swaps.maturities; 
swap_rates=instruments_complete.hedging.swaps.rates; 
today=instruments_complete.bootstrap.dates(1); 

% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the swap notionals
instruments.hedging.swaps.notionals=zeros(length(weights(:,1)), 1);

% Compute delta course-grained bucket_sensitivities of the contract
[delta_course_grained_bucket_sensitivities] = computeDeltaCourseGrainedBucketSensitivities(contract,instruments,instruments_complete,filename, ...
    macro_buckets, shift, X);

% Initialize quantities of interest (obviously assuming that the number of swaps is
% equal to the number of macro buckets to have a unique solution of the system)
delta_course_grained_bucket_sensitivities_swap=zeros(length(swap_maturities));

for ii=1:length(swap_maturities)
    delta_course_grained_bucket_sensitivities_swap(:,ii) = computeDeltaCourseGrainedBucketSensitivitiesSwaps(...
        filename,instruments,instruments_complete, macro_buckets, shift, today, swap_rates(ii), swap_maturities(ii), 1);
end

% Solve the linear system
if consider_after_maturity
    swaps_notionals=-delta_course_grained_bucket_sensitivities_swap\delta_course_grained_bucket_sensitivities;
else
    % Set the upper diagonal elements to 0
    for i = 1:length(swap_maturities)
        for j = i+1:length(swap_maturities)
            delta_course_grained_bucket_sensitivities_swap(i, j) = 0;
        end
    end

    % Solve the linear system
    swaps_notionals=-delta_course_grained_bucket_sensitivities_swap\delta_course_grained_bucket_sensitivities;


end
