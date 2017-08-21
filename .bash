### worker-gif
function make-docker()
{
    docker-compose exec worker make $1 $2 $3 $4
}