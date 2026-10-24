---
name: matlab-headless
description: Best practices and execution patterns for running MATLAB scripts and tests in headless non-interactive environments.
---

# MATLAB Headless Execution Skill

## Overview
Guidelines for invoking MATLAB headlessly in batch mode on Linux, handling licenses, catching runtime errors, and saving clean outputs.

## Headless CLI Syntax
Always use the non-display, non-splash batch runner:
```bash
matlab -nodisplay -nosplash -batch "<MATLAB_CODE>"
```
Or for running a standalone script:
```bash
matlab -nodisplay -nosplash -batch "run('path/to/script.m')"
```

## Error Handling Pattern
Wrap top-level batch commands in `try...catch` blocks so that errors produce clean stderr diagnostics and exit with non-zero status codes:
```matlab
try
    % Execution logic
    run_sim();
catch ME
    fprintf(2, '[ERROR] %s\n', ME.message);
    for k = 1:length(ME.stack)
        fprintf(2, '  in %s at line %d\n', ME.stack(k).name, ME.stack(k).line);
    end
    exit(1);
end
exit(0);
```

## Vectorization & Performance Invariants
1. Never use scalar `for` loops across slip arrays or time grids for analytical calculations.
2. Preallocate all matrices and utilize array operators (`.*`, `./`, `.^`).
3. Set up workspace variables cleanly before executing Simulink models.
