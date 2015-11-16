# twit-candi-2016
Tweet "ingestor" for the 2016 Presidential Candidates.

Python script (tc_application.py) just slightly modified from Emma Pierson's [mineTweets.py](https://github.com/epierson9/TwitterTools).  Updated to read twitter credentials and application config from JSON files, and to explicitly handle unicode characters.

The script collects tweets that "mention" a candidate, not just tweets that reference official campaign accounts.  What constitues a mention for each candidate is defined in config.json. Generally, it is their official campaign account/accounts,   their name, and their name plus "2016".  

Currently running for 12 minutes -- from minutes 5 to 16 inclusive -- every hour on AWS box, and storing the collected tweets in S3.  Would ideally run for longer, but need to get a sense of storage costs.    

My goal is to collect tweets through the 2016 election.  

Working on this [user interface](https://github.com/triciajam/twit-candi-ui) for analyzing the data.  Visualization is currently
only running on local machine; hoping to have one live on AWS shortly.
