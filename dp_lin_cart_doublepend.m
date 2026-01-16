function [A,B,x0,u0] = dp_lin_cart_doublepend(theta1e, theta2e, x_ref, p)
%DP_LIN_CART_DOUBLEPEND Numerically linearize the cart + double pendulum dynamics around an equilibrium.
%
% Builds the operating point (x0,u0) for the given reference position and
% equilibrium angles, then computes the continuous-time linear model
% xdot ≈ A*(x - x0) + B*(u - u0) using central finite differences applied to
% dp_dynamics. Step sizes are scaled per-state to improve numerical robustness.
%
% Inputs:
%   theta1e - equilibrium angle of the first pendulum [rad].
%   theta2e - equilibrium angle of the second pendulum [rad].
%   x_ref   - cart reference position used to form x0 (default: 0).
%   p       - struct of physical parameters (M, m1, m2, l1, l2, g).
%
% Outputs:
%   A  - state matrix (6x6) at the operating point.
%   B  - input matrix (6x1) at the operating point.
%   x0 - operating state [x_ref; 0; theta1e; 0; theta2e; 0].
%   u0 - operating input (scalar, default 0).

if nargin < 3 || isempty(x_ref), x_ref = 0; end
if nargin < 4 || isempty(p)
    p = struct('M',1.0,'m1',0.1,'m2',0.1,'l1',0.5,'l2',0.5,'g',9.81);
end

x0 = [x_ref; 0; theta1e; 0; theta2e; 0];
u0 = 0;

f = @(x,u) dp_dynamics(x,u,p);

nx = 6;
A = zeros(nx,nx);
B = zeros(nx,1);

h = zeros(nx,1);
for i = 1:nx
    h(i) = 1e-6 * max(1, abs(x0(i)));
end
hu = 1e-6 * max(1, abs(u0));

for j = 1:nx
    ej = zeros(nx,1); ej(j) = 1;
    fp = f(x0 + h(j)*ej, u0);
    fm = f(x0 - h(j)*ej, u0);
    A(:,j) = (fp - fm) / (2*h(j));
end

fp = f(x0, u0 + hu);
fm = f(x0, u0 - hu);
B(:,1) = (fp - fm) / (2*hu);
end
