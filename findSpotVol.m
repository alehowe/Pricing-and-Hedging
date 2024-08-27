function [spot_vol]=findSpotVol(bootstrap, caps, searching_strike, searching_date)
 % findSpotVol: finds the spot volatility at a given strike and date
    %
    % Inputs:
    % bootstrap: struct containing the bootstrap data
    % caps: struct containing cap data
    % searching_strike: strike of the spot_vol
    % searching_date: date of the spot_vol
    %
    % Outputs:
    % spot_vol: spot volatility at the given strike and date

% Outputs:
% spotVol:          spot volatility at the given strike and date

dates=bootstrap.dates; 
discounts=bootstrap.discounts; 

% Extract the information from the struct
available_strikes=caps.strikes;
available_maturities=caps.maturities;
spot_vols=caps.spot_vols;

% Build the maturity dates vector
maturity_dates=zeros(length(available_maturities), 1);

for ii=1:length(maturity_dates)
    % Dates every year from now to expiry
    maturity_dates(ii)=addtodate(dates(1), available_maturities(ii), 'year');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
maturity_dates=busdate(maturity_dates-1, 'follow', eurCalendar);

% Initialize the spot vols at the given date
spot_vols_at_given_date=zeros(length(available_strikes),1);

% If the date I'm looking for is under a year the spot vols are the first
% year's flat vols
if searching_date<=maturity_dates(1)
    spot_vols_at_given_date=caps.flat_vols(1,:);
elseif searching_date<=maturity_dates(end)
% Compute the spot volatilities for the availbale strikes at the given date
    for ii=1:length(spot_vols_at_given_date)
        spot_vols_at_given_date(ii)=interp1(maturity_dates, spot_vols(:, ii), searching_date, "linear");
    end
else
% If the searching date is after the last maturity date I have raise an
% error
    error("The searching date you're looking for is out of range")
end

% Check if the strike I'm looking for is in the vector of strikes
found=find(available_strikes==searching_strike);

% If the strike is available just return the spot_vol at the given date and
% strike
if (found)
    spot_vol=spot_vols_at_given_date(found);

% If the strike I'm looking for is in the range of the strikes I have
% spline interpolation 
else if (searching_strike>available_strikes(1) || searching_strike<available_strikes(end))     
    spot_vol=interp1(available_strikes, spot_vols_at_given_date, searching_strike, "spline");

else 
% If the strike I'm looking for is out of range of the strikes I have
% spline extrapolation 
     spot_vol=interp1(available_strikes, spot_vols_at_given_date, searching_strike, "spline", "extrap");
end

end

