% RUN_ANALYTICAL_SWEEPS
% Entry-point script for Task 1.2: Full-Speed Steady-State Sweeps and
% Scalar V/f Control Family Curves.
%
% Calls plot_steady_state_curves() to compute pure vectorized curves,
% render 6 publication-grade figures in out/figures/, and exports the
% baseline data array to out/results/analytical_baseline.mat for
% pipeline gating and downstream Simscape dynamic comparison.
%
% Adheres to:
%   - ADR-001 (Consolidated Lab Parameters)
%   - ADR-003 (Pure Vectorization, no scalar loops over speed/slip)
%   - Academic spec (utils/docs/sim_proj.pdf Part 1)

fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - TASK 1.2: STEADY-STATE SWEEPS & V/f CONTROL RUNNER  \n');
fprintf('====================================================================\n\n');

%% 1. Execute Vectorized Analytical Calculations and Visualization
curves = plot_steady_state_curves();

%% 2. Extract Key Baseline Vectors for Downstream Validation
n_vec         = curves.nominal_sweep.n_vec;
s_vec         = curves.nominal_sweep.s_vec;
T_em_vec      = curves.nominal_sweep.T_em;
T_shaft_vec   = curves.nominal_sweep.T_shaft;
I1_line_vec   = curves.nominal_sweep.I1_line;
I1_ph_vec     = curves.nominal_sweep.I1_ph;
P_elec_vec    = curves.nominal_sweep.P_elec;
Q_elec_vec    = curves.nominal_sweep.Q_elec;
P_ag_vec      = curves.nominal_sweep.P_ag;
P_em_vec      = curves.nominal_sweep.P_em;
P_shaft_vec   = curves.nominal_sweep.P_shaft;
cos_phi_vec   = curves.nominal_sweep.cos_phi;
eta_em_vec    = curves.nominal_sweep.eta_em;
eta_shaft_vec = curves.nominal_sweep.eta_shaft;
vf_family     = curves.vf_family;

%% 3. Export Baseline Data to out/results/analytical_baseline.mat
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'out', 'results');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

baseline_mat = fullfile(out_dir, 'analytical_baseline.mat');
save(baseline_mat, 'curves', 'n_vec', 's_vec', 'T_em_vec', 'T_shaft_vec', ...
     'I1_line_vec', 'I1_ph_vec', 'P_elec_vec', 'Q_elec_vec', 'P_ag_vec', 'P_em_vec', ...
     'P_shaft_vec', 'cos_phi_vec', 'eta_em_vec', 'eta_shaft_vec', 'vf_family');

fprintf('[OK] Successfully exported analytical baseline to:\n     %s\n\n', baseline_mat);

%% 4. Summary Verification Printout
fprintf('--------------------------------------------------------------------\n');
fprintf('  TASK 1.2 EXECUTION SUMMARY\n');
fprintf('--------------------------------------------------------------------\n');
fprintf('  Number of speed sample points: %d\n', length(n_vec));
fprintf('  Speed range:                   %.1f to %.1f rpm\n', min(n_vec), max(n_vec));
fprintf('  Peak breakdown torque (T_max): %.2f N.m at %.1f rpm\n', ...
        curves.nominal_sweep.T_max, curves.nominal_sweep.n_at_Tmax);
fprintf('  Starting line current (s=1):   %.2f A RMS\n', I1_line_vec(1));
fprintf('  Starting torque (s=1):         %.2f N.m\n', T_em_vec(1));
fprintf('  Scalar V/f family curves:      4 curves generated (100%%, 75%%, 50%%, 25%%)\n');
fprintf('--------------------------------------------------------------------\n');
fprintf('[PASS] Task 1.2 analytical routines executed successfully.\n');
