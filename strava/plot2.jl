using DataFrames
using Plots
using Dates
using Printf
using Statistics
using StravaConnect

activities = begin
    df = get_cached_activity_list()
    reduce_subdicts!(df)
    fill_dicts!(df)
    
    df = DataFrame(df)
    println("Total activities: ", size(df, 1))
    println("Sample columns: ", names(df))
    
    # Convert to miles and minutes
    df.distance = df.distance .* 0.000621371 # meters to miles
    df.elapsed_time = df.elapsed_time ./ 60.0 # seconds to minutes
    
    df
end

# run stats
begin
    df = copy(activities)
    # Parse dates using the correct ISO format with Z timezone indicator
    df[!, :YM] = Dates.format.(DateTime.(df.start_date, dateformat"yyyy-mm-ddTHH:MM:SSZ"), "Y-m")
    filter!(df) do row
        contains(lowercase(row.sport_type), "run")
    end

    df = combine(groupby(df, :YM), :distance => sum, :elapsed_time => sum)
    df.avg_pace = df.elapsed_time_sum ./ df.distance_sum

    # Sort by date for better visualization
    sort!(df, :YM)
    
    println("\nMonthly summary:")
    println(df)

    p = plot(
        df[!, "YM"],
        df[!, "distance_sum"],
        title = "Monthly Runing Stats",
        xlabel = "Month",
        ylabel = "Distance (miles)",
        label = "Distance",
        legend = :bottomleft,
        dpi = 500,
    )

    plot!(
        twinx(),
        df[!, "YM"],
        df.avg_pace,
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

# ride stats
begin
    df = copy(activities)
    # Parse dates using the correct ISO format with Z timezone indicator
    df[!, :YM] = Dates.format.(DateTime.(df.start_date, dateformat"yyyy-mm-ddTHH:MM:SSZ"), "Y-m")
    filter!(df) do row
        contains(lowercase(row.sport_type), "ride")
    end

    df = combine(groupby(df, :YM), :distance => sum, :elapsed_time => sum)
    df.avg_speed = df.distance_sum ./ (df.elapsed_time_sum ./ 60.0) # miles / (minutes / 60) => mph

    # Sort by date for better visualization
    sort!(df, :YM)

    println("\nMonthly ride summary:")
    println(df)

    p = plot(
        df[!, "YM"],
        df[!, "distance_sum"],
        title = "Monthly Ride Stats",
        xlabel = "Month",
        ylabel = "Distance (miles)",
        label = "Distance",
        legend = :bottomleft,
        dpi = 500,
    )

    plot!(
        twinx(),
        df[!, "YM"],
        df.avg_speed,
        label = "Average Speed",
        ylabel = "Average Speed (mph)",
        yflip = true,
        color = :red,
        legend = :bottomright,
    )

    savefig(p, "strava/plots/monthly_ride_distance.png")

    if isinteractive()
        display(p)
    end

    println("\nPlot saved to strava/plots/monthly_ride_distance.png")
    p
end