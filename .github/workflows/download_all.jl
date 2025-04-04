write(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), ENV["USER_JSON"])

using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect

u = setup_user();
acts = get_activity_list(u)

for act in acts
    try
        get_activity(act[:id], u; verbose = true) # Download each activity
    catch e
        # Handle any errors that occur during the download
        @error "Failed to download activity $(act[:id]): $e"
        # Optionally, you can continue or break based on the error type
        continue
    end
end
