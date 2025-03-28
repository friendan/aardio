#include <cstdio>

#include "dict.h"

using namespace std;

namespace rmmseg
{
    struct Entry
    {
        Word *word;
        Entry *next;
    };

    const int init_size = 262147;
    const int max_density = 5;
    /*
      Table of prime numbers 2^n+a, 2<=n<=30.
    */
    static int primes[] = {
        524288 + 21,
        1048576 + 7,
        2097152 + 17,
        4194304 + 15,
        8388608 + 9,
        16777216 + 43,
        33554432 + 35,
        67108864 + 15,
        134217728 + 29,
        268435456 + 3,
        536870912 + 11,
        1073741824 + 85,
    };


    static int n_bins = init_size;
    static int n_entries = 0;
    static Entry **bins = static_cast<Entry **>(std::calloc(init_size,
                                                            sizeof(Entry *)));

    static int new_size()
    {
        for (unsigned int i = 0;
             i < sizeof(primes)/sizeof(primes[0]);
             ++i)
        {
            if (primes[i] > n_bins)
            {
                return primes[i];
            }
        }
        // TODO: raise exception here
        return n_bins;
    }

    static unsigned int hash(const char *str, int len)
    {
        unsigned int key = 0;
        while (len--)
        {
            key += *str++;
            key += (key << 10);
            key ^= (key >> 6);
        }
        key += (key << 3);
        key ^= (key >> 11);
        key += (key << 15);
        return key;
    }

    static void rehash()
    {
        int new_n_bins = new_size();
        Entry **new_bins = static_cast<Entry **>(calloc(new_n_bins,
                                                        sizeof(Entry *)));
        Entry *entry, *next;
        unsigned int hash_val;

        for (int i = 0; i < n_bins; ++i)
        {
            entry = bins[i];
            while (entry)
            {
                next = entry->next;
                hash_val = hash(entry->word->text,
                                entry->word->nbytes) % new_n_bins;
                entry->next = new_bins[hash_val];
                new_bins[hash_val] = entry;
                entry = next;
            }
        }
        free(bins);
        n_bins = new_n_bins;
        bins = new_bins;
    }

    namespace dict
    {

        /**
         * str: the base of the string
         * len: length of the string (in bytes)
         *
         * str may be a substring of a big chunk of text thus not nul-terminated,
         * so len is necessary here.
         */
        Word *get(const char *str, int len)
        {
            unsigned int h = hash(str, len) % n_bins;
            Entry *entry = bins[h];
            if (!entry)
                return NULL;
            do
            {
                if (len == entry->word->nbytes &&
                    strncmp(str, entry->word->text, len) == 0)
                    return entry->word;
                entry = entry->next;
            }
            while (entry);

            return NULL;
        }

        void add(Word *word)
        {
            unsigned int hash_val = hash(word->text, word->nbytes);
            unsigned int h = hash_val % n_bins;
            Entry *entry = bins[h];
            if (!entry)
            {
                if (n_entries/n_bins > max_density)
                {
                    rehash();
                    h = hash_val % n_bins;
                }
            
                entry = static_cast<Entry *>(pool_alloc(sizeof(Entry)));
                entry->word = word;
                entry->next = NULL;
                bins[h] = entry;
                n_entries++;
            }

            bool done = false;
            do
            {
                if (word->nbytes == entry->word->nbytes &&
                    strncmp(word->text, entry->word->text, word->nbytes) == 0)
                {
                    /* Overwriting. WARNING: the original Word object is
                     * permanently lost. This IS a memory leak, because
                     * the memory is allocated by pool_alloc. Instead of
                     * fixing this, tuning the dictionary file is a better
                     * idea
                     */
                    entry->word = word;
                    done = true;
                    break;
                }
                entry = entry->next;
            }
            while (entry);

            if (!done)
            {
                entry = static_cast<Entry *>(pool_alloc(sizeof(Entry)));
                entry->word = word;
                entry->next = bins[h];
                bins[h] = entry;
            }
        }

        bool load_chars(const wchar_t *filename)
        {
            FILE *fp = _wfopen(filename, L"r");
            if (!fp)
            {
                return false;
            }

            const int buf_len = 24;
            char buf[buf_len];
            char *ptr;

            while(fgets(buf, buf_len, fp))
            {
                // NOTE: there SHOULD be a newline at the end of the file
                buf[strlen(buf)-1] = '\0';    // truncate the newline
                ptr = strchr(buf, ' ');
                if (!ptr)
                    continue;       // illegal input
                *ptr = '\0';
                add(make_word(ptr+1, 1, atoi(buf)));
            }
        
            fclose(fp);
            return true;
        }

        bool load_words(const wchar_t *filename)
        {
            FILE *fp = _wfopen(filename, L"r");
            if (!fp)
            {
                return false;
            }

            const int buf_len = 48;
            char buf[buf_len];
            char *ptr;
			
            while(fgets(buf, buf_len, fp))
            {
                // NOTE: there SHOULD be a newline at the end of the file
                buf[strlen(buf)-1] = '\0';    // truncate the newline
                if (buf[0] == '#')
                    continue;

				ptr = buf;
				int len = 0;
				char chr = '\0';
				while( (chr = *ptr) &&  (chr!=' ')){   
					ptr++;
					if( ( 0x80 & chr ) && (0x40 & chr ) ){
						while(  (chr <<= 1 ) &0x80 ) ptr++;
					}
					len++;
				};
				if(!len) continue;

				if (*ptr != ' ')
					add(make_word(buf, len, 0));
				else
				{
					*ptr = '\0';
					add(make_word(buf, len, 0, -1, *(ptr+1)));
				}
			}
        
            fclose(fp);
            return true;
        }
    }
}
