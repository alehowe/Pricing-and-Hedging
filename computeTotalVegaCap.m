function total_vega_cap=computeTotalVegaCap( instruments_complete, shift, today, cap_strike, cap_maturity)
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
                                                   


% Compute NPV of the cap in the normal case 
NPV_cap=priceCapBachelier(instruments_complete, today, cap_maturity, cap_strike);

% Peform the shift
instruments_complete_mod=instruments_complete; 
instruments_complete_mod.caps.flat_vols=instruments_complete_mod.caps.flat_vols+shift;

% Recompute the spot volatilities
instruments_complete_mod.caps=calibrateSpotVol(instruments_complete_mod.bootstrap, instruments_complete_mod.caps);

% Compute new NPV
NPV_cap_mod=priceCapBachelier(instruments_complete_mod,today, cap_maturity, cap_strike);

% Compute the vega
total_vega_cap=NPV_cap_mod-NPV_cap;

end
