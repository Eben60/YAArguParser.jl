using YAArguParser

using YAArguParser: AbstractArgumentParser, get_value, set_value!, 
    positional_args, args2vec, sort_args, canonicalname, getnestedparsers, 
    throw_on_exception, generate_usage!, validate, shell_split

using Aqua, Suppressor

alltests = !(isdefined(@__MODULE__, :complete_tests) && !complete_tests)
alltests && Aqua.test_all(YAArguParser)

using Test



@testset "Testset empty constructor" begin
    p = ArgumentParser()
    @test isempty(p.description)
    @test isempty(p.usage)
    @test !p.add_help
end

@testset "Testset parameterized constructor" begin

    ap = ArgumentParser(
        description="test",
        usage="julia main.jl --arg val",
        add_help=true,
        color = "magenta",
        )

    p = InteractiveArgumentParser(; ap,
        throw_on_exception = false,
        introduction = "story to tell",
        prompt = "--/ ",
        )

    @test "test" == p.description
    @test "julia main.jl --arg val" == p.usage
    @test p.add_help
    @test !p.throw_on_exception
    @test p.color == "magenta"
    @test p.introduction == "story to tell"
    @test p.prompt == "--/ "
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
    set_value!(p, "--foo", "baz")
    @test "baz" == get_value(p, "--foo")
end

@testset "StrValidator" begin
    @suppress_out begin
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
    end # suppress  
end

@testset "RealValidator" begin
    @suppress_out begin

        @test_throws ErrorException RealValidator{Int}()
        rvl = RealValidator{Int}(;excl_vals=[1, 2], excl_ivls=[(10, 15), (20, 25)], incl_vals=[3, 4, 11], incl_ivls=[(100, typemax(Int))])
        @test !validate(1, rvl).ok # == (; ok=false, v=nothing) 
        @test validate(11, rvl) == (; ok=false, v=nothing) 
        @test validate(50, rvl) == (; ok=false, v=nothing) 
        @test validate(3, rvl) == (; ok=true, v=3)  
        @test validate(111, rvl) == (; ok=true, v=111) 
        rv1 = RealValidator{Float64}(;incl_ivls=[(10, 20), (30, 40), (100, Inf)])
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

        rvl1 = RealValidator{Int}(;excl_vals=[1, 2])
        @test validate(11, rvl1) == (; ok=true, v=11)        
        @test validate(1, rvl1) == (; ok=false, v=nothing) 

    end # suppress  
end

@testset "Testset parse_args!" begin
    p = ArgumentParser();
    add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff");
    add_argument!(p, "-g", "--goo", type=String, default="ggg", description="Ggg");
    add_argument!(p, "-i", "--int", type=Int, default=0, description="integer");
    add_argument!(p, "-j", "--negint", type=Int, default=0, description="integer why not negative");
    add_argument!(p, "-b", "--bool1", type=Bool, default=false, description="bool 1");
    add_argument!(p, "-p", "--bool2", type=Bool, default=false, description="bool 2");
    add_argument!(p, "-r", "--bool3", type=Bool, description="bool 3 required");
    cli_args = ["-goo", "Gggg", "-b", "-f", "Ffff", "--bool3", "false", "-i", "1", "--negint", "-13", "--bool2"];

    p0 = deepcopy(p)

    parse_args!(p; cli_args);

    @test get_value(p, "--foo") == "Ffff"
    @test get_value(p, "--goo") == "Gggg"
    @test get_value(p, "--int") == 1
    @test get_value(p, "--negint") == -13
    @test get_value(p, "-b")
    @test get_value(p, "-p")
    @test !get_value(p, "-r")        
    @test_throws ArgumentError get_value(p, "--bar")
    @test_throws ArgumentError parse_args!(p; cli_args=["-i", "1.5"])

    p = deepcopy(p0)

    cli_args = ["-goo", "Gggg", "-b", "-f", "Ffff", "-i", "1", "--bool2"];
    @test_throws ArgumentError parse_args!(p; cli_args);

    p = deepcopy(p0)

    cli_args = ["-goo", "Gggg", "-b", "-f", "Ffff", "-i"];
    @test_throws ArgumentError parse_args!(p; cli_args);
