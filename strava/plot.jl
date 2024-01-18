using GZip
using XMLDict
using ProgressMeter
using DataFrames
using Plots
using Random
using Dates
Random.seed!(1234)

background = :white

colors = Symbol.(keys(Plots.Colors.color_names))

activity_files = [file for file in readdir("strava/data/activities/", sort = true, join = true) if contains(file, ".tcx.gz")]

begin
    activities = DataFrame[]
    @showprogress for file in activity_files
        tcx = GZip.open(file, "r") do io
            xml_dict(strip(String(read(io))))
        end

        local df = DataFrame(
            lat = Float64[],
            lon = Float64[],
            ele = Float64[],
            time = DateTime[]
        )

        points = tcx["TrainingCenterDatabase"]["Activities"]["Activity"]["Lap"]["Track"]["Trackpoint"][2:end]

        for point in points
            if haskey(point, "Position")
                try
                    push!(df, (
                        lat = parse(Float64, point["Position"]["LatitudeDegrees"]),
                        lon = parse(Float64, point["Position"]["LongitudeDegrees"]),
                        ele = parse(Float64, point["AltitudeMeters"]),
                        time = DateTime(point["Time"], "yyyy-mm-ddTHH:MM:SSZ")
                    ))
                catch 
                    continue
                end
            end
        end

        df.y = df.lat .- df.lat[1]
        df.x = df.lon .- df.lon[1]

        push!(activities, df)
    end
end

begin
    latmin, lonmin = 40.380824, -83.068371
    latmax, lonmax = 40.413487, -83.047552


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

    for i in 1:length(activities)
        plot!(
            p,
            activities[i][!, :lon],
            activities[i][!, :lat],
            alpha = 0.5,
            linewidth = 2,
        )
    end

    display(p)
    savefig(p, "strava/plots/activities_delaware.png")
end

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

    for i in 1:length(activities)
        plot!(
            activities[i][!, :x],
            activities[i][!, :y],
            alpha = 0.5
        )
    end

    display(p)
    savefig(p, "strava/plots/activities_zeroed.png")
end

# grid of activities
begin
    plots = []

    for i in 1:length(activities)
        
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

    display(p)

    savefig(p, "strava/plots/activities_grid.png")
end;

