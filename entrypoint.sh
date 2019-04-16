#! /usr/bin/env bash
# Helper script to automate the build and deployment of Sphinx content for a specific workshop

make dirhtml
cp -r _build/dirhtml/_static .
cd _build/dirhtml && python -m SimpleHTTPServer 8080