end

@testset "Testset return Exception" begin
    p = InteractiveArgumentParser();
    p0 = deepcopy(p)
    add_argument!(p, "-f", "--foo", type=String, default="fff", description="Fff");
    add_argument!(p, "-g", "--goo", type=String, default="ggg", description="Ggg")
    add_argument!(p, "-i", "--int", type=Int, default=0, description="integer")
    add_argument!(p, "-b", "--boolean", type=Bool, default=false, description="boolean")
    cli_args = ["-goo", "Gggg", "-f", "Ffff", "-i", "1", "-b", "true"]
    parse_args!(p; cli_args)
    @test get_value(p, "--foo") == "Ffff"
    @test get_value(p, "--goo") == "Gggg"
    @test get_value(p, "--int") == 1
    @test get_value(p, "-b")
    @test ! throw_on_exception(p)
    @test get_value(p, "--bar") isa ArgumentError
    p = deepcopy(p0)
    @test parse_args!(p; cli_args=["-i", "1.5"]) isa ArgumentError

    p = deepcopy(p0)
    cli_args = ["-goo", "Gggg", "-f", "Ffff", "-i",]
    @test parse_args!(p; cli_args) isa ArgumentError       
end

@testset "nothing is an valid default value" begin
    p = ArgumentParser();
    add_argument!(p, "-f", "--foo", type=String, default=nothing, description="Fff");
    add_argument!(p, "-i", "--int", type=Int, default=nothing, description="integer")
    add_argument!(p, "-b", "--boolean", type=Bool, default=nothing, description="boolean")
    parse_args!(p; cli_args=[])
    @test isnothing(get_value(p, "--foo"))
    @test isnothing(get_value(p, "--int"))
    @test isnothing(get_value(p, "-b"))
end

@testset "Check missing arguments" begin
    p = ArgumentParser();
    add_argument!(p, "-f", "--foo", type=String, description="Required argument");
    @test_throws ArgumentError parse_args!(p; cli_args=[]) 
end

