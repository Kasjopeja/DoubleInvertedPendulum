function xdot = dp_dynamics(x, u, p)
%DP_DYNAMICS Continuous-time equations of motion for the cart + double pendulum.
%
% Computes the state derivatives xdot for the nonlinear model using the
% mass-matrix formulation M(q)*qdd = rhs(q,qd,u). This function is intended
% to be the single, source of dynamics used by the simulator
% and any analysis utilities, ensuring consistent physics across the codebase.
%
% Inputs:
%   x - state vector [x; dx; th1; dth1; th2; dth2]
%   u - cart force input
%   p - struct of physical parameters (M, m1, m2, l1, l2, g)
%
% Output:
%   xdot - time derivative of the state vector

x = x(:);

th1  = x(3);  dth1 = x(4);
th2  = x(5);  dth2 = x(6);

s1  = sin(th1);   c1t = cos(th1);
s2  = sin(th2);   c2t = cos(th2);

d12 = th1 - th2;
s12 = sin(d12);
c12 = cos(d12);

M  = p.M;  m1 = p.m1;  m2 = p.m2;
l1 = p.l1; l2 = p.l2;  g  = p.g;

Mmat = [ M + m1 + m2,        (m1 + m2)*l1*c1t,     m2*l2*c2t;
        (m1 + m2)*l1*c1t,   (m1 + m2)*l1^2,       m2*l1*l2*c12;
        m2*l2*c2t,          m2*l1*l2*c12,         m2*l2^2 ];

rhs = [ u + (m1 + m2)*l1*s1*dth1^2 + m2*l2*s2*dth2^2;
        (m1 + m2)*g*l1*s1 - m2*l1*l2*s12*dth2^2;
        m2*g*l2*s2 + m2*l1*l2*s12*dth1^2 ];

qdd = Mmat \ rhs;

ddx      = qdd(1);
ddtheta1 = qdd(2);
ddtheta2 = qdd(3);

xdot = zeros(6,1);
xdot(1) = x(2);
xdot(2) = ddx;
xdot(3) = dth1;
xdot(4) = ddtheta1;
xdot(5) = dth2;
xdot(6) = ddtheta2;
end
