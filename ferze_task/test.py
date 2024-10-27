def check(arr):
    for i in range(len(arr)):
        for j in range(len(arr)):
            if i != j and (abs(i - j) == abs(arr[i] - arr[j]) or arr[i] == arr[j]):
                return False
    return True

count = 0
for i1 in range(8):
    pos1 = i1
    for i2 in range(8):
        pos2 = i2
        for i3 in range(8):
            pos3 = i3
            for i4 in range(8):
                pos4 = i4
                for i5 in range(8):
                    pos5 = i5
                    for i6 in range(8):
                        pos6 = i6
                        for i7 in range(8):
                            pos7 = i7
                            for i8 in range(8):
                                pos8 = i8
                                arr = [pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8]
                                if check(arr):
                                    print(f'a{arr[0]+1}b{arr[1]+1}c{arr[2]+1}d{arr[3]+1}e{arr[4]+1}f{arr[5]+1}g{arr[6]+1}h{arr[7]+1}')