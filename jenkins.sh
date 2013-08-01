#!/bin/bash -x
export RAILS_ENV=test
export DISPLAY=":99"

set -e
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
export GOVUK_APP_DOMAIN=dev.gov.uk
bundle exec rake
bundle exec rake publish_gem