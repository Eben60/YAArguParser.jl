using Pkg, Coverage
Pkg.test("YAArguParser"; coverage=true)

srcfolder = normpath(@__DIR__, "../../src")
coverage = process_folder(srcfolder)

open("lcov.info", "w") do io
    LCOV.write(io, coverage)
end;
