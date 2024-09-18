import itertools
import functools
import random
import pandas as pd

__author__ = "Rony Hirschhorn"

NUM_CATEGORIES = 8  # there are 8 category ids
NUM_SIMULT_PRES = 4  # there are 4 items presented simultaneously in each trial
CAT_SELECT_DICT = {x: 0 for x in range(1, NUM_CATEGORIES + 1)}  # the number of times each category was selected
NUM_SESSIONS = 3  # each participant should have 3 sessions as one is too long (1680 trials)
NUM_BLOCKS_PER_SES = 6  # how many blocks are there in each session (runs?)
GLOBAL_LOCATION_DICTS = [{x: 0 for x in range(1, NUM_CATEGORIES + 1)} for y in range(NUM_SIMULT_PRES)]


class NumberCounter:
    def __init__(self, num, counter):
        self.num = num  # digit, corresponds in our case to a category
        self.counter = counter  # how many times was a combination containing this digit was selected


def compare(tup1, tup2):  # same as before
    """
    Given two tuples of NUM_SIMULT_PRES elements each, it returns 1 if tup1 > tup2, and -1 if tup1 < tup2,
    where the comparison operator is defined using CAT_SELECT_DICT (a dict where key=category and value=num of
    times the category was selected):
    - Convert each tuple to a list of NumberCounter
    - Sort each list of NumberCounter by the elements' self.counter in an increasing order
    - Compare the two sorted lists, item by item (counter by counter).

    :return: 1 or -1 according to the larger tuple; if equal arbitrarily choose one as larger
    """
    tup1_list = [NumberCounter(x, CAT_SELECT_DICT[x]) for x in tup1]
    tup2_list = [NumberCounter(x, CAT_SELECT_DICT[x]) for x in tup2]
    tup1_list.sort(reverse=False, key=lambda x: x.counter)
    tup2_list.sort(reverse=False, key=lambda x: x.counter)

    for i in range(NUM_SIMULT_PRES):
        if tup1_list[i].counter < tup2_list[i].counter:
            return -1
        elif tup1_list[i].counter > tup2_list[i].counter:
            return 1
    return 1


def compare_by_locations(tup1, tup2):  # consider LOCATIONS
    """
    Given two tuples of NUM_SIMULT_PRES elements each, it returns 1 if tup1 > tup2, and -1 if tup1 < tup2,
    where the comparison operator is defined using GLOBAL_LOCATION_DICTS (a LIST of DICTS where each list represents
    a location, and in each dict key=category and value=num of times the category was selected in that location):
    - Convert each tuple to a list of NumberCounter
    - Take each time from a different DICT according to the LOCATION (first=TL, second=TR, third=BL, fourth=BR)
    - Sort each list of NumberCounter by the elements' self.counter in an increasing order
    - Compare the two sorted lists, item by item (counter by counter).

    :return: 1 or -1 according to the larger tuple; if equal arbitrarily choose one as larger
    """
    tup1_list = [NumberCounter(tup1[x], GLOBAL_LOCATION_DICTS[x][tup1[x]]) for x in range(len(tup1))]
    tup2_list = [NumberCounter(tup2[x], GLOBAL_LOCATION_DICTS[x][tup2[x]]) for x in range(len(tup2))]
    tup1_list.sort(reverse=False, key=lambda x: x.counter)
    tup2_list.sort(reverse=False, key=lambda x: x.counter)

    for i in range(NUM_SIMULT_PRES):
        if tup1_list[i].counter < tup2_list[i].counter:
            return -1
        elif tup1_list[i].counter > tup2_list[i].counter:
            return 1
    return 1


