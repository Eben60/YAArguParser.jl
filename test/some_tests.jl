using SimpleArgParse2

using SimpleArgParse2: AbstractArgumentParser, get_value, set_value!, positional_args, args2vec, 
    sort_args, canonicalname, getnestedparsers, throw_on_exception, generate_usage!

using Aqua, Suppressor


using Test

  
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



;