function [K,Q,R,lin] = dp_lqr_calc(cfg)
%DP_LQR_CALC Compute the LQR gain for the current configuration and return linearization data.
%
% Builds the LQR weighting matrices from cfg.lqr, linearizes the nonlinear plant
% around the configured equilibrium (cfg.eq) using dp_lin_cart_doublepend, and
% computes the continuous-time state feedback gain K via lqr(A,B,Q,R). The
% returned lin struct captures the operating point and linear model used for
% reproducibility and debugging.
%
% Input:
%   cfg - configuration struct containing fields: lqr (Qdiag, R), eq (theta1e, theta2e, x_ref), and p.
%
% Outputs:
%   K   - LQR state feedback gain matrix.
%   Q   - state weighting matrix (diag(cfg.lqr.Qdiag)).
%   R   - input weighting scalar/matrix from cfg.lqr.R.
%   lin - struct with linearization results: A, B, x0, u0.

Q = diag(cfg.lqr.Qdiag(:).');
R = cfg.lqr.R;

th1e = cfg.eq.theta1e;
th2e = cfg.eq.theta2e;
x_ref = 0;
if isfield(cfg.eq,'x_ref'), x_ref = cfg.eq.x_ref; end

[A,B,x0,u0] = dp_lin_cart_doublepend(th1e, th2e, x_ref, cfg.p);

lin = struct('A',A,'B',B,'x0',x0,'u0',u0);

K = lqr(A,B,Q,R);
end
