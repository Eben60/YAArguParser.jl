module ParseDates

using Test
using YAArguParser: add_argument!, args_pairs, parse_arg, parse_args!, ArgumentParser
using Dates

@testset "ParseDates" begin
    @test parse_arg(DateTime, "2024-12-31T15:06:48", nothing) == (ok = true, v = DateTime("2024-12-31T15:06:48"), msg = nothing)
    @test parse_arg(DateTime, "2024-12-31 15:06:48.000", nothing) == (ok = true, v = DateTime("2024-12-31T15:06:48"), msg = nothing) 
    @test parse_arg(DateTime, "2024-12-31", nothing) == (ok = true, v = Date("2024-12-31"), msg = nothing)
    @test parse_arg(DateTime, "31.12.2024", nothing) == (ok = true, v = Date("2024-12-31"), msg = nothing)
    @test parse_arg(Date, "31.12.2024", nothing) == (ok = true, v = Date("2024-12-31"), msg = nothing)
    @test parse_arg(DateTime, "15:06:48", nothing) == (ok = true, v = Time("15:06:48"), msg = nothing)
    @test parse_arg(Time, "15:06:48", nothing) == (ok = true, v = Time("15:06:48"), msg = nothing)
    @test parse_arg(DateTime, "15:06:48.000", nothing) == (ok = true, v = Time("15:06:48"), msg = nothing)

    (;ok, v, msg) = parse_arg(DateTime, "01.01.01 15:06", nothing) 
    @test !ok && isnothing(v) && !isempty(msg)
    (;ok, v, msg) = parse_arg(Date, "2024-12-31T15:06:48", nothing) 
    @test !ok && isnothing(v) && !isempty(msg)
    (;ok, v, msg) = parse_arg(Time, "2024-12-31T15:06:48", nothing) 
    @test !ok && isnothing(v) && !isempty(msg)
    (;ok, v, msg) = parse_arg(Time, "2024-12-31", nothing)
    @test !ok && isnothing(v) && !isempty(msg)
    (;ok, v, msg) = parse_arg(Date, "15:06:48", nothing)
    @test !ok && isnothing(v) && !isempty(msg)

    p = ArgumentParser();
    add_argument!(p, "-a", "--dt1", type=DateTime, default=DateTime("2001-12-31"), description="dt1");
    add_argument!(p, "-b", "--dt2", type=DateTime, default=DateTime("2001-12-31"), description="dt2");
    add_argument!(p, "-c", "--dt3", type=DateTime, default=DateTime("2001-12-31"), description="dt2");
    add_argument!(p, "-d", "--dt4", type=DateTime, default=DateTime("2001-12-31"), description="dt2");
    add_argument!(p, "-e", "--dt5", type=DateTime, default=DateTime("2001-12-31"), description="dt2");

    cli_args = ["-a", "2024-12-31T15:06:48", "-b", "2024-12-31 15:06:48.000", "-c", "2024-12-31", "-d", "31.12.2024", "-e", "23:55:59"];
    parse_args!(p; cli_args);
    ap = args_pairs(p) |> NamedTuple
    @test ap == (dt1 = DateTime("2024-12-31T15:06:48"), dt2 = DateTime("2024-12-31T15:06:48"), dt3 = Date("2024-12-31"), dt4 = Date("2024-12-31"), dt5 = Time(23, 55, 59))

end # testset

end # module ParseDates
