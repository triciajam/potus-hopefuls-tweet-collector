# potus-hopefuls-tweet-collector
Tweet "ingestor" for the 2016 Presidential primary candidates.

The core is a python script tc_application.py just slightly modified from Emma Pierson's [mineTweets.py](https://github.com/epierson9/TwitterTools).  I updated the script to read twitter credentials and application configuration information from JSON files, and to explicitly handle unicode characters.

The script collects any tweets containing text defined as a "mention" of a candidate.  Mentions are currently configured in config.json as candidate first and last name, candidate first or last name plus "2016", official campaign accounts, certain campaign hashtags.  

Cron scripts start and stop the python script.  Tweets are written to a file as they are collected.  Files are synced with Amazon S3 storage every hour.  Currently running for 12 minutes -- from minute 5 to 16 inclusive -- every hour on an AWS box.

dist/ contains the python, config, and cron scripts described above.
startup/ contains scripts to set up on a new AWS box - work in progress.
data/ folder must be created - files are written to candidate subfolders created based on config.json.

My goal is to collect tweets until 2016 general election.  

See [twit-candi-ui](https://github.com/triciajam/twit-candi-ui) for visualization project.

Also working on [real-time collection and visualization](https://github.com/triciajam/realtime-twitter) using a message queue middle layer.
