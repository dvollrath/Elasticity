
mat TR = [1.2, .3 \ .8, 1.5] // given from BEA - is Industry by Industry, combines Use/Make information
//mat TR = [1, 0 \ 0, 1] 
//mat TR = [1.2, .3 \ .3, 1.2]
//mat X = [320 \ 212] // gross output of industries, from Use table
mat X = [200 \ 300]
mat e = [1 \ 1] // summation matrix
mat cva = [0.75, 0.40 \ 0.1, 0.30] // diff markup and factor cost shares
//mat cva = [0.75, .85*.4/.7 \ 0.1, .85*.3/.7] // same markup, diff factor cost shares
//mat cva = [0.75, .7*.75/.85 \ 0.1, .7*.1/.85] // diff markup, same factor cost shares


// Solve for Z table consistnet with gross output
mat Z = (I(2) - inv(TR))*diag(X)
mat V = X - Z'*e // value added consistent with gross output and TR
mat list V
mat C = cva*diag(V)
mat list C

// Calculate total costs
mat T = e'*Z + e'*C
mat list T
mat list X

// Total reqs based on costs
mat TRC = inv(I(2)-Z*inv(diag(T)))

// Get FU shares
mat F = inv(TR)*X // this is implicitly what final use is given TR - negatives are OKAY - some FU is negative
mat f = F*inv(e'*F)

mat M = diag(X)*inv(diag(T))

// Elasticity and shares
mat E = C*inv(diag(T))*TRC*F*inv(e'*F)
mat list E

mat SVA = C*e*inv(e'*V)
mat list SVA

mat SCOST = C*e*inv(e'*C*e)
mat list SCOST

mat Cost = e'*C*e
mat list Cost
mat FU = e'*F
mat list FU

mat STEST = C*inv(diag(T))*inv(M)*TR*F*inv(e'*inv(TRC)*inv(M)*TR*F)
