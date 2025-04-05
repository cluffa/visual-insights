using Plots
using DataFrames
using Random
using Dates
using ProgressMeter
using StravaConnect
Random.seed!(1234)

background = :white
colors = Symbol.(keys(Plots.Colors.color_names))

# Get activities from Strava API
u = (@isdefined u) ? u : setup_user()
activity_list = get_activity_list(u)
reduce_subdicts!(activity_list)
fill_dicts!(activity_list)
activity_df = DataFrame(activity_list)

println("Total activities before filter: ", size(activity_df, 1))

filter!(activity_df) do row
    !isnothing(row.map_summary_polyline) && length(row.map_summary_polyline) > 0
end

println("Activities with map data: ", size(activity_df, 1))

# Get detailed data for each activity
activities = DataFrame[]
@showprogress for id in activity_df.id
    act = get_activity(id, u)
    println("Activity ID: ", id)
    println("Keys in activity: ", keys(act))
    reduce_subdicts!(act)
    # fill_dicts!(act) does not work for dicts, only vectors of dicts
    
    if haskey(act, :latlng_data) && !isnothing(act[:latlng_data]) && !isempty(act[:latlng_data])
        println("Found lat/lng data for activity: ", id)
        df = DataFrame(
            lat = Float64[p[1] for p in act[:latlng_data]],
            lon = Float64[p[2] for p in act[:latlng_data]],
            ele = act[:altitude_data],
            time = DateTime.(act[:time_data])
        )
        
        df.y = df.lat .- df.lat[1]
        df.x = df.lon .- df.lon[1]
        
        push!(activities, df)
    else
        println("No lat/lng data for activity: ", id)
    end
end

println("Activities with complete data: ", length(activities))

println("\nStarting Delaware State Park plot...")
begin
    latmin, lonmin = 40.380824, -83.068371
    latmax, lonmax = 40.413487, -83.047552

    println("Activities count: ", length(activities))
    println("First activity data sample:")
    if length(activities) > 0
        println("Lat range: ", extrema(activities[1].lat))
        println("Lon range: ", extrema(activities[1].lon))
    end

    local p = plot(
        title = "Delaware State Park",
        legend = false,
        xaxis = false,
        yaxis = false,
        grid = false,
        ticks = false,
        size = (800, 1000),
        dpi = 500,
        aspect_ratio = :equal,
        background = background,
        xlims = (lonmin, lonmax),
        ylims = (latmin, latmax),
    )

    for i in eachindex(activities)
        plot!(
            p,
            activities[i][!, :lon],
            activities[i][!, :lat],
            alpha = 0.5,
            linewidth = 2,
        )
    end

    println("Saving Delaware plot...")
    savefig(p, "strava/plots/activities_delaware.png")
    if isinteractive()
        display(p)
    end
end

println("\nStarting zeroed activities plot...")
# zeroed overlapped activities
begin
    local p = plot(
        legend = false,
        xaxis = false,
        yaxis = false,
        grid = false,
        ticks = false,
        # size = (1000, 500),
        dpi = 500,
        aspect_ratio = :equal,
        background = background,
    )

    for i in eachindex(activities)
        plot!(
            activities[i][!, :x],
            activities[i][!, :y],
            alpha = 0.5
        )
    end

    if isinteractive()
        display(p)
    end
    savefig(p, "strava/plots/activities_zeroed.png")
end

# grid of activities
begin
    plots = []

    for i in eachindex(activities)
        
        local p = plot(
            legend = false,
            xaxis = false,
            yaxis = false,
            grid = false,
            ticks = false,
            # size = (1000, 500),
            dpi = 500,
            aspect_ratio = :equal,
            background = background,
            activities[i][!, :x],
            activities[i][!, :y],
            # alpha = 0.5
            # color = rand(colors)
            color = :orangered
        )

        push!(plots, p)
    end

    shuffle!(plots)
    local p = plot(plots...)

    if isinteractive()
        display(p)
    end
    
    savefig(p, "strava/plots/activities_grid.png")
end;

