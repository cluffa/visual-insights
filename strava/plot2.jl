using DataFrames
using Plots
using Dates
using Printf
using Statistics
using StravaConnect

struct Pace
    minutes::Float64
end

function Base.show(io::IO, p::Pace)
    minutes = floor(p.minutes)
    seconds = round((p.minutes - minutes) * 60)
    @printf io "%d'%02d\"/mi" minutes seconds
end

activities = begin
    u = (@isdefined u) ? u : setup_user()
    df = get_activity_list(u)
    reduce_subdicts!(df)
    fill_dicts!(df)
    
    df = DataFrame(df)
    println("Total activities: ", size(df, 1))
    println("Sample columns: ", names(df))
    
    # Convert to miles and minutes
    df.distance = df.distance .* 0.000621371 # meters to miles
    df.elapsed_time = df.elapsed_time ./ 60.0 # seconds to minutes
    df.average_speed = Pace.(df.elapsed_time ./ df.distance)
    
    df
end

begin
    df = copy(activities)
    # Parse dates using the correct ISO format with Z timezone indicator
    df[!, :YM] = Dates.format.(DateTime.(df.start_date, dateformat"yyyy-mm-ddTHH:MM:SSZ"), "Y-m")
    df = combine(groupby(df, :YM), :distance => sum, :elapsed_time => sum)
    df.AvgPace = df.elapsed_time_sum ./ df.distance_sum

    # Sort by date for better visualization
    sort!(df, :YM)
    
    println("\nMonthly summary:")
    println(df)

    p = plot(
        df[!, "YM"],
        df[!, "distance_sum"],
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
        df.AvgPace,
        label = "Average Pace",
        ylabel = "Average Pace (mins/mile)",
        yflip = true,
        color = :red,
        legend = :bottomright,
    )

    savefig(p, "strava/plots/monthly_distance.png")

    if isinteractive()
        display(p)
    end

    println("\nPlot saved to strava/plots/monthly_distance.png")
    p
end