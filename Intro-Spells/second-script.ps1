$servers = @('fileserver01', '10.5.1.35', '10.5.1.197')

get-content -path "\\($servers[0])\c$\secret.txt"
get-content -path "\\($servers[1])\c$\secret.txt"
get-content -path "\\($servers[2])\c$\secret.txt"