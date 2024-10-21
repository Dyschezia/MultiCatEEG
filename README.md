# MultiCatEEG


TODO:

In generateTrials.m:
- Decide whether it makes sense to continue generating ITIs from the almost-uniform truncated normal distribution, or either just use a uniform dist or make the sigma smaller.
- Currently sampled ITIs are in jumps of 100ms (i.e. 600/700/800ms). This is comfortable because it is divisible by the 60Hz screen's flip duration. However, can set timing to be based on flips and thus sample ITIs more finely. 


Places where code remains hardcoded:
1. setupCatch.m assumes 4 runs per set.


Open questions:
1. Is counterbalancing of response mapping necassary?
2. Should we limit single array trials to not repeat? (unlikely but possible). 
