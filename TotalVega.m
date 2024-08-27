function TV=TotalVega(dates, discounts, today, contract_maturities_time, matrix_data, CapVolSet, X, spolA, first_couponB, notional)

CapVolSet.spot_vols=CapVolSet.spot_vols+10^-4; 

TV=NPVcontract(dates, discounts, today, contract_maturities_time, matrix_data, CapVolSet, X, spolA, first_couponB, notional);

CapVolSet.spot_vols=CapVolSet.spot_vols-10^-4; 

end
