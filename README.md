# Twitter

#How to run

# First, Run the twitter engine
* Go to the project4_engine directory
* run the following commands:
    * mix escript.build
    * ./project4_engine

# Then, Run the twitter client simulator

Please find below all the commands that are supported by the Engine API and that can be used from the client-side
For getting meaningful results, the following order can be used:

1. Do a run of the simulation. You can use either Command-1 or Command-2 based on what you want to see in the output.
2. After some time kill the client process.(Once you have got say, 1 running average printed out on the console you can hit cancel). Next you can play with the rest of the actions as we have some tables populated in the engine
3. You can subscribe user(s) to another user(s) using Command-3 and then look at each user's feed based on their subscription by using Command-4
(Subscriptions in simulation takes time since we are batching ALL subscriptions at once but it is works relatively fast if the number of users are <= 1000 (~30s). To see this in action, please uncomment lines [86,87,88] in 'actions.ex' in 'project4_client' and run the simulation again. Once this is done, all feeds of all users will be populated and you can have a better look at them by using Command-4)
4. You can look at some sample hashtags in the database using Command-5 and test if hashtag API works by using Command-6 (Make sure you dont uss the '#' symbol in the argument)
5. You can look at some sample mentions in the database using Command-7 and test if mention API works by using Command-8

Below are the commands:

#USER COMMANDS

The following operations are supported:
1. ./project4_client simulate see_tweets NUM_CLIENTS
    Starts a simulation with the given number of users (limits to this value are included in the report). The 'see_tweets' flag allows the _tweets sent by the various users_ to be printed on the console for you to look at.

2. ./project4_client simulate see_tweet_rate NUM_CLIENTS
    Starts a simulation with the given number of users (limits to this value are included in the report). The 'see_tweet_rate' flag allows the printing of _running average of number of tweets/second_ to be printed on the console. It is printed in periodic intervals of time (based on the print_every parameter as explained in the report)

3. ./project4_client subscribe_to USERID_1 USERID_2
    Subscribes USERID_1 to the twitter activity of USERID_2. Userids can be anything between [0, NUM_CLIENTS].

4. ./project4_client feed USERID
    Returns the feed of the provided USERID. USERID can be anything between [0, NUM_CLIENTS]. Make sure the USERID is subscribed to at least 1 other user so as to get a non-empty feed! 

5. ./project4_client sample_hashtags
    Prints the hashtags of all the tweets seen so far. You can pick any of these and use it as an argument in the next command

6. ./project4_client tweets_with_hashtag HASHTAG  **HASHTAG should be WITHOUT the '#' symbol**
    Provided a hashtag, it outputs ALL the tweets sent so far to the engine that have the hashtag. Make sure you do not include the '#' in the command line argument!

7. ./project4_client sample_mentions
    Prints the mentions of all the tweets sent so far.You can pick any of these and use it as an argument in the next command
8. ./project4_client tweets_with_mention MENTION
    Provided a mention, it outputs ALL the tweets sent so far to the engine that have that mention.
9. ./project4_client retweet USERID
    Provided a userid, retweets as the user. For simulation, it does 3 things:
	1. Gets the user's feed
	2. Randomly selects 1 tweet from its feed
	3. (Re)Tweets that tweet 	
