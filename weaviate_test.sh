
# Perform a test to check the database is running
kubectl wait --for=condition=ready pod -l app=weaviate --timeout=180s

# Add additional information as needed and exit

exit 0
