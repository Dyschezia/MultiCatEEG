# MultiCatEEG


TODO:

In setupExpParam.m:
- set expected subject number
- catch N and P are currently commented out to see whether they are used somewhere. 

In setupBalancedSets.m:
- this loads an externally generated design. Check that it is indeed balanced as described and check the code that generated it (attached, Rony Hirschon's).

In setupCatch.m:
- rows 109-111 are saving catch trial information s.t. the second session overrides the first. For now commented, so that can find whether any future code depended on this erroneous structre or whether it's an old leftover. 

In generateTrials.m:
- Decide whether it makes sense to continue generating ITIs from the almost-uniform truncated normal distribution, or either just use a uniform dist or make the sigma smaller.
- Currently sampled ITIs are in jumps of 100ms (i.e. 600/700/800ms). This is comfortable because it is divisible by the 60Hz screen's flip duration. However, can set timing to be based on flips and thus sample ITIs more finely. 

In generateTiming.m and during play: 
- currently does not have an option for a break between runs. Need to add and to make sure exp running itself does not depend on generateTiming.m...

Places where code remains hardcoded:
1. setupCatch.m assumes 4 runs per set.
2. shuffleTrials.m assumes 2 sets per session; currently commented out. 
