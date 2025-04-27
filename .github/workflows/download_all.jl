using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect
using Dates # Import the Dates module for time functions

# Write user JSON to file
write(joinpath(ENV["STRAVA_DATA_DIR"], "user.json"), ENV["USER_JSON"])

u = setup_user();
acts = get_activity_list(u; force_update = true)

start_time = now() # Record the start time
max_duration = Minute(30) # Set the maximum duration for the download process

for act in acts
    # Check if elapsed time exceeds the maximum duration
    elapsed_time = now() - start_time
    if elapsed_time >= max_duration
        @info "Stopping execution after $max_duration"
        break # Exit the loop
    end

    try
        get_activity(act[:id], u; verbose = true) # Download each activity
    catch e
        # Handle any errors that occur during the download
        @error "Failed to download activity $(act[:id]): $e"
        # Optionally, you can continue or break based on the error type
        continue
    end
end

@info "Activity download process finished or timed out."