# CPS_test_generation
Test Case Generation study for CPS 2022-2023


## Requirement
Please install MATLAB2021b or higher and the Simulink comes with MATLAB2021b or higher. The test case selection approach proposed in this study requires to run simulation during the search algorithm.

## Reproduction step
1. Clone or download the entire repo.
2. Open MATLAB, navigate to the downloaded folder.
3. In the MATLAB folder panel, right click the root folder (if not renamed, should be "CPS_test_generation"), select **Add to path -> Selected folder and subfolders**.
4. Open **demo.m**. This is the main script to start the experiment.
5. You can adjust the experiment settings in **demo.m**. Basic settings are in the following lines:
```
%%% define some experiment parameters (adjust based on design)
repeat = 20;
cp_number = 5;
n_samples = 256;
n_tests = 32;
```
- repeat: number of experiments to run for generality
- cp_number: number of control points for generating the input signal. Usually 3, 5 or 10 in literature.
- n_samples: number of initial random samples for GenClu algorithm. In our case studies, 256 is enough. (May need to adjust based on different case studies)
- n_tests: number of tests generated in the final test suite.
6. Comment or uncomment to choose the case study you want to run.
7. Click **Run** botton to start the experiment.

## Additional tips
1. You can choose which algorithm to run in the **utils/experiment_runner.m** file:
```
%   running_mode = ["random", "epicurus", "sway", "od"];
    running_mode = ["random", "sway"];
```
- first line is to run all approaches. If you want to run all, comment it in
- second line in the above example means only run Random approach and GenClu approach (which we represent it as **sway**). You can modify this to run different approach.
2. Terminal will show the running progress
3. When experiment is finished, the mutation score for 20 repeats will be printed in the terminal. Also the overall runtime for the experiment will be printed also right after the mutation score. You need to enter those mutation scores to a .txt file like the files in the **evaluation** folder.
4. To evaluate results, please follow the instruction in the **evaluation** folder.
