from tweepy import Stream, OAuthHandler
from tweepy.streaming import StreamListener
import sys, json, os, string, random, os
from traceback import print_exc

env_outfiles = os.environ["TC_OUTF"]
env_useHash = os.environ["TC_USEHASH"]
env_useNonHash = os.environ["TC_USENONHASH"]
env_words = os.environ["TC_WORDS"]

print "Arguments:"
print env_outfiles
print env_useHash
print env_useNonHash
print env_words
print env_words.split()

#print env_outfiles.split(',')

atoken = "165655742-7jwGBomBbT63xzxk8XbEvLbWl5a0p4kQ3oOKW2IV" #your access token
asecret = "WLY0NsQ5p8ukubIRb95tu56bjflS8FMyyXIiMicxr3cB4" #your access secret
ckey = "nbE0tEokCo5lRvGHOLa4g0D0E" #your consumer key
csecret = "wLJBjJFiz1B4tGj239mXMbGGq0rUMlv6LpL0JqtI8HwtYxBb4B" #your consumer secret
#BASE_DIR = "/Users/trish/Desktop/Projects/twitcamp/" #your base directory. 
BASE_DIR = "/home/ec2-user/twit-candi-2016/" #your base directory. 

bad_set = ''.join([a for a in string.punctuation if a!='#'])
downsample_fracs = {}#change this if you only want a subset of the tweets. 

def removePuncExceptHashtag(s):
    """this removes the punctuation (except for hashtags) from a tweet s and turns it to lowercase so we can see which hashtags and words it includes"""
    out = s.translate(string.maketrans("",""), bad_set)
    out = out.split()
    out = ' '.join([a.lower() for a in out])
    return out
    
def getMaxOutfileNumber(path, good_filename):
    """
    Helper method that figures out the maximum filename. 
    path: the path for the files to load. 
       good_filename: the filename the files should contain (eg, ferguson)
    returns the maximum filenumber.
    """
    all_files = os.listdir(path)
    filenums = [''.join([char for char in filename if char.isdigit()]) for filename in all_files if good_filename in filename]
    good_filenums = []
    for f in filenums:
       try:
           good_filenums.append(int(f))
       except:
            continue
    if len(good_filenums) == 0:
        return 0
    return max(good_filenums)



def getWhichGroupTweetBelongsTo(processed_string):
    """takes the processed tweet string and determines which group it belongs to. In some cases, returns none. """
    idxs = []
    string_tokens = processed_string.split()
    for idx, group in enumerate(tweetGroups): 
        in_group = False 
        for g in group:   
            if ' ' in g or '#' in g:#if it's a hashtag or it has a space in it, look for it anywhere in the string. 
                if g in processed_string:
                    in_group = True
                    break
            else:#if it's just a single word, only take exact match (so we don't get hashtags if we don't want to). 
                if g in string_tokens:
                    in_group = True
                    break        
        if in_group:
            idxs.append(idx)
    return idxs
class listener(StreamListener):
    """main class for getting and processing Twitter data"""
    def on_data(self, data):
        try:
            d = json.loads(data)
            retweet = 'retweeted_status' in d
            if not retweet:
                tweet_text = d['text'].encode('utf-8', 'ignore')
            else:
                tweet_text = d['retweeted_status']['text'].encode('utf-8', 'ignore')
                
            hashtags = [a['text'] for a in d['entities']['hashtags']]
            tokenized_tweet = removePuncExceptHashtag(tweet_text)
            groups = getWhichGroupTweetBelongsTo(tokenized_tweet)
            if len(groups) == 0:
                print 'Unable to assign tweet to a group; hashtags were', hashtags, 'groups were', groups, 'tweet text', tweet_text
            for idx in groups:
                group = outfileDirs[idx]
                if group in downsample_fracs and random.random() > downsample_fracs[group]:#if we are down-sampling, only take some tweets. 
                    continue

                if (self.n[idx])%1000 == 0:#if we have dumped a thousand tweets, dump to a new outfile. 
                    self.outfile_number[idx] += 1
                    print 'Writing to outfile', self.outfile_number[idx]
                    self.outfile[idx] = open('%s/%s%i' % (outfileDirs[idx], outfileDirs[idx], self.outfile_number[idx]), 'wb')
                
                if str(d['user']['geo_enabled']) != 'False':
                    self.n_geolocated[idx] += 1
                print 'For group', idx + 1, 'tweet', self.n[idx], 'geolocated', self.n_geolocated[idx], d['text'].encode('utf-8'), d['created_at']
                self.outfile[idx].write(json.dumps(d)+'\n')
                self.n[idx]+=1
        except:
            print_exc()
            print d
            print 'Error with tweet'
            
    def on_timeout():
        raise Exception('Timed out!')
    def on_disconnect(notice):
        raise Exception('Disconnected with notification %s' % str(notice))

    def on_error(self, status):
        print 'Error', status
    def __init__(self):
        self.n_streams = len(outfileDirs)
        self.n = [0 for i in range(self.n_streams)]
        self.outfile_number = [getMaxOutfileNumber(BASE_DIR + outfileName + '/', outfileName) for outfileName in outfileDirs]
        print 'Max outfile numbers are', self.outfile_number, 'for', outfileDirs
        self.n_geolocated = [0 for i in range(self.n_streams)]
        self.outfile = [None for i in range(self.n_streams)]
    

if __name__ == '__main__':
    if len(sys.argv) < 5:
        raise Exception('Wrong number of arguments! See documentation.')
    if None in [atoken, asecret, ckey, csecret, BASE_DIR]:
        raise Exception('Please be sure to set all arguments in lines 6 - 10')
    global outfileDirs
    global tweetGroups
    global allTweetsToMonitor

    outfileDirs = env_outfiles.split(',')#get names of outfiles
    
    assert([a.lower() in ['true', 'false'] for a in env_useHash.split(',')])
    assert([a.lower() in ['true', 'false'] for a in env_useNonHash.split(',')])
    useHashtags = [a.lower() == 'true' for a in env_useHash.split(',')]#figure out whether to use hashtags. 
    useNonHashtags = [a.lower() == 'true' for a in env_useNonHash.split(',')]
    
    wordsToMonitor = [a.split(',') for a in env_words.split()]
    wordsToMonitor = [[a.lower().replace('_', ' ') for a in b] for b in wordsToMonitor]
    
    print "DEbug"
    print useHashtags
    print useNonHashtags
    print wordsToMonitor
     
    tweetGroups = [[] for a in wordsToMonitor]
    for i in range(len(wordsToMonitor)):
        if useHashtags[i]:
            tweetGroups[i] = tweetGroups[i] + ['#%s' % a for a in wordsToMonitor[i]]
        if useNonHashtags[i]:
            tweetGroups[i] = tweetGroups[i] + ['%s' % a for a in wordsToMonitor[i]] 
    allTweetsToMonitor = sorted(list(set([a for b in tweetGroups for a in b])))
    print 'Searching for Tweets containing', tweetGroups
    assert(len(outfileDirs) == len(tweetGroups))
    while True:
        try:
            print 'Restarting stream...'#restart every time it crashes. 
            auth = OAuthHandler(ckey, csecret)
            auth.set_access_token(atoken, asecret)
            twitterStream = Stream(auth, listener(), timeout = 60, stall_warnings = True)
            ones_to_track = [','.join(['%s' % s for s in allTweetsToMonitor])]
            twitterStream.filter(track=ones_to_track)
        except KeyboardInterrupt:
            raise
        except:
            print 'Stream crashed.'
            print_exc()
            continue
