using SimpleArgParse: ArgumentParser, add_argument!, add_example!, generate_usage, help, parse_args!, get_value, set_value! 

using SimpleArgParse: StrValidator, validate, RealValidator

using Test

@testset "SimpleArgParse tests" begin

    @testset "Testset empty constructor" begin
        p = ArgumentParser()
        @test isempty(p.description)
        @test isempty(p.authors)
        @test isempty(p.documentation)
        @test isempty(p.repository)
        @test isempty(p.license)
        @test isempty(p.usage)
        @test !p.add_help
    end

    @testset "Testset parameterized constructor" begin
        p = ArgumentParser(
            description="test",
            authors=["first last <first.last@foo.bar>"],
            documentation="server/docs",
            repository="server/repo",
            license="license",
            usage="julia main.jl --arg val",
            add_help=true
        )
        @test "test" == p.description
        @test ["first last <first.last@foo.bar>"] == p.authors
        @test "server/docs" == p.documentation
        @test "server/repo" == p.repository
        @test "license" == p.license
        @test "julia main.jl --arg val" == p.usage
        @test p.add_help
    end

    @testset "Testset add_argument!" begin
        p = ArgumentParser()
        add_argument!(p, "-f", "--foo", type=String, default="bar", description="baz")
        @test "bar" == get_value(p, "--foo")
        @test "bar" == get_value(p, "-f")
        @test "bar" == get_value(p, "f")
        @test_throws ArgumentError add_argument!(p, "", "", type=String, default="bar", description="baz")
    end

    @testset "Testset get_value" begin
        p = ArgumentParser()
        add_argument!(p, "-f", "--foo", type=String, default="bar", description="baz")
        @test "bar" == get_value(p, "--foo")
        @test "bar" == get_value(p, "-f")
        @test "bar" == get_value(p, "f")
        @test isa(get_value(p, "foo"), String)
    end
    
    @testset "Testset set_value!" begin
        p = ArgumentParser()
        add_argument!(p, "-f", "--foo", type=String, default="bar")
        @test "bar" == get_value(p, "--foo")
        p = set_value!(p, "--foo", "baz")
        @test "baz" == get_value(p, "--foo")
    end

    @testset "StrValidator" begin
        v1 = StrValidator(; val_list=["aaa", "BBB"])
        v1c = StrValidator(; case_sens=true, val_list=["aaa", "BBB"])
        v2 = StrValidator(; start_w=["yes", "no"])
        v3 = StrValidator(; case_sens=true, reg_ex=[r"^ab[cd]$"])
        @test_throws ErrorException StrValidator(; case_sens=true)

        @test validate("Aaa", v1) == (; ok=true, v="AAA")
        @test validate("Aaa", v1c) == (; ok=false, v=nothing) 
        @test validate("ye", v2) == (; ok=true, v="YES")
        @test validate("abc", v3) == (; ok=true, v="abc")
        @test validate("Abc", v3) == (; ok=false, v=nothing)

        p = ArgumentParser()
        @test_throws ArgumentError add_argument!(p, "-f", "--foo", type=String, default="bar", validator=v1)
        add_argument!(p, "-f", "--foo", type=String, validator=v1)
        set_value!(p, "--foo", "aaa")
        @test get_value(p, "--foo") == "AAA"
        @test_throws ArgumentError set_value!(p, "--foo", "abc")
    end

    @testset "RealValidator" begin
        @test_throws ErrorException RealValidator()
        rvl = RealValidator(;excl_vals=[1, 2], excl_ivls=[(10, 15), (20, 25)], incl_vals=[3, 4, 11], incl_ivls=[(100, Inf)])
        @test !validate(1, rvl).ok # == (; ok=false, v=nothing) 
        @test validate(11, rvl) == (; ok=false, v=nothing) 
        @test validate(50, rvl) == (; ok=false, v=nothing) 
        @test validate(3, rvl) == (; ok=true, v=3)  
        @test validate(111, rvl) == (; ok=true, v=111) 
        rv1 = RealValidator(;incl_ivls=[(10, 20), (30, 40), (100, Inf)])
        @test validate(111, rv1) == (; ok=true, v=111)
        @test validate(15, rv1) == (; ok=true, v=15)
        @test validate(25, rv1) == (; ok=false, v=nothing) 
        @test_throws ErrorException validate("25", rv1)

        p = ArgumentParser()
        @test_throws ArgumentError add_argument!(p, "-i", "--int", type=Int, default=1, validator=rvl)
        add_argument!(p, "-i", "--int", type=Int, validator=rvl)
        set_value!(p, "-i", 3)
        @test get_value(p, "--int") == 3
        @test_throws ArgumentError set_value!(p, "--foo", "abc")
    end


    @testset "Testset parse_args!" begin
        p = ArgumentParser()
        add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff")
        add_argument!(p, "-g", "--goo", type=String, default="ggg", description="Ggg")
        add_argument!(p, "-i", "--int", type=Int, default=0, description="integer")
        cli_args = ["-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)
        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test_throws ArgumentError get_value(p, "--bar")
        @test_throws ArgumentError parse_args!(p; cli_args=["-i", "1.5"])
    end

    @testset "Testset return Exception" begin
        p = ArgumentParser(; return_err = true)
        add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff")
        add_argument!(p, "-g", "--goo", type=String, default="ggg", description="Ggg")
        add_argument!(p, "-i", "--int", type=Int, default=0, description="integer")
        cli_args = ["-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)
        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--bar") isa ArgumentError
        @test parse_args!(p; cli_args=["-i", "1.5"]) isa ArgumentError
    end

end
;