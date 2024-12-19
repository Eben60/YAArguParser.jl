using YAArguParser
using YAArguParser: parse_arg
using Test, Dates

@testset "ParseDates" begin
    @test parse_arg(DateTime, "2024-12-12T15:06:48", nothing) == (ok = true, v = DateTime("2024-12-12T15:06:48"), msg = nothing)
    @test parse_arg(DateTime, "2024-12-12 15:06:48.000", nothing) == (ok = true, v = DateTime("2024-12-12T15:06:48"), msg = nothing) 
    @test parse_arg(DateTime, "2024-12-12", nothing) == (ok = true, v = Date("2024-12-12"), msg = nothing)
    @test parse_arg(DateTime, "15:06:48", nothing) == (ok = true, v = Time("15:06:48"), msg = nothing)
    @test parse_arg(DateTime, "15:06:48.000", nothing) == (ok = true, v = Time("15:06:48"), msg = nothing)
    (;ok, v, msg) = parse_arg(DateTime, "01.01.01 15:06", nothing) 
    @test !ok && isnothing(v) && !isempty(msg)
end



;