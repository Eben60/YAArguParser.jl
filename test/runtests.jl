using SimpleArgParse

using SimpleArgParse: ArgumentParser, add_argument!, add_example!, generate_usage!, help, parse_args!, get_value, set_value! 

using SimpleArgParse: StrValidator, validate, RealValidator, positional_args, args_pairs, ArgForms, args2vec

# using Aqua
# Aqua.test_all(SimpleArgParse)

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

        ia = InteractiveUsage(throw_on_exception = false,
            color = "magenta",
            introduction = "story to tell",
            prompt = "--/ ",
            )
    
        p = ArgumentParser(
            description="test",
            authors=["first last <first.last@foo.bar>"],
            documentation="server/docs",
            repository="server/repo",
            license="license",
            usage="julia main.jl --arg val",
            add_help=true,
            interactive=ia,
            )

        @test "test" == p.description
        @test ["first last <first.last@foo.bar>"] == p.authors
        @test "server/docs" == p.documentation
        @test "server/repo" == p.repository
        @test "license" == p.license
        @test "julia main.jl --arg val" == p.usage
        @test p.add_help
        @test !p.interactive.throw_on_exception
        @test p.interactive.color == "magenta"
        @test p.interactive.introduction == "story to tell"
        @test p.interactive.prompt == "--/ "
    end

    @testset "Testset add_argument!" begin
        p = ArgumentParser()
        add_argument!(p, "-f", "--foo", type=String, default="bar", description="baz")
        @test "bar" == get_value(p, "--foo")
        @test "bar" == get_value(p, "-f")
        @test "bar" == get_value(p, "f")

        # at least one of the argument forms must be non-empty
        @test_throws ArgumentError add_argument!(p, "", "", type=String, default="bar", description="baz")

        # argument of that name already present
        @test_throws ErrorException add_argument!(p, "-f", "", type=String, default="bar", description="baz")
        @test_throws ErrorException add_argument!(p, "", "--foo", type=String, default="bar", description="baz")    
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
        v1 = StrValidator(; upper_case=true, patterns=["aaa", "BBB"])
        v1c = StrValidator(;  patterns=["aaa", "BBB"])
        v2 = StrValidator(; upper_case=true, starts_with=true, patterns=["yes", "no"])
        v3 = StrValidator(; patterns=[r"^ab[cd]$"])

        @test validate("Aaa", v1) == (; ok=true, v="AAA")
        @test validate("Aaa", v1c) == (; ok=false, v=nothing) 
        @test validate("ye", v2) == (; ok=true, v="YES")
        @test validate("abc", v3) == (; ok=true, v="abc")
        @test validate("Abc", v3) == (; ok=false, v=nothing)

        p = ArgumentParser()
        @test_throws ArgumentError add_argument!(p, "-f", "--foo", type=String, default="bar", validator=v1)
        p = ArgumentParser()
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
        p = ArgumentParser()
        add_argument!(p, "-i", "--int", type=Int, validator=rvl)
        set_value!(p, "-i", 3)
        @test get_value(p, "--int") == 3
        @test_throws ArgumentError set_value!(p, "--foo", "abc")

        rvl1 = RealValidator(;excl_vals=[1, 2])
        @test validate(11, rvl1) == (; ok=true, v=11)        
        @test validate(1, rvl1) == (; ok=false, v=nothing)    
    end


    @testset "Testset parse_args!" begin
        p = ArgumentParser();
        add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff");
        add_argument!(p, "-g", "--goo", type=String, default="ggg", description="Ggg");
        add_argument!(p, "-i", "--int", type=Int, default=0, description="integer");
        cli_args = ["-goo", "Gggg", "-f", "Ffff", "-i", "1"];
        parse_args!(p; cli_args);
        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test_throws ArgumentError get_value(p, "--bar")
        @test_throws ArgumentError parse_args!(p; cli_args=["-i", "1.5"])
    end

    @testset "Testset return Exception" begin
        p = ArgumentParser(; interactive=InteractiveUsage());
        add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff");
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

    @testset "Positional args" begin
        p0 = ArgumentParser();
        add_argument!(p0, "-f", "--foo", type=String, default="fff", description="Fff");
        add_argument!(p0, "-g", "--goo", type=String, default="ggg", description="Ggg");
        add_argument!(p0, "-i", "--int", type=Int, default=0, description="integer");
        add_argument!(p0, "-a", "--abort", type=Bool, default=false, description="abort");
        generate_usage!(p0);

        p = deepcopy(p0);
        add_argument!(p, "", "--posn", type=Int, default=0, positional=true, description="integer")

        @test length(positional_args(p)) == 1
        @test length(args_pairs(p)) == 5

        cli_args = ["3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]

        parse_args!(p; cli_args)
        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--posn") == 3                
        @test_throws ErrorException add_argument!(p, "", "--pos2", type=Int, default=nothing, required=false, positional=true, description="integer2")

        p = deepcopy(p0)
        add_argument!(p, "", "--posn", type=Int, default=0, positional=true, description="integer")
        cli_args = ["1.5", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        @test_throws ArgumentError parse_args!(p; cli_args)

        p = deepcopy(p0)
        rvl = RealValidator(;incl_vals=[3, 4, 6]);
        add_argument!(p, "", "--posn", type=Int, positional=true, required=true, description="integer", validator=rvl);
        cli_args = ["2", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];
        @test_throws ArgumentError parse_args!(p; cli_args)
        cli_args = ["3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)
        @test get_value(p, "--posn") == 3 

        p1 = deepcopy(p0)
        add_argument!(p1, "", "--pos1", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "--pos2", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "--pos3", type=Int, default=0, positional=true, description="integer")

        p = deepcopy(p1)
        cli_args = ["1", "2", "3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--pos1") == 1 
        @test get_value(p, "--pos2") == 2 
        @test get_value(p, "--pos3") == 3

        p1 = deepcopy(p0)
        add_argument!(p1, "", "pos1", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "pos2", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "pos3", type=Int, default=0, positional=true, description="integer")

        p = deepcopy(p1)
        cli_args = ["1", "2", "3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "pos1") == 1 
        @test get_value(p, "pos2") == 2 
        @test get_value(p, "pos3") == 3

        @test args_pairs(p) == [:foo => "Ffff", :goo => "Gggg", :int => 1, :abort => false, :pos1 => 1, :pos2 => 2, :pos3 => 3]

        p = deepcopy(p1)
        cli_args = ["1", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--pos1") == 1 
        @test get_value(p, "--pos2") == 0 
        @test get_value(p, "--pos3") == 0

        p1 = deepcopy(p0);
        add_argument!(p1, "", "--pos1", type=Int, default=0, positional=true, description="integer");
        add_argument!(p1, "", "--pos2", type=Int, positional=true, required=true, description="integer");
        add_argument!(p1, "", "--pos3", type=Int, positional=true, required=true, description="integer");

        p = deepcopy(p1);
        cli_args = ["1", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];
        @test_throws ArgumentError parse_args!(p; cli_args)
    end

    @testset "positional yes or no" begin
        p0 = ArgumentParser();
        vl = StrValidator(; upper_case=true, starts_with=true, patterns=["yes", "no"]);
        add_argument!(p0, "", "--cont", type=String, default="no", positional=true, description="continue or not!", validator=vl);

        p = deepcopy(p0)
        cli_args = ["ye"];
        parse_args!(p; cli_args)
        @test get_value(p, "--cont") == "YES"

        p = deepcopy(p0);
        cli_args = [];
        parse_args!(p; cli_args);
        @test get_value(p, "--cont") == "NO"
    end

    @testset "various internals" begin
        @test args2vec(ArgForms("-f", "--foo")) == ["-f", "--foo"]
        @test args2vec(ArgForms("", "--foo")) == ["--foo"]
    end

end

;