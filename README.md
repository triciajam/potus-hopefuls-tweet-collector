# twit-candi-2016
Tweet "ingestor" for the 2016 Presidential Candidates.

Python script just slightly modified from Emma Pierson's [mineTweets.py](https://github.com/epierson9/TwitterTools).
Currently running for 12 minutes -- from minutes 5 to 16 inclusive -- every hour on AWS box, and storing the collected tweets in S3.  Would ideally run for longer, but need to get a sense of storage costs.    
My goal is to collect tweets through the 2016 election.  

Working on this [user interface](https://github.com/triciajam/twit-candi-ui) for analyzing the data.  Visualization is currently
only running on local machine; hoping to have one live on AWS shortly.
