function [delta_bucket_sensitivities] = computeDeltaBucketSensitivities(contract,instruments,instruments_complete,filename, shift, numbuckets,X)
% computeDeltaBucketSensitivities: computes the delta bucket sensitivities
    % varying the relevant market rates
    %
    % INPUTS:
    % filename: name of the excel file
    % instruments: struct with instrument data before modification
    % instruments_complete: struct with complete instrument data before modification
    % shift: shift to be applied to the bucket
    % numbuckets: number of buckets that can be modified
    % X: Principal amount
    %
    % OUTPUTS:
    % delta_bucket_sensitivities: delta bucket sensitivities

NPV_old=NPVcontract(instruments_complete,contract,X); 

% For each bucket perform the shift
for ii=1:numbuckets
    %Take all depos 7 futures all swaps and shift
    instruments_mod=instruments; 

    [instruments_mod.dates, instruments_mod.rates]=bucketModifier(instruments.dates,instruments.rates, ii, shift);   
    
    [instruments_mod_complete] = completeStructSwapModified(filename, instruments_mod);
    
    [instruments_mod_complete.bootstrap.dates, instruments_mod_complete.bootstrap.discounts]=bootstrap(instruments_mod_complete.dates, instruments_mod_complete.rates); 
    
    delta_bucket_sensitivities(ii)=NPVcontract(instruments_mod_complete,contract,X)-NPV_old;
   
         
end

end
    