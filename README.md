# Nginx-Load-Balancer-Demo

## Overview
This project demonstrates how to run multiple Nginx web server containers (web1,web2,web3) behind an Nginx load balancer container which would all be hosted on a single AWS EC2 instance

The setup uses Docker Compose to orchestrate 4 containers:

* web1 - Nginx web server
* web2 - Nginx web server
* web3 - Nginx web server
* lb - Nginx reverse proxy that acts as a load balancer that distributes traffic to web1,web2,web3 using the default round robin method.

This architecture simulates a typical load balanced microservice environment and is ideal for learning Nginx upstream configuration, Docker Compose, networking, and infrastructure basics.

## Architechture

## Features

## Prerequisites

## Installation Instructions

### Option 1: Via automated scripts (recommended)

### Option 2: Manual setup

## Project File Structure

## Testing

## Troubleshooting Guide

## Recap
