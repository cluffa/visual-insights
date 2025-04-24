using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")
Pkg.add("Dates")

using StravaConnect
using Dates # Import the Dates module for time functions

# Write user JSON to file
write(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), ENV["USER_JSON"])

u = setup_user();
acts = get_activity_list(u; force_update = true)

start_time = now() # Record the start time
max_duration = Hour(5) # Define the maximum duration (5 hours)

for act in acts
    # Check if elapsed time exceeds the maximum duration
    elapsed_time = now() - start_time
    if elapsed_time >= max_duration
        @info "Stopping execution after 5 hours."
        break # Exit the loop
    end

    if contains(lowercase(act[:type]), "run") || contains(lowercase(act[:type]), "ride")
        try
            get_activity(act[:id], u; verbose = true) # Download each activity
            sleep(20) # Sleep to avoid hitting the rate limit
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

@info "Activity download process finished or timed out."