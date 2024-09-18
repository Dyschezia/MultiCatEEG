# MultiCatEEG


TODO:

In setupExpParam.m:
- set expected subject number
- catch N and P are not exact but I am not sure they are used.

In setupBalancedSets.m:
- this loads an externally generated design. Check that it is indeed balanced as described and check the code that generated it (attached, Rony Hirschon's). 

Places where code remains hardcoded:
1. setupCatch.m assumes 4 runs per set. 
