
# Create the Podman Secrets
echo -n "your_vcenter_username" | podman secret create vcenter_username -
echo -n "your_vcenter_password" | podman secret create vcenter_password -


# Build the Podman Image
podman build -t vm-info-fetcher .


# Run the Podman Container with Secrets
podman run -d \
    --name vm-info-container \
    -p 8888:8888 \
    --secret vcenter_username \
    --secret vcenter_password \
    vm-info-fetcher

# Debug

To debug the setup with Docker, you can follow these steps:

1. **Build the Docker Image**:
    Ensure you've copied all necessary files and directories into the Docker build context.

    ```sh
    docker build -t vm-info-fetcher .
    ```

2. **Run the Docker Container**:
    Run the container with the necessary secrets and ports exposed.

    ```sh
    docker run -d \
        --name vm-info-container \
        -p 8888:8888 \
        -v /path/to/vcenter_username:/run/secrets/vcenter_username:ro \
        -v /path/to/vcenter_password:/run/secrets/vcenter_password:ro \
        vm-info-fetcher
    ```

3. **Check Container Logs**:
    To see the logs and ensure that everything is running correctly, use the following command:

    ```sh
    docker logs -f vm-info-container
    ```

    This will show the output of the cron job and the HTTP server, including any errors.

4. **Access the Shell Inside the Container**:
    If you need to inspect files or run commands inside the container, you can start an interactive shell session:

    ```sh
    docker exec -it vm-info-container /bin/sh
    ```

5. **Verify the Output Files**:
    Inside the container, check if the output files `/tmp/vm_info.html` and `/tmp/last_updated_time.txt` are created and have the expected content.

    ```sh
    cat /tmp/vm_info.html
    cat /tmp/last_updated_time.txt
    ```

6. **Run Ansible Playbooks Manually**:
    If the cron job does not seem to be running correctly, you can manually invoke the Ansible playbook to check for errors.

    ```sh
    ansible-playbook /vm-info/playbooks/main.yml -i /vm-info/inventory/hosts
    ```

7. **Check Cron Job Configuration**:
    Ensure that the cron job is correctly configured and running. You can check the cron job status and schedule with the following commands:

    ```sh
    crontab -l
    tail -f /var/log/cron.log
    ```

8. **Validate HTTP Server**:
    Make sure the HTTP server is running and serving the expected content. You can use tools like `curl` to make requests to the server:

    ```sh
    curl http://localhost:8888/vm_info.html
    ```

### Example Debugging Session

1. **Build the Image**:

    ```sh
    docker build -t vm-info-fetcher .
    ```

2. **Run the Container**:

    ```sh
    docker run -d \
        --name vm-info-container \
        -p 8888:8888 \
        -v /path/to/vcenter_username:/run/secrets/vcenter_username:ro \
        -v /path/to/vcenter_password:/run/secrets/vcenter_password:ro \
        vm-info-fetcher
    ```

3. **Check Logs**:

    ```sh
    docker logs -f vm-info-container
    ```

4. **Access Container Shell**:

    ```sh
    docker exec -it vm-info-container /bin/sh
    ```

5. **Verify Files**:

    ```sh
    cat /tmp/vm_info.html
    cat /tmp/last_updated_time.txt
    ```

6. **Run Ansible Playbook**:

    ```sh
    ansible-playbook /vm-info/playbooks/main.yml -i /vm-info/inventory/hosts
    ```

7. **Check Cron Job**:

    ```sh
    crontab -l
    tail -f /var/log/cron.log
    ```

8. **Test HTTP Server**:

    ```sh
    curl http://localhost:8888/vm_info.html
    ```

### Additional Tips

- **Ensure Secrets are Correct**: Verify that the secrets for `vcenter_username` and `vcenter_password` are correctly mounted and accessible.
- **Check Network Connectivity**: Ensure the container has network access to the VMware vCenter server.
- **Inspect Ansible Output**: Ansible's verbose mode can be helpful for debugging:

    ```sh
    ansible-playbook /vm-info/playbooks/main.yml -i /vm-info/inventory/hosts -vvv
    ```

By following these steps, you should be able to diagnose and resolve any issues with the setup in Docker.