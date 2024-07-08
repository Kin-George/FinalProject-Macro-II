/*
 * Este codigo es una adaptación del codigo realizado por: 
 * Dr. Johannes Pfeifer  
 * donde replica el paper de Schmitt-Grohé, Stephanie and Uribe, Martín (2003): "Closing small open economy 
 * models", Journal of International Economics, 61, pp. 163-185.
 * 
 */

title_string='Model 1: Endogenous descount factor';

var  c h y i k a lambda ${\lambda}$ util;  
varexo e;                                    
                                             
parameters  gamma ${\gamma}$
            omega ${\omega}$
            rho ${\gamma}$
            sigma_tfp ${\sigma_{a}}$
            delta ${\delta}$
            psi_1 ${\psi_1}$
            psi_2 ${\psi_2}$
            alpha ${\alpha}$
            phi ${\phi}$
            psi_3 ${\psi_3}$
            psi_4 ${\psi_4}$
            r_bar ${\bar r}$
            d_bar ${\bar d}$;
            
%Table 1
gamma  = 2; %risk aversion
omega  = 1.455; %Frisch-elasticity parameter
psi_1  = 0; %set in steady state %elasticity discount factor w.r.t. to arguments of utility function
alpha  = 0.32; %labor share
phi    = 0.028; %capital adjustment cost parameter
r_bar    = 0.04; %world interest rate		
delta  = 0.1; %depreciation rate
rho    = 0.42; %autocorrelation TFP 
sigma_tfp = 0.0129; %standard deviation TFP

%Table 2
psi_2    = 0.000742;
d_bar  = 0.7442;

psi_3  = 0.00074; 
psi_4  = 0; %set in steady state; parameter complete markets case

var d tb_y, ca_y, r beta_fun, eta; 

model;
    [name='Eq. (4), Evolution of debt']
    d = (1+exp(r(-1)))*d(-1)- exp(y)+exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2;
    [name='Eq. (5), Production function']
    exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha));
    [name='Eq. (6), Law of motion for capital']
    exp(k) = exp(i)+(1-delta)*exp(k(-1)); 

    [name='Eq. (8), Euler equation']
    exp(lambda)= beta_fun*(1+exp(r))*exp(lambda(+1)); 
    [name='Eq. (9), Definition marginal utility']
    exp(lambda)=(exp(c)-((exp(h)^omega)/omega))^(-gamma)-eta*(-psi_1*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi_1-1));  
    [name='Eq. (10), Law of motion Lagrange mulitplier on discount factor equation']
    eta=-util(+1)+eta(+1)*beta_fun(+1);
    [name='Eq. (11), Labor FOC']
    ((exp(c)-(exp(h)^omega)/omega)^(-gamma))*(exp(h)^(omega-1)) + 
        eta*(-psi_1*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi_1-1)*(-exp(h)^(omega-1))) = exp(lambda)*(1-alpha)*exp(y)/exp(h); 
    [name='Eq. (12), Investment FOC']
    exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) = beta_fun*exp(lambda(+1))*(alpha*exp(y(+1))/exp(k)+1-delta+phi*(exp(k(+1))-exp(k))); 
    [name='Eq. (14), Law of motion for TFP']
    a = rho*a(-1)+sigma_tfp*e; 

    [name='Definition endogenous discount factor, p. 168']
    beta_fun =(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi_1);
    [name='Definition felicity function']    
    util=(((exp(c)-omega^(-1)*exp(h)^omega)^(1-gamma))-1)/(1-gamma);
    [name='9. Eq. (23), country interest rate']
    exp(r) = r_bar;

    [name='11. p. 169, Definition of trade balance to ouput ratio']
    tb_y = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y));
    ca_y = (1/exp(y))*(d(-1)-d);                                   
end;

steady_state_model;
    r     = log(r_bar);
    d     = d_bar;
    h     = log(((1-alpha)*(alpha/(r_bar+delta))^(alpha/(1-alpha)))^(1/(omega-1)));
    k     = log(exp(h)/(((r_bar+delta)/alpha)^(1/(1-alpha))));
    y     = log((exp(k)^alpha)*(exp(h)^(1-alpha)));
    i     = log(delta*exp(k));
    c     = log(exp(y)-exp(i)-r_bar*d);
    tb_y    = 1-((exp(c)+exp(i))/exp(y));
    util=(((exp(c)-omega^(-1)*exp(h)^omega)^(1-gamma))-1)/(1-gamma);
    psi_1=-log(1/(1+r_bar))/(log((1+exp(c)-omega^(-1)*exp(h)^omega)));
    beta_fun =(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi_1);
    eta=-util/(1-beta_fun);
    lambda=log((exp(c)-((exp(h)^omega)/omega))^(-gamma)-eta*(-psi_1*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi_1-1)));
    a     = 0;
    ca_y    = 0;
