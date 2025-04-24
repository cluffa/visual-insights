write(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), ENV["USER_JSON"])

using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect

u = setup_user();
acts = get_activity_list(u; )

for act in acts
    if contains(lowercase(act[:type]), "run") || contains(lowercase(act[:type]), "ride")
        try
            get_activity(act[:id], u; verbose = true) # Download each activity
            sleep(87) # Sleep for 87 seconds to avoid hitting the rate limit
        catch e
            # Handle any errors that occur during the download
            @error "Failed to download activity $(act[:id]): $e"
            # Optionally, you can continue or break based on the error type
            continue
        end
    else
        @info "Skipping activity $(act[:id]) of type $(act[:type])"
    end
end
