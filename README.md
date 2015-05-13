# Archiver
A simple app that receives .mp4/.asf files http request, puts the link to these files into a queue, and then transcodes them in a limited number of workers.

##info
The app starts cowboy on port 8008 and receives files through put request.
Files added to queue, queue stored in SLQLite database.
Worker pops record from database and transcodes it, then saves to the final destination.

## Building
make deps && make all

##Configuration
all config defined at archive.hrl

##TODO
add cfg configuration files


#Used libraries
* lager       https://github.com/basho/lager
* worker_pool https://github.com/inaka/worker_pool
* cowboy      https://github.com/ninenines/cowboy
* sqlite3     https://github.com/alexeyr/erlang-sqlite3