end;

resid;

check;
steady; 

shocks;
    var e; stderr 1;
end;

stoch_simul(order=1, irf=0);

//Report results from Table 3
y_pos=strmatch('y',M_.endo_names,'exact');
c_pos=strmatch('c',M_.endo_names,'exact');
i_pos=strmatch('i',M_.endo_names,'exact');
h_pos=strmatch('h',M_.endo_names,'exact');
tb_y_pos=strmatch('tb_y',M_.endo_names,'exact');
ca_y_pos=strmatch('ca_y',M_.endo_names,'exact');


fprintf('\nstd(y):              \t %2.1f \n',sqrt(oo_.var(y_pos,y_pos))*100)
fprintf('std(c):                \t %2.1f \n',sqrt(oo_.var(c_pos,c_pos))*100)
fprintf('std(i):                \t %2.1f \n',sqrt(oo_.var(i_pos,i_pos))*100)
fprintf('std(h):                \t %2.1f \n',sqrt(oo_.var(h_pos,h_pos))*100)
fprintf('std(tb/y):             \t %2.1f \n',sqrt(oo_.var(tb_y_pos,tb_y_pos))*100)
if ~isempty(ca_y_pos)
fprintf('std(ca/y):             \t %2.1f \n',sqrt(oo_.var(ca_y_pos,ca_y_pos))*100)
else %complete markets case
fprintf('std(ca/y):             \t %2.1f \n',sqrt(oo_.var(ca_y_pos,ca_y_pos))*100)
end
fprintf('corr(y_t,y_t-1):       \t %3.2f \n',oo_.autocorr{1}(y_pos,y_pos))
fprintf('corr(c_t,c_t-1):       \t %3.2f \n',oo_.autocorr{1}(c_pos,c_pos))
fprintf('corr(i_t,i_t-1):       \t %4.3f \n',oo_.autocorr{1}(i_pos,i_pos))
fprintf('corr(h_t,h_t-1):       \t %3.2f \n',oo_.autocorr{1}(h_pos,h_pos))
fprintf('corr(tb/y_t,tb/y_t-1): \t %3.2f \n',oo_.autocorr{1}(tb_y_pos,tb_y_pos))
if ~isempty(ca_y_pos)
fprintf('corr(ca/y_t,ca/y_t-1): \t %3.2f \n',oo_.autocorr{1}(ca_y_pos,ca_y_pos))
else %complete markets case
fprintf('corr(ca/y_t,ca/y_t-1): \t %3.2f \n',NaN)
end
fprintf('corr(c_t,y_t):         \t %3.2f \n',oo_.gamma_y{1}(c_pos,y_pos)/sqrt(oo_.var(c_pos,c_pos)*oo_.var(y_pos,y_pos)))
fprintf('corr(i_t,y_t):         \t %3.2f \n',oo_.gamma_y{1}(i_pos,y_pos)/sqrt(oo_.var(i_pos,i_pos)*oo_.var(y_pos,y_pos)))
fprintf('corr(h_t,y_t):         \t %2.1f \n',oo_.gamma_y{1}(h_pos,y_pos)/sqrt(oo_.var(h_pos,h_pos)*oo_.var(y_pos,y_pos)))
fprintf('corr(tb/y_t,y_t):      \t %4.3f \n',oo_.gamma_y{1}(tb_y_pos,y_pos)/sqrt(oo_.var(tb_y_pos,tb_y_pos)*oo_.var(y_pos,y_pos)))
if ~isempty(ca_y_pos)
fprintf('corr(ca/y_t,y_t):      \t %4.3f \n',oo_.gamma_y{1}(ca_y_pos,y_pos)/sqrt(oo_.var(ca_y_pos,ca_y_pos)*oo_.var(y_pos,y_pos)))
else %complete markets case
fprintf('corr(ca/y_t,y_t):      \t %4.3f \n',NaN)
end









