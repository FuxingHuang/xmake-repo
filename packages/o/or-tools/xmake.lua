package("or-tools")
    set_homepage("https://developers.google.com/optimization/")
    set_description("Google's Operations Research tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/or-tools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/or-tools.git")

    add_versions("v9.9", "8c17b1b5b05d925ed03685522172ca87c2912891d57a5e0d5dcaeff8f06a4698")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        -- table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        -- table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DEPS=ON")
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
           #include "ortools/linear_solver/linear_solver.h"
           #include "ortools/linear_solver/linear_solver.pb.h"
             void RunTest(
               MPSolver::OptimizationProblemType optimization_problem_type) {
               MPSolver solver("Glop", optimization_problem_type);
               MPVariable* const x = solver.MakeNumVar(0.0, 1, "x");
               MPVariable* const y = solver.MakeNumVar(0.0, 2, "y");
               MPObjective* const objective = solver.MutableObjective();
               objective->SetCoefficient(x, 1);
               objective->SetCoefficient(y, 1);
               objective->SetMaximization();
               solver.Solve();
               printf("\nSolution:");
               printf("\nx = %.1f", x->solution_value());
               printf("\ny = %.1f", y->solution_value());
             }
        ]]}, {configs = {languages = "c++17"}}))
    end)
