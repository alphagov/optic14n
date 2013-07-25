#!/bin/bash -x
export RAILS_ENV=test
export DISPLAY=":99"

bundle install --path "/home/jenkins/bundles/${JOB_NAME}"
bundle exec rake