def combinations_in_sessions():
    """
    Given there are [NUM_CATEGORIES] identities, [NUM_SIMULT_PRES] of which presented simultaneously
    at each trial, this method returns a list of length [NUM_SESSIONS] s.t. each session (list)
    contains all the combinations (trials; tuples) (NOT permutations) that will appear in this session:

    First, choose the combination that appeared the LEAST amt of times (not considering permutations at all).
    Once it's chosen, we DON'T take it out - this way, it can be chosen to appear in all session such that
    all 70 combinations could appear in all sessions. **NOTE** though that it's not guarenteed (the algorithm is naive).
    But it _should_ be able to happen with this method; otherwise, you'd take a combination out once it's selected and
    then it's guarenteed to appear only once across all sessions.

    Additionally, we also have for each combination all of its possible permutations saved. So once we selected a
    combination - now we will select its permutation according to the category that appeared the LEAST AMT OF TIMES IN
    A CERTAIN LOCATION. We will always select a permutation by the id with the least instances in a location.
    Then, we will REMOVE this permutation - because unlike combinations, a permutation should repeat only once across
    all sessions. **NOTE 2**: again, naive, meaning: a permutation won't repeat across sessions and the selection
    process should be able to generate a balanced sequence, BUT it doesn't enforce that ACROSS sessions the # of permutations
    for the same combination will be equal.

    Then, a combination is removed from being able to be selected once all its permutations have been removed.
    This way we receive a session divide that is (aspiring to be) balanced. This doesn't guarentee anything about blocks.
    """

    """
    Create a list of all possible combinations of [NUM_SIMULT_PRES]. 
    This will result in a list of length [number of combinations], each element in this list is a TUPLE
    (but the order doesn't matter as this is a combination).
    For the case where there are 4 NUM_SIMULT_PRES and 8 possible_elements, combinations is of length 70
    """
    possible_elements = [x for x in range(1, NUM_CATEGORIES + 1)]
    combinations = list(itertools.combinations(possible_elements, NUM_SIMULT_PRES))
    num_combinations = len(combinations)  # how many combination are there
    sessions_tuples = [list() for _ in range(NUM_SESSIONS)]  # open a list of sessions (each is a list of tuples (combinations))
    num_permutations_per_combination = len(list(itertools.permutations([1,2,3,4], NUM_SIMULT_PRES)))
    items_per_session = num_combinations * num_permutations_per_combination // NUM_SESSIONS

    all_permutations_of_combination = dict()
    for i in range(num_combinations):
        perms = list(itertools.permutations(combinations[i], NUM_SIMULT_PRES))
        all_permutations_of_combination[combinations[i]] = perms

    for i in range(num_combinations * num_permutations_per_combination):  # for each combination
        combinations_sorted = sorted(combinations, key=functools.cmp_to_key(compare))  # sort combinations by the comparison method
        selected_tuple = combinations_sorted[0]  # choose the smallest, which is the combination of the least used categories
        #combinations.remove(selected_tuple)  --> this is the change
        for num in selected_tuple:  # update the global dictionary CAT_SELECT_DICT
            CAT_SELECT_DICT[num] += 1
        # Now, need to choose PERMUTATION
        permutations_sorted = sorted(all_permutations_of_combination[selected_tuple], key=functools.cmp_to_key(compare_by_locations))  # sort combinations by the comparison method
        selected_permutation = permutations_sorted[0]
        for x in range(len(selected_permutation)):  # update the global dictionary GLOBAL_LOCATION_DICTS
            GLOBAL_LOCATION_DICTS[x][selected_permutation[x]] += 1
        all_permutations_of_combination[selected_tuple].remove(selected_permutation)
        if len(all_permutations_of_combination[selected_tuple]) == 0:
            combinations.remove(selected_tuple)
        sessions_tuples[min(i // items_per_session, NUM_SESSIONS - 1)].append(selected_permutation)  # put it in the corresponding session

    # print summary
    i = 1
    for session_list in sessions_tuples:
        print(f"Session {i} Category Balance:")
        num_counter = {x: 0 for x in range(1, NUM_CATEGORIES + 1)}
        num_locations = [{x: 0 for x in range(1, NUM_CATEGORIES + 1)} for y in range(NUM_SIMULT_PRES)]
        for tup in session_list:
            for loc in range(len(tup)):
                num = tup[loc]
                num_counter[num] += 1
                num_locations[loc][num] += 1

        for num in num_counter.keys():
            print(f"Number {num}: Top left {num_locations[0][num]}, Top right: {num_locations[1][num]}, "\
                  f"bottom left {num_locations[2][num]}, bottom right: {num_locations[3][num]}")
        print(num_counter)
        print("==========")
        i += 1

    """
    again - at the end the balance here is across sessions in the sense of the COMBINATIONS that appear and the 
    NUMBER OF CATEGORIES per location. 
    """

    return sessions_tuples


def permutations_in_sessions(sessions_tuples):
    """
    For each combination, create a list of all of its permutations.
    Then, create a mega-list for all of these permutations for each session.
    If you'd stop there and just shuffle - you'd have the needed balance across sessions, detailed by permutations
    (each permutation = trial).
    As you want to break sessions into blocks, the next step instead is to use [NUM_BLOCKS_PER_SES], and divide
    the session such that across all blocks within the same session you'd have a category balance.
    """

    sess_list = list()  # hold the session trial info, to be concatenated later

    sess_num = 1
    for session in sessions_tuples:
        print(f" ****** Session {sess_num}  ****** ")
        session_mega_list = list()
        session_mega_list.extend(session)
        random.shuffle(session_mega_list)
        # AT THIS POINT IF WE STOP AND NOT CONTINUE, WE HAVE A BALANCE BETWEEN SESSIONS (NOT DIVIDED INTO BLOCKS)

        num_permutations = len(session_mega_list)
        sessions_mega_list_blocks = list()

        for key in CAT_SELECT_DICT.keys():
            CAT_SELECT_DICT[key] = 0

        for i in range(num_permutations):  # for each combination
            combinations_sorted = sorted(session_mega_list, key=functools.cmp_to_key(compare))  # sort combinations by the comparison method
            selected_tuple = combinations_sorted[0]  # choose the smallest, which is the combination of the least used categories
            session_mega_list.remove(selected_tuple)
            for num in selected_tuple:  # update the global dictionary CAT_SELECT_DICT
                CAT_SELECT_DICT[num] += 1
            sessions_mega_list_blocks.append(selected_tuple)  # put it in the corresponding session

        trials_per_block = len(sessions_mega_list_blocks)//NUM_BLOCKS_PER_SES

        # print summary
        for i in range(NUM_BLOCKS_PER_SES):
            print(f"Block {i} Category Balance:")
            num_counter = {x: 0 for x in range(1, NUM_CATEGORIES + 1)}
            for j in range(i * trials_per_block, (i+1) * trials_per_block):
                tup = sessions_mega_list_blocks[j]
                for num in tup:
                    num_counter[num] += 1
            print(num_counter)
            print("==========")

        # unify and save
        sess_df = pd.DataFrame(sessions_mega_list_blocks, columns=["TL", "TR", "BL", "BR"])
        sess_df["session"] = [sess_num for x in range(len(sessions_mega_list_blocks))]
        sess_df["block"] = [x//trials_per_block + 1 for x in range(len(sessions_mega_list_blocks))]
        sess_list.append(sess_df)
        sess_num += 1

    sess_df = pd.concat(sess_list)
    sess_df.to_csv("trial_scheme.csv", index=False)
    return


if __name__ == "__main__":
    # first, get a balance of all combinations (not permutations) between sessions
    sessions_tuples = combinations_in_sessions()
    print("=======================")
    # next, turn combinations into permutations (=consider locations)
    permutations_in_sessions(sessions_tuples)
