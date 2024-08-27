function NPV=NPVcontract(instruments,contract,X)
% NPVcontract computes the Net Present Value (NPV) of a contract
    %
    % Inputs:
    % instruments: struct containing instrument data
    %              - instruments.bootstrap.dates: vector of dates
    %              - instruments.bootstrap.discounts: vector of discounts
    %              - instruments.caps: struct containing cap data
    %              - instruments.caps.strikes: vector of strikes
    %              - instruments.caps.maturities: vector of maturities
    %              - instruments.caps.flat_vols: matrix of flat volatilities
    % contract: struct containing contract information
    %           - contract.B.maturities: vector of maturities when contract conditions change
    %           - contract.start_date: start date of the contract
    %           - contract.A.spol: spread over Libor paid by party A
    %           - contract.B.last_coupons: matrix of last coupons paid by party B
    %           - contract.B.first_coupon: first quarter coupon paid by party B
    %           - contract.notional: notional of the contract
    % X: Principal amount
    %
    % Output:
    % NPV: Net Present Value of the contract

% Parameters
Act365=3;
Act360=2;
Eu_30_360=6;

capsDates=DateCaps(contract.B.maturities,instruments.bootstrap.dates); 

% Build the start dates and maturity vectors
start_dates=[contract.start_date; capsDates.dte_start];
payment_dates=[addtodate(contract.start_date, 3, 'month'); capsDates.dte_end];

% Compute the yearfracs between start_dates and end_dates
delta=yearfrac(start_dates, payment_dates, Act360);

% Find the needed discounts
used_discounts=find_discount(instruments.bootstrap.dates, instruments.bootstrap.discounts, payment_dates);

% NPV of the principal amount
NPV_pcam=-X;

% NPV of the first Libor payments of part A
libor_start=(1./(used_discounts(1))-1)/delta(1);
NPV_first_Libor=(libor_start+contract.A.spol)*delta(1)*used_discounts(1);

% NPV first quarter coupon payed by B
NPV_first_coupon=contract.B.first_coupon*delta(1)*used_discounts(1);

% NPV Caplet payoff traslation
traslation_vector_start=contract.A.spol*ones(length(contract.B.last_coupons(:,1)), 1)-contract.B.last_coupons(:,1);

traslation_vector=traslation_vector_start(1)*ones(contract.B.maturities(1)*4, 1);

% Compute the translation vector
for ii=2:length(traslation_vector_start)
    traslation_vector=[traslation_vector; traslation_vector(ii)*ones((contract.B.maturities(ii)-contract.B.maturities(ii-1))*4, 1)];
end

NPV_tras=sum(used_discounts(2:end).*delta(2:end).*traslation_vector(2:end));

% NPV Caplets
strikes=contract.B.last_coupons(:,2)-contract.B.last_coupons(:,1);

% Spot volatilities under the year are equal to the flat
sigma_first_year=findSpotVol(instruments.bootstrap, instruments.caps , strikes(1), payment_dates(4));
caplet_prices=zeros(length(delta)-1,1);

% Compute the caplet prices of the first strike value (1st year)
for ii=1:3
    caplet_prices(ii)=PriceCapletBachelier(instruments.bootstrap, start_dates(ii+1), payment_dates(ii+1), strikes(1), sigma_first_year);
end

% Compute the caplet prices of the first strike value (from 1sst year up to
% the year before changes in the contract)
for jj=4:contract.B.maturities(1)*4-1
    spot_vol=findSpotVol(instruments.bootstrap, instruments.caps, strikes(1), payment_dates(jj+1));
    caplet_prices=[caplet_prices; PriceCapletBachelier(instruments.bootstrap, start_dates(jj+1), payment_dates(jj+1), strikes(1), spot_vol)];

end

% Compute the caplet prices of the folowing strike values
for ii=2:length(strikes)

    for jj=contract.B.maturities(ii-1)*4:contract.B.maturities(ii)*4-1
        spot_vol=findSpotVol(instruments.bootstrap, instruments.caps, strikes(ii), payment_dates(jj+1));
        caplet_prices=[caplet_prices; PriceCapletBachelier(instruments.bootstrap, start_dates(jj+1), payment_dates(jj+1), strikes(ii), spot_vol)];

    end
end

% Compute the sum 
NPV_caplets=sum(caplet_prices); 

% Compute the total NPV
NPV=contract.notional*(NPV_pcam+NPV_first_Libor-NPV_first_coupon+NPV_caplets+NPV_tras);

end