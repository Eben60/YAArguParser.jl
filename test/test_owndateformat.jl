module OwnDateFormat

using Test
using Dates, OrderedCollections
using YAArguParser

using YAArguParser: add_argument!, args_pairs, parse_arg, parse_args!, ArgumentParser, AbstractValidator
import YAArguParser: specify_datetime_fmts

struct DatesUSA <: AbstractValidator
end

dates_usa = DatesUSA()

function specify_datetime_fmts(::DatesUSA)
    formats = OrderedDict(
        Date => ["mm/dd/yy"], # "mm/dd/yyyy"],
        DateTime => ["mm/dd/yy HH:MM p", "mm/dd/yyyy HH:MM p"],
    )

    wrong_formats = Regex[]
    return (;formats, wrong_formats)
end

@testset "OwnDateFormat" begin
    
    p = ArgumentParser();
    add_argument!(p, "-a", "--dt1", type=DateTime, default=DateTime("2001-12-31"), description="dt1", validator = dates_usa);
    add_argument!(p, "-b", "--dt2", type=DateTime, default=DateTime("2001-12-31"), description="dt2", validator = dates_usa);
    add_argument!(p, "-c", "--dt3", type=DateTime, default=DateTime("2001-12-31"), description="dt2", validator = dates_usa);
    add_argument!(p, "-d", "--dt4", type=DateTime, default=DateTime("2001-12-31"), description="dt2", validator = dates_usa);
    
    cli_args = ["-a", "12/30/24", "-b", "12/30/2024", "-c", "12/30/2024 11:44 AM", "-d", "12/30/24 07:55 PM"];
    
    parse_args!(p; cli_args);
    ap = args_pairs(p) |> NamedTuple

    @test ap == (dt1 = Date("0024-12-30"), dt2 = Date("2024-12-30"), dt3 = DateTime("2024-12-30T11:44:00"), dt4 = DateTime("0024-12-30T19:55:00"))

end # testset

end # module OwnDateFormat
;