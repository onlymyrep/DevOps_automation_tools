# CREATE
curl -X POST http://localhost:8082/api/v1/hotels \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Hotel","location":"Test City"}'

# READ ALL
curl http://localhost:8082/api/v1/hotels

# READ ONE (используйте ID из CREATE)
curl http://localhost:8082/api/v1/hotels/<HOTEL_UID>

# DELETE
curl -X DELETE http://localhost:8082/api/v1/hotels/<HOTEL_UID>

# CHECK CONSUL
curl http://localhost:8500/ui/ | grep "<title>Consul</title>"