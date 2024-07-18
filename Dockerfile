# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y ansible cron && \
    apt-get clean

# Install Ansible collection for VMware
RUN ansible-galaxy collection install community.vmware

# Install additional Python packages, including PyVmomi
RUN pip install jinja2 humanize pyvmomi

# Create necessary directories
RUN mkdir -p /vm-info /tmp

# Copy Ansible files
COPY ansible.cfg /vm-info/
COPY inventory/ /vm-info/inventory/
COPY playbooks/ /vm-info/playbooks/
COPY roles/ /vm-info/roles/
COPY scripts/ /vm-info/scripts/

# Give execution rights on the cron job script
RUN chmod +x /vm-info/scripts/entrypoint.sh /vm-info/scripts/fetch_and_serve.sh

# Add crontab file in the cron directory
RUN echo "*/5 * * * * /vm-info/scripts/fetch_and_serve.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/fetch_vm_info

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/fetch_vm_info

# Apply cron job
RUN crontab /etc/cron.d/fetch_vm_info

# Expose the port the app runs on
EXPOSE 8888

# Run the command on container startup
CMD ["sh", "/vm-info/scripts/entrypoint.sh"]