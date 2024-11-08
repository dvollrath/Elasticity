mat U = [10, 30 \ 20, 20] // Use table
mat e = [25 \ 15] // final use
mat va = [30 \ 10] // value added
mat i = [1 \ 1]
mat I = [1, 0 \ 0, 1]
mat V = [30, 30 \ 35, 25] // make table

mat q = U*i + e
mat g = V*i

mat ghat = diag(g)
mat qhat = diag(q)

mat B = U*inv(ghat)
mat D = V*inv(qhat)

mat TII = inv(I - D*B)
mat De = D*e

mat TCC = inv(I - B*D)

mat A = B*D
mat TIC = D*inv(I - B*D)

mat V = V'
mat A = U*inv(diag(i'*V))*V'*inv(diag(V*i))
mat z = va'*inv(diag(i'*V))*V'

mat x = inv(I-A)*e
mat IO = A*diag(x)
