# MultiCatEEG


TODO:

In setupExpParam.m:
- set expected subject number
- catch N and P are not exact but I am not sure they are used.

In setupBalancedSets.m:
- this loads an externally generated design. Check that it is indeed balanced as described and check the code that generated it (attached, Rony Hirschon's).

In generateTrials.m:
- Decide whether it makes sense to continue generating ITIs from the almost-uniform truncated normal distribution, or either just use a uniform dist or make the sigma smaller.
- Currently sampled ITIs are in jumps of 100ms (i.e. 600/700/800ms). This is comfortable because it is divisible by the 60Hz screen's flip duration. However, can set timing to be based on flips and thus sample ITIs more finely. 

Places where code remains hardcoded:
1. setupCatch.m assumes 4 runs per set. 
