#!/bin/bash

fly -t demo sp -p demo-bg -c pipeline.yml -l params.yml