@testset "Positional args" begin
    generated_usage = "\nUsage: $PROGRAM_FILE [ <Int64>] [ <Int64>] [ <Int64>] [-f|--foo <String>] [-g|--goo <String>] [-i|--int <Int64>] [-a|--abort]\n\n\n\nOptions:\n  --pos1 <Int64>\tinteger1\t (positional arg)\n  --pos2 <Int64>\tinteger2\t (positional arg)\n  --pos3 <Int64>\tinteger3\t (positional arg)\n  -f, --foo <String>\tFff\n  -g, --goo <String>\tGgg\n  -i, --int <Int64>\tinteger\n  -a, --abort\t\tabort\n\nExamples:\n  \$ 1 2 3 -f \"string 1\" -int 4\n  \$ 4 5 6 -goo \"string 2\" -i 7\n"
    
    @suppress_out begin
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

        p = deepcopy(p0)
        add_argument!(p, "", "--posn", type=Int, default=0, positional=true, description="integer")
        cli_args = ["1.5", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        @test_throws ArgumentError parse_args!(p; cli_args)

        p = deepcopy(p0)
        rvl = RealValidator{Int}(;incl_vals=[3, 4, 6]);
        add_argument!(p, "", "--posn", type=Int, positional=true, description="integer", validator=rvl);
        cli_args = ["2", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];
        @test_throws ArgumentError parse_args!(p; cli_args)
        cli_args = ["3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)
        @test get_value(p, "--posn") == 3 

        p1 = deepcopy(p0)
        add_argument!(p1, "", "--pos1", type=Int, default=0, positional=true, description="integer1");
        add_argument!(p1, "", "--pos2", type=Int, default=0, positional=true, description="integer2");
        add_argument!(p1, "", "--pos3", type=Int, default=0, positional=true, description="integer3");
        add_example!(p1, "1 2 3 -f \"string 1\" -int 4");
        add_example!(p1, "4 5 6 -goo \"string 2\" -i 7");
        generate_usage!(p1);
        @test p1.usage == generated_usage

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
        add_argument!(p1, "", "--pos2", type=Int, positional=true, description="integer");
        add_argument!(p1, "", "--pos3", type=Int, positional=true, description="integer");

        p = deepcopy(p1);
        cli_args = ["1", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];

        @test_throws ArgumentError parse_args!(p; cli_args)
    end
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

@testset "sort_args" begin
    p = ArgumentParser();
    add_argument!(p, "", "pos1", type=Int, positional=true, default=0, description="integer")
    add_argument!(p, "", "pos2", type=String, positional=true, default="", description="integer")
    add_argument!(p, "", "pos3", type=Int, positional=true, default=0, description="integer")
    add_argument!(p, "", "--cycles", type=Int);
    add_argument!(p, "", "--cont", type=String);
    (;pos_args, keyed_args, all_args) = sort_args(p)
    @test [canonicalname(a) for a in pos_args] == ["pos1", "pos2", "pos3"]
    @test [canonicalname(a) for a in keyed_args] == ["cycles", "cont"]
    @test [canonicalname(a) for a in all_args] == ["pos1", "pos2", "pos3", "cycles", "cont"]
    
end

@testset "shell_split" begin
    @test shell_split("foo bar baz") == ["foo", "bar", "baz"]
    @test shell_split("foo\\ bar baz") == ["foo bar", "baz"]
    @test shell_split("'foo bar' baz") == ["foo bar", "baz"]
    # "Over quoted"
    @test shell_split("'foo\\ bar' baz") == ["foo\\ bar", "baz"]
    @test shell_split("\"foo\\ bar\" baz") == ["foo\\ bar", "baz"]

    p = ArgumentParser();
    add_argument!(p, "", "pos1", type=Int, positional=true, default=0, description="integer1")
    add_argument!(p, "", "pos2", type=String, positional=true, default="", description="string2")
    add_argument!(p, "", "pos3", type=Bool, positional=true, default=false, description="bool3")
    add_argument!(p, "-i", "--int4", type=Int);
    add_argument!(p, "-s", "--str5", type=String);
    add_argument!(p, "-b", "--bool6", type=Bool);

    cli_args = shell_split("1 s2 true -s s5 -int4 4 -b false")
    parse_args!(p; cli_args);

    @test get_value(p, "pos1") == 1
    @test get_value(p, "pos2") == "s2"
    @test get_value(p, "pos3")
    @test get_value(p, "--int4") == 4 
    @test get_value(p, "--str5") == "s5" 
    @test !get_value(p, "-b")            
end

@testset "Extensible ArgumentParser" begin
    include("../src/legacy_parser.jl")
    ap = ArgumentParser()
    lp = LegacyArgumentParser(; documentation="bar", ap=ArgumentParser(;description="baz"))
    @test isempty(getnestedparsers(ap))
    @test getnestedparsers(lp)[1] isa ArgumentParser
    @test hasproperty(lp, :documentation)
    @test hasproperty(lp, :ap)
    @test hasproperty(lp, :kv_store)
    @test hasproperty(ap, :kv_store)
    @test ! hasproperty(lp, :not_a_property)
    @test lp.documentation == "bar" 
    @test lp.description == "baz"
    @test_throws ErrorException lp.not_a_property

    @test_throws ErrorException initparser(InteractiveArgumentParser; wrongfield=1)
    @test initparser(InteractiveArgumentParser, false; wrongfield=1, add_help=true).add_help
#       
    ip = initparser(InteractiveArgumentParser; 
        description="blablabla", color="magenta", add_help=true, throw_on_exception=true)
    
    @test ip.throw_on_exception
    @test ip.ap.description == ip.description == "blablabla"
    @test Set(propertynames(ip)) == Set((:ap, :kv_store, :arg_store, :lng, :description, :filename, 
        :usage, :examples, :add_help, :color, :throw_on_exception, :introduction, :prompt))

    @kwdef struct RedundantParser  <: AbstractArgumentParser
        ap1::ArgumentParser = ArgumentParser()
        foo::String = ""
        ap2::ArgumentParser = ArgumentParser()
    end

    @test_throws ErrorException initparser(RedundantParser; foo="FOO")
end

include("test_datetime.jl")

include("test_owndateformat.jl")
