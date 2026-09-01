# Check-in word list

`check_in_words.txt` is the [EFF long wordlist](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases) used to generate human-readable, memorable check-in codes for events and workshops.

- Source file: https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt
- 7,776 words, allowing roughly 4.7×10^11 unique three-word combinations.
- To update the list, replace `check_in_words.txt` with a new word list and ensure `CheckInable.word_list` still filters out blank lines and comment lines.
