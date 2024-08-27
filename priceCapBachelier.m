function cap_price=priceCapBachelier(instruments_complete, today, maturity, strike)
% priceCapBachelier: computes the price of a Cap using Bachelier's normal model using spot volatilities
    
    % Inputs:
    % instruments_complete: struct containing all relevant instrument data
    % today: start date of the caplet
    % maturity: expiry of the Cap
    % strike: strike of the Cap
    %
    % Outputs:
    % cap_price: price of the caplets
    
% Build the start dates and maturity vectors
aux_vector=zeros(maturity(end)*4, 1);

for ii=1:maturity(end)*4
    % Dates every year from now to expiry
    
    aux_vector(ii)=addtodate(today, 3*ii, 'month');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
aux_vector=busdate(aux_vector-1, 'follow', eurCalendar);

% Build the start dates and maturity vectors (neglecting the first caplet)
start_dates=aux_vector(1:end-1);
payment_dates=aux_vector(2:end);


% Compute the prices of the caplets
caplet_prices=zeros(length(payment_dates), 1);

for ii=1:length(payment_dates)
    spot_vol=findSpotVol(instruments_complete.bootstrap, instruments_complete.caps, strike, payment_dates(ii));

    caplet_prices(ii)=PriceCapletBachelier(instruments_complete.bootstrap, start_dates(ii), payment_dates(ii), strike, spot_vol);
    
end

% Compute the Cap's price
cap_price=instruments_complete.hedging.caps.notional*sum(caplet_prices);

end

