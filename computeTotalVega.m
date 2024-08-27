function total_vega=computeTotalVega(contract,instruments_complete, shift, ...
    X)
 % computeTotalVega: computes the total vega of the contract 
    %
    % INPUTS:
    % contract: contract details
    % instruments_complete: struct with complete instrument data
    % shift: shift to be applied to the bucket
    % X: Principal amount
    %
    % OUTPUTS:
    % total_vega: vega sensitivity of the contract



% Compute NPV of the contract in the normal case 
NPV=NPVcontract(instruments_complete,contract,X); 

% Peform the shift
instruments_complete_mod=instruments_complete; 
instruments_complete_mod.caps.flat_vols=instruments_complete.caps.flat_vols+shift;

% Recompute the spot volatilities
instruments_complete_mod.caps=calibrateSpotVol(instruments_complete.bootstrap, instruments_complete_mod.caps);

% Compute new NPV
NPV_mod=NPVcontract(instruments_complete_mod,contract,X);

% Compute the vega
total_vega=NPV_mod-NPV;

end
