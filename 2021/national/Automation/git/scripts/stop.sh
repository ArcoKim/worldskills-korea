#!/bin/bash
fuser -k 80/tcp && echo "Stop Server" || echo "Not Running"