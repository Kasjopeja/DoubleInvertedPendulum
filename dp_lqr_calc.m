function [K,Q,R,lin] = dp_lqr_calc(cfg)
%DP_LQR_CALC Liczy regulator LQR na podstawie cfg.
%
% cfg.lqr.Qdiag (1x6), cfg.lqr.R, cfg.eq.theta1e/theta2e/x_ref, cfg.p

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
