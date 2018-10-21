#!/bin/bash

fly -t pcfdemoe sp -p demo-bg -c pipeline.yml -l ../../params.yml
