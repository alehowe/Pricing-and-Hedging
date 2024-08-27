function [caplet_price]=PriceCapletBachelier(bootstrap, start_date, maturity, strike, flat_vol)
% PriceCapletBachelier: computes the price of a Caplet using Bachelier's normal model
    %
    % Inputs:
    % bootstrap: struct containing dates and discounts of the curve
    % start_date: start date of the caplet
    % maturity: expiry of the caplet
    % strike: strike of the caplet
    % flat_vol: flat volatility of the caplet
    %
    % Outputs:
    % caplet_price: price of the caplet
    

% Define the year fraction conventions
Act360=2;
dates=bootstrap.dates; 
discounts=bootstrap.discounts; 

% Compute the year fraction
deltas=yearfrac(start_date, maturity, Act360);

% Find the discounts
used_discounts_starting= find_discount(dates, discounts, start_date);
used_discounts_maturities= find_discount(dates, discounts, maturity);

% Compute the forward discount
fwd_discounts=used_discounts_maturities./used_discounts_starting;

% Compute the corresponding forward libor rate
forwardLibor=(1-fwd_discounts)./(deltas.*fwd_discounts);

% Compute d
deltaStart=yearfrac(dates(1), start_date, Act360);
d=(forwardLibor-strike)./(flat_vol.*sqrt(deltaStart));

% Compute the price
caplet_price=used_discounts_maturities.*deltas.*((forwardLibor-strike).*normcdf(d)+flat_vol.*sqrt(deltaStart).*normpdf(d));

end