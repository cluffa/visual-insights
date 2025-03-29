mkdir(ENV["STRAVA_DATA_DIR"])

open(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), "w+") do f
    write(f, ENV["USER_JSON"])
end

using Pkg
Pkg.activate(".")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect

u = setup_user();
acts = get_activity_list(u)

for act in acts
    full_activity = get_activity(act[:id], u)
    @info "Downloaded activity ID: $(act[:id])"
end
