write(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), ENV["USER_JSON"])

using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect

u = setup_user();
refreresh_if_needed!(u)
acts = get_activity_list(u)

for act in acts[1:50]
    refreresh_if_needed!(u)
    full_activity = get_activity(act[:id], u)
    @info "Downloaded activity ID: $(act[:id])"
end
