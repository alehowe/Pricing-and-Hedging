function [caps] = calibrateSpotVol(bootstrap, caps)
    % calibrateSpotVol: Calibrates the cap spot volatilities given the cap flat volatilities
    %
    % Inputs:
    % bootstrap: struct containing discount curve information
    %            - bootstrap.dates: vector containing dates of the curve
    %            - bootstrap.discounts: vector containing discounts of the curve
    % caps: struct containing cap information
    %       - caps.flat_vols: matrix containing the flat volatilities
    %       - caps.strikes: vector of strikes
    %       - caps.maturities: vector of maturities
    %       - caps.dates: struct containing cap dates
    %                     - caps.dates.dte_start: vector of start dates for caps
    %                     - caps.dates.dte_end: vector of payment dates for caps
    %
    % Outputs:
    % caps: struct containing updated cap information
    %       - caps.spot_vols: matrix containing the spot volatilities

    % Extract the flat volatilities
    flat_vols = caps.flat_vols;
    strikes = caps.strikes;
    maturities = caps.maturities;
    discountDates=bootstrap.dates; 
    discounts=bootstrap.discounts; 
    
    % Initialize the matrix containing the spot volatilities
    spot_vols = zeros(size(flat_vols));

    % Spot volatilities under one year are the same as the flat vols
    spot_vols(1, :) = flat_vols(1, :);

    % Extract capDates fields
    start_dates = caps.dates.dte_start;
    payment_dates = caps.dates.dte_end;

    for ii = 1:length(strikes)
        caplets1year = PriceCapletBachelier(bootstrap, start_dates(1:3), payment_dates(1:3), strikes(ii), flat_vols(1, ii));
        capflat_upto_previous_mat = sum(caplets1year);

        for kk = 1:length(maturities) - 1
            caplets_upto_maturity = PriceCapletBachelier(bootstrap, start_dates(1:maturities(kk + 1) * 4 - 1), payment_dates(1:maturities(kk + 1) * 4 - 1), strikes(ii), flat_vols(kk + 1, ii));
            capflat_upto_maturity = sum(caplets_upto_maturity);

            delta_capflat = capflat_upto_maturity - capflat_upto_previous_mat;
            caplets_spot_between_maturities = @(sigma) PriceCapletBachelier(bootstrap, start_dates(4 * maturities(kk):4 * maturities(kk + 1) - 1), payment_dates(4 * maturities(kk):4 * maturities(kk + 1) - 1), strikes(ii), interp1([payment_dates(4 * maturities(kk) - 1); payment_dates(4 * maturities(kk + 1) - 1)], [spot_vols(kk, ii); sigma], payment_dates(4 * maturities(kk):4 * maturities(kk + 1) - 1)));

            delta_capspot = @(sigma) sum(caplets_spot_between_maturities(sigma));

            spot_vols(kk + 1, ii) = fzero(@(sigma)(delta_capspot(sigma) - delta_capflat), 0);

            capflat_upto_previous_mat = capflat_upto_maturity;
        end
    end

    caps.spot_vols = spot_vols;
end