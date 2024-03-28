using SimpleArgParse: ArgumentParser, add_argument!, add_example!, generate_usage, help, parse_args!, get_value, set_value! 

using SimpleArgParse: StrValidator, validate

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

        @test validate("Aaa", v1) == (; ok=true, s="AAA")
        @test validate("Aaa", v1c) == (; ok=false, s=nothing) 
        @test validate("ye", v2) == (; ok=true, s="YES")
        @test validate("abc", v3) == (; ok=true, s="abc")
        @test validate("Abc", v3) == (; ok=false, s=nothing)

        p = ArgumentParser()
        @test_throws ErrorException add_argument!(p, "-f", "--foo", type=String, default="bar", validator=v1)
        add_argument!(p, "-f", "--foo", type=String, validator=v1)
        set_value!(p, "--foo", "aaa")
        @test "AAA" == get_value(p, "--foo")
        @test_throws ErrorException set_value!(p, "--foo", "abc")
    end

end
