% this example simulation function simulates a model
% and computes the burst period and mean spikes per burst
% then, it returns a cost
% if the burst period is within [900, 2000] ms, then that part of the cost is zero
% if the mean spikes per burst is within [2, 20] then that part of the cost is zero
% otherwise, the cost is the quadratic difference

function [C, V] = burstingCostFcn(x,~)

% x is a xolotl object
x.reset;
x.t_end = 10e3;
x.approx_channels = 1;
x.sim_dt = .1;
x.dt = .1;
x.closed_loop = true;

x.integrate;
V = x.integrate;

% measure behaviour
metrics = xtools.V2metrics(V,'sampling_rate',10);

% accumulate errors
C = 100*xtools.binCost([900 2000],metrics.burst_period);
C = C + 100*xtools.binCost([.1 .5],metrics.duty_cycle_mean);
C = C + 100*xtools.binCost([2 20],metrics.n_spikes_per_burst_mean);
C = C + 100*xtools.binCost([0 20], metrics.min_V_in_burst_mean - metrics.min_V_bw_burst_mean);
C = C + 100*xtools.binCost([100 200],x.AB.Ca_average);

% safety -- if something goes wrong, return a large cost
if isnan(C)
	C = 1e3;
end