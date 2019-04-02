#! /usr/bin/env bash
# Helper script to automate the build and deployment of Sphinx content for a specific workshop

make html
cd _build/html && python -m SimpleHTTPServer 8080
