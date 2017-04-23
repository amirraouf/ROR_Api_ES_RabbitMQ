#!/bin/bash
set -e

rake db:create
rake db:migrate
rails server -p 3000 -b 0.0.0.0
exec "$@"