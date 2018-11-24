dictionary = {'а':'a',
              'ә':'a',
              'б':'b',
              'в':'v',
              'г':'g',
              'ғ':'g',
              'д':'d',
              'е':['e','ye'],
              'ё':['e','o'],
              'ж':['zh','j'],
              'з':'z',
              'и':['i','y'],
              'й':['y','i'],
              'к': 'k',
              'қ':['k','q'],
              'л':'l',
              'м':'m',
              'н':'n',
              'ң':'n',
              'о':'o',
              'ө':'o',
              'п':'p',
              'р':'r',
              'с':'s',
              'т':'t',
              'у':'u',
              'ұ':'u',
              'ү':'u',
              'ф':'f',
              'х':['kh','h'],
              'ц':['c','ts'],
              'ч':'ch',
              'ш':'sh',
              'щ':'sh',
              'ъ':'',
              'ы':['y','i'],
              'і':'i',
              'ь':'',
              'э':'e',
              'ю':'yu',
              'я':'ya'
}

vowels = ['а', 'ә', 'е', 'и', 'й', 'о', 'ө', 'у', 'ы', 'э', ' ']

#  Translating function (cyr -> lat)
def translate_that_shit(s, add_vowel=False):
    s = s.lower()
    res = ""
    n = 0
    h = ""
    for i in s:
        if i in dictionary:
            if type(dictionary[i]) != list:
                res += dictionary[i]
            else:
                if add_vowel:
                    if (i == "е"):
                        if (n > 0):
                            if (s[n-1] in vowels):
                                res += dictionary[i][1]
                            else:
                                res += dictionary[i][0]
                        else:
                            res += dictionary[i][1]
                    else:
                        res += dictionary[i][0]
                else:
                    res += dictionary[i][0]
        else:
            res += i
        n += 1
    return res

#  Converting the first letter of name (cyr -> lat)
def convert_name(s, s_length=1):
    s = s.lower()
    res = ""
    for i in range(0, s_length - 1):
        if s[i] in dictionary:
            res += translate_that_shit(s[i])
        else:
            res += s[i]
    return res