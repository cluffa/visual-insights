using DataFrames
using Plots
using CSV
using Dates
using Printf
using Statistics

struct Pace
    minutes::Float64
end

function Base.show(io::IO, p::Pace)
    minutes = floor(p.minutes)
    seconds = round((p.minutes - minutes) * 60)
    @printf io "%d'%02d\"/mi" minutes seconds
end

"returns a new column name with no spaces or special characters, and capitalized first letters"
function newName(name::String)
    name = split(name)
    name = join(uppercasefirst.(name))
    name = replace(name, r"[^a-zA-Z0-9]" => "")
    name = Symbol(name)
end

activities = begin
    df = CSV.read("strava/data/activities.csv", DataFrame, dateformat = dateformat"u dd, y, HH:MM:SS p")

    rename!(newName, df)
    df.Distance = df.Distance .* 0.621371
    df.ElapsedTime = df.ElapsedTime ./ 60
    df.AvgPace = Pace.(df.ElapsedTime ./ df.Distance)

    df
end

begin
    df = copy(activities)
    df[!, :YM] = Dates.format.(df[!, :ActivityDate], "Y-m")
    df = combine(groupby(df, :YM), :Distance => sum, :ElapsedTime => sum)
    df.AvgPace = df.ElapsedTime_sum ./ df.Distance_sum

    p = plot(
        df[!, "YM"],
        df[!, "Distance_sum"],
        title = "Monthly Distance",
        xlabel = "Month",
        ylabel = "Distance (miles)",
        label = "Distance",
        legend = :bottomleft,
        dpi = 500,
    )

    plot!(
        twinx(),
        df[!, "YM"],
        df[!, "AvgPace"],
        label = "Average Pace",
        ylabel = "Average Pace (mins/mile)",
        yflip = true,
        color = :red,
        legend = :bottomright,
    )

    savefig(p, "strava/plots/monthly_distance.png")
    
    p
end