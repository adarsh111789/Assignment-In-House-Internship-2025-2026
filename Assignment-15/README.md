# Assignment 15 - Dockerized Python Application

## Objective
This project creates a Dockerized Python application using the python:3.12-slim base image.

The application prints:
- Current Python version
- Current date and time

## Project Files
- app.py
- Dockerfile
- requirements.txt
- README.md

## Build Docker Image

Run this command inside project folder:

docker build -t assignment15 .

## Run Docker Container

docker run assignment15

## Sample Output

Python Version: 3.12.x
Current Date & Time: 2026-06-26 18:00:00
