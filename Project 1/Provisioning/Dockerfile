### NGINX docker image

# Use the official Ubuntu base image
FROM ubuntu:latest

# Update package lists and install basic dependencies
RUN apt-get update && apt-get install -y nginx

# Expose port 80 to allow access to Nginx
EXPOSE 80

# Set the working directory inside the container (if needed)
WORKDIR /nginx

# Command to start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
