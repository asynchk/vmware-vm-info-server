#!/bin/sh

# Create cron log file
touch /var/log/cron.log

# Start cron
cron

. /vm-info/scripts/fetch_and_serve.sh

# Start the HTTP server with custom Jinja2 filter
python3 - <<EOF
import os
import http.server
import socketserver
from jinja2 import Environment, FileSystemLoader
from humanize import naturaltime
from datetime import timedelta

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/vm_info.html':
            env = Environment(loader=FileSystemLoader('/tmp'))
            env.filters['timedelta'] = lambda seconds: str(timedelta(seconds=seconds))
            template = env.get_template('vm_info.html')
            with open('/tmp/vm_info.html', 'w') as f:
                f.write(template.render())
            self.path = '/vm_info.html'
        return super().do_GET()

PORT = 8888
Handler = CustomHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
EOF

# Prevent the container from exiting
tail -f /var/log/cron.log