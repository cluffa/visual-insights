using DataFrames
using Plots
using CSV
using Dates

begin
    df = CSV.read("data/activities.csv", DataFrame)
    select!(df, ["Activity Date", "Distance"])

    transform!(
        df, 
        :Distance => (x -> x * 0.621371) => :Distance,
        "Activity Date" => (x -> DateTime.(x, "u dd, y, HH:MM:SS p")) => "Activity Date"
    )

    df[!, "YM"] = Dates.format.(df[!, "Activity Date"], "Y-m")

    df = combine(groupby(df, "YM"), "Distance" => sum)

    plot(
        df[!, "YM"],
        df[!, "Distance_sum"],
        title="Monthly Distance",
        xlabel="Month",
        ylabel="Distance (miles)",
        label="Distance",
        legend=false,
        dpi=500,
        # background=:transparent,
    )

    savefig("plots/monthly_distance.png")
end