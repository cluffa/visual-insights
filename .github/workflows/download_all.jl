user_json_file = joinpath(DATA_DIR, "user.json")

open(user_json_file, "w+") do io
    write(io, ENV["USER_JSON"])
end

using Pkg
Pkg.activate(".github/workflows")
Pkg.add(url = "https://github.com/cluffa/StravaConnect.jl.git")

using StravaConnect

u = setup_user();
acts = get_activity_list(u)

for act in acts
    full_activity = get_activity(act[:id], u)
    @info "Downloaded activity ID: $(act[:id])"
end
