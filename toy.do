clear
set obs 1000

gen v = 5*invnorm(runiform()) // noise
gen u = 5*invnorm(runiform()) // noise

gen S = -5+10*runiform() // exogenous suitability measure runs from neg to pos
gen X = 1/(1+exp(-2*S + v + 0.5*u)) // labor intensity is non-lin with S and some noise
	// but *also* depends on noise from individualism

gen XSplit = 1/(1+exp(-2*S+v)) + 1/(1+exp(0.5*u)) // if X is non-linear but split	
	
gen Y = 3*X + u // real relationship of individualism to labor intensity

gen YSplit = 3*XSplit + u

gen Xhat = 1/(1+exp(-2*S)) // this is fitted value of X from "zero stage" 
	// same regardless if split or not

reg Y Xhat // reduced form - "forbidden regression"
reg YSplit Xhat // reduced form

reg X Xhat // first stage

ivreg Y (X = Xhat) // IV
ivreg YSplit (X = Xhat)
