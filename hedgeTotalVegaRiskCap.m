function cap_notional=hedgeTotalVegaRiskCap(contract,instruments_complete,shift, today, X, cap_maturity, cap_strike)
% hedgeTotalVegaRiskCap: hedges the total vega of the contract
    %
    % INPUTS:
    % contract: contract details
    % instruments_complete: struct with complete instrument data
    % shift: shift to be applied to the bucket
    % today: Today's date
    % X: Principal amount
    % cap_maturity: maturity of the cap
    % cap_strike: strike of the considered cap
    %
    % OUTPUTS:
    % cap_notional: Cap notional that hedges the position


% Compute total vega of the contract 
total_vega_contract=computeTotalVega(contract,instruments_complete, shift,X);

% Compute the total vega of the cap
total_vega_cap=computeTotalVegaCap(instruments_complete, shift, today, cap_strike, cap_maturity);

% Hedge the position by imposing the two sensitivities the same (assuming 
% the cap and the contract have the same maturity)
cap_notional=-total_vega_contract/total_vega_cap;

end
