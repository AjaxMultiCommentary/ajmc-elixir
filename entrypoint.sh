#!/bin/bash


until pg_isready -d ${DATABASE_URL} 
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

/app/bin/migrate
/app/bin/server